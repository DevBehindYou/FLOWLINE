import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/recurrence/recurrence_rule.dart';

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
    DateTime? dueAt,
    RecurrenceRule? repeat,
  }) async {
    final blockId = await _storedBlockId(scheduleBlockId);
    await ref.read(taskRepositoryProvider).createTask(
          title: title,
          notes: notes,
          priority: priority,
          scheduleBlockId: blockId,
          dueAt: dueAt,
          repeat: repeat,
        );
  }

  Future<void> updateTask(Task task) async {
    final blockId = await _storedBlockId(task.scheduleBlockId);
    await ref
        .read(taskRepositoryProvider)
        .updateTask(task.copyWith(scheduleBlockId: () => blockId));
  }

  /// A task can be put in a computed occurrence of a repeating block (a
  /// negative stand-in id); the occurrence gets its own row first, so the
  /// foreign key has something to point at.
  Future<int?> _storedBlockId(int? blockId) async => blockId == null
      ? null
      : ref.read(scheduleRepositoryProvider).storeOccurrence(blockId);

  Future<void> deleteTask(int id) {
    return ref.read(taskRepositoryProvider).deleteTask(id);
  }
}
