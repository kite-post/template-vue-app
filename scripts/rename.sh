#!/usr/bin/env bash
# Перетворює шаблон у репозиторій конкретного застосунку: ім'я пакета,
# ім'я образу та заголовок сторінки.
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Вкажи ім'я застосунку, наприклад kite-web" >&2
  exit 1
fi
name="$1"

if [[ ! "$name" =~ ^[a-z][a-z0-9-]*$ ]]; then
  echo "Ім'я застосунку — малі літери, цифри і дефіси: kite-web" >&2
  exit 1
fi

echo "Застосунок: $name"

while IFS= read -r f; do
  perl -pi -e "s/vue-app-template/$name/g" "$f"
done < <(find . -type f \
  \( -name '*.json' -o -name '*.ts' -o -name '*.vue' -o -name '*.md' -o -name '*.html' -o -name '*.yml' \) \
  -not -path './.git/*' -not -path './node_modules/*' -not -path './dist/*')

echo
echo "Готово. Далі:"
echo "  make install lint types test"
echo "  git add -A && git commit -m \"Перейменувати шаблон у $name\""
