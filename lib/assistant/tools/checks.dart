import '../../domain/assistant/ledger.dart';
import '../../domain/assistant/tool.dart';
import '../../domain/services/schedule_conflict_checker.dart';
import '../../domain/time/calendar_day.dart';

/// "Now" requests ("start a block now") arrive a few seconds late; only
/// a time more than a minute ago counts as past.
bool isPast(DateTime t, DateTime now) =>
    t.isBefore(now.subtract(const Duration(minutes: 1)));

/// The longest block or session a tool creates: a day.
const maxBlockMinutes = 24 * 60;

/// Checks a new time range against the schedule as it is now (R16):
/// order, not in the past, at most a day long, no overlap with any block
/// except [excludeBlockId] (locked external blocks included).
Future<Invalid?> checkTimeRange(
  ToolEnv env,
  DateTime start,
  DateTime end, {
  int? excludeBlockId,
}) async {
  if (!end.isAfter(start)) {
    return const Invalid(InvalidReason.endBeforeStart, 'end');
  }
  if (isPast(start, env.now)) {
    return const Invalid(InvalidReason.inPast, 'start');
  }
  if (end.difference(start).inMinutes > maxBlockMinutes) {
    return const Invalid(InvalidReason.outOfRange, 'at most 24 hours');
  }
  final blocks = [
    ...await env.schedule.getBlocksForDay(start),
    if (!isSameDay(start, end)) ...await env.schedule.getBlocksForDay(end),
  ];
  final conflicts = const ScheduleConflictChecker().findConflicts(
    startTime: start,
    endTime: end,
    existingBlocks: blocks,
    excludeBlockId: excludeBlockId,
  );
  if (conflicts.isEmpty) return null;
  final c = conflicts.first;
  return Invalid(InvalidReason.conflict, '${c.id}: ${c.title}');
}

/// The undo for an update: the columns that changed between [before] and
/// [after] (stored rows of the same id). Null when nothing changed.
RestoreFields? fieldsUndo(UndoTable table, int id, Map<String, Object?> before,
    Map<String, Object?> after) {
  final changed = [
    for (final key in after.keys)
      if (before[key] != after[key]) key,
  ];
  if (changed.isEmpty) return null;
  return RestoreFields(
    table,
    id,
    before: {for (final k in changed) k: before[k]},
    after: {for (final k in changed) k: after[k]},
  );
}

/// The stored row, or a [StateError]: a tool only asks for rows it just
/// validated or wrote in the same transaction.
Future<Map<String, Object?>> mustRow(
    ToolEnv env, UndoTable table, int id) async {
  final row = await env.storedRow(table, id);
  if (row == null) throw StateError('No ${table.name} row $id');
  return row;
}
