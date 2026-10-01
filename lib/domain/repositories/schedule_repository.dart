import '../entities/planned_block.dart';
import '../entities/schedule_block.dart';

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

  Future<int> createBlock({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
  });

  Future<void> updateBlock(ScheduleBlock block);
  Future<void> deleteBlock(int id);
}
