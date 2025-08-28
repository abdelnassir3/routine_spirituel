// Mobile Isar implementation that bypasses schema generation issues
// This provides a working Isar interface for iOS/Android without requiring isar_generator

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Stub classes that match the Isar collections interface
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

class VerseDoc {
  int id = 0;
  late int surah;
  late int ayah;
  String? textAr;
  String? textFr;

  int get surahAyah => surah;

  VerseDoc();
}

class TaskContent {
  int isarId = 0;
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

  String get taskId => id;

  TaskContent();
}

// Simple in-memory storage for mobile stub
class _MemoryStorage {
  static final _instance = _MemoryStorage._internal();
  factory _MemoryStorage() {
    print('🔧 DEBUG _MemoryStorage: Getting instance (${_instance.hashCode})');
    return _instance;
  }
  _MemoryStorage._internal() {
    print('🔧 DEBUG _MemoryStorage: Creating singleton instance');
  }

  final List<VerseDoc> _verses = [];
  final List<ContentDoc> _contents = [];
  final List<TaskContent> _tasks = [];

  void clearAll() {
    _verses.clear();
    _contents.clear();
    _tasks.clear();
  }
  
  // Debug method to check storage content
  void debugPrintStatus() {
    print('🔍 DEBUG Storage Status: ${_verses.length} verses, ${_contents.length} contents, ${_tasks.length} tasks');
    if (_verses.length > 0) {
      print('🔍 DEBUG First verse: Surah ${_verses[0].surah}, Ayah ${_verses[0].ayah}');
      print('🔍 DEBUG Last verse: Surah ${_verses.last.surah}, Ayah ${_verses.last.ayah}');
      
      // Check specific verses that user is looking for
      final surah3verses = _verses.where((v) => v.surah == 3).toList();
      print('🔍 DEBUG Surah 3 verses count: ${surah3verses.length}');
      if (surah3verses.length > 0) {
        print('🔍 DEBUG Surah 3 first verse: ${surah3verses[0].ayah}');
      }
    }
  }
}

// Collection stub that provides actual storage for mobile
class _IsarCollectionStub {
  final String _collectionType;
  _IsarCollectionStub(this._collectionType);

  _IsarFilterStub filter() => _IsarFilterStub(_collectionType);
  
  Future<void> put(dynamic doc) async {
    final storage = _MemoryStorage();
    if (_collectionType == 'verseDocs' && doc is VerseDoc) {
      // Remove existing doc with same surah/ayah
      storage._verses.removeWhere((v) => v.surah == doc.surah && v.ayah == doc.ayah);
      storage._verses.add(doc);
      print('💾 DEBUG put: stored verse ${doc.surah}:${doc.ayah} (total: ${storage._verses.length})');
    } else if (_collectionType == 'contentDocs' && doc is ContentDoc) {
      // Remove existing doc with same taskId/locale
      storage._contents.removeWhere((c) => c.taskId == doc.taskId && c.locale == doc.locale);
      storage._contents.add(doc);
    } else if (_collectionType == 'taskContents' && doc is TaskContent) {
      // Remove existing doc with same id
      storage._tasks.removeWhere((t) => t.id == doc.id);
      storage._tasks.add(doc);
    }
  }
  
  Future<void> putAll(List<dynamic> docs) async {
    for (final doc in docs) {
      await put(doc);
    }
  }
}

class _IsarFilterStub {
  final String _collectionType;
  String? _taskIdFilter;
  String? _localeFilter;
  int? _surahFilter;
  int? _ayahStartFilter;
  int? _ayahEndFilter;
  bool _sortByAyahFlag = false;

  _IsarFilterStub(this._collectionType);
  
  _IsarFilterStub taskIdEqualTo(String value) {
    _taskIdFilter = value;
    return this;
  }
  
  _IsarFilterStub and() => this;
  
  _IsarFilterStub localeEqualTo(String value) {
    _localeFilter = value;
    return this;
  }
  
  _IsarFilterStub surahEqualTo(int value) {
    _surahFilter = value;
    return this;
  }
  
  _IsarFilterStub ayahBetween(int start, int end) {
    _ayahStartFilter = start;
    _ayahEndFilter = end;
    return this;
  }
  
  _IsarFilterStub sortByAyah() {
    _sortByAyahFlag = true;
    return this;
  }
  
  Future<ContentDoc?> findFirst() async {
    final storage = _MemoryStorage();
    if (_collectionType == 'contentDocs') {
      ContentDoc? result;
      for (final doc in storage._contents) {
        bool matches = true;
        if (_taskIdFilter != null && doc.taskId != _taskIdFilter) matches = false;
        if (_localeFilter != null && doc.locale != _localeFilter) matches = false;
        if (matches) {
          result = doc;
          break;
        }
      }
      return result;
    }
    return null;
  }
  
  Future<List<VerseDoc>> findAll() async {
    final storage = _MemoryStorage();
    print('🔍 DEBUG findAll: collectionType=$_collectionType');
    print('🔍 DEBUG findAll: total verses in storage = ${storage._verses.length}');
    print('🔍 DEBUG findAll: surahFilter=$_surahFilter, ayahStart=$_ayahStartFilter, ayahEnd=$_ayahEndFilter');
    storage.debugPrintStatus();
    
    if (_collectionType == 'verseDocs') {
      List<VerseDoc> result = [];
      for (final verse in storage._verses) {
        bool matches = true;
        if (_surahFilter != null && verse.surah != _surahFilter) matches = false;
        if (_ayahStartFilter != null && verse.ayah < _ayahStartFilter!) matches = false;
        if (_ayahEndFilter != null && verse.ayah > _ayahEndFilter!) matches = false;
        if (matches) {
          result.add(verse);
          print('🔍 DEBUG findAll: matched verse ${verse.surah}:${verse.ayah}');
        }
      }
      
      if (_sortByAyahFlag) {
        result.sort((a, b) => a.ayah.compareTo(b.ayah));
      }
      
      print('🔍 DEBUG findAll: returning ${result.length} results');
      return result;
    }
    return [];
  }
}

// Isar class stub for mobile
class Isar {
  static const autoIncrement = 0;

  static Future<Isar> open(List<dynamic> schemas, {String? directory}) async {
    return Isar._();
  }

  Isar._();

  void close() {}

  // Collection getters that the real code expects
  _IsarCollectionStub get contentDocs => _IsarCollectionStub('contentDocs');
  _IsarCollectionStub get verseDocs => _IsarCollectionStub('verseDocs');
  _IsarCollectionStub get taskContents => _IsarCollectionStub('taskContents');

  Future<void> writeTxn(Function() fn) async {
    await fn();
  }
}

// Schema stubs (not used but needed for compilation)
class ContentDocSchema {
  const ContentDocSchema();
}

class VerseDocSchema {
  const VerseDocSchema();
}

class TaskContentSchema {
  const TaskContentSchema();
}

// Provider removed - use the one from content_service.dart