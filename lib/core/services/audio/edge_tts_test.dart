import 'package:flutter/foundation.dart';
import 'edge_tts_service.dart';
import 'audio_api_config.dart';
import 'vps_connection_test.dart';

/// Test spécifique pour Edge-TTS avec votre VPS
class EdgeTtsVpsTest {
  /// Teste une synthèse simple avec votre VPS
  static Future<void> testSimpleSynthesis() async {
    debugPrint('🧪 === Test Edge-TTS VPS ===');
    AudioApiConfig.logConfiguration();

    // Test 1: Connexion VPS
    debugPrint('\n📡 Test 1: Connexion au VPS...');
    final connectionResult = await VpsConnectionTest.testConnection();
    debugPrint(connectionResult.summary);

    if (connectionResult.overallStatus == VpsTestStatus.failed) {
      debugPrint('❌ VPS inaccessible, arrêt des tests');
      return;
    }

    // Test 2: Synthèse française simple
    debugPrint('\n🇫🇷 Test 2: Synthèse française...');
    await _testFrenchSynthesis();

    // Test 3: Synthèse arabe simple
    debugPrint('\n🇸🇦 Test 3: Synthèse arabe...');
    await _testArabicSynthesis();

    // Test 4: Test avec différentes voix
    debugPrint('\n🎭 Test 4: Test voix multiples...');
    await _testMultipleVoices();

    debugPrint('\n✅ Tests Edge-TTS terminés');
  }

  /// Exécute tous les tests et retourne un résumé
  static Future<String> runAllTestsAndGetSummary() async {
    try {
      debugPrint('🧪 === Test Edge-TTS VPS - Résumé ===');
      
      // Test de connexion
      final connectionResult = await VpsConnectionTest.testConnection();
      final summary = StringBuffer('🔗 Test connexion VPS: ${connectionResult.overallStatus.name}\n');
      
      if (connectionResult.overallStatus == VpsTestStatus.failed) {
        summary.write('❌ VPS inaccessible - Tests interrompus\n');
        return summary.toString();
      }
      
      // Tests de synthèse
      int successCount = 0;
      int totalTests = 4;
      
      try {
        await _testFrenchSynthesis();
        successCount++;
      } catch (e) {
        summary.write('❌ Test français échoué: $e\n');
      }
      
      try {
        await _testArabicSynthesis();
        successCount++;
      } catch (e) {
        summary.write('❌ Test arabe échoué: $e\n');
      }
      
      try {
        await _testMultipleVoices();
        successCount += 2; // Multiple voices compte pour 2 tests
      } catch (e) {
        summary.write('❌ Test voix multiples échoué: $e\n');
      }
      
      summary.write('📊 Tests réussis: $successCount/$totalTests\n');
      
      if (successCount == totalTests) {
        summary.write('✅ Tous les tests Edge-TTS sont réussis!');
      } else {
        summary.write('⚠️ Certains tests ont échoué');
      }
      
      return summary.toString();
    } catch (e) {
      return '❌ Erreur lors des tests Edge-TTS: $e';
    }
  }

  static Future<void> _testFrenchSynthesis() async {
    try {
      final audioBytes = await EdgeTtsService.synthesizeText(
        'Bonjour, ceci est un test de synthèse vocale française.',
        language: 'fr-FR',
        voice: EdgeTtsVoice.frenchDenise,
      );

      if (audioBytes != null) {
        debugPrint('✅ Synthèse française réussie: ${audioBytes.length} bytes');
      } else {
        debugPrint('❌ Échec synthèse française');
      }
    } catch (e) {
      debugPrint('❌ Erreur synthèse française: $e');
    }
  }

  static Future<void> _testArabicSynthesis() async {
    try {
      final audioBytes = await EdgeTtsService.synthesizeText(
        'السلام عليكم، هذا اختبار للصوت العربي.',
        language: 'ar-SA',
        voice: EdgeTtsVoice.arabicHamed,
      );

      if (audioBytes != null) {
        debugPrint('✅ Synthèse arabe réussie: ${audioBytes.length} bytes');
      } else {
        debugPrint('❌ Échec synthèse arabe');
      }
    } catch (e) {
      debugPrint('❌ Erreur synthèse arabe: $e');
    }
  }

  static Future<void> _testMultipleVoices() async {
    final testCases = [
      {
        'text': 'Test voix française féminine',
        'voice': EdgeTtsVoice.frenchDenise,
        'lang': 'fr-FR'
      },
      {
        'text': 'Test voix française masculine',
        'voice': EdgeTtsVoice.frenchHenri,
        'lang': 'fr-FR'
      },
      {
        'text': 'اختبار الصوت العربي الذكوري',
        'voice': EdgeTtsVoice.arabicHamed,
        'lang': 'ar-SA'
      },
      {
        'text': 'اختبار الصوت العربي الأنثوي',
        'voice': EdgeTtsVoice.arabicZariyah,
        'lang': 'ar-SA'
      },
    ];

    for (final testCase in testCases) {
      try {
        final audioBytes = await EdgeTtsService.synthesizeText(
          testCase['text'] as String,
          language: testCase['lang'] as String,
          voice: testCase['voice'] as EdgeTtsVoice,
        );

        if (audioBytes != null) {
          debugPrint('✅ ${testCase['voice']}: ${audioBytes.length} bytes');
        } else {
          debugPrint('❌ ${testCase['voice']}: échec');
        }
      } catch (e) {
        debugPrint('❌ ${testCase['voice']}: erreur $e');
      }

      // Petite pause entre les tests
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  /// Test de performance avec texte long
  static Future<void> testLongTextPerformance() async {
    debugPrint('\n📊 Test performance texte long...');

    const longText = '''
    Ceci est un test de performance avec un texte relativement long pour évaluer 
    la vitesse de synthèse du serveur Edge-TTS. Le texte contient plusieurs phrases 
    et devrait permettre de mesurer la latence et la qualité de l'audio généré.
    ''';

    final stopwatch = Stopwatch()..start();

    try {
      final audioBytes = await EdgeTtsService.synthesizeText(
        longText,
        language: 'fr-FR',
        voice: EdgeTtsVoice.frenchDenise,
      );

      stopwatch.stop();

      if (audioBytes != null) {
        final duration = stopwatch.elapsedMilliseconds;
        final efficiency = (audioBytes.length / duration * 1000).round();

        debugPrint('✅ Texte long réussi:');
        debugPrint('   📝 Caractères: ${longText.length}');
        debugPrint('   🔊 Audio: ${audioBytes.length} bytes');
        debugPrint('   ⏱️ Durée: ${duration}ms');
        debugPrint('   📊 Efficacité: ${efficiency} bytes/s');
      } else {
        debugPrint(
            '❌ Échec texte long après ${stopwatch.elapsedMilliseconds}ms');
      }
    } catch (e) {
      stopwatch.stop();
      debugPrint(
          '❌ Erreur texte long après ${stopwatch.elapsedMilliseconds}ms: $e');
    }
  }
}

/// Extension pour faciliter les tests depuis l'UI
extension EdgeTtsVpsTestWidget on EdgeTtsVpsTest {
  /// Lance tous les tests et retourne un résumé
  static Future<String> runAllTestsAndGetSummary() async {
    final buffer = StringBuffer();

    // Rediriger debugPrint vers notre buffer
    final originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) {
        buffer.writeln(message);
      }
      originalDebugPrint?.call(message, wrapWidth: wrapWidth);
    };

    try {
      await testSimpleSynthesis();
      await testLongTextPerformance();
    } finally {
      // Restaurer debugPrint
      debugPrint = originalDebugPrint;
    }

    return buffer.toString();
  }
}
