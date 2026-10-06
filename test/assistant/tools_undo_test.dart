import 'dart:convert';

import 'package:atomic_assist/assistant/tools/tool_registry.dart';
import 'package:atomic_assist/data/assistant/drift_tool_env.dart';
import 'package:atomic_assist/data/assistant/stored_rows.dart';
import 'package:atomic_assist/data/assistant/tool_executor.dart';
import 'package:atomic_assist/data/assistant/undo_service.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/app_settings_repository_impl.dart';
import 'package:atomic_assist/data/repositories/focus_session_repository_impl.dart';
import 'package:atomic_assist/data/repositories/list_repository_impl.dart';
import 'package:atomic_assist/data/repositories/people_repository_impl.dart';
import 'package:atomic_assist/data/repositories/reminder_repository_impl.dart';
import 'package:atomic_assist/data/repositories/schedule_repository_impl.dart';
import 'package:atomic_assist/data/repositories/task_repository_impl.dart';
import 'package:atomic_assist/domain/assistant/autonomy.dart';
import 'package:atomic_assist/domain/assistant/ledger.dart';
import 'package:atomic_assist/domain/assistant/tool.dart';
import 'package:atomic_assist/domain/entities/focus_session.dart';
import 'package:atomic_assist/domain/entities/reminder.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:atomic_assist/domain/recurrence/recurrence_rule.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_database.dart';

