# syntax=docker/dockerfile:1

# ── Збірка ────────────────────────────────────────────────────────────────────
FROM node:26-alpine AS build
WORKDIR /build

# У Node 26 corepack уже не входить до дистрибутива, тож pnpm ставимо явно.
# Версія — та сама, що в полі packageManager, інакше lock-файл може поїхати.
ARG PNPM_VERSION=12.21.0
ENV PNPM_HOME=/pnpm
ENV PATH="$PNPM_HOME:$PATH"
RUN npm install -g "pnpm@${PNPM_VERSION}"

# Залежності окремим шаром: lock-файл змінюється рідше за код.
COPY package.json pnpm-lock.yaml .npmrc ./
RUN --mount=type=cache,target=/pnpm/store \
    pnpm install --frozen-lockfile --store-dir /pnpm/store

COPY . .

# Vite запікає адресу API у збірку, тож вона приходить аргументом збірки.
ARG VITE_API_BASE_URL=/api/v1
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL
RUN pnpm run build

# ── Запуск ────────────────────────────────────────────────────────────────────
FROM nginx:1.31-alpine AS runtime

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /build/dist /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=15s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -q --spider http://localhost/healthz || exit 1
