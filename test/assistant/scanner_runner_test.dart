import 'dart:convert';

import 'package:atomic_assist/assistant/proposal_service.dart';
import 'package:atomic_assist/assistant/scanner_runner.dart';
import 'package:atomic_assist/assistant/tools/tool_registry.dart';
import 'package:atomic_assist/data/assistant/drift_tool_env.dart';
import 'package:atomic_assist/data/assistant/stored_rows.dart';
import 'package:atomic_assist/data/assistant/tool_executor.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/app_settings_repository_impl.dart';
import 'package:atomic_assist/data/repositories/assistant_repository_impl.dart';
import 'package:atomic_assist/data/repositories/focus_session_repository_impl.dart';
import 'package:atomic_assist/data/repositories/list_repository_impl.dart';
import 'package:atomic_assist/data/repositories/people_repository_impl.dart';
import 'package:atomic_assist/data/repositories/reminder_repository_impl.dart';
import 'package:atomic_assist/data/repositories/schedule_repository_impl.dart';
import 'package:atomic_assist/data/repositories/task_repository_impl.dart';
import 'package:atomic_assist/domain/assistant/autonomy.dart';
import 'package:atomic_assist/domain/assistant/proposal.dart';
import 'package:atomic_assist/domain/entities/app_settings.dart';
import 'package:atomic_assist/domain/entities/person.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:atomic_assist/l10n/l10n.dart';
import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_database.dart';

void main() {
  // Monday 5 October 2026, 10:20.
  final now = DateTime(2026, 10, 5, 10, 20);
  late AppDatabase db;
  late TaskRepositoryImpl tasks;
  late AssistantRepositoryImpl store;
  late AppSettingsRepositoryImpl settings;
  late ScannerRunner runner;
  late ProposalService proposals;

  setUp(() {
    db = createTestDatabase();
    tasks = TaskRepositoryImpl(db);
    store = AssistantRepositoryImpl(db);
    settings = AppSettingsRepositoryImpl(db);
    DriftToolEnv env() => DriftToolEnv(
          tasks: tasks,
          schedule: ScheduleRepositoryImpl(db),
          focus: FocusSessionRepositoryImpl(db),
          reminders: ReminderRepositoryImpl(db),
          lists: ListRepositoryImpl(db),
          people: PeopleRepositoryImpl(db),
          settings: settings,
          rows: StoredRows(db),
          now: clock.now(),
        );
    final executor = ToolExecutor(db: db, env: env);
    final registry = ToolRegistry();
    runner = ScannerRunner(
      tasks: tasks,
      schedule: ScheduleRepositoryImpl(db),
      people: PeopleRepositoryImpl(db),
      store: store,
      settings: settings,
      l10n: () => lookupAppLocalizations(const Locale('en')),
      registry: registry,
      executor: executor,
    );
    proposals = ProposalService(
        registry: registry, executor: executor, store: store, env: env);
  });
  tearDown(() => db.close());

  Future<List<Proposal>> open() =>
      withClock(Clock.fixed(now), () => store.watchOpenProposals(now).first);

  Future<int> run() => withClock(Clock.fixed(now), () => runner.run(now));

  Future<void> seed() async {
    await withClock(Clock.fixed(DateTime(2026, 9, 30)), () async {
      await tasks.createTask(
          title: 'Write report',
          priority: TaskPriority.high,
          dueAt: DateTime(2026, 10, 2, 17));
    });
    final people = PeopleRepositoryImpl(db);
    final priya = await people.createPerson('Priya');
    await people.addDate(
        personId: priya, kind: PersonDateKind.birthday, month: 10, day: 8);
  }

  test('what the scanners find becomes Inbox proposals, worded', () async {
    await seed();
    expect(await run(), 3);
    final ps = await open();
    final byReason = {for (final p in ps) p.reason: p};
    expect(byReason.keys, {
      ProposalReason.upcomingDate,
      ProposalReason.overdueDrift,
      ProposalReason.freeGapForTasks,
    });
    final birthday = byReason[ProposalReason.upcomingDate]!;
    expect(birthday.toolName, 'create_reminder');
    expect(jsonDecode(birthday.argsJson),
        {'title': 'Priya’s birthday', 'at': '2026-10-08T09:00'});
    expect(birthday.origin, ActionOrigin.context);
    final moved = jsonDecode(byReason[ProposalReason.overdueDrift]!.argsJson)
        as Map<String, Object?>;
    expect(moved['due'], '2026-10-06T17:00');
    expect(jsonDecode(byReason[ProposalReason.freeGapForTasks]!.argsJson), {
      'task_id': 1,
      'start': '2026-10-05T10:30',
      'minutes': 60,
    });
  });

  test('each one is a valid call: ACCEPT runs it', () async {
    await seed();
    await run();
    for (final p in await open()) {
      expect(await withClock(Clock.fixed(now), () => proposals.accept(p.id)),
          AcceptResult.done,
          reason: p.toolName);
    }
  });

  test('a second run adds nothing; a dismissed one never comes back', () async {
    await seed();
    await run();
    expect(await run(), 0);
    final birthday = (await open())
        .singleWhere((p) => p.reason == ProposalReason.upcomingDate);
    await proposals.dismiss(birthday.id);
    expect(await run(), 0);
    expect((await open()).map((p) => p.reason),
        isNot(contains(ProposalReason.upcomingDate)));
  });

  test('the kill switch stops every scanner', () async {
    await seed();
    await settings.save(const AppSettings(suggestions: false));
    expect(await run(), 0);
    expect(await open(), isEmpty);
  });

  test('HANDS-OFF: a reversible finding is done, with a ledger row', () async {
    await seed();
    await settings.save(const AppSettings(autonomy: AutonomyPreset.handsOff));
    await run();
    // Done on its own, so nothing waits in the Inbox.
    expect(await open(), isEmpty);
    final report = (await tasks.getTask(1))!;
    expect(report.dueAt, DateTime(2026, 10, 6, 17));
    final ledger = await db.select(db.assistantActions).get();
    expect(ledger.map((a) => a.toolName),
        containsAll(['create_reminder', 'update_task', 'schedule_task']));
    expect(ledger.every((a) => a.origin == ActionOrigin.context), isTrue);
    // And never twice.
    expect(await run(), 0);
  });
}
