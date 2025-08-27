import 'package:flutter/foundation.dart';
import 'package:spiritual_routines/core/models/task_category.dart';

@immutable
class RoutineThemeModel {
  final String id;
  final Map<String, String> name; // lang -> label
  final String frequency; // daily|weekly|monthly
  final List<String> routineIds;
  final DateTime createdAt;
  final Map<String, Object?> metadata;
  const RoutineThemeModel({
    required this.id,
    required this.name,
    required this.frequency,
    required this.routineIds,
    required this.createdAt,
    this.metadata = const {},
  });
}

enum TaskType { surah, verses, mixed, text }

@immutable
class SpiritualTask {
  final String id;
  final TaskType type;
  final TaskCategory category;
  final int defaultRepetitions;
  final Map<String, Object?> content; // composite payload (refs, text, etc.)
  final Map<String, String> notes; // lang -> note
  final Map<String, Object?> audioSettings;
  final Map<String, Object?> displaySettings;

  const SpiritualTask({
    required this.id,
    required this.type,
    required this.category,
    required this.defaultRepetitions,
    required this.content,
    this.notes = const {},
    this.audioSettings = const {},
    this.displaySettings = const {},
  });
}

@immutable
class TaskProgress {
  final String taskId;
  final int remainingRepetitions;
  final Duration elapsedTime;
  final (int wordIndex, int verseIndex) currentPosition;
  final DateTime lastUpdate;
  final String state; // active|paused|completed
  const TaskProgress({
    required this.taskId,
    required this.remainingRepetitions,
    required this.elapsedTime,
    required this.currentPosition,
    required this.lastUpdate,
    required this.state,
  });
}
