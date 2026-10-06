import 'package:atomic_assist/domain/recurrence/recurrence_rule.dart';
import 'package:atomic_assist/domain/recurrence/repeat_due.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 2026-10-05 is a Monday.
  final monday9 = DateTime(2026, 10, 5, 9);

  test('daily, done on the day: tomorrow at the same time', () {
    expect(
        nextRepeatDue(
            RecurrenceRule.daily(), DateTime(2026, 10, 5, 18), monday9),
        DateTime(2026, 10, 6, 18));
  });

  test('overdue: the next day after today, not after the old due', () {
    // Due last Monday, every Monday: next Monday, not today.
    expect(
        nextRepeatDue(RecurrenceRule([DateTime.monday]),
            DateTime(2026, 9, 28, 8), monday9),
        DateTime(2026, 10, 12, 8));
  });

  test('done early: one occurrence after the due day', () {
    // Due Thursday, every Mon and Thu, done on Monday: the next Monday.
    expect(
        nextRepeatDue(RecurrenceRule([DateTime.monday, DateTime.thursday]),
            DateTime(2026, 10, 8, 20), monday9),
        DateTime(2026, 10, 12, 20));
  });

  test('weekdays skip the weekend', () {
    expect(
        nextRepeatDue(RecurrenceRule.weekdays(), DateTime(2026, 10, 9, 17),
            DateTime(2026, 10, 9, 18)),
        DateTime(2026, 10, 12, 17));
  });

  test('keeps the wall-clock time across a daylight-saving change', () {
    // America/New_York leaves DST on 2026-11-01 (R7).
    expect(
        nextRepeatDue(RecurrenceRule.daily(), DateTime(2026, 10, 31, 9),
            DateTime(2026, 10, 31, 10)),
        DateTime(2026, 11, 1, 9));
  });
}
