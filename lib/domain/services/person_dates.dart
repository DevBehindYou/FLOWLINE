import '../entities/person.dart';
import '../time/calendar_day.dart';

/// Whether month/day is a real calendar date in some year (Feb 29
/// counts).
bool isValidMonthDay(int month, int day) {
  if (month < 1 || month > 12 || day < 1) return false;
  const lengths = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  return day <= lengths[month - 1];
}

bool _isLeap(int y) => (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;

/// The day [date] falls on in [year]: Feb 29 is kept on Feb 28 in a year
/// without one (docs/05 §15), never rolled to March 1.
DateTime occurrenceIn(PersonDate date, int year) {
  final day =
      date.month == 2 && date.day == 29 && !_isLeap(year) ? 28 : date.day;
  return DateTime(year, date.month, day);
}

/// The next time [date] comes round, from [today] (local midnight; today
/// itself counts).
DateTime nextOccurrence(PersonDate date, DateTime today) {
  final from = startOfDay(today);
  final thisYear = occurrenceIn(date, from.year);
  return thisYear.isBefore(from) ? occurrenceIn(date, from.year + 1) : thisYear;
}

/// Whole calendar days from [today] to the next occurrence (0 = today).
int daysUntil(PersonDate date, DateTime today) {
  final from = startOfDay(today);
  final next = nextOccurrence(date, from);
  var n = 0;
  var d = from;
  while (d.isBefore(next)) {
    d = addDays(d, 1);
    n++;
  }
  return n;
}

/// How many years it will be at the next occurrence (a birthday's age),
/// when the year is known.
int? yearsAtNext(PersonDate date, DateTime today) =>
    date.year == null ? null : nextOccurrence(date, today).year - date.year!;
