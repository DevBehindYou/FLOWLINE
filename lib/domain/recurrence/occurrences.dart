import '../entities/schedule_block.dart';
import '../time/calendar_day.dart';

// Expanding recurring series into the blocks of one day. Pure: the
// repository passes in the stored series and what to skip.

// A computed occurrence has no row, so it gets a stable negative id that
// encodes its series and day: -(seriesId * _dayRange + epochDay). Every
// id-keyed path (conflict checks, list keys, "exclude this block") keeps
// working, and the id alone is enough to store the occurrence later.
const _dayRange = 1000000;

int _epochDay(DateTime day) =>
    DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;

DateTime _fromEpochDay(int epochDay) {
  final utc = DateTime.utc(1970, 1, 1 + epochDay);
  return DateTime(utc.year, utc.month, utc.day);
}

/// The stand-in id of [seriesId]'s occurrence on [day].
int occurrenceId(int seriesId, DateTime day) =>
    -(seriesId * _dayRange + _epochDay(day));

/// The series and day a stand-in id from [occurrenceId] stands for, or
/// null for a real (positive) row id.
({int seriesId, DateTime day})? decodeOccurrenceId(int id) {
  if (id >= 0) return null;
  final n = -id;
  return (seriesId: n ~/ _dayRange, day: _fromEpochDay(n % _dayRange));
}

/// Minutes between two wall-clock times, ignoring DST: a 9:00-10:00 block
/// is 60 minutes on every day, including the day the clocks change.
int _wallClockMinutes(DateTime start, DateTime end) =>
    (_epochDay(end) - _epochDay(start)) * 24 * 60 +
    (end.hour * 60 + end.minute) -
    (start.hour * 60 + start.minute);

/// The occurrences of [series] that overlap [day]: the one starting that
/// day, and the previous day's if it runs past midnight. Days before the
/// series starts, after [ScheduleBlock.recurrenceUntil], on weekdays the
/// rule excludes, or in [skip] (deleted, or stored as their own rows)
/// produce nothing.
List<ScheduleBlock> occurrencesOverlapping({
  required ScheduleBlock series,
  required DateTime day,
  Set<DateTime> skip = const {},
}) {
  final rule = series.recurrence;
  if (rule == null) return const [];
  final first = startOfDay(series.startTime);
  final until = series.recurrenceUntil;
  final minutes = _wallClockMinutes(series.startTime, series.endTime);
  final dayStart = startOfDay(day);
  final dayEnd = addDays(day, 1);

  return [
    for (final candidate in [addDays(day, -1), dayStart])
      if (!candidate.isBefore(first) &&
          (until == null || !candidate.isAfter(until)) &&
          rule.occursOnWeekday(candidate.weekday) &&
          !skip.contains(candidate))
        ScheduleBlock(
          id: occurrenceId(series.id, candidate),
          title: series.title,
          startTime: DateTime(candidate.year, candidate.month, candidate.day,
              series.startTime.hour, series.startTime.minute),
          endTime: DateTime(candidate.year, candidate.month, candidate.day,
              series.startTime.hour, series.startTime.minute + minutes),
          source: series.source,
          isLocked: series.isLocked,
          recurrence: rule,
          recurrenceUntil: until,
          seriesId: series.id,
          occurrenceDate: candidate,
        ),
  ]
      .where((o) => o.startTime.isBefore(dayEnd) && o.endTime.isAfter(dayStart))
      .toList();
}
