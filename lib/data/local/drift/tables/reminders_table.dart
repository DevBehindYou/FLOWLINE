import 'package:drift/drift.dart';

import '../../../../domain/entities/reminder.dart';
import 'tasks_table.dart';

/// Reminders (schema v11, docs/05 §13). The notification id is derived
/// from the row id (`reminderNotificationId`), so re-scheduling replaces
/// a notification rather than duplicating it.
@TableIndex(name: 'reminders_status_fire_at', columns: {#status, #fireAt})
@DataClassName('ReminderRow')
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()
      // Drift's documented pattern for a column CHECK.
      // ignore: recursive_getters
      .check(title.length.isBetweenValues(1, 200))();
  DateTimeColumn get fireAt => dateTime()();
  IntColumn get kind => intEnum<ReminderKind>()();
  IntColumn get status => intEnum<ReminderStatus>()();
  IntColumn get snoozeCount => integer()
      .withDefault(const Constant(0))
      // ignore: recursive_getters
      .check(snoozeCount.isBiggerOrEqualValue(0))();
  IntColumn get taskId => integer()
      .nullable()
      .references(Tasks, #id, onDelete: KeyAction.setNull)();
}
