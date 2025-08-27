import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_tts_service.dart';
import 'audio_tts_flutter.dart';
import 'edge_tts_adapter_service.dart';
import 'secure_tts_cache_service.dart';
import 'tts_config_service.dart';
import 'tts_logger_service.dart';
import 'audio/audio_api_config.dart';
import 'hybrid_audio_service.dart';

/// Service TTS intelligent avec fallback et queue
/// Orchestration: Edge-TTS (principal) → flutter_tts (fallback)
class SmartTtsService implements AudioTtsService {
  final EdgeTtsAdapterService? _edgeTtsService;
  final FlutterTtsAudioService _flutterTtsService;
  final TtsConfigService _config;

  // Compteur pour détecter les appels multiples
  static int _playCallCount = 0;

  // Queue pour synthèse différée
  final Queue<_TtsRequest> _backgroundQueue = Queue();
  Timer? _queueTimer;
  bool _isProcessingQueue = false;

  // Métriques
  int _edgeTtsSuccessCount = 0;
  int _edgeTtsFallbackCount = 0;
  int _totalRequests = 0;

  // État du circuit breaker
  bool _edgeTtsAvailable = true;
  DateTime? _edgeTtsLastFailure;
  static const _circuitBreakerTimeout = Duration(minutes: 5);

  SmartTtsService({
    EdgeTtsAdapterService? edgeTtsService,
    required FlutterTtsAudioService flutterTtsService,
    required TtsConfigService config,
  })  : _edgeTtsService = edgeTtsService,
        _flutterTtsService = flutterTtsService,
        _config = config {
    _startQueueProcessor();
  }

