import '../entities/subtask.dart';
import '../entities/task.dart';
import '../recurrence/recurrence_rule.dart';

/// Contract for task + subtask persistence. The implementation
/// (`TaskRepositoryImpl`, backed by Drift) lives in `data/repositories/` —
/// nothing above this layer knows or cares that it's SQLite underneath.
abstract interface class TaskRepository {
  Stream<List<Task>> watchTasksForBlock(int scheduleBlockId);

  /// Tasks in no block (the backlog), at most [limit]. Open tasks oldest
  /// first, or with [done] the completed ones newest first, so the list
  /// doesn't grow forever with finished work (B20).
  Stream<List<Task>> watchUnscheduledTasks({
    required bool done,
    required int limit,
  });

  /// How many completed tasks are in the backlog.
  Stream<int> watchUnscheduledDoneCount();
  Stream<Task?> watchTask(int id);
  Stream<List<Subtask>> watchSubtasks(int taskId);

  // One-shot reads (the assistant's tools validate against these; a watch
  // stream's `.first` never completes under the widget tester's clock).
  Future<Task?> getTask(int id);
  Future<List<Subtask>> getSubtasks(int taskId);
  Future<List<Task>> getTasksForBlock(int scheduleBlockId);

  /// Tasks whose title contains [query] (case-insensitive; every task when
  /// empty), not done unless [includeDone], at most [limit], oldest first.
  Future<List<Task>> findTasks(String query,
      {bool includeDone = false, int limit = 20});

  Future<int> createTask({
    required String title,
    String notes = '',
    required TaskPriority priority,
    int? scheduleBlockId,
    DateTime? dueAt,
    RecurrenceRule? repeat,
  });

  Future<void> updateTask(Task task);

  /// Marks [id] done. A repeating task instead stays open with its due
  /// time moved to the next occurrence after [now], and a done copy is
  /// added as the record of this completion; its id is returned (null
  /// for a task that doesn't repeat). One transaction.
  Future<int?> completeTask(int id, {required DateTime now});
  Future<void> deleteTask(int id);
  Future<void> setTaskStatus(int id, TaskStatus status);

  Future<int> createSubtask({
    required int taskId,
    required String title,
    int plannedSprints = 1,
  });
  Future<void> setSubtaskStatus(int id, SubtaskStatus status);

  /// Puts [taskId]'s subtasks in the order of [subtaskIds].
  Future<void> reorderSubtasks(int taskId, List<int> subtaskIds);
  Future<void> deleteSubtask(int id);

  /// Called by the Focus Timer when a full (not ended-early) focus
  /// session linked to this subtask completes.
  Future<void> incrementSubtaskCompletedSprints(int subtaskId);
}
