import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../assistant/assistant_providers.dart';
import '../../../assistant/direct_action.dart';
import '../../../core/providers.dart';
import '../../../core/time/current_day.dart';
import '../../../data/assistant/tool_executor.dart';
import '../../../domain/entities/planned_block.dart';
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

/// The selected day's blocks with their tasks, from one query (B21).
@riverpod
Stream<List<PlannedBlock>> dayPlan(Ref ref) {
  final date = ref.watch(selectedDateProvider);
  return ref.watch(scheduleRepositoryProvider).watchDayPlan(date);
}

/// How many open backlog tasks are shown; "Show more" raises it (B20).
@riverpod
class BacklogLimit extends _$BacklogLimit {
  static const pageSize = 50;

  @override
  int build() => pageSize;

  void showMore() => state += pageSize;
}

/// Open backlog tasks. Reads one past the limit, so the view knows
/// whether to offer "Show more" without a separate count query.
@riverpod
Stream<List<Task>> openBacklog(Ref ref) {
  final limit = ref.watch(backlogLimitProvider);
  return ref
      .watch(taskRepositoryProvider)
      .watchUnscheduledTasks(done: false, limit: limit + 1);
}

/// Whether completed backlog tasks are listed (collapsed by default).
@riverpod
class ShowCompletedBacklog extends _$ShowCompletedBacklog {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

@riverpod
Stream<int> completedBacklogCount(Ref ref) =>
    ref.watch(taskRepositoryProvider).watchUnscheduledDoneCount();

/// The most recent completed backlog tasks, when they're shown.
@riverpod
Stream<List<Task>> completedBacklog(Ref ref) => ref
    .watch(taskRepositoryProvider)
    .watchUnscheduledTasks(done: true, limit: BacklogLimit.pageSize);

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

  /// Completes a repeating task through `complete_task`, so it gets a
  /// ledger row and Undo puts back both its due time and the completion
  /// record. Returns the entry to undo and the next due time; null when
  /// the task changed underneath (it was already done).
  Future<({int entryId, DateTime? nextDue})?> completeRepeating(
      Task task) async {
    final result = await runDirectAction(
      registry: ref.read(toolRegistryProvider),
      executor: ref.read(toolExecutorProvider),
      tool: 'complete_task',
      args: {'task_id': task.id},
    );
    switch (result) {
      case Executed(:final entryId?):
        final next = await ref.read(taskRepositoryProvider).getTask(task.id);
        return (entryId: entryId, nextDue: next?.dueAt);
      case Failed(:final error):
        Error.throwWithStackTrace(error, StackTrace.current);
      case Executed() || Rejected():
        return null;
    }
  }

  Future<void> undoEntry(int entryId) =>
      ref.read(undoServiceProvider).undoEntry(entryId);

  Future<void> setStatus(int taskId, TaskStatus status) =>
      ref.read(taskRepositoryProvider).setTaskStatus(taskId, status);

  Future<void> setPriority(Task task, TaskPriority priority) => ref
      .read(taskRepositoryProvider)
      .updateTask(task.copyWith(priority: priority));

  Future<void> deleteTask(int taskId) {
    return ref.read(taskRepositoryProvider).deleteTask(taskId);
  }
}
