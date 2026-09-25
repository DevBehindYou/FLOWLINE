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
}
