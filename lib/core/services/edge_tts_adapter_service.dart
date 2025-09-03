import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io';

import 'audio_tts_service.dart';
import 'tts_config_service.dart';
import 'tts_logger_service.dart';
import 'secure_tts_cache_service.dart';
import 'audio/edge_tts_service.dart';
import 'audio/audio_api_config.dart';

/// Exception spécialisée pour les problèmes de compatibilité audio
class AudioCompatibilityException implements Exception {
  final String message;
  AudioCompatibilityException(this.message);

  @override
  String toString() => 'AudioCompatibilityException: $message';
}

/// Service qui adapte Edge-TTS pour remplacer Coqui TTS
/// Utilise l'API Edge-TTS sur votre VPS tout en gardant la même interface
class EdgeTtsAdapterService implements AudioTtsService {
  final TtsConfigService _config;
  final SecureTtsCacheService _cache;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();

  StreamSubscription<Duration>? _positionSubscription;
  int _consecutiveFailures = 0;
  static const int _maxConsecutiveFailures = 5;

  EdgeTtsAdapterService({
    required TtsConfigService config,
    required SecureTtsCacheService cache,
  })  : _config = config,
        _cache = cache {
    _setupAudioPlayer();
    TtsLogger.info('🎯 EdgeTtsAdapterService initialisé', {
      'endpoint': AudioApiConfig.edgeTtsBaseUrl,
      'apiKeyPresent': AudioApiConfig.edgeTtsApiKey.isNotEmpty,
    });
  }

