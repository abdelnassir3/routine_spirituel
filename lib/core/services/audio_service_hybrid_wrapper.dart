import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_session/audio_session.dart';

import 'audio_tts_service.dart';
import 'smart_tts_service.dart';
import 'tts_logger_service.dart';
import 'audio/hybrid_audio_service.dart';
import 'audio/content_detector_service.dart';

/// Wrapper qui adapte le système hybride existant à l'interface AudioTtsService
/// Route intelligemment entre APIs Quran et Edge-TTS selon le type de contenu
class AudioServiceHybridWrapper implements AudioTtsService {
  final AudioTtsService _fallbackTtsService;
  AudioPlayer _audioPlayer = AudioPlayer();
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();

  StreamSubscription<Duration>? _positionSubscription;
  bool _isDisposing = false;

  // Settings hybrides configurables
  final HybridAudioSettings _settings;

  AudioServiceHybridWrapper({
    required AudioTtsService fallbackTtsService,
    HybridAudioSettings? settings,
  })  : _fallbackTtsService = fallbackTtsService,
        _settings = settings ?? HybridAudioSettings.defaultSettings() {
    _setupAudioPlayer();

    TtsLogger.info('🎯 AudioServiceHybridWrapper initialisé', {
      'quranicProvider': _settings.quranicProvider.displayName,
      'preferredReciter': _settings.preferredReciter,
      'diacritization': _settings.enableDiacritization,
      'fallbackService': _fallbackTtsService.runtimeType.toString(),
    });
  }

