// Stub pour Isar sur le web
// Sur le web, nous utilisons Drift exclusivement

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/quran_corpus_web_service.dart';

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

  dynamic get contentDocs => _IsarCollectionStub('content');
  dynamic get taskContents => _IsarCollectionStub('task');
  dynamic get verseDocs => _IsarCollectionStub('verse');

  Future<void> writeTxn(Function() fn) async {
    throw UnsupportedError('Isar is not supported on web. Use Drift instead.');
  }
}

// IsarStub class for web platform compatibility
class IsarStub extends Isar {
  @override
  static Future<IsarStub> open(List<dynamic> schemas,
      {String? directory}) async {
    return IsarStub();
  }

  @override
  void close() {
    // Stub implementation - do nothing
  }

  @override
  dynamic get contentDocs => _IsarCollectionStub('content');
  @override
  dynamic get taskContents => _IsarCollectionStub('task');
  @override
  dynamic get verseDocs => _IsarCollectionStub('verse');

  @override
  Future<void> writeTxn(Function() fn) async {
    // Stub implementation - just call the function without persistence
    fn();
  }
}

class _IsarCollectionStub {
  // Stockage statique en mémoire pour persister les données entre instances
  static final Map<String, Map<String, dynamic>> _contentDocs = {};
  static final Map<String, Map<String, dynamic>> _taskContents = {};
  static int _idCounter = 2000; // Compteur simple pour éviter l'overflow DateTime
  
  final String _collectionType;
  
  _IsarCollectionStub([this._collectionType = 'content']);
  
  _IsarFilterStub filter() => _IsarFilterStub(_collectionType);
  
  Future<void> put(dynamic doc) async {
    if (doc == null) return;
    
    print('📝 IsarStub: Storing document in $_collectionType collection');
    
    // Générer un ID si nécessaire
    if (doc.id == 0 || doc.id == null) {
      doc.id = ++_idCounter;
    }
    
    // Debug: afficher les propriétés du doc avant conversion
    if (doc is ContentDoc) {
      print('🔍 IsarStub: ContentDoc properties - taskId: ${doc.taskId}, locale: ${doc.locale}, body: ${doc.body?.substring(0, (doc.body?.length ?? 0).clamp(0, 50))}..., kind: ${doc.kind}');
    }
    
    final docData = _convertToMap(doc);
    final String docId = doc.id.toString();
    
    if (_collectionType == 'content') {
      _contentDocs[docId] = docData;
      print('✅ IsarStub: Stored ContentDoc with ID $docId: ${docData['taskId']}-${docData['locale']}');
    } else if (_collectionType == 'task') {
      _taskContents[docId] = docData;
      print('✅ IsarStub: Stored TaskContent with ID $docId: ${docData['id']}');
    }
    
    // Debug: afficher l'état du stockage
    print('📊 IsarStub: Total stored - ContentDocs: ${_contentDocs.length}, TaskContents: ${_taskContents.length}');
  }
  
  Future<void> putAll(List<dynamic> docs) async {
    for (final doc in docs) {
      await put(doc);
    }
  }
  
  Map<String, dynamic> _convertToMap(dynamic doc) {
    if (doc is ContentDoc) {
      return {
        'id': doc.id,
        'taskId': doc.taskId,
        'locale': doc.locale,
        'kind': doc.kind,
        'title': doc.title,
        'body': doc.body,
        'source': doc.source,
        'rawBody': doc.rawBody,
        'correctedBody': doc.correctedBody,
        'diacritizedBody': doc.diacritizedBody,
        'validated': doc.validated,
      };
    } else if (doc is TaskContent) {
      return {
        'id': doc.id,
        'isarId': doc.isarId,
        'type': doc.type,
        'nameFr': doc.nameFr,
        'nameAr': doc.nameAr,
        'textAr': doc.textAr,
        'textFr': doc.textFr,
        'surahNumber': doc.surahNumber,
        'ayahStart': doc.ayahStart,
        'ayahEnd': doc.ayahEnd,
        'category': doc.category,
        'defaultRepetitions': doc.defaultRepetitions,
        'notes': doc.notes,
      };
    }
    return {};
  }
  
  // Méthode de débogage pour afficher l'état de la mémoire statique
  static void debugPrintMemoryState() {
    print('📊 IsarStub Memory State:');
    print('  - ContentDocs: ${_contentDocs.length} entries');
    _contentDocs.forEach((key, value) {
      print('    [$key]: ${value['taskId']}-${value['locale']} = "${value['body']?.toString().substring(0, (value['body']?.toString().length ?? 0).clamp(0, 50))}..."');
    });
    print('  - TaskContents: ${_taskContents.length} entries');
    _taskContents.forEach((key, value) {
      print('    [$key]: ${value['id']}');
    });
  }
}

class _IsarFilterStub {
  int? _surahFilter;
  int? _ayahStart;
  int? _ayahEnd;
  String? _taskIdFilter;
  String? _localeFilter;
  final String _collectionType;
  
  _IsarFilterStub([this._collectionType = 'content']);
  
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
    _ayahStart = start;
    _ayahEnd = end;
    return this;
  }
  
  _IsarFilterStub sortByAyah() => this;
  
  Future<ContentDoc?> findFirst() async {
    if (_collectionType == 'content' && _taskIdFilter != null && _localeFilter != null) {
      print('🔍 IsarStub: Searching for ContentDoc with taskId=$_taskIdFilter, locale=$_localeFilter');
      
      // Afficher l'état actuel de la mémoire
      _IsarCollectionStub.debugPrintMemoryState();
      
      // Chercher dans les ContentDocs stockés
      for (final entry in _IsarCollectionStub._contentDocs.entries) {
        final data = entry.value;
        if (data['taskId'] == _taskIdFilter && data['locale'] == _localeFilter) {
          print('✅ IsarStub: Found matching ContentDoc with ID ${entry.key}');
          
          // Convertir les données en objet ContentDoc
          final doc = ContentDoc()
            ..id = int.parse(entry.key)
            ..taskId = data['taskId'] as String
            ..locale = data['locale'] as String
            ..kind = data['kind'] as String
            ..title = data['title'] as String?
            ..body = data['body'] as String?
            ..source = data['source'] as String?
            ..rawBody = data['rawBody'] as String?
            ..correctedBody = data['correctedBody'] as String?
            ..diacritizedBody = data['diacritizedBody'] as String?
            ..validated = data['validated'] as bool;
          
          return doc;
        }
      }
      print('❌ IsarStub: No matching ContentDoc found for taskId=$_taskIdFilter, locale=$_localeFilter');
    }
    return null;
  }
  
  Future<List<VerseDoc>> findAll() async {
    // Si on a des filtres pour les versets du Coran, utiliser le service web
    if (_surahFilter != null && _ayahStart != null && _ayahEnd != null) {
      try {
        final service = QuranCorpusWebService();
        return await service.getRange(_surahFilter!, _ayahStart!, _ayahEnd!);
      } catch (e) {
        print('❌ Error loading verses from web service: $e');
      }
    }
    return <VerseDoc>[];
  }
}

// Provider stub is in content_service.dart to avoid conflicts
// The isarProvider is defined in content_service.dart
