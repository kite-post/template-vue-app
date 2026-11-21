# template-vue-app

Шаблон репозиторію для веб-застосунку Kite: Vue 3, Vite 8, TypeScript, Pinia,
Vue Router, vue-i18n, pnpm 12 на Node 26. Із нього створюються kite-web,
kite-business, kite-ops і kite-box-screen (5.2).

## Новий застосунок

```bash
gh repo create kite-post/kite-web --public --template kite-post/template-vue-app
cd kite-web
make rename NAME=kite-web
git add -A && git commit -m "Перейменувати шаблон у kite-web" && git push
```

## Що всередині

```
src/main.ts               точка входу: Pinia, Router, i18n
src/App.vue               оболонка з <RouterView>
src/views/HomeView.vue    сторінка, підтягується лінивим чанком
src/components/           InfoCard.vue і тест на нього
src/stores/info.ts        приклад стора з викликом через шлюз
src/locales/              uk і en; типізовані словники
eslint.config.ts          ESLint 9 flat config — у TypeScript, не в JS
nginx.conf                SPA-фолбек, кеш на /assets, /healthz
Dockerfile                pnpm-збірка → статика в nginx
Makefile                  той самий набір цілей, що й у решти репозиторіїв
.github/workflows/ci.yml  п'ять рядків: виклик спільного workflow із .github
```

Увесь інструментарій і конфіги — TypeScript: `vite.config.ts`,
`eslint.config.ts`, словники локалізації. Жодного `.js` у репозиторії немає
навмисно — конфіг теж код, і він теж має перевірятися типами.

TypeScript закріплений на 6.0, хоча 7.0 уже вийшов: 7.x — це нативний порт,
який живе паралельно з 6.x, і typescript-eslint його поки не підтримує
(peer-діапазон `>=4.8.4 <6.1.0`). Щойно підтримка з'явиться, достатньо буде
підняти одне поле.

## Команди

```bash
make install    # pnpm install --frozen-lockfile
make run        # Vite dev-сервер на 3000 з проксі /api на шлюз
make lint       # ESLint + prettier --check
make fmt        # виправити те, що виправляється
make types      # vue-tsc
make test       # Vitest одним проходом
make build      # статика у ./dist
make verify     # усе, що робить CI
make image      # образ з nginx
make up         # підняти образ на 3000
```

pnpm, не npm: один store на всі чотири застосунки замість чотирьох копій
`node_modules`, і `--frozen-lockfile` у CI падає, якщо lock-файл розійшовся з
`package.json`. Версія pnpm закріплена полем `packageManager`: локально її
бере corepack, у CI — `pnpm/action-setup`, а в образі вона ставиться через
`npm install -g`, бо з Node 26 corepack уже не входить до дистрибутива.

## Контракти

Типи REST і подій, реєстр топіків і типізований клієнт API приходять пакетом
`@kite-post/contracts` з GitHub Packages, закріпленим точною версією — своїх копій
`openapi.yaml` і JSON Schema застосунок не тримає (5.4, п. 6).

```bash
make contracts            # поставити пакет за поточним тегом
make contracts V=0.3.0    # перейти на нову версію: Makefile + package.json + lock
make contracts-check      # версія точна, lock узгоджений, копій схем немає
```

```ts
import { createKiteClient } from '@kite-post/contracts'

const api = createKiteClient({ baseUrl: import.meta.env.VITE_API_BASE_URL })
const { data } = await api.GET('/public/track/{trackingNumber}', {
  params: { path: { trackingNumber } },
})
```

Нова версія приходить сама: після релізу `kite-contracts` розсилає подію
всім репозиторіям із топіком `kite-contracts`, і workflow `contracts-bump`
відкриває PR з `make contracts V=<версія>`. Версія одна на всі репозиторії.
Руками те саме: `make contracts V=0.3.0`. Якщо тегу немає, `Makefile` і
маніфест лишаються як були.

Пакет приватний, як і `@kite-post/ui`: локально потрібен токен з
`read:packages`, у CI вистачає вбудованого `GITHUB_TOKEN`, а в збірку образу
токен їде секретом BuildKit (`npmrc`) і в шарах не лишається.

## CI

Увесь пайплайн — виклик спільного workflow з
[kite-post/.github](https://github.com/kite-post/.github): ESLint, vue-tsc,
Vitest, збірка, образ з nginx у `ghcr.io/kite-post/<застосунок>` і PR у
`kite-infra` з новою версією (12.6).

## Адреса API

Vite запікає змінні `VITE_*` у збірку, тому адреса шлюзу приходить аргументом
збірки образу:

```bash
docker build --build-arg VITE_API_BASE_URL=/api/v1 -t kite-web:dev .
```

Типове значення — `/api/v1`: у стенді nginx і шлюз за одним хостом, тож
відносний шлях працює без CORS. У розробці те саме робить проксі Vite
(`VITE_API_PROXY`, типово `http://localhost:8080`).

## Коли підключатимемо @kite-post/ui

UI-кит живе в окремому репозиторії і приходить npm-пакетом з GitHub Packages,
закріпленим за версією (5.2). `.npmrc` для цього вже налаштований: скоуп
`@kite-post` дивиться на `npm.pkg.github.com`, той самий, що й для
контрактів. Локально потрібен токен з `read:packages`, у CI вистачає
вбудованого `GITHUB_TOKEN`.
