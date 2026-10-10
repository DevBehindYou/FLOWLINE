import 'package:atomic_assist/assistant/orchestrator.dart';
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
import 'package:atomic_assist/design/atomic.dart';
import 'package:atomic_assist/domain/assistant/autonomy.dart';
import 'package:atomic_assist/domain/assistant/utterance.dart';
import 'package:atomic_assist/domain/repositories/ai_repository.dart';
import 'package:atomic_assist/features/lists/view/list_detail_screen.dart';
import 'package:atomic_assist/features/lists/view/lists_screen.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_app.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late ListRepositoryImpl lists;
  setUp(() {
    db = createTestDatabase();
    lists = ListRepositoryImpl(db);
  });
  tearDown(() => db.close());

  test('a fresh database has the three default lists', () async {
    expect((await lists.getLists()).map((l) => l.name),
        ['Shopping', 'Errands', 'Packing']);
    expect((await lists.findByName('SHOPPING'))!.name, 'Shopping');
  });

  test('"add milk, eggs and bread to shopping" adds three, locally', () async {
    final executor = ToolExecutor(db: db, env: () => _env(db, lists));
    final orchestrator = AssistantOrchestrator(
      registry: ToolRegistry(),
      ai: _NoAi(),
      executor: executor,
      store: AssistantRepositoryImpl(db),
      env: () => _env(db, lists),
      autonomy: () async => AutonomyPreset.balanced,
    );
    final r = await orchestrator.handle(const Utterance(
        'add milk, eggs and bread to shopping',
        source: UtteranceSource.typed));
    expect(r, isA<TurnAnswered>());
    final shopping = (await lists.findByName('shopping'))!;
    expect((await lists.getItems(shopping.id)).map((i) => i.text),
        ['milk', 'eggs', 'bread']);
    expect(shopping.openCount, 3);
  });

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 5)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets('Lists shows each list with open / total', (tester) async {
    final shopping =
        (await tester.runAsync(() => lists.findByName('shopping')))!;
    await tester.runAsync(() async {
      final ids =
          await lists.addItems(shopping.id, ['Milk', 'Eggs'], at: clock.now());
      await lists.setChecked(ids.first, true, at: clock.now());
    });
    await pumpScreen(tester, db: db, child: const ListsScreen());
    expect(find.text('Shopping'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.text('0 / 0'), findsNWidgets(2));
  });

  testWidgets('a list: add, tick, clear ticked after a confirm',
      (tester) async {
    final shopping =
        (await tester.runAsync(() => lists.findByName('shopping')))!;
    await pumpScreen(tester,
        db: db, child: ListDetailScreen(listId: shopping.id));
    expect(find.text('Nothing on this list yet.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Coffee');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
    expect(find.text('Coffee'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await settle(tester);
    await tester.tap(find.bySemanticsLabel('Clear ticked'));
    await settle(tester);
    expect(
        find.text(
            '1 ticked item will be removed from Shopping. You can undo this.'),
        findsOneWidget);
    await tester.tap(find.widgetWithText(AtomicButton, 'Clear ticked'));
    await settle(tester);
    expect(find.text('Coffee'), findsNothing);
    // Each change was a tool call with a ledger row.
    final tools =
        (await tester.runAsync(() => db.select(db.assistantActions).get()))!
            .map((a) => a.toolName);
    expect(tools, ['add_list_items', 'check_list_item', 'clear_checked']);
  });
}

DriftToolEnv _env(AppDatabase db, ListRepositoryImpl lists) => DriftToolEnv(
      tasks: TaskRepositoryImpl(db),
      schedule: ScheduleRepositoryImpl(db),
      focus: FocusSessionRepositoryImpl(db),
      reminders: ReminderRepositoryImpl(db),
      lists: lists,
      people: PeopleRepositoryImpl(db),
      settings: AppSettingsRepositoryImpl(db),
      rows: StoredRows(db),
    );

final class _NoAi implements AIRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('the local grammar should have handled this');
}
