import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/services/audio_tts_service.dart';
import 'package:spiritual_routines/core/services/smart_tts_service.dart';
import 'package:spiritual_routines/core/services/quran_recitation_service.dart';
import 'package:spiritual_routines/core/services/quran_content_detector.dart';
import 'package:spiritual_routines/core/services/tts_logger_service.dart';

/// Service hybride qui route intelligemment entre TTS et récitation coranique
/// Utilise QuranContentDetector pour identifier le type de contenu
class HybridAudioService implements AudioTtsService {
  final AudioTtsService _smartTtsService;
  final QuranRecitationService _quranRecitationService;
  
  // Service actuellement actif
  AudioTtsService? _activeService;
  
  HybridAudioService({
    required AudioTtsService smartTtsService,
    required QuranRecitationService quranRecitationService,
  }) : _smartTtsService = smartTtsService,
       _quranRecitationService = quranRecitationService {
    
    TtsLogger.info('🎯 HybridAudioService initialisé', {
      'smartTts': _smartTtsService.runtimeType.toString(),
      'quranService': _quranRecitationService.runtimeType.toString(),
    });
  }

  @override
  Future<void> playText(
    String text, {
    required String voice,
    double speed = 0.9,
    double pitch = 1.0,
    bool allowFallback = true,
  }) async {
    final timer = TtsPerformanceTimer('hybrid.playText', {
      'textLength': text.length,
      'voice': voice,
      'speed': speed,
    });

    try {
      // Arrêter tout audio en cours
      await stop();

      // Détecter le type de contenu
      final detection = await QuranContentDetector.detectQuranContent(text);
      
      TtsLogger.info('🔍 Détection de contenu', {
        'isQuranic': detection.isQuranic,
        'confidence': detection.confidence,
        'matchType': detection.matchType.toString(),
        'textPreview': text.substring(0, text.length > 50 ? 50 : text.length) + '...',
      });

      if (detection.isQuranic && detection.confidence > 0.8) {
        // CONTENU CORANIQUE -> Utiliser le service de récitation
        TtsLogger.info('🕌 Routage vers récitation coranique', {
          'surah': detection.verse?.surah,
          'ayah': detection.verse?.ayah,
          'confidence': detection.confidence,
        });

        _activeService = _quranRecitationService;
        
        // Ajuster la vitesse pour la récitation (plus lente)
        final quranSpeed = _adjustSpeedForQuran(speed);
        
        await _quranRecitationService.playText(
          text,
          voice: voice,
          speed: quranSpeed,
          pitch: pitch,
          allowFallback: allowFallback,
        );

        TtsLogger.metric('hybrid.route.quran', 1, {
          'surah': detection.verse?.surah,
          'confidence': detection.confidence,
        });

      } else {
        // TEXTE NORMAL -> Utiliser SmartTTS
        TtsLogger.info('🗣️ Routage vers TTS normal', {
          'confidence': detection.confidence,
          'isArabic': _isArabicText(text),
        });

        _activeService = _smartTtsService;
        
        await _smartTtsService.playText(
          text,
          voice: voice,
          speed: speed,
          pitch: pitch,
          allowFallback: allowFallback,
        );

        TtsLogger.metric('hybrid.route.tts', 1, {
          'isArabic': _isArabicText(text),
          'textLength': text.length,
        });
      }

    } catch (e) {
      TtsLogger.error('Erreur HybridAudioService', {
        'service': _activeService?.runtimeType.toString() ?? 'none',
        'error': e.toString(),
      });

      // Fallback vers SmartTTS si QuranRecitationService échoue
      if (_activeService == _quranRecitationService && allowFallback) {
        TtsLogger.warning('🔄 Fallback récitation -> TTS normal', {
          'reason': e.toString(),
        });
        
        try {
          _activeService = _smartTtsService;
          await _smartTtsService.playText(
            text,
            voice: voice,
            speed: speed,
            pitch: pitch,
            allowFallback: true,
          );
          
          TtsLogger.metric('hybrid.fallback.success', 1);
          return;
        } catch (fallbackError) {
          TtsLogger.error('Échec fallback TTS', {
            'error': fallbackError.toString(),
          });
        }
      }

      TtsLogger.metric('hybrid.error', 1);
      rethrow;
      
    } finally {
      timer.stop();
    }
  }

