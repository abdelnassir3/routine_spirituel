#!/bin/bash
set -e

echo "🌐 Running web-specific tests..."
echo "⚠️  Note: Ces tests ne fonctionneront que sur plateforme web"

echo "📦 Getting dependencies..."
flutter pub get

echo "🏗️  Building generated code..."
dart run build_runner build --delete-conflicting-outputs

echo "🧪 Running ALL tests including web integration..."
# Définir les variables d'environnement pour les tests web
export FLUTTER_WEB=true
export FLUTTER_TEST_PLATFORM=web

flutter test --reporter=expanded --coverage --platform web

echo "✅ Web tests completed!"
echo "Coverage report generated in coverage/lcov.info"