  @override
  Future<void> playText(
    String text, {
    required String voice,
    double speed = 0.9, // Vitesse normale par défaut
    double pitch = 1.0,
    bool allowFallback = false, // Permettre le fallback automatique
  }) async {
    _totalRequests++;
    _playCallCount++;
    
    // Nettoyer le texte en supprimant les marqueurs de versets
    final cleanedText = _cleanVerseMarkers(text);
    
    TtsLogger.info('🔢 PlayText appelé', {
      'callCount': _playCallCount,
      'text': cleanedText.substring(0, cleanedText.length > 50 ? 50 : cleanedText.length) + '...',
    });

    final timer = TtsPerformanceTimer('smart.playText', {
      'preferredProvider': _config.preferredProvider,
      'edge-ttsAvailable': _edgeTtsAvailable,
    });

    try {
      // Vérifier d'abord si l'API key est présente et valide
      final hasValidApiKey =
          _config.coquiApiKey.isNotEmpty && _config.coquiApiKey.length >= 32;

      // Respecter le choix de l'utilisateur pour le provider
      final bool useEdgeTts = _config.preferredProvider == 'coqui' &&
          _edgeTtsService != null &&
          hasValidApiKey;

      TtsLogger.info('🎯 Décision provider TTS', {
        'preferredProvider': _config.preferredProvider,
        'edgeTtsServiceAvailable': _edgeTtsService != null,
        'apiKeyPresent': AudioApiConfig.edgeTtsApiKey.isNotEmpty,
        'apiKeyValid': hasValidApiKey,
        'apiKeyLength': AudioApiConfig.edgeTtsApiKey.length,
        'useEdgeTts': useEdgeTts,
        'endpoint': AudioApiConfig.edgeTtsBaseUrl,
      });

      if (useEdgeTts) {
        // L'utilisateur a choisi Edge-TTS
        try {
          TtsLogger.info('🎯 Utilisation de Edge-TTS TTS (choix utilisateur)', {
            'voice': voice,
            'textLength': cleanedText.length,
            'apiKeyPresent': AudioApiConfig.edgeTtsApiKey.isNotEmpty,
            'endpoint': AudioApiConfig.edgeTtsBaseUrl,
          });

          // Vider le cache pour forcer la synthèse du nouveau texte
          TtsLogger.info('🧹 Préparation de la synthèse vocale', {
            'textLength': cleanedText.length,
            'textPreview':
                cleanedText.substring(0, cleanedText.length > 50 ? 50 : cleanedText.length) + '...',
          });

          // Calculer un timeout dynamique basé sur la longueur du texte
          // Estimation plus généreuse: 25 caractères/seconde + 30 secondes de marge
          // Pour les textes très longs, permettre jusqu'à 10 minutes
          final estimatedSeconds = (cleanedText.length / 25).ceil() + 30;
          final dynamicTimeout =
              Duration(seconds: estimatedSeconds.clamp(30, 600));

          TtsLogger.info('⏱️ Timeout dynamique configuré', {
            'textLength': cleanedText.length,
            'timeoutSeconds': dynamicTimeout.inSeconds,
            'estimatedMinutes':
                (dynamicTimeout.inSeconds / 60).toStringAsFixed(1),
          });

          // Avertir l'utilisateur si le texte est très long
          if (cleanedText.length > 1000) {
            TtsLogger.warning('⏳ Texte très long détecté', {
              'caracteres': cleanedText.length,
              'tempsEstime':
                  '${(dynamicTimeout.inSeconds / 60).toStringAsFixed(1)} minutes',
              'conseil': 'La synthèse peut prendre plusieurs minutes',
            });
          }

          // Pour les textes très longs, découper et jouer en segments
          if (cleanedText.length > 2000) {
            TtsLogger.info('✂️ Découpage du texte en segments', {
              'tailleTexte': cleanedText.length,
              'seuilDécoupage': 2000,
            });

            final segments = _splitLongText(cleanedText, maxLength: 1500);

            for (int i = 0; i < segments.length; i++) {
              TtsLogger.info(
                  '🎵 Lecture du segment ${i + 1}/${segments.length}', {
                'tailleSegment': segments[i].length,
              });

              // Calculer timeout pour ce segment
              final segmentTimeout = Duration(
                  seconds:
                      ((segments[i].length / 25).ceil() + 30).clamp(30, 300));

              await _playWithTimeout(
                () => _edgeTtsService!.playText(
                  segments[i],
                  voice: voice,
                  speed: speed,
                  pitch: pitch,
                ),
                timeout: segmentTimeout,
              );

              // Petite pause entre les segments
              if (i < segments.length - 1) {
                await Future.delayed(Duration(milliseconds: 500));
              }
            }
          } else {
            // Texte normal, jouer en une fois
            await _playWithTimeout(
              () => _edgeTtsService!.playText(
                cleanedText,
                voice: voice,
                speed: speed,
                pitch: pitch,
              ),
              timeout: dynamicTimeout,
            );
          }

          _edgeTtsSuccessCount++;
          _edgeTtsAvailable = true;

          TtsLogger.metric('tts.smart.edgetts.success', 1);

          // Ajouter à la queue pour pré-cache si succès
          _queueForBackground(cleanedText, voice, speed, pitch);

          return;
        } catch (e) {
          TtsLogger.error('❌ Échec Edge-TTS TTS', {
            'error': e.toString(),
            'type': e.runtimeType.toString(),
          });

          // Arrêter Edge-TTS si nécessaire
          if (_edgeTtsService != null) {
            try {
              await _edgeTtsService.stop();
              TtsLogger.info('⏹️ Audio Edge-TTS arrêté');
            } catch (_) {}
          }

          _edgeTtsLastFailure = DateTime.now();
          _edgeTtsFallbackCount++;

          TtsLogger.metric('tts.smart.edgetts.error', 1);
          
          // Détecter les erreurs de compatibilité MP3
          final isCompatibilityError = e is AudioCompatibilityException || 
              e.toString().contains('incompatible avec just_audio');

          // Fallback automatique si autorisé OU si erreur de compatibilité
          if (allowFallback || isCompatibilityError) {
            TtsLogger.warning('🔄 Fallback automatique vers flutter_tts', {
              'reason': isCompatibilityError ? 'MP3 incompatible iOS' : 'Échec Edge-TTS',
              'voice': voice,
              'isAutoFallback': isCompatibilityError,
            });
            
            // Calculer vitesse optimale pour flutter_tts
            final adjustedSpeed = _calculateOptimalFlutterSpeed(speed, voice);
            
            await _flutterTtsService.playText(
              cleanedText,
              voice: voice,
              speed: adjustedSpeed,
              pitch: pitch,
            );
            
            TtsLogger.metric('tts.smart.fallback.success', 1);
            if (isCompatibilityError) {
              TtsLogger.metric('tts.smart.fallback.compatibility', 1);
            }
            return;
          }

          // PAS de fallback automatique - l'utilisateur a choisi Edge-TTS
          throw Exception(
              'Edge-TTS non disponible. Veuillez réessayer ou changer de provider dans les paramètres.');
        }
      } else if (_config.preferredProvider == 'flutter_tts') {
        // L'utilisateur a choisi flutter_tts
        TtsLogger.info('🔊 Utilisation flutter_tts (choix utilisateur)', {
          'voice': voice,
        });

        await _flutterTtsService.playText(
          cleanedText,
          voice: voice,
          speed: speed,
          pitch: pitch,
        );
      } else {
        // Provider invalide ou non configuré
        throw Exception(
            'Provider TTS non configuré. Veuillez choisir dans les paramètres.');
      }

      TtsLogger.metric('tts.smart.flutter.success', 1);

      // Ajouter à la queue pour synthèse Edge-TTS différée
      if (_edgeTtsService != null) {
        _queueForBackground(cleanedText, voice, speed, pitch);
      }
    } catch (e) {
      TtsLogger.error(
          'Échec total TTS',
          {
            'provider': _edgeTtsAvailable ? 'coqui' : 'flutter_tts',
          },
          e);

      TtsLogger.metric('tts.smart.error', 1);
      rethrow;
    } finally {
      timer.stop();
      _logMetrics();
    }
  }