  /// Ajuste la vitesse pour la récitation coranique
  double _adjustSpeedForQuran(double originalSpeed) {
    // La récitation coranique doit être plus lente que le TTS normal
    // Mapper les vitesses : 0.5-1.5 -> 0.3-0.8
    final adjustedSpeed = (originalSpeed * 0.6).clamp(0.3, 0.8);
    
    TtsLogger.info('⚡ Ajustement vitesse récitation', {
      'original': originalSpeed,
      'adjusted': adjustedSpeed,
    });
    
    return adjustedSpeed;
  }

  /// Détecte si le texte contient de l'arabe
  bool _isArabicText(String text) {
    if (text.trim().isEmpty) return false;
    
    final arabicRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]');
    return arabicRegex.hasMatch(text);
  }

  @override
  Future<void> stop() async {
    try {
      // Arrêter tous les services
      await Future.wait([
        _smartTtsService.stop(),
        _quranRecitationService.stop(),
      ]);
      
      _activeService = null;
      
      TtsLogger.info('🛑 HybridAudioService arrêté');
    } catch (e) {
      TtsLogger.error('Erreur stop HybridAudioService', {
        'error': e.toString(),
      });
    }
  }

  @override
  Stream<Duration> positionStream() {
    // Retourner le stream du service actif, sinon celui de smartTTS par défaut
    if (_activeService != null) {
      return _activeService!.positionStream();
    }
    return _smartTtsService.positionStream();
  }

  @override
  Future<void> cacheIfNeeded(
    String text, {
    required String voice,
    double speed = 1.0,
  }) async {
    try {
      // Détecter le type de contenu pour le pré-cache
      final detection = await QuranContentDetector.detectQuranContent(text);
      
      if (detection.isQuranic && detection.confidence > 0.8) {
        // Pré-cacher la récitation coranique
        await _quranRecitationService.cacheIfNeeded(
          text,
          voice: voice,
          speed: _adjustSpeedForQuran(speed),
        );
        
        TtsLogger.info('Pré-cache récitation initié', {
          'surah': detection.verse?.surah,
          'ayah': detection.verse?.ayah,
        });
      } else {
        // Pré-cacher le TTS normal
        await _smartTtsService.cacheIfNeeded(
          text,
          voice: voice,
          speed: speed,
        );
        
        TtsLogger.info('Pré-cache TTS normal initié', {
          'textLength': text.length,
        });
      }
      
    } catch (e) {
      TtsLogger.debug('Échec pré-cache hybride', {
        'error': e.toString(),
      });
    }
  }

  /// Détecte le type de contenu d'un texte
  Future<QuranDetectionResult> detectContentType(String text) async {
    return await QuranContentDetector.detectQuranContent(text);
  }

  /// Obtient des informations sur le service actuellement actif
  Map<String, dynamic> getActiveServiceInfo() {
    return {
      'activeService': _activeService?.runtimeType.toString() ?? 'none',
      'smartTtsAvailable': true,
      'quranServiceAvailable': true,
    };
  }

  void dispose() {
    try {
      _quranRecitationService.dispose();
      // Note: ne pas disposer _smartTtsService car il peut être partagé
    } catch (e) {
      TtsLogger.error('Erreur dispose HybridAudioService', {
        'error': e.toString(),
      });
    }
  }
}

/// Provider Riverpod pour HybridAudioService
final hybridAudioServiceProvider = Provider<HybridAudioService>((ref) {
  final smartTts = ref.watch(smartTtsServiceProvider);
  final quranService = ref.watch(quranRecitationServiceProvider);
  
  final hybridService = HybridAudioService(
    smartTtsService: smartTts,
    quranRecitationService: quranService,
  );
  
  ref.onDispose(() {
    hybridService.dispose();
  });
  
  return hybridService;
});

/// Provider principal pour remplacer audioTtsServiceProvider
/// Utilise HybridAudioService pour router intelligemment le contenu
final audioTtsServiceHybridProvider = Provider<AudioTtsService>((ref) {
  return ref.watch(hybridAudioServiceProvider);
});