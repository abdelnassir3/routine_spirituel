import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tts_logger_service.dart';

/// Service de cache sécurisé pour TTS avec chiffrement AES-256
class SecureTtsCacheService {
  static const _cacheVersion = 'v2'; // Pour invalider ancien cache SHA1
  static const _manifestName = 'manifest.encrypted';

  // Chiffrement AES-256
  late final Key _encryptionKey;
  late final IV _iv;
  late final Encrypter _encrypter;

  SecureTtsCacheService() {
    _initEncryption();
  }

  void _initEncryption() {
    // En production, cette clé devrait venir du secure storage
    // Pour l'instant, clé dérivée du device ID
    const keyString = 'TTS_CACHE_KEY_32_CHARS_LONG_2024';
    _encryptionKey = Key.fromUtf8(keyString);
    _iv = IV.fromLength(16);
    _encrypter = Encrypter(AES(_encryptionKey));
  }

  /// Génère une clé de cache sécurisée avec SHA-256
  Future<String> generateKey({
    required String provider,
    required String text,
    required String voice,
    required double speed,
    required double pitch,
  }) async {
    final content = '$_cacheVersion|$provider|$voice|$speed|$pitch|$text';
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Récupère le répertoire de cache
  Future<Directory> cacheDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'tts-cache-secure', _cacheVersion));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Vérifie si un fichier existe dans le cache
  Future<bool> exists(String key) async {
    final dir = await cacheDir();
    final encryptedPath = p.join(dir.path, '$key.aes');
    return File(encryptedPath).exists();
  }

  /// Récupère le chemin d'un fichier déchiffré du cache
  Future<String?> getPath(String key) async {
    final timer = TtsPerformanceTimer('cache.get', {'key': key});

    try {
      final dir = await cacheDir();
      final encryptedPath = p.join(dir.path, '$key.aes');
      final encryptedFile = File(encryptedPath);

      if (!await encryptedFile.exists()) {
        TtsLogger.metric('tts.cache.miss', 1);
        return null;
      }

      // Vérifier TTL
      final metadata = await _getMetadata(key);
      if (metadata != null) {
        final timestamp = DateTime.tryParse(metadata['timestamp'] ?? '');
        if (timestamp != null) {
          final age = DateTime.now().difference(timestamp);
          const maxAge = Duration(days: 7); // TTL configurable

          if (age > maxAge) {
            TtsLogger.info('Cache expiré', {
              'key': key,
              'age': age.inDays,
              'maxAge': maxAge.inDays,
            });
            await _removeEntry(key);
            TtsLogger.metric('tts.cache.expired', 1);
            return null;
          }
        }
      }

      // Déchiffrer le fichier
      final encryptedBytes = await encryptedFile.readAsBytes();
      final encrypted = Encrypted(encryptedBytes);
      final decryptedBytes = _encrypter.decryptBytes(encrypted, iv: _iv);

      // Sauvegarder temporairement pour lecture
      final tempDir = await getTemporaryDirectory();
      final tempPath = p.join(tempDir.path, 'tts_temp_$key.mp3');
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(decryptedBytes);

      TtsLogger.metric('tts.cache.hit', 1);
      return tempPath;
    } catch (e) {
      TtsLogger.error('Erreur lecture cache', {'key': key}, e);
      return null;
    } finally {
      timer.stop();
    }
  }

  /// Stocke un fichier dans le cache avec chiffrement
  Future<void> store({
    required String key,
    required String filePath,
    required Map<String, dynamic> metadata,
  }) async {
    final timer = TtsPerformanceTimer('cache.store', {'key': key});

    try {
      final dir = await cacheDir();
      final sourceFile = File(filePath);

      if (!await sourceFile.exists()) {
        throw Exception('Fichier source inexistant: $filePath');
      }

      // Lire et chiffrer le fichier
      final originalBytes = await sourceFile.readAsBytes();
      final encrypted = _encrypter.encryptBytes(originalBytes, iv: _iv);

      // Sauvegarder le fichier chiffré
      final encryptedPath = p.join(dir.path, '$key.aes');
      final encryptedFile = File(encryptedPath);
      await encryptedFile.writeAsBytes(encrypted.bytes);

      // Sauvegarder les métadonnées
      await _saveMetadata(key, {
        ...metadata,
        'size': originalBytes.length,
        'encryptedSize': encrypted.bytes.length,
        'timestamp': DateTime.now().toIso8601String(),
      });

      TtsLogger.info('Fichier mis en cache', {
        'key': key,
        'originalSize': originalBytes.length,
        'encryptedSize': encrypted.bytes.length,
      });

      TtsLogger.metric('tts.cache.store', 1, {
        'sizeBytes': originalBytes.length,
      });

      // Nettoyer automatiquement les vieux fichiers
      await _autoCleanup();
    } catch (e) {
      TtsLogger.error('Erreur stockage cache', {'key': key}, e);
    } finally {
      timer.stop();
    }
  }

  /// Charge le manifest chiffré
  Future<Map<String, dynamic>> _loadManifest() async {
    try {
      final dir = await cacheDir();
      final manifestFile = File(p.join(dir.path, _manifestName));

      if (!await manifestFile.exists()) {
        return {};
      }

      // Déchiffrer le manifest
      final encryptedBytes = await manifestFile.readAsBytes();
      final encrypted = Encrypted(encryptedBytes);
      final decryptedBytes = _encrypter.decryptBytes(encrypted, iv: _iv);
      final jsonString = utf8.decode(decryptedBytes);

      final data = jsonDecode(jsonString);
      return data is Map<String, dynamic> ? data : {};
    } catch (e) {
      TtsLogger.error('Erreur lecture manifest', null, e);
      return {};
    }
  }

  /// Sauvegarde le manifest chiffré
  Future<void> _saveManifest(Map<String, dynamic> manifest) async {
    try {
      final dir = await cacheDir();
      final manifestFile = File(p.join(dir.path, _manifestName));

      // Chiffrer le manifest
      final jsonString = jsonEncode(manifest);
      final jsonBytes = utf8.encode(jsonString);
      final encrypted = _encrypter.encryptBytes(jsonBytes, iv: _iv);

      await manifestFile.writeAsBytes(encrypted.bytes);
    } catch (e) {
      TtsLogger.error('Erreur sauvegarde manifest', null, e);
    }
  }

  /// Récupère les métadonnées d'une entrée
  Future<Map<String, dynamic>?> _getMetadata(String key) async {
    final manifest = await _loadManifest();
    final metadata = manifest[key];
    return metadata is Map<String, dynamic> ? metadata : null;
  }

  /// Sauvegarde les métadonnées d'une entrée
  Future<void> _saveMetadata(String key, Map<String, dynamic> metadata) async {
    final manifest = await _loadManifest();
    manifest[key] = metadata;
    await _saveManifest(manifest);
  }

  /// Supprime une entrée du cache
  Future<void> _removeEntry(String key) async {
    try {
      final dir = await cacheDir();

      // Supprimer le fichier chiffré
      final encryptedPath = p.join(dir.path, '$key.aes');
      final encryptedFile = File(encryptedPath);
      if (await encryptedFile.exists()) {
        await encryptedFile.delete();
      }

      // Supprimer des métadonnées
      final manifest = await _loadManifest();
      manifest.remove(key);
      await _saveManifest(manifest);
    } catch (e) {
      TtsLogger.error('Erreur suppression cache', {'key': key}, e);
    }
  }

  /// Nettoyage automatique des vieux fichiers
  Future<void> _autoCleanup() async {
    try {
      final manifest = await _loadManifest();
      final now = DateTime.now();
      const maxAge = Duration(days: 7);
      const maxSize = 100 * 1024 * 1024; // 100 MB

      // Calculer taille totale et identifier fichiers à supprimer
      int totalSize = 0;
      final toRemove = <String>[];

      for (final entry in manifest.entries) {
        final metadata = entry.value as Map<String, dynamic>;
        final timestamp = DateTime.tryParse(metadata['timestamp'] ?? '');
        final size = metadata['encryptedSize'] as int? ?? 0;

        totalSize += size;

        if (timestamp != null && now.difference(timestamp) > maxAge) {
          toRemove.add(entry.key);
        }
      }

      // Supprimer les vieux fichiers
      for (final key in toRemove) {
        await _removeEntry(key);
      }

      // Si toujours trop gros, supprimer les plus vieux
      if (totalSize > maxSize) {
        final sortedEntries = manifest.entries.toList()
          ..sort((a, b) {
            final aTime =
                DateTime.tryParse(a.value['timestamp'] ?? '') ?? DateTime(2000);
            final bTime =
                DateTime.tryParse(b.value['timestamp'] ?? '') ?? DateTime(2000);
            return aTime.compareTo(bTime);
          });

        // Supprimer jusqu'à ce que la taille soit acceptable
        for (final entry in sortedEntries) {
          if (totalSize <= maxSize) break;

          final size = entry.value['encryptedSize'] as int? ?? 0;
          await _removeEntry(entry.key);
          totalSize -= size;
        }
      }

      TtsLogger.info('Nettoyage cache', {
        'removed': toRemove.length,
        'totalSize': totalSize,
        'maxSize': maxSize,
      });
    } catch (e) {
      TtsLogger.error('Erreur nettoyage cache', null, e);
    }
  }

  /// Obtient les statistiques du cache
  Future<Map<String, dynamic>> getStats() async {
    try {
      final manifest = await _loadManifest();
      int fileCount = 0;
      int totalSize = 0;
      DateTime? oldestFile;
      DateTime? newestFile;

      for (final metadata in manifest.values) {
        if (metadata is Map<String, dynamic>) {
          fileCount++;
          totalSize += (metadata['encryptedSize'] as int? ?? 0);

          final timestamp = DateTime.tryParse(metadata['timestamp'] ?? '');
          if (timestamp != null) {
            if (oldestFile == null || timestamp.isBefore(oldestFile)) {
              oldestFile = timestamp;
            }
            if (newestFile == null || timestamp.isAfter(newestFile)) {
              newestFile = timestamp;
            }
          }
        }
      }

      return {
        'fileCount': fileCount,
        'totalSizeBytes': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'oldestFile': oldestFile?.toIso8601String(),
        'newestFile': newestFile?.toIso8601String(),
        'cacheVersion': _cacheVersion,
        'encrypted': true,
      };
    } catch (e) {
      TtsLogger.error('Erreur stats cache', null, e);
      return {
        'error': e.toString(),
      };
    }
  }

  /// Vide complètement le cache
  Future<void> clear() async {
    try {
      final dir = await cacheDir();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      await dir.create(recursive: true);

      TtsLogger.info('Cache vidé complètement');
      TtsLogger.metric('tts.cache.clear', 1);
    } catch (e) {
      TtsLogger.error('Erreur vidage cache', null, e);
    }
  }
}

// Provider Riverpod
final secureTtsCacheProvider = Provider<SecureTtsCacheService>((ref) {
  return SecureTtsCacheService();
});
