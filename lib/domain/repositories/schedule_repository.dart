import '../entities/schedule_block.dart';

abstract interface class ScheduleRepository {
  Stream<List<ScheduleBlock>> watchBlocksForDay(DateTime day);

  Future<int> createBlock({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
  });

  Future<void> updateBlock(ScheduleBlock block);
  Future<void> deleteBlock(int id);
}
