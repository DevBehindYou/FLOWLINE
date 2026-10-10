import 'package:drift/drift.dart';

import '../../domain/entities/planned_block.dart';
import '../../domain/entities/schedule_block.dart';
import '../../domain/entities/task.dart';
import '../../domain/recurrence/occurrences.dart';
import '../../domain/recurrence/recurrence_rule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../domain/time/calendar_day.dart';
import '../local/drift/app_database.dart';
import 'row_mappers.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  ScheduleRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<ScheduleBlock>> watchBlocksForDay(DateTime day) => _live(
      {_db.scheduleBlocks, _db.scheduleBlockExceptions}, () => _readDay(day));

  @override
  Future<List<ScheduleBlock>> getBlocksForDay(DateTime day) => _readDay(day);

  // Two queries for the whole timeline (B21), whatever the number of
  // blocks: the day's blocks (stored and computed), then the tasks of the
  // stored ones. Computed occurrences have no tasks: adding one stores the
  // occurrence first (storeOccurrence).
  @override
  Stream<List<PlannedBlock>> watchDayPlan(DateTime day) => _live(
        {_db.scheduleBlocks, _db.scheduleBlockExceptions, _db.tasks},
        () async {
          final blocks = await _readDay(day);
          final storedIds = [
            for (final b in blocks)
              if (!b.isComputedOccurrence) b.id,
          ];
          final tasksByBlock = <int, List<Task>>{};
          if (storedIds.isNotEmpty) {
            final rows = await (_db.select(_db.tasks)
                  ..where((t) => t.scheduleBlockId.isIn(storedIds))
                  ..orderBy([(t) => OrderingTerm.asc(t.id)]))
                .get();
            for (final row in rows) {
              tasksByBlock
                  .putIfAbsent(row.scheduleBlockId!, () => [])
                  .add(taskFromRow(row));
            }
          }
          return [
            for (final b in blocks)
              PlannedBlock(block: b, tasks: tasksByBlock[b.id] ?? const []),
          ];
        },
      );

  /// Re-reads after every write to [tables]. The day's blocks come from
  /// several queries (plain blocks, series, their exceptions), so there
  /// is no single Drift query to watch.
  Stream<T> _live<T>(
    Set<TableInfo<Table, Object?>> tables,
    Future<T> Function() read,
  ) async* {
    yield await read();
    await for (final _
        in _db.tableUpdates(TableUpdateQuery.onAllTables(tables))) {
      yield await read();
    }
  }

  /// Everything shown for [day], by start time: plain blocks and stored
  /// occurrences that overlap it, plus each series' computed occurrences
  /// for the days not deleted or stored on their own.
  Future<List<ScheduleBlock>> _readDay(DateTime day) async {
    final dayStart = startOfDay(day);
    final dayEnd = addDays(day, 1);
    final previousDay = addDays(day, -1);

    final stored =
        await (_blocksForDay(day)..where((b) => b.recurrence.isNull())).get();
    final series = await (_db.select(_db.scheduleBlocks)
          ..where((b) =>
              b.recurrence.isNotNull() &
              b.startTime.isSmallerThanValue(dayEnd) &
              (b.recurrenceUntil.isNull() |
                  b.recurrenceUntil.isBiggerOrEqualValue(previousDay))))
        .get();

    final blocks = stored.map(blockFromRow).toList();
    if (series.isNotEmpty) {
      final seriesIds = [for (final s in series) s.id];
      final days = [previousDay, dayStart];
      final skip = <int, Set<DateTime>>{};
      final exceptions = await (_db.select(_db.scheduleBlockExceptions)
            ..where((e) =>
                e.seriesId.isIn(seriesIds) & e.occurrenceDate.isIn(days)))
          .get();
      for (final e in exceptions) {
        skip.putIfAbsent(e.seriesId, () => {}).add(e.occurrenceDate);
      }
      // A stored occurrence replaces its day even if it was moved to
      // another time (or day), so look it up by occurrence date, not by
      // where it sits now.
      final replaced = await (_db.select(_db.scheduleBlocks)
            ..where((b) =>
                b.seriesId.isIn(seriesIds) & b.occurrenceDate.isIn(days)))
          .get();
      for (final r in replaced) {
        skip.putIfAbsent(r.seriesId!, () => {}).add(r.occurrenceDate!);
      }
      for (final s in series) {
        blocks.addAll(occurrencesOverlapping(
          series: blockFromRow(s),
          day: day,
          skip: skip[s.id] ?? const {},
        ));
      }
    }
    return blocks
      ..sort((a, b) {
        final byStart = a.startTime.compareTo(b.startTime);
        return byStart != 0 ? byStart : a.id.compareTo(b.id);
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
  Future<ScheduleBlock?> getBlock(int id) async {
    final row = await (_db.select(_db.scheduleBlocks)
          ..where((b) => b.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : blockFromRow(row);
  }

  @override
  Future<int> createBlock({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    RecurrenceRule? recurrence,
  }) {
    return _db.into(_db.scheduleBlocks).insert(
          ScheduleBlocksCompanion.insert(
            title: title,
            startTime: startTime,
            endTime: endTime,
            recurrence: Value(recurrence?.format()),
          ),
        );
  }

  @override
  Future<int> storeOccurrence(int blockId) async {
    final occurrence = decodeOccurrenceId(blockId);
    if (occurrence == null) return blockId;
    return _db.transaction(() async {
      final existing = await (_db.select(_db.scheduleBlocks)
            ..where((b) =>
                b.seriesId.equals(occurrence.seriesId) &
                b.occurrenceDate.equals(occurrence.day)))
          .getSingleOrNull();
      if (existing != null) return existing.id;

      final series = await getBlock(occurrence.seriesId);
      final computed = series == null
          ? null
          : occurrencesOverlapping(series: series, day: occurrence.day)
              .where((o) => o.occurrenceDate == occurrence.day)
              .firstOrNull;
      if (computed == null) {
        throw StateError('No occurrence of series ${occurrence.seriesId} '
            'on ${occurrence.day}');
      }
      return _db.into(_db.scheduleBlocks).insert(
            ScheduleBlocksCompanion.insert(
              title: computed.title,
              startTime: computed.startTime,
              endTime: computed.endTime,
              source: Value(computed.source),
              isLocked: Value(computed.isLocked),
              seriesId: Value(occurrence.seriesId),
              occurrenceDate: Value(occurrence.day),
            ),
          );
    });
  }

  /// Title and times of a plain block or one occurrence (stored first if
  /// it's computed), or of a series template including its rule.
  @override
  Future<void> updateBlock(ScheduleBlock block) async {
    final id = await storeOccurrence(block.id);
    final isSeries = block.recurrence != null && !block.isOccurrence;
    await (_db.update(_db.scheduleBlocks)..where((b) => b.id.equals(id))).write(
      ScheduleBlocksCompanion(
        title: Value(block.title),
        startTime: Value(block.startTime),
        endTime: Value(block.endTime),
        recurrence:
            isSeries ? Value(block.recurrence!.format()) : const Value.absent(),
      ),
    );
  }

  // Tasks.scheduleBlockId is a plain column, not a foreign key, so nothing
  // else would clear it: a task left pointing at a deleted block is in no
  // block and not "unscheduled" either, so it silently vanishes from Today.
  //
  // One occurrence of a series ("Delete this occurrence") is recorded as
  // an exception, or its computed stand-in would simply come back.
  @override
  Future<void> deleteBlock(int id) {
    return _db.transaction(() async {
      final computed = decodeOccurrenceId(id);
      if (computed != null) {
        await _addException(computed.seriesId, computed.day);
        return;
      }
      final row = await (_db.select(_db.scheduleBlocks)
            ..where((b) => b.id.equals(id)))
          .getSingleOrNull();
      if (row == null) return;
      if (row.seriesId != null) {
        await _addException(row.seriesId!, row.occurrenceDate!);
      }
      await (_db.update(_db.tasks)..where((t) => t.scheduleBlockId.equals(id)))
          .write(const TasksCompanion(scheduleBlockId: Value(null)));
      await (_db.delete(_db.scheduleBlocks)..where((b) => b.id.equals(id)))
          .go();
    });
  }

  Future<void> _addException(int seriesId, DateTime day) =>
      _db.into(_db.scheduleBlockExceptions).insert(
            ScheduleBlockExceptionsCompanion.insert(
                seriesId: seriesId, occurrenceDate: day),
            mode: InsertMode.insertOrIgnore,
          );

  /// "Delete this and all following": the series ends the day before
  /// [occurrence]. From its first day, that's the whole series. Stored
  /// occurrences from that day on go too; their tasks become unscheduled
  /// (the tasks foreign key sets them to null).
  @override
  Future<void> endSeriesAt(ScheduleBlock occurrence) {
    final seriesId = occurrence.seriesId;
    final day = occurrence.occurrenceDate;
    if (seriesId == null || day == null) {
      throw ArgumentError.value(occurrence, 'occurrence', 'not an occurrence');
    }
    return _db.transaction(() async {
      final series = await getBlock(seriesId);
      if (series == null) return;
      if (!day.isAfter(startOfDay(series.startTime))) {
        // Cascades to its stored occurrences and exceptions.
        await (_db.delete(_db.scheduleBlocks)
              ..where((b) => b.id.equals(seriesId)))
            .go();
        return;
      }
      await (_db.update(_db.scheduleBlocks)
            ..where((b) => b.id.equals(seriesId)))
          .write(ScheduleBlocksCompanion(
              recurrenceUntil: Value(addDays(day, -1))));
      await (_db.delete(_db.scheduleBlocks)
            ..where((b) =>
                b.seriesId.equals(seriesId) &
                b.occurrenceDate.isBiggerOrEqualValue(day)))
          .go();
      await (_db.delete(_db.scheduleBlockExceptions)
            ..where((e) =>
                e.seriesId.equals(seriesId) &
                e.occurrenceDate.isBiggerOrEqualValue(day)))
          .go();
    });
  }
}
