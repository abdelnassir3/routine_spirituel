import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';
import 'package:drift/drift.dart' as drift;

class TaskLangAudio {
  final String source; // 'coqui' | 'device' | 'cloud' | 'file'
  final String? filePath;
  const TaskLangAudio({required this.source, this.filePath});
  bool get hasLocalFile =>
      source == 'file' && filePath != null && File(filePath!).existsSync();

  Map<String, dynamic> toJson() => {
        'source': source,
        if (filePath != null) 'filePath': filePath,
      };

  static TaskLangAudio fromJson(Object? json) {
    if (json is Map<String, dynamic>) {
      return TaskLangAudio(
        source: (json['source'] as String?) ?? 'coqui',
        filePath: json['filePath'] as String?,
      );
    }
    return const TaskLangAudio(source: 'coqui');
  }
}

class TaskAudioPrefsService {
  TaskAudioPrefsService(this._ref);
  final Ref _ref;

  Future<Map<String, dynamic>> _loadSettingsMap(String taskId) async {
    final dao = _ref.read(taskDaoProvider);
    final row = await dao.getById(taskId);
    if (row == null) return {};
    try {
      final map = jsonDecode(row.audioSettings);
      if (map is Map<String, dynamic>) return map;
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveSettingsMap(
      String taskId, Map<String, dynamic> data) async {
    final dao = _ref.read(taskDaoProvider);
    await dao.upsertTask(TasksCompanion(
      id: drift.Value(taskId),
      audioSettings: drift.Value(jsonEncode(data)),
    ));
  }

  Future<TaskLangAudio> getForTaskLocale(String taskId, String locale) async {
    final map = await _loadSettingsMap(taskId);
    // Support ancien format plat
    if (map.containsKey('source') || map.containsKey('filePath')) {
      return TaskLangAudio(
        source: (map['source'] as String?) ?? 'coqui',
        filePath: map['filePath'] as String?,
      );
    }
    final sub = map[locale];
    return TaskLangAudio.fromJson(sub);
  }

  Future<void> setForTaskLocale(
      String taskId, String locale, TaskLangAudio settings) async {
    final map = await _loadSettingsMap(taskId);
    // Si ancien format, on migre en structure par locale
    if (map.containsKey('source') || map.containsKey('filePath')) {
      map.remove('source');
      map.remove('filePath');
    }
    map[locale] = settings.toJson();
    await _saveSettingsMap(taskId, map);
  }
}

final taskAudioPrefsProvider =
    Provider<TaskAudioPrefsService>((ref) => TaskAudioPrefsService(ref));
