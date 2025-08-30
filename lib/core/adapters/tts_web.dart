import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_interop' as jsInterop;
import 'tts_adapter.dart';

/// Implementation Web réelle du Text-to-Speech avec Web Speech API
/// Fournit une vraie synthèse vocale pour le preview Web
class WebTtsStub implements TtsAdapter {
  bool _isSpeaking = false;
  bool _isPaused = false;
  VoidCallback? _completionCallback;
  html.SpeechSynthesis? _synth;
  html.SpeechSynthesisUtterance? _currentUtterance;

  WebTtsStub() {
    _initializeSpeechSynthesis();
  }

  void _initializeSpeechSynthesis() {
    try {
      if (html.window.speechSynthesis != null) {
        _synth = html.window.speechSynthesis;
        if (kDebugMode) {
          debugPrint('🎤 Web Speech API initialized successfully');
        }
      } else {
        if (kDebugMode) {
          debugPrint('⚠️ Web Speech API not supported in this browser');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error initializing Web Speech API: $e');
      }
    }
  }

  @override
  Future<void> speak(
    String text, {
    required String voice,
    double speed = 0.55,
    double pitch = 1.0,
    bool allowFallback = true,
  }) async {
    if (_synth == null) {
      if (kDebugMode) {
        debugPrint(
            '⚠️ Web Speech API not available, falling back to simulation');
      }
      return _simulateSpeak(text, speed);
    }

    try {
      // Arrêter toute synthèse en cours
      await stop();

      _currentUtterance = html.SpeechSynthesisUtterance(text);

      // Configuration de la synthèse
      _currentUtterance!.rate = speed.clamp(0.1, 10.0);
      _currentUtterance!.pitch = pitch.clamp(0.0, 2.0);
      _currentUtterance!.volume = 1.0;

      // Essayer de définir la voix demandée
      final targetVoice = await _findBestVoice(voice);
      if (targetVoice != null) {
        _currentUtterance!.voice = targetVoice;
      }

      // Configurer les callbacks
      _currentUtterance!.onStart.listen((_) {
        _isSpeaking = true;
        _isPaused = false;
        if (kDebugMode) {
          debugPrint(
              '🎤 Web TTS: Started speaking "${text.length > 50 ? text.substring(0, 50) + '...' : text}"');
        }
      });

      _currentUtterance!.onEnd.listen((_) {
        _isSpeaking = false;
        _isPaused = false;
        _completionCallback?.call();
        if (kDebugMode) {
          debugPrint('✅ Web TTS: Finished speaking');
        }
      });

      _currentUtterance!.onError.listen((event) {
        _isSpeaking = false;
        _isPaused = false;
        if (kDebugMode) {
          debugPrint('❌ Web TTS Error event');
        }
        // Fallback vers simulation en cas d'erreur
        _simulateSpeak(text, speed);
      });

      _currentUtterance!.onPause.listen((_) {
        _isPaused = true;
        if (kDebugMode) {
          debugPrint('⏸️ Web TTS: Paused');
        }
      });

      _currentUtterance!.onResume.listen((_) {
        _isPaused = false;
        if (kDebugMode) {
          debugPrint('▶️ Web TTS: Resumed');
        }
      });

      // Démarrer la synthèse
      _synth!.speak(_currentUtterance!);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Web TTS Error: $e');
      }
      // Fallback vers simulation
      await _simulateSpeak(text, speed);
    }
  }

  /// Fallback simulation pour navigateurs sans Web Speech API
  Future<void> _simulateSpeak(String text, double speed) async {
    _isSpeaking = true;
    _isPaused = false;

    if (kDebugMode) {
      debugPrint(
          '🔇 Web TTS Simulation: "${text.length > 50 ? text.substring(0, 50) + '...' : text}"');
    }

    // Estimation durée basée sur longueur et vitesse
    final estimatedDuration = Duration(
      milliseconds: (text.length * 50 / speed).round(),
    );

    await Future.delayed(estimatedDuration);

    _isSpeaking = false;
    _completionCallback?.call();
  }

