// Reminders (docs/05 §13). Enums are stored by index, append-only (R1).

enum ReminderKind {
  plain,
  beforeBlock,
  followUp,
  bill,
  personDate,
  departure,
  document,
}

enum ReminderStatus {
  /// Waiting for its time (a notification is, or will be, scheduled).
  scheduled,

  /// Its time passed while it was still open.
  fired,

  /// The user marked it done.
  done,

  /// Called off.
  cancelled,
}

final class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.fireAt,
    this.kind = ReminderKind.plain,
    this.status = ReminderStatus.scheduled,
    this.snoozeCount = 0,
    this.taskId,
  });

  final int id;
  final String title;
  final DateTime fireAt;
  final ReminderKind kind;
  final ReminderStatus status;
  final int snoozeCount;

  /// The task it's about, if any (kept when the task is deleted: null).
  final int? taskId;

  /// Still to happen or still to deal with.
  bool get isOpen =>
      status == ReminderStatus.scheduled || status == ReminderStatus.fired;
}
