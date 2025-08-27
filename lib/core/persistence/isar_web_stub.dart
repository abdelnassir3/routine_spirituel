// Stub pour Isar sur le web
// Sur le web, nous utilisons Drift exclusivement

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Classes stub pour éviter les erreurs de compilation
class ContentDoc {
  String? id;
  String? taskId;
  String? locale;
  String? kind;
  String? title;
  String? body;
  String? source;
  String? rawBody;
  String? correctedBody;
  String? diacritizedBody;
  bool? validated;
  
  ContentDoc();
}

class VerseDoc {
  final String id;
  final int surah;
  final int ayah;
  final String? textAr;
  final String? textFr;
  
  VerseDoc({
    required this.id,
    required this.surah,
    required this.ayah,
    this.textAr,
    this.textFr,
  });
}

class TaskContent {
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
  
  Future<void> writeTxn(Function() fn) async {
    throw UnsupportedError('Isar is not supported on web. Use Drift instead.');
  }
}

class _IsarCollectionStub {
  _IsarFilterStub filter() => _IsarFilterStub();
}

class _IsarFilterStub {
  _IsarFilterStub taskIdEqualTo(String value) => this;
  _IsarFilterStub and() => this;
  _IsarFilterStub localeEqualTo(String value) => this;
  Future<ContentDoc?> findFirst() async => null;
  Future<void> put(ContentDoc doc) async {}
}

// Provider stub
final isarProvider = FutureProvider<Isar>((ref) async {
  throw UnsupportedError('Isar is not supported on web. Use Drift instead.');
});