import 'package:drift/drift.dart';

import '../../../../domain/entities/focus_session.dart';
import 'subtasks_table.dart';
import 'tasks_table.dart';

@DataClassName('FocusSessionRow')
class FocusSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer()
      .nullable()
      .references(Tasks, #id, onDelete: KeyAction.setNull)();
  IntColumn get subtaskId => integer()
      .nullable()
      .references(Subtasks, #id, onDelete: KeyAction.setNull)();
  IntColumn get sessionType => intEnum<FocusSessionType>()();
  IntColumn get plannedDurationSec => integer()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get segmentStartedAt => dateTime().nullable()();
  IntColumn get remainingSecAtSegmentStart => integer()();
  BoolColumn get isPaused => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get actualDurationSec => integer().nullable()();
  BoolColumn get endedEarly => boolean().withDefault(const Constant(false))();
}
