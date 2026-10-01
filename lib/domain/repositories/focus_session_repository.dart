import '../entities/focus_session.dart';

abstract interface class FocusSessionRepository {
  /// At most one session is ever active (not completed) at a time —
  /// enforced by [startSession].
  Stream<FocusSession?> watchActiveSession();
  Future<FocusSession?> getActiveSession();

  Stream<List<FocusSession>> watchSessionsForTask(int taskId);

  /// Completed sessions whose [FocusSession.completedAt] falls in
  /// `[start, end)`. Every day window in the app (Focus footer, Insights,
  /// export) uses this one rule, the same one the stats calculator buckets
  /// by, so a session that crosses midnight lands on the same day
  /// everywhere: the day it ended.
  Stream<List<FocusSession>> watchCompletedSessionsInRange(
      DateTime start, DateTime end);

  /// One-shot read of the same set (see `getBlocksForDay` for why).
  Future<List<FocusSession>> getCompletedSessionsInRange(
      DateTime start, DateTime end);

  /// Starts a session and returns its id. Idempotent while one is active:
  /// if a session is already running (with time left) or paused, that
  /// session's id is returned and nothing changes. An active session whose
  /// time already ran out is completed at its natural end first.
  Future<int> startSession({
    required FocusSessionType sessionType,
    required int plannedDurationSec,
    int? taskId,
    int? subtaskId,
  });

  Future<void> pauseSession(int id);
  Future<void> resumeSession(int id);
  Future<void> extendSession(int id, int addSeconds);

  /// Completes [id] if it is still active. Returns false when it was
  /// already completed, so a repeated call can't double-credit anything.
  Future<bool> completeSession(int id, {required bool endedEarly});
}
