# template-vue-app

Шаблон репозиторію для веб-застосунку Kite: Vue 3, Vite, TypeScript, Pinia,
Vue Router, vue-i18n, pnpm. Із нього створюються kite-web, kite-business,
kite-ops і kite-box-screen (5.2).

## Новий застосунок

```bash
gh repo create kite-post/kite-web --private --template kite-post/template-vue-app
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
`package.json`. Версія pnpm закріплена полем `packageManager` — і локально
(через corepack), і в CI, і в образі вона та сама.

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

## Коли підключатимемо @kite/ui

UI-кит живе в окремому репозиторії і приходить npm-пакетом з GitHub Packages,
закріпленим за версією (5.2). `.npmrc` для цього вже налаштований: скоуп
`@kite` дивиться на `npm.pkg.github.com`. Локально потрібен токен з
`read:packages`, у CI вистачає вбудованого `GITHUB_TOKEN`.
