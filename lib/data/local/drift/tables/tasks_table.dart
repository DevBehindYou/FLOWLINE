import 'package:drift/drift.dart';

import '../../../../domain/entities/task.dart';
import 'schedule_blocks_table.dart';

@TableIndex(name: 'tasks_schedule_block_id', columns: {#scheduleBlockId})
@DataClassName('TaskRow')
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  // A real foreign key since schema v4: deleting a block unschedules its
  // tasks in SQLite itself, rather than relying on every delete path to
  // remember to (ScheduleRepositoryImpl.deleteBlock still does it too).
  IntColumn get scheduleBlockId => integer()
      .nullable()
      .references(ScheduleBlocks, #id, onDelete: KeyAction.setNull)();
  TextColumn get title => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  IntColumn get priority => intEnum<TaskPriority>()();
  IntColumn get status => intEnum<TaskStatus>()();
  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  // A repeating task (schema v14): the same RRULE subset as blocks (see
  // RecurrenceRule). Completing one moves due_at to the next occurrence,
  // so a repeating task always has a due time.
  TextColumn get recurrence => text().nullable()();

  @override
  List<String> get customConstraints => [
        'CHECK (recurrence IS NULL OR due_at IS NOT NULL)',
      ];
}
