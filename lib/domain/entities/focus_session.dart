enum FocusSessionType { focus, shortBreak, longBreak }

/// A Pomodoro-style session, persisted from the moment it starts so it
/// survives the app process being killed while backgrounded — remaining
/// time is always derived from a wall-clock anchor (`segmentStartedAt`),
/// never from an in-memory countdown. See `remainingSec` below.
class FocusSession {
  const FocusSession({
    required this.id,
    this.taskId,
    this.subtaskId,
    required this.sessionType,
    required this.plannedDurationSec,
    required this.startedAt,
    required this.segmentStartedAt,
    required this.remainingSecAtSegmentStart,
    required this.isPaused,
    this.completedAt,
    this.actualDurationSec,
    this.endedEarly = false,
  });

  final int id;
  final int? taskId;
  final int? subtaskId;
  final FocusSessionType sessionType;
  final int plannedDurationSec;
  final DateTime startedAt;

  /// Wall-clock anchor for the *current run segment* — null while paused.
  /// Reset to `DateTime.now()` every time the session starts or resumes.
  final DateTime? segmentStartedAt;

  /// Remaining seconds as of the start of the current segment. This is
  /// the only stored countdown value; while running, the true remaining
  /// time is this minus elapsed wall-clock time since [segmentStartedAt].
  final int remainingSecAtSegmentStart;

  final bool isPaused;
  final DateTime? completedAt;
  final int? actualDurationSec;
  final bool endedEarly;

  bool get isRunning => !isPaused && completedAt == null;

  /// The actual remaining seconds right now — safe to call every second
  /// from the UI, and safe to call once after the app was backgrounded
  /// for any length of time; it is never stale, because it is always
  /// computed from a wall-clock timestamp rather than an accumulated tick.
  int get remainingSec {
    if (isPaused || segmentStartedAt == null) return remainingSecAtSegmentStart;
    final elapsed = DateTime.now().difference(segmentStartedAt!).inSeconds;
    final remaining = remainingSecAtSegmentStart - elapsed;
    return remaining < 0 ? 0 : remaining;
  }
}
