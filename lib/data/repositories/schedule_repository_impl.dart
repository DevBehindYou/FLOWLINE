import 'package:drift/drift.dart';

import '../../domain/entities/schedule_block.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../local/drift/app_database.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  ScheduleRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<ScheduleBlock>> watchBlocksForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final query = _db.select(_db.scheduleBlocks)
      ..where((b) =>
          b.startTime.isBiggerOrEqualValue(start) &
          b.startTime.isSmallerThanValue(end))
      ..orderBy([(b) => OrderingTerm.asc(b.startTime)]);
    return query.watch().map((rows) => rows.map(_mapBlock).toList());
  }

  @override
  Future<int> createBlock({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return _db.into(_db.scheduleBlocks).insert(
          ScheduleBlocksCompanion.insert(
            title: title,
            startTime: startTime,
            endTime: endTime,
          ),
        );
  }

  @override
  Future<void> updateBlock(ScheduleBlock block) {
    return (_db.update(_db.scheduleBlocks)..where((b) => b.id.equals(block.id)))
        .write(
      ScheduleBlocksCompanion(
        title: Value(block.title),
        startTime: Value(block.startTime),
        endTime: Value(block.endTime),
      ),
    );
  }

  // Tasks.scheduleBlockId is a plain column, not a foreign key, so nothing
  // else would clear it: a task left pointing at a deleted block is in no
  // block and not "unscheduled" either, so it silently vanishes from Today.
  @override
  Future<void> deleteBlock(int id) {
    return _db.transaction(() async {
      await (_db.update(_db.tasks)..where((t) => t.scheduleBlockId.equals(id)))
          .write(const TasksCompanion(scheduleBlockId: Value(null)));
      await (_db.delete(_db.scheduleBlocks)..where((b) => b.id.equals(id)))
          .go();
    });
  }

  ScheduleBlock _mapBlock(ScheduleBlockRow row) {
    return ScheduleBlock(
      id: row.id,
      title: row.title,
      startTime: row.startTime,
      endTime: row.endTime,
      source: row.source,
      isLocked: row.isLocked,
    );
  }
}
