import '../entities/person.dart';
import '../entities/schedule_block.dart';
import '../entities/task.dart';
import '../services/free_time.dart';
import '../services/person_dates.dart';
import '../time/calendar_day.dart';

// Context scanners (docs/05 §5.2): pure functions over a snapshot of the
// user's data. Each finding is typed (no English here); the runner turns
// it into a proposal for a real tool, worded by l10n, and the Inbox shows
// it until the user accepts or dismisses it. None calls a model.

/// What the scanners look at, read once per run.
final class ScanSnapshot {
  const ScanSnapshot({
    required this.now,
    this.openTasks = const [],
    this.blocksToday = const [],
    this.people = const {},
    this.personDates = const [],
    this.openFollowUps = const [],
  });

  final DateTime now;
  final List<Task> openTasks;

  /// Today's blocks, occurrences of repeating ones included.
  final List<ScheduleBlock> blocksToday;
  final Map<int, Person> people;
  final List<PersonDate> personDates;
  final List<FollowUp> openFollowUps;
}

sealed class ScanFinding {
  const ScanFinding();

  /// One open proposal per key; a key that was ever dismissed or accepted
  /// is never proposed again.
  String get key;
}

/// A birthday, anniversary or other date within [upcomingDateDays].
final class UpcomingDateFinding extends ScanFinding {
  const UpcomingDateFinding(
      {required this.person, required this.date, required this.on});
  final Person person;
  final PersonDate date;

  /// This year's (or next year's) occurrence, midnight.
  final DateTime on;

  @override
  String get key => 'upcomingDate:${date.id}:${_iso(on)}';
}

/// An open task whose due time has passed.
final class OverdueTaskFinding extends ScanFinding {
  const OverdueTaskFinding(this.task);
  final Task task;

  @override
  String get key => 'overdueDrift:${task.id}:${_iso(task.dueAt!)}';
}

/// A free gap today and a high-priority task with no block.
final class FreeGapFinding extends ScanFinding {
  const FreeGapFinding(
      {required this.task, required this.start, required this.minutes});
  final Task task;
  final DateTime start;
  final int minutes;

  @override
  String get key => 'freeGap:${task.id}:${_iso(start)}';
}

/// A follow-up whose wait time has passed, still open.
final class FollowUpDueFinding extends ScanFinding {
  const FollowUpDueFinding({required this.followUp, required this.person});
  final FollowUp followUp;
  final Person person;

  @override
  String get key => 'followUpDue:${followUp.id}';
}

/// Today's blocks fill at least [overbookedShare] of the working day;
/// [move] is the last block that could go to tomorrow.
final class DayOverbookedFinding extends ScanFinding {
  const DayOverbookedFinding({required this.day, required this.move});
  final DateTime day;
  final ScheduleBlock move;

  @override
  String get key => 'dayOverbooked:${_iso(day)}';
}

/// How far ahead a person's date is mentioned.
const upcomingDateDays = 7;

/// Gaps at least this long are worth a task.
const freeGapMinutes = 45;

/// A suggested focus block is at most this long.
const freeGapSuggestMinutes = 60;

/// The working day the load and gaps are measured in.
const workdayStartHour = 9;
const workdayEndHour = 18;
const overbookedShare = 0.9;

List<ScanFinding> runScanners(ScanSnapshot s) => [
      ...upcomingDates(s),
      ...overdueTasks(s),
      ...freeGapForTasks(s),
      ...followUpsDue(s),
      ...dayOverbooked(s),
    ];

List<UpcomingDateFinding> upcomingDates(ScanSnapshot s) => [
      for (final d in s.personDates)
        if (s.people[d.personId] case final person?)
          if (daysUntil(d, startOfDay(s.now)) <= upcomingDateDays)
            UpcomingDateFinding(
                person: person,
                date: d,
                on: nextOccurrence(d, startOfDay(s.now))),
    ];

List<OverdueTaskFinding> overdueTasks(ScanSnapshot s) => [
      for (final t in s.openTasks)
        if (t.status != TaskStatus.done &&
            t.dueAt != null &&
            t.dueAt!.isBefore(s.now))
          OverdueTaskFinding(t),
    ];

/// The first gap of [freeGapMinutes] left in today's working day, for the
/// oldest high-priority task that has no block.
List<FreeGapFinding> freeGapForTasks(ScanSnapshot s) {
  final candidates = [
    for (final t in s.openTasks)
      if (t.priority == TaskPriority.high &&
          t.status != TaskStatus.done &&
          t.scheduleBlockId == null)
        t,
  ];
  if (candidates.isEmpty) return const [];
  final day = startOfDay(s.now);
  final end = DateTime(day.year, day.month, day.day, workdayEndHour);
  var from = DateTime(day.year, day.month, day.day, workdayStartHour);
  if (s.now.isAfter(from)) {
    // From the next quarter hour: nobody starts at 14:07.
    final q = s.now.add(Duration(minutes: 15 - s.now.minute % 15));
    from = DateTime(q.year, q.month, q.day, q.hour, q.minute);
  }
  final slots = findFreeSlots(
      blocks: s.blocksToday,
      from: from,
      to: end,
      minutes: freeGapMinutes,
      limit: 1);
  if (slots.isEmpty) return const [];
  final slot = slots.single;
  final minutes = slot.end.difference(slot.start).inMinutes;
  return [
    FreeGapFinding(
      task: candidates.reduce((a, b) => a.id < b.id ? a : b),
      start: slot.start,
      minutes:
          minutes < freeGapSuggestMinutes ? minutes : freeGapSuggestMinutes,
    ),
  ];
}

List<FollowUpDueFinding> followUpsDue(ScanSnapshot s) => [
      for (final f in s.openFollowUps)
        if (f.status == FollowUpStatus.open && !f.waitUntil.isAfter(s.now))
          if (s.people[f.personId] case final person?)
            FollowUpDueFinding(followUp: f, person: person),
    ];

List<DayOverbookedFinding> dayOverbooked(ScanSnapshot s) {
  final day = startOfDay(s.now);
  final start = DateTime(day.year, day.month, day.day, workdayStartHour);
  final end = DateTime(day.year, day.month, day.day, workdayEndHour);
  var busy = 0;
  for (final b in s.blocksToday) {
    final from = b.startTime.isBefore(start) ? start : b.startTime;
    final to = b.endTime.isAfter(end) ? end : b.endTime;
    if (to.isAfter(from)) busy += to.difference(from).inMinutes;
  }
  final workday = end.difference(start).inMinutes;
  if (busy < workday * overbookedShare) return const [];
  // The latest block that hasn't started and isn't locked or repeating
  // (a move of a repeating block is a different question).
  final movable = [
    for (final b in s.blocksToday)
      if (!b.isLocked &&
          b.startTime.isAfter(s.now) &&
          b.recurrence == null &&
          !b.isOccurrence &&
          b.id > 0)
        b,
  ]..sort((a, b) => a.startTime.compareTo(b.startTime));
  if (movable.isEmpty) return const [];
  return [DayOverbookedFinding(day: day, move: movable.last)];
}

String _iso(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
