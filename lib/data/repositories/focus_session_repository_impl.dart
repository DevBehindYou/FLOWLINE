import 'package:clock/clock.dart';
import 'package:drift/drift.dart';

import '../../domain/entities/focus_session.dart';
import '../../domain/repositories/focus_session_repository.dart';
import '../local/drift/app_database.dart';

class FocusSessionRepositoryImpl implements FocusSessionRepository {
  FocusSessionRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<FocusSession?> watchActiveSession() {
    final query = _db.select(_db.focusSessions)
      ..where((s) => s.completedAt.isNull());
    return query
        .watchSingleOrNull()
        .map((row) => row == null ? null : _map(row));
  }

  @override
  Future<FocusSession?> getActiveSession() async {
    final row = await (_db.select(_db.focusSessions)
          ..where((s) => s.completedAt.isNull()))
        .getSingleOrNull();
    return row == null ? null : _map(row);
  }

  @override
  Stream<List<FocusSession>> watchSessionsForTask(int taskId) {
    final query = _db.select(_db.focusSessions)
      ..where((s) => s.taskId.equals(taskId))
      ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]);
    return query.watch().map((rows) => rows.map(_map).toList());
  }

  @override
  Stream<List<FocusSession>> watchCompletedSessionsInRange(
      DateTime start, DateTime end) {
    final query = _db.select(_db.focusSessions)
      ..where((s) =>
          s.completedAt.isBiggerOrEqualValue(start) &
          s.completedAt.isSmallerThanValue(end))
      ..orderBy([(s) => OrderingTerm.asc(s.completedAt)]);
    return query.watch().map((rows) => rows.map(_map).toList());
  }

  @override
  Future<int> startSession({
    required FocusSessionType sessionType,
    required int plannedDurationSec,
    int? taskId,
    int? subtaskId,
  }) async {
    // At most one session is ever active (watchActiveSession relies on
    // it). The UI only offers Start when none is, so an active one here
    // means a duplicate request (a double tap racing the screen rebuild,
    // B6): starting is idempotent and returns it unchanged rather than
    // closing a session the user just started as "ended early". Only a
    // session whose time already ran out unobserved is closed — at its
    // natural end — before the new one starts.
    final existing = await getActiveSession();
    if (existing != null) {
      final expired = existing.isRunning && existing.remainingSec <= 0;
      if (!expired) return existing.id;
      await completeSession(existing.id, endedEarly: false);
    }

    final now = clock.now();
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

  // Pause and resume only touch an active session (`completedAt IS NULL`):
  // a quick End followed by Pause/Resume must not write timer state onto a
  // session that's already completed.
  @override
  Future<void> pauseSession(int id) async {
    final row = await _rowById(id);
    final session = _map(row);
    if (session.completedAt != null || session.isPaused) return;
    await (_db.update(_db.focusSessions)
          ..where((s) => s.id.equals(id) & s.completedAt.isNull()))
        .write(
      FocusSessionsCompanion(
        remainingSecAtSegmentStart: Value(session.remainingSec),
        segmentStartedAt: const Value(null),
        isPaused: const Value(true),
      ),
    );
  }

  @override
  Future<void> resumeSession(int id) {
    return (_db.update(_db.focusSessions)
          ..where((s) =>
              s.id.equals(id) &
              s.completedAt.isNull() &
              s.isPaused.equals(true)))
        .write(
      FocusSessionsCompanion(
        segmentStartedAt: Value(clock.now()),
        isPaused: const Value(false),
      ),
    );
  }

  // The planned duration grows with the extension; otherwise a naturally
  // finished extended session records actual = planned (clamped) and the
  // extra minutes vanish from stats and exports.
  @override
  Future<void> extendSession(int id, int addSeconds) async {
    final row = await _rowById(id);
    await (_db.update(_db.focusSessions)..where((s) => s.id.equals(id))).write(
      FocusSessionsCompanion(
        plannedDurationSec: Value(row.plannedDurationSec + addSeconds),
        remainingSecAtSegmentStart:
            Value(row.remainingSecAtSegmentStart + addSeconds),
      ),
    );
  }

  @override
  Future<bool> completeSession(int id, {required bool endedEarly}) async {
    final session = _map(await _rowById(id));
    if (session.completedAt != null) return false;

    final now = clock.now();
    final actual = (session.plannedDurationSec - session.remainingSec)
        .clamp(0, session.plannedDurationSec);
    // The `completedAt IS NULL` guard makes a concurrent second call a
    // no-op at the SQL level, not just in the check above.
    final updated = await (_db.update(_db.focusSessions)
          ..where((s) => s.id.equals(id) & s.completedAt.isNull()))
        .write(
      FocusSessionsCompanion(
        completedAt: Value(endedEarly ? now : _naturalEnd(session, now)),
        actualDurationSec: Value(actual),
        endedEarly: Value(endedEarly),
        segmentStartedAt: const Value(null),
      ),
    );
    return updated > 0;
  }

  // A session that ran out while nothing was watching (app backgrounded,
  // Focus tab never built, process killed) ended at anchor + remaining,
  // not whenever it was noticed — which may be a different day.
  DateTime _naturalEnd(FocusSession session, DateTime now) {
    final anchor = session.segmentStartedAt;
    if (anchor == null) return now;
    final end =
        anchor.add(Duration(seconds: session.remainingSecAtSegmentStart));
    return end.isBefore(now) ? end : now;
  }

  Future<FocusSessionRow> _rowById(int id) {
    return (_db.select(_db.focusSessions)..where((s) => s.id.equals(id)))
        .getSingle();
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
