import 'package:flutter/foundation.dart';
import 'package:spiritual_routines/core/services/audio_tts_flutter.dart';
import 'package:spiritual_routines/core/services/audio/edge_tts_service.dart';
import 'package:spiritual_routines/core/services/coqui_tts_service.dart';
import 'package:spiritual_routines/core/services/tts_config_service.dart';
import 'package:spiritual_routines/core/services/secure_tts_cache_service.dart';
import 'tts_adapter.dart';

/// Implémentation mobile unifiée du TTS (iOS/Android)
/// Utilise la hiérarchie Edge TTS → Coqui TTS → Flutter TTS
class MobileTtsAdapter implements TtsAdapter {
  final EdgeTtsService _edgeTts = EdgeTtsService();
  late final CoquiTtsService _coquiTts;
  final FlutterTtsAudioService _flutterTts = FlutterTtsAudioService();
  
  MobileTtsAdapter() {
    // Initialize CoquiTtsService with required parameters
    final config = TtsConfigService(
      coquiEndpoint: 'http://168.231.112.71:8001',
      coquiApiKey: '', // Empty for now, can be configured later
    );
    final cache = SecureTtsCacheService.instance;
    _coquiTts = CoquiTtsService(config: config, cache: cache);
  }

  VoidCallback? _completionCallback;
  bool _isSpeaking = false;
  bool _isPaused = false;

  @override
  Future<void> speak(
    String text, {
    required String voice,
    double speed = 0.55,
    double pitch = 1.0,
    bool allowFallback = true,
  }) async {
    if (kDebugMode) {
      debugPrint('🎤 Mobile TTS: Speaking "$text" with voice "$voice"');
    }

    _isSpeaking = true;
    _isPaused = false;

    try {
      // Stratégie 1: Edge TTS (le plus fiable)
      await _edgeTts.playText(
        text,
        voice: voice,
        speed: speed,
        pitch: pitch,
        allowFallback: allowFallback,
      );

      if (kDebugMode) {
        debugPrint('✅ Edge TTS successful');
      }
    } catch (edgeError) {
      if (kDebugMode) {
        debugPrint('❌ Edge TTS failed: $edgeError');
      }

      if (!allowFallback) {
        _isSpeaking = false;
        rethrow;
      }

      try {
        // Stratégie 2: Coqui TTS (haute qualité)
        await _coquiTts.playText(
          text,
          voice: voice,
          speed: speed,
          pitch: pitch,
          allowFallback: allowFallback,
        );

        if (kDebugMode) {
          debugPrint('✅ Coqui TTS successful');
        }
      } catch (coquiError) {
        if (kDebugMode) {
          debugPrint('❌ Coqui TTS failed: $coquiError');
        }

        if (!allowFallback) {
          _isSpeaking = false;
          rethrow;
        }

        try {
          // Stratégie 3: Flutter TTS (fallback local)
          await _flutterTts.playText(
            text,
            voice: voice,
            speed: speed,
            pitch: pitch,
            allowFallback: allowFallback,
          );

          if (kDebugMode) {
            debugPrint('✅ Flutter TTS fallback successful');
          }
        } catch (flutterError) {
          if (kDebugMode) {
            debugPrint('❌ All TTS services failed');
          }
          _isSpeaking = false;
          rethrow;
        }
      }
    }

    _isSpeaking = false;
    _completionCallback?.call();
  }

  @override
  Future<void> stop() async {
    if (kDebugMode) {
      debugPrint('🛑 Mobile TTS: Stopping');
    }

    _isSpeaking = false;
    _isPaused = false;

    // Arrêter tous les services en parallèle
    await Future.wait([
      _edgeTts.stop().catchError((_) {}),
      _coquiTts.stop().catchError((_) {}),
      _flutterTts.stop().catchError((_) {}),
    ]);
  }

  @override
  Future<void> pause() async {
    if (kDebugMode) {
      debugPrint('⏸️ Mobile TTS: Pausing');
    }
    _isPaused = true;
    // Note: Pas tous les services supportent pause/resume
    await _flutterTts.pause().catchError((_) {});
  }

  @override
  Future<void> resume() async {
    if (kDebugMode) {
      debugPrint('▶️ Mobile TTS: Resuming');
    }
    _isPaused = false;
    await _flutterTts.resume().catchError((_) {});
  }

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  bool get isPaused => _isPaused;

  @override
  Future<List<String>> getAvailableVoices() async {
    // Combiner les voix de Flutter TTS (seul service qui expose les voix)
    try {
      final voices = await _flutterTts.getAvailableVoices();
      return voices.cast<String>();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get voices: $e');
      }
      return ['fr-FR-DeniseNeural', 'ar-SA-HamedNeural']; // Voix par défaut
    }
  }

  @override
  Future<bool> isVoiceAvailable(String voice) async {
    final voices = await getAvailableVoices();
    return voices.contains(voice);
  }

  @override
  void setCompletionCallback(VoidCallback? callback) {
    _completionCallback = callback;
  }

  @override
  Future<void> dispose() async {
    if (kDebugMode) {
      debugPrint('🗑️ Mobile TTS: Disposing');
    }

    await stop();
    _completionCallback = null;

    // Disposer les ressources des services
    await Future.wait([
      _edgeTts.dispose(),
      _flutterTts.dispose(),
    ]);
    
    // CoquiTtsService has a void dispose method, call it separately
    try {
      _coquiTts.dispose();
    } catch (_) {
      // Ignore disposal errors
    }
  }
}
