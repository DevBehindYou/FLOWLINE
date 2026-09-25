import '../entities/subtask.dart';
import '../entities/task.dart';

/// Contract for task + subtask persistence. The implementation
/// (`TaskRepositoryImpl`, backed by Drift) lives in `data/repositories/` —
/// nothing above this layer knows or cares that it's SQLite underneath.
abstract interface class TaskRepository {
  Stream<List<Task>> watchTasksForBlock(int scheduleBlockId);
  Stream<List<Task>> watchUnscheduledTasks();
  Stream<Task?> watchTask(int id);
  Stream<List<Subtask>> watchSubtasks(int taskId);

  Future<int> createTask({
    required String title,
    String notes = '',
    required TaskPriority priority,
    int? scheduleBlockId,
    DateTime? dueAt,
  });

  Future<void> updateTask(Task task);
  Future<void> deleteTask(int id);
  Future<void> setTaskStatus(int id, TaskStatus status);

  Future<int> createSubtask({
    required int taskId,
    required String title,
    int plannedSprints = 1,
  });
  Future<void> setSubtaskStatus(int id, SubtaskStatus status);
  Future<void> deleteSubtask(int id);

  /// Called by the Focus Timer when a full (not ended-early) focus
  /// session linked to this subtask completes.
  Future<void> incrementSubtaskCompletedSprints(int subtaskId);
}
