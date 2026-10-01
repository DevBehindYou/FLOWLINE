import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
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
@riverpod
class TodayActions extends _$TodayActions {
  @override
  void build() {}

  Future<void> toggleTaskDone(Task task) {
    final next =
        task.status == TaskStatus.done ? TaskStatus.todo : TaskStatus.done;
    return ref.read(taskRepositoryProvider).setTaskStatus(task.id, next);
  }

  Future<void> deleteTask(int taskId) {
    return ref.read(taskRepositoryProvider).deleteTask(taskId);
  }
}
