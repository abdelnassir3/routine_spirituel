import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import conditionnel pour supporter Web et Native
import 'package:spiritual_routines/core/persistence/drift_native.dart'
    if (dart.library.html) 'drift_web.dart' as impl;

part 'drift_schema.g.dart';

// Generic JSON <-> TEXT converter
class JsonTextConverter extends TypeConverter<Map<String, dynamic>, String> {
  const JsonTextConverter();
  @override
  Map<String, dynamic> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb);
    if (decoded is Map<String, dynamic>) return decoded;
    return Map<String, dynamic>.from(decoded as Map);
  }

  @override
  String toSql(Map<String, dynamic> value) => jsonEncode(value);
}

// Tables
@DataClassName('ThemeRow')
class Themes extends Table {
  TextColumn get id => text()();
  TextColumn get nameFr => text()();
  TextColumn get nameAr => text()();
  TextColumn get frequency => text()(); // daily|weekly|monthly
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get metadata =>
      text().withDefault(const Constant('{}'))(); // JSON string

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RoutineRow')
class Routines extends Table {
  TextColumn get id => text()();
  TextColumn get themeId => text().references(Themes, #id)();
  TextColumn get nameFr => text()();
  TextColumn get nameAr => text()();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TaskRow')
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get routineId => text().references(Routines, #id)();
  TextColumn get type => text()(); // surah|verses|mixed|text
  TextColumn get category => text()();
  IntColumn get defaultReps => integer().withDefault(const Constant(1))();
  // JSON blobs
  TextColumn get audioSettings => text().withDefault(const Constant('{}'))();
  TextColumn get displaySettings => text().withDefault(const Constant('{}'))();
  // reference to Isar content id (string)
  TextColumn get contentId => text().nullable()();
  TextColumn get notesFr => text().nullable()();
  TextColumn get notesAr => text().nullable()();

  IntColumn get orderIndex => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SessionRow')
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get routineId => text().references(Routines, #id)();
  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get state =>
      text().withDefault(const Constant('active'))(); // active|paused|completed
  TextColumn get snapshotRef => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TaskProgressRow')
class TaskProgress extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(Sessions, #id)();
  TextColumn get taskId => text().references(Tasks, #id)();
  IntColumn get remainingReps => integer()();
  IntColumn get elapsedMs => integer().withDefault(const Constant(0))();
  IntColumn get wordIndex => integer().withDefault(const Constant(0))();
  IntColumn get verseIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastUpdate => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SnapshotRow')
class Snapshots extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(Sessions, #id)();
  TextColumn get payload => text()(); // JSON string
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('UserSettingsRow')
class UserSettings extends Table {
  TextColumn get id => text()(); // could be a fixed key per user
  TextColumn get userId => text().nullable()();
  TextColumn get language => text().withDefault(const Constant('fr'))();
  BoolColumn get rtlPref => boolean().withDefault(const Constant(false))();
  TextColumn get fontPrefs => text().withDefault(const Constant('{}'))();
  TextColumn get ttsVoice => text().nullable()();
  RealColumn get speed => real().withDefault(const Constant(1.0))();
  BoolColumn get haptics => boolean().withDefault(const Constant(true))();
  BoolColumn get notifications => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

// Database
@DriftDatabase(tables: [
  Themes,
  Routines,
  Tasks,
  Sessions,
  TaskProgress,
  Snapshots,
  UserSettings,
], daos: [
  ThemeDao,
  RoutineDao,
  TaskDao,
  SessionDao,
  ProgressDao,
  SnapshotDao,
  UserSettingsDao,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.openConnection());

  @override
  int get schemaVersion => 1;
}

// Riverpod provider for DB lifecycle
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// DAOs
@DriftAccessor(tables: [Themes])
class ThemeDao extends DatabaseAccessor<AppDatabase> with _$ThemeDaoMixin {
  ThemeDao(super.db);

  Future<void> upsertTheme(ThemesCompanion entry) async {
    await into(themes).insertOnConflictUpdate(entry);
  }

  Future<List<ThemeRow>> all() => select(themes).get();

  Stream<List<ThemeRow>> watchAll() => select(themes).watch();

  Future<int> deleteById(String id) =>
      (delete(themes)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [Routines, Themes])
class RoutineDao extends DatabaseAccessor<AppDatabase> with _$RoutineDaoMixin {
  RoutineDao(super.db);

  Future<void> upsertRoutine(RoutinesCompanion entry) =>
      into(routines).insertOnConflictUpdate(entry);

  Stream<List<RoutineRow>> watchByTheme(String themeId) {
    final q = (select(routines)
      ..where((r) => r.themeId.equals(themeId))
      ..orderBy([(r) => OrderingTerm.asc(r.orderIndex)]));
    return q.watch();
  }

  Stream<List<RoutineRow>> watchAll() {
    final q =
        (select(routines)..orderBy([(r) => OrderingTerm.asc(r.orderIndex)]));
    return q.watch();
  }

  Future<int> deleteById(String id) =>
      (delete(routines)..where((r) => r.id.equals(id))).go();

  Future<int> reassignTheme(String fromThemeId, String toThemeId) async {
    return (update(routines)..where((r) => r.themeId.equals(fromThemeId)))
        .write(RoutinesCompanion(themeId: Value(toThemeId)));
  }

  Future<void> updateOrder(String routineId, int order) async {
    await (update(routines)..where((r) => r.id.equals(routineId)))
        .write(RoutinesCompanion(orderIndex: Value(order)));
  }
}

@DriftAccessor(tables: [Tasks, Routines])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  Future<void> upsertTask(TasksCompanion entry) =>
      into(tasks).insertOnConflictUpdate(entry);

  Stream<List<TaskRow>> watchByRoutine(String routineId) {
    final q = (select(tasks)
      ..where((t) => t.routineId.equals(routineId))
      ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]));
    return q.watch();
  }

  Stream<List<TaskRow>> watchByCategory(String categoryLabel) =>
      (select(tasks)..where((t) => t.category.equals(categoryLabel))).watch();

  Future<int> deleteById(String id) =>
      (delete(tasks)..where((t) => t.id.equals(id))).go();

  Future<TaskRow?> getById(String id) =>
      (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> updateOrder(String taskId, int order) async {
    await (update(tasks)..where((t) => t.id.equals(taskId)))
        .write(TasksCompanion(orderIndex: Value(order)));
  }
}

@DriftAccessor(tables: [Sessions, Routines])
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(super.db);

  Future<void> upsertSession(SessionsCompanion entry) =>
      into(sessions).insertOnConflictUpdate(entry);

  Future<SessionRow?> activeForRoutine(String routineId) {
    final q = (select(sessions)
      ..where((s) => s.routineId.equals(routineId) & s.state.equals('active'))
      ..orderBy([(s) => OrderingTerm.desc(s.startedAt)])
      ..limit(1));
    return q.getSingleOrNull();
  }

  Future<void> closeSession(String id) async {
    await (update(sessions)..where((s) => s.id.equals(id))).write(
        SessionsCompanion(
            endedAt: Value(DateTime.now()), state: const Value('paused')));
  }

  Future<SessionRow?> latestAnyActiveOrPaused() {
    final q = (select(sessions)
      ..where((s) => s.state.isIn(['active', 'paused']))
      ..orderBy([(s) => OrderingTerm.desc(s.startedAt)])
      ..limit(1));
    return q.getSingleOrNull();
  }

  Future<SessionRow?> getById(String id) =>
      (select(sessions)..where((s) => s.id.equals(id))).getSingleOrNull();

  /// Récupère toutes les sessions complétées pour une routine donnée
  Future<List<SessionRow>> getCompletedSessionsForRoutine(String routineId) {
    final q = (select(sessions)
      ..where(
          (s) => s.routineId.equals(routineId) & s.state.equals('completed'))
      ..orderBy([(s) => OrderingTerm.desc(s.endedAt)]));
    return q.get();
  }

  /// Récupère toutes les sessions pour une routine donnée
  Future<List<SessionRow>> getAllByRoutine(String routineId) {
    final q = (select(sessions)
      ..where((s) => s.routineId.equals(routineId))
      ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]));
    return q.get();
  }
}

@DriftAccessor(tables: [TaskProgress])
class ProgressDao extends DatabaseAccessor<AppDatabase>
    with _$ProgressDaoMixin {
  ProgressDao(super.db);

  Future<void> upsertProgress(TaskProgressCompanion entry) =>
      into(taskProgress).insertOnConflictUpdate(entry);

  Stream<List<TaskProgressRow>> watchBySession(String sessionId) =>
      (select(taskProgress)..where((p) => p.sessionId.equals(sessionId)))
          .watch();

  Future<List<TaskProgressRow>> getBySession(String sessionId) =>
      (select(taskProgress)..where((p) => p.sessionId.equals(sessionId))).get();

  Future<int> deleteBySession(String sessionId) =>
      (delete(taskProgress)..where((p) => p.sessionId.equals(sessionId))).go();
}

@DriftAccessor(tables: [Snapshots])
class SnapshotDao extends DatabaseAccessor<AppDatabase>
    with _$SnapshotDaoMixin {
  SnapshotDao(super.db);

  Future<void> addSnapshot(SnapshotsCompanion entry) =>
      into(snapshots).insert(entry);

  Future<SnapshotRow?> latestForSession(String sessionId) {
    final q = (select(snapshots)
      ..where((s) => s.sessionId.equals(sessionId))
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
      ..limit(1));
    return q.getSingleOrNull();
  }

  Future<SnapshotRow?> latest() {
    final q = (select(snapshots)
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
      ..limit(1));
    return q.getSingleOrNull();
  }
}

@DriftAccessor(tables: [UserSettings])
class UserSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$UserSettingsDaoMixin {
  UserSettingsDao(super.db);

  Future<UserSettingsRow?> getById(String id) =>
      (select(userSettings)..where((u) => u.id.equals(id))).getSingleOrNull();

  Future<void> upsert(UserSettingsCompanion entry) =>
      into(userSettings).insertOnConflictUpdate(entry);
}
