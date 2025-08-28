import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'audio_api_config.dart';

/// Service Edge-TTS pour synthèse vocale haute qualité
class EdgeTtsService {
  static final Dio _dio = Dio();
  static const String _cacheFolder = 'edge_tts_cache';

  /// Synthétise l'audio à partir du texte avec Edge-TTS
  static Future<Uint8List?> synthesizeText(
    String text, {
    String language = 'fr-FR',
    EdgeTtsVoice? voice,
    double rate = 1.0,
    double pitch = 1.0,
  }) async {
    try {
      // 1. Sélectionner la voix appropriée
      final selectedVoice = voice ?? _getDefaultVoice(language);

      // 2. Vérifier le cache
      final cacheKey = _generateCacheKey(text, selectedVoice, rate, pitch);
      final cachedAudio = await _getCachedAudio(cacheKey);
      if (cachedAudio != null) {
        debugPrint('✅ Audio Edge-TTS trouvé en cache');
        return cachedAudio;
      }

      // 3. Appeler l'API Edge-TTS
      final audioBytes =
          await _callEdgeTtsApi(text, selectedVoice, rate, pitch);

      if (audioBytes != null) {
        // 4. Sauvegarder en cache
        await _cacheAudio(cacheKey, audioBytes);
        debugPrint('✅ Audio Edge-TTS généré: ${audioBytes.length} bytes');
        return audioBytes;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Erreur Edge-TTS: $e');
      return null;
    }
  }

  /// Appelle l'API Edge-TTS (via serveur proxy ou bibliothèque locale)
  static Future<Uint8List?> _callEdgeTtsApi(
    String text,
    EdgeTtsVoice voice,
    double rate,
    double pitch,
  ) async {
    try {
      // Option 1: Via serveur proxy (recommandé)
      if (kIsWeb || Platform.isIOS) {
        return await _callEdgeTtsProxy(text, voice, rate, pitch);
      }

      // Option 2: Via package edge_tts (Android/Desktop)
      return await _callEdgeTtsNative(text, voice, rate, pitch);
    } catch (e) {
      debugPrint('❌ Erreur appel Edge-TTS API: $e');
      return null;
    }
  }

  /// Appel via serveur proxy Edge-TTS
  static Future<Uint8List?> _callEdgeTtsProxy(
    String text,
    EdgeTtsVoice voice,
    double rate,
    double pitch,
  ) async {
    // Vérifier la configuration avant l'appel
    if (!AudioApiConfig.isConfigurationValid) {
      debugPrint('❌ Configuration Edge-TTS invalide');
      return null;
    }

    debugPrint(
        '🌐 Appel Edge-TTS VPS: ${AudioApiConfig.edgeTtsSynthesizeEndpoint}');
    debugPrint('🎙️ Voix: ${voice.name} (${voice.fullName})');
    debugPrint('📝 Texte: ${text.length} caractères');

    try {
      final requestData = {
        'text': text,
        'voice': voice.shortName, // Use shortName instead of name for API
      };

      // Ajouter rate seulement si différent de 1.0
      if (rate != 1.0) {
        final ratePercent = (rate * 100).round().clamp(50, 150);
        final rateAdjustment = ratePercent - 100;
        requestData['rate'] =
            '${rateAdjustment >= 0 ? '+' : ''}${rateAdjustment}%';
      }

      // Ajouter pitch seulement si différent de 1.0
      if (pitch != 1.0) {
        final pitchPercent = (pitch * 100).round().clamp(50, 150);
        final pitchAdjustment = pitchPercent - 100;
        requestData['pitch'] =
            '${pitchAdjustment >= 0 ? '+' : ''}${pitchAdjustment}%';
      }

      debugPrint('📝 Requête: $requestData');

      final response = await _dio
          .post(
            AudioApiConfig.edgeTtsSynthesizeEndpoint,
            data: requestData,
            options: Options(
              responseType: ResponseType.json, // Changed from bytes to json
              headers: {
                ...AudioApiConfig.edgeTtsHeaders,
                'Content-Type':
                    'application/json; charset=utf-8', // Explicit UTF-8
              },
            ),
          )
          .timeout(AudioApiConfig.edgeTtsTimeout);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Vérifier si la réponse contient le succès
        if (responseData['success'] == true &&
            responseData.containsKey('audio')) {
          try {
            // Décoder l'audio base64
            final audioBase64 = responseData['audio'] as String;
            final audioBytes = base64Decode(audioBase64);

            debugPrint('✅ Edge-TTS réussi: ${audioBytes.length} bytes');
            debugPrint('🔊 Format: ${responseData['format'] ?? 'unknown'}');
            debugPrint(
                '🎙️ Voix utilisée: ${responseData['voice'] ?? 'unknown'}');

            return Uint8List.fromList(audioBytes);
          } catch (e) {
            debugPrint('❌ Erreur décodage base64: $e');
            return null;
          }
        } else {
          debugPrint(
              '❌ Edge-TTS erreur réponse: ${responseData['error'] ?? 'Unknown error'}');
          return null;
        }
      } else {
        debugPrint('❌ Edge-TTS erreur HTTP: ${response.statusCode}');
        if (response.data != null) {
          debugPrint('🛠️ Erreur détail: ${response.data}');
        }
        return null;
      }
    } catch (e) {
      debugPrint('❌ Exception Edge-TTS VPS: $e');
      return null;
    }
  }

