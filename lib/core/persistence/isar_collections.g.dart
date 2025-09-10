// GENERATED CODE - DO NOT MODIFY BY HAND
// This file is generated from isar_collections.dart
// Manual stub to resolve compilation errors

// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

import 'package:isar/isar.dart';
import 'isar_collections.dart';

// ContentDoc schema stub
const ContentDocSchema = CollectionSchema<ContentDoc>(
  name: r'ContentDoc',
  id: 1,
  properties: {
    r'body': PropertySchema(id: 0, name: r'body', type: IsarType.string),
    r'correctedBody': PropertySchema(id: 1, name: r'correctedBody', type: IsarType.string),
    r'diacritizedBody': PropertySchema(id: 2, name: r'diacritizedBody', type: IsarType.string),
    r'kind': PropertySchema(id: 3, name: r'kind', type: IsarType.string),
    r'locale': PropertySchema(id: 4, name: r'locale', type: IsarType.string),
    r'rawBody': PropertySchema(id: 5, name: r'rawBody', type: IsarType.string),
    r'source': PropertySchema(id: 6, name: r'source', type: IsarType.string),
    r'taskId': PropertySchema(id: 7, name: r'taskId', type: IsarType.string),
    r'taskLocale': PropertySchema(id: 8, name: r'taskLocale', type: IsarType.string),
    r'title': PropertySchema(id: 9, name: r'title', type: IsarType.string),
    r'validated': PropertySchema(id: 10, name: r'validated', type: IsarType.bool),
  },
  estimateSize: _contentDocEstimateSize,
  serialize: _contentDocSerialize,
  deserialize: _contentDocDeserialize,
  deserializeProp: _contentDocDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: (obj) => obj.id,
  setId: (obj, id) => obj.id = id,
  getLinks: (obj) => [],
  attachLinks: (obj, _) {},
  version: '3.1.0+1',
);

int _contentDocEstimateSize(ContentDoc object, List<int> offsets, Map<Type, List<int>> allOffsets) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _contentDocSerialize(ContentDoc object, IsarWriter writer, List<int> offsets, Map<Type, List<int>> allOffsets) {}

ContentDoc _contentDocDeserialize(Id id, IsarReader reader, List<int> offsets, Map<Type, List<int>> allOffsets) {
  final object = ContentDoc();
  object.id = id;
  return object;
}

P _contentDocDeserializeProp<P>(IsarReader reader, int propertyId, int offset, Map<Type, List<int>> allOffsets) {
  switch (propertyId) {
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

// VerseDoc schema stub
const VerseDocSchema = CollectionSchema<VerseDoc>(
  name: r'VerseDoc',
  id: 2,
  properties: {
    r'ayah': PropertySchema(id: 0, name: r'ayah', type: IsarType.long),
    r'surah': PropertySchema(id: 1, name: r'surah', type: IsarType.long),
    r'surahAyah': PropertySchema(id: 2, name: r'surahAyah', type: IsarType.long),
    r'textAr': PropertySchema(id: 3, name: r'textAr', type: IsarType.string),
    r'textFr': PropertySchema(id: 4, name: r'textFr', type: IsarType.string),
  },
  estimateSize: _verseDocEstimateSize,
  serialize: _verseDocSerialize,
  deserialize: _verseDocDeserialize,
  deserializeProp: _verseDocDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: (obj) => obj.id,
  setId: (obj, id) => obj.id = id,
  getLinks: (obj) => [],
  attachLinks: (obj, _) {},
  version: '3.1.0+1',
);

int _verseDocEstimateSize(VerseDoc object, List<int> offsets, Map<Type, List<int>> allOffsets) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _verseDocSerialize(VerseDoc object, IsarWriter writer, List<int> offsets, Map<Type, List<int>> allOffsets) {}

VerseDoc _verseDocDeserialize(Id id, IsarReader reader, List<int> offsets, Map<Type, List<int>> allOffsets) {
  final object = VerseDoc();
  object.id = id;
  return object;
}

P _verseDocDeserializeProp<P>(IsarReader reader, int propertyId, int offset, Map<Type, List<int>> allOffsets) {
  switch (propertyId) {
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

// TaskContent schema stub
const TaskContentSchema = CollectionSchema<TaskContent>(
  name: r'TaskContent',
  id: 3,
  properties: {
    r'ayahEnd': PropertySchema(id: 0, name: r'ayahEnd', type: IsarType.long),
    r'ayahStart': PropertySchema(id: 1, name: r'ayahStart', type: IsarType.long),
    r'category': PropertySchema(id: 2, name: r'category', type: IsarType.string),
    r'defaultRepetitions': PropertySchema(id: 3, name: r'defaultRepetitions', type: IsarType.long),
    r'id': PropertySchema(id: 4, name: r'id', type: IsarType.string),
    r'nameAr': PropertySchema(id: 5, name: r'nameAr', type: IsarType.string),
    r'nameFr': PropertySchema(id: 6, name: r'nameFr', type: IsarType.string),
    r'notes': PropertySchema(id: 7, name: r'notes', type: IsarType.string),
    r'surahNumber': PropertySchema(id: 8, name: r'surahNumber', type: IsarType.long),
    r'taskId': PropertySchema(id: 9, name: r'taskId', type: IsarType.string),
    r'textAr': PropertySchema(id: 10, name: r'textAr', type: IsarType.string),
    r'textFr': PropertySchema(id: 11, name: r'textFr', type: IsarType.string),
    r'type': PropertySchema(id: 12, name: r'type', type: IsarType.string),
  },
  estimateSize: _taskContentEstimateSize,
  serialize: _taskContentSerialize,
  deserialize: _taskContentDeserialize,
  deserializeProp: _taskContentDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: (obj) => obj.isarId,
  setId: (obj, id) => obj.isarId = id,
  getLinks: (obj) => [],
  attachLinks: (obj, _) {},
  version: '3.1.0+1',
);

int _taskContentEstimateSize(TaskContent object, List<int> offsets, Map<Type, List<int>> allOffsets) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _taskContentSerialize(TaskContent object, IsarWriter writer, List<int> offsets, Map<Type, List<int>> allOffsets) {}

TaskContent _taskContentDeserialize(Id id, IsarReader reader, List<int> offsets, Map<Type, List<int>> allOffsets) {
  final object = TaskContent();
  object.isarId = id;
  return object;
}

P _taskContentDeserializeProp<P>(IsarReader reader, int propertyId, int offset, Map<Type, List<int>> allOffsets) {
  switch (propertyId) {
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}