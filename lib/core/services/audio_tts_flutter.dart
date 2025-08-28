import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:spiritual_routines/core/services/audio_tts_service.dart';

class FlutterTtsAudioService implements AudioTtsService {
  final FlutterTts _tts = FlutterTts();
  final StreamController<Duration> _posCtrl = StreamController.broadcast();
  Timer? _ticker;

  FlutterTtsAudioService() {
    // Ensure completion futures await full utterance where supported
    try {
      _tts.awaitSpeakCompletion(true);
    } catch (_) {}
    // iOS: configure audio so TTS plays reliably (even in silent)
    // Skip explicit iOS audio category to maintain compatibility across
    // multiple flutter_tts versions. Defaults are generally sufficient.
    _tts.setCompletionHandler(() {
      _stopTicker();
      _posCtrl.add(Duration.zero);
    });
  }

  @override
  Future<void> playText(
    String text, {
    required String voice,
    double speed = 0.55,
    double pitch = 1.0,
    bool allowFallback =
        false, // Paramètre ignoré car flutter_tts est déjà le fallback
  }) async {
    try {
      // Détecter la langue pour les optimisations spécifiques
      final isArabic = voice.toLowerCase().contains('ar-') ||
          voice.toLowerCase().contains('arabic');
      final isFrench = voice.toLowerCase().contains('fr-') ||
          voice.toLowerCase().contains('french');

      // Prefer a concrete voice if available; otherwise fall back to language
      final selected = await _setBestVoiceOrLanguage(voice);
      if (!selected) {
        final lang = await _pickBestLanguage(voice);
        try {
          await _tts.setLanguage(lang); // e.g., 'fr-FR' or 'ar-SA'
        } catch (_) {}
      }

      // Engine hint (Android): prefer Google for higher quality voices
      try {
        // If Google engine is present, this will switch to it; otherwise ignored
        await _tts.setEngine('com.google.android.tts');
      } catch (_) {}

      // Optimisations spécifiques par langue
      if (isArabic) {
        // Configuration optimisée pour l'arabe
        try {
          await _tts.setPitch(
              pitch.clamp(0.9, 1.1)); // Pitch plus neutre pour l'arabe
        } catch (_) {}
        await _tts.setSpeechRate(
            speed.clamp(0.3, 0.7)); // Vitesse plus lente pour clarté

        // Tenter d'utiliser des moteurs TTS arabes spécialisés si disponibles
        try {
          await _tts.setEngine(
              'com.google.android.tts'); // Google TTS avec support arabe étendu
        } catch (_) {
          try {
            await _tts.setEngine(
                'com.samsung.android.tts'); // Samsung TTS (bon support arabe sur Galaxy)
          } catch (_) {}
        }
      } else if (isFrench) {
        // Configuration optimisée pour le français
        try {
          await _tts.setPitch(pitch.clamp(0.8, 1.2));
        } catch (_) {}
        await _tts.setSpeechRate(speed.clamp(0.4, 0.9));
      } else {
        // Configuration par défaut
        try {
          await _tts.setPitch(pitch.clamp(0.8, 1.2));
        } catch (_) {}
        await _tts.setSpeechRate(speed.clamp(0.3, 0.9));
      }

      try {
        await _tts.setVolume(1.0);
      } catch (_) {}

      // Logging pour debug
      print(
          '🔊 Flutter TTS: ${isArabic ? "Arabe" : isFrench ? "Français" : "Autre"} - Speed: $speed, Pitch: $pitch');

      await _tts.speak(text);
      _startTicker();
    } catch (e) {
      // Swallow TTS errors to avoid crashes; callers can retry or inform user
      print('❌ TTS error: $e');
    }
  }

  @override
  Future<void> stop() async {
    _stopTicker();
    await _tts.stop();
  }

  @override
  Stream<Duration> positionStream() => _posCtrl.stream;

  @override
  Future<void> cacheIfNeeded(String text,
      {required String voice, double speed = 1.0}) async {
    // No-op for on-device TTS; cloud caching can be implemented separately.
  }

  Future<List<String>> languages() async {
    try {
      final langs = (await _tts.getLanguages) as List<dynamic>;
      return langs.map((e) => e.toString()).toList()..sort();
    } catch (_) {
      return const ['fr-FR', 'ar-SA'];
    }
  }

  Future<List<Map<String, String>>> voices() async {
    try {
      final raw = await _tts.getVoices;
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((m) => {
                'name': (m['name'] ?? '').toString(),
                'locale': (m['locale'] ?? '').toString(),
              })
          .where((v) => v['name']!.isNotEmpty || v['locale']!.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<bool> _setBestVoiceOrLanguage(String requested) async {
    try {
      final raw = await _tts.getVoices;
      if (raw is! List) return false;
      final voices = raw
          .whereType<Map>()
          .map((m) => (
                name: (m['name'] ?? '').toString(),
                locale: (m['locale'] ?? '').toString(),
              ))
          .toList();
      if (voices.isEmpty) return false;

      final req = requested.toLowerCase();

      // 1) Exact match by name or locale
      final exact = voices.firstWhere(
        (v) => v.name.toLowerCase() == req || v.locale.toLowerCase() == req,
        orElse: () => (name: '', locale: ''),
      );
      if (exact.name.isNotEmpty || exact.locale.isNotEmpty) {
        await _tts.setVoice({
          'name': exact.name,
          'locale': exact.locale.isNotEmpty
              ? exact.locale
              : await _pickBestLanguage(requested),
        });
        return true;
      }

      // 2) Fuzzy by language code (e.g., 'fr' matches 'fr-FR')
      final langCode = req.replaceAll('_', '-').split('-').first;
      final fuzzy = voices.firstWhere(
        (v) => v.locale.toLowerCase().startsWith(langCode),
        orElse: () => (name: '', locale: ''),
      );
      if (fuzzy.name.isNotEmpty || fuzzy.locale.isNotEmpty) {
        await _tts.setVoice({
          'name': fuzzy.name,
          'locale': fuzzy.locale,
        });
        return true;
      }
    } catch (_) {}
    return false;
  }

  void _startTicker() {
    _stopTicker();
    var elapsed = Duration.zero;
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      elapsed += const Duration(milliseconds: 250);
      _posCtrl.add(elapsed);
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  Future<String> _pickBestLanguage(String requested) async {
    try {
      final langs = (await _tts.getLanguages) as List<dynamic>;
      final list = langs.map((e) => e.toString()).toList();
      if (list.contains(requested)) return requested;
      final req = requested.toLowerCase().replaceAll('_', '-');
      final prefLang = req.split('-').first;
      // Try any variant with the same language code
      final match = list.firstWhere(
        (l) => l.toLowerCase().startsWith(prefLang),
        orElse: () => list.isNotEmpty ? list.first : requested,
      );
      return match;
    } catch (_) {
      return requested;
    }
  }
}

// Shared TTS service instance for on-demand playback
final flutterTtsServiceProvider = Provider<FlutterTtsAudioService>((ref) {
  final svc = FlutterTtsAudioService();
  ref.onDispose(() {
    // Best-effort stop when provider is disposed
    svc.stop();
  });
  return svc;
});
