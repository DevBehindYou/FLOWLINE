import '../entities/person.dart';
import '../entities/schedule_block.dart';
import '../entities/task.dart';
import '../time/calendar_day.dart';

// The daily rhythm (docs/05 §21): a briefing is typed sections built from
// the day's facts. Pure; the screen and the spoken script both word the
// same sections through l10n, so they never disagree.

/// Stored nowhere yet, but append-only like every enum that may be (R1).
enum BriefingKind { morning, checkIn, shutdown, weekly }

typedef UpcomingDate = ({Person person, PersonDate date, DateTime on});
typedef OpenFollowUp = ({FollowUp followUp, Person person});

/// What a briefing is built from, read once.
final class DayFacts {
  const DayFacts({
    required this.now,
    this.blocksToday = const [],
    this.blocksTomorrow = const [],
    this.openTasks = const [],
    this.upcomingDates = const [],
    this.openFollowUps = const [],
    this.openProposals = 0,
    this.actionsByAaToday = 0,
    this.focusSessionsToday = 0,
    this.focusMinutesToday = 0,
  });

  final DateTime now;
  final List<ScheduleBlock> blocksToday;
  final List<ScheduleBlock> blocksTomorrow;
  final List<Task> openTasks;
  final List<UpcomingDate> upcomingDates;
  final List<OpenFollowUp> openFollowUps;
  final int openProposals;

  /// Ledger entries today that AA did unasked (not `said`) and kept.
  final int actionsByAaToday;

  /// Completed focus sessions today (tasks keep no completion time, so
  /// focus is the day's measurable work).
  final int focusSessionsToday;
  final int focusMinutesToday;
}

sealed class BriefingSection {
  const BriefingSection();
}

/// How full the day is, and when it starts.
final class LoadSection extends BriefingSection {
  const LoadSection(
      {required this.blocks, required this.busyMinutes, this.first});
  final int blocks;
  final int busyMinutes;
  final ScheduleBlock? first;
}

/// At most [topTaskCount]: overdue first, then high priority, then the
/// soonest due.
final class TopTasksSection extends BriefingSection {
  const TopTasksSection(this.tasks);
  final List<Task> tasks;
}

/// People's dates in the coming week.
final class DatesSection extends BriefingSection {
  const DatesSection(this.dates);
  final List<UpcomingDate> dates;
}

final class ProposalsSection extends BriefingSection {
  const ProposalsSection(this.count);
  final int count;
}

final class DoneSection extends BriefingSection {
  const DoneSection({required this.sessions, required this.focusMinutes});
  final int sessions;
  final int focusMinutes;
}

/// What AA did on its own today; each is in Activity with UNDO.
final class ActionsByAaSection extends BriefingSection {
  const ActionsByAaSection(this.count);
  final int count;
}

/// Open tasks due today: MOVE UNFINISHED TO TOMORROW moves these.
final class UnfinishedSection extends BriefingSection {
  const UnfinishedSection(this.tasks);
  final List<Task> tasks;
}

final class FollowUpsSection extends BriefingSection {
  const FollowUpsSection(this.followUps);
  final List<OpenFollowUp> followUps;
}

/// Tomorrow's first block, or null for a clear morning.
final class TomorrowSection extends BriefingSection {
  const TomorrowSection(this.first);
  final ScheduleBlock? first;
}

final class Briefing {
  const Briefing(
      {required this.kind, required this.day, required this.sections});
  final BriefingKind kind;
  final DateTime day;
  final List<BriefingSection> sections;
}

const topTaskCount = 3;

/// Morning and shutdown (§21). Check-in and the weekly review are built
/// as their nearest neighbour until they get their own sections.
Briefing buildBriefing(BriefingKind kind, DayFacts f) {
  final day = startOfDay(f.now);
  final sections = switch (kind) {
    BriefingKind.morning || BriefingKind.checkIn => _morning(f),
    BriefingKind.shutdown || BriefingKind.weekly => _shutdown(f),
  };
  return Briefing(kind: kind, day: day, sections: sections);
}

List<BriefingSection> _morning(DayFacts f) {
  final blocks = [...f.blocksToday]
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
  final busy = blocks.fold<int>(
      0, (sum, b) => sum + b.endTime.difference(b.startTime).inMinutes);
  final upcoming = [
    for (final b in blocks)
      if (b.endTime.isAfter(f.now)) b,
  ];
  final top = topTasks(f.openTasks, f.now);
  return [
    LoadSection(
        blocks: blocks.length,
        busyMinutes: busy,
        first: upcoming.isEmpty ? null : upcoming.first),
    if (top.isNotEmpty) TopTasksSection(top),
    if (f.upcomingDates.isNotEmpty)
      DatesSection([...f.upcomingDates]..sort((a, b) => a.on.compareTo(b.on))),
    if (f.openProposals > 0) ProposalsSection(f.openProposals),
  ];
}

List<BriefingSection> _shutdown(DayFacts f) {
  final unfinished = unfinishedToday(f.openTasks, f.now);
  final tomorrow = [...f.blocksTomorrow]
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
  return [
    DoneSection(
        sessions: f.focusSessionsToday, focusMinutes: f.focusMinutesToday),
    if (f.actionsByAaToday > 0) ActionsByAaSection(f.actionsByAaToday),
    if (unfinished.isNotEmpty) UnfinishedSection(unfinished),
    if (f.openFollowUps.isNotEmpty) FollowUpsSection(f.openFollowUps),
    TomorrowSection(tomorrow.isEmpty ? null : tomorrow.first),
  ];
}

List<Task> topTasks(List<Task> open, DateTime now) {
  int rank(Task t) {
    final due = t.dueAt;
    if (due != null && due.isBefore(now)) return 0;
    if (t.priority == TaskPriority.high) return 1;
    return due == null ? 3 : 2;
  }

  final ranked = [
    for (final t in open)
      if (t.status != TaskStatus.done) t,
  ]..sort((a, b) {
      final r = rank(a).compareTo(rank(b));
      if (r != 0) return r;
      final ad = a.dueAt, bd = b.dueAt;
      if (ad != null && bd != null) return ad.compareTo(bd);
      if (ad != null) return -1;
      if (bd != null) return 1;
      return a.id.compareTo(b.id);
    });
  return ranked.take(topTaskCount).toList();
}

/// Open tasks due before the end of today (overdue ones included).
List<Task> unfinishedToday(List<Task> open, DateTime now) {
  final end = addDays(now, 1);
  return [
    for (final t in open)
      if (t.status != TaskStatus.done &&
          t.dueAt != null &&
          t.dueAt!.isBefore(end))
        t,
  ]..sort((a, b) => a.dueAt!.compareTo(b.dueAt!));
}
