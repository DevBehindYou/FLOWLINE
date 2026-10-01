import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/task.dart';

part 'add_edit_task_view_model.g.dart';

// keepAlive (rule R11): an action surface whose methods use `ref` after
// an `await`. Auto-dispose would let it be disposed mid-action (the sheet
// or screen that called it closes), and Riverpod 3 throws on any use of a
// disposed Ref.
@Riverpod(keepAlive: true)
class AddEditTaskViewModel extends _$AddEditTaskViewModel {
  @override
  void build() {}

  Future<void> createTask({
    required String title,
    required String notes,
    required TaskPriority priority,
    int? scheduleBlockId,
  }) {
    return ref.read(taskRepositoryProvider).createTask(
          title: title,
          notes: notes,
          priority: priority,
          scheduleBlockId: scheduleBlockId,
        );
  }

  Future<void> updateTask(Task task) {
    return ref.read(taskRepositoryProvider).updateTask(task);
  }
}
