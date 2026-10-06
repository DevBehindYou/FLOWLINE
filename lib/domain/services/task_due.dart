import 'package:clock/clock.dart';

import '../entities/task.dart';
import '../time/calendar_day.dart';

/// How a task's due date should read right now. Pure, so the overdue
/// rule is unit-tested rather than buried in a widget.
enum DueState { none, overdue, dueToday, upcoming }

DueState dueStateOf(Task task, {DateTime? now}) {
  final due = task.dueAt;
  if (due == null || task.status == TaskStatus.done) return DueState.none;
  final at = now ?? clock.now();
  if (due.isBefore(at)) return DueState.overdue;
  if (isSameDay(due, at)) return DueState.dueToday;
  return DueState.upcoming;
}