  /// Trouve la meilleure voix disponible pour la langue demandée
  Future<html.SpeechSynthesisVoice?> _findBestVoice(
      String requestedVoice) async {
    if (_synth == null) return null;

    try {
      final voices = _synth!.getVoices();
      if (voices.isEmpty) {
        // Attendre que les voix soient chargées
        await Future.delayed(const Duration(milliseconds: 100));
        final voicesRetry = _synth!.getVoices();
        if (voicesRetry.isEmpty) return null;
        return _selectVoice(voicesRetry, requestedVoice);
      }
      return _selectVoice(voices, requestedVoice);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting voices: $e');
      }
      return null;
    }
  }

  /// Sélectionne la meilleure voix parmi celles disponibles
  html.SpeechSynthesisVoice? _selectVoice(
      List<html.SpeechSynthesisVoice> voices, String requestedVoice) {
    // 1. Chercher correspondance exacte
    for (final voice in voices) {
      if ((voice.name?.contains(requestedVoice) ?? false)) {
        return voice;
      }
    }

    // 2. Chercher par langue
    String targetLang = 'en-US'; // défaut
    if (requestedVoice.contains('fr-FR') || requestedVoice.contains('French')) {
      targetLang = 'fr-FR';
    } else if (requestedVoice.contains('ar-SA') ||
        requestedVoice.contains('Arabic')) {
      targetLang = 'ar-SA';
    }

    // Chercher voix avec la langue cible
    for (final voice in voices) {
      if ((voice.lang?.startsWith(targetLang.substring(0, 2)) ?? false)) {
        return voice;
      }
    }

    // 3. Retourner la première voix par défaut
    return voices.isNotEmpty ? voices.first : null;
  }

  @override
  Future<void> stop() async {
    try {
      if (_synth != null) {
        _synth!.cancel();
        if (kDebugMode) {
          debugPrint('⏹️ Web TTS: Stopped');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error stopping Web TTS: $e');
      }
    }

    _isSpeaking = false;
    _isPaused = false;
    _currentUtterance = null;
  }

  @override
  Future<void> pause() async {
    try {
      if (_synth != null && _isSpeaking) {
        _synth!.pause();
        if (kDebugMode) {
          debugPrint('⏸️ Web TTS: Paused');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error pausing Web TTS: $e');
      }
    }
    _isPaused = true;
  }

  @override
  Future<void> resume() async {
    try {
      if (_synth != null && _isPaused) {
        _synth!.resume();
        if (kDebugMode) {
          debugPrint('▶️ Web TTS: Resumed');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error resuming Web TTS: $e');
      }
    }
    _isPaused = false;
  }

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  bool get isPaused => _isPaused;

  @override
  Future<List<String>> getAvailableVoices() async {
    if (_synth == null) {
      // Fallback vers voix par défaut si Speech API indisponible
      return [
        'fr-FR-DeniseNeural',
        'ar-SA-HamedNeural',
        'en-US-AriaNeural',
      ];
    }

    try {
      final voices = _synth!.getVoices();
      if (voices.isEmpty) {
        // Attendre le chargement des voix
        await Future.delayed(const Duration(milliseconds: 100));
        final voicesRetry = _synth!.getVoices();
        if (voicesRetry.isEmpty) {
          return [
            'fr-FR-DeniseNeural',
            'ar-SA-HamedNeural',
            'en-US-AriaNeural',
          ];
        }
        return voicesRetry.map((v) => '${v.lang}-${v.name}').toList();
      }

      final voiceList = voices.map((v) => '${v.lang}-${v.name}').toList();

      if (kDebugMode) {
        debugPrint('🎤 Web TTS: Found ${voiceList.length} voices');
        debugPrint(
            '🎤 Available languages: ${voices.map((v) => v.lang).toSet().join(', ')}');
      }

      return voiceList;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting voices: $e');
      }
      return [
        'fr-FR-DeniseNeural',
        'ar-SA-HamedNeural',
        'en-US-AriaNeural',
      ];
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
    try {
      await stop();
      _completionCallback = null;
      _isSpeaking = false;
      _isPaused = false;
      _currentUtterance = null;

      if (kDebugMode) {
        debugPrint('🗑️ Web TTS: Disposed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error disposing Web TTS: $e');
      }
    }
  }
}
