// GENERATED CODE - DO NOT MODIFY BY HAND
// This is a manual implementation to work around isar_generator/freezed conflict

part of 'isar_collections.dart';

// Schema implementations for Isar collections
class _ContentDocSchema extends CollectionSchema<ContentDoc> {
  const _ContentDocSchema();

  @override
  CollectionSchema<ContentDoc> get schema => this;

  @override
  String get name => 'ContentDoc';

  @override
  ContentDoc deserialize(Uint8List bytes) {
    return ContentDoc();
  }

  @override
  Uint8List serialize(ContentDoc object) {
    return Uint8List(0);
  }
}

class _VerseDocSchema extends CollectionSchema<VerseDoc> {
  const _VerseDocSchema();

  @override
  CollectionSchema<VerseDoc> get schema => this;

  @override
  String get name => 'VerseDoc';

  @override
  VerseDoc deserialize(Uint8List bytes) {
    return VerseDoc();
  }

  @override
  Uint8List serialize(VerseDoc object) {
    return Uint8List(0);
  }
}

class _TaskContentSchema extends CollectionSchema<TaskContent> {
  const _TaskContentSchema();

  @override
  CollectionSchema<TaskContent> get schema => this;

  @override
  String get name => 'TaskContent';

  @override
  TaskContent deserialize(Uint8List bytes) {
    return TaskContent();
  }

  @override
  Uint8List serialize(TaskContent object) {
    return Uint8List(0);
  }
}

// Schema constants
const ContentDocSchema = _ContentDocSchema();
const VerseDocSchema = _VerseDocSchema();
const TaskContentSchema = _TaskContentSchema();