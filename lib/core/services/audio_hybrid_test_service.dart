import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_service_hybrid_wrapper.dart';
import 'audio/content_detector_service.dart';
import 'audio/hybrid_audio_service.dart';
import 'tts_logger_service.dart';

/// Service de test pour valider le système audio hybride
class AudioHybridTestService {
  /// Teste différents types de contenu avec le système hybride
  static Future<void> runComprehensiveTest(WidgetRef ref) async {
    TtsLogger.info('🧪 Démarrage des tests audio hybride');

    final hybridWrapper = ref.read(audioServiceHybridWrapperProvider);

    // 1. Test avec verset coranique (doit utiliser API Quran)
    await _testQuranicContent(hybridWrapper);

    // 2. Test avec invocation islamique (doit utiliser Edge-TTS avec diacritisation)
    await _testIslamicDua(hybridWrapper);

    // 3. Test avec texte arabe simple (doit utiliser Edge-TTS)
    await _testArabicText(hybridWrapper);

    // 4. Test avec texte français (doit utiliser Edge-TTS)
    await _testFrenchText(hybridWrapper);

    // 5. Test avec contenu mixte
    await _testMixedContent(hybridWrapper);

    TtsLogger.info('✅ Tests audio hybride terminés');
  }

  /// Test 1: Contenu coranique
  static Future<void> _testQuranicContent(
      AudioServiceHybridWrapper service) async {
    TtsLogger.info('🕌 Test contenu coranique');

    final testTexts = [
      // Avec marqueur de verset
      '{{V:1:1}}بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      // Sans marqueur mais contenu reconnaissable
      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      // Autre verset
      '{{V:2:255}}اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
    ];

    for (final text in testTexts) {
      try {
        TtsLogger.info(
            '🎵 Test verset', {'text': text.substring(0, 30) + '...'});

        final analysis = await HybridAudioService.analyzeContentDetails(text);
        TtsLogger.info('📊 Analyse', {
          'type': analysis.contentType.toString(),
          'verses': analysis.verses.length,
        });

        // Test de détection seulement (pas de lecture audio réelle)
        final expectedType = ContentType.quranicVerse;
        if (analysis.contentType == expectedType) {
          TtsLogger.info('✅ Détection correcte: ${analysis.contentType}');
        } else {
          TtsLogger.warning('⚠️ Détection incorrecte', {
            'expected': expectedType.toString(),
            'actual': analysis.contentType.toString(),
          });
        }

        await Future.delayed(Duration(milliseconds: 100));
      } catch (e) {
        TtsLogger.error('❌ Erreur test verset', {'error': e.toString()});
      }
    }
  }

  /// Test 2: Invocations islamiques
  static Future<void> _testIslamicDua(AudioServiceHybridWrapper service) async {
    TtsLogger.info('🤲 Test invocations islamiques');

    final testTexts = [
      'بسم الله الرحمن الرحيم',
      'الحمد لله رب العالمين',
      'سبحان الله وبحمده سبحان الله العظيم',
      'اللهم صل على محمد وعلى آل محمد',
      'أستغفر الله العظيم الذي لا إله إلا هو الحي القيوم وأتوب إليه',
    ];

    for (final text in testTexts) {
      try {
        TtsLogger.info(
            '🎵 Test invocation', {'text': text.substring(0, 30) + '...'});

        final analysis = await HybridAudioService.analyzeContentDetails(text);
        TtsLogger.info('📊 Analyse invocation', {
          'type': analysis.contentType.toString(),
          'arabicRatio':
              (analysis.languageRatio.arabic * 100).toStringAsFixed(1) + '%',
        });

        // Les invocations peuvent être détectées comme islamicDua ou arabicText
        if (analysis.contentType == ContentType.islamicDua ||
            analysis.contentType == ContentType.arabicText) {
          TtsLogger.info('✅ Détection correcte pour invocation');
        } else {
          TtsLogger.warning('⚠️ Type inattendu pour invocation', {
            'type': analysis.contentType.toString(),
          });
        }

        await Future.delayed(Duration(milliseconds: 100));
      } catch (e) {
        TtsLogger.error('❌ Erreur test invocation', {'error': e.toString()});
      }
    }
  }

  /// Test 3: Texte arabe simple
  static Future<void> _testArabicText(AudioServiceHybridWrapper service) async {
    TtsLogger.info('🗣️ Test texte arabe simple');

    final testTexts = [
      'مرحبا كيف حالك؟',
      'هذا نص عربي عادي للاختبار',
      'أريد أن أتعلم اللغة العربية',
      'الطقس جميل اليوم',
    ];

    for (final text in testTexts) {
      try {
        TtsLogger.info('🎵 Test texte arabe', {'text': text});

        final analysis = await HybridAudioService.analyzeContentDetails(text);
        TtsLogger.info('📊 Analyse texte arabe', {
          'type': analysis.contentType.toString(),
          'arabicRatio':
              (analysis.languageRatio.arabic * 100).toStringAsFixed(1) + '%',
        });

        final expectedType = ContentType.arabicText;
        if (analysis.contentType == expectedType) {
          TtsLogger.info('✅ Détection correcte: texte arabe');
        } else {
          TtsLogger.warning('⚠️ Type inattendu pour texte arabe', {
            'expected': expectedType.toString(),
            'actual': analysis.contentType.toString(),
          });
        }

        await Future.delayed(Duration(milliseconds: 100));
      } catch (e) {
        TtsLogger.error('❌ Erreur test texte arabe', {'error': e.toString()});
      }
    }
  }

