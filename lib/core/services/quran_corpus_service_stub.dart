import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../persistence/isar_web_stub.dart' show TaskContent;

// Stub temporaire pour compilation mobile - désactive Isar
class VerseDoc {
  int id = 0;
  late int surah;
  late int ayah;
  String? textAr;
  String? textFr;
  int get surahAyah => surah;
  VerseDoc();
}

class ContentDoc {
  int id = 0;
  late String taskId;
  late String locale;
  late String kind;
  String? title;
  String? body;
  String? source;
  String? rawBody;
  String? correctedBody;
  String? diacritizedBody;
  bool validated = false;
  String get taskLocale => taskId;
  ContentDoc();
}

// TaskContent is imported from isar_web_stub.dart to avoid conflicts

class QuranCorpusService {
  QuranCorpusService(this._ref);
  final Ref _ref;

  Future<List<VerseDoc>> getRange(int surah, int start, int end) async {
    // Stub - retourne liste vide
    return <VerseDoc>[];
  }

  Future<void> importVerses(List<VerseDoc> verses) async {
    // Stub - ne fait rien
  }
}

final quranCorpusServiceProvider =
    Provider<QuranCorpusService>((ref) => QuranCorpusService(ref));