/// The Phase E exit gate (docs/05 §36, §37): for every tool that changes
/// something, run it through the real executor, then undo the turn, and
/// the database must equal the snapshot taken before.
void main() {
  // Monday 2026-10-05, 09:00.
  final now = DateTime(2026, 10, 5, 9);

  late AppDatabase db;
  late TaskRepositoryImpl tasks;
  late ScheduleRepositoryImpl schedule;
  late FocusSessionRepositoryImpl focus;
  late ToolRegistry registry;
  late ToolExecutor executor;
  late UndoService undo;
  late List<AfterCommit> effects;
  late StoredRows rows;
  final roundTripped = <String>{};

  // Seed: what a real day looks like.
  late int report,
      bank,
      inBlock,
      deepWork,
      gymSeries,
      sub1,
      callMum,
      milk,
      ravi,
      invoice;

  setUp(() async {
    db = createTestDatabase();
    tasks = TaskRepositoryImpl(db);
    schedule = ScheduleRepositoryImpl(db);
    focus = FocusSessionRepositoryImpl(db);
    rows = StoredRows(db);
    registry = ToolRegistry();
    effects = [];
    final handler = _Recorder(effects);
    executor = ToolExecutor(
      db: db,
      env: () => DriftToolEnv(
        tasks: tasks,
        schedule: schedule,
        focus: focus,
        reminders: ReminderRepositoryImpl(db),
        lists: ListRepositoryImpl(db),
        people: PeopleRepositoryImpl(db),
        settings: AppSettingsRepositoryImpl(db),
        rows: rows,
        now: clock.now(),
      ),
      effects: handler,
    );
    undo = UndoService(db: db, focus: focus, effects: handler);

    await withClock(Clock.fixed(now.subtract(const Duration(days: 1))),
        () async {
      report = await tasks.createTask(
          title: 'Write report',
          priority: TaskPriority.high,
          dueAt: DateTime(2026, 10, 6, 17));
      sub1 = await tasks.createSubtask(taskId: report, title: 'Outline');
      await tasks.createSubtask(taskId: report, title: 'Draft');
      bank = await tasks.createTask(
          title: 'Call bank', priority: TaskPriority.low);
      await tasks.setTaskStatus(bank, TaskStatus.done);
      deepWork = await schedule.createBlock(
          title: 'Deep work',
          startTime: DateTime(2026, 10, 5, 10),
          endTime: DateTime(2026, 10, 5, 11));
      inBlock = await tasks.createTask(
          title: 'Review PR',
          priority: TaskPriority.medium,
          scheduleBlockId: deepWork);
      gymSeries = await schedule.createBlock(
          title: 'Gym',
          startTime: DateTime(2026, 10, 1, 18),
          endTime: DateTime(2026, 10, 1, 19),
          recurrence: RecurrenceRule.daily());
      // Yesterday's finished session on the report's first subtask.
      final s = await focus.startSession(
          sessionType: FocusSessionType.focus,
          plannedDurationSec: 1500,
          taskId: report,
          subtaskId: sub1);
      await focus.completeSession(s, endedEarly: true);
      callMum = await ReminderRepositoryImpl(db)
          .create(title: 'Call Mum', fireAt: DateTime(2026, 10, 5, 19));
      // The default Shopping list, with one open and one ticked item.
      final lists = ListRepositoryImpl(db);
      final shopping = (await lists.findByName('shopping'))!;
      final ids = await lists.addItems(shopping.id, ['Milk', 'Bread'],
          at: DateTime(2026, 10, 4, 9));
      milk = ids.first;
      await lists.setChecked(ids.last, true, at: DateTime(2026, 10, 4, 10));
      // Ravi, with one open follow-up and its reminder.
      final people = PeopleRepositoryImpl(db);
      ravi = await people.createPerson('Ravi', relation: 'client');
      final chase = await ReminderRepositoryImpl(db).create(
          title: 'Ravi · invoice',
          fireAt: DateTime(2026, 10, 9, 10),
          kind: ReminderKind.followUp);
      invoice = await people.createFollowUp(
          personId: ravi,
          about: 'invoice',
          waitUntil: DateTime(2026, 10, 9, 10),
          reminderId: chase);
    });
  });
  tearDown(() => db.close());

  Future<Map<String, List<Map<String, Object?>>>> snapshot() async => {
        for (final t in UndoTable.values)
          t.name: [
            for (final r in await db
                .customSelect('SELECT * FROM ${rows.table(t).actualTableName} '
                    'ORDER BY rowid')
                .get())
              r.data,
          ],
      };

  Future<ExecutionResult> run(String tool, Map<String, Object?> args,
      {String group = 'g'}) async {
    final prepared = registry.prepare(tool, jsonEncode(args));
    expect(prepared, isA<Prepared>(), reason: '$prepared');
    return executor.execute((prepared as Prepared).call,
        groupId: group,
        origin: ActionOrigin.said,
        decision: Decision.executeWithUndo);
  }

  /// Runs [tool], checks it changed something, undoes it, and checks the
  /// database is back exactly.
  Future<Executed> roundTrip(String tool, Map<String, Object?> args) =>
      withClock(Clock.fixed(now), () async {
        final before = await snapshot();
        final result = await run(tool, args);
        expect(result, isA<Executed>(), reason: '$result');
        expect(await snapshot(), isNot(equals(before)),
            reason: '$tool changed nothing');
        expect(await undo.undoGroup('g'), UndoResult.undone);
        expect(await snapshot(), equals(before));
        final entry = await db.select(db.assistantActions).getSingle();
        expect(entry.status, LedgerStatus.undone);
        expect(entry.toolName, tool);
        roundTripped.add(tool);
        return result as Executed;
      });

  group('undo round trip, every tool that writes', () {
    test('create_task', () async {
      await roundTrip('create_task', {
        'title': 'Send deck to Priya',
        'due': '2026-10-09T17:00',
        'priority': 'high',
      });
    });

    test('update_task', () async {
      await roundTrip('update_task', {
        'task_id': report,
        'title': 'Write Q3 report',
        'clear_due': true,
        'notes': 'with charts',
      });
    });

    test('complete_task, by title', () async {
      await roundTrip('complete_task', {'task': 'write report'});
    });

    test('schedule_task (task already in a block moves back)', () async {
      await roundTrip('schedule_task',
          {'task_id': inBlock, 'start': '2026-10-05T14:00', 'minutes': 45});
    });

    test('break_down_task', () async {
      await roundTrip('break_down_task', {
        'task_id': report,
        'steps': ['Collect numbers', 'Write summary', 'Send for review'],
      });
    });

    test('create_block', () async {
      await roundTrip('create_block', {
        'title': 'Lunch',
        'start': '2026-10-05T13:00',
        'end': '2026-10-05T13:45',
      });
    });

    test('move_block, a one-off block', () async {
      await roundTrip('move_block', {
        'block_id': deepWork,
        'start': '2026-10-05T15:00',
        'end': '2026-10-05T16:00',
      });
    });

    test('move_block, one day of a repeating block', () async {
      final gymToday = (await schedule.getBlocksForDay(now))
          .singleWhere((b) => b.seriesId == gymSeries);
      expect(gymToday.isComputedOccurrence, isTrue);
      await roundTrip('move_block', {
        'block_id': gymToday.id,
        'start': '2026-10-05T19:00',
        'end': '2026-10-05T20:00',
      });
      // The computed occurrence is back, not a stored copy.
      final again = (await schedule.getBlocksForDay(now))
          .singleWhere((b) => b.seriesId == gymSeries);
      expect(again.isComputedOccurrence, isTrue);
      expect(again.startTime, DateTime(2026, 10, 5, 18));
    });

    test('start_focus (undone within a minute leaves no history)', () async {
      final result = await roundTrip('start_focus', {'task': 'Write report'});
      final id = result.outcome.result['session_id']! as int;
      expect(effects.map((e) => e.runtimeType), [FocusStarted, FocusStopped]);
      expect((effects.last as FocusStopped).sessionId, id);
    });

    test('delete_task restores the task, its subtasks and session links',
        () async {
      await roundTrip('delete_task', {'task_id': report});
    });

    test('create_reminder (linked to a task by title)', () async {
      final r = await roundTrip('create_reminder', {
        'title': 'Send the report',
        'at': '2026-10-06T09:30',
        'task': 'Write report',
      });
      expect(effects.whereType<ReminderTouched>().map((e) => e.reminderId),
          [r.outcome.result['reminder_id'], r.outcome.result['reminder_id']],
          reason: 'synced after the create and after its undo');
    });

    test('snooze_reminder', () async {
      await roundTrip('snooze_reminder',
          {'reminder_id': callMum, 'until': '2026-10-05T21:00'});
    });

    test('complete_reminder', () async {
      await roundTrip('complete_reminder', {'reminder_id': callMum});
    });

    test('add_list_items (skips what is already open on it)', () async {
      final r = await roundTrip('add_list_items', {
        'list': 'SHOPPING',
        'items': ['eggs', 'milk', 'Eggs', 'bread'],
      });
      // milk is open already; Eggs repeats eggs; bread was ticked, so it
      // goes back on.
      expect(r.outcome.result['added'], ['eggs', 'bread']);
    });

    test('check_list_item', () async {
      await roundTrip('check_list_item', {'item_id': milk});
    });

    test('clear_checked puts the ticked items back on undo', () async {
      await roundTrip('clear_checked', {'list': 'shopping'});
    });

    test('add_person_date for someone known', () async {
      await roundTrip('add_person_date',
          {'person': 'ravi', 'kind': 'anniversary', 'month': 3, 'day': 14});
    });

    test('add_person_date for someone new: undo removes them too', () async {
      final r = await roundTrip('add_person_date', {
        'person': 'Priya',
        'month': 10,
        'day': 9,
        'year': 1992,
      });
      expect(r.outcome.result['person_id'], isNot(ravi));
    });

    test('create_follow_up (with its reminder)', () async {
      await roundTrip('create_follow_up', {
        'person': 'Asha',
        'about': 'the deck',
        'wait_until': '2026-10-08T10:00',
      });
    });

    test('complete_follow_up closes its reminder too', () async {
      await roundTrip('complete_follow_up', {'follow_up_id': invoice});
    });

    test('delete_block restores the block and re-schedules its tasks',
        () async {
      await roundTrip('delete_block', {'block_id': deepWork});
    });
  });

  // Runs after the group above: a tool added to the registry without a
  // round-trip test fails here.
  test('every registered tool that writes has a round trip', () {
    final writers = {
      for (final t in ToolRegistry().tools)
        if (t.risk != ActionRisk.read) t.name,
    };
    expect(roundTripped, writers);
  });

  group('undo refuses rather than overwrite the user', () {
    test('a task edited since its completion was undone stays', () async {
      await withClock(Clock.fixed(now), () async {
        await run('complete_task', {'task_id': report});
        await tasks.setTaskStatus(report, TaskStatus.inProgress);
        expect(await undo.undoGroup('g'), UndoResult.changedSince);
        expect((await tasks.getTask(report))!.status, TaskStatus.inProgress);
        final entry = await db.select(db.assistantActions).getSingle();
        expect(entry.status, LedgerStatus.done);
      });
    });

    test('a whole turn rolls back when one step is refused', () async {
      await withClock(Clock.fixed(now), () async {
        await run('create_task', {'title': 'A'});
        await run('complete_task', {'task_id': report});
        await tasks.updateTask(
            (await tasks.getTask(report))!.copyWith(status: TaskStatus.todo));
        expect(await undo.undoGroup('g'), UndoResult.changedSince);
        // The created task is still there: nothing was undone in part.
        expect(await tasks.findTasks('A', includeDone: true), isNotEmpty);
      });
    });

    test('undoing twice does nothing the second time', () async {
      await withClock(Clock.fixed(now), () async {
        await run('create_task', {'title': 'Once'});
        expect(await undo.undoGroup('g'), UndoResult.undone);
        expect(await undo.undoGroup('g'), UndoResult.nothing);
      });
    });

    test('a focus session that ran for a while ends early instead', () async {
      final result = await withClock(
              Clock.fixed(now), () => run('start_focus', {'minutes': 25}))
          as Executed;
      final id = result.outcome.result['session_id']! as int;
      await withClock(Clock.fixed(now.add(const Duration(minutes: 10))),
          () async {
        expect(await undo.undoGroup('g'), UndoResult.undone);
        final s = (await focus.getSession(id))!;
        expect(s.completedAt, isNotNull);
        expect(s.endedEarly, isTrue);
        expect(s.actualDurationSec, 600);
      });
    });

    test('a focus session that already ended cannot be undone', () async {
      final result = await withClock(
              Clock.fixed(now), () => run('start_focus', {'minutes': 5}))
          as Executed;
      final id = result.outcome.result['session_id']! as int;
      await withClock(Clock.fixed(now.add(const Duration(minutes: 6))),
          () async {
        await focus.completeSession(id, endedEarly: false);
        expect(await undo.undoGroup('g'), UndoResult.changedSince);
      });
    });
  });

  group('validation against the current state (R16)', () {
    Future<Invalid> rejected(String tool, Map<String, Object?> args) =>
        withClock(Clock.fixed(now), () async {
          final result = await run(tool, args);
          expect(result, isA<Rejected>(), reason: '$result');
          return (result as Rejected).invalid;
        });

    test('nothing is recorded for a rejected call', () async {
      await rejected('complete_task', {'task_id': bank});
      expect(await db.select(db.assistantActions).get(), isEmpty);
    });

    test('reasons', () async {
      expect((await rejected('complete_task', {'task_id': bank})).reason,
          InvalidReason.alreadyDone);
      expect((await rejected('complete_task', {'task': 'nope'})).reason,
          InvalidReason.notFound);
      expect(
          (await rejected('create_task', {
            'title': 'Late',
            'due': '2026-10-04T10:00',
          }))
              .reason,
          InvalidReason.inPast);
      final overlap = await rejected('create_block', {
        'title': 'Clash',
        'start': '2026-10-05T10:30',
        'end': '2026-10-05T11:30',
      });
      expect(overlap.reason, InvalidReason.conflict);
      expect(overlap.detail, contains('Deep work'));
      expect(
          (await rejected('move_block', {
            'block_id': deepWork,
            'start': '2026-10-05T10:00',
            'end': '2026-10-05T11:00',
          }))
              .reason,
          InvalidReason.nothingToChange);
      expect(
          (await rejected('move_block', {
            'block_id': gymSeries,
            'start': '2026-10-05T07:00',
            'end': '2026-10-05T08:00',
          }))
              .reason,
          InvalidReason.notSupported);
      expect((await rejected('update_task', {'task_id': report})).reason,
          InvalidReason.nothingToChange);
      expect((await rejected('delete_block', {'block_id': 999})).reason,
          InvalidReason.notFound);
    });

    test('a title that matches several tasks is ambiguous', () async {
      await withClock(Clock.fixed(now), () async {
        await tasks.createTask(
            title: 'Write report appendix', priority: TaskPriority.low);
        await tasks.createTask(
            title: 'Write report summary', priority: TaskPriority.low);
      });
      // "Write report" is an exact match among them: no ambiguity.
      expect(
          await withClock(Clock.fixed(now),
              () => run('complete_task', {'task': 'write report'})),
          isA<Executed>());
      final invalid = await rejected('complete_task', {'task': 'report'});
      expect(invalid.reason, InvalidReason.ambiguous);
      expect(invalid.detail, contains('appendix'));
    });

    test('a second focus session while one is active is busy', () async {
      await withClock(Clock.fixed(now), () => run('start_focus', {}));
      expect((await rejected('start_focus', {})).reason, InvalidReason.busy);
    });
  });

  group('reads change nothing and write no ledger row', () {
    Future<Map<String, Object?>> read(String tool, Map<String, Object?> args) =>
        withClock(Clock.fixed(now), () async {
          final before = await snapshot();
          final result = await run(tool, args) as Executed;
          expect(result.entryId, isNull);
          expect(await snapshot(), equals(before));
          expect(await db.select(db.assistantActions).get(), isEmpty);
          return result.outcome.result;
        });

    test('get_agenda lists blocks with their tasks', () async {
      final agenda = await read('get_agenda', {'day': '2026-10-05'});
      final blocks = agenda['blocks']! as List;
      expect(blocks.map((b) => (b as Map)['title']), ['Deep work', 'Gym']);
      final deep = blocks.first as Map;
      expect(
          (deep['tasks'] as List).single, containsPair('title', 'Review PR'));
      expect((blocks.last as Map)['repeats'], isTrue);
    });

    test('find_free_time skips the past and busy blocks', () async {
      final free =
          await read('find_free_time', {'day': '2026-10-05', 'minutes': 60});
      // 09:05-10:00 (from now, rounded up) is only 55 minutes: skipped.
      expect(free['slots'], [
        {'start': '2026-10-05T11:00', 'end': '2026-10-05T18:00'},
        {'start': '2026-10-05T19:00', 'end': '2026-10-05T20:00'},
      ]);
    });

    test('search_tasks and get_task', () async {
      final found = await read('search_tasks', {'query': 'REPORT'});
      expect((found['tasks']! as List).single, containsPair('id', report));
      final open = await read('search_tasks', {'query': ''});
      expect((open['tasks']! as List).map((t) => (t as Map)['id']),
          isNot(contains(bank)));
      final task = await read('get_task', {'task_id': report});
      expect((task['subtasks']! as List).map((s) => (s as Map)['title']),
          ['Outline', 'Draft']);
    });
  });

  test('a tool that throws rolls back and records a failure', () async {
    await withClock(Clock.fixed(now), () async {
      final before = await snapshot();
      final result = await executor.execute(
        _Throws().prepare({}),
        groupId: 'g',
        origin: ActionOrigin.said,
        decision: Decision.executeWithUndo,
      );
      expect(result, isA<Failed>());
      expect(await snapshot(), equals(before));
      final entry = await db.select(db.assistantActions).getSingle();
      expect(entry.status, LedgerStatus.failed);
      expect(entry.undoJson, isNull);
    });
  });
}

final class _Recorder implements AfterCommitHandler {
  _Recorder(this.seen);
  final List<AfterCommit> seen;
  @override
  Future<void> handle(AfterCommit effect) async => seen.add(effect);
}

/// Writes, then throws: the write must not survive.
final class _Throws extends AssistantTool<Map<String, Object?>> {
  @override
  String get name => 'throws';
  @override
  String get description => '';
  @override
  Map<String, Object?> get parameters => const {'type': 'object'};
  @override
  ActionRisk get risk => ActionRisk.reversible;
  @override
  Map<String, Object?> parse(Map<String, Object?> json) => json;
  @override
  Future<ToolValidation> validate(Map<String, Object?> a, ToolEnv env) async =>
      const Valid();
  @override
  Future<Never> preview(Map<String, Object?> a, ToolEnv env) =>
      throw UnimplementedError();
  @override
  Future<ToolOutcome> run(Map<String, Object?> a, ToolEnv env) async {
    await env.tasks.createTask(title: 'ghost', priority: TaskPriority.low);
    throw StateError('boom');
  }
}