  /// Appel natif Edge-TTS (à implémenter avec package approprié)
  static Future<Uint8List?> _callEdgeTtsNative(
    String text,
    EdgeTtsVoice voice,
    double rate,
    double pitch,
  ) async {
    // TODO: Implémenter avec package edge_tts ou équivalent
    // Exemple de structure :
    /*
    final edgeTts = EdgeTTS();
    await edgeTts.setVoice(voice.name);
    await edgeTts.setRate(rate);
    await edgeTts.setPitch(pitch);
    return await edgeTts.synthesize(text);
    */
    return null;
  }

  /// Obtient la voix par défaut selon la langue
  static EdgeTtsVoice _getDefaultVoice(String language) {
    switch (language.toLowerCase()) {
      case 'fr':
      case 'fr-fr':
        return EdgeTtsVoice.frenchDenise;
      case 'ar':
      case 'ar-sa':
        return EdgeTtsVoice.arabicHamed;
      case 'en':
      case 'en-us':
        return EdgeTtsVoice.englishAria;
      default:
        return EdgeTtsVoice.frenchDenise;
    }
  }

  /// Génère une clé de cache unique
  static String _generateCacheKey(
    String text,
    EdgeTtsVoice voice,
    double rate,
    double pitch,
  ) {
    final content = '$text|${voice.name}|$rate|$pitch';
    return content.hashCode.toString();
  }

  /// Cache et récupération
  static Future<Uint8List?> _getCachedAudio(String cacheKey) async {
    try {
      final cacheFile = await _getCacheFile(cacheKey);
      if (await cacheFile.exists()) {
        return await cacheFile.readAsBytes();
      }
    } catch (e) {
      debugPrint('⚠️ Erreur lecture cache Edge-TTS: $e');
    }
    return null;
  }

  static Future<void> _cacheAudio(String cacheKey, Uint8List audioBytes) async {
    try {
      final cacheFile = await _getCacheFile(cacheKey);
      await cacheFile.parent.create(recursive: true);
      await cacheFile.writeAsBytes(audioBytes);
    } catch (e) {
      debugPrint('⚠️ Erreur cache Edge-TTS: $e');
    }
  }

  static Future<File> _getCacheFile(String cacheKey) async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/$_cacheFolder');
    return File('${cacheDir.path}/$cacheKey.mp3');
  }

  /// Nettoie le cache ancien
  static Future<void> cleanOldCache() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/$_cacheFolder');

      if (await cacheDir.exists()) {
        final cutoffDate = DateTime.now().subtract(const Duration(days: 7));

        await for (final file in cacheDir.list()) {
          if (file is File) {
            final stat = await file.stat();
            if (stat.modified.isBefore(cutoffDate)) {
              await file.delete();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Erreur nettoyage cache Edge-TTS: $e');
    }
  }
}

/// Voix Edge-TTS disponibles (utilise les ShortNames de l'API)
enum EdgeTtsVoice {
  // Français
  frenchDenise('fr-FR-DeniseNeural'),
  frenchHenri('fr-FR-HenriNeural'),

  // Arabe
  arabicHamed('ar-SA-HamedNeural'),
  arabicZariyah('ar-SA-ZariyahNeural'),

  // Anglais
  englishAria('en-US-AriaNeural'),
  englishGuy('en-US-GuyNeural');

  const EdgeTtsVoice(this.name);
  final String name;

  /// Obtient le nom court pour l'API
  String get shortName => name;

  /// Obtient le nom complet de la voix
  String get fullName {
    switch (this) {
      case EdgeTtsVoice.frenchDenise:
        return 'Microsoft Server Speech Text to Speech Voice (fr-FR, DeniseNeural)';
      case EdgeTtsVoice.frenchHenri:
        return 'Microsoft Server Speech Text to Speech Voice (fr-FR, HenriNeural)';
      case EdgeTtsVoice.arabicHamed:
        return 'Microsoft Server Speech Text to Speech Voice (ar-SA, HamedNeural)';
      case EdgeTtsVoice.arabicZariyah:
        return 'Microsoft Server Speech Text to Speech Voice (ar-SA, ZariyahNeural)';
      case EdgeTtsVoice.englishAria:
        return 'Microsoft Server Speech Text to Speech Voice (en-US, AriaNeural)';
      case EdgeTtsVoice.englishGuy:
        return 'Microsoft Server Speech Text to Speech Voice (en-US, GuyNeural)';
    }
  }
}
