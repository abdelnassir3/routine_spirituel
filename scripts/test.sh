#!/bin/bash
set -e

echo "🧪 Adding test package if missing..."
dart pub add --dev test 2>/dev/null || true

echo "📦 Getting dependencies..."
flutter pub get

echo "🏗️  Building generated code..."
dart run build_runner build --delete-conflicting-outputs

echo "🧪 Running tests (excluding web-only tests on non-web platforms)..."
# Exécuter uniquement les tests unitaires et widgets sur plateformes non-web
flutter test test/unit/ test/widgets/ --reporter=expanded --coverage

echo "✅ Tests completed!"
echo "Coverage report generated in coverage/lcov.info"