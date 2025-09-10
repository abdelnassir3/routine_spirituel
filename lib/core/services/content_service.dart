import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:spiritual_routines/core/utils/refs.dart';
import 'package:spiritual_routines/core/services/quran_corpus_service.dart';

// Stub temporaire pour désactiver Isar
final contentServiceProvider = Provider<ContentService>((ref) => ContentService(ref));

class ContentService {
  ContentService(this._ref);
  final Ref _ref;

  Future<dynamic> getByTaskAndLocale(String taskId, String locale) async {
    return null;
  }

  Stream<List<dynamic>> watchByTaskAndLocale(String taskId, String locale) {
    return Stream.value([]);
  }

  Future<String?> buildTextFromRefs(String refs, String locale) async {
    final ranges = parseRefs(refs);
    if (ranges.isEmpty) return null;
    final corpus = _ref.read(quranCorpusServiceProvider);
    final buffer = StringBuffer();
    for (final r in ranges) {
      final verses = await corpus.getRange(r.surah, r.start, r.end);
      if (verses.isEmpty) continue;
      for (final v in verses) {
        final line = locale == 'ar' ? (v.textAr ?? '') : (v.textFr ?? '');
        if (line.isEmpty) continue;
        buffer.write(line.trim());
        buffer.write(' {{V:${v.ayah}}}');
        buffer.writeln();
      }
      buffer.writeln();
    }
    final text = buffer.toString().trim();
    return text.isEmpty ? null : text;
  }

  Future<(String?, String?)> getBuiltTextsForTask(String taskId) async {
    return (null, null);
  }

  bool _isArabicQuranContent(String text) => false;
  bool _isFrenchQuranContent(String text) => false;
  String _addVerseMarkersToQuranText(String text) => text;

  // Méthodes manquantes utilisées dans les pages  
  Future<void> putContent({
    required String taskId, 
    required String locale, 
    required String content,
    String? title,
    String? body,
    String? kind,
  }) async {
    // Stub pour stocker du contenu
  }

  Future<Map<String, String>?> getEditingBodies(String taskId, String locale) async {
    // Stub pour récupérer les contenus en cours d'édition
    return null;
  }

  Future<void> setSource({
    required String taskId, 
    required String locale, 
    required String source
  }) async {
    // Stub pour définir la source
  }

  Future<void> updateRaw({
    required String taskId, 
    required String locale, 
    required String raw
  }) async {
    // Stub pour mettre à jour le contenu brut
  }

  Future<void> updateCorrected({
    required String taskId, 
    required String locale, 
    required String corrected
  }) async {
    // Stub pour mettre à jour le contenu corrigé
  }

  Future<void> updateDiacritized({
    required String taskId, 
    required String locale, 
    required String diacritized
  }) async {
    // Stub pour mettre à jour le contenu avec diacritiques
  }

  Future<void> validateAndFinalize({
    required String taskId, 
    required String locale
  }) async {
    // Stub pour valider et finaliser le contenu
  }

  Future<void> store(String taskId, String locale, String body, String bodyType, String? refs) async {
    // Stub - ne fait rien
  }

  Future<void> storeAyah(String taskId, String locale, int surah, int ayah, String text) async {
    // Stub - ne fait rien
  }

  Future<void> storeRecitation(String taskId, String locale, String ref, String text) async {
    // Stub - ne fait rien
  }

  Future<void> storeDua(String taskId, String locale, String text, {String? category}) async {
    // Stub - ne fait rien
  }

  Future<void> storeParayerText(String taskId, String locale, String text) async {
    // Stub - ne fait rien
  }

  Future<void> storeTaskContent(dynamic content) async {
    // Stub - ne fait rien
  }

  Future<void> saveTaskContent(dynamic content) async {
    // Stub - ne fait rien
  }
}