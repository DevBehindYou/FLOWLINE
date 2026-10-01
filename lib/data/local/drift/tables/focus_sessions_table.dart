import 'package:drift/drift.dart';

import '../../../../domain/entities/focus_session.dart';
import 'subtasks_table.dart';
import 'tasks_table.dart';

// "At most one active session" (rule R3, B8) enforced by SQLite, not only
// by FocusSessionRepositoryImpl.startSession: every active row has
// `completed_at IS NULL` = 1, so a unique index over that expression,
// limited to active rows, admits exactly one. (A plain unique index on
// completed_at wouldn't work: SQL treats NULLs as distinct.)
@TableIndex.sql('CREATE UNIQUE INDEX focus_sessions_one_active '
    'ON focus_sessions (completed_at IS NULL) WHERE completed_at IS NULL')
@TableIndex(name: 'focus_sessions_completed_at', columns: {#completedAt})
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
