#!/bin/bash
# Script helper pour les commandes FVM courantes
# Assure l'utilisation cohérente de FVM sur tous les systèmes

FVM_PATH="$HOME/.pub-cache/bin/fvm"

case "$1" in
  "get")
    echo "📦 Installation des dépendances avec FVM..."
    $FVM_PATH flutter pub get
    ;;
  "run")
    echo "🚀 Lancement de l'application..."
    $FVM_PATH flutter run -d chrome --web-port=52047
    ;;
  "test")
    echo "🧪 Lancement des tests..."
    $FVM_PATH flutter test
    ;;
  "build")
    echo "🏗️ Build de l'application..."
    shift
    $FVM_PATH flutter build $@
    ;;
  "clean")
    echo "🧹 Nettoyage du projet..."
    $FVM_PATH flutter clean
    ;;
  "doctor")
    echo "🔍 Vérification de l'environnement..."
    $FVM_PATH flutter doctor
    ;;
  "analyze")
    echo "📊 Analyse du code..."
    $FVM_PATH flutter analyze
    ;;
  *)
    echo "Utilisation: ./fvm_commands.sh [get|run|test|build|clean|doctor|analyze]"
    echo ""
    echo "Commandes disponibles:"
    echo "  get      - Installer les dépendances"
    echo "  run      - Lancer l'app sur Chrome (port 52047)"
    echo "  test     - Exécuter les tests"
    echo "  build    - Compiler l'application"
    echo "  clean    - Nettoyer les fichiers générés"
    echo "  doctor   - Vérifier l'environnement Flutter"
    echo "  analyze  - Analyser le code"
    ;;
esac