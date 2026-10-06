import '../entities/focus_session.dart';
import '../time/calendar_day.dart';

class DailyFocusTotal {
  const DailyFocusTotal({
    required this.date,
    required this.totalSeconds,
    required this.sessionCount,
  });

  /// Day-only (midnight, local time).
  final DateTime date;
  final int totalSeconds;
  final int sessionCount;
}

/// Pure, framework-free stats over completed focus sessions — no
/// Flutter, no Drift, so both numbers here are unit-testable without a
/// device. Deliberately counts *any* completed focus session (full or
/// ended-early) toward a day's streak/totals: showing up and focusing
/// for part of a session is still real consistency, unlike the stricter
/// "only a full, not-ended-early session" rule Phase 2 uses for
/// crediting a subtask's logged-pomodoro count — that one is about
/// finishing a specific unit of planned work, a different question from
/// "did you focus at all that day."
class FocusStatsCalculator {
  const FocusStatsCalculator();

  /// One entry per day for the last [days] days, oldest first, ending
  /// today — every day gets an entry even with zero sessions, so a chart
  /// never has to guess at a missing bar.
  List<DailyFocusTotal> dailyTotals(List<FocusSession> sessions,
      {int days = 7}) {
    final todayStart = today();
    final byDay = <DateTime, List<FocusSession>>{};
    for (final session in sessions) {
      if (session.sessionType != FocusSessionType.focus ||
          session.completedAt == null) {
        continue;
      }
      final day = startOfDay(session.completedAt!);
      byDay.putIfAbsent(day, () => []).add(session);
    }

    return List.generate(days, (i) {
      final day = addDays(todayStart, -(days - 1 - i));
      final daySessions = byDay[day] ?? const [];
      final total = daySessions.fold<int>(
          0, (sum, s) => sum + (s.actualDurationSec ?? 0));
      return DailyFocusTotal(
          date: day, totalSeconds: total, sessionCount: daySessions.length);
    });
  }

  /// Consecutive days with at least one completed focus session, walking
  /// back from today. Today having none *yet* doesn't break the streak
  /// on its own — the day isn't over — so the walk starts from yesterday
  /// in that case instead of zeroing out mid-afternoon.
  int currentStreak(List<FocusSession> sessions) {
    final qualifyingDays = <DateTime>{
      for (final s in sessions)
        if (s.sessionType == FocusSessionType.focus && s.completedAt != null)
          startOfDay(s.completedAt!),
    };

    final todayStart = today();
    var cursor = qualifyingDays.contains(todayStart)
        ? todayStart
        : addDays(todayStart, -1);

    var streak = 0;
    while (qualifyingDays.contains(cursor)) {
      streak++;
      cursor = addDays(cursor, -1);
    }
    return streak;
  }
}
