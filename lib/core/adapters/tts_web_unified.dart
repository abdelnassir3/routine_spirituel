import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:js' as js;
import '../services/audio/web_edge_tts_service.dart';
import 'tts_adapter.dart';

/// Adaptateur TTS Web avec architecture IDENTIQUE au mobile
/// Hiérarchie: Edge-TTS (168.231.112.71:8010) → Web Speech API → Simulation
class WebTtsAdapter implements TtsAdapter {
  final WebEdgeTtsService _edgeTts = WebEdgeTtsService();
  final _WebSpeechFallback _webSpeechFallback = _WebSpeechFallback();
  
  VoidCallback? _completionCallback;
  bool _isSpeaking = false;
  bool _isPaused = false;

  // Circuit breaker pour Edge-TTS (même logique que mobile)
  bool _edgeTtsAvailable = true;
  DateTime? _edgeTtsLastFailure;
  static const _circuitBreakerTimeout = Duration(minutes: 5);

  // Métriques (même logique que mobile)
  int _edgeTtsSuccessCount = 0;
  int _webSpeechFallbackCount = 0;
  int _totalRequests = 0;

  WebTtsAdapter() {
    _webSpeechFallback._initializeSpeechSynthesis();
  }

  @override
  Future<void> speak(
    String text, {
    required String voice,
    double speed = 0.55,
    double pitch = 1.0,
    bool allowFallback = true,
  }) async {
    _totalRequests++;

    if (kDebugMode) {
      debugPrint('🌐 Web TTS: Architecture unifiée - début synthèse');
      debugPrint('📝 Texte: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
      debugPrint('🎙️ Voix: $voice, Vitesse: $speed');
    }

    try {
      await stop(); // Arrêter toute lecture en cours
      
      _isSpeaking = true;
      _isPaused = false;

      // STRATÉGIE 1: Edge-TTS (principal, comme sur mobile)
      if (_edgeTtsAvailable && _shouldRetryService(_edgeTtsLastFailure)) {
        try {
          if (kDebugMode) {
            debugPrint('🎯 Tentative Edge-TTS (168.231.112.71:8010)...');
          }

          // Configurer callback pour Edge-TTS
          _edgeTts.setCompletionCallback(() {
            _completionCallback?.call();
            _isSpeaking = false;
          });

          await _edgeTts.playText(
            text,
            voice: voice,
            speed: speed,
            pitch: pitch,
            allowFallback: false, // Ne pas faire de fallback dans le service
          );

          _edgeTtsSuccessCount++;
          _edgeTtsAvailable = true;
          _edgeTtsLastFailure = null;

          if (kDebugMode) {
            debugPrint('✅ Edge-TTS réussi (succès: $_edgeTtsSuccessCount)');
          }
          
          // Note: _isSpeaking sera mis à false par le callback
          return;

        } catch (edgeError) {
          if (kDebugMode) {
            debugPrint('❌ Edge-TTS échec: $edgeError');
          }
          
          _edgeTtsLastFailure = DateTime.now();
          _edgeTtsAvailable = false;

          if (!allowFallback) {
            _isSpeaking = false;
            rethrow;
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint('⏭️ Edge-TTS indisponible (circuit breaker)');
        }
      }

      // STRATÉGIE 2: Web Speech API (fallback natif Web)
      try {
        if (kDebugMode) {
          debugPrint('🎯 Fallback Web Speech API...');
        }

        // Configurer callback pour Web Speech API
        _webSpeechFallback.setCompletionCallback(() {
          _completionCallback?.call();
          _isSpeaking = false;
        });

        await _webSpeechFallback.speak(
          text,
          voice: voice,
          speed: speed,
          pitch: pitch,
          allowFallback: true,
        );

        _webSpeechFallbackCount++;

        if (kDebugMode) {
          debugPrint('✅ Web Speech API réussi (fallbacks: $_webSpeechFallbackCount)');
        }

        // Note: _isSpeaking sera mis à false par le callback
        return;

      } catch (webSpeechError) {
        if (kDebugMode) {
          debugPrint('❌ Web Speech API échec: $webSpeechError');
        }

        if (!allowFallback) {
          _isSpeaking = false;
          rethrow;
        }
      }

      // STRATÉGIE 3: Mode silencieux (dernier recours)
      if (kDebugMode) {
        debugPrint('🔇 Tous les services TTS ont échoué, mode silencieux');
      }
      
      _isSpeaking = false;
      throw Exception('Tous les services TTS Web ont échoué');

    } catch (e) {
      _isSpeaking = false;
      if (kDebugMode) {
        debugPrint('❌ Erreur globale Web TTS: $e');
      }
      rethrow;
    }
  }

  /// Vérifie si on doit réessayer un service après échec (circuit breaker)
  bool _shouldRetryService(DateTime? lastFailure) {
    if (lastFailure == null) return true;
    return DateTime.now().difference(lastFailure) > _circuitBreakerTimeout;
  }

  @override
  Future<void> stop() async {
    if (kDebugMode) {
      debugPrint('🛑 Web TTS: Arrêt de tous les services');
    }

    _isSpeaking = false;
    _isPaused = false;

    // Arrêter tous les services en parallèle
    await Future.wait([
      _edgeTts.stop().catchError((_) {}),
      _webSpeechFallback.stop().catchError((_) {}),
    ]);
  }

  @override
  Future<void> pause() async {
    if (kDebugMode) {
      debugPrint('⏸️ Web TTS: Pause');
    }
    
    _isPaused = true;
    
    // Tenter de pauser tous les services
    await Future.wait([
      _edgeTts.pause().catchError((_) {}),
      _webSpeechFallback.pause().catchError((_) {}),
    ]);
  }

  @override
  Future<void> resume() async {
    if (kDebugMode) {
      debugPrint('▶️ Web TTS: Resume');
    }
    
    _isPaused = false;
    
    // Tenter de reprendre tous les services
    await Future.wait([
      _edgeTts.resume().catchError((_) {}),
      _webSpeechFallback.resume().catchError((_) {}),
    ]);
  }

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  bool get isPaused => _isPaused;

  @override
  Future<List<String>> getAvailableVoices() async {
    // Combiner les voix de tous les services
    try {
      final edgeVoices = await _edgeTts.getAvailableVoices();
      final webVoices = await _webSpeechFallback.getAvailableVoices();
      
      // Fusionner et dédupliquer
      final allVoices = <String>{};
      allVoices.addAll(edgeVoices);
      allVoices.addAll(webVoices);
      
      return allVoices.toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur récupération voix: $e');
      }
      // Voix par défaut en cas d'erreur
      return ['fr-FR-DeniseNeural', 'ar-SA-HamedNeural', 'en-US-AriaNeural'];
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
    
    // Propager aux services
    _edgeTts.setCompletionCallback(callback);
    _webSpeechFallback.setCompletionCallback(callback);
  }

  @override
  Future<void> dispose() async {
    if (kDebugMode) {
      debugPrint('🗑️ Web TTS: Nettoyage');
    }

    await stop();
    _completionCallback = null;

    // Disposer tous les services
    await Future.wait([
      _edgeTts.dispose().catchError((_) {}),
      _webSpeechFallback.dispose().catchError((_) {}),
    ]);
  }

  /// Méthode pour obtenir les statistiques d'utilisation (debug)
  Map<String, dynamic> getUsageStats() {
    return {
      'totalRequests': _totalRequests,
      'edgeTtsSuccess': _edgeTtsSuccessCount,
      'webSpeechFallback': _webSpeechFallbackCount,
      'edgeTtsAvailable': _edgeTtsAvailable,
      'successRate': _totalRequests > 0 
          ? ((_edgeTtsSuccessCount + _webSpeechFallbackCount) / _totalRequests * 100).toStringAsFixed(1)
          : '0',
    };
  }
}

/// Classe de fallback Web Speech API - Copie de WebTtsStub original
class _WebSpeechFallback implements TtsAdapter {
  bool _isSpeaking = false;
  bool _isPaused = false;
  VoidCallback? _completionCallback;
  html.SpeechSynthesis? _synth;
  html.SpeechSynthesisUtterance? _currentUtterance;

  void _initializeSpeechSynthesis() {
    try {
      if (html.window.speechSynthesis != null) {
        _synth = html.window.speechSynthesis;
        if (kDebugMode) {
          debugPrint('🎤 Web Speech API initialized successfully');
        }
        
        // Force load voices on initialization
        _synth!.getVoices();
        
        // Add voices changed listener to ensure voices are loaded
        html.window.addEventListener('voiceschanged', (event) {
          if (kDebugMode) {
            final voices = _synth!.getVoices();
            debugPrint('🎤 Web Speech API voices loaded: ${voices.length} voices available');
          }
        });
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
    if (kDebugMode) {
      debugPrint('🎤 Web Speech: speak() called with voice: $voice, speed: $speed');
      debugPrint('🎤 Web Speech: text length: ${text.length} characters');
    }
    
    if (_synth == null) {
      if (kDebugMode) {
        debugPrint('⚠️ Web Speech API not available, falling back to simulation');
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
          debugPrint('🎤 Web Speech: Started speaking "${text.length > 50 ? text.substring(0, 50) + '...' : text}"');
        }
      });

      _currentUtterance!.onEnd.listen((_) {
        _isSpeaking = false;
        _isPaused = false;
        _completionCallback?.call();
        if (kDebugMode) {
          debugPrint('✅ Web Speech: Finished speaking');
        }
      });

      _currentUtterance!.onError.listen((event) {
        _isSpeaking = false;
        _isPaused = false;
        if (kDebugMode) {
          debugPrint('❌ Web Speech Error event');
        }
        // Fallback vers simulation en cas d'erreur
        _simulateSpeak(text, speed);
      });

      _currentUtterance!.onPause.listen((_) {
        _isPaused = true;
        if (kDebugMode) {
          debugPrint('⏸️ Web Speech: Paused');
        }
      });

      _currentUtterance!.onResume.listen((_) {
        _isPaused = false;
        if (kDebugMode) {
          debugPrint('▶️ Web Speech: Resumed');
        }
      });

      // Démarrer la synthèse
      _synth!.speak(_currentUtterance!);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Web Speech Error: $e');
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
      debugPrint('🔇 Web Speech Simulation: "${text.length > 50 ? text.substring(0, 50) + '...' : text}"');
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
  Future<html.SpeechSynthesisVoice?> _findBestVoice(String requestedVoice) async {
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
          debugPrint('⏹️ Web Speech: Stopped');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error stopping Web Speech: $e');
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
          debugPrint('⏸️ Web Speech: Paused');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error pausing Web Speech: $e');
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
          debugPrint('▶️ Web Speech: Resumed');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error resuming Web Speech: $e');
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
        debugPrint('🎤 Web Speech: Found ${voiceList.length} voices');
        debugPrint('🎤 Available languages: ${voices.map((v) => v.lang).toSet().join(', ')}');
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
        debugPrint('🗑️ Web Speech: Disposed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error disposing Web Speech: $e');
      }
    }
  }
}