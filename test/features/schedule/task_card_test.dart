import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/task_repository_impl.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:atomic_assist/features/schedule/view/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
    expect(find.textContaining('Overdue'), findsOneWidget);
  });

  testWidgets('a done task is never shown as overdue', (tester) async {
    await seed(tester, dueAt: DateTime(2020, 1, 1, 9), status: TaskStatus.done);
    await pumpScreen(tester, db: db, child: const TodayScreen());
    expect(find.textContaining('Overdue'), findsNothing);
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
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(await tester.runAsync(() => db.select(db.tasks).get()), isEmpty);
  });
}
