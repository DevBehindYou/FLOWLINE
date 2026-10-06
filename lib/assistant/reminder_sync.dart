import 'dart:ui' show DartPluginRegistrant;

import 'package:clock/clock.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/notifications/notification_service.dart';
import '../data/assistant/drift_tool_env.dart';
import '../data/assistant/stored_rows.dart';
import '../data/assistant/tool_executor.dart';
import '../data/local/drift/app_database.dart';
import '../data/repositories/app_settings_repository_impl.dart';
import '../data/repositories/focus_session_repository_impl.dart';
import '../data/repositories/reminder_repository_impl.dart';
import '../data/repositories/schedule_repository_impl.dart';
import '../data/repositories/task_repository_impl.dart';
import '../domain/assistant/autonomy.dart';
import '../domain/entities/reminder.dart';
import '../domain/repositories/reminder_repository.dart';
import '../domain/services/reminder_actions.dart';
import '../l10n/l10n.dart';
import 'tools/tool_registry.dart';

/// Keeps reminder notifications in line with the database (docs/05 §13).
/// The database is the truth; this only ever schedules, moves or cancels.
final class ReminderSync {
  ReminderSync({required this.reminders, required this.notifications});

  final ReminderRepository reminders;
  final Future<NotificationService> Function() notifications;

  /// How far ahead notifications are scheduled; the rest are topped up
  /// on start and resume (OEM limits, and the plugin's own).
  // An exact span, not calendar days (R7): a few hours either way at a
  // DST change doesn't matter for a top-up window.
  static const horizon = Duration(hours: 14 * 24);
  static const maxScheduled = 64;

  /// After a reminder changed: schedule, move or cancel its alert.
  Future<void> sync(int reminderId) async {
    final service = await notifications();
    final r = await reminders.get(reminderId);
    final now = clock.now();
    final nid = reminderNotificationId(reminderId);
    if (r == null ||
        r.status != ReminderStatus.scheduled ||
        !r.fireAt.isAfter(now)) {
      await service.cancel(nid);
      return;
    }
    // The first reminder is when the alert permission is worth asking for.
    await service.requestPermission();
    await _schedule(service, r);
  }

  /// On start and resume: what has fired is marked so, and the next two
  /// weeks are (re)scheduled. Scheduling an id again replaces it.
  Future<void> topUp() async {
    final now = clock.now();
    await reminders.markFiredBefore(now);
    final next = await reminders.getOpenBetween(now, now.add(horizon),
        limit: maxScheduled);
    if (next.isEmpty) return;
    final service = await notifications();
    for (final r in next) {
      await _schedule(service, r);
    }
  }

  Future<void> _schedule(NotificationService service, Reminder r) {
    final l10n = deviceLocalizations();
    return service.scheduleReminder(
      notificationId: reminderNotificationId(r.id),
      reminderId: r.id,
      fireAt: r.fireAt,
      title: r.title,
      channelName: l10n.reminderNotificationChannel,
      channelDescription: l10n.reminderNotificationChannelDescription,
      actions: [
        (id: ReminderAction.done.name, label: l10n.reminderDone),
        (id: ReminderAction.snooze10.name, label: l10n.reminderSnooze10),
        (id: ReminderAction.tomorrow.name, label: l10n.reminderTomorrow),
      ],
    );
  }
}

/// A notification button, applied as the tool call it maps to, through
/// the executor: a ledger row and an undo, like anything else AA does.
/// Returns the reminder whose alert must be synced, or null.
Future<int?> applyReminderAction({
  required String actionId,
  required int reminderId,
  required ReminderRepository reminders,
  required ToolRegistry registry,
  required ToolExecutor executor,
}) async {
  final action =
      ReminderAction.values.where((a) => a.name == actionId).firstOrNull;
  final reminder = await reminders.get(reminderId);
  if (action == null || reminder == null) return null;
  final now = clock.now();
  final call = reminderActionCall(action, reminder, now);
  if (call == null) return null;
  final prepared = registry.prepareMap(call.tool, call.args);
  if (prepared is! Prepared) return null;
  await executor.execute(
    prepared.call,
    groupId: 'notification-$reminderId-${now.microsecondsSinceEpoch}',
    // Pressing the button is the user asking.
    origin: ActionOrigin.said,
    decision: Decision.executeWithUndo,
  );
  return reminderId;
}

/// A reminder button pressed while the app isn't running: the plugin runs
/// this in a background isolate. It opens the database itself, applies
/// the press through the same tool, re-syncs that alert, and closes.
/// UNVERIFIED on a device (background isolate, OEM restrictions).
@pragma('vm:entry-point')
Future<void> reminderActionInBackground(NotificationResponse response) async {
  final reminderId = NotificationService.reminderIdOf(response.payload);
  final action = response.actionId;
  if (reminderId == null || action == null || action.isEmpty) return;
  DartPluginRegistrant.ensureInitialized();
  final db = AppDatabase();
  try {
    final reminders = ReminderRepositoryImpl(db);
    final rows = StoredRows(db);
    final executor = ToolExecutor(
      db: db,
      env: () => DriftToolEnv(
        tasks: TaskRepositoryImpl(db),
        schedule: ScheduleRepositoryImpl(db),
        focus: FocusSessionRepositoryImpl(db),
        reminders: reminders,
        settings: AppSettingsRepositoryImpl(db),
        rows: rows,
      ),
    );
    final touched = await applyReminderAction(
      actionId: action,
      reminderId: reminderId,
      reminders: reminders,
      registry: ToolRegistry(),
      executor: executor,
    );
    if (touched != null) {
      final service = NotificationService();
      await service.init();
      await ReminderSync(
          reminders: reminders,
          notifications: () async => service).sync(touched);
    }
  } finally {
    await db.close();
  }
}
