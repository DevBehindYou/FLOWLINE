import '../time/calendar_day.dart';
import 'recurrence_rule.dart';

/// When a repeating task is due next after it is completed at [now]
/// (docs/05 §17): the first day of [rule] after both [due]'s day and
/// today, at [due]'s time of day. Completing an overdue chore doesn't
/// leave it overdue again; completing one early moves it one occurrence.
DateTime nextRepeatDue(RecurrenceRule rule, DateTime due, DateTime now) {
  final base = due.isAfter(now) ? due : now;
  for (var i = 1; i <= 7; i++) {
    final day = addDays(base, i);
    if (rule.occursOnWeekday(day.weekday)) {
      return DateTime(day.year, day.month, day.day, due.hour, due.minute);
    }
  }
  // A rule always has at least one weekday, so a week always finds it.
  throw StateError('no day in $rule');
}
