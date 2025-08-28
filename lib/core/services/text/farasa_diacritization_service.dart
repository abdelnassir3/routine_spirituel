import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';

/// Service de diacritisation arabe utilisant Farasa API
/// Ajoute automatiquement les harakat (marques de voyelles) au texte arabe
class FarasaDiacritizationService {
  static final Dio _dio = Dio();
  static const String _cachePrefix = 'farasa_diac_';

  // Configuration API Farasa
  static const String farasaApiUrl = 'https://farasa-api.qcri.org/diacritize';
  static const String farasaBackupUrl =
      'https://qcri.org/farasa/api/diacritize';

  // Cache local simple (en mémoire)
  static final Map<String, String> _memoryCache = {};
  static const int maxCacheSize = 1000;

  /// Diacritise le texte arabe en ajoutant les harakat
  static Future<String> diacritizeText(String text) async {
    try {
      // 1. Nettoyer et valider le texte
      final cleanText = _cleanArabicText(text);
      if (cleanText.isEmpty || !_containsArabic(cleanText)) {
        debugPrint('📝 Farasa: Texte non-arabe, retour original');
        return text;
      }

      // 2. Vérifier le cache
      final cacheKey = _generateCacheKey(cleanText);
      if (_memoryCache.containsKey(cacheKey)) {
        debugPrint('✅ Farasa: Trouvé en cache');
        return _memoryCache[cacheKey]!;
      }

      debugPrint('🔤 Farasa: Diacritisation de ${cleanText.length} caractères');

      // 3. Appeler l'API Farasa
      String? diacritizedText = await _callFarasaApi(cleanText);

      // 4. Fallback vers API de secours si échec
      if (diacritizedText == null) {
        debugPrint('⚠️ API principale échouée, essai API de secours...');
        diacritizedText = await _callFarasaBackup(cleanText);
      }

      // 5. Si succès, mettre en cache et retourner
      if (diacritizedText != null && diacritizedText.isNotEmpty) {
        _addToCache(cacheKey, diacritizedText);
        debugPrint('✅ Farasa: Diacritisation réussie');
        return _restoreOriginalFormat(text, cleanText, diacritizedText);
      }

      // 6. En cas d'échec total, retourner le texte original
      debugPrint('❌ Farasa: Échec diacritisation, retour texte original');
      return text;
    } catch (e) {
      debugPrint('❌ Erreur Farasa: $e');
      return text; // Fallback vers texte original
    }
  }

  /// Appelle l'API Farasa principale
  static Future<String?> _callFarasaApi(String text) async {
    try {
      final response = await _dio.post(
        farasaApiUrl,
        data: {'text': text, 'lang': 'ar', 'format': 'json'},
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'ProjetSpirit/1.0.0 (Flutter Mobile App)',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('diacritized_text')) {
          return data['diacritized_text'] as String;
        } else if (data is String) {
          return data;
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Erreur API Farasa principale: $e');
      return null;
    }
  }

  /// API de secours (format différent)
  static Future<String?> _callFarasaBackup(String text) async {
    try {
      final response = await _dio.post(
        farasaBackupUrl,
        data: {'text': text},
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        return response.data.toString();
      }

      return null;
    } catch (e) {
      debugPrint('❌ Erreur API Farasa secours: $e');
      return null;
    }
  }

  /// Nettoie le texte arabe pour l'API
  static String _cleanArabicText(String text) {
    // Supprimer les marqueurs de versets et caractères non-arabes
    return text
        .replaceAll(RegExp(r'\{\{V:\d+:\d+\}\}'), '') // Marqueurs versets
        .replaceAll(RegExp(r'[^\u0600-\u06FF\u0750-\u077F\s]'),
            '') // Garder seulement arabe
        .replaceAll(RegExp(r'\s+'), ' ') // Normaliser espaces
        .trim();
  }

  /// Vérifie si le texte contient de l'arabe
  static bool _containsArabic(String text) {
    return RegExp(r'[\u0600-\u06FF\u0750-\u077F]').hasMatch(text);
  }

  /// Restaure le format original en préservant les marqueurs
  static String _restoreOriginalFormat(
      String originalText, String cleanText, String diacritizedText) {
    // Si le texte original avait des marqueurs de versets, les préserver
    if (originalText.contains('{{V:')) {
      final verseMarkers =
          RegExp(r'\{\{V:\d+:\d+\}\}').allMatches(originalText);
      String result = diacritizedText;

      // Réinsérer les marqueurs à leurs positions approximatives
      for (final match in verseMarkers) {
        result = '${match.group(0)} $result';
      }

      return result.trim();
    }

    return diacritizedText;
  }

  /// Génère une clé de cache
  static String _generateCacheKey(String text) {
    final bytes = utf8.encode(text);
    final digest = md5.convert(bytes);
    return '$_cachePrefix${digest.toString()}';
  }

  /// Ajoute au cache avec limite de taille
  static void _addToCache(String key, String value) {
    // Nettoyer le cache si trop grand
    if (_memoryCache.length >= maxCacheSize) {
      final keysToRemove = _memoryCache.keys
          .take(_memoryCache.length - maxCacheSize + 100)
          .toList();
      for (final keyToRemove in keysToRemove) {
        _memoryCache.remove(keyToRemove);
      }
    }

    _memoryCache[key] = value;
    debugPrint(
        '💾 Farasa: Mis en cache (${_memoryCache.length}/$maxCacheSize)');
  }

  /// Diacritise plusieurs segments de texte en parallèle
  static Future<List<String>> diacritizeMultipleTexts(
      List<String> texts) async {
    final futures = texts.map((text) => diacritizeText(text));
    return await Future.wait(futures);
  }

  /// Diacritise seulement si le texte n'a pas déjà de harakat
  static Future<String> diacritizeIfNeeded(String text) async {
    if (_alreadyDiacritized(text)) {
      debugPrint('✅ Farasa: Texte déjà diacritisé');
      return text;
    }
    return await diacritizeText(text);
  }

  /// Vérifie si le texte contient déjà des harakat
  static bool _alreadyDiacritized(String text) {
    // Chercher les signes diacritiques arabes courants
    final diacriticsRegex = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');
    final arabicChars =
        text.replaceAll(RegExp(r'[^\u0600-\u06FF\u0750-\u077F]'), '');

    if (arabicChars.isEmpty) return true;

    final diacriticsCount = diacriticsRegex.allMatches(text).length;
    final arabicCharCount = arabicChars.length;

    // Si plus de 10% des caractères arabes ont des diacritiques, considérer comme diacritisé
    return (diacriticsCount / arabicCharCount) > 0.1;
  }

  /// Statistiques du cache
  static Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _memoryCache.length,
      'maxCacheSize': maxCacheSize,
      'usagePercent': ((_memoryCache.length / maxCacheSize) * 100).round(),
    };
  }

  /// Nettoie le cache
  static void clearCache() {
    _memoryCache.clear();
    debugPrint('🧹 Farasa: Cache nettoyé');
  }

  /// Test de l'API Farasa
  static Future<bool> testFarasaConnection() async {
    try {
      debugPrint('🧪 Test connexion Farasa...');
      final testText = 'السلام عليكم';
      final result = await diacritizeText(testText);

      final isWorking = result != testText && _containsArabic(result);
      debugPrint(
          isWorking ? '✅ Farasa fonctionne' : '❌ Farasa ne fonctionne pas');

      return isWorking;
    } catch (e) {
      debugPrint('❌ Test Farasa échoué: $e');
      return false;
    }
  }
}
