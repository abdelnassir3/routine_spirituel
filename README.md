# Projet Spiritual Routines

Application mobile de routines spirituelles bilingue français-arabe développée avec Flutter.

## 🚀 Quick Start

```bash
# Installation
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Développement
flutter run                    # Debug mode
flutter run --release          # Release mode pour tests perf

# Génération de code (après modifications modèles)
dart run build_runner watch --delete-conflicting-outputs
```

## 🛠 Qualité & Commandes

```bash
# Tests
./scripts/test.sh               # Tests complets avec coverage
flutter test --reporter=expanded

# Linting et formatage
./scripts/lint.sh               # Analyse complète
flutter analyze                 # Analyse statique
dart format .                   # Formatage code

# Build production
flutter build apk --release     # Android APK
flutter build appbundle --release # Android App Bundle  
flutter build ios --release     # iOS (macOS requis)
```

## 📚 Documentation

- [BRIEF](docs/BRIEF.md) - Objectifs produit et fonctionnalités
- [CONTRAINTES](docs/CONTRAINTES.md) - Contraintes techniques et charte qualité
- [SERVEURS](docs/SERVEURS.md) - Configuration serveurs TTS et APIs
- [CLAUDE.md](CLAUDE.md) - Guide développement avec Claude Code

## 🏗 Architecture

Flutter 3.x • Riverpod • Drift/Isar • Material Design 3 • TTS Hybride
