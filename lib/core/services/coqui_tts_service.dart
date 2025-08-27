import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

import 'audio_tts_service.dart';
import 'tts_config_service.dart';
import 'tts_logger_service.dart';
import 'secure_tts_cache_service.dart';

/// Service TTS utilisant Coqui XTTS-v2 sur serveur VPS
/// Implémente retry, timeout, métriques et fallback
class CoquiTtsService implements AudioTtsService {
  final TtsConfigService _config;
  final SecureTtsCacheService _cache;
  final Dio _dio;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();

  StreamSubscription<Duration>? _positionSubscription;
  Timer? _retryTimer;
  int _consecutiveFailures = 0;
  static const int _maxConsecutiveFailures = 5;

  CoquiTtsService({
    required TtsConfigService config,
    required SecureTtsCacheService cache,
    Dio? dio,
  })  : _config = config,
        _cache = cache,
        _dio = dio ?? Dio() {
    _setupDio();
    _setupAudioPlayer();
  }

  void _setupDio() {
    // Configuration Dio avec timeout très étendu pour les textes longs
    // Les timeouts sont largement augmentés pour supporter les longues synthèses
    _dio.options = BaseOptions(
      connectTimeout: Duration(seconds: 15), // 15 secondes pour la connexion
      receiveTimeout:
          Duration(seconds: 600), // 10 minutes pour recevoir la réponse
      sendTimeout: Duration(seconds: 60), // 60 secondes pour envoyer la requête
      responseType: ResponseType.json,
      validateStatus: (status) => status != null && status < 500,
    );

    // Intercepteur pour retry avec exponential backoff
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (_shouldRetry(error) &&
              error.requestOptions.extra['retryCount'] != null) {
            final retryCount = error.requestOptions.extra['retryCount'] as int;
            if (retryCount < _config.maxRetries) {
              TtsLogger.info('Retry TTS request', {
                'attempt': retryCount + 1,
                'maxRetries': _config.maxRetries,
                'error': error.message,
              });

              // Exponential backoff: 100ms, 200ms, 400ms...
              final delay = Duration(milliseconds: 100 * (1 << retryCount));
              await Future.delayed(delay);

              // Clone et retry
              final opts = Options(
                method: error.requestOptions.method,
                headers: error.requestOptions.headers,
                extra: {'retryCount': retryCount + 1},
              );

              try {
                final response = await _dio.request(
                  error.requestOptions.path,
                  data: error.requestOptions.data,
                  options: opts,
                );
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  bool _shouldRetry(DioException error) {
    // Retry sur erreurs réseau et timeouts
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.response?.statusCode ?? 0) >= 500;
  }

  void _setupAudioPlayer() {
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      _positionController.add(position);
    });

    _audioPlayer.playbackEventStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        _positionController.add(Duration.zero);
      }
    });
  }

  @override
  Future<void> playText(
    String text, {
    required String voice,
    double speed = 0.55,
    double pitch = 1.0,
    bool allowFallback = false, // Paramètre ignoré dans CoquiTtsService
  }) async {
    final timer = TtsPerformanceTimer('playText', {
      'provider': 'coqui',
      'voice': voice,
      'textLength': text.length,
    });

    try {
      // Arrêter lecture en cours
      await stop();

      // Vérifier circuit breaker
      if (_consecutiveFailures >= _maxConsecutiveFailures) {
        TtsLogger.warning('Circuit breaker ouvert', {
          'failures': _consecutiveFailures,
          'max': _maxConsecutiveFailures,
        });
        throw Exception('Service TTS temporairement indisponible');
      }

      // Déterminer langue et type de voix
      final language = _detectLanguage(text, voice);
      final voiceType = _getVoiceType(voice);

      TtsLogger.info('Synthèse TTS Coqui', {
        'language': language,
        'voiceType': voiceType,
        'speed': speed,
        'pitch': pitch,
        'textPreview': text.length > 50 ? '${text.substring(0, 50)}...' : text,
      });

      // Générer clé de cache
      final cacheKey = await _cache.generateKey(
        provider: 'coqui',
        text: text,
        voice: '$language-$voiceType',
        speed: speed,
        pitch: pitch,
      );

      // Vérifier cache
      String? audioPath = await _cache.getPath(cacheKey);

      if (audioPath == null || !File(audioPath).existsSync()) {
        TtsLogger.info('Cache miss, synthèse requise', {'cacheKey': cacheKey});

        // Synthétiser avec Coqui
        audioPath = await _synthesizeWithCoqui(
          text: text,
          language: language,
          voiceType: voiceType,
          speed: speed,
          pitch: pitch,
          cacheKey: cacheKey,
        );

        if (audioPath == null) {
          throw Exception('Échec de synthèse Coqui');
        }

        // Sauvegarder dans cache sécurisé
        await _cache.store(
          key: cacheKey,
          filePath: audioPath,
          metadata: {
            'provider': 'coqui',
            'language': language,
            'voiceType': voiceType,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      } else {
        TtsLogger.info('Cache hit', {'cacheKey': cacheKey});
        TtsLogger.metric('tts.cache.hit', 1, {'provider': 'coqui'});
      }

      // Vérifier que le fichier audio existe et est complet
      if (!kIsWeb) {
        final audioFile = File(audioPath);
        if (!audioFile.existsSync()) {
          throw Exception('Fichier audio introuvable: $audioPath');
        }

        final fileSize = await audioFile.length();
        TtsLogger.info('Fichier audio prêt', {
          'path': audioPath,
          'sizeBytes': fileSize,
          'sizeKB': (fileSize / 1024).toStringAsFixed(2),
        });

        // Charger le fichier audio
        await _audioPlayer.setFilePath(audioPath);
      } else {
        // Sur le web, utiliser l'URL
        await _audioPlayer.setUrl(audioPath);
      }

      // Attendre que l'audio soit complètement chargé
      await _audioPlayer.load();

      // Vérifier la durée de l'audio pour s'assurer qu'il est complet
      final duration = _audioPlayer.duration;
      if (duration != null) {
        TtsLogger.info('Audio chargé et prêt', {
          'durationSeconds': duration.inSeconds,
          'durationMs': duration.inMilliseconds,
        });

        // Si la durée est trop courte par rapport au texte, c'est suspect
        final wordsCount = text.split(' ').length;
        final expectedMinDuration =
            (wordsCount * 0.3).ceil(); // 0.3 secondes par mot minimum

        if (duration.inSeconds < expectedMinDuration) {
          TtsLogger.warning('Audio peut-être incomplet', {
            'wordsCount': wordsCount,
            'actualDuration': duration.inSeconds,
            'expectedMinDuration': expectedMinDuration,
          });
        }
      } else {
        TtsLogger.warning('Impossible de déterminer la durée de l\'audio');
      }

      // Jouer l'audio
      await _audioPlayer.play();

      // Reset compteur échecs sur succès
      _consecutiveFailures = 0;

      TtsLogger.metric('tts.synthesis.success', 1, {
        'provider': 'coqui',
        'language': language,
      });
    } catch (e) {
      _consecutiveFailures++;
      TtsLogger.error(
          'Erreur TTS Coqui',
          {
            'consecutiveFailures': _consecutiveFailures,
          },
          e);

      TtsLogger.metric('tts.synthesis.error', 1, {
        'provider': 'coqui',
        'errorType': e.runtimeType.toString(),
      });

      rethrow;
    } finally {
      timer.stop();
    }
  }

  Future<String?> _synthesizeWithCoqui({
    required String text,
    required String language,
    required String voiceType,
    required double speed,
    required double pitch,
    required String cacheKey,
  }) async {
    final synthesisTimer = TtsPerformanceTimer('synthesis', {
      'provider': 'coqui',
      'language': language,
    });

    try {
      // Convertir vitesse en format API
      final rate = _speedToRate(speed);

      // Calculer un timeout dynamique basé sur la longueur du texte
      // Estimation généreuse: 20 caractères/seconde + 40 secondes de marge
      // Pour les textes très longs, permettre jusqu'à 10 minutes
      final estimatedTimeSeconds = (text.length / 20).ceil() + 40;
      final dynamicTimeout = Duration(
          seconds: estimatedTimeSeconds.clamp(45, 600)); // Jusqu'à 10 minutes

      TtsLogger.info('Synthèse Coqui avec timeout dynamique', {
        'textLength': text.length,
        'estimatedTime': estimatedTimeSeconds,
        'timeoutSeconds': dynamicTimeout.inSeconds,
        'estimatedMinutes': (dynamicTimeout.inSeconds / 60).toStringAsFixed(1),
      });

      // Avertissement pour les textes très longs
      if (text.length > 1500) {
        TtsLogger.warning('⚠️ Texte très long, découpage recommandé', {
          'caracteres': text.length,
          'tempsMaximal':
              '${(dynamicTimeout.inSeconds / 60).toStringAsFixed(1)} minutes',
          'recommendation': 'Considérer le découpage en segments plus courts',
        });
      }

      // Préparer requête
      final requestBody = {
        'text': text,
        'language': language,
        'voice_type': voiceType,
        'rate': rate,
      };

      TtsLogger.debug('Requête Coqui', {
        'endpoint': '${_config.coquiEndpoint}/api/tts',
        'language': language,
        'voiceType': voiceType,
        'rate': rate,
      });

      // Appel API avec timeout dynamique et retry automatique
      final response = await _dio.post(
        '${_config.coquiEndpoint}/api/tts',
        queryParameters: {'b64': 1},
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-API-Key': _config.coquiApiKey,
          },
          receiveTimeout: dynamicTimeout,
          sendTimeout: Duration(seconds: 10),
          extra: {'retryCount': 0},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final audioBase64 = response.data['audio'] as String?;

        if (audioBase64 == null || audioBase64.isEmpty) {
          throw Exception('Audio vide reçu de Coqui');
        }

        // Décoder base64
        final audioBytes = base64Decode(audioBase64);

        TtsLogger.metric('tts.audio.size', audioBytes.length, {
          'provider': 'coqui',
          'unit': 'bytes',
        });

        // Sauvegarder temporairement
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$cacheKey.mp3');
        await tempFile.writeAsBytes(audioBytes);

        return tempFile.path;
      } else {
        throw Exception('Réponse invalide de Coqui: ${response.statusCode}');
      }
    } catch (e) {
      TtsLogger.error(
          'Échec synthèse Coqui',
          {
            'language': language,
            'voiceType': voiceType,
          },
          e);
      return null;
    } finally {
      synthesisTimer.stop();
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _positionController.add(Duration.zero);
    } catch (e) {
      TtsLogger.error('Erreur stop audio', null, e);
    }
  }

  @override
  Stream<Duration> positionStream() => _positionController.stream;

  @override
  Future<void> cacheIfNeeded(
    String text, {
    required String voice,
    double speed = 1.0,
  }) async {
    try {
      final language = _detectLanguage(text, voice);
      final voiceType = _getVoiceType(voice);
      final cacheKey = await _cache.generateKey(
        provider: 'coqui',
        text: text,
        voice: '$language-$voiceType',
        speed: speed,
        pitch: 1.0,
      );

      // Vérifier si déjà en cache
      final exists = await _cache.exists(cacheKey);
      if (!exists) {
        // Synthétiser en arrière-plan
        await _synthesizeWithCoqui(
          text: text,
          language: language,
          voiceType: voiceType,
          speed: speed,
          pitch: 1.0,
          cacheKey: cacheKey,
        );
      }
    } catch (e) {
      TtsLogger.error('Erreur pré-cache', null, e);
    }
  }

  /// Détecte la langue du texte ou utilise la voix spécifiée
  String _detectLanguage(String text, String voice) {
    // Détection simple basée sur les caractères arabes
    final arabicPattern = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]');
    final hasArabic = arabicPattern.hasMatch(text);

    if (hasArabic) {
      return 'ar';
    }

    // Utiliser la voix spécifiée
    final voiceLower = voice.toLowerCase();
    if (voiceLower.contains('ar') || voiceLower.contains('arabic')) {
      return 'ar';
    } else if (voiceLower.contains('en') || voiceLower.contains('english')) {
      return 'en';
    } else if (voiceLower.contains('es') || voiceLower.contains('spanish')) {
      return 'es';
    }

    // Par défaut français
    return 'fr';
  }

  /// Détermine le type de voix (male/female)
  String _getVoiceType(String voice) {
    final voiceLower = voice.toLowerCase();
    if (voiceLower.contains('female') || voiceLower.contains('femme')) {
      return 'female';
    }
    return 'male';
  }

  /// Convertit la vitesse en format rate pour l'API
  String _speedToRate(double speed) {
    if (speed > 1.0) {
      return '+${((speed - 1.0) * 100).toInt()}%';
    } else if (speed < 1.0) {
      return '-${((1.0 - speed) * 100).toInt()}%';
    }
    return '+0%';
  }

  void dispose() {
    _retryTimer?.cancel();
    _positionSubscription?.cancel();
    _positionController.close();
    _audioPlayer.dispose();
  }
}

/// Provider Riverpod pour CoquiTtsService
final coquiTtsServiceProvider = Provider<CoquiTtsService>((ref) {
  final configAsync = ref.watch(ttsConfigProvider);

  return configAsync.when(
    data: (config) {
      final cache = ref.watch(secureTtsCacheProvider);
      final service = CoquiTtsService(
        config: config,
        cache: cache,
      );

      ref.onDispose(() {
        service.dispose();
      });

      return service;
    },
    loading: () => throw Exception('Configuration en cours de chargement'),
    error: (error, stack) => throw Exception('Erreur configuration: $error'),
  );
});
