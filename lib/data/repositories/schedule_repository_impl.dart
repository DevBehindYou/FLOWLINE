import 'package:drift/drift.dart';

import '../../domain/entities/planned_block.dart';
import '../../domain/entities/schedule_block.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../domain/time/calendar_day.dart';
import '../local/drift/app_database.dart';
import 'row_mappers.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  ScheduleRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<ScheduleBlock>> watchBlocksForDay(DateTime day) =>
      _blocksForDay(day).watch().map((rows) => rows.map(_mapBlock).toList());

  @override
  Future<List<ScheduleBlock>> getBlocksForDay(DateTime day) async =>
      (await _blocksForDay(day).get()).map(_mapBlock).toList();

  // One query for the timeline (B21): the day's blocks left-joined with
  // their tasks, instead of one live query per block. Drift re-runs it
  // when either table changes.
  @override
  Stream<List<PlannedBlock>> watchDayPlan(DateTime day) {
    final blocks = _blocksForDay(day);
    final query = blocks.join([
      leftOuterJoin(_db.tasks,
          _db.tasks.scheduleBlockId.equalsExp(_db.scheduleBlocks.id)),
    ])
      ..orderBy([
        OrderingTerm.asc(_db.scheduleBlocks.startTime),
        OrderingTerm.asc(_db.scheduleBlocks.id),
        OrderingTerm.asc(_db.tasks.id),
      ]);
    return query.watch().map((rows) {
      final blocksById = <int, ScheduleBlock>{};
      final tasksByBlock = <int, List<Task>>{};
      for (final row in rows) {
        final block = row.readTable(_db.scheduleBlocks);
        blocksById.putIfAbsent(block.id, () => blockFromRow(block));
        final tasks = tasksByBlock.putIfAbsent(block.id, () => []);
        final task = row.readTableOrNull(_db.tasks);
        if (task != null) tasks.add(taskFromRow(task));
      }
      return [
        for (final entry in blocksById.entries)
          PlannedBlock(block: entry.value, tasks: tasksByBlock[entry.key]!),
      ];
    });
  }

  // Every block that overlaps the day, not only those that start on it:
  // a block running past midnight also occupies the next morning, and
  // conflict checks for that morning must see it.
  SimpleSelectStatement<$ScheduleBlocksTable, ScheduleBlockRow> _blocksForDay(
      DateTime day) {
    final start = startOfDay(day);
    final end = addDays(day, 1);
    return _db.select(_db.scheduleBlocks)
      ..where((b) =>
          b.startTime.isSmallerThanValue(end) &
          b.endTime.isBiggerThanValue(start))
      ..orderBy([(b) => OrderingTerm.asc(b.startTime)]);
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

  ScheduleBlock _mapBlock(ScheduleBlockRow row) => blockFromRow(row);
}
