import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../../../core/time/current_day.dart';
import '../../../domain/entities/schedule_block.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/time/calendar_day.dart';

part 'today_view_model.g.dart';

/// The day shown on the Today tab. Follows [currentDayProvider], so it
/// moves to the new day at midnight instead of staying on yesterday.
@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => ref.watch(currentDayProvider);

  void goToToday() => state = ref.read(currentDayProvider);
  void nextDay() => state = addDays(state, 1);
  void previousDay() => state = addDays(state, -1);
}

@riverpod
Stream<List<Task>> tasksForBlock(Ref ref, int blockId) {
  return ref.watch(taskRepositoryProvider).watchTasksForBlock(blockId);
}

@riverpod
Stream<List<Task>> unscheduledTasks(Ref ref) {
  return ref.watch(taskRepositoryProvider).watchUnscheduledTasks();
}

@riverpod
Stream<List<ScheduleBlock>> scheduleBlocksForSelectedDate(Ref ref) {
  final date = ref.watch(selectedDateProvider);
  return ref.watch(scheduleRepositoryProvider).watchBlocksForDay(date);
}

/// Action surface for the Today screen. The View calls through here
/// rather than touching repositories directly, keeping the MVVM boundary
/// even though there's no separate state to hold beyond the streams
/// above — see the README for why a full Use Case layer isn't here yet.
// keepAlive (rule R11): an action surface whose methods use `ref` after
// an `await`. Auto-dispose would let it be disposed mid-action (the sheet
// or screen that called it closes), and Riverpod 3 throws on any use of a
// disposed Ref.
@Riverpod(keepAlive: true)
class TodayActions extends _$TodayActions {
  @override
  void build() {}

  /// Flips done/not done and returns the status it replaced, so the UI can
  /// offer Undo that restores exactly what was there (e.g. "in progress").
  Future<TaskStatus> toggleTaskDone(Task task) async {
    final next =
        task.status == TaskStatus.done ? TaskStatus.todo : TaskStatus.done;
    await ref.read(taskRepositoryProvider).setTaskStatus(task.id, next);
    return task.status;
  }

  Future<void> setStatus(int taskId, TaskStatus status) =>
      ref.read(taskRepositoryProvider).setTaskStatus(taskId, status);

  Future<void> setPriority(Task task, TaskPriority priority) => ref
      .read(taskRepositoryProvider)
      .updateTask(task.copyWith(priority: priority));

  Future<void> deleteTask(int taskId) {
    return ref.read(taskRepositoryProvider).deleteTask(taskId);
  }
}
