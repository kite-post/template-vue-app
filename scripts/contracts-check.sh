#!/usr/bin/env bash
# Перевіряє, що застосунок підключає @kite-post/contracts залежністю, закріпленою за
# тегом, і не тримає копій схем у себе (5.4, п. 6). Цю ціль проганяє CI.
set -euo pipefail

want="${1:?вкажи версію: scripts/contracts-check.sh 0.2.0}"

fail() {
  echo "contracts-check: $1" >&2
  exit 1
}

# 1. У package.json — точна версія, та сама, що в Makefile.
declared="$(node -p 'require("./package.json").dependencies?.["@kite-post/contracts"] ?? ""')"
[ -n "$declared" ] || fail "залежності @kite-post/contracts немає в package.json — проганяй make contracts V=…"
[ "$declared" = "$want" ] || fail "package.json закріплений за «$declared», а Makefile — за $want (лише точна версія, без ^ і ~)"

# 2. Lock-файл знає саме цю версію.
grep -q "'@kite-post/contracts@$want'\|/@kite-post/contracts@$want\|@kite-post/contracts@$want:" pnpm-lock.yaml \
  || fail "pnpm-lock.yaml не містить @kite-post/contracts@$want — проганяй make contracts"

# 3. Своїх копій схем у репозиторії бути не повинно.
copies="$(find . \( -path ./node_modules -o -path ./dist -o -path ./.git \) -prune -o \
  \( -name '*.schema.json' -o -name 'openapi.yaml' -o -name 'openapi.yml' -o -name 'openapi.json' -o -name 'asyncapi.yaml' \) \
  -print 2>/dev/null || true)"
[ -z "$copies" ] || fail "у репозиторії лежать копії схем, а мають приходити залежністю:
$copies"

# 4. Встановлено саме цю версію.
have="$(node -p 'require("./node_modules/@kite-post/contracts/package.json").version' 2>/dev/null || true)"
[ "$have" = "$want" ] || fail "у node_modules @kite-post/contracts «$have», а закріплено $want — проганяй make install"

echo "contracts-check: @kite-post/contracts $want підключений за тегом, копій схем немає."
