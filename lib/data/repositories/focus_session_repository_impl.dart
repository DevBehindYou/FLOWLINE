import 'package:drift/drift.dart';

import '../../domain/entities/focus_session.dart';
import '../../domain/repositories/focus_session_repository.dart';
import '../local/drift/app_database.dart';

class FocusSessionRepositoryImpl implements FocusSessionRepository {
  FocusSessionRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<FocusSession?> watchActiveSession() {
    final query = _db.select(_db.focusSessions)..where((s) => s.completedAt.isNull());
    return query.watchSingleOrNull().map((row) => row == null ? null : _map(row));
  }

  @override
  Stream<List<FocusSession>> watchSessionsForTask(int taskId) {
    final query = _db.select(_db.focusSessions)
      ..where((s) => s.taskId.equals(taskId))
      ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]);
    return query.watch().map((rows) => rows.map(_map).toList());
  }

  @override
  Stream<List<FocusSession>> watchTodaysSessions() {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final query = _db.select(_db.focusSessions)
      ..where(
        (s) => s.startedAt.isBiggerOrEqualValue(dayStart) & s.startedAt.isSmallerThanValue(dayEnd),
      );
    return query.watch().map((rows) => rows.map(_map).toList());
  }

  @override
  Stream<List<FocusSession>> watchSessionsInRange(DateTime start, DateTime end) {
    final query = _db.select(_db.focusSessions)
      ..where((s) => s.startedAt.isBiggerOrEqualValue(start) & s.startedAt.isSmallerThanValue(end));
    return query.watch().map((rows) => rows.map(_map).toList());
  }

  @override
  Future<int> startSession({
    required FocusSessionType sessionType,
    required int plannedDurationSec,
    int? taskId,
    int? subtaskId,
  }) async {
    // Defensive self-heal: there should never be more than one active
    // session (watchActiveSession relies on that), but if one was
    // somehow left dangling, close it out as ended-early rather than
    // letting watchSingleOrNull throw.
    final existing =
        await (_db.select(_db.focusSessions)..where((s) => s.completedAt.isNull()))
            .getSingleOrNull();
    if (existing != null) {
      await completeSession(existing.id, endedEarly: true);
    }

    final now = DateTime.now();
    return _db.into(_db.focusSessions).insert(
          FocusSessionsCompanion.insert(
            taskId: Value(taskId),
            subtaskId: Value(subtaskId),
            sessionType: sessionType,
            plannedDurationSec: plannedDurationSec,
            startedAt: now,
            segmentStartedAt: Value(now),
            remainingSecAtSegmentStart: plannedDurationSec,
          ),
        );
  }

  @override
  Future<void> pauseSession(int id) async {
    final row = await _rowById(id);
    final session = _map(row);
    await (_db.update(_db.focusSessions)..where((s) => s.id.equals(id))).write(
      FocusSessionsCompanion(
        remainingSecAtSegmentStart: Value(session.remainingSec),
        segmentStartedAt: const Value(null),
        isPaused: const Value(true),
      ),
    );
  }

  @override
  Future<void> resumeSession(int id) {
    return (_db.update(_db.focusSessions)..where((s) => s.id.equals(id))).write(
      FocusSessionsCompanion(
        segmentStartedAt: Value(DateTime.now()),
        isPaused: const Value(false),
      ),
    );
  }

  @override
  Future<void> extendSession(int id, int addSeconds) async {
    final row = await _rowById(id);
    await (_db.update(_db.focusSessions)..where((s) => s.id.equals(id))).write(
      FocusSessionsCompanion(
        remainingSecAtSegmentStart: Value(row.remainingSecAtSegmentStart + addSeconds),
      ),
    );
  }

  @override
  Future<void> completeSession(int id, {required bool endedEarly}) async {
    final row = await _rowById(id);
    final session = _map(row);
    final actual =
        (session.plannedDurationSec - session.remainingSec).clamp(0, session.plannedDurationSec);
    await (_db.update(_db.focusSessions)..where((s) => s.id.equals(id))).write(
      FocusSessionsCompanion(
        completedAt: Value(DateTime.now()),
        actualDurationSec: Value(actual),
        endedEarly: Value(endedEarly),
        segmentStartedAt: const Value(null),
      ),
    );
  }

  Future<FocusSessionRow> _rowById(int id) {
    return (_db.select(_db.focusSessions)..where((s) => s.id.equals(id))).getSingle();
  }

  FocusSession _map(FocusSessionRow row) {
    return FocusSession(
      id: row.id,
      taskId: row.taskId,
      subtaskId: row.subtaskId,
      sessionType: row.sessionType,
      plannedDurationSec: row.plannedDurationSec,
      startedAt: row.startedAt,
      segmentStartedAt: row.segmentStartedAt,
      remainingSecAtSegmentStart: row.remainingSecAtSegmentStart,
      isPaused: row.isPaused,
      completedAt: row.completedAt,
      actualDurationSec: row.actualDurationSec,
      endedEarly: row.endedEarly,
    );
  }
}
