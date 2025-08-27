import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';

final themeDaoProvider = Provider<ThemeDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ThemeDao(db);
});

final routineDaoProvider = Provider<RoutineDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return RoutineDao(db);
});

final taskDaoProvider = Provider<TaskDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TaskDao(db);
});

final sessionDaoProvider = Provider<SessionDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SessionDao(db);
});

final progressDaoProvider = Provider<ProgressDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProgressDao(db);
});

final snapshotDaoProvider = Provider<SnapshotDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SnapshotDao(db);
});

final userSettingsDaoProvider = Provider<UserSettingsDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return UserSettingsDao(db);
});
