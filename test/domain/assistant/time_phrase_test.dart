import 'package:atomic_assist/domain/assistant/time_phrase.dart';
import 'package:flutter_test/flutter_test.dart';

// Monday 5 October 2026, 16:40.
final _now = DateTime(2026, 10, 5, 16, 40);
DateTime _d(int day, [int hour = 0, int minute = 0, int month = 10]) =>
    DateTime(2026, month, day, hour, minute);

void main() {
  // phrase → expected (AtInstant or OnDay), all at _now.
  final cases = <String, TimePhrase?>{
    // Bare hours today pick the next time the clock shows them.
    'at 7': AtInstant(_d(5, 19)),
    'at 5': AtInstant(_d(5, 17)),
    'at 4': AtInstant(_d(6, 4)), // 04:00 and 16:00 have passed
    'at 12': AtInstant(_d(6, 0)), // noon passed; midnight next
    '@9': AtInstant(_d(5, 21)),
    // Explicit meridiem and 24-hour.
    'at 7pm': AtInstant(_d(5, 19)),
    '7 pm': AtInstant(_d(5, 19)),
    '7p.m.': AtInstant(_d(5, 19)),
    'at 9am': AtInstant(_d(6, 9)), // passed today → tomorrow
    '8 am': AtInstant(_d(6, 8)),
    'at 12pm': AtInstant(_d(6, 12)),
    'at 12am': AtInstant(_d(6, 0)),
    '19:00': AtInstant(_d(5, 19)),
    'at 18:30': AtInstant(_d(5, 18, 30)),
    '07:30': AtInstant(_d(6, 7, 30)),
    'at 7:45 pm': AtInstant(_d(5, 19, 45)),
    '7.15pm': AtInstant(_d(5, 19, 15)),
    'noon': AtInstant(_d(6, 12)),
    'at midnight': AtInstant(_d(6, 0)),
    // Relative.
    'in 20 minutes': AtInstant(_d(5, 17)),
    'in 20 mins': AtInstant(_d(5, 17)),
    'in 20m': AtInstant(_d(5, 17)),
    'in 2 hours': AtInstant(_d(5, 18, 40)),
    'in an hour': AtInstant(_d(5, 17, 40)),
    'in half an hour': AtInstant(_d(5, 17, 10)),
    'in 90 minutes': AtInstant(_d(5, 18, 10)),
    '10 min baad': AtInstant(_d(5, 16, 50)),
    '2 ghante baad': AtInstant(_d(5, 18, 40)),
    // Days.
    'today': OnDay(_d(5)),
    'aaj': OnDay(_d(5)),
    'tomorrow': OnDay(_d(6)),
    'tmrw': OnDay(_d(6)),
    'kal': OnDay(_d(6)),
    'parso': OnDay(_d(7)),
    'day after tomorrow': OnDay(_d(7)),
    'on friday': OnDay(_d(9)),
    'friday': OnDay(_d(9)),
    'fri': OnDay(_d(9)),
    'next monday': OnDay(_d(12)), // today is Monday: next week's
    'monday': OnDay(_d(12)),
    'this sunday': OnDay(_d(11)),
    'on 2026-10-20': OnDay(_d(20)),
    '20 oct': OnDay(_d(20)),
    'oct 20': OnDay(_d(20)),
    '20th october': OnDay(_d(20)),
    'on 3rd jan': OnDay(DateTime(2027, 1, 3)), // already passed this year
    // Days with times.
    'tomorrow at 7': AtInstant(_d(6, 7)),
    'tomorrow at 3': AtInstant(_d(6, 15)), // 1–6 on another day: pm
    'tomorrow at 8pm': AtInstant(_d(6, 20)),
    'at 7 tomorrow': AtInstant(_d(6, 7)),
    'kal 5 baje': AtInstant(_d(6, 17)),
    'friday at 10:30': AtInstant(_d(9, 10, 30)),
    'on friday 6pm': AtInstant(_d(9, 18)),
    '2026-10-20 14:00': AtInstant(_d(20, 14)),
    // Parts of the day.
    'tomorrow morning': AtInstant(_d(6, 9)),
    'kal subah': AtInstant(_d(6, 9)),
    'tonight': AtInstant(_d(5, 20)),
    'this evening': AtInstant(_d(5, 18)),
    'aaj shaam': AtInstant(_d(5, 18)),
    'friday evening at 7': AtInstant(_d(9, 19)),
    'tomorrow afternoon': AtInstant(_d(6, 14)),
    'raat 9 baje': AtInstant(_d(5, 21)),
    'tomorrow night': AtInstant(_d(6, 20)),
    'morning': AtInstant(_d(6, 9)), // 9:00 has passed today
    // Nothing to find.
    'buy milk': null,
    'call mum': null,
    'at 25': null,
    '': null,
  };

  for (final MapEntry(key: phrase, value: expected) in cases.entries) {
    test('"$phrase"', () {
      expect(parseTimePhrase(phrase, now: _now), expected);
    });
  }

  test('the phrase can be taken out of a sentence', () {
    final m = findTimePhrase('call Mum tomorrow at 7 please', now: _now)!;
    expect(m.value, AtInstant(_d(6, 7)));
    expect(m.strip('call Mum tomorrow at 7 please'), 'call Mum please');
  });

  test('relative phrases strip their "in"', () {
    const text = 'stretch in 20 minutes';
    final m = findTimePhrase(text, now: _now)!;
    expect(m.strip(text), 'stretch');
  });

  test('day parts are configurable', () {
    expect(
        parseTimePhrase('tomorrow morning',
            now: _now, parts: const DayParts(morning: 7)),
        AtInstant(_d(6, 7)));
  });

  test('early in the day, a bare hour is the morning one', () {
    expect(parseTimePhrase('at 7', now: DateTime(2026, 10, 5, 6, 10)),
        AtInstant(_d(5, 7)));
  });

  test('late at night, "at 7" is tomorrow morning', () {
    expect(parseTimePhrase('at 7', now: DateTime(2026, 10, 5, 23, 30)),
        AtInstant(_d(6, 7)));
  });

  test('tomorrow across a DST change is the next calendar day (R7)', () {
    // US DST ends 2026-11-01; the local day is 25 hours long there.
    final saturday = DateTime(2026, 10, 31, 22);
    expect(parseTimePhrase('tomorrow at 9', now: saturday),
        AtInstant(DateTime(2026, 11, 1, 9)));
    expect(parseTimePhrase('day after tomorrow', now: saturday),
        OnDay(DateTime(2026, 11, 2)));
  });

  test('month and year roll over', () {
    final lateDec = DateTime(2026, 12, 31, 20);
    expect(
        parseTimePhrase('tomorrow', now: lateDec), OnDay(DateTime(2027, 1, 1)));
  });

  test('"today at 9" said at 16:40 stays in the past for the caller', () {
    expect(parseTimePhrase('today at 9am', now: _now), AtInstant(_d(5, 9)));
  });
}
