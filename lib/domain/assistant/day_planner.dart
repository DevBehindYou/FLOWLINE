import '../entities/schedule_block.dart';
import '../entities/task.dart';
import '../services/free_time.dart';
import '../time/calendar_day.dart';

// Plan my day (docs/05 §12.3): fit the backlog into today's free time.
// Pure; the result is a preview, and APPLY runs `schedule_task` for each
// item in one ledger group, so one UNDO takes the whole plan back.

/// One task placed in a slot.
typedef PlannedTask = ({Task task, DateTime start, int minutes});

final class DayPlanRules {
  const DayPlanRules({
    this.dayStartHour = 9,
    this.dayEndHour = 18,
    this.defaultMinutes = 30,
    this.minMinutes = 25,
    this.bufferAfterBlockMinutes = 10,
    this.maxTasks = 8,
  });

  final int dayStartHour;
  final int dayEndHour;

  /// Tasks keep no estimate yet: each gets this much.
  final int defaultMinutes;

  /// A gap shorter than this is never used.
  final int minMinutes;

  /// Room left after each existing block (a meeting runs over, a break).
  final int bufferAfterBlockMinutes;
  final int maxTasks;
}

/// Places open tasks with no block, most urgent first (due soonest, then
/// priority, then oldest), each in the first free gap that fits it, from
/// the next quarter hour to the end of the working day. A task due before
/// the gap would end is skipped, unless it is already overdue.
List<PlannedTask> planDay({
  required DateTime now,
  required List<Task> tasks,
  required List<ScheduleBlock> blocks,
  DayPlanRules rules = const DayPlanRules(),
}) {
  final day = startOfDay(now);
  final end = DateTime(day.year, day.month, day.day, rules.dayEndHour);
  var from = DateTime(day.year, day.month, day.day, rules.dayStartHour);
  if (now.isAfter(from)) {
    final q = now.add(Duration(minutes: 15 - now.minute % 15));
    from = DateTime(q.year, q.month, q.day, q.hour, q.minute);
  }
  if (!end.isAfter(from)) return const [];

  final candidates = [
    for (final t in tasks)
      if (t.status != TaskStatus.done && t.scheduleBlockId == null) t,
  ]..sort(_urgency);

  // Existing blocks, each with its buffer; planned items join them.
  final busy = <ScheduleBlock>[
    for (final b in blocks)
      ScheduleBlock(
        id: b.id,
        title: b.title,
        startTime: b.startTime,
        endTime:
            b.endTime.add(Duration(minutes: rules.bufferAfterBlockMinutes)),
      ),
  ];
  final plan = <PlannedTask>[];
  for (final t in candidates) {
    if (plan.length >= rules.maxTasks) break;
    final minutes = rules.defaultMinutes < rules.minMinutes
        ? rules.minMinutes
        : rules.defaultMinutes;
    final slot = findFreeSlots(
            blocks: busy, from: from, to: end, minutes: minutes, limit: 1)
        .firstOrNull;
    if (slot == null) break;
    final finish = slot.start.add(Duration(minutes: minutes));
    final due = t.dueAt;
    if (due != null && due.isAfter(now) && finish.isAfter(due)) continue;
    plan.add((task: t, start: slot.start, minutes: minutes));
    busy.add(ScheduleBlock(
        id: -1 - plan.length,
        title: t.title,
        startTime: slot.start,
        endTime: finish));
  }
  return plan;
}

int _urgency(Task a, Task b) {
  final ad = a.dueAt, bd = b.dueAt;
  if (ad != null && bd != null && ad != bd) return ad.compareTo(bd);
  if (ad != null && bd == null) return -1;
  if (ad == null && bd != null) return 1;
  final p = b.priority.index.compareTo(a.priority.index);
  if (p != 0) return p;
  final c = a.createdAt.compareTo(b.createdAt);
  return c != 0 ? c : a.id.compareTo(b.id);
}
