import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../smart_tts_enhanced_service.dart';

/// Test simple du système audio hybride
class HybridAudioTest {
  /// Teste le système avec différents types de contenu
  static Future<void> runTests(SmartTtsEnhancedService ttsService) async {
    debugPrint('🧪 === Test du Système Audio Hybride ===\n');

    // 1. Test contenu coranique
    await _testQuranicContent(ttsService);

    // 2. Test contenu français
    await _testFrenchContent(ttsService);

    // 3. Test invocation islamique
    await _testIslamicDua(ttsService);

    // 4. Test contenu mixte
    await _testMixedContent(ttsService);

    debugPrint('✅ Tests terminés\n');
  }

  static Future<void> _testQuranicContent(SmartTtsEnhancedService tts) async {
    debugPrint('📖 Test 1: Contenu Coranique');

    const quranicText =
        '{{V:1:1}} بسم الله الرحمن الرحيم {{V:1:2}} الحمد لله رب العالمين';

    // Analyser avant lecture
    final analysis = await tts.analyzeContent(quranicText);
    debugPrint('📊 Analyse: ${await tts.previewContentType(quranicText)}');
    debugPrint('🎯 Type détecté: ${analysis.contentType}');
    debugPrint('📜 Versets trouvés: ${analysis.verses.length}');

    // Tester la lecture
    try {
      await tts.playHighQuality(quranicText);
      debugPrint('✅ Lecture coranique réussie\n');
    } catch (e) {
      debugPrint('❌ Erreur lecture coranique: $e\n');
    }
  }

  static Future<void> _testFrenchContent(SmartTtsEnhancedService tts) async {
    debugPrint('🇫🇷 Test 2: Contenu Français');

    const frenchText =
        'Bonjour, ceci est un test de synthèse vocale en français avec Edge-TTS.';

    final analysis = await tts.analyzeContent(frenchText);
    debugPrint('📊 Analyse: ${await tts.previewContentType(frenchText)}');
    debugPrint('🎯 Type détecté: ${analysis.contentType}');
    debugPrint(
        '🗣️ Ratio français: ${(analysis.languageRatio.french * 100).round()}%');

    try {
      await tts.playAuto(frenchText);
      debugPrint('✅ Lecture française réussie\n');
    } catch (e) {
      debugPrint('❌ Erreur lecture française: $e\n');
    }
  }

  static Future<void> _testIslamicDua(SmartTtsEnhancedService tts) async {
    debugPrint('🤲 Test 3: Invocation Islamique');

    const duaText =
        'بسم الله الرحمن الرحيم، الحمد لله رب العالمين، أستغفر الله العظيم';

    final analysis = await tts.analyzeContent(duaText);
    debugPrint('📊 Analyse: ${await tts.previewContentType(duaText)}');
    debugPrint('🎯 Type détecté: ${analysis.contentType}');

    try {
      await tts.playHighQuality(duaText);
      debugPrint('✅ Lecture invocation réussie\n');
    } catch (e) {
      debugPrint('❌ Erreur lecture invocation: $e\n');
    }
  }

  static Future<void> _testMixedContent(SmartTtsEnhancedService tts) async {
    debugPrint('🌍 Test 4: Contenu Mixte');

    const mixedText =
        'Voici une invocation: بسم الله الرحمن الرحيم - Au nom d\'Allah, le Tout Miséricordieux';

    final analysis = await tts.analyzeContent(mixedText);
    debugPrint('📊 Analyse: ${await tts.previewContentType(mixedText)}');
    debugPrint('🎯 Type détecté: ${analysis.contentType}');
    debugPrint(
        '🌐 Ratio AR/FR: ${(analysis.languageRatio.arabic * 100).round()}% / ${(analysis.languageRatio.french * 100).round()}%');

    try {
      await tts.playAuto(mixedText);
      debugPrint('✅ Lecture mixte réussie\n');
    } catch (e) {
      debugPrint('❌ Erreur lecture mixte: $e\n');
    }
  }
}

/// Provider pour les tests (optionnel)
final hybridAudioTestProvider = Provider<HybridAudioTest>((ref) {
  return HybridAudioTest();
});
