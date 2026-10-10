import 'package:atomic_assist/domain/assistant/briefing.dart';
import 'package:atomic_assist/domain/entities/person.dart';
import 'package:atomic_assist/domain/entities/schedule_block.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:atomic_assist/features/briefing/view/briefing_text.dart';
import 'package:atomic_assist/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  // Monday 5 October 2026, 07:30.
  final now = DateTime(2026, 10, 5, 7, 30);
  final made = DateTime(2026, 9, 1);
  final l10n = lookupAppLocalizations(const Locale('en'));
  setUpAll(() => initializeDateFormatting('en'));

  Task task(int id, String title,
          {TaskPriority priority = TaskPriority.medium, DateTime? due}) =>
      Task(
          id: id,
          title: title,
          priority: priority,
          status: TaskStatus.todo,
          dueAt: due,
          createdAt: made);

  ScheduleBlock block(int id, String title, DateTime start, DateTime end) =>
      ScheduleBlock(id: id, title: title, startTime: start, endTime: end);

  group('morning', () {
    final facts = DayFacts(
      now: now,
      blocksToday: [
        block(2, 'Gym', DateTime(2026, 10, 5, 18), DateTime(2026, 10, 5, 19)),
        block(1, 'Standup', DateTime(2026, 10, 5, 9),
            DateTime(2026, 10, 5, 9, 15)),
      ],
      openTasks: [
        task(1, 'Someday'),
        task(2, 'Ship it', priority: TaskPriority.high),
        task(3, 'Invoice', due: DateTime(2026, 10, 4, 17)), // overdue
        task(4, 'Slides', due: DateTime(2026, 10, 6, 12)),
      ],
      upcomingDates: [
        (
          person: const Person(id: 1, name: 'Priya'),
          date: const PersonDate(
              id: 1,
              personId: 1,
              kind: PersonDateKind.birthday,
              month: 10,
              day: 8),
          on: DateTime(2026, 10, 8),
        ),
      ],
      openProposals: 2,
    );
    final b = buildBriefing(BriefingKind.morning, facts);

    test('load, top tasks, dates, suggestions, in that order', () {
      expect(b.sections.map((s) => s.runtimeType), [
        LoadSection,
        TopTasksSection,
        DatesSection,
        ProposalsSection,
      ]);
      final load = b.sections.first as LoadSection;
      expect(load.blocks, 2);
      expect(load.busyMinutes, 75);
      expect(load.first!.title, 'Standup');
    });

    test('top tasks: overdue, then high priority, then soonest due', () {
      final top = (b.sections[1] as TopTasksSection).tasks;
      expect(top.map((t) => t.title), ['Invoice', 'Ship it', 'Slides']);
    });

    test('worded: headline and lines', () {
      final h = l10n.briefingHeadline(b);
      expect(h.first, '2 blocks today.');
      expect(h.second, 'Start with Invoice.');
      final blocks = l10n.briefingBlocks(b);
      expect(blocks.first.lines.first, '2 blocks · 75 min');
      expect(blocks[2].lines.single, 'Priya · Birthday · In 3 days');
      expect(blocks.last.lines.single, '2 suggestions in the Inbox');
      expect(l10n.briefingScript(b), startsWith('2 blocks today. Start with'));
    });

    test('a clear day says so', () {
      final empty = buildBriefing(BriefingKind.morning, DayFacts(now: now));
      expect(empty.sections.single, isA<LoadSection>());
      final h = l10n.briefingHeadline(empty);
      expect('${h.first} ${h.second}', 'A clear day. Nothing due.');
    });
  });

  group('shutdown', () {
    final evening = DateTime(2026, 10, 5, 18, 30);
    final b = buildBriefing(
      BriefingKind.shutdown,
      DayFacts(
        now: evening,
        openTasks: [
          task(1, 'Invoice', due: DateTime(2026, 10, 5, 17)),
          task(2, 'Old', due: DateTime(2026, 10, 2, 9)),
          task(3, 'Tomorrow thing', due: DateTime(2026, 10, 6, 9)),
        ],
        blocksTomorrow: [
          block(5, 'Kickoff', DateTime(2026, 10, 6, 10),
              DateTime(2026, 10, 6, 11)),
        ],
        openFollowUps: [
          (
            followUp: FollowUp(
                id: 1,
                personId: 2,
                about: 'invoice',
                waitUntil: DateTime(2026, 10, 9),
                status: FollowUpStatus.open),
            person: const Person(id: 2, name: 'Ravi'),
          ),
        ],
        actionsByAaToday: 1,
        focusSessionsToday: 2,
        focusMinutesToday: 50,
      ),
    );

    test('done, by AA, unfinished (due today or before), waiting, tomorrow',
        () {
      expect(b.sections.map((s) => s.runtimeType), [
        DoneSection,
        ActionsByAaSection,
        UnfinishedSection,
        FollowUpsSection,
        TomorrowSection,
      ]);
      expect((b.sections[2] as UnfinishedSection).tasks.map((t) => t.title),
          ['Old', 'Invoice']);
    });

    test('worded', () {
      final h = l10n.briefingHeadline(b);
      expect(h.first, '50 minutes of focus.');
      expect(h.second, startsWith('Tomorrow starts at 10:00'));
      final lines = l10n.briefingBlocks(b).expand((x) => x.lines).toList();
      expect(lines, contains('2 focus sessions · 50 min'));
      expect(lines, contains('Ravi · invoice'));
    });
  });

  test('stored enums keep their order (R1)', () {
    expect(BriefingKind.values.map((k) => k.name),
        ['morning', 'checkIn', 'shutdown', 'weekly']);
  });
}
