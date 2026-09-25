import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/subtask.dart';
import '../../../domain/entities/task.dart';

part 'task_detail_view_model.g.dart';

@riverpod
Stream<Task?> taskById(Ref ref, int taskId) {
  return ref.watch(taskRepositoryProvider).watchTask(taskId);
}

@riverpod
Stream<List<Subtask>> subtasksForTask(Ref ref, int taskId) {
  return ref.watch(taskRepositoryProvider).watchSubtasks(taskId);
}

@riverpod
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

  Future<void> deleteSubtask(int id) {
    return ref.read(taskRepositoryProvider).deleteSubtask(id);
  }

  Future<void> deleteTask(int id) {
    return ref.read(taskRepositoryProvider).deleteTask(id);
  }
}
