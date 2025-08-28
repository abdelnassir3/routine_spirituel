import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift; // ✅

import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';

class ProgressService {
  ProgressService(this._ref);
  final Ref _ref;

  Future<void> initProgressForSession(String sessionId,
      {String? startTaskId}) async {
    final sessionDao = _ref.read(sessionDaoProvider);
    final taskDao = _ref.read(taskDaoProvider);
    final progressDao = _ref.read(progressDaoProvider);

    // print('🔧 Initialisation des progressions pour session: $sessionId');

    final session = await sessionDao.getById(sessionId);
    if (session == null) {
      // print('❌ Session non trouvée: $sessionId');
      return;
    }

    // print('📋 Routine ID de la session: ${session.routineId}');

    final tasks = await (taskDao.select(taskDao.tasks)
          ..where((t) => t.routineId.equals(session.routineId))
          ..orderBy([(t) => drift.OrderingTerm.asc(t.orderIndex)]))
        .get();

    // print('📝 Nombre de tâches trouvées pour la routine: ${tasks.length}');
    for (final task in tasks) {
      // print('   - Tâche ${task.id}: ${task.notesFr ?? task.notesAr ?? "Sans nom"}');
    }

    // Supprimer les anciennes progressions pour cette session d'abord
    await progressDao.deleteBySession(sessionId);
    // print('🧹 Anciennes progressions supprimées');

    // Créer de nouvelles progressions
    bool foundStartTask = startTaskId ==
        null; // Si pas de tâche de départ spécifiée, commencer dès la première

    for (final t in tasks) {
      int reps;
      if (startTaskId != null) {
        if (!foundStartTask && t.id == startTaskId) {
          foundStartTask = true;
          reps = t.defaultReps; // Tâche de départ : répétitions normales
          // print('🎯 Tâche de départ trouvée: ${t.id}');
        } else if (!foundStartTask) {
          reps = 0; // Tâches précédentes : déjà "complétées"
          // print('⏭️ Tâche précédente marquée comme complétée: ${t.id}');
        } else {
          reps = t.defaultReps; // Tâches suivantes : répétitions normales
        }
      } else {
        reps = t
            .defaultReps; // Comportement normal : toutes les tâches avec répétitions
      }

      await progressDao.upsertProgress(TaskProgressCompanion.insert(
        id: _genId(),
        sessionId: sessionId,
        taskId: t.id,
        remainingReps: reps,
      ));
      // print('✅ Progression créée pour tâche ${t.id} avec $reps répétitions');
    }

    if (startTaskId != null && !foundStartTask) {
      // print('⚠️ Tâche de départ $startTaskId non trouvée dans la routine');
    }

    // print('✅ Toutes les progressions initialisées pour session: $sessionId');
  }

  Future<TaskProgressRow?> getCurrentProgress(String sessionId) async {
    final sessionDao = _ref.read(sessionDaoProvider);
    final taskDao = _ref.read(taskDaoProvider);
    final progressDao = _ref.read(progressDaoProvider);

    print('🔍 getCurrentProgress appelé pour session: $sessionId');

    final session = await sessionDao.getById(sessionId);
    if (session == null) {
      // print('❌ Session non trouvée: $sessionId');
      return null;
    }

    print('📋 Routine de la session: ${session.routineId}');

    final tasks = await (taskDao.select(taskDao.tasks)
          ..where((t) => t.routineId.equals(session.routineId))
          ..orderBy([(t) => drift.OrderingTerm.asc(t.orderIndex)]))
        .get();

    print('📝 ${tasks.length} tâches trouvées pour la routine');

    final progress = await progressDao.getBySession(sessionId);
    final progressMap = {for (final p in progress) p.taskId: p};

    print('📊 ${progress.length} progressions trouvées pour la session');

    for (final t in tasks) {
      final p = progressMap[t.id];
      if (p != null && p.remainingReps > 0) {
        print(
            '✅ Tâche active trouvée: ${t.id} avec ${p.remainingReps} répétitions restantes');
        return p;
      }
    }

    print('⚠️ Toutes les tâches sont terminées pour la session');
    // All tasks completed -> no current progress
    return null;
  }

