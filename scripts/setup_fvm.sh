#!/bin/bash
# Script de configuration FVM pour le projet

set -e

echo "🚀 Configuration FVM pour Spiritual Routines..."

# Vérifier si FVM est installé
if ! command -v fvm &> /dev/null; then
    echo "❌ FVM n'est pas installé"
    echo "👉 Installation: dart pub global activate fvm"
    exit 1
fi

# Installer Flutter 3.32.8 si nécessaire
echo "📦 Installation Flutter 3.32.8..."
fvm install 3.32.8

# Utiliser cette version pour le projet
echo "🔧 Configuration du projet..."
fvm use 3.32.8

# Vérifier la version
echo "✅ Version Flutter configurée:"
fvm flutter --version

# Installation des dépendances
echo "📥 Installation des dépendances..."
fvm flutter pub get

# Génération du code
echo "🔨 Génération du code..."
fvm flutter packages pub run build_runner build --delete-conflicting-outputs

echo "✅ Configuration FVM terminée!"
echo "👉 Utiliser 'fvm flutter' au lieu de 'flutter' pour toutes les commandes"