  void _setupAudioPlayer() {
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      _positionController.add(position);
    });
  }

  @override
  Future<void> playText(
    String text, {
    required String voice,
    double speed = 1.0,
    double pitch = 1.0,
    bool allowFallback = false, // Paramètre ignoré dans EdgeTtsAdapterService
  }) async {
    final timer = TtsPerformanceTimer('edge_tts.playText', {
      'voice': voice,
      'speed': speed,
      'pitch': pitch,
      'textLength': text.length,
    });

    try {
      final edgeTtsVoice = _mapToEdgeTtsVoice(voice);
      final language = _detectLanguage(voice);

      TtsLogger.info('Synthèse TTS Edge-TTS', {
        'originalVoice': voice,
        'edgeTtsVoice': edgeTtsVoice.name,
        'language': language,
        'voiceType': _detectVoiceType(voice),
        'speed': speed,
        'pitch': pitch,
        'textPreview':
            text.substring(0, text.length > 50 ? 50 : text.length) + '...',
      });

      // 1. Vérifier le cache
      final cacheKey = _generateCacheKey(text, voice, speed, pitch);

      Uint8List? audioData;

      try {
        // Tenter de récupérer depuis le cache
        final cachedPath = await _cache.getPath(cacheKey);
        if (cachedPath != null) {
          final cachedFile = File(cachedPath);
          if (await cachedFile.exists()) {
            audioData = await cachedFile.readAsBytes();
            TtsLogger.info('✅ Audio trouvé en cache');
          }
        }
      } catch (e) {
        TtsLogger.debug('Cache miss ou erreur', {'error': e.toString()});
      }

      // 2. Si pas en cache, synthétiser avec Edge-TTS
      if (audioData == null) {
        TtsLogger.info('Synthèse Edge-TTS requise');

        // Appeler Edge-TTS
        audioData = await EdgeTtsService.synthesizeText(
          text,
          language: language,
          voice: edgeTtsVoice,
          rate: speed,
          pitch: pitch,
        );

        if (audioData == null) {
          throw Exception('Échec de synthèse Edge-TTS');
        }

        // 3. Mettre en cache
        if (_config.cacheEnabled) {
          try {
            // Créer un fichier temporaire pour le cache
            final tempDir = await getTemporaryDirectory();
            final tempCacheFile = File(
                '${tempDir.path}/cache_${DateTime.now().millisecondsSinceEpoch}.mp3');
            await tempCacheFile.writeAsBytes(audioData);

            await _cache.store(
              key: cacheKey,
              filePath: tempCacheFile.path,
              metadata: {
                'voice': voice,
                'speed': speed,
                'pitch': pitch,
                'textLength': text.length,
                'provider': 'edge-tts',
              },
            );

            // Nettoyer le fichier temporaire
            await tempCacheFile.delete();

            TtsLogger.info('Audio mis en cache', {
              'size': audioData.length,
              'cacheKey': cacheKey.substring(0, 8) + '...'
            });
          } catch (e) {
            TtsLogger.warning('Échec mise en cache', {'error': e.toString()});
          }
        }
      }

      // 4. Jouer l'audio
      await _playAudioData(audioData);

      // Réinitialiser le compteur d'échecs
      _consecutiveFailures = 0;

      TtsLogger.metric('tts.edge.success', 1);
    } catch (e) {
      _consecutiveFailures++;
      TtsLogger.error(
          'Erreur TTS Edge-TTS',
          {
            'consecutiveFailures': _consecutiveFailures,
            'error': e.toString(),
          },
          e);

      TtsLogger.metric('tts.edge.error', 1);

      if (_consecutiveFailures >= _maxConsecutiveFailures) {
        TtsLogger.error('Trop d\'échecs Edge-TTS consécutifs', {
          'count': _consecutiveFailures,
        });
      }

      rethrow;
    } finally {
      timer.stop();
    }
  }

  /// Joue les données audio avec validation et fallback
  Future<void> _playAudioData(Uint8List audioData) async {
    try {
      // Écrire dans un fichier temporaire
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
          '${tempDir.path}/edge_tts_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await tempFile.writeAsBytes(audioData);

      TtsLogger.info('📁 Fichier Edge-TTS créé', {
        'path': tempFile.path,
        'size': audioData.length,
      });

      // Validation du fichier MP3 avant lecture
      final isValid = await _validateAudioFile(tempFile.path, audioData);

      if (!isValid) {
        // Nettoyage du fichier invalide
        await tempFile.delete();
        throw AudioCompatibilityException(
            'Fichier MP3 Edge-TTS incompatible avec just_audio iOS');
      }

      // Jouer avec just_audio si validation OK
      await _audioPlayer.setFilePath(tempFile.path);
      await _audioPlayer.play();

      TtsLogger.info('▶️ Edge-TTS audio lecture démarrée avec succès');

      // Nettoyer après un délai
      Future.delayed(Duration(seconds: 10), () async {
        try {
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (_) {}
      });
    } catch (e) {
      TtsLogger.error('Erreur lecture audio Edge-TTS', {'error': e.toString()});
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      TtsLogger.info('Audio Edge-TTS arrêté');
    } catch (e) {
      TtsLogger.error('Erreur stop Edge-TTS', null, e);
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      TtsLogger.info('Audio Edge-TTS mis en pause');
    } catch (e) {
      TtsLogger.error('Erreur pause Edge-TTS', null, e);
    }
  }

  @override
  Future<void> resume() async {
    try {
      await _audioPlayer.play();
      TtsLogger.info('Audio Edge-TTS repris');
    } catch (e) {
      TtsLogger.error('Erreur resume Edge-TTS', null, e);
    }
  }

  @override
  bool get isPlaying {
    return _audioPlayer.playing;
  }

  @override
  bool get isPaused {
    return !_audioPlayer.playing && _audioPlayer.duration != null;
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
    if (!_config.cacheEnabled) return;

    final cacheKey = _generateCacheKey(text, voice, speed, 1.0);

    try {
      // Vérifier si déjà en cache
      final existing = await _cache.exists(cacheKey);
      if (existing) {
        TtsLogger.debug('Déjà en cache', {'key': cacheKey.substring(0, 8)});
        return;
      }

      // Synthétiser et mettre en cache
      final edgeTtsVoice = _mapToEdgeTtsVoice(voice);
      final language = _detectLanguage(voice);

      final audioData = await EdgeTtsService.synthesizeText(
        text,
        language: language,
        voice: edgeTtsVoice,
        rate: speed,
      );

      if (audioData != null) {
        // Créer un fichier temporaire pour le cache
        final tempDir = await getTemporaryDirectory();
        final tempCacheFile = File(
            '${tempDir.path}/precache_${DateTime.now().millisecondsSinceEpoch}.mp3');
        await tempCacheFile.writeAsBytes(audioData);

        await _cache.store(
          key: cacheKey,
          filePath: tempCacheFile.path,
          metadata: {
            'voice': voice,
            'speed': speed,
            'textLength': text.length,
            'provider': 'edge-tts',
          },
        );

        // Nettoyer le fichier temporaire
        await tempCacheFile.delete();

        TtsLogger.info('Pré-cache Edge-TTS réussi', {
          'size': audioData.length,
        });
      }
    } catch (e) {
      TtsLogger.debug('Échec pré-cache', {'error': e.toString()});
    }
  }

  /// Génère une clé de cache unique
  String _generateCacheKey(
      String text, String voice, double speed, double pitch) {
    final content = '$text|$voice|$speed|$pitch|edge-tts';
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Détecte la langue depuis le nom de la voix
  String _detectLanguage(String voice) {
    if (voice.contains('fr-FR') || voice.contains('French')) {
      return 'fr-FR';
    } else if (voice.contains('ar-') || voice.contains('Arabic')) {
      return 'ar-SA';
    } else if (voice.contains('en-') || voice.contains('English')) {
      return 'en-US';
    }
    return 'fr-FR'; // Par défaut
  }

  /// Détecte le type de voix (masculin/féminin)
  String _detectVoiceType(String voice) {
    final voiceLower = voice.toLowerCase();
    if (voiceLower.contains('male') ||
        voiceLower.contains('henri') ||
        voiceLower.contains('hamed') ||
        voiceLower.contains('guy')) {
      return 'male';
    }
    return 'female';
  }

  /// Mappe les voix Coqui vers Edge-TTS
  EdgeTtsVoice _mapToEdgeTtsVoice(String voice) {
    TtsLogger.info('🎙️ Mapping voix Edge-TTS', {
      'inputVoice': voice,
      'containsFrench': voice.contains('fr-FR') || voice.contains('French'),
      'containsArabic': voice.contains('ar-') || voice.contains('Arabic'),
      'containsEnglish': voice.contains('en-') || voice.contains('English'),
    });

    // Mapper les anciennes voix Coqui vers Edge-TTS
    if (voice.contains('fr-FR') || voice.contains('French')) {
      final selectedVoice = (voice.contains('Henri') || voice.contains('male'))
          ? EdgeTtsVoice.frenchHenri
          : EdgeTtsVoice.frenchDenise;

      TtsLogger.info('✅ Voix française sélectionnée', {
        'selectedVoice': selectedVoice.name,
        'reason': 'French detected',
      });
      return selectedVoice;
    } else if (voice.contains('ar-') ||
        voice.contains('Arabic') ||
        voice == 'ar') {
      final selectedVoice =
          (voice.contains('Zariyah') || voice.contains('female'))
              ? EdgeTtsVoice.arabicZariyah
              : EdgeTtsVoice.arabicHamed;

      TtsLogger.info('✅ Voix arabe sélectionnée', {
        'selectedVoice': selectedVoice.name,
        'reason': 'Arabic detected',
      });
      return selectedVoice;
    } else if (voice.contains('en-') || voice.contains('English')) {
      final selectedVoice = (voice.contains('Guy') || voice.contains('male'))
          ? EdgeTtsVoice.englishGuy
          : EdgeTtsVoice.englishAria;

      TtsLogger.info('✅ Voix anglaise sélectionnée', {
        'selectedVoice': selectedVoice.name,
        'reason': 'English detected',
      });
      return selectedVoice;
    }

    // PROBLÈME : Défaut vers français au lieu d'arabe pour langue inconnue
    TtsLogger.warning('⚠️ Langue non détectée, fallback vers arabe', {
      'inputVoice': voice,
      'defaultVoice': EdgeTtsVoice.arabicHamed.name,
    });
    return EdgeTtsVoice.arabicHamed; // Changé de frenchDenise vers arabicHamed
  }

  /// Valide la compatibilité d'un fichier audio avec just_audio
  Future<bool> _validateAudioFile(String filePath, Uint8List audioData) async {
    try {
      TtsLogger.info('🔍 Validation fichier Edge-TTS', {
        'path': filePath,
        'size': audioData.length,
      });

      // 1. Validation basique du header MP3
      if (!_isValidMp3Header(audioData)) {
        TtsLogger.warning('❌ Header MP3 invalide détecté');
        return false;
      }

      // 2. Test de décodage avec just_audio
      final testPlayer = AudioPlayer();
      try {
        await testPlayer.setFilePath(filePath);

        // Attendre que le fichier soit complètement chargé
        await testPlayer.load();

        // Vérifier la durée pour confirmer le décodage
        final duration = testPlayer.duration;

        await testPlayer.dispose();

        final isValid = duration != null && duration.inMilliseconds > 0;

        TtsLogger.info('🎵 Validation Edge-TTS résultat', {
          'isValid': isValid,
          'duration': duration?.inMilliseconds,
          'hasValidDuration': duration != null,
        });

        return isValid;
      } finally {
        await testPlayer.dispose();
      }
    } catch (e) {
      TtsLogger.warning('❌ Erreur validation Edge-TTS', {
        'error': e.toString(),
      });
      return false;
    }
  }

  /// Vérifie si les données ont un header MP3 valide
  bool _isValidMp3Header(Uint8List bytes) {
    if (bytes.length < 4) return false;

    // Header MP3: FF FB ou FF FA (MPEG Layer 3)
    return bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0;
  }

  void dispose() {
    _positionSubscription?.cancel();
    _audioPlayer.dispose();
    _positionController.close();
  }
}
