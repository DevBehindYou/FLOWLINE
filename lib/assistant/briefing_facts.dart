import '../domain/assistant/autonomy.dart';
import '../domain/assistant/briefing.dart';
import '../domain/assistant/ledger.dart';
import '../domain/assistant/scanners.dart';
import '../domain/entities/focus_session.dart';
import '../domain/entities/person.dart';
import '../domain/repositories/assistant_repository.dart';
import '../domain/repositories/focus_session_repository.dart';
import '../domain/repositories/people_repository.dart';
import '../domain/repositories/schedule_repository.dart';
import '../domain/repositories/task_repository.dart';
import '../domain/time/calendar_day.dart';

/// Reads what a briefing is built from (docs/05 §21), once, with one-shot
/// reads only.
final class BriefingFactsLoader {
  BriefingFactsLoader({
    required this.tasks,
    required this.schedule,
    required this.people,
    required this.store,
    required this.focus,
  });

  final TaskRepository tasks;
  final ScheduleRepository schedule;
  final PeopleRepository people;
  final AssistantRepository store;
  final FocusSessionRepository focus;

  Future<DayFacts> load(DateTime now) async {
    final today = startOfDay(now);
    final tomorrow = addDays(today, 1);

    final dates = await people.getAllDates();
    final followUps = await people.getOpenFollowUps();
    final byId = <int, Person>{
      for (final id in {
        for (final d in dates) d.personId,
        for (final f in followUps) f.personId,
      })
        if (await people.getPerson(id) case final p?) id: p,
    };

    final sessions = [
      for (final s in await focus.getCompletedSessionsInRange(today, tomorrow))
        if (s.sessionType == FocusSessionType.focus) s,
    ];
    final focusSeconds = sessions.fold<int>(
        0, (sum, s) => sum + (s.actualDurationSec ?? s.plannedDurationSec));

    final ledger = await store.getLedger(from: today, to: tomorrow);

    return DayFacts(
      now: now,
      blocksToday: await schedule.getBlocksForDay(today),
      blocksTomorrow: await schedule.getBlocksForDay(tomorrow),
      openTasks: await tasks.findTasks('', limit: 500),
      upcomingDates: [
        for (final f in upcomingDates(
            ScanSnapshot(now: now, people: byId, personDates: dates)))
          (person: f.person, date: f.date, on: f.on),
      ],
      openFollowUps: [
        for (final f in followUps)
          if (byId[f.personId] case final p?) (followUp: f, person: p),
      ],
      openProposals: await store.countOpenProposals(now),
      actionsByAaToday: ledger
          .where((e) =>
              e.origin != ActionOrigin.said && e.status == LedgerStatus.done)
          .length,
      focusSessionsToday: sessions.length,
      focusMinutesToday: focusSeconds ~/ 60,
    );
  }
}
