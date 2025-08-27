import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:spiritual_routines/core/platform/platform_service.dart';

/// Wrapper pour l'OCR qui fonctionne sur toutes les plateformes
class OCRWrapper {
  final PlatformService _platform = PlatformService.instance;

  /// Vérifie si l'OCR est disponible sur cette plateforme
  bool get isOCRAvailable => _platform.supportsOCR;

  /// Extrait le texte d'une image de manière cross-platform
  Future<String?> extractTextFromImage(String imagePath) async {
    if (!isOCRAvailable) {
      // Sur desktop, on pourrait utiliser une API web ou Tesseract
      return _extractTextFallback(imagePath);
    }

    // Sur mobile, utiliser google_mlkit_text_recognition
    if (_platform.isMobile) {
      try {
        // Import conditionnel pour éviter les erreurs sur desktop
        if (_platform.isAndroid || _platform.isIOS) {
          final textRecognizer = await _getMobileTextRecognizer();
          return await textRecognizer?.processImage(imagePath);
        }
      } catch (e) {
        debugPrint('Erreur OCR mobile: $e');
      }
    }

    return null;
  }

  /// Méthode fallback pour desktop
  Future<String?> _extractTextFallback(String imagePath) async {
    // Options pour desktop :
    // 1. Utiliser une API web OCR (nécessite connexion)
    // 2. Intégrer Tesseract via FFI
    // 3. Demander à l'utilisateur de saisir le texte manuellement

    debugPrint('OCR non disponible sur desktop. Alternatives :');
    debugPrint('1. Saisie manuelle du texte');
    debugPrint('2. Import d\'un fichier texte');

    // Pour l'instant, retourner null
    return null;
  }

  /// Obtient le recognizer mobile de manière conditionnelle
  Future<dynamic> _getMobileTextRecognizer() async {
    try {
      // Cette importation ne sera exécutée que sur mobile
      if (_platform.isMobile) {
        // Le code réel importerait google_mlkit_text_recognition ici
        // Pour éviter les erreurs de compilation sur desktop, on le garde dynamique
        return null; // Placeholder - implémenter avec import conditionnel
      }
    } catch (e) {
      debugPrint('Impossible de charger OCR mobile: $e');
    }
    return null;
  }

  /// Obtient un message d'aide pour l'utilisateur
  String getUnavailableMessage() {
    if (_platform.isDesktop) {
      return 'La reconnaissance de texte n\'est pas encore disponible sur desktop.\n'
          'Vous pouvez importer directement un fichier texte ou saisir le contenu manuellement.';
    } else if (_platform.isWeb) {
      return 'La reconnaissance de texte n\'est pas disponible sur la version web.\n'
          'Veuillez utiliser l\'application mobile ou desktop.';
    } else {
      return 'La reconnaissance de texte n\'est pas disponible sur cette plateforme.';
    }
  }
}
