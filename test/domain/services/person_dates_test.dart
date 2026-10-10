import 'package:atomic_assist/domain/entities/person.dart';
import 'package:atomic_assist/domain/services/person_dates.dart';
import 'package:flutter_test/flutter_test.dart';

PersonDate date(int month, int day, {int? year}) => PersonDate(
    id: 1,
    personId: 1,
    kind: PersonDateKind.birthday,
    month: month,
    day: day,
    year: year);

void main() {
  final today = DateTime(2026, 10, 6, 15, 30);

  test('later this year, today, or next year', () {
    expect(nextOccurrence(date(10, 9), today), DateTime(2026, 10, 9));
    expect(nextOccurrence(date(10, 6), today), DateTime(2026, 10, 6));
    expect(nextOccurrence(date(3, 1), today), DateTime(2027, 3, 1));
    expect(daysUntil(date(10, 9), today), 3);
    expect(daysUntil(date(10, 6), today), 0);
  });

  test('Feb 29 falls on Feb 28 in a year without one', () {
    expect(occurrenceIn(date(2, 29), 2027), DateTime(2027, 2, 28));
    expect(occurrenceIn(date(2, 29), 2028), DateTime(2028, 2, 29));
    expect(occurrenceIn(date(2, 29), 2100), DateTime(2100, 2, 28));
    expect(occurrenceIn(date(2, 29), 2000), DateTime(2000, 2, 29));
    expect(nextOccurrence(date(2, 29), today), DateTime(2027, 2, 28));
  });

  test('days count calendar days, across a DST change', () {
    // America/New_York leaves DST on 2026-11-01: still 26 days.
    expect(daysUntil(date(11, 1), today), 26);
    expect(daysUntil(date(11, 2), today), 27);
  });

  test('age at the next one', () {
    expect(yearsAtNext(date(10, 9, year: 1990), today), 36);
    expect(yearsAtNext(date(3, 1, year: 1990), today), 37);
    expect(yearsAtNext(date(3, 1), today), isNull);
  });

  test('valid month and day', () {
    expect(isValidMonthDay(2, 29), isTrue);
    expect(isValidMonthDay(2, 30), isFalse);
    expect(isValidMonthDay(4, 31), isFalse);
    expect(isValidMonthDay(13, 1), isFalse);
    expect(isValidMonthDay(12, 31), isTrue);
  });
}
