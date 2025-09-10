import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'quran_corpus_web_service.dart';
import '../persistence/isar_web_stub.dart' show VerseDoc;

// Provider qui utilise le web service sur web
final quranCorpusServiceProvider = Provider<QuranCorpusService>((ref) {
  if (kIsWeb) {
    return QuranCorpusService(ref.read(quranCorpusWebServiceProvider));
  }
  return QuranCorpusService(null);
});

class QuranCorpusService {
  final QuranCorpusWebService? _webService;
  
  QuranCorpusService(this._webService);

  Future<List<VerseDoc>> getRange(int surah, int start, int end) async {
    if (kIsWeb && _webService != null) {
      return _webService!.getRange(surah, start, end);
    }
    // Pour les plateformes mobiles, retourner une liste vide pour l'instant
    // TODO: Implémenter le service pour mobile avec Isar
    return [];
  }

  Future<List<VerseDoc>> getSurah(int surah) async {
    if (kIsWeb && _webService != null) {
      return _webService!.getSurah(surah);
    }
    return [];
  }

  Future<List<VerseDoc>> getBySurahAyah(int surah, int ayah) async {
    if (kIsWeb && _webService != null) {
      return _webService!.getRange(surah, ayah, ayah);
    }
    return [];
  }

  Future<void> importVerses(List<dynamic> verses) async {
    // Stub - ne fait rien pour l'instant
    // TODO: Implémenter l'import pour mobile
  }
}

// Alias pour compatibilité
class VerseStub extends VerseDoc {
  VerseStub({int? ayah, String? textAr, String? textFr}) {
    if (ayah != null) this.ayah = ayah;
    if (textAr != null) this.textAr = textAr;
    if (textFr != null) this.textFr = textFr;
  }
}