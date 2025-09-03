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
  })  : _smartTtsService = smartTtsService,
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

    // Déclarer detection outside try block so it's available in catch
    QuranDetectionResult? detection;

    try {
      // Arrêter tout audio en cours
      await stop();

      // Détecter le type de contenu
      detection = await QuranContentDetector.detectQuranContent(text);

      TtsLogger.info('🔍 Détection de contenu', {
        'isQuranic': detection.isQuranic,
        'confidence': detection.confidence,
        'matchType': detection.matchType.toString(),
        'textPreview':
            text.substring(0, text.length > 50 ? 50 : text.length) + '...',
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
          'originalText': text.substring(0, text.length > 50 ? 50 : text.length) + '...',
        });

        // NE PAS faire fallback pour le contenu coranique détecté
        // Car le TTS normal ne peut pas lire correctement les versets
        if (detection != null && detection.isQuranic && detection.confidence > 0.8) {
          TtsLogger.error('❌ Échec récitation coranique - pas de fallback TTS pour préserver la qualité', {
            'surah': detection.verse?.surah,
            'ayah': detection.verse?.ayah,
            'confidence': detection.confidence,
            'reason': 'TTS normal inadequate for Quranic content'
          });
          
          // Pour le contenu coranique, échouer silencieusement plutot que de dégrader
          TtsLogger.metric('hybrid.quran.fallback.blocked', 1);
          return; // Ne pas faire de fallback
        }

        // OK pour faire fallback sur texte normal
        _activeService = _smartTtsService;
        await _smartTtsService.playText(
          text,
          voice: voice,
          speed: speed,
          pitch: pitch,
          allowFallback: false, // Pas de fallback supplémentaire
        );

        TtsLogger.metric('hybrid.fallback.success', 1);
      } else {
        // Re-throw si pas de fallback possible
        TtsLogger.metric('hybrid.fallback.failed', 1);
        rethrow;
      }
    } finally {
      timer.stop();
    }
  }

  @override
  Future<void> speak(String text) async {
    // Implementation simple: utilise playText avec voix par défaut
    await playText(
      text,
      voice: 'fr-FR-DeniseNeural', // Voix par défaut
      speed: 0.9,
      pitch: 1.0,
      allowFallback: true,
    );
  }

  @override
  Future<void> stop() async {
    try {
      // Arrêter les deux services
      await Future.wait([
        _smartTtsService.stop(),
        _quranRecitationService.stop(),
      ]);

      _activeService = null;
      TtsLogger.info('⏹️ HybridAudioService arrêté');
    } catch (e) {
      TtsLogger.error('Erreur lors de l\'arrêt HybridAudioService', {
        'error': e.toString(),
      });
    }
  }

  @override
  Future<void> pause() async {
    if (_activeService != null) {
      await _activeService!.pause();
      TtsLogger.info('⏸️ HybridAudioService mis en pause');
    }
  }

  @override
  Future<void> resume() async {
    if (_activeService != null) {
      await _activeService!.resume();
      TtsLogger.info('▶️ HybridAudioService repris');
    }
  }

  @override
  bool get isPlaying {
    return _activeService?.isPlaying ?? false;
  }

  @override
  bool get isPaused {
    return _activeService?.isPaused ?? false;
  }
  
  @override
  Future<void> cacheIfNeeded(String text, {required String voice, double speed = 1.0}) async {
    // Déléguer au service actif ou à SmartTTS par défaut
    if (_activeService != null) {
      await _activeService!.cacheIfNeeded(text, voice: voice, speed: speed);
    } else {
      await _smartTtsService.cacheIfNeeded(text, voice: voice, speed: speed);
    }
  }
  
  @override
  Stream<Duration> positionStream() {
    // Retourner le stream du service actif ou un stream vide
    return _activeService?.positionStream() ?? const Stream.empty();
  }

  /// Ajuste la vitesse pour la récitation coranique
  /// La récitation doit être plus lente pour être respectueuse
  double _adjustSpeedForQuran(double originalSpeed) {
    // Réduire la vitesse de 20% pour la récitation
    final adjustedSpeed = originalSpeed * 0.8;
    
    // Garder dans les limites raisonnables (0.3 - 1.2)
    return adjustedSpeed.clamp(0.3, 1.2);
  }

  /// Détecte si un texte contient principalement des caractères arabes
  bool _isArabicText(String text) {
    if (text.trim().isEmpty) return false;
    
    int arabicCount = 0;
    int totalLetters = 0;
    
    for (int i = 0; i < text.length; i++) {
      final codeUnit = text.codeUnitAt(i);
      
      // Vérifier si c'est une lettre (pas de ponctuation, espaces, etc.)
      if ((codeUnit >= 0x0041 && codeUnit <= 0x005A) || // A-Z
          (codeUnit >= 0x0061 && codeUnit <= 0x007A) || // a-z
          (codeUnit >= 0x0600 && codeUnit <= 0x06FF) || // Arabic block
          (codeUnit >= 0x0750 && codeUnit <= 0x077F) || // Arabic Supplement
          (codeUnit >= 0x08A0 && codeUnit <= 0x08FF)) { // Arabic Extended-A
        totalLetters++;
        
        // Vérifier si c'est un caractère arabe
        if ((codeUnit >= 0x0600 && codeUnit <= 0x06FF) || // Arabic block
            (codeUnit >= 0x0750 && codeUnit <= 0x077F) || // Arabic Supplement
            (codeUnit >= 0x08A0 && codeUnit <= 0x08FF)) { // Arabic Extended-A
          arabicCount++;
        }
      }
    }
    
    if (totalLetters == 0) return false;
    
    // Si plus de 50% des lettres sont arabes, considérer comme texte arabe
    return (arabicCount / totalLetters) > 0.5;
  }

  /// Méthodes pour compatibilité avec l'interface
  String get currentVoice => _activeService?.toString() ?? 'HybridService';
  double get currentSpeed => 0.9; // Vitesse par défaut
  double get currentPitch => 1.0; // Pitch par défaut
}

/// Provider pour le service hybride
final hybridAudioServiceProvider = Provider<HybridAudioService>((ref) {
  final smartTtsService = ref.watch(smartTtsServiceProvider);
  final quranService = ref.watch(quranRecitationServiceProvider);
  
  return HybridAudioService(
    smartTtsService: smartTtsService,
    quranRecitationService: quranService,
  );
});

/// Alias pour la compatibilité avec le code existant
final audioTtsServiceHybridProvider = hybridAudioServiceProvider;