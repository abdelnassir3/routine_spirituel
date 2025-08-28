import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:spiritual_routines/core/services/audio_tts_service.dart';
import 'package:spiritual_routines/core/services/tts_logger_service.dart';
import 'package:spiritual_routines/core/services/quran_content_detector.dart';

/// Service pour la récitation coranique via API Quran
/// Implémente l'interface AudioTtsService pour s'intégrer avec le système TTS existant
class QuranRecitationService implements AudioTtsService {
  final Dio _dio;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();

  StreamSubscription<Duration>? _positionSubscription;

  // Configuration API Quran
  static const String _baseApiUrl = 'https://api.quran.com/api/v4';
  static const Map<String, int> _reciters = {
    'AbdulBaset': 1, // Abdul Basit Abd us-Samad
    'Mishary': 2, // Mishary Rashid Alafasy
    'Sudais': 3, // Abdul Rahman Al-Sudais (par défaut)
    'Minshawi': 4, // Mohamed Siddiq El-Minshawi
    'Husary': 5, // Mahmoud Khalil Al-Husary
  };

  // Récitateur par défaut : Abdul Rahman Al-Sudais
  static const String defaultReciter = 'Sudais';

  // Cache local pour les récitations
  static final Map<String, String> _audioCache = {};

  QuranRecitationService({Dio? dio}) : _dio = dio ?? Dio() {
    _setupDio();
    _setupAudioPlayer();
  }

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: _baseApiUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout:
          Duration(seconds: 300), // 5 minutes pour télécharger audio
      sendTimeout: Duration(seconds: 10),
      responseType: ResponseType.json,
    );
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
    double speed = 0.5, // Vitesse plus lente pour la récitation coranique
    double pitch = 1.0,
    bool allowFallback = true,
  }) async {
    final timer = TtsPerformanceTimer('quran.playText', {
      'voice': voice,
      'speed': speed,
      'textLength': text.length,
    });

    try {
      // Détecter si c'est bien du contenu coranique
      final detection = await QuranContentDetector.detectQuranContent(text);

      if (!detection.isQuranic || detection.verse == null) {
        throw Exception('Texte non coranique détecté');
      }

      final verse = detection.verse!;
      final reciter = _selectReciterFromVoice(voice);

      TtsLogger.info('🕌 Récitation coranique', {
        'surah': verse.surah,
        'ayah': verse.ayah,
        'reciter': reciter,
        'confidence': detection.confidence,
        'matchType': detection.matchType.toString(),
      });

      // Arrêter toute lecture en cours
      await stop();

      // Obtenir l'URL ou le chemin de l'audio
      final audioPath = await _getRecitationAudio(
        verse.surah,
        verse.ayah,
        reciter,
      );

      if (audioPath == null) {
        throw Exception('Impossible d\'obtenir l\'audio de récitation');
      }

      // Configurer et jouer l'audio
      if (audioPath.startsWith('http')) {
        // URL distante
        await _audioPlayer.setUrl(audioPath);
      } else {
        // Fichier local
        await _audioPlayer.setFilePath(audioPath);
      }

      // Ajuster la vitesse si supporté
      if (speed != 1.0) {
        try {
          await _audioPlayer.setSpeed(speed.clamp(0.25, 2.0));
        } catch (e) {
          TtsLogger.warning('Impossible d\'ajuster la vitesse', {
            'speed': speed,
            'error': e.toString(),
          });
        }
      }

      await _audioPlayer.play();

      TtsLogger.metric('quran.recitation.success', 1, {
        'surah': verse.surah,
        'ayah': verse.ayah,
        'reciter': reciter,
      });
    } catch (e) {
      TtsLogger.error('Erreur récitation coranique', {
        'error': e.toString(),
        'text': text.substring(0, text.length > 50 ? 50 : text.length) + '...',
      });

      TtsLogger.metric('quran.recitation.error', 1);
      rethrow;
    } finally {
      timer.stop();
    }
  }

  /// Obtient l'audio de récitation pour un verset spécifique
  Future<String?> _getRecitationAudio(
      int surah, int ayah, String reciter) async {
    try {
      // Générer une clé de cache
      final cacheKey = 'quran_${surah}_${ayah}_$reciter';

      // Vérifier le cache en mémoire
      if (_audioCache.containsKey(cacheKey)) {
        final cachedPath = _audioCache[cacheKey]!;
        if (await File(cachedPath).exists()) {
          TtsLogger.info('Cache hit pour récitation', {'cacheKey': cacheKey});
          return cachedPath;
        } else {
          _audioCache.remove(cacheKey);
        }
      }

      // Obtenir l'ID du récitateur
      final reciterId = _reciters[reciter] ?? _reciters['AbdulBaset']!;

      // Appeler l'API Quran pour obtenir l'URL audio
      final response = await _dio.get(
        '/recitations/$reciterId/by_ayah/$surah:$ayah',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final audioRecitations = data['audio_files'] as List?;

        if (audioRecitations != null && audioRecitations.isNotEmpty) {
          final audioUrlPath = audioRecitations.first['url'] as String?;

          if (audioUrlPath != null) {
            // Construire l'URL complète
            final fullAudioUrl = 'https://verses.quran.com/$audioUrlPath';

            // Télécharger et cacher localement
            final localPath =
                await _downloadAndCacheAudio(fullAudioUrl, cacheKey);
            if (localPath != null) {
              _audioCache[cacheKey] = localPath;
              return localPath;
            }

            // Si le téléchargement échoue, retourner l'URL directement
            return fullAudioUrl;
          }
        }
      }

      // Fallback : utiliser une API alternative
      return await _getFallbackRecitationUrl(surah, ayah, reciter);
    } catch (e) {
      TtsLogger.warning('Erreur obtention audio récitation', {
        'surah': surah,
        'ayah': ayah,
        'reciter': reciter,
        'error': e.toString(),
      });

      // Fallback
      return await _getFallbackRecitationUrl(surah, ayah, reciter);
    }
  }

  /// URL de fallback pour les récitations
  Future<String?> _getFallbackRecitationUrl(
      int surah, int ayah, String reciter) async {
    try {
      // Utiliser une API alternative comme everyayah.com
      final reciterCode = _getEveryAyahReciterCode(reciter);
      final surahPadded = surah.toString().padLeft(3, '0');
      final ayahPadded = ayah.toString().padLeft(3, '0');

      final fallbackUrl =
          'https://everyayah.com/data/$reciterCode/$surahPadded$ayahPadded.mp3';

      TtsLogger.info('Utilisation URL fallback', {
        'url': fallbackUrl,
        'surah': surah,
        'ayah': ayah,
        'reciter': reciter,
      });

      return fallbackUrl;
    } catch (e) {
      TtsLogger.error('Échec fallback récitation', {'error': e.toString()});
      return null;
    }
  }

  /// Télécharge et cache l'audio localement
  Future<String?> _downloadAndCacheAudio(
      String audioUrl, String cacheKey) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final audioFile = File('${tempDir.path}/quran_$cacheKey.mp3');

      if (await audioFile.exists()) {
        return audioFile.path;
      }

      TtsLogger.info('Téléchargement audio récitation', {
        'url': audioUrl,
        'cacheKey': cacheKey,
      });

      final response = await _dio.download(
        audioUrl,
        audioFile.path,
        options: Options(
          receiveTimeout: Duration(minutes: 5),
        ),
      );

      if (response.statusCode == 200 && await audioFile.exists()) {
        final fileSize = await audioFile.length();
        TtsLogger.info('Audio téléchargé et caché', {
          'path': audioFile.path,
          'sizeKB': (fileSize / 1024).toStringAsFixed(2),
        });
        return audioFile.path;
      }

      return null;
    } catch (e) {
      TtsLogger.warning('Échec téléchargement audio', {
        'url': audioUrl,
        'error': e.toString(),
      });
      return null;
    }
  }

  /// Sélectionne le récitateur basé sur la voix demandée
  String _selectReciterFromVoice(String voice) {
    final voiceLower = voice.toLowerCase();

    if (voiceLower.contains('sudais')) return 'Sudais';
    if (voiceLower.contains('mishary')) return 'Mishary';
    if (voiceLower.contains('minshawi')) return 'Minshawi';
    if (voiceLower.contains('husary')) return 'Husary';

    // Par défaut : Abdul Basit
    return 'AbdulBaset';
  }

  /// Obtient le code récitateur pour everyayah.com
  String _getEveryAyahReciterCode(String reciter) {
    const codes = {
      'AbdulBaset': 'AbdulSamad_64kbps_QuranExplorer.Com',
      'Mishary': 'Alafasy_128kbps',
      'Sudais': 'Sudais_40kbps',
      'Minshawi': 'Minshawi_Murattal_128kbps',
      'Husary': 'Husary_128kbps',
    };

    return codes[reciter] ?? codes['AbdulBaset']!;
  }

  @override
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _positionController.add(Duration.zero);
      TtsLogger.info('Récitation coranique arrêtée');
    } catch (e) {
      TtsLogger.error('Erreur stop récitation', {'error': e.toString()});
    }
  }

  @override
  Stream<Duration> positionStream() => _positionController.stream;

  @override
  Future<void> cacheIfNeeded(
    String text, {
    required String voice,
    double speed = 0.5,
  }) async {
    try {
      // Détecter si c'est du contenu coranique
      final detection = await QuranContentDetector.detectQuranContent(text);

      if (!detection.isQuranic || detection.verse == null) {
        return; // Ne pas cacher si ce n'est pas du Coran
      }

      final verse = detection.verse!;
      final reciter = _selectReciterFromVoice(voice);

      // Pré-charger en arrière-plan
      await _getRecitationAudio(verse.surah, verse.ayah, reciter);

      TtsLogger.info('Pré-cache récitation réussi', {
        'surah': verse.surah,
        'ayah': verse.ayah,
        'reciter': reciter,
      });
    } catch (e) {
      TtsLogger.debug('Échec pré-cache récitation', {'error': e.toString()});
    }
  }

  void dispose() {
    _positionSubscription?.cancel();
    _audioPlayer.dispose();
    _positionController.close();
  }
}

/// Provider Riverpod pour QuranRecitationService
final quranRecitationServiceProvider = Provider<QuranRecitationService>((ref) {
  final service = QuranRecitationService();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
