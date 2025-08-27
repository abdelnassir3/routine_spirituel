#!/bin/bash
set -e

echo "🔍 Running Flutter Analysis..."
flutter analyze --fatal-infos

echo "📐 Checking code formatting..."
dart format --output=none --set-exit-if-changed .

echo "📦 Checking dependencies..."
dart pub outdated --no-dev-dependencies

echo "✅ Linting completed successfully!"
echo "Run 'dart format .' to fix formatting issues if any."