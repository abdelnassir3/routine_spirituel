import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'audio_api_config.dart';
import '../audio_tts_service.dart';

/// Service Edge-TTS pour Web - Architecture identique au mobile
/// Utilise fetch API pour appels HTTP vers 168.231.112.71:8010 (endpoint principal)
class WebEdgeTtsService implements AudioTtsService {
  bool _isSpeaking = false;
  VoidCallback? _completionCallback;
  html.AudioElement? _currentAudio;

  @override
  Future<void> playText(
    String text, {
    required String voice,
    double speed = 0.55,
    double pitch = 1.0,
    bool allowFallback = true,
  }) async {
    if (kDebugMode) {
      debugPrint('🌐 Web Edge-TTS: Synthétisant "$text" avec voix "$voice"');
    }

    try {
      // 1. Arrêter l'audio actuel
      await stop();

      // 2. Appeler l'API Edge-TTS via HTTP
      final audioBytes = await _callEdgeTtsApi(text, voice, speed, pitch);
      
      if (audioBytes == null) {
        throw Exception('Edge-TTS API returned null');
      }

      // 3. Jouer l'audio reçu
      await _playAudioBytes(audioBytes);

      if (kDebugMode) {
        debugPrint('✅ Web Edge-TTS: Lecture réussie');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Web Edge-TTS Error: $e');
      }
      
      if (!allowFallback) {
        rethrow;
      }
      
      // Si allowFallback = true, l'erreur sera gérée par le niveau supérieur
      rethrow;
    }
  }

