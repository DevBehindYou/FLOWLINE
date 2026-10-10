import 'dart:convert';

import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/assistant_repository_impl.dart';
import 'package:atomic_assist/data/repositories/task_repository_impl.dart';
import 'package:atomic_assist/design/atomic.dart';
import 'package:atomic_assist/domain/assistant/action_preview.dart';
import 'package:atomic_assist/domain/assistant/autonomy.dart';
import 'package:atomic_assist/domain/assistant/ledger.dart';
import 'package:atomic_assist/domain/assistant/proposal.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:atomic_assist/features/inbox/view/activity_screen.dart';
import 'package:atomic_assist/features/inbox/view/inbox_screen.dart';
import 'package:atomic_assist/features/library/view/library_screen.dart';
import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_app.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late TaskRepositoryImpl tasks;
  late AssistantRepositoryImpl store;

  setUp(() {
    db = createTestDatabase();
    tasks = TaskRepositoryImpl(db);
    store = AssistantRepositoryImpl(db);
  });
  tearDown(() => db.close());

  /// Lets database work started by a tap finish between frames.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 5)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  /// A task AA created earlier today, with its ledger row.
  Future<int> createdByAa(WidgetTester tester, String title) async {
    return (await tester.runAsync(() async {
      final id =
          await tasks.createTask(title: title, priority: TaskPriority.medium);
      await db
          .into(db.assistantActions)
          .insert(AssistantActionsCompanion.insert(
            at: clock.now(),
            groupId: 'g-$id',
            toolName: 'create_task',
            argsJson: jsonEncode({'title': title}),
            origin: ActionOrigin.said,
            decision: Decision.executeWithUndo,
            status: LedgerStatus.done,
            undoJson:
                Value(encodeUndoRecipe(DeleteRows(UndoTable.tasks, [id]))),
            previewJson: Value(jsonEncode(previewToJson(CreateTaskPreview(
                title: title, priority: TaskPriority.medium)))),
          ));
      return id;
    }))!;
  }

  Future<int> suggest(
          WidgetTester tester, String tool, Map<String, Object?> args,
          {String key = 'k1'}) async =>
      (await tester.runAsync(() => store.createProposal(
          ProposalDraft(
            toolName: tool,
            argsJson: jsonEncode(args),
            origin: ActionOrigin.commitment,
            reason: ProposalReason.commitment,
            dedupeKey: key,
            sourceText: 'I told Priya I would send the deck',
          ),
          at: clock.now())))!;

  group('Inbox', () {
    testWidgets('empty: says so', (tester) async {
      await pumpScreen(tester, db: db, child: const InboxScreen());
      expect(find.text("You're clear"), findsOneWidget);
    });

    testWidgets('a suggestion shows what it would do; accept does it',
        (tester) async {
      await suggest(tester, 'create_task', {'title': 'Send deck to Priya'});
      await pumpScreen(tester, db: db, child: const InboxScreen());
      await settle(tester);
      expect(find.text('FROM SOMETHING YOU SAID'), findsOneWidget);
      expect(find.text('CREATED TASK'), findsOneWidget);
      expect(find.text('Send deck to Priya'), findsOneWidget);
      expect(find.text('You said: I told Priya I would send the deck'),
          findsOneWidget);

      await tester.tap(find.widgetWithText(AtomicButton, 'Accept'));
      await settle(tester);
      expect(
          await tester.runAsync(() => tasks.findTasks('deck')), hasLength(1));
      // Gone from SUGGESTED, now under DONE BY AA TODAY with UNDO.
      expect(find.text('FROM SOMETHING YOU SAID'), findsNothing);
      expect(find.widgetWithText(AtomicButton, 'UNDO'), findsOneWidget);
    });

    testWidgets('dismiss removes it and does nothing', (tester) async {
      await suggest(tester, 'create_task', {'title': 'Maybe later'});
      await pumpScreen(tester, db: db, child: const InboxScreen());
      await settle(tester);
      await tester.tap(find.widgetWithText(AtomicButton, 'Dismiss'));
      await settle(tester);
      expect(find.text("You're clear"), findsOneWidget);
      expect(await tester.runAsync(() => tasks.findTasks('Maybe')), isEmpty);
    });

    testWidgets('a suggestion whose target is gone cannot be accepted',
        (tester) async {
      final id = (await tester.runAsync(() =>
          tasks.createTask(title: 'Report', priority: TaskPriority.low)))!;
      await suggest(tester, 'complete_task', {'task_id': id});
      await tester.runAsync(() => tasks.deleteTask(id));
      await pumpScreen(tester, db: db, child: const InboxScreen());
      await settle(tester);
      expect(
          find.text(
              'No longer possible. Things changed since it was suggested.'),
          findsOneWidget);
      expect(find.widgetWithText(AtomicButton, 'Accept'), findsNothing);
    });

    testWidgets("today's actions can be undone from the Inbox", (tester) async {
      await createdByAa(tester, 'Buy milk');
      await pumpScreen(tester, db: db, child: const InboxScreen());
      await settle(tester);
      expect(find.text('DONE BY AA TODAY · 1'), findsOneWidget);
      await tester.tap(find.widgetWithText(AtomicButton, 'UNDO'));
      await settle(tester);
      expect(find.text('UNDONE'), findsOneWidget);
      expect(await tester.runAsync(() => tasks.findTasks('milk')), isEmpty);
    });
  });

  group('Activity', () {
    testWidgets('empty: says so', (tester) async {
      await pumpScreen(tester, db: db, child: const ActivityScreen());
      expect(find.text('Nothing yet'), findsOneWidget);
    });

    testWidgets('lists what AA did, with why', (tester) async {
      await createdByAa(tester, 'Call bank');
      await pumpScreen(tester, db: db, child: const ActivityScreen());
      await settle(tester);
      expect(find.text('CREATED TASK'), findsOneWidget);
      expect(find.text('Call bank'), findsOneWidget);
      expect(find.textContaining('YOU ASKED'), findsOneWidget);
    });

    testWidgets('undo refuses when the user changed it since, and says so',
        (tester) async {
      await tester.runAsync(() async {
        final id =
            await tasks.createTask(title: 'Report', priority: TaskPriority.low);
        await tasks.setTaskStatus(id, TaskStatus.done);
        await db
            .into(db.assistantActions)
            .insert(AssistantActionsCompanion.insert(
              at: clock.now(),
              groupId: 'g-done',
              toolName: 'complete_task',
              argsJson: '{"task_id": $id}',
              origin: ActionOrigin.said,
              decision: Decision.executeWithUndo,
              status: LedgerStatus.done,
              undoJson: Value(encodeUndoRecipe(RestoreFields(
                  UndoTable.tasks, id,
                  before: {'status': TaskStatus.todo.index},
                  after: {'status': TaskStatus.done.index}))),
              previewJson: Value(jsonEncode(
                  previewToJson(const CompleteTaskPreview('Report')))),
            ));
        // The user reopened it in the meantime.
        await tasks.setTaskStatus(id, TaskStatus.inProgress);
      });
      await pumpScreen(tester, db: db, child: const ActivityScreen());
      await settle(tester);
      await tester.tap(find.widgetWithText(AtomicButton, 'UNDO'));
      await settle(tester);
      expect(find.text('Changed since. Not undone.'), findsOneWidget);
      expect(find.text('UNDONE'), findsNothing);
      final report = (await tester
              .runAsync(() => tasks.findTasks('Report', includeDone: true)))!
          .single;
      expect(report.status, TaskStatus.inProgress);
    });
  });

  testWidgets('Library opens Review', (tester) async {
    await pumpScreen(tester, db: db, child: const LibraryScreen());
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Your focus over the week'), findsOneWidget);
  });
}
