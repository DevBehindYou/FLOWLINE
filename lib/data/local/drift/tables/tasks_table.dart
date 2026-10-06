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
}
