import 'package:atomic_assist/design/atomic.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/task_repository_impl.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:atomic_assist/domain/recurrence/recurrence_rule.dart';
import 'package:atomic_assist/domain/time/calendar_day.dart';
import 'package:atomic_assist/features/schedule/view/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/finders.dart';

import '../../support/pump_app.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  Future<TaskRow> only(WidgetTester tester) async =>
      (await tester.runAsync(() => db.select(db.tasks).getSingle()))!;

  Future<void> seed(WidgetTester tester,
      {DateTime? dueAt, TaskStatus? status}) async {
    final repo = TaskRepositoryImpl(db);
    final id = await tester.runAsync(() => repo.createTask(
        title: 'Ship it', priority: TaskPriority.medium, dueAt: dueAt));
    if (status != null) {
      await tester.runAsync(() => repo.setTaskStatus(id!, status));
    }
  }

  testWidgets('an overdue task says so in text, not only colour',
      (tester) async {
    await seed(tester, dueAt: DateTime(2020, 1, 1, 9));
    await pumpScreen(tester, db: db, child: const TodayScreen());
    expect(findLabelContaining('Overdue'), findsOneWidget);
  });

  testWidgets('a done task is never shown as overdue', (tester) async {
    await seed(tester, dueAt: DateTime(2020, 1, 1, 9), status: TaskStatus.done);
    await pumpScreen(tester, db: db, child: const TodayScreen());
    expect(findLabelContaining('Overdue'), findsNothing);
  });

  testWidgets('marking done offers Undo that restores the old status',
      (tester) async {
    await seed(tester, status: TaskStatus.inProgress);
    await pumpScreen(tester, db: db, child: const TodayScreen());

    await tester.tap(find.byTooltip('Mark as done'));
    await tester.pumpAndSettle();
    expect((await only(tester)).status, TaskStatus.done);
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect((await only(tester)).status, TaskStatus.inProgress);
  });

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 5)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets('ticking a repeating task moves it on; Undo puts it back',
      (tester) async {
    final tomorrow = addDays(today(), 1);
    final due = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9);
    final id = (await tester.runAsync(() => TaskRepositoryImpl(db).createTask(
        title: 'Water plants',
        priority: TaskPriority.medium,
        dueAt: due,
        repeat: RecurrenceRule.daily())))!;
    await pumpScreen(tester, db: db, child: const TodayScreen());

    await tester.tap(find.byTooltip('Mark as done'));
    await settle(tester);
    final moved =
        (await tester.runAsync(() => TaskRepositoryImpl(db).getTask(id)))!;
    expect(moved.status, TaskStatus.todo);
    expect(moved.dueAt, DateTime(due.year, due.month, due.day + 1, 9));
    expect(find.textContaining('Marked "Water plants" done. Next'),
        findsOneWidget);
    // Through the tool: a ledger row, and a done record of this one.
    expect(
        (await tester.runAsync(() => db.select(db.assistantActions).get()))!
            .map((a) => a.toolName),
        ['complete_task']);
    expect((await tester.runAsync(() => db.select(db.tasks).get()))!,
        hasLength(2));

    await tester.tap(find.text('Undo'));
    await settle(tester);
    final rows = (await tester.runAsync(() => db.select(db.tasks).get()))!;
    expect(rows.single.dueAt, due);
    expect(rows.single.status, TaskStatus.todo);
  });

  testWidgets('long-press changes priority without opening the task',
      (tester) async {
    await seed(tester);
    await pumpScreen(tester, db: db, child: const TodayScreen());

    await tester.longPress(find.text('Ship it'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Priority: High'));
    await tester.tap(find.text('Priority: High'));
    await tester.pumpAndSettle();

    expect((await only(tester)).priority, TaskPriority.high);
    // Tags are mono caps on screen; TalkBack reads the word as written.
    expect(find.text('HIGH'), findsOneWidget);
    expect(
        find.byWidgetPredicate(
            (w) => w is Text && w.data == 'HIGH' && w.semanticsLabel == 'High'),
        findsOneWidget);
  });

  testWidgets('long-press delete asks first', (tester) async {
    await seed(tester);
    await pumpScreen(tester, db: db, child: const TodayScreen());

    await tester.longPress(find.text('Ship it'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Delete'));
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete task?'), findsOneWidget);
    await tester.tap(find.widgetWithText(AtomicButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(await tester.runAsync(() => db.select(db.tasks).get()), isEmpty);
  });
}