  Future<int?> decrementCurrent(String sessionId) async {
    final current = await getCurrentProgress(sessionId);
    if (current == null) return null;

    final newVal = (current.remainingReps - 1).clamp(0, 1 << 31);
    final progressDao = _ref.read(progressDaoProvider);

    await (progressDao.update(progressDao.taskProgress)
          ..where((p) => p.id.equals(current.id)))
        .write(TaskProgressCompanion(
      remainingReps: drift.Value(newVal), // ✅
      lastUpdate: drift.Value(DateTime.now()), // ✅
    ));

    return newVal;
  }

  Future<int?> incrementCurrent(String sessionId, {int delta = 1}) async {
    final current = await getCurrentProgress(sessionId);
    if (current == null) return null;
    final progressDao = _ref.read(progressDaoProvider);
    final newVal = (current.remainingReps + delta).clamp(0, 1 << 31);
    await (progressDao.update(progressDao.taskProgress)
          ..where((p) => p.id.equals(current.id)))
        .write(TaskProgressCompanion(
      remainingReps: drift.Value(newVal),
      lastUpdate: drift.Value(DateTime.now()),
    ));
    return newVal;
  }

  Future<void> completeCurrent(String sessionId) async {
    final current = await getCurrentProgress(sessionId);
    if (current == null) return;
    final progressDao = _ref.read(progressDaoProvider);
    await (progressDao.update(progressDao.taskProgress)
          ..where((p) => p.id.equals(current.id)))
        .write(TaskProgressCompanion(
      remainingReps: const drift.Value(0),
      lastUpdate: drift.Value(DateTime.now()),
    ));
  }

  Future<void> advanceToNext(String sessionId) async {
    await completeCurrent(sessionId);
  }

  Future<void> advanceToPrevious(String sessionId) async {
    final sessionDao = _ref.read(sessionDaoProvider);
    final taskDao = _ref.read(taskDaoProvider);
    final progressDao = _ref.read(progressDaoProvider);

    final session = await sessionDao.getById(sessionId);
    if (session == null) return;

    // Obtenir toutes les tâches de la routine
    final tasks = await (taskDao.select(taskDao.tasks)
          ..where((t) => t.routineId.equals(session.routineId))
          ..orderBy([(t) => drift.OrderingTerm(expression: t.orderIndex)]))
        .get();

    // Obtenir tous les progrès de la session
    final progresses = await progressDao.getBySession(sessionId);
    final progressMap = {for (final p in progresses) p.taskId: p};

    // Trouver la tâche actuelle
    int currentIndex = -1;
    for (int i = 0; i < tasks.length; i++) {
      final progress = progressMap[tasks[i].id];
      if (progress != null && progress.remainingReps > 0) {
        currentIndex = i;
        break;
      }
    }

    // Si on peut revenir en arrière
    if (currentIndex > 0) {
      // Réinitialiser la tâche précédente
      final previousTask = tasks[currentIndex - 1];
      await progressDao.upsertProgress(TaskProgressCompanion(
        id: drift.Value(progressMap[previousTask.id]?.id ?? _genId()),
        sessionId: drift.Value(sessionId),
        taskId: drift.Value(previousTask.id),
        remainingReps: drift.Value(previousTask.defaultReps),
        lastUpdate: drift.Value(DateTime.now()),
      ));
    }
  }

  Future<void> resetSession(String sessionId) async {
    final sessionDao = _ref.read(sessionDaoProvider);
    final taskDao = _ref.read(taskDaoProvider);
    final progressDao = _ref.read(progressDaoProvider);

    final session = await sessionDao.getById(sessionId);
    if (session == null) return;
    final tasks = await (taskDao.select(taskDao.tasks)
          ..where((t) => t.routineId.equals(session.routineId)))
        .get();
    for (final t in tasks) {
      await progressDao.upsertProgress(TaskProgressCompanion(
        id: drift.Value(_genId()),
        sessionId: drift.Value(sessionId),
        taskId: drift.Value(t.id),
        remainingReps: drift.Value(t.defaultReps),
        lastUpdate: drift.Value(DateTime.now()),
      ));
    }
  }

  /// Supprimer tous les progrès d'une session
  Future<void> clearProgressForSession(String sessionId) async {
    final progressDao = _ref.read(progressDaoProvider);
    await progressDao.deleteBySession(sessionId);
  }

  String _genId() => DateTime.now().microsecondsSinceEpoch.toString();
}

final progressServiceProvider =
    Provider<ProgressService>((ref) => ProgressService(ref));
