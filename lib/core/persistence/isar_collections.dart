import 'dart:typed_data';
import 'package:isar/isar.dart';

part 'isar_collections.g.dart';

@collection
class ContentDoc {
  Id id = Isar.autoIncrement;
  late String taskId; // FK to Tasks.id
  late String locale; // 'fr' | 'ar'
  late String kind; // text|verses|surah|mixed
  String? title;
  // Final text displayed (after validation/diacritization)
  String? body;
  // Source management
  String?
      source; // manual|image_ocr|pdf_ocr|audio_transcription|verses|surah|mixed
  String? rawBody; // OCR/transcription raw result
  String? correctedBody; // corrected by user
  String? diacritizedBody; // Arabic diacritized
  bool validated = false;

  @Index(composite: [CompositeIndex('locale')])
  String get taskLocale => taskId;
}

@collection
class VerseDoc {
  Id id = Isar.autoIncrement;
  late int surah; // 1..114
  late int ayah; // ≥1
  String? textAr;
  String? textFr;

  @Index(composite: [CompositeIndex('ayah')])
  int get surahAyah => surah;
}

@collection
class TaskContent {
  Id isarId = Isar.autoIncrement;
  String id = '';
  String type = 'text'; // text|verses|surah|mixed
  String? nameFr;
  String? nameAr;
  String? textAr;
  String? textFr;
  int? surahNumber;
  int? ayahStart;
  int? ayahEnd;
  String? category;
  int? defaultRepetitions;
  String? notes;

  @Index()
  String get taskId => id;
}
