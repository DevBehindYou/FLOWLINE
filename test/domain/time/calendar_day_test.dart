import 'package:clock/clock.dart';
import 'package:atomic_assist/domain/entities/focus_session.dart';
import 'package:atomic_assist/domain/services/focus_stats_calculator.dart';
import 'package:atomic_assist/domain/time/calendar_day.dart';
import 'package:flutter_test/flutter_test.dart';

// These dates straddle the 2026 US daylight-saving changes (spring
// forward 2026-03-08, fall back 2026-11-01). Under a DST timezone (CI also
// runs this file with TZ=America/New_York) those days are 23 and 25 hours
// long, which is exactly what broke the old Duration(days:) arithmetic
// (B1). Under UTC or IST they still pass; they just can't fail.
FocusSession _completed(int id, DateTime completedAt) => FocusSession(
      id: id,
      sessionType: FocusSessionType.focus,
      plannedDurationSec: 1500,
      startedAt: completedAt.subtract(const Duration(minutes: 25)),
      segmentStartedAt: null,
      remainingSecAtSegmentStart: 0,
      isPaused: false,
      completedAt: completedAt,
      actualDurationSec: 1500,
    );

void main() {
  group('calendar helpers', () {
    test('addDays always lands on local midnight, across both DST changes', () {
      for (final start in [DateTime(2026, 3, 7), DateTime(2026, 10, 31)]) {
        var day = start;
        for (var i = 1; i <= 3; i++) {
          day = addDays(day, 1);
          expect(day.hour, 0, reason: '$start + $i days gave $day');
          expect(day.day, DateTime(start.year, start.month, start.day + i).day);
        }
      }
    });

    test('addDays goes backwards and across months and years', () {
      expect(addDays(DateTime(2026, 3, 1, 15, 30), -1), DateTime(2026, 2, 28));
      expect(addDays(DateTime(2026, 12, 31), 1), DateTime(2027, 1, 1));
      expect(addDays(DateTime(2028, 2, 28), 1), DateTime(2028, 2, 29));
    });

    test('startOfDay drops the time; isSameDay compares calendar days', () {
      expect(
          startOfDay(DateTime(2026, 3, 8, 23, 59, 59)), DateTime(2026, 3, 8));
      expect(isSameDay(DateTime(2026, 3, 8), DateTime(2026, 3, 8, 23, 59)),
          isTrue);
      expect(isSameDay(DateTime(2026, 3, 8, 23, 59), DateTime(2026, 3, 9)),
          isFalse);
    });

    test('dayRange is the half-open day, even on a 23-hour day', () {
      final range = dayRange(DateTime(2026, 3, 8, 12));
      expect(range.start, DateTime(2026, 3, 8));
      expect(range.end, DateTime(2026, 3, 9));
    });

    test('today() reads package:clock', () {
      withClock(Clock.fixed(DateTime(2026, 3, 8, 18, 45)), () {
        expect(today(), DateTime(2026, 3, 8));
      });
    });
  });

  group('FocusStatsCalculator across DST (B1)', () {
    const calculator = FocusStatsCalculator();

    test('a streak is not broken by the spring-forward day', () {
      final sessions = [
        _completed(1, DateTime(2026, 3, 7, 10)),
        _completed(2, DateTime(2026, 3, 8, 10)),
        _completed(3, DateTime(2026, 3, 9, 10)),
      ];
      withClock(Clock.fixed(DateTime(2026, 3, 9, 20)), () {
        expect(calculator.currentStreak(sessions), 3);
      });
    });

    test('a streak is not broken by the fall-back day', () {
      final sessions = [
        _completed(1, DateTime(2026, 10, 31, 10)),
        _completed(2, DateTime(2026, 11, 1, 10)),
        _completed(3, DateTime(2026, 11, 2, 10)),
      ];
      withClock(Clock.fixed(DateTime(2026, 11, 2, 20)), () {
        expect(calculator.currentStreak(sessions), 3);
      });
    });

    test('daily totals keep one midnight-keyed bar per day across DST', () {
      final sessions = [
        _completed(1, DateTime(2026, 11, 1, 9)),
        _completed(2, DateTime(2026, 11, 2, 9)),
      ];
      withClock(Clock.fixed(DateTime(2026, 11, 3, 12)), () {
        final totals = calculator.dailyTotals(sessions, days: 7);
        expect(totals, hasLength(7));
        expect(totals.every((d) => d.date.hour == 0), isTrue);
        expect(totals.last.date, DateTime(2026, 11, 3));
        expect(totals.first.date, DateTime(2026, 10, 28));
        final byDate = {for (final d in totals) d.date: d.sessionCount};
        expect(byDate[DateTime(2026, 11, 1)], 1);
        expect(byDate[DateTime(2026, 11, 2)], 1);
      });
    });
  });
}