  /// Test 4: Texte français
  static Future<void> _testFrenchText(AudioServiceHybridWrapper service) async {
    TtsLogger.info('🇫🇷 Test texte français');

    final testTexts = [
      'Bonjour, comment allez-vous ?',
      'Ceci est un texte français pour les tests',
      'Je voudrais apprendre le français',
      'Il fait beau aujourd\'hui',
    ];

    for (final text in testTexts) {
      try {
        TtsLogger.info('🎵 Test texte français', {'text': text});

        final analysis = await HybridAudioService.analyzeContentDetails(text);
        TtsLogger.info('📊 Analyse texte français', {
          'type': analysis.contentType.toString(),
          'frenchRatio':
              (analysis.languageRatio.french * 100).toStringAsFixed(1) + '%',
        });

        final expectedType = ContentType.frenchText;
        if (analysis.contentType == expectedType) {
          TtsLogger.info('✅ Détection correcte: texte français');
        } else {
          TtsLogger.warning('⚠️ Type inattendu pour texte français', {
            'expected': expectedType.toString(),
            'actual': analysis.contentType.toString(),
          });
        }

        await Future.delayed(Duration(milliseconds: 100));
      } catch (e) {
        TtsLogger.error(
            '❌ Erreur test texte français', {'error': e.toString()});
      }
    }
  }

  /// Test 5: Contenu mixte
  static Future<void> _testMixedContent(
      AudioServiceHybridWrapper service) async {
    TtsLogger.info('🌍 Test contenu mixte');

    final testTexts = [
      'Bonjour مرحبا comment ça va؟',
      'Ceci est un test avec du texte عربي مختلط',
      'Hello سلام عليكم how are you كيف حالك؟',
    ];

    for (final text in testTexts) {
      try {
        TtsLogger.info('🎵 Test contenu mixte', {'text': text});

        final analysis = await HybridAudioService.analyzeContentDetails(text);
        TtsLogger.info('📊 Analyse contenu mixte', {
          'type': analysis.contentType.toString(),
          'arabicRatio':
              (analysis.languageRatio.arabic * 100).toStringAsFixed(1) + '%',
          'frenchRatio':
              (analysis.languageRatio.french * 100).toStringAsFixed(1) + '%',
        });

        final expectedType = ContentType.mixedLanguage;
        if (analysis.contentType == expectedType) {
          TtsLogger.info('✅ Détection correcte: contenu mixte');
        } else {
          TtsLogger.info('ℹ️ Type détecté pour contenu mixte', {
            'type': analysis.contentType.toString(),
            'note': 'Peut varier selon la langue dominante',
          });
        }

        await Future.delayed(Duration(milliseconds: 100));
      } catch (e) {
        TtsLogger.error('❌ Erreur test contenu mixte', {'error': e.toString()});
      }
    }
  }

  /// Test spécifique de la vitesse pour le contenu coranique
  static Future<void> testQuranicSpeedAdjustment() async {
    TtsLogger.info('⚡ Test ajustement vitesse coranique');

    final testSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5];

    for (final speed in testSpeeds) {
      // Simuler l'ajustement de vitesse pour récitation coranique
      final adjustedSpeed = (speed * 0.6 + 0.1).clamp(0.4, 0.8);

      TtsLogger.info('🎵 Ajustement vitesse', {
        'original': speed,
        'adjusted': adjustedSpeed,
        'reduction':
            '${((1 - adjustedSpeed / speed) * 100).toStringAsFixed(1)}%',
      });
    }
  }

  /// Affiche un résumé de la configuration hybride
  static void showHybridConfiguration(AudioServiceHybridWrapper service) {
    TtsLogger.info('⚙️ Configuration système hybride');

    final settings = service.getHybridSettings();

    TtsLogger.info('📋 Paramètres hybrides', settings);
  }

  /// Test de performance du système
  static Future<void> performanceTest(AudioServiceHybridWrapper service) async {
    TtsLogger.info('🚀 Test de performance');

    final startTime = DateTime.now();

    // Test de détection rapide sur plusieurs textes
    final testTexts = [
      '{{V:1:1}}بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', // Coranique
      'بسم الله الرحمن الرحيم', // Invocation
      'مرحبا كيف حالك؟', // Arabe
      'Bonjour comment allez-vous ?', // Français
      'Hello مرحبا mixed content', // Mixte
    ];

    for (int i = 0; i < testTexts.length; i++) {
      final text = testTexts[i];
      final analysisStartTime = DateTime.now();

      final analysis = await HybridAudioService.analyzeContentDetails(text);

      final analysisTime = DateTime.now().difference(analysisStartTime);

      TtsLogger.info('⏱️ Performance analyse', {
        'text': i + 1,
        'type': analysis.contentType.name,
        'time': '${analysisTime.inMilliseconds}ms',
      });
    }

    final totalTime = DateTime.now().difference(startTime);
    TtsLogger.info('🏁 Performance totale', {
      'totalTexts': testTexts.length,
      'totalTime': '${totalTime.inMilliseconds}ms',
      'averageTime':
          '${(totalTime.inMilliseconds / testTexts.length).toStringAsFixed(1)}ms',
    });
  }
}

/// Provider pour les tests audio hybride
final audioHybridTestServiceProvider = Provider<AudioHybridTestService>((ref) {
  return AudioHybridTestService();
});
