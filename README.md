# Projet Spiritual Routines

Application mobile de routines spirituelles bilingue français-arabe développée avec Flutter.

## 🚀 Quick Start

```bash
# Configuration FVM (recommandé)
./scripts/setup_fvm.sh          # Configuration automatique FVM + Flutter 3.32.8

# Installation manuelle (si pas de FVM)
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Développement
fvm flutter run                 # Debug mode (avec FVM)
fvm flutter run --release      # Release mode pour tests perf
fvm flutter run -d chrome      # Web avec Device Preview

# Génération de code (après modifications modèles)
dart run build_runner watch --delete-conflicting-outputs
```

## 🛠 Qualité & Commandes

```bash
# Tests
./scripts/test.sh               # Tests complets avec coverage
./scripts/test_golden.sh        # Tests golden (rendu UI)
./scripts/test_golden.sh update # Mettre à jour les goldens
fvm flutter test --reporter=expanded

# Linting et formatage
./scripts/lint.sh               # Analyse complète (Very Good Analysis)
fvm flutter analyze             # Analyse statique
dart format .                   # Formatage code

# Build multi-plateforme
fvm flutter build web --release       # Web (PWA)
fvm flutter build apk --release       # Android APK
fvm flutter build appbundle --release # Android App Bundle  
fvm flutter build ios --release --no-codesign # iOS
fvm flutter build macos --release     # macOS
```

## 🌐 Web Preview (flutter.js)

- Le bootstrap Web utilise désormais `flutter.js` (et non `flutter_bootstrap.js`).
- Le service worker est géré automatiquement par Flutter (voir `web/index.html`).
- Lancer la preview:

```bash
fvm flutter run -d chrome  # Device Preview actif en debug
```

Notes:
- Haptique: routé via un adaptateur — no‑op sur Web, natif sur mobile.
- TTS: via un adaptateur — Web Speech API si disponible, sinon simulation (aperçu fluide).
- Détails et matrice de parité: voir `docs/PARITY.md`.

## 📚 Documentation

- [BRIEF](docs/BRIEF.md) - Objectifs produit et fonctionnalités
- [CONTRAINTES](docs/CONTRAINTES.md) - Contraintes techniques et charte qualité
- [SERVEURS](docs/SERVEURS.md) - Configuration serveurs TTS et APIs
- [**PARITY.md**](docs/PARITY.md) - 🆕 Matrice parité multi-plateforme (iOS référence)
- [CLAUDE.md](CLAUDE.md) - Guide développement avec Claude Code

## 🔧 Outils de Développement

```bash
# Installation des outils (à faire une seule fois)
dart pub global activate fvm
dart pub global activate very_good_cli

# Configuration initiale du projet
./scripts/setup_fvm.sh

# Device Preview pour Web (debug responsive)
fvm flutter run -d chrome
# → Interface avec simulateurs iPhone/iPad/Desktop intégrée
```

## 🏗 Architecture

Flutter 3.x • Riverpod • Drift/Isar • Material Design 3 • TTS Hybride
