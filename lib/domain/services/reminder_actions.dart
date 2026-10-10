import '../entities/reminder.dart';
import '../time/calendar_day.dart';

// What a reminder notification's buttons do (docs/05 §13): a pure
// function of (action, reminder, now) to the same tool call the chat
// would make, so the change gets a ledger row and an undo wherever it
// runs (the app, or the background isolate with the app closed).

/// Stored as the notification action id: never rename (R1 in spirit).
enum ReminderAction { done, snooze10, tomorrow }

/// The tool call for [action] on [reminder], or null when there is
/// nothing to do (it was already done or cancelled).
({String tool, Map<String, Object?> args})? reminderActionCall(
    ReminderAction action, Reminder reminder, DateTime now) {
  if (!reminder.isOpen) return null;
  return switch (action) {
    ReminderAction.done => (
        tool: 'complete_reminder',
        args: {'reminder_id': reminder.id},
      ),
    ReminderAction.snooze10 => (
        tool: 'snooze_reminder',
        args: {
          'reminder_id': reminder.id,
          'until': _iso(_minute(now).add(const Duration(minutes: 10)))
        },
      ),
    // The same time of day tomorrow (calendar math, so DST can't move it).
    ReminderAction.tomorrow => (
        tool: 'snooze_reminder',
        args: {
          'reminder_id': reminder.id,
          'until': _iso(_atTimeOf(addDays(now, 1), reminder.fireAt)),
        },
      ),
  };
}

DateTime _minute(DateTime t) =>
    DateTime(t.year, t.month, t.day, t.hour, t.minute);

DateTime _atTimeOf(DateTime day, DateTime time) =>
    DateTime(day.year, day.month, day.day, time.hour, time.minute);

String _iso(DateTime t) =>
    '${t.year.toString().padLeft(4, '0')}-${_pad(t.month)}-${_pad(t.day)}'
    'T${_pad(t.hour)}:${_pad(t.minute)}';

String _pad(int n) => n.toString().padLeft(2, '0');

/// The notification id of a reminder: stable, so scheduling again
/// replaces it. Focus uses 1001; reminders start well above.
int reminderNotificationId(int reminderId) => 100000 + reminderId;
