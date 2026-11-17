#!/usr/bin/env bash
# Підключає @kite-post/contracts за тегом: make contracts V=0.2.0 розставляє версію в
# Makefile і package.json (точну, без ^) і оновлює lock-файл. Без V — ставить
# поточну версію. Цим самим викликом користується CI, коли kite-contracts
# випускає новий тег. Пакет живе в GitHub Packages поруч з @kite/ui (5.2), тож
# потрібен NODE_AUTH_TOKEN з правом read:packages — як і для pnpm install.
set -euo pipefail

v="${1:?вкажи версію: scripts/contracts.sh 0.2.0}"
printf '%s' "$v" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' \
  || { echo "contracts: версія «$v» має бути вигляду 1.2.3" >&2; exit 1; }

# Правка атомарна: якщо тег не знайдеться, файли повертаються як були, і
# Makefile не розійдеться з package.json.
backup="$(mktemp -d)"
for f in Makefile package.json pnpm-lock.yaml; do cp "$f" "$backup/"; done
restore() { for f in Makefile package.json pnpm-lock.yaml; do cp "$backup/$f" "$f"; done; }
trap 'rc=$?; [ $rc -ne 0 ] && restore; exit $rc' EXIT

perl -pi -e "s|^CONTRACTS_VERSION \?= .*|CONTRACTS_VERSION ?= $v|" Makefile
pnpm add --save-exact "@kite-post/contracts@$v"
echo "@kite-post/contracts $v на місці: типи API і подій, реєстр і createKiteClient."
