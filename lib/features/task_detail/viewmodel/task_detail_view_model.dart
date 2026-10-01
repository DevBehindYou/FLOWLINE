import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/focus_session.dart';
import '../../../domain/entities/subtask.dart';
import '../../../domain/entities/task.dart';

part 'task_detail_view_model.g.dart';

@riverpod
Stream<Task?> taskById(Ref ref, int taskId) {
  return ref.watch(taskRepositoryProvider).watchTask(taskId);
}

@riverpod
Stream<List<FocusSession>> sessionsForTask(Ref ref, int taskId) {
  return ref.watch(focusSessionRepositoryProvider).watchSessionsForTask(taskId);
}

@riverpod
Stream<List<Subtask>> subtasksForTask(Ref ref, int taskId) {
  return ref.watch(taskRepositoryProvider).watchSubtasks(taskId);
}

// keepAlive (rule R11): an action surface whose methods use `ref` after
// an `await`. Auto-dispose would let it be disposed mid-action (the sheet
// or screen that called it closes), and Riverpod 3 throws on any use of a
// disposed Ref.
@Riverpod(keepAlive: true)
class TaskDetailActions extends _$TaskDetailActions {
  @override
  void build() {}

  Future<void> addSubtask(int taskId, String title) {
    return ref
        .read(taskRepositoryProvider)
        .createSubtask(taskId: taskId, title: title);
  }

  Future<void> toggleSubtask(Subtask subtask) {
    final next = subtask.status == SubtaskStatus.done
        ? SubtaskStatus.todo
        : SubtaskStatus.done;
    return ref.read(taskRepositoryProvider).setSubtaskStatus(subtask.id, next);
  }

  Future<void> reorderSubtasks(int taskId, List<int> subtaskIds) =>
      ref.read(taskRepositoryProvider).reorderSubtasks(taskId, subtaskIds);

  Future<void> deleteSubtask(int id) {
    return ref.read(taskRepositoryProvider).deleteSubtask(id);
  }

  Future<void> deleteTask(int id) {
    return ref.read(taskRepositoryProvider).deleteTask(id);
  }
}
