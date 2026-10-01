import '../entities/planned_block.dart';
import '../entities/schedule_block.dart';
import '../recurrence/recurrence_rule.dart';

abstract interface class ScheduleRepository {
  /// Every block that overlaps [day] (including one that started the
  /// evening before and runs past midnight), ordered by start time.
  Stream<List<ScheduleBlock>> watchBlocksForDay(DateTime day);

  /// One-shot read of the same set as [watchBlocksForDay]. Use this, not
  /// `watchBlocksForDay(day).first`, for a single read: it doesn't open a
  /// live query (and a watch stream's `.first` never completes under the
  /// widget tester's fake clock).
  Future<List<ScheduleBlock>> getBlocksForDay(DateTime day);

  /// The same blocks as [watchBlocksForDay], each with its tasks, from a
  /// single live query (the Today timeline).
  Stream<List<PlannedBlock>> watchDayPlan(DateTime day);

  /// A stored row by id (a plain block, a series or a stored
  /// occurrence), or null.
  Future<ScheduleBlock?> getBlock(int id);

  /// With [recurrence], a series whose first day is [startTime]'s.
  Future<int> createBlock({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    RecurrenceRule? recurrence,
  });

  /// The row id for [blockId]: itself for a stored row; for a computed
  /// occurrence (negative id), the row it is stored as, created on first
  /// use. Do this before attaching tasks to an occurrence.
  Future<int> storeOccurrence(int blockId);

  /// A plain block, one occurrence (stored first if computed), or a series
  /// template (title, times and rule).
  Future<void> updateBlock(ScheduleBlock block);

  /// A plain block, or one occurrence of a series (the series skips that
  /// day from then on). Its tasks become unscheduled.
  Future<void> deleteBlock(int id);

  /// Ends [occurrence]'s series the day before it ("this and all
  /// following"); from the series' first day, deletes the series.
  Future<void> endSeriesAt(ScheduleBlock occurrence);
}
