#!/bin/bash
# scripts/goldens.sh - Génération et update des goldens
set -e

echo "🎨 Goldens Management"
echo "===================="

MODE=${1:-test}

if [ "$MODE" = "update" ]; then
  echo "📸 Updating golden files..."
  flutter test --update-goldens test/goldens/
elif [ "$MODE" = "test" ]; then
  echo "✅ Testing golden files..."
  flutter test test/goldens/
elif [ "$MODE" = "clean" ]; then
  echo "🗑️ Cleaning golden files..."
  find test/goldens -name "*.png" -delete
else
  echo "Usage: $0 [test|update|clean]"
  exit 1
fi

echo "✨ Done!"