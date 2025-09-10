#!/bin/bash

# Script pour lancer Flutter avec Device Preview activé
# Usage: ./scripts/run_with_device_preview.sh

echo "🚀 Lancement de Flutter avec Device Preview activé..."
echo "📱 Device Preview sera disponible sur http://localhost:52044"
echo ""

# Lancer Flutter en mode web avec Device Preview
flutter run -d chrome --web-port=52044 --dart-define=DEVICE_PREVIEW=true

# Alternative : Si vous voulez lancer sans la variable d'environnement
# (maintenant que le code est modifié pour activer Device Preview automatiquement sur web)
# flutter run -d chrome --web-port=52044