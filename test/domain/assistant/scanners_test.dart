import 'package:atomic_assist/domain/assistant/scanners.dart';
import 'package:atomic_assist/domain/entities/person.dart';
import 'package:atomic_assist/domain/entities/schedule_block.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:atomic_assist/domain/recurrence/recurrence_rule.dart';
import 'package:flutter_test/flutter_test.dart';

/// The context scanners with a fixed clock (docs/05 §5.2, Phase H gate).
void main() {
  // Monday 5 October 2026, 10:20.
  final now = DateTime(2026, 10, 5, 10, 20);
  final made = DateTime(2026, 9, 1);

  Task task(int id,
          {TaskPriority priority = TaskPriority.medium,
          DateTime? due,
          TaskStatus status = TaskStatus.todo,
          int? block}) =>
      Task(
          id: id,
          title: 'T$id',
          priority: priority,
          status: status,
          dueAt: due,
          scheduleBlockId: block,
          createdAt: made);

  ScheduleBlock block(int id, int fromHour, int toHour,
          {bool locked = false, RecurrenceRule? repeat}) =>
      ScheduleBlock(
          id: id,
          title: 'B$id',
          startTime: DateTime(2026, 10, 5, fromHour),
          endTime: DateTime(2026, 10, 5, toHour),
          isLocked: locked,
          recurrence: repeat);

  const priya = Person(id: 1, name: 'Priya');
  const ravi = Person(id: 2, name: 'Ravi');

  group('upcomingDates', () {
    PersonDate date(int id, int month, int day) => PersonDate(
        id: id,
        personId: 1,
        kind: PersonDateKind.birthday,
        month: month,
        day: day);

    test('a date within 7 days, today included; not 8 days out', () {
      final found = upcomingDates(ScanSnapshot(
        now: now,
        people: const {1: priya},
        personDates: [
          date(1, 10, 5), // today
          date(2, 10, 12), // 7 days
          date(3, 10, 13), // 8 days
          date(4, 10, 4), // yesterday: next year
        ],
      ));
      expect(found.map((f) => f.date.id), [1, 2]);
      expect(found.last.on, DateTime(2026, 10, 12));
      expect(found.last.key, 'upcomingDate:2:2026-10-12');
    });

    test('a date of someone unknown is skipped', () {
      expect(
          upcomingDates(ScanSnapshot(now: now, personDates: [date(1, 10, 6)])),
          isEmpty);
    });

    test('across the new year', () {
      final found = upcomingDates(ScanSnapshot(
        now: DateTime(2026, 12, 29, 9),
        people: const {1: priya},
        personDates: [date(1, 1, 2)],
      ));
      expect(found.single.on, DateTime(2027, 1, 2));
    });
  });

  group('overdueTasks', () {
    test('open tasks past due only', () {
      final found = overdueTasks(ScanSnapshot(now: now, openTasks: [
        task(1, due: DateTime(2026, 10, 4, 17)),
        task(2, due: DateTime(2026, 10, 5, 17)), // later today
        task(3), // no due
        task(4, due: DateTime(2026, 10, 1), status: TaskStatus.done),
      ]));
      expect(found.map((f) => f.task.id), [1]);
      // Keyed by the due day: moving it makes a new suggestion possible.
      expect(found.single.key, 'overdueDrift:1:2026-10-04');
    });
  });

  group('freeGapForTasks', () {
    test('the first gap of 45 min from the next quarter hour, ≤ 60 min', () {
      final found = freeGapForTasks(ScanSnapshot(
        now: now,
        openTasks: [
          task(7, priority: TaskPriority.high),
          task(3, priority: TaskPriority.high),
          task(9), // medium: not suggested
        ],
        blocksToday: [block(1, 9, 11)],
      ));
      final f = found.single;
      expect(f.task.id, 3, reason: 'the oldest high-priority task');
      expect(f.start, DateTime(2026, 10, 5, 11));
      expect(f.minutes, freeGapSuggestMinutes);
    });

    test('a short gap gives a short block', () {
      final found = freeGapForTasks(ScanSnapshot(
        now: now,
        openTasks: [task(1, priority: TaskPriority.high)],
        blocksToday: [block(1, 9, 11), block(2, 12, 18)],
      ));
      expect(found.single.start, DateTime(2026, 10, 5, 11));
      expect(found.single.minutes, 60);
      final tight = freeGapForTasks(ScanSnapshot(
        now: now,
        openTasks: [task(1, priority: TaskPriority.high)],
        blocksToday: [
          block(1, 9, 11),
          ScheduleBlock(
              id: 2,
              title: 'B2',
              startTime: DateTime(2026, 10, 5, 11, 50),
              endTime: DateTime(2026, 10, 5, 18)),
        ],
      ));
      expect(tight.single.minutes, 50);
    });

    test('nothing when the day is full or no task needs a block', () {
      expect(
          freeGapForTasks(ScanSnapshot(
              now: now,
              openTasks: [task(1, priority: TaskPriority.high)],
              blocksToday: [block(1, 9, 18)])),
          isEmpty);
      expect(
          freeGapForTasks(ScanSnapshot(now: now, openTasks: [
            task(1, priority: TaskPriority.high, block: 4),
          ])),
          isEmpty);
    });

    test('after the working day, nothing', () {
      expect(
          freeGapForTasks(ScanSnapshot(
              now: DateTime(2026, 10, 5, 17, 30),
              openTasks: [task(1, priority: TaskPriority.high)])),
          isEmpty);
    });
  });

  group('followUpsDue', () {
    FollowUp follow(int id, DateTime wait,
            {FollowUpStatus status = FollowUpStatus.open}) =>
        FollowUp(
            id: id,
            personId: 2,
            about: 'invoice',
            waitUntil: wait,
            status: status);

    test('past the wait time and still open', () {
      final found = followUpsDue(ScanSnapshot(
        now: now,
        people: const {2: ravi},
        openFollowUps: [
          follow(1, DateTime(2026, 10, 5, 9)),
          follow(2, DateTime(2026, 10, 6, 9)),
          follow(3, DateTime(2026, 10, 1), status: FollowUpStatus.replied),
        ],
      ));
      expect(found.map((f) => f.followUp.id), [1]);
      expect(found.single.person.name, 'Ravi');
    });
  });

  group('dayOverbooked', () {
    test('≥ 90% of 09:00–18:00 booked: the last movable block', () {
      final found = dayOverbooked(ScanSnapshot(now: now, blocksToday: [
        block(1, 9, 12),
        block(2, 12, 15, repeat: RecurrenceRule.daily()),
        block(3, 15, 16),
        block(4, 16, 18, locked: true),
      ]));
      expect(found.single.move.id, 3);
      expect(found.single.key, 'dayOverbooked:2026-10-05');
    });

    test('under 90%: nothing', () {
      expect(
          dayOverbooked(ScanSnapshot(now: now, blocksToday: [
            block(1, 9, 12),
            block(2, 13, 17),
          ])),
          isEmpty);
    });

    test('full, but nothing left that can move: nothing', () {
      expect(
          dayOverbooked(ScanSnapshot(now: now, blocksToday: [
            block(1, 9, 18, locked: true),
          ])),
          isEmpty);
    });
  });

  test('runScanners collects every scanner', () {
    final all = runScanners(ScanSnapshot(
      now: now,
      openTasks: [task(1, due: DateTime(2026, 10, 1))],
      people: const {1: priya},
      personDates: const [
        PersonDate(
            id: 1,
            personId: 1,
            kind: PersonDateKind.birthday,
            month: 10,
            day: 8),
      ],
    ));
    expect(all.map((f) => f.runtimeType),
        containsAll([UpcomingDateFinding, OverdueTaskFinding]));
  });

  group('blockEndedWithOpenTasks', () {
    test('a block that ended with an open task: the next free gap', () {
      final found = blockEndedWithOpenTasks(ScanSnapshot(
        now: now, // 10:20
        openTasks: [
          task(5, block: 1),
          task(6, block: 1, status: TaskStatus.done),
        ],
        blocksToday: [block(1, 9, 10), block(2, 10, 11, locked: true)],
      ));
      final f = found.single;
      expect(f.task.id, 5);
      expect(f.start, DateTime(2026, 10, 5, 11));
      expect(f.minutes, 60);
      expect(f.key, 'blockEnded:1:5');
    });

    test('a block still running, or with nothing open: nothing', () {
      expect(
          blockEndedWithOpenTasks(ScanSnapshot(
              now: now,
              openTasks: [task(5, block: 1)],
              blocksToday: [block(1, 10, 11)])),
          isEmpty);
      expect(
          blockEndedWithOpenTasks(
              ScanSnapshot(now: now, blocksToday: [block(1, 9, 10)])),
          isEmpty);
    });
  });
}
