import '../entities/reminder.dart';

abstract interface class ReminderRepository {
  Future<int> create({
    required String title,
    required DateTime fireAt,
    ReminderKind kind = ReminderKind.plain,
    int? taskId,
  });

  Future<Reminder?> get(int id);

  /// Open reminders (scheduled or fired), soonest first.
  Stream<List<Reminder>> watchOpen({int limit = 100});

  /// Open reminders whose time is in `[from, to)`, soonest first.
  Future<List<Reminder>> getOpenBetween(DateTime from, DateTime to,
      {int limit = 64});

  /// Scheduled reminders whose time is before [now]: they have fired.
  Future<int> markFiredBefore(DateTime now);

  Future<void> setStatus(int id, ReminderStatus status);

  /// Moves it to [fireAt] and back to scheduled, counting a snooze.
  Future<void> snooze(int id, DateTime fireAt);
}
