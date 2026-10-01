import 'package:flowline/data/local/drift/app_database.dart';
import 'package:flowline/data/repositories/task_repository_impl.dart';
import 'package:flowline/domain/entities/task.dart';
import 'package:flowline/features/schedule/view/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_app.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets(
        'shows the empty state when there are no tasks or blocks (${mode.name})',
        (tester) async {
      await pumpScreen(tester,
          db: db, themeMode: mode, child: const TodayScreen());

      expect(find.text('No tasks yet'), findsOneWidget);
      expect(find.text('Add your first task to start planning today.'),
          findsOneWidget);
      expect(find.widgetWithText(FloatingActionButton, 'Add Task'),
          findsOneWidget);
      // The empty state's own action button duplicates the FAB's label —
      // both should be reachable, neither should throw on tap.
      expect(find.text('Add Task'), findsNWidgets(2));
    });
  }

  testWidgets(
      'shows an unscheduled task in the timeline instead of the empty state',
      (tester) async {
    final taskRepo = TaskRepositoryImpl(db);
    await taskRepo.createTask(
      title: 'Write the QA report',
      priority: TaskPriority.medium,
    );

    await pumpScreen(tester, db: db, child: const TodayScreen());

    expect(find.text('No tasks yet'), findsNothing);
    expect(find.text('Write the QA report'), findsOneWidget);
  });

  testWidgets('date header shows "Jump to today" only when viewing another day',
      (tester) async {
    await pumpScreen(tester, db: db, child: const TodayScreen());
    expect(find.text('Jump to today'), findsNothing);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('Jump to today'), findsOneWidget);

    await tester.tap(find.text('Jump to today'));
    await tester.pumpAndSettle();
    expect(find.text('Jump to today'), findsNothing);
  });

  group('backlog (B20)', () {
    testWidgets('completed tasks are hidden behind a toggle', (tester) async {
      await tester.runAsync(() async {
        final repo = TaskRepositoryImpl(db);
        await repo.createTask(title: 'Still open', priority: TaskPriority.low);
        final done = await repo.createTask(
            title: 'Finished', priority: TaskPriority.low);
        await repo.setTaskStatus(done, TaskStatus.done);
      });
      await pumpScreen(tester, db: db, child: const TodayScreen());

      expect(find.text('Still open'), findsOneWidget);
      expect(find.text('Finished'), findsNothing);

      await tester.tap(find.text('Show completed (1)'));
      await tester.pumpAndSettle();
      expect(find.text('Finished'), findsOneWidget);
      expect(find.text('Hide completed (1)'), findsOneWidget);
    });

    testWidgets(
        'only completed tasks still show the toggle, not the empty state',
        (tester) async {
      await tester.runAsync(() async {
        final repo = TaskRepositoryImpl(db);
        final done = await repo.createTask(
            title: 'Finished', priority: TaskPriority.low);
        await repo.setTaskStatus(done, TaskStatus.done);
      });
      await pumpScreen(tester, db: db, child: const TodayScreen());

      expect(find.text('No tasks yet'), findsNothing);
      expect(find.text('Show completed (1)'), findsOneWidget);
    });

    testWidgets('a long backlog is paged with "Show more"', (tester) async {
      await tester.runAsync(() async {
        final repo = TaskRepositoryImpl(db);
        for (var i = 0; i < 51; i++) {
          await repo.createTask(title: 'Task $i', priority: TaskPriority.low);
        }
      });
      await pumpScreen(tester, db: db, child: const TodayScreen());

      final more = find.text('Show more');
      await tester.scrollUntilVisible(more, 500);
      expect(find.text('Task 50'), findsNothing);

      await tester.tap(more);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Task 50'), 500);
      expect(find.text('Task 50'), findsOneWidget);
      expect(find.text('Show more'), findsNothing);
    });
  });
}
