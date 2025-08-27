import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'content_detector_service.dart';
import 'audio_api_config.dart';

/// Service pour récupérer l'audio coranique depuis différentes APIs
class QuranicAudioService {
  static final Dio _dio = Dio();
  static const String _cacheFolder = 'quranic_audio_cache';
  
  /// Récupère l'audio pour un verset depuis les APIs coraniques
  static Future<Uint8List?> getVerseAudio(
    VerseReference verse, {
    QuranicAudioProvider provider = QuranicAudioProvider.alQuran,
    String reciter = 'ar.sudais', // Abdul Rahman Al-Sudais par défaut
  }) async {
    try {
      // 1. Vérifier le cache local
      final cachedAudio = await _getCachedAudio(verse, provider, reciter);
      if (cachedAudio != null) {
        debugPrint('✅ Audio coranique trouvé en cache: $verse');
        return cachedAudio;
      }
      
      // 2. Télécharger depuis l'API
      final audioUrl = _buildAudioUrl(verse, provider, reciter);
      debugPrint('🌐 Téléchargement audio coranique: $audioUrl');
      
      final response = await _dio.get(
        audioUrl,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: AudioApiConfig.defaultTimeout,
          headers: AudioApiConfig.defaultHeaders,
        ),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final audioBytes = Uint8List.fromList(response.data);
        
        // 3. Sauvegarder en cache
        await _cacheAudio(verse, provider, reciter, audioBytes);
        
        debugPrint('✅ Audio coranique téléchargé: ${audioBytes.length} bytes');
        return audioBytes;
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Erreur téléchargement audio coranique: $e');
      return null;
    }
  }
  
  /// Récupère l'audio pour plusieurs versets (sourate complète)
  static Future<List<Uint8List>> getSurahAudio(
    int surahNumber, {
    QuranicAudioProvider provider = QuranicAudioProvider.everyayah,
    String reciter = 'Alafasy_128kbps',
  }) async {
    // Logique pour récupérer une sourate complète
    // Placeholder - à implémenter selon les besoins
    return [];
  }
  
  /// Construit l'URL API selon le fournisseur
  static String _buildAudioUrl(
    VerseReference verse,
    QuranicAudioProvider provider,
    String reciter,
  ) {
    switch (provider) {
      case QuranicAudioProvider.alQuran:
        // AlQuran.cloud API - format: https://cdn.alquran.cloud/media/audio/ayah/ar.alafasy/1
        final ayahNumber = _calculateGlobalAyahNumber(verse.surah, verse.verse);
        return '${AudioApiConfig.alQuranBaseUrl}/$reciter/$ayahNumber';
        
      case QuranicAudioProvider.everyayah:
        // Everyayah.com API - format: https://everyayah.com/data/reciter/surah/verse.mp3
        final surahPadded = verse.surah.toString().padLeft(3, '0');
        final versePadded = verse.verse.toString().padLeft(3, '0');
        return '${AudioApiConfig.everyayahBaseUrl}/$reciter/$surahPadded$versePadded.mp3';
        
      case QuranicAudioProvider.quranCom:
        // Quran.com API - format: https://verses.quran.com/reciter/surah_verse.mp3
        return '${AudioApiConfig.quranComBaseUrl}/$reciter/${verse.surah}_${verse.verse}.mp3';
    }
  }
  
  /// Calcule le numéro global d'ayah (1-6236)
  static int _calculateGlobalAyahNumber(int surah, int verse) {
    // Table des versets par sourate (simplified - à compléter)
    const verseCounts = [7, 286, 200, 176, 120, 165, 206, 75, 129, 109]; // etc...
    
    int globalNumber = 0;
    for (int i = 1; i < surah; i++) {
      globalNumber += verseCounts[i - 1];
    }
    globalNumber += verse;
    
    return globalNumber;
  }
  
  /// Vérifie le cache local
  static Future<Uint8List?> _getCachedAudio(
    VerseReference verse,
    QuranicAudioProvider provider,
    String reciter,
  ) async {
    try {
      final cacheFile = await _getCacheFile(verse, provider, reciter);
      if (await cacheFile.exists()) {
        return await cacheFile.readAsBytes();
      }
    } catch (e) {
      debugPrint('⚠️ Erreur lecture cache: $e');
    }
    return null;
  }
  
  /// Sauvegarde l'audio en cache
  static Future<void> _cacheAudio(
    VerseReference verse,
    QuranicAudioProvider provider,
    String reciter,
    Uint8List audioBytes,
  ) async {
    try {
      final cacheFile = await _getCacheFile(verse, provider, reciter);
      await cacheFile.parent.create(recursive: true);
      await cacheFile.writeAsBytes(audioBytes);
    } catch (e) {
      debugPrint('⚠️ Erreur sauvegarde cache: $e');
    }
  }
  
  /// Obtient le fichier cache pour un verset
  static Future<File> _getCacheFile(
    VerseReference verse,
    QuranicAudioProvider provider,
    String reciter,
  ) async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/$_cacheFolder');
    
    final filename = '${provider.name}_${reciter}_${verse.surah}_${verse.verse}.mp3';
    return File('${cacheDir.path}/$filename');
  }
  
  /// Nettoie le cache ancien (> 30 jours)
  static Future<void> cleanOldCache() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/$_cacheFolder');
      
      if (await cacheDir.exists()) {
        final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
        
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
      debugPrint('⚠️ Erreur nettoyage cache: $e');
    }
  }
}

/// Fournisseurs d'audio coranique
enum QuranicAudioProvider {
  alQuran('AlQuran.cloud'),
  everyayah('Everyayah.com'),
  quranCom('Quran.com');
  
  const QuranicAudioProvider(this.displayName);
  final String displayName;
}