APP   ?= $(notdir $(CURDIR))
ORG   ?= kite-post
IMAGE ?= ghcr.io/$(ORG)/$(APP)
TAG   ?= dev
PORT  ?= 3000
# Тег kite-contracts, за яким закріплений застосунок. Той самий номер стоїть у
# package.json; contracts-check стежить, щоб вони не розійшлися.
CONTRACTS_VERSION ?= 0.2.1

.DEFAULT_GOAL := help
.PHONY: help install build lint fmt types test test-it verify image run up down clean contracts contracts-check rename

help: ## Показати цілі
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

install: ## Поставити залежності строго за lock-файлом
	pnpm install --frozen-lockfile

build: ## Зібрати статику у ./dist
	pnpm run build

lint: ## ESLint + перевірка форматування
	pnpm run lint

fmt: ## Виправити те, що виправляється
	pnpm run lint:fix

types: ## vue-tsc
	pnpm run type-check

test: ## Юніт-тести одним проходом
	pnpm run test:unit --run

test-it: test ## Для застосунків інтеграційні тести — це e2e, їх тут поки немає

verify: lint types test build ## Усе, що робить CI

image: ## Зібрати образ локально
	docker build -t $(IMAGE):$(TAG) .

run: ## Vite dev-сервер з проксі на шлюз
	pnpm run dev

up: image ## Підняти образ у контейнері
	docker run --rm -p $(PORT):80 --name $(APP) $(IMAGE):$(TAG)

down: ## Зупинити контейнер
	-docker rm -f $(APP)

clean: ## Прибрати збірку і кеші
	rm -rf dist coverage node_modules/.tmp node_modules/.vite

contracts: ## Підключити @kite-post/contracts за тегом; нова версія — make contracts V=0.2.0
	@bash scripts/contracts.sh "$(if $(V),$(V),$(CONTRACTS_VERSION))"

contracts-check: ## Перевірити, що контракти підключені за тегом і копій схем немає
	@bash scripts/contracts-check.sh "$(CONTRACTS_VERSION)"

rename: ## Перейменувати шаблон: make rename NAME=kite-web
	@test -n "$(NAME)" || (echo "Вкажи ім'я: make rename NAME=kite-web"; exit 1)
	@bash scripts/rename.sh "$(NAME)"
