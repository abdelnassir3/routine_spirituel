import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart'
    if (dart.library.html) '../persistence/isar_web_stub.dart'
    if (dart.library.io) '../persistence/isar_mobile_stub.dart';

import 'package:spiritual_routines/core/persistence/isar_collections.dart'
    if (dart.library.html) '../persistence/isar_web_stub.dart'
    if (dart.library.io) '../persistence/isar_mobile_stub.dart';
import 'package:spiritual_routines/core/services/content_service.dart' show ContentService, isarProvider; // Import both

final quranCorpusServiceProvider =
    Provider<QuranCorpusService>((ref) => QuranCorpusService(ref));

class QuranCorpusService {
  QuranCorpusService(this._ref);
  final Ref _ref;

  Future<List<VerseDoc>> getRange(int surah, int start, int end) async {
    final isar =
        await _ref.read(isarProvider.future); // ⬅️ utilise l’instance partagée
    return isar.verseDocs
        .filter()
        .surahEqualTo(surah)
        .and()
        .ayahBetween(start, end) // adapte le nom du champ si nécessaire
        .sortByAyah()
        .findAll();
  }

  Future<void> importVerses(List<VerseDoc> verses) async {
    final isar = await _ref.read(isarProvider.future); // ⬅️ idem
    await isar.writeTxn(() => isar.verseDocs.putAll(verses));
  }
}
