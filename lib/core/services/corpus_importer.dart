import 'dart:convert';
import 'dart:io' as io; // ✅ pour File

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:spiritual_routines/core/persistence/isar_collections.dart';
import 'package:spiritual_routines/core/services/quran_corpus_service.dart';

class CorpusImporter {
  CorpusImporter(this._ref);
  final Ref _ref;

  Future<(int inserted, int updated)> importFromAssets() async {
    final svc = _ref.read(quranCorpusServiceProvider);

    // 1) Essayer d'abord le fichier complet (6236 versets)
    final full = await _tryLoad('assets/corpus/quran_full.json');
    if (full != null) {
      final items = jsonDecode(full);
      final verses = _parseCombined(items);
      await _chunkedImport(svc, verses);
      return (verses.length, 0);
    }

    // 2) Sinon essayer le fichier combiné
    final combined = await _tryLoad('assets/corpus/quran_combined.json');
    if (combined != null) {
      final items = jsonDecode(combined);
      final verses = _parseCombined(items);
      await _chunkedImport(svc, verses);
      return (verses.length, 0);
    }
    // 2) Deux fichiers séparés
    final arStr = await _tryLoad('assets/corpus/quran_ar.json');
    final frStr = await _tryLoad('assets/corpus/quran_fr.json');
    if (arStr == null && frStr == null) {
      throw Exception('Aucun fichier corpus trouvé dans assets/corpus');
    }
    final arList = arStr != null ? jsonDecode(arStr) : [];
    final frList = frStr != null ? jsonDecode(frStr) : [];
    final verses = _parseSeparate(arList, frList);
    await _chunkedImport(svc, verses);
    return (verses.length, 0);
  }

  Future<(int inserted, int updated)> importFromPath(String path) async {
    final svc = _ref.read(quranCorpusServiceProvider);
    final data = await _loadFile(path);
    final lower = path.toLowerCase();

    if (lower.contains('combined')) {
      final items = jsonDecode(data);
      final verses = _parseCombined(items);
      await _chunkedImport(svc, verses);
      return (verses.length, 0);
    }

    final parsed = jsonDecode(data);
    if (parsed is List &&
        parsed.isNotEmpty &&
        parsed.first is Map<String, dynamic>) {
      final first = parsed.first as Map<String, dynamic>;
      if (first.containsKey('textAr') || first.containsKey('textFr')) {
        final verses = _parseCombined(parsed);
        await _chunkedImport(svc, verses);
        return (verses.length, 0);
      }
    }

    // Fallback: liste simple (AR ou FR) -> parseSeparate
    final verses = _parseSeparate(parsed, []);
    await _chunkedImport(svc, verses);
    return (verses.length, 0);
  }

  Future<String> _loadFile(String path) async {
    return io.File(path).readAsString(); // ✅
  }

  Future<String?> _tryLoad(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (_) {
      return null;
    }
  }

  List<VerseDoc> _parseCombined(dynamic jsonVal) {
    final List<VerseDoc> out = [];
    if (jsonVal is List) {
      for (final e in jsonVal) {
        if (e is Map<String, dynamic>) {
          final v = VerseDoc()
            ..surah = (e['surah'] as num).toInt()
            ..ayah = (e['ayah'] as num).toInt()
            ..textAr = e['textAr'] as String?
            ..textFr = e['textFr'] as String?;
          out.add(v);
        }
      }
    }
    return out;
  }

  List<VerseDoc> _parseSeparate(dynamic arJson, dynamic frJson) {
    final Map<String, Map<String, dynamic>> frMap = {};
    if (frJson is List) {
      for (final e in frJson) {
        if (e is Map<String, dynamic>) {
          frMap['${e['surah']}-${e['ayah']}'] = e;
        }
      }
    }

    final List<VerseDoc> out = [];
    if (arJson is List) {
      for (final e in arJson) {
        if (e is Map<String, dynamic>) {
          final key = '${e['surah']}-${e['ayah']}';
          final fr = frMap[key];
          final v = VerseDoc()
            ..surah = (e['surah'] as num).toInt()
            ..ayah = (e['ayah'] as num).toInt()
            ..textAr = e['text'] as String?
            ..textFr = fr?['text'] as String?;
          out.add(v);
        }
      }
    } else if (frJson is List) {
      // Aucun AR fourni → importer FR seul
      for (final e in frJson) {
        if (e is Map<String, dynamic>) {
          final v = VerseDoc()
            ..surah = (e['surah'] as num).toInt()
            ..ayah = (e['ayah'] as num).toInt()
            ..textFr = e['text'] as String?;
          out.add(v);
        }
      }
    }
    return out;
  }

  Future<void> _chunkedImport(
      QuranCorpusService svc, List<VerseDoc> verses) async {
    const chunk = 2000;
    for (int i = 0; i < verses.length; i += chunk) {
      final end = (i + chunk < verses.length) ? i + chunk : verses.length;
      await svc.importVerses(verses.sublist(i, end));
    }
  }
}

final corpusImporterProvider =
    Provider<CorpusImporter>((ref) => CorpusImporter(ref));
