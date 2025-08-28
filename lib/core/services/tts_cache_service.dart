import 'dart:io';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

class TtsCacheService {
  static const _manifestName = 'manifest.json';
  Future<Directory> cacheDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'tts-cache'));
    if (!(await dir.exists())) await dir.create(recursive: true);
    return dir;
  }

  Future<int> sizeBytes() async {
    final dir = await cacheDir();
    int total = 0;
    await for (final ent in dir.list(recursive: true, followLinks: false)) {
      if (ent is File) {
        try {
          total += await ent.length();
        } catch (_) {}
      }
    }
    return total;
  }

  Future<void> clear() async {
    final dir = await cacheDir();
    try {
      await dir.delete(recursive: true);
    } catch (_) {}
    await dir.create(recursive: true);
  }

  Future<int> purgeOlderThan(Duration age) async {
    final dir = await cacheDir();
    int removed = 0;
    final threshold = DateTime.now().subtract(age);
    await for (final ent in dir.list(recursive: true, followLinks: false)) {
      if (ent is File) {
        try {
          final stat = await ent.stat();
          if (stat.modified.isBefore(threshold)) {
            await ent.delete();
            removed++;
          }
        } catch (_) {}
      }
    }
    return removed;
  }

  Future<bool> existsFor({
    required String provider,
    required String voice,
    required double speed,
    required double pitch,
    required String text,
  }) async {
    final dir = await cacheDir();
    final digest =
        sha1.convert(utf8.encode('$provider|$voice|$speed|$pitch|$text'));
    final path = p.join(dir.path, '${digest.toString()}.mp3');
    return File(path).exists();
  }

  // Manifest management -------------------------------------------------
  Future<File> _manifestFile() async {
    final dir = await cacheDir();
    return File(p.join(dir.path, _manifestName));
  }

  Future<Map<String, dynamic>> _loadManifest() async {
    try {
      final f = await _manifestFile();
      if (!await f.exists()) return {};
      final txt = await f.readAsString();
      final data = jsonDecode(txt);
      return data is Map<String, dynamic> ? data : {};
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveManifest(Map<String, dynamic> data) async {
    final f = await _manifestFile();
    await f.writeAsString(jsonEncode(data));
  }

  Future<String> computeDigest({
    required String provider,
    required String voice,
    required double speed,
    required double pitch,
    required String text,
  }) async {
    return sha1
        .convert(utf8.encode('$provider|$voice|$speed|$pitch|$text'))
        .toString();
  }

  Future<void> recordEntry({
    required String digest,
    required String routineId,
    required String taskId,
    required String lang,
    required int sizeBytes,
  }) async {
    final manifest = await _loadManifest();
    manifest[digest] = {
      'routineId': routineId,
      'taskId': taskId,
      'lang': lang,
      'size': sizeBytes,
      'ts': DateTime.now().toIso8601String(),
    };
    await _saveManifest(manifest);
  }

  Future<(int files, int bytes)> statsForRoutine(String routineId) async {
    final manifest = await _loadManifest();
    int files = 0;
    int bytes = 0;
    manifest.forEach((_, meta) {
      if (meta is Map && meta['routineId'] == routineId) {
        files += 1;
        final s = meta['size'];
        if (s is int) bytes += s;
      }
    });
    return (files, bytes);
  }

  Future<int> clearRoutine(String routineId) async {
    final manifest = await _loadManifest();
    final dir = await cacheDir();
    int removed = 0;
    final toRemove = <String>[];
    for (final entry in manifest.entries) {
      final meta = entry.value;
      if (meta is Map && meta['routineId'] == routineId) {
        final digest = entry.key;
        final path = p.join(dir.path, '$digest.mp3');
        try {
          final f = File(path);
          if (await f.exists()) {
            await f.delete();
            removed++;
          }
        } catch (_) {}
        toRemove.add(digest);
      }
    }
    for (final d in toRemove) {
      manifest.remove(d);
    }
    await _saveManifest(manifest);
    return removed;
  }

  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final dir = await cacheDir();
      int fileCount = 0;
      int totalSize = 0;
      DateTime? oldestFile;
      DateTime? newestFile;

      await for (final entity
          in dir.list(recursive: true, followLinks: false)) {
        if (entity is File && entity.path.endsWith('.mp3')) {
          fileCount++;
          final stat = await entity.stat();
          totalSize += await entity.length();

          if (oldestFile == null || stat.modified.isBefore(oldestFile)) {
            oldestFile = stat.modified;
          }
          if (newestFile == null || stat.modified.isAfter(newestFile)) {
            newestFile = stat.modified;
          }
        }
      }

      return {
        'fileCount': fileCount,
        'totalSizeBytes': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'oldestFile': oldestFile?.toIso8601String(),
        'newestFile': newestFile?.toIso8601String(),
      };
    } catch (e) {
      return {
        'fileCount': 0,
        'totalSizeBytes': 0,
        'totalSizeMB': '0.00',
        'error': e.toString(),
      };
    }
  }
}

final ttsCacheServiceProvider =
    Provider<TtsCacheService>((ref) => TtsCacheService());
