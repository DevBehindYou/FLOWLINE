import 'package:flowline/domain/entities/focus_session.dart';
import 'package:flowline/domain/services/focus_stats_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

FocusSession _session({
  required int id,
  FocusSessionType sessionType = FocusSessionType.focus,
  required DateTime startedAt,
  DateTime? completedAt,
  int? actualDurationSec,
  bool endedEarly = false,
}) {
  return FocusSession(
    id: id,
    sessionType: sessionType,
    plannedDurationSec: 1500,
    startedAt: startedAt,
    segmentStartedAt: null,
    remainingSecAtSegmentStart: 0,
    isPaused: true,
    completedAt: completedAt,
    actualDurationSec: actualDurationSec,
    endedEarly: endedEarly,
  );
}

void main() {
  const calculator = FocusStatsCalculator();
  final now = DateTime.now();
  DateTime daysAgo(int n) =>
      DateTime(now.year, now.month, now.day).subtract(Duration(days: n));

  group('dailyTotals', () {
    test('returns one zeroed entry per day when there are no sessions', () {
      final totals = calculator.dailyTotals(const [], days: 7);
      expect(totals, hasLength(7));
      expect(totals.every((d) => d.totalSeconds == 0 && d.sessionCount == 0),
          isTrue);
      expect(totals.last.date, daysAgo(0));
      expect(totals.first.date, daysAgo(6));
    });

    test('buckets a completed session under the day it completed on', () {
      final today = daysAgo(0);
      final sessions = [
        _session(
            id: 1,
            startedAt: today,
            completedAt: today,
            actualDurationSec: 900),
      ];
      final totals = calculator.dailyTotals(sessions, days: 7);
      expect(totals.last.totalSeconds, 900);
      expect(totals.last.sessionCount, 1);
    });

    test('sums multiple sessions completed on the same day', () {
      final today = daysAgo(0);
      final sessions = [
        _session(
            id: 1,
            startedAt: today,
            completedAt: today,
            actualDurationSec: 600),
        _session(
            id: 2,
            startedAt: today,
            completedAt: today,
            actualDurationSec: 300),
      ];
      final totals = calculator.dailyTotals(sessions, days: 7);
      expect(totals.last.totalSeconds, 900);
      expect(totals.last.sessionCount, 2);
    });

    test('excludes sessions with no completedAt (in-progress or abandoned)',
        () {
      final today = daysAgo(0);
      final sessions = [_session(id: 1, startedAt: today, completedAt: null)];
      final totals = calculator.dailyTotals(sessions, days: 7);
      expect(totals.last.totalSeconds, 0);
      expect(totals.last.sessionCount, 0);
    });

    test('excludes break sessions from focus totals', () {
      final today = daysAgo(0);
      final sessions = [
        _session(
          id: 1,
          sessionType: FocusSessionType.shortBreak,
          startedAt: today,
          completedAt: today,
          actualDurationSec: 300,
        ),
      ];
      final totals = calculator.dailyTotals(sessions, days: 7);
      expect(totals.last.totalSeconds, 0);
      expect(totals.last.sessionCount, 0);
    });

    test('excludes sessions completed outside the requested window', () {
      final tooOld = daysAgo(10);
      final sessions = [
        _session(
            id: 1,
            startedAt: tooOld,
            completedAt: tooOld,
            actualDurationSec: 900),
      ];
      final totals = calculator.dailyTotals(sessions, days: 7);
      expect(totals.every((d) => d.totalSeconds == 0), isTrue);
    });

    test(
        'counts an ended-early session toward its day total, same as a full one',
        () {
      final today = daysAgo(0);
      final sessions = [
        _session(
          id: 1,
          startedAt: today,
          completedAt: today,
          actualDurationSec: 400,
          endedEarly: true,
        ),
      ];
      final totals = calculator.dailyTotals(sessions, days: 7);
      expect(totals.last.totalSeconds, 400);
      expect(totals.last.sessionCount, 1);
    });

    test('treats a null actualDurationSec as zero rather than throwing', () {
      final today = daysAgo(0);
      final sessions = [_session(id: 1, startedAt: today, completedAt: today)];
      final totals = calculator.dailyTotals(sessions, days: 7);
      expect(totals.last.totalSeconds, 0);
      expect(totals.last.sessionCount, 1);
    });
  });

  group('currentStreak', () {
    test('is zero with no sessions', () {
      expect(calculator.currentStreak(const []), 0);
    });

    test('is one when only today has a completed session', () {
      final today = daysAgo(0);
      final sessions = [_session(id: 1, startedAt: today, completedAt: today)];
      expect(calculator.currentStreak(sessions), 1);
    });

    test('counts consecutive days including today', () {
      final sessions = [
        _session(id: 1, startedAt: daysAgo(0), completedAt: daysAgo(0)),
        _session(id: 2, startedAt: daysAgo(1), completedAt: daysAgo(1)),
        _session(id: 3, startedAt: daysAgo(2), completedAt: daysAgo(2)),
      ];
      expect(calculator.currentStreak(sessions), 3);
    });

    test('does not zero out just because today has no session yet', () {
      final sessions = [
        _session(id: 1, startedAt: daysAgo(1), completedAt: daysAgo(1)),
        _session(id: 2, startedAt: daysAgo(2), completedAt: daysAgo(2)),
      ];
      expect(calculator.currentStreak(sessions), 2);
    });

    test('breaks at the first gap walking backward from today', () {
      final sessions = [
        _session(id: 1, startedAt: daysAgo(0), completedAt: daysAgo(0)),
        // day -1 missing on purpose
        _session(id: 2, startedAt: daysAgo(2), completedAt: daysAgo(2)),
      ];
      expect(calculator.currentStreak(sessions), 1);
    });

    test('is zero when the most recent session was two days ago', () {
      final sessions = [
        _session(id: 1, startedAt: daysAgo(2), completedAt: daysAgo(2))
      ];
      expect(calculator.currentStreak(sessions), 0);
    });

    test('an ended-early session still extends the streak', () {
      final sessions = [
        _session(
            id: 1,
            startedAt: daysAgo(0),
            completedAt: daysAgo(0),
            endedEarly: true),
      ];
      expect(calculator.currentStreak(sessions), 1);
    });
  });
}
