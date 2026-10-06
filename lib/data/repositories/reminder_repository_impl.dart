import 'package:drift/drift.dart';

import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../local/drift/app_database.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  ReminderRepositoryImpl(this._db);

  final AppDatabase _db;

  static final _open = [ReminderStatus.scheduled, ReminderStatus.fired];

  @override
  Future<int> create({
    required String title,
    required DateTime fireAt,
    ReminderKind kind = ReminderKind.plain,
    int? taskId,
  }) =>
      _db.into(_db.reminders).insert(RemindersCompanion.insert(
            title: title,
            fireAt: fireAt,
            kind: kind,
            status: ReminderStatus.scheduled,
            taskId: Value(taskId),
          ));

  @override
  Future<Reminder?> get(int id) async {
    final row = await (_db.select(_db.reminders)..where((r) => r.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _map(row);
  }

  @override
  Stream<List<Reminder>> watchOpen({int limit = 100}) {
    final q = _db.select(_db.reminders)
      ..where((r) => r.status.isInValues(_open))
      ..orderBy(
          [(r) => OrderingTerm.asc(r.fireAt), (r) => OrderingTerm.asc(r.id)])
      ..limit(limit);
    return q.watch().map((rows) => rows.map(_map).toList());
  }

  @override
  Future<List<Reminder>> getOpenBetween(DateTime from, DateTime to,
      {int limit = 64}) async {
    final rows = await (_db.select(_db.reminders)
          ..where((r) =>
              r.status.isInValues(_open) &
              r.fireAt.isBiggerOrEqualValue(from) &
              r.fireAt.isSmallerThanValue(to))
          ..orderBy([(r) => OrderingTerm.asc(r.fireAt)])
          ..limit(limit))
        .get();
    return rows.map(_map).toList();
  }

  @override
  Future<int> markFiredBefore(DateTime now) => (_db.update(_db.reminders)
        ..where((r) =>
            r.status.equalsValue(ReminderStatus.scheduled) &
            r.fireAt.isSmallerThanValue(now)))
      .write(const RemindersCompanion(status: Value(ReminderStatus.fired)));

  @override
  Future<void> setStatus(int id, ReminderStatus status) =>
      (_db.update(_db.reminders)..where((r) => r.id.equals(id)))
          .write(RemindersCompanion(status: Value(status)));

  @override
  Future<void> snooze(int id, DateTime fireAt) => _db.customUpdate(
        'UPDATE reminders SET fire_at = ?, status = ?, '
        'snooze_count = snooze_count + 1 WHERE id = ?',
        variables: [
          Variable(fireAt),
          Variable.withInt(ReminderStatus.scheduled.index),
          Variable.withInt(id),
        ],
        updates: {_db.reminders},
        updateKind: UpdateKind.update,
      );

  Reminder _map(ReminderRow r) => Reminder(
        id: r.id,
        title: r.title,
        fireAt: r.fireAt,
        kind: r.kind,
        status: r.status,
        snoozeCount: r.snoozeCount,
        taskId: r.taskId,
      );
}