  @override
  Future<void> stop() async {
    try {
      // Arrêter les deux services
      await Future.wait([
        if (_edgeTtsService != null) _edgeTtsService.stop(),
        _flutterTtsService.stop(),
      ]);
    } catch (e) {
      TtsLogger.error('Erreur stop smart TTS', null, e);
    }
  }

  @override
  Stream<Duration> positionStream() {
    // Retourner le stream du service actif
    if (_edgeTtsService != null && _edgeTtsAvailable) {
      return _edgeTtsService.positionStream();
    }
    return _flutterTtsService.positionStream();
  }

  @override
  Future<void> cacheIfNeeded(
    String text, {
    required String voice,
    double speed = 1.0,
  }) async {
    // Essayer de pré-cacher avec Edge-TTS si disponible
    if (_edgeTtsService != null && _edgeTtsAvailable) {
      try {
        await _edgeTtsService.cacheIfNeeded(
          text,
          voice: voice,
          speed: speed,
        );
      } catch (e) {
        TtsLogger.debug('Pré-cache échoué', {'error': e.toString()});
      }
    }
  }

  /// Détermine si Edge-TTS doit être utilisé
  bool _shouldUseEdgeTts() {
    // Pas de service Edge-TTS configuré
    if (_edgeTtsService == null) return false;

    // Préférence utilisateur
    if (_config.preferredProvider != 'coqui') return false;

    // Circuit breaker fermé
    if (!_edgeTtsAvailable) {
      // Vérifier si on peut réactiver
      if (_edgeTtsLastFailure != null) {
        final elapsed = DateTime.now().difference(_edgeTtsLastFailure!);
        if (elapsed > _circuitBreakerTimeout) {
          TtsLogger.info('Réactivation Edge-TTS après timeout');
          _edgeTtsAvailable = true;
          _edgeTtsFallbackCount = 0;
        }
      }
    }

    return _edgeTtsAvailable;
  }

  /// Exécute une fonction avec timeout
  Future<T> _playWithTimeout<T>(
    Future<T> Function() operation, {
    required Duration timeout,
  }) async {
    return await operation().timeout(
      timeout,
      onTimeout: () {
        throw TimeoutException('Timeout TTS', timeout);
      },
    );
  }

