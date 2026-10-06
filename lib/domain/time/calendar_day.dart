import 'package:clock/clock.dart';

/// Calendar-day arithmetic for the whole app (rule R7 in
/// `docs/04-build-and-optimization-plan.md`).
///
/// Never use `Duration(days: n)` for calendar math: a `Duration` is an
/// exact number of seconds, and on a daylight-saving change a local day is
/// 23 or 25 hours long. `midnight.add(Duration(days: 1))` then lands on
/// 23:00 or 01:00, and every lookup keyed by a midnight `DateTime` (daily
/// totals, streaks, the selected day) silently misses. Building the date
/// from its year/month/day fields lets `DateTime` do the calendar math.
///
/// "Now" always comes from `package:clock` (rule R8), so tests can drive it.

/// Local midnight at the start of [moment]'s calendar day.
DateTime startOfDay(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day);

/// Local midnight [days] calendar days after [moment]'s day (negative for
/// earlier days). Always midnight, whatever the time of [moment].
DateTime addDays(DateTime moment, int days) =>
    DateTime(moment.year, moment.month, moment.day + days);

/// Whether [a] and [b] fall on the same local calendar day.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Local midnight today, read through `package:clock`.
DateTime today() => startOfDay(clock.now());

/// The half-open range `[start of day, start of next day)` for [moment].
({DateTime start, DateTime end}) dayRange(DateTime moment) =>
    (start: startOfDay(moment), end: addDays(moment, 1));
