import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:spiritual_routines/core/services/quran_content_detector.dart';

void main() {
  group('QuranContentDetector Tests', () {
    setUpAll(() async {
      // Mock the asset bundle to simulate asset loading
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
        final String key =
            const StandardMessageCodec().decodeMessage(message!) as String;

        if (key == 'assets/corpus/quran_full.json') {
          // Return a minimal valid Quran corpus for testing
          return ByteData.view(Uint8List.fromList('''[
  {
    "surah": 1,
    "ayah": 1,
    "textAr": "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
    "textFr": "Au nom d'Allah, le Tout Miséricordieux, le Très Miséricordieux."
  },
  {
    "surah": 1,
    "ayah": 2,
    "textAr": "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
    "textFr": "Louange à Allah, Seigneur de l'univers."
  },
  {
    "surah": 2,
    "ayah": 1,
    "textAr": "الم",
    "textFr": "Alif, Lam, Mim."
  }
]'''
              .codeUnits).buffer);
        }

        return null;
      });
    });

    test('should initialize with complete corpus', () async {
      // Test initialization by calling public method
      await QuranContentDetector.initialize();

      // Verify initialization by testing detection functionality
      final result = await QuranContentDetector.detectContent('بسم الله الرحمن الرحيم');
      expect(result.confidence, greaterThan(0.5));
      expect(result.isQuranVerse, isTrue);
    });

    test('should detect Quranic content with high confidence', () async {
      // Test with Al-Fatiha verse 1
      final result = await QuranContentDetector.detectQuranContent(
          "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ");

      expect(result.isQuranic, true);
      expect(result.confidence, greaterThan(0.9));
      expect(result.matchType, MatchType.exact);
      expect(result.verse, isNotNull);
      expect(result.verse!.surah, 1);
      expect(result.verse!.ayah, 1);
    });

    test('should not detect non-Quranic Arabic text', () async {
      final result =
          await QuranContentDetector.detectQuranContent("مرحبا كيف حالك اليوم");

      expect(result.isQuranic, false);
      expect(result.confidence, lessThan(0.8));
    });

    test('should handle empty text gracefully', () async {
      final result = await QuranContentDetector.detectQuranContent("");

      expect(result.isQuranic, false);
      expect(result.confidence, 0.0);
    });

    tearDownAll(() async {
      // Clean up mock message handler
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });
  });
}
