import 'package:flowline/domain/entities/schedule_block.dart';
import 'package:flowline/domain/recurrence/occurrences.dart';
import 'package:flowline/domain/recurrence/recurrence_rule.dart';
import 'package:flutter_test/flutter_test.dart';

ScheduleBlock _series(
  RecurrenceRule rule, {
  DateTime? start,
  DateTime? end,
  DateTime? until,
}) =>
    ScheduleBlock(
      id: 7,
      title: 'Deep work',
      // Tuesday 10 March 2026.
      startTime: start ?? DateTime(2026, 3, 10, 9),
      endTime: end ?? DateTime(2026, 3, 10, 11),
      recurrence: rule,
      recurrenceUntil: until,
    );

void main() {
  group('RecurrenceRule', () {
    test('formats and parses the supported RRULE subset', () {
      for (final (rule, text) in [
        (RecurrenceRule.daily(), 'FREQ=DAILY'),
        (RecurrenceRule.weekdays(), 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR'),
        (RecurrenceRule([3, 1]), 'FREQ=WEEKLY;BYDAY=MO,WE'),
      ]) {
        expect(rule.format(), text);
        expect(RecurrenceRule.tryParse(text), rule);
      }
    });

    test('anything else is not a rule (never throws)', () {
      for (final text in [
        null,
        '',
        'FREQ=MONTHLY',
        'FREQ=WEEKLY',
        'FREQ=WEEKLY;BYDAY=XX',
        'FREQ=DAILY;INTERVAL=2',
        'garbage',
      ]) {
        expect(RecurrenceRule.tryParse(text), isNull, reason: '$text');
      }
    });

    test('needs at least one day', () {
      expect(() => RecurrenceRule(const []), throwsArgumentError);
    });

    test('knows its presets', () {
      expect(RecurrenceRule.daily().isDaily, isTrue);
      expect(RecurrenceRule.weekdays().isWeekdays, isTrue);
      expect(RecurrenceRule([1, 2]).isWeekdays, isFalse);
    });
  });

  group('occurrence ids', () {
    test('round-trip series and day, and never collide with row ids', () {
      final day = DateTime(2026, 3, 10);
      final id = occurrenceId(7, day);
      expect(id, isNegative);
      final decoded = decodeOccurrenceId(id)!;
      expect(decoded.seriesId, 7);
      expect(decoded.day, day);
      expect(decodeOccurrenceId(42), isNull);
    });

    test('differ by day', () {
      expect(occurrenceId(7, DateTime(2026, 3, 10)),
          isNot(occurrenceId(7, DateTime(2026, 3, 11))));
    });
  });

  group('occurrencesOverlapping', () {
    List<ScheduleBlock> on(ScheduleBlock series, DateTime day,
            {Set<DateTime> skip = const {}}) =>
        occurrencesOverlapping(series: series, day: day, skip: skip);

    test('daily: one occurrence at the same time each day', () {
      final o = on(_series(RecurrenceRule.daily()), DateTime(2026, 3, 12));
      expect(o, hasLength(1));
      expect(o.single.startTime, DateTime(2026, 3, 12, 9));
      expect(o.single.endTime, DateTime(2026, 3, 12, 11));
      expect(o.single.seriesId, 7);
      expect(o.single.occurrenceDate, DateTime(2026, 3, 12));
      expect(o.single.isComputedOccurrence, isTrue);
    });

    test('weekdays: nothing on Saturday', () {
      final series = _series(RecurrenceRule.weekdays());
      expect(on(series, DateTime(2026, 3, 13)), hasLength(1)); // Friday
      expect(on(series, DateTime(2026, 3, 14)), isEmpty); // Saturday
    });

    test('nothing before the series starts or after it ends', () {
      final series =
          _series(RecurrenceRule.daily(), until: DateTime(2026, 3, 12));
      expect(on(series, DateTime(2026, 3, 9)), isEmpty);
      expect(on(series, DateTime(2026, 3, 10)), hasLength(1));
      expect(on(series, DateTime(2026, 3, 12)), hasLength(1));
      expect(on(series, DateTime(2026, 3, 13)), isEmpty);
    });

    test('skipped days are left out', () {
      final series = _series(RecurrenceRule.daily());
      expect(on(series, DateTime(2026, 3, 11), skip: {DateTime(2026, 3, 11)}),
          isEmpty);
    });

    test('an overnight occurrence also belongs to the next morning', () {
      final series = _series(RecurrenceRule([DateTime.tuesday]),
          start: DateTime(2026, 3, 10, 22), end: DateTime(2026, 3, 11, 2));
      final wednesday = on(series, DateTime(2026, 3, 11));
      expect(wednesday, hasLength(1));
      expect(wednesday.single.occurrenceDate, DateTime(2026, 3, 10));
      expect(wednesday.single.endTime, DateTime(2026, 3, 11, 2));
    });

    test('keeps wall-clock times across a DST change', () {
      // US clocks go forward on Sunday 8 March 2026 and back on 1
      // November; CI reruns this under TZ=America/New_York.
      final series = _series(RecurrenceRule.daily(),
          start: DateTime(2026, 3, 1, 9), end: DateTime(2026, 3, 1, 10));
      for (final day in [
        DateTime(2026, 3, 8),
        DateTime(2026, 3, 9),
        DateTime(2026, 11, 1),
        DateTime(2026, 11, 2),
      ]) {
        final o = on(series, day).single;
        expect(o.startTime.hour, 9, reason: '$day');
        expect(o.endTime.hour, 10, reason: '$day');
        expect(o.occurrenceDate, day);
      }
    });
  });
}
