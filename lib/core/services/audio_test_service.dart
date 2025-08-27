import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_service_hybrid_wrapper.dart';
import 'tts_logger_service.dart';

/// Service simple pour tester l'audio hybride
class AudioTestService {
  
  /// Teste l'audio avec un texte arabe simple
  static Future<void> testArabicText(WidgetRef ref) async {
    TtsLogger.info('🧪 === DÉBUT TEST AUDIO ARABE ===');
    
    final hybridService = ref.read(audioTtsServiceHybridProvider);
    
    try {
      const testText = 'السلام عليكم ورحمة الله وبركاته، هذا اختبار للصوت العربي';
      
      TtsLogger.info('🎵 Test lecture arabe avec détection de fallback', {
        'text': testText,
        'longueur': testText.length,
        'speed_originale': 0.8,
        'expected': 'Fallback vers flutter_tts avec vitesse ajustée à ~0.48'
      });
      
      await hybridService.playText(
        testText,
        voice: 'ar-001',
        speed: 0.8, // Sera ajusté automatiquement dans le fallback
      );
      
      TtsLogger.info('✅ === FIN TEST AUDIO ARABE ===');
      
    } catch (e) {
      TtsLogger.error('❌ Erreur test arabe', {
        'error': e.toString(),
      });
    }
  }
  
  /// Teste l'audio avec un verset coranique
  static Future<void> testQuranicVerse(WidgetRef ref) async {
    TtsLogger.info('🧪 Test verset coranique');
    
    final hybridService = ref.read(audioTtsServiceHybridProvider);
    
    try {
      const testText = '{{V:1:1}}بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
      
      TtsLogger.info('🎵 Test verset coranique', {
        'text': testText,
        'longueur': testText.length,
      });
      
      await hybridService.playText(
        testText,
        voice: 'ar-001',
        speed: 1.0, // Sera ajusté automatiquement pour récitation
      );
      
      TtsLogger.info('✅ Test coranique terminé');
      
    } catch (e) {
      TtsLogger.error('❌ Erreur test coranique', {
        'error': e.toString(),
      });
    }
  }
  
  /// Teste l'audio avec du texte français
  static Future<void> testFrenchText(WidgetRef ref) async {
    TtsLogger.info('🧪 Test audio français');
    
    final hybridService = ref.read(audioTtsServiceHybridProvider);
    
    try {
      const testText = 'Bonjour, ceci est un test audio en français.';
      
      TtsLogger.info('🎵 Test lecture français', {
        'text': testText,
        'longueur': testText.length,
      });
      
      await hybridService.playText(
        testText,
        voice: 'fr-FR',
        speed: 0.8,
      );
      
      TtsLogger.info('✅ Test français terminé');
      
    } catch (e) {
      TtsLogger.error('❌ Erreur test français', {
        'error': e.toString(),
      });
    }
  }
  
  /// Lance tous les tests de manière séquentielle
  static Future<void> runAllTests(WidgetRef ref) async {
    TtsLogger.info('🚀 Démarrage de tous les tests audio');
    
    try {
      // Test 1: Texte arabe
      await testArabicText(ref);
      await Future.delayed(Duration(seconds: 3));
      
      // Test 2: Verset coranique
      await testQuranicVerse(ref);
      await Future.delayed(Duration(seconds: 3));
      
      // Test 3: Texte français
      await testFrenchText(ref);
      
      TtsLogger.info('🎉 Tous les tests audio terminés');
      
    } catch (e) {
      TtsLogger.error('❌ Erreur lors des tests', {
        'error': e.toString(),
      });
    }
  }
}

/// Provider pour les tests audio
final audioTestServiceProvider = Provider<AudioTestService>((ref) {
  return AudioTestService();
});