import '../entities/schedule_block.dart';

abstract interface class ScheduleRepository {
  /// Every block that overlaps [day] (including one that started the
  /// evening before and runs past midnight), ordered by start time.
  Stream<List<ScheduleBlock>> watchBlocksForDay(DateTime day);

  Future<int> createBlock({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
  });

  Future<void> updateBlock(ScheduleBlock block);
  Future<void> deleteBlock(int id);
}
