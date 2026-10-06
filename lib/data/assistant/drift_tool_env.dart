import 'package:clock/clock.dart';

import '../../domain/assistant/ledger.dart';
import '../../domain/assistant/tool.dart';
import '../../domain/repositories/app_settings_repository.dart';
import '../../domain/repositories/focus_session_repository.dart';
import '../../domain/repositories/list_repository.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../domain/repositories/task_repository.dart';
import 'stored_rows.dart';

/// The [ToolEnv] the app runs tools in: the normal repositories over the
/// app database. "Now" is read once, when the env is made, so validate
/// and run agree about it.
final class DriftToolEnv implements ToolEnv {
  DriftToolEnv({
    required this.tasks,
    required this.schedule,
    required this.focus,
    required this.reminders,
    required this.lists,
    required AppSettingsRepository settings,
    required StoredRows rows,
    DateTime? now,
  })  : _settings = settings,
        _rows = rows,
        now = now ?? clock.now();

  @override
  final DateTime now;
  @override
  final TaskRepository tasks;
  @override
  final ScheduleRepository schedule;
  @override
  final FocusSessionRepository focus;
  @override
  final ReminderRepository reminders;
  @override
  final ListRepository lists;
  final AppSettingsRepository _settings;
  final StoredRows _rows;

  @override
  Future<int> focusMinutes() async => (await _settings.get()).focusMinutes;

  @override
  Future<Map<String, Object?>?> storedRow(UndoTable table, int id) =>
      _rows.row(table, id);

  @override
  Future<List<Map<String, Object?>>> storedRowsWhere(
          UndoTable table, String column, int value) =>
      _rows.rowsWhere(table, column, value);
}
