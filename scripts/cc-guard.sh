#!/usr/bin/env bash
set -euo pipefail
if [ $# -lt 1 ]; then
  echo "Usage: $0 <commande...>"; exit 2
fi

MSG="before: $*"
git add -A
git commit -m "savepoint: ${MSG}" >/dev/null 2>&1 || true
git tag -f savepoint-latest
PREV=$(git rev-parse HEAD)

set +e
"$@"
CODE=$?
set -e

if [ $CODE -ne 0 ]; then
  echo "❌ Commande échouée ($CODE). Restauration…"
  git reset --hard "$PREV" >/dev/null
  exit $CODE
fi
echo "✅ Commande réussie"