  void _setupAudioPlayer() {
    _initAudioSession();

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      _safeAddToPositionStream(position);
    });

    _audioPlayer.playbackEventStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        _safeAddToPositionStream(Duration.zero);
      }
    });
  }

  /// Initialise la session audio pour iOS
  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.audibilityEnforced,
          usage: AndroidAudioUsage.assistanceAccessibility,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: false,
      ));

      TtsLogger.info('🔊 Session audio configurée', {
        'category': 'playback',
        'options': 'duckOthers',
      });
    } catch (e) {
      TtsLogger.warning('⚠️ Erreur configuration session audio', {
        'error': e.toString(),
      });
    }
  }

  @override
  Future<void> playText(
    String text, {
    required String voice,
    double speed = 0.9,
    double pitch = 1.0,
    bool allowFallback = true,
  }) async {
    final timer = TtsPerformanceTimer('hybrid_wrapper.playText', {
      'textLength': text.length,
      'voice': voice,
      'speed': speed,
    });

    try {
      // Arrêter toute lecture en cours de manière complète
      await stop();

      // Attendre un peu pour s'assurer que tout est bien arrêté
      await Future.delayed(Duration(milliseconds: 100));

      // Analyser le contenu avec le système existant
      final contentAnalysis =
          await HybridAudioService.analyzeContentDetails(text);

      TtsLogger.info('🔍 Analyse de contenu', {
        'contentType': contentAnalysis.contentType.toString(),
        'verses': contentAnalysis.verses.length,
        'arabicRatio':
            (contentAnalysis.languageRatio.arabic * 100).toStringAsFixed(1) +
                '%',
        'frenchRatio':
            (contentAnalysis.languageRatio.french * 100).toStringAsFixed(1) +
                '%',
        'textPreview':
            text.substring(0, text.length > 50 ? 50 : text.length) + '...',
      });

      // Router selon le type de contenu
      if (contentAnalysis.contentType == ContentType.quranicVerse) {
        // CONTENU CORANIQUE -> Utiliser les APIs Quran
        TtsLogger.info('🕌 Routage vers API Quran', {
          'verses': contentAnalysis.verses
              .map((v) => '${v.surah}:${v.verse}')
              .join(', '),
          'provider': _settings.quranicProvider.displayName,
          'reciter': _settings.preferredReciter,
        });

        await _playQuranicAudio(contentAnalysis, voice, speed);

        TtsLogger.metric('hybrid_wrapper.route.quran', 1, {
          'provider': _settings.quranicProvider.name,
          'verses': contentAnalysis.verses.length,
        });
      } else {
        // TEXTE NORMAL -> Utiliser système hybride avec Edge-TTS
        TtsLogger.info('🗣️ Routage vers système hybride Edge-TTS', {
          'contentType': contentAnalysis.contentType.toString(),
          'enableDiacritization': _settings.enableDiacritization,
        });

        await _playHybridTtsAudio(
            contentAnalysis, voice, speed, pitch, allowFallback);

        TtsLogger.metric('hybrid_wrapper.route.tts', 1, {
          'contentType': contentAnalysis.contentType.name,
        });
      }
    } catch (e) {
      TtsLogger.error('Erreur AudioServiceHybridWrapper', {
        'error': e.toString(),
        'voice': voice,
      });

      // Fallback vers le service TTS traditionnel
      if (allowFallback) {
        TtsLogger.warning('🔄 Fallback global vers service TTS traditionnel', {
          'reason': e.toString(),
        });

        try {
          // Ajuster la vitesse pour le fallback TTS selon la langue
          double adjustedSpeed = speed;
          if (_isArabicContent(text)) {
            // Pour l'arabe, utiliser une vitesse plus lente (max 0.6)
            adjustedSpeed = (speed * 0.6).clamp(0.4, 0.6);
            TtsLogger.info('⚡ Vitesse ajustée pour arabe (fallback global)', {
              'original': speed,
              'adjusted': adjustedSpeed,
            });
          } else {
            // Pour le français, vitesse normale mais limitée
            adjustedSpeed = speed.clamp(0.5, 0.8);
          }

          await _fallbackTtsService.playText(
            text,
            voice: voice,
            speed: adjustedSpeed,
            pitch: pitch,
            allowFallback: true,
          );

          TtsLogger.metric('hybrid_wrapper.fallback.success', 1);
          return;
        } catch (fallbackError) {
          TtsLogger.error('Échec fallback TTS global', {
            'error': fallbackError.toString(),
          });
        }
      }

      TtsLogger.metric('hybrid_wrapper.error', 1);
      rethrow;
    } finally {
      timer.stop();
    }
  }

  /// Joue l'audio coranique en utilisant les APIs Quran
  Future<void> _playQuranicAudio(
    ContentAnalysis analysis,
    String voice,
    double speed,
  ) async {
    // Ajuster la vitesse pour la récitation coranique (plus lente)
    final adjustedSpeed = _adjustSpeedForQuran(speed);

    // Utiliser le système hybride existant
    final audioBytes = await HybridAudioService.generateAudio(
      analysis.originalText,
      language: 'ar-SA',
      speed: adjustedSpeed,
      settings: _settings,
    );

    if (audioBytes == null) {
      throw Exception('Impossible de générer l\'audio coranique');
    }

    // Jouer l'audio généré
    await _playAudioBytes(audioBytes, 'quran_audio');
  }

  /// Joue l'audio TTS hybride (Edge-TTS avec diacritisation)
  Future<void> _playHybridTtsAudio(
    ContentAnalysis analysis,
    String voice,
    double speed,
    double pitch,
    bool allowFallback,
  ) async {
    // Utiliser le système hybride existant pour générer l'audio
    final audioBytes = await HybridAudioService.generateAudio(
      analysis.originalText,
      language: 'auto',
      speed: speed,
      pitch: pitch,
      settings: _settings,
    );

    if (audioBytes != null) {
      try {
        // Jouer l'audio généré par le système hybride
        await _playAudioBytes(audioBytes, 'hybrid_tts');
        // Si on arrive ici, la lecture a réussi
        return;
      } catch (e) {
        TtsLogger.warning('⚠️ Échec lecture Edge-TTS, fallback nécessaire', {
          'error': e.toString(),
          'allowFallback': allowFallback,
        });
        // Continuer vers le fallback si autorisé
        if (!allowFallback) {
          rethrow;
        }
      }
    }

    // Fallback vers le service TTS traditionnel
    if (allowFallback) {
      // Fallback vers le service TTS traditionnel avec vitesse ajustée
      double adjustedSpeed = speed;
      if (_isArabicContent(analysis.originalText)) {
        adjustedSpeed = (speed * 0.6).clamp(0.4, 0.6);
        TtsLogger.info('⚡ Vitesse ajustée pour arabe (fallback hybride)', {
          'original': speed,
          'adjusted': adjustedSpeed,
        });
      } else {
        adjustedSpeed = speed.clamp(0.5, 0.8);
      }

      // Utiliser le texte original pour le fallback
      final textForFallback = analysis.originalText;

      TtsLogger.info('🔄 Activation du fallback flutter_tts', {
        'text': textForFallback.substring(
                0, textForFallback.length > 50 ? 50 : textForFallback.length) +
            '...',
        'voice': voice,
        'adjustedSpeed': adjustedSpeed,
        'isArabic': _isArabicContent(textForFallback),
      });

      await _fallbackTtsService.playText(
        textForFallback,
        voice: voice,
        speed: adjustedSpeed,
        pitch: pitch,
        allowFallback: true,
      );
    } else {
      throw Exception('Impossible de générer l\'audio TTS hybride');
    }
  }

  /// Joue des données audio à partir de bytes
  Future<void> _playAudioBytes(Uint8List audioBytes, String prefix) async {
    try {
      // Arrêter toute lecture en cours de manière complète
      try {
        await _audioPlayer.stop();
      } catch (_) {}

      // S'assurer qu'aucun autre service ne joue en même temps
      await _fallbackTtsService.stop();

      // Réactiver la session audio si nécessaire
      try {
        final session = await AudioSession.instance;
        await session.setActive(true);
        TtsLogger.info('🔊 Session audio activée');
      } catch (e) {
        TtsLogger.debug(
            'Erreur activation session audio', {'error': e.toString()});
      }

      // Créer un fichier temporaire
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
          '${tempDir.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.mp3');

      await tempFile.writeAsBytes(audioBytes);

      TtsLogger.info('📁 Fichier audio créé', {
        'path': tempFile.path,
        'size': audioBytes.length,
        'exists': await tempFile.exists(),
      });

      // Vérifier si le fichier est valide
      final fileInfo = await tempFile.stat();
      if (fileInfo.size == 0) {
        throw Exception('Fichier audio vide');
      }

      // Charger et jouer avec just_audio
      await _audioPlayer.setFilePath(tempFile.path);

      // Attendre que l'audio soit complètement chargé
      await _audioPlayer.load();

      // Vérifier la durée pour s'assurer que le fichier est valide
      final duration = _audioPlayer.duration;
      TtsLogger.info('🎵 Audio chargé', {
        'duration': duration?.inMilliseconds,
        'hasValidDuration': duration != null && duration.inMilliseconds > 0,
        'fileSize': fileInfo.size,
      });

      // Configuration du volume pour s'assurer qu'il soit audible
      await _audioPlayer.setVolume(1.0);

      // Jouer l'audio
      await _audioPlayer.play();

      TtsLogger.info('▶️ Audio lecture démarrée', {
        'isPlaying': _audioPlayer.playing,
        'volume': _audioPlayer.volume,
        'position': _audioPlayer.position.inMilliseconds,
      });

      // Attendre pour vérifier si la lecture fonctionne réellement
      await Future.delayed(Duration(milliseconds: 500));

      final isActuallyPlaying = _audioPlayer.playing;
      final currentState = _audioPlayer.processingState;
      final currentPosition = _audioPlayer.position.inMilliseconds;

      TtsLogger.info('🔊 État lecture après 500ms', {
        'isPlaying': isActuallyPlaying,
        'position': currentPosition,
        'processingState': currentState.name,
      });

      // Vérifier si l'audio joue réellement
      if (!isActuallyPlaying ||
          currentState == ProcessingState.idle ||
          (duration == null || duration.inMilliseconds == 0)) {
        TtsLogger.warning('⚠️ Audio MP3 non compatible détecté', {
          'isPlaying': isActuallyPlaying,
          'processingState': currentState.name,
          'duration': duration?.inMilliseconds,
          'position': currentPosition,
        });

        // Arrêter complètement la tentative de lecture Edge-TTS
        await _audioPlayer.stop();
        await _audioPlayer.dispose();

        // Aussi arrêter tout service TTS en arrière-plan qui pourrait jouer
        await _fallbackTtsService.stop();

        // Recréer un nouveau player pour éviter les conflits
        await _recreateAudioPlayer();

        // Attendre un peu pour s'assurer que tout est arrêté
        await Future.delayed(Duration(milliseconds: 200));

        throw Exception(
            'Audio MP3 d\'Edge-TTS incompatible avec AudioPlayer iOS - fallback requis');
      }

      // Nettoyer après un délai
      Future.delayed(Duration(seconds: 30), () async {
        try {
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (e) {
          TtsLogger.debug(
              'Erreur nettoyage fichier temp', {'error': e.toString()});
        }
      });

      TtsLogger.info('Audio joué avec succès', {
        'size': audioBytes.length,
        'prefix': prefix,
      });
    } catch (e) {
      TtsLogger.error('Erreur lecture audio bytes', {
        'error': e.toString(),
        'size': audioBytes.length,
      });
      rethrow;
    }
  }

  /// Ajuste la vitesse pour la récitation coranique
  double _adjustSpeedForQuran(double originalSpeed) {
    // La récitation coranique doit être plus lente
    // Mapper 0.5-1.5 -> 0.4-0.8
    final adjustedSpeed = (originalSpeed * 0.6 + 0.1).clamp(0.4, 0.8);

    TtsLogger.info('⚡ Ajustement vitesse récitation', {
      'original': originalSpeed,
      'adjusted': adjustedSpeed,
    });

    return adjustedSpeed;
  }

  /// Détecte si le contenu est en arabe
  bool _isArabicContent(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F]');
    final arabicMatches = arabicRegex.allMatches(text).length;
    final totalChars = text.replaceAll(RegExp(r'\s'), '').length;

    if (totalChars == 0) return false;

    // Si plus de 50% du contenu est arabe
    return (arabicMatches / totalChars) > 0.5;
  }

  /// Recrée un nouveau AudioPlayer pour éviter les conflits
  Future<void> _recreateAudioPlayer() async {
    try {
      // Annuler la subscription existante
      await _positionSubscription?.cancel();

      // Créer un nouveau player
      _audioPlayer = AudioPlayer();

      // Reconfigurer les listeners avec protection
      if (!_isDisposing && !_positionController.isClosed) {
        _positionSubscription = _audioPlayer.positionStream.listen((position) {
          _safeAddToPositionStream(position);
        });

        _audioPlayer.playbackEventStream.listen((event) {
          if (event.processingState == ProcessingState.completed) {
            _safeAddToPositionStream(Duration.zero);
          }
        });
      }

      TtsLogger.info('🔄 Nouveau AudioPlayer créé pour éviter les conflits');
    } catch (e) {
      TtsLogger.error('Erreur recréation AudioPlayer', {
        'error': e.toString(),
      });
    }
  }

  @override
  Future<void> stop() async {
    try {
      // Arrêter d'abord le lecteur audio principal
      await _audioPlayer.stop();

      // Arrêter le service TTS de fallback
      await _fallbackTtsService.stop();

      // Réinitialiser le stream de position de manière sécurisée
      _safeAddToPositionStream(Duration.zero);

      // Attendre un peu pour s'assurer que tout est arrêté
      await Future.delayed(Duration(milliseconds: 100));

      TtsLogger.info('🛑 AudioServiceHybridWrapper arrêté complètement');
    } catch (e) {
      TtsLogger.error('Erreur stop wrapper', {
        'error': e.toString(),
      });
    }
  }

  @override
  Stream<Duration> positionStream() {
    return _positionController.stream;
  }

  @override
  Future<void> cacheIfNeeded(
    String text, {
    required String voice,
    double speed = 1.0,
  }) async {
    try {
      // Analyser le contenu pour le pré-cache
      final analysis = await HybridAudioService.analyzeContentDetails(text);

      // Pré-générer l'audio selon le type
      if (analysis.contentType == ContentType.quranicVerse) {
        TtsLogger.info('Pré-cache API Quran initié', {
          'verses': analysis.verses.length,
        });

        // Le système hybride gère déjà le cache
        await HybridAudioService.generateAudio(
          text,
          language: 'ar-SA',
          speed: _adjustSpeedForQuran(speed),
          settings: _settings,
        );
      } else {
        TtsLogger.info('Pré-cache TTS hybride initié', {
          'contentType': analysis.contentType.toString(),
        });

        await HybridAudioService.generateAudio(
          text,
          language: 'auto',
          speed: speed,
          settings: _settings,
        );
      }
    } catch (e) {
      TtsLogger.debug('Échec pré-cache wrapper', {
        'error': e.toString(),
      });

      // Fallback vers le service traditionnel
      await _fallbackTtsService.cacheIfNeeded(
        text,
        voice: voice,
        speed: speed,
      );
    }
  }

  /// Obtient des informations sur les paramètres hybrides
  Map<String, dynamic> getHybridSettings() {
    return {
      'quranicProvider': _settings.quranicProvider.displayName,
      'preferredReciter': _settings.preferredReciter,
      'arabicVoice': _settings.arabicVoice.name,
      'frenchVoice': _settings.frenchVoice.name,
      'enableDiacritization': _settings.enableDiacritization,
      'enableCaching': _settings.enableAudioCaching,
    };
  }

  void dispose() {
    _isDisposing = true;
    try {
      _positionSubscription?.cancel();
      _audioPlayer.dispose();

      // Fermeture sécurisée du controller
      if (!_positionController.isClosed) {
        _positionController.close();
      }
    } catch (e) {
      TtsLogger.error('Erreur dispose wrapper', {
        'error': e.toString(),
      });
    }
  }

  /// Méthode sécurisée pour ajouter des événements au stream
  void _safeAddToPositionStream(Duration position) {
    if (!_isDisposing && !_positionController.isClosed) {
      try {
        _positionController.add(position);
      } catch (e) {
        TtsLogger.debug('Erreur ajout position stream (ignorée)', {
          'error': e.toString(),
          'isDisposing': _isDisposing,
          'isClosed': _positionController.isClosed,
        });
      }
    }
  }
}

/// Provider Riverpod pour le wrapper hybride
final audioServiceHybridWrapperProvider =
    Provider<AudioServiceHybridWrapper>((ref) {
  final smartTts = ref.watch(smartTtsServiceProvider);

  // Configuration optimisée pour récitation coranique
  final hybridSettings = HybridAudioSettings.highQuality();

  final wrapper = AudioServiceHybridWrapper(
    fallbackTtsService: smartTts,
    settings: hybridSettings,
  );

  ref.onDispose(() {
    wrapper.dispose();
  });

  return wrapper;
});

/// Provider principal - remplace audioTtsServiceProvider
final audioTtsServiceHybridProvider = Provider<AudioTtsService>((ref) {
  return ref.watch(audioServiceHybridWrapperProvider);
});
