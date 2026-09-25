import '../entities/focus_session.dart';

abstract interface class FocusSessionRepository {
  /// At most one session is ever active (not completed) at a time —
  /// enforced by [startSession].
  Stream<FocusSession?> watchActiveSession();

  Stream<List<FocusSession>> watchSessionsForTask(int taskId);
  Stream<List<FocusSession>> watchTodaysSessions();
  Stream<List<FocusSession>> watchSessionsInRange(DateTime start, DateTime end);

  Future<int> startSession({
    required FocusSessionType sessionType,
    required int plannedDurationSec,
    int? taskId,
    int? subtaskId,
  });

  Future<void> pauseSession(int id);
  Future<void> resumeSession(int id);
  Future<void> extendSession(int id, int addSeconds);
  Future<void> completeSession(int id, {required bool endedEarly});
}