  /// Découpe intelligemment un texte long en segments
  List<String> _splitLongText(String text, {int maxLength = 1500}) {
    if (text.length <= maxLength) {
      return [text];
    }

    final segments = <String>[];
    final lines = text.split('\n');
    var currentSegment = '';

    for (final line in lines) {
      // Si ajouter cette ligne dépasse la limite
      if ((currentSegment + line).length > maxLength &&
          currentSegment.isNotEmpty) {
        // Sauvegarder le segment actuel
        segments.add(currentSegment.trim());
        currentSegment = '';
      }

      // Si une seule ligne est trop longue, découper par phrases
      if (line.length > maxLength) {
        final sentences = line.split(RegExp(r'[.!?؟]'));
        for (final sentence in sentences) {
          if ((currentSegment + sentence).length > maxLength &&
              currentSegment.isNotEmpty) {
            segments.add(currentSegment.trim());
            currentSegment = sentence;
          } else {
            currentSegment += sentence + ' ';
          }
        }
      } else {
        currentSegment += line + '\n';
      }
    }

    // Ajouter le dernier segment
    if (currentSegment.isNotEmpty) {
      segments.add(currentSegment.trim());
    }

    TtsLogger.info('📝 Texte découpé en segments', {
      'texteOriginal': text.length,
      'nombreSegments': segments.length,
      'taillesSegments': segments.map((s) => s.length).toList(),
    });

    return segments;
  }

  /// Ajoute une requête à la queue de synthèse différée
  void _queueForBackground(
      String text, String voice, double speed, double pitch) {
    if (!_config.cacheEnabled) return;

    final request = _TtsRequest(
      text: text,
      voice: voice,
      speed: speed,
      pitch: pitch,
      timestamp: DateTime.now(),
    );

    _backgroundQueue.add(request);

    TtsLogger.debug('Ajout queue background', {
      'queueSize': _backgroundQueue.length,
    });
  }

  /// Démarre le processeur de queue en arrière-plan
  void _startQueueProcessor() {
    _queueTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _processBackgroundQueue();
    });
  }

  /// Traite la queue de synthèse en arrière-plan
  Future<void> _processBackgroundQueue() async {
    if (_isProcessingQueue || _backgroundQueue.isEmpty) return;
    if (_edgeTtsService == null || !_edgeTtsAvailable) return;

    _isProcessingQueue = true;

    try {
      while (_backgroundQueue.isNotEmpty) {
        final request = _backgroundQueue.removeFirst();

        // Ignorer les requêtes trop vieilles
        if (DateTime.now().difference(request.timestamp) >
            const Duration(minutes: 10)) {
          continue;
        }

        try {
          TtsLogger.debug('Traitement queue background', {
            'textLength': request.text.length,
          });

          await _edgeTtsService.cacheIfNeeded(
            request.text,
            voice: request.voice,
            speed: request.speed,
          );

          TtsLogger.metric('tts.smart.background.success', 1);

          // Pause entre les requêtes pour ne pas surcharger
          await Future.delayed(const Duration(seconds: 1));
        } catch (e) {
          TtsLogger.debug('Échec background cache', {'error': e.toString()});
          TtsLogger.metric('tts.smart.background.error', 1);
        }
      }
    } finally {
      _isProcessingQueue = false;
    }
  }

  /// Log les métriques périodiquement
  void _logMetrics() {
    if (_totalRequests % 10 == 0) {
      final successRate = _totalRequests > 0
          ? (_edgeTtsSuccessCount / _totalRequests * 100).toStringAsFixed(1)
          : '0';

      TtsLogger.info('Métriques Smart TTS', {
        'totalRequests': _totalRequests,
        'edge-ttsSuccess': _edgeTtsSuccessCount,
        'fallbackCount': _edgeTtsFallbackCount,
        'successRate': '$successRate%',
        'queueSize': _backgroundQueue.length,
        'edge-ttsAvailable': _edgeTtsAvailable,
      });
    }
  }

  /// Calcule la vitesse optimale pour flutter_tts selon la langue
  double _calculateOptimalFlutterSpeed(double baseSpeed, String voice) {
    // Détecter la langue
    final isArabic = voice.toLowerCase().contains('ar-') || 
                     voice.toLowerCase().contains('arabic');
    final isFrench = voice.toLowerCase().contains('fr-') || 
                     voice.toLowerCase().contains('french');
    
    // Vitesses optimisées par langue pour flutter_tts
    if (isArabic) {
      // L'arabe nécessite une vitesse plus lente pour être clair
      // Mapping: Edge-TTS 1.0 → flutter_tts 0.4-0.6
      return (baseSpeed * 0.5).clamp(0.3, 0.7);
    } else if (isFrench) {
      // Le français peut être plus rapide 
      // Mapping: Edge-TTS 1.0 → flutter_tts 0.6-0.8
      return (baseSpeed * 0.7).clamp(0.4, 0.8);
    } else {
      // Autres langues
      return (baseSpeed * 0.6).clamp(0.3, 0.9);
    }
  }

  void dispose() {
    _queueTimer?.cancel();
    _backgroundQueue.clear();
    _edgeTtsService?.dispose();
  }

  /// Nettoie le texte en supprimant les marqueurs de versets {{V:X}}
  String _cleanVerseMarkers(String text) {
    // Support pour les deux formats : {{V:verset}} et {{V:sourate:verset}}
    return text.replaceAll(RegExp(r'\{\{V:\d+(?::\d+)?\}\}'), '').trim();
  }
}

