// Stub pour Isar sur le web
// Sur le web, nous utilisons Drift exclusivement

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Classes stub pour éviter les erreurs de compilation
class ContentDoc {
  int id = 0; // Match Isar's Id type
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

  String get taskLocale => taskId; // Match the getter from Isar version

  ContentDoc();
}

class VerseDoc {
  int id = 0; // Match Isar's Id type
  late int surah;
  late int ayah;
  String? textAr;
  String? textFr;

  int get surahAyah => surah; // Match the getter from Isar version

  VerseDoc();
}

class TaskContent {
  int isarId = 0; // Match the Isar version's Id field
  String id = '';
  String type = 'text';
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

  String get taskId => id; // Match the getter from Isar version

  TaskContent();
}

// Schemas stub
class ContentDocSchema {}

class VerseDocSchema {}

class TaskContentSchema {}

// Isar class stub
class Isar {
  static const autoIncrement = 0;

  static Future<Isar> open(List<dynamic> schemas, {String? directory}) async {
    throw UnsupportedError('Isar is not supported on web. Use Drift instead.');
  }

  void close() {}

  dynamic get contentDocs => _IsarCollectionStub();
  dynamic get taskContents => _IsarCollectionStub();
  dynamic get verseDocs => _IsarCollectionStub();

  Future<void> writeTxn(Function() fn) async {
    throw UnsupportedError('Isar is not supported on web. Use Drift instead.');
  }
}

// IsarStub class for web platform compatibility
class IsarStub extends Isar {
  @override
  static Future<IsarStub> open(List<dynamic> schemas, {String? directory}) async {
    return IsarStub();
  }

  @override
  void close() {
    // Stub implementation - do nothing
  }

  @override
  dynamic get contentDocs => _IsarCollectionStub();
  @override
  dynamic get taskContents => _IsarCollectionStub();
  @override
  dynamic get verseDocs => _IsarCollectionStub();

  @override
  Future<void> writeTxn(Function() fn) async {
    // Stub implementation - just call the function without persistence
    fn();
  }
}

class _IsarCollectionStub {
  _IsarFilterStub filter() => _IsarFilterStub();
  Future<void> put(dynamic doc) async {}
  Future<void> putAll(List<dynamic> docs) async {}
}

class _IsarFilterStub {
  _IsarFilterStub taskIdEqualTo(String value) => this;
  _IsarFilterStub and() => this;
  _IsarFilterStub localeEqualTo(String value) => this;
  _IsarFilterStub surahEqualTo(int value) => this;
  _IsarFilterStub ayahBetween(int start, int end) => this;
  _IsarFilterStub sortByAyah() => this;
  Future<ContentDoc?> findFirst() async => null;
  Future<List<VerseDoc>> findAll() async => <VerseDoc>[];
}

// Provider stub is in content_service.dart to avoid conflicts
// The isarProvider is defined in content_service.dart
