#!/bin/bash

# Script de développement avec proxy CORS pour APIs Quran
# Usage: ./scripts/dev_with_proxy.sh

set -e

echo "🚀 Démarrage de l'environnement de développement avec proxy CORS..."

# Vérifier que Node.js est installé
if ! command -v node &> /dev/null; then
    echo "❌ Node.js n'est pas installé. Installez-le d'abord."
    exit 1
fi

# Fonction pour nettoyer à l'arrêt
cleanup() {
    echo "\n🛑 Arrêt des services..."
    if [[ -n $PROXY_PID ]]; then
        kill $PROXY_PID 2>/dev/null || true
        echo "✅ Proxy CORS arrêté"
    fi
    if [[ -n $FLUTTER_PID ]]; then
        kill $FLUTTER_PID 2>/dev/null || true
        echo "✅ Flutter arrêté"
    fi
    exit 0
}

# Configurer le signal handler
trap cleanup SIGINT SIGTERM

# Démarrer le proxy CORS en arrière-plan
echo "🌐 Démarrage du proxy CORS sur http://localhost:3000..."
node scripts/cors_proxy.js &
PROXY_PID=$!

# Attendre que le proxy soit prêt
sleep 2

# Vérifier que le proxy fonctionne
if ! curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "❌ Le proxy CORS n'a pas démarré correctement"
    cleanup
    exit 1
fi

echo "✅ Proxy CORS démarré avec succès"
echo "📋 URLs de test:"
echo "   - Proxy: http://localhost:3000"
echo "   - Test: http://localhost:3000/?url=https://cdn.alquran.cloud/media/audio/ayah/ar.sudais/674"

# Démarrer Flutter
echo "\n📱 Démarrage de l'application Flutter..."
echo "   Mode: développement avec proxy CORS activé"
echo "   Utilisez Ctrl+C pour arrêter tous les services\n"

# Lancer Flutter en mode web avec port personnalisé
flutter run -d chrome --web-port 8080 &
FLUTTER_PID=$!

# Attendre que les processus se terminent
wait $FLUTTER_PID
cleanup
