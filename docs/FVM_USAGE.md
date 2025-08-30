# Guide d'utilisation FVM

## 🎯 Objectif
Utiliser FVM (Flutter Version Management) pour garantir une version Flutter cohérente sur tous les systèmes de développement.

## 📦 Installation de FVM
```bash
dart pub global activate fvm
```

## 🚀 Commandes rapides

### Avec les scripts fournis
```bash
# Lancer l'application sur Chrome
./run_web.sh

# Commandes courantes FVM
./fvm_commands.sh get      # Installer les dépendances
./fvm_commands.sh run      # Lancer sur Chrome (port 52047)
./fvm_commands.sh test     # Exécuter les tests
./fvm_commands.sh clean    # Nettoyer le projet
./fvm_commands.sh analyze  # Analyser le code
```

### Commandes FVM directes
```bash
# Chemin complet vers FVM
~/.pub-cache/bin/fvm flutter [commande]

# Exemples
~/.pub-cache/bin/fvm flutter pub get
~/.pub-cache/bin/fvm flutter run -d chrome --web-port=52047
~/.pub-cache/bin/fvm flutter test
~/.pub-cache/bin/fvm flutter build web
```

## 🌐 Ports utilisés
- **52047** : Port principal pour le développement web
- **52044** : Port alternatif (peut être utilisé par d'autres instances)

## ✅ Corrections appliquées pour la compatibilité Web

### Imports conditionnels
Tous les imports `dart:io` ont été rendus conditionnels :
```dart
import 'dart:io' show Platform, File, Directory 
  if (dart.library.html) 'package:spiritual_routines/core/platform/platform_stub.dart';
```

### Fichiers modifiés
- `lib/core/platform/platform_stub.dart` : Créé pour les stubs Web
- `lib/features/content/modern_content_editor_page.dart`
- `lib/features/settings/modern_settings_page.dart`
- `lib/features/reader/premium_reader_page.dart`
- `lib/features/reader/reader_page.dart`
- `lib/features/content/content_editor_page.dart`
- `lib/features/debug/security_dashboard_screen.dart`

## 📝 Notes importantes

1. **sql.js warning** : Normal sur Web, l'app utilise des stubs de données
2. **Platform detection** : Utilise `kIsWeb` avant d'accéder à `Platform`
3. **FVM Path** : FVM est installé dans `~/.pub-cache/bin/fvm`

## 🔧 Dépannage

### Port déjà utilisé
Si le port est occupé, utilisez un port différent :
```bash
~/.pub-cache/bin/fvm flutter run -d chrome --web-port=52048
```

### FVM non trouvé
Ajoutez FVM au PATH :
```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

## 📱 Développement multi-plateforme

L'application fonctionne maintenant sur :
- ✅ Web (Chrome, Safari, Firefox)
- ✅ iOS (via FVM)
- ✅ Android (via FVM)
- ✅ macOS (via FVM)

Utilisez toujours FVM pour garantir la cohérence entre les plateformes.