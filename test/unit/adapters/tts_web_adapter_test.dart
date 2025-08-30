import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_test/flutter_test.dart';
import 'package:spiritual_routines/core/adapters/tts_web.dart';

void main() {
  group('Web TTS Adapter', () {
    test('getAvailableVoices does not throw', () async {
      final tts = WebTtsStub();
      final voices = await tts.getAvailableVoices();
      expect(voices, isA<List<String>>());
      // At least returns defaults if Speech API unavailable
      expect(voices, isNotEmpty);
    });

    test('speak completes (simulation fallback if needed)', () async {
      final tts = WebTtsStub();
      await expectLater(
        tts.speak(
          'Bonjour, ceci est un test de synthèse.',
          voice: 'fr-FR-DeniseNeural',
          speed: 0.6,
          pitch: 1.0,
        ),
        completes,
      );
    });

    test('stop/pause/resume do not throw', () async {
      final tts = WebTtsStub();
      await tts.stop();
      await tts.pause();
      await tts.resume();
      await tts.dispose();
    });
  });
}
