# Guide de Compatibilité Cross-Platform

## 🎯 Objectif
Assurer que l'application fonctionne identiquement sur toutes les plateformes : iOS, Android, macOS, Windows, Linux et Web.

## ✅ Changements Appliqués

### 1. **Permissions et Entitlements macOS**
Les entitlements macOS ont été mis à jour pour correspondre aux capacités iOS :
- ✅ Accès réseau client
- ✅ Accès fichiers utilisateur
- ✅ Microphone
- ✅ Caméra
- ✅ Photothèque

### 2. **Service de Plateforme Unifié**
Nouveau fichier : `lib/core/platform/platform_service.dart`
- Détection automatique de la plateforme
- Capacités disponibles par plateforme
- Configuration UI adaptative
- Chemins et dimensions spécifiques

### 3. **Wrappers Cross-Platform**

#### **OCR Wrapper** (`ocr_wrapper.dart`)
- ✅ Mobile : google_mlkit_text_recognition
- ⚠️ Desktop : Fallback vers saisie manuelle ou import fichier
- 🔄 Web : Non disponible

#### **Audio Wrapper** (`audio_wrapper.dart`)
- ✅ TTS : Toutes plateformes
- ✅ Audio playback : Toutes plateformes
- ⚠️ Background audio : Mobile uniquement
- ✅ Configuration adaptée par plateforme

#### **Permission Wrapper** (`permission_wrapper.dart`)
- ✅ Mobile : permission_handler standard
- ✅ macOS : Entitlements + permissions système
- ✅ Windows/Linux : Permissions automatiques
- ✅ Web : Pas de permissions nécessaires

#### **Media Picker Wrapper** (`media_picker_wrapper.dart`)
- ✅ Mobile : image_picker pour caméra/galerie
- ✅ Desktop : file_picker pour sélection fichiers
- ⚠️ Caméra desktop : Non disponible en release
- ✅ Sélection multiple : Toutes plateformes

### 4. **Widgets Adaptatifs**
Nouveau fichier : `lib/core/platform/platform_adaptive_widget.dart`
- `PlatformAdaptiveButton` : Cupertino sur Apple, Material ailleurs
- `PlatformAdaptiveDialog` : Dialogues natifs par plateforme
- `PlatformAdaptiveProgressIndicator` : Indicateurs natifs
- `PlatformAdaptiveSwitch` : Switches natifs

## 📝 Guide d'Utilisation

### Exemple 1 : Utiliser l'OCR de manière cross-platform

```dart
import 'package:spiritual_routines/core/platform/ocr_wrapper.dart';

class MyWidget extends StatelessWidget {
  final OCRWrapper _ocr = OCRWrapper();
  
  Future<void> _extractText() async {
    if (_ocr.isOCRAvailable) {
      final text = await _ocr.extractTextFromImage(imagePath);
      // Utiliser le texte extrait
    } else {
      // Afficher message alternatif
      showDialog(
        title: 'OCR non disponible',
        content: _ocr.getUnavailableMessage(),
      );
    }
  }
}
```

### Exemple 2 : Picker d'image adaptatif

```dart
import 'package:spiritual_routines/core/platform/media_picker_wrapper.dart';

class ImageSelector extends StatelessWidget {
  final MediaPickerWrapper _picker = MediaPickerWrapper();
  
  Future<void> _selectImage() async {
    // Vérifier si la caméra est disponible
    if (_picker.isSourceAvailable(ImageSource.camera)) {
      // Afficher option caméra
    }
    
    // Sélectionner depuis la galerie (toujours disponible)
    final image = await _picker.pickImage(source: ImageSource.gallery);
  }
}
```

### Exemple 3 : Audio TTS cross-platform

```dart
import 'package:spiritual_routines/core/platform/audio_wrapper.dart';

class TTSReader extends StatefulWidget {
  final AudioWrapper _audio = AudioWrapper();
  
  @override
  void initState() {
    super.initState();
    _audio.initialize();
  }
  
  Future<void> _speak(String text, String language) async {
    await _audio.speak(text, language: language);
  }
  
  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }
}
```

### Exemple 4 : Widgets adaptatifs

```dart
import 'package:spiritual_routines/core/platform/platform_adaptive_widget.dart';

// Bouton adaptatif
PlatformAdaptiveButton(
  onPressed: () {},
  child: Text('Cliquez'),
);

// Dialogue adaptatif
PlatformAdaptiveDialog.show(
  context: context,
  title: 'Confirmation',
  content: 'Êtes-vous sûr ?',
  confirmText: 'Oui',
  cancelText: 'Non',
);

// Indicateur de chargement adaptatif
PlatformAdaptiveProgressIndicator();
```

## 🔧 Migration du Code Existant

### Étape 1 : Remplacer les imports directs

**Avant :**
```dart
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
```

**Après :**
```dart
import 'package:spiritual_routines/core/platform/ocr_wrapper.dart';
import 'package:spiritual_routines/core/platform/media_picker_wrapper.dart';
import 'package:spiritual_routines/core/platform/permission_wrapper.dart';
```

### Étape 2 : Utiliser les wrappers

**Avant :**
```dart
final textRecognizer = TextRecognizer();
final result = await textRecognizer.processImage(inputImage);
```

**Après :**
```dart
final ocr = OCRWrapper();
if (ocr.isOCRAvailable) {
  final text = await ocr.extractTextFromImage(imagePath);
}
```

### Étape 3 : Gérer les cas non supportés

```dart
if (!platform.supportsFeature) {
  // Afficher alternative ou message
  showDialog(
    title: 'Fonctionnalité non disponible',
    content: 'Cette fonctionnalité n\'est pas disponible sur ${platform.isDesktop ? "desktop" : "cette plateforme"}',
  );
}
```

## 🧪 Tests par Plateforme

### iOS
```bash
flutter run -d iphone
```

### Android
```bash
flutter run -d android
```

### macOS
```bash
flutter clean
flutter pub get
flutter run -d macos
```

### Windows
```bash
flutter clean
flutter pub get
flutter run -d windows
```

### Linux
```bash
flutter clean
flutter pub get
flutter run -d linux
```

### Web
```bash
flutter run -d chrome
```

## ⚠️ Limitations Connues

| Fonctionnalité | iOS | Android | macOS | Windows | Linux | Web |
|----------------|-----|---------|-------|---------|-------|-----|
| OCR | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Caméra | ✅ | ✅ | ⚠️ | ❌ | ❌ | ❌ |
| TTS | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ |
| Background Audio | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| File Picker | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Microphone | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ |

**Légende :**
- ✅ : Complètement supporté
- ⚠️ : Support partiel ou limité
- ❌ : Non supporté (alternative disponible)

## 🚀 Prochaines Étapes

1. **Tester** l'application sur toutes les plateformes
2. **Vérifier** que toutes les fonctionnalités marchent
3. **Ajuster** les UI selon les retours utilisateurs
4. **Optimiser** les performances par plateforme
5. **Documenter** les différences restantes

## 📱 Commandes de Build

### iOS
```bash
flutter build ios --release
```

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### macOS
```bash
flutter build macos --release
```

### Windows
```bash
flutter build windows --release
```

### Linux
```bash
flutter build linux --release
```

### Web
```bash
flutter build web --release
```