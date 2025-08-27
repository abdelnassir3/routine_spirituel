import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:spiritual_routines/core/persistence/dao_providers.dart';
import 'package:spiritual_routines/core/persistence/drift_schema.dart';

final progressListProvider =
    StreamProvider.family<List<TaskProgressRow>, String>((ref, sessionId) {
  final progressDao = ref.watch(progressDaoProvider);
  return progressDao.watchBySession(sessionId);
});

final sessionRowProvider =
    FutureProvider.family<SessionRow?, String>((ref, sessionId) async {
  final sessionDao = ref.read(sessionDaoProvider);
  return sessionDao.getById(sessionId);
});

final tasksByRoutineProvider =
    StreamProvider.family<List<TaskRow>, String>((ref, routineId) {
  final taskDao = ref.watch(taskDaoProvider);
  return taskDao.watchByRoutine(routineId);
});

final taskRowProvider =
    FutureProvider.family<TaskRow?, String>((ref, taskId) async {
  final taskDao = ref.read(taskDaoProvider);
  return await taskDao.getById(taskId);
});

final currentProgressProvider =
    StreamProvider.family<TaskProgressRow?, String>((ref, sessionId) async* {
  final session = await ref.watch(sessionRowProvider(sessionId).future);
  if (session == null) {
    yield null;
    return;
  }

  // Fetch tasks once to establish the intended order
  final tasks =
      await ref.watch(tasksByRoutineProvider(session.routineId).stream).first;
  final progressStream = ref.watch(progressListProvider(sessionId).stream);

  await for (final progress in progressStream) {
    final map = {for (final p in progress) p.taskId: p};
    TaskProgressRow? current;

    // Chercher d'abord une tâche avec des répétitions restantes
    for (final t in tasks) {
      final p = map[t.id];
      if (p != null && p.remainingReps > 0) {
        current = p;
        break;
      }
    }

    // Si aucune tâche n'a de répétitions restantes, prendre la première tâche
    // pour permettre la lecture même après la fin de session
    if (current == null && tasks.isNotEmpty) {
      final firstTaskId = tasks.first.id;
      current = map[firstTaskId];
    }

    yield current;
  }
});