/// Requête TTS pour la queue
class _TtsRequest {
  final String text;
  final String voice;
  final double speed;
  final double pitch;
  final DateTime timestamp;

  _TtsRequest({
    required this.text,
    required this.voice,
    required this.speed,
    required this.pitch,
    required this.timestamp,
  });
}

/// Provider Riverpod pour SmartTtsService
final smartTtsServiceProvider = Provider<AudioTtsService>((ref) {
  final configAsync = ref.watch(ttsConfigProvider);

  return configAsync.when(
    data: (config) {
      // TOUJOURS créer Edge-TTS service si l'endpoint est configuré
      EdgeTtsAdapterService? edgeTtsService;

      // Créer EdgeTtsAdapterService - utilise la configuration existante
      // mais redirige vers Edge-TTS au lieu de Coqui
      if (config.coquiEndpoint.isNotEmpty &&
          config.coquiEndpoint != 'Non configuré') {
        try {
          final cache = ref.watch(secureTtsCacheProvider);
          edgeTtsService = EdgeTtsAdapterService(
            config: config,
            cache: cache,
          );
          TtsLogger.info('✅ EdgeTtsAdapterService créé avec succès', {
            'endpoint': AudioApiConfig.edgeTtsBaseUrl,
            'apiKeyPresent': AudioApiConfig.edgeTtsApiKey.isNotEmpty,
            'preferredProvider': config.preferredProvider,
          });
        } catch (e) {
          TtsLogger.warning('Impossible de créer EdgeTtsAdapterService', {
            'error': e.toString(),
            'endpoint': AudioApiConfig.edgeTtsBaseUrl,
          });
        }
      } else {
        TtsLogger.warning('EdgeTtsAdapterService non créé - endpoint manquant', {
          'endpoint': config.coquiEndpoint,
        });
      }

      // Flutter TTS toujours disponible comme fallback
      final flutterTts = ref.watch(flutterTtsServiceProvider);

      final smartService = SmartTtsService(
        edgeTtsService: edgeTtsService,
        flutterTtsService: flutterTts,
        config: config,
      );

      TtsLogger.info('🎯 SmartTtsService initialisé', {
        'edgeTtsServiceAvailable': edgeTtsService != null,
        'preferredProvider': config.preferredProvider,
        'endpoint': config.coquiEndpoint,
      });

      ref.onDispose(() {
        smartService.dispose();
      });

      return smartService;
    },
    loading: () {
      // Pendant le chargement, utiliser flutter_tts directement
      return ref.watch(flutterTtsServiceProvider);
    },
    error: (error, stack) {
      TtsLogger.error('Erreur configuration Smart TTS', null, error, stack);
      // En cas d'erreur, fallback sur flutter_tts
      return ref.watch(flutterTtsServiceProvider);
    },
  );
});

/// Provider principal pour l'app (remplace l'ancien)
/// IMPORTANT: Utilise maintenant le HybridAudioService pour le routage intelligent
final audioTtsServiceProvider = Provider<AudioTtsService>((ref) {
  // Importer le HybridAudioService pour le routage intelligent
  try {
    // Utiliser le service hybride qui route automatiquement entre TTS et récitation coranique
    return ref.watch(hybridAudioServiceProvider);
  } catch (e) {
    // Fallback vers SmartTTS si HybridAudioService n'est pas disponible
    TtsLogger.warning('HybridAudioService non disponible, fallback vers SmartTTS', {
      'error': e.toString(),
    });
    return ref.watch(smartTtsServiceProvider);
  }
});
