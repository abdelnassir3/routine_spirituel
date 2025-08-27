#!/usr/bin/env bash
set -euo pipefail
MSG=${1:-"savepoint"}
git add -A
git commit -m "savepoint: ${MSG}" >/dev/null 2>&1 || true  # pas d'erreur si rien à committer
git tag -f savepoint-latest
echo "✅ Savepoint créé -> tag savepoint-latest"