  /// Appelle l'API Edge-TTS via fetch
  Future<Uint8List?> _callEdgeTtsApi(
    String text,
    String voice,
    double speed,
    double pitch,
  ) async {
    try {
      // Configuration de la requête Edge-TTS
      final requestData = {
        'text': text,
        'voice': _mapVoiceToEdgeFormat(voice),
      };

      // Ajouter rate si différent de la valeur par défaut
      if (speed != 0.55) {
        final ratePercent = (speed * 100).round().clamp(50, 150);
        final rateAdjustment = ratePercent - 100;
        requestData['rate'] = '${rateAdjustment >= 0 ? '+' : ''}${rateAdjustment}%';
      }

      // Ajouter pitch si différent de 1.0
      if (pitch != 1.0) {
        final pitchAdjustment = ((pitch - 1.0) * 50).round().clamp(-50, 50);
        requestData['pitch'] = '${pitchAdjustment >= 0 ? '+' : ''}${pitchAdjustment}Hz';
      }

      if (kDebugMode) {
        debugPrint('🌐 Web Edge-TTS Request: ${AudioApiConfig.edgeTtsSynthesizeEndpoint}');
        debugPrint('📦 Payload: $requestData');
      }

      // Appel fetch API
      final response = await html.window.fetch(
        AudioApiConfig.edgeTtsSynthesizeEndpoint,
        {
          'method': 'POST',
          'headers': {
            'Content-Type': 'application/json',
            'Accept': 'audio/mpeg',
          },
          'body': jsonEncode(requestData),
        },
      );

      if (response.status != 200) {
        throw Exception('Edge-TTS API Error: ${response.status} ${response.statusText}');
      }

      // Récupérer les bytes audio
      final arrayBuffer = await response.arrayBuffer();
      final bytes = arrayBuffer.asUint8List();

      if (kDebugMode) {
        debugPrint('✅ Web Edge-TTS: Reçu ${bytes.length} bytes audio');
      }

      return bytes;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Web Edge-TTS API Error: $e');
      }
      return null;
    }
  }

  /// Joue les bytes audio reçus
  Future<void> _playAudioBytes(Uint8List audioBytes) async {
    try {
      // Créer un blob audio à partir des bytes
      final blob = html.Blob([audioBytes], 'audio/mpeg');
      final url = html.Url.createObjectUrl(blob);

      // Créer un élément audio
      _currentAudio = html.AudioElement(url);
      _currentAudio!.preload = 'auto';

      // Configurer les callbacks
      final completer = Completer<void>();
      late StreamSubscription playSubscription;
      late StreamSubscription endSubscription;
      late StreamSubscription errorSubscription;

      playSubscription = _currentAudio!.onPlay.listen((_) {
        _isSpeaking = true;
        if (kDebugMode) {
          debugPrint('🎵 Web Edge-TTS: Audio started');
        }
      });

      endSubscription = _currentAudio!.onEnded.listen((_) {
        _isSpeaking = false;
        _completionCallback?.call();
        
        // Cleanup
        playSubscription.cancel();
        endSubscription.cancel();
        errorSubscription.cancel();
        html.Url.revokeObjectUrl(url);
        
        if (!completer.isCompleted) {
          completer.complete();
        }
        
        if (kDebugMode) {
          debugPrint('✅ Web Edge-TTS: Audio finished');
        }
      });

      errorSubscription = _currentAudio!.onError.listen((e) {
        _isSpeaking = false;
        
        // Cleanup
        playSubscription.cancel();
        endSubscription.cancel();
        errorSubscription.cancel();
        html.Url.revokeObjectUrl(url);
        
        if (!completer.isCompleted) {
          completer.completeError(Exception('Audio playback error'));
        }
        
        if (kDebugMode) {
          debugPrint('❌ Web Edge-TTS: Audio error');
        }
      });

      // Lancer la lecture
      await _currentAudio!.play();
      await completer.future;
      
    } catch (e) {
      _isSpeaking = false;
      if (kDebugMode) {
        debugPrint('❌ Web Edge-TTS Playback Error: $e');
      }
      rethrow;
    }
  }

  /// Mappe les voix vers le format Edge-TTS
  String _mapVoiceToEdgeFormat(String voice) {
    // Mapping des voix courantes vers Edge-TTS
    final voiceMap = {
      'fr-FR': 'fr-FR-DeniseNeural',
      'ar-SA': 'ar-SA-HamedNeural',
      'fr': 'fr-FR-DeniseNeural',
      'ar': 'ar-SA-HamedNeural',
    };

    // Retourner la voix mappée ou utiliser la voix telle quelle
    return voiceMap[voice] ?? voice;
  }

  @override
  Future<void> stop() async {
    try {
      if (_currentAudio != null) {
        _currentAudio!.pause();
        _currentAudio!.currentTime = 0;
        _currentAudio = null;
        
        if (kDebugMode) {
          debugPrint('⏹️ Web Edge-TTS: Stopped');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error stopping Web Edge-TTS: $e');
      }
    }
    
    _isSpeaking = false;
  }

  @override
  Future<void> pause() async {
    try {
      if (_currentAudio != null) {
        _currentAudio!.pause();
        if (kDebugMode) {
          debugPrint('⏸️ Web Edge-TTS: Paused');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error pausing Web Edge-TTS: $e');
      }
    }
  }

  @override
  Future<void> resume() async {
    try {
      if (_currentAudio != null) {
        await _currentAudio!.play();
        if (kDebugMode) {
          debugPrint('▶️ Web Edge-TTS: Resumed');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error resuming Web Edge-TTS: $e');
      }
    }
  }

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  bool get isPaused => _currentAudio?.paused ?? false;

  @override
  Future<List<String>> getAvailableVoices() async {
    // Retourner les voix supportées par Edge-TTS
    return [
      'fr-FR-DeniseNeural',
      'ar-SA-HamedNeural',
      'en-US-AriaNeural',
      'fr-FR-HenriNeural',
      'ar-SA-ZariyahNeural',
    ];
  }

  @override
  Future<bool> isVoiceAvailable(String voice) async {
    final voices = await getAvailableVoices();
    return voices.contains(voice) || voices.contains(_mapVoiceToEdgeFormat(voice));
  }

  @override
  void setCompletionCallback(VoidCallback? callback) {
    _completionCallback = callback;
  }

  @override
  Future<void> dispose() async {
    await stop();
    _completionCallback = null;
    
    if (kDebugMode) {
      debugPrint('🗑️ Web Edge-TTS: Disposed');
    }
  }

  @override
  Stream<Duration> positionStream() {
    // Pour Web Edge-TTS, on ne peut pas suivre la position précise
    // Retourner un stream vide pour compatibilité
    return const Stream.empty();
  }

  @override
  Future<void> cacheIfNeeded(String text, {
    required String voice,
    double speed = 0.55,
    double pitch = 1.0,
  }) async {
    // Pour Web Edge-TTS, pas de cache préemptif nécessaire
    // Le cache est géré par le navigateur automatiquement
    if (kDebugMode) {
      debugPrint('🗃️ Web Edge-TTS: Cache request for "${text.substring(0, text.length > 30 ? 30 : text.length)}..." (browser handles caching)');
    }
  }
}