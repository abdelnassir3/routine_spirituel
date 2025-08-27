import 'package:spiritual_routines/core/models/routine_models.dart';
import 'package:spiritual_routines/core/models/task_category.dart';

abstract class TaskRepository {
  Future<SpiritualTask> getTask(String id);
  Stream<List<SpiritualTask>> watchTasksByCategory(TaskCategory category);
  Future<void> saveTask(SpiritualTask task);
  Future<void> syncWithRemote();
}
