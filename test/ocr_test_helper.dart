import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spiritual_routines/services/ocr/ocr_service.dart';
import 'package:spiritual_routines/services/ocr/ocr_wrapper.dart';

/// Helper pour tester les fonctionnalités OCR
class OCRTestHelper {
  
  /// Vérifie que l'OCR est disponible sur la plateforme actuelle
  static Future<void> checkOCRAvailability() async {
    print('🔍 Vérification de la disponibilité OCR...');
    
    final ocrWrapper = OCRWrapper();
    final isAvailable = await ocrWrapper.isAvailable();
    
    if (isAvailable) {
      print('✅ OCR disponible sur cette plateforme');
      print('📱 Service utilisé: ${ocrWrapper.currentService.runtimeType}');
    } else {
      print('❌ OCR non disponible');
      print('💡 Assurez-vous d\'être sur iOS/Android');
    }
  }
  
  /// Test OCR avec une image locale
  static Future<void> testLocalImage(String imagePath) async {
    print('🖼️ Test OCR sur: $imagePath');
    
    try {
      final ocrWrapper = OCRWrapper();
      final result = await ocrWrapper.recognizeTextFromImage(imagePath);
      
      if (result != null && result.isNotEmpty) {
        print('✅ Texte extrait avec succès:');
        print('---');
        print(result);
        print('---');
        print('📊 Nombre de caractères: ${result.length}');
      } else {
        print('⚠️ Aucun texte détecté');
      }
    } catch (e) {
      print('❌ Erreur OCR: $e');
    }
  }
  
  /// Affiche les langues supportées
  static void showSupportedLanguages() {
    print('🌍 Langues OCR supportées:');
    print('  - iOS/macOS (Vision): Français, Arabe, Anglais (auto-détection)');
    print('  - Android (ML Kit): Français, Anglais');
    print('  - Android (Tesseract): Français, Arabe (avec traineddata)');
  }
}

// Exemple d'utilisation dans un test
void main() {
  test('OCR availability test', () async {
    await OCRTestHelper.checkOCRAvailability();
    OCRTestHelper.showSupportedLanguages();
  });
}