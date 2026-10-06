import 'package:drift/drift.dart';

import '../../../../domain/entities/schedule_block.dart';

@TableIndex(name: 'schedule_blocks_start_time', columns: {#startTime})
// One stored row per series occurrence at most (an occurrence that was
// edited, or got tasks, on its own).
@TableIndex(
    name: 'schedule_blocks_series_occurrence',
    columns: {#seriesId, #occurrenceDate},
    unique: true)
@DataClassName('ScheduleBlockRow')
class ScheduleBlocks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get startTime => dateTime()();
  // A zero-length or inverted block can't be shown or conflict-checked
  // sensibly; every UI path already validates this, the CHECK makes it a
  // guarantee (rule R3).
  // Drift's documented pattern for a column CHECK: the getter is read by
  // the code generator, never called at runtime.
  DateTimeColumn get endTime =>
      // ignore: recursive_getters
      dateTime().check(endTime.isBiggerThan(startTime))();
  IntColumn get source =>
      intEnum<ScheduleBlockSource>().withDefault(const Constant(0))();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();

  // Recurrence (schema v6). A row is one of three kinds:
  // - a plain block: all four columns null;
  // - a series: `recurrence` set (an RRULE subset, see RecurrenceRule).
  //   Its own start/end give the first day and the time of day; it is a
  //   template and never shown itself;
  // - a stored occurrence of a series: `seriesId` + `occurrenceDate` set,
  //   written when one occurrence is edited or given tasks.
  TextColumn get recurrence => text().nullable()();

  /// Last day (local midnight) a series occurs on; null = no end.
  DateTimeColumn get recurrenceUntil => dateTime().nullable()();
  IntColumn get seriesId => integer()
      .nullable()
      .references(ScheduleBlocks, #id, onDelete: KeyAction.cascade)();

  /// The day (local midnight) this stored occurrence replaces in its
  /// series, even if it was moved to another time.
  DateTimeColumn get occurrenceDate => dateTime().nullable()();

  @override
  List<String> get customConstraints => [
        // A stored occurrence names both its series and its day, and is
        // never itself a series.
        'CHECK ((series_id IS NULL) = (occurrence_date IS NULL))',
        'CHECK (series_id IS NULL OR recurrence IS NULL)',
      ];
}

/// Single occurrences removed from a series ("Delete this occurrence").
@DataClassName('ScheduleBlockExceptionRow')
class ScheduleBlockExceptions extends Table {
  IntColumn get seriesId =>
      integer().references(ScheduleBlocks, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get occurrenceDate => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {seriesId, occurrenceDate};
}
