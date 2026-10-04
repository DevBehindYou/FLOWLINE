import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/schedule_repository_impl.dart';
import 'package:atomic_assist/data/repositories/task_repository_impl.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:atomic_assist/domain/time/calendar_day.dart';
import 'package:atomic_assist/features/schedule/view/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_app.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  Future<List<TaskRow>> tasks(WidgetTester tester) async =>
      (await tester.runAsync(() => db.select(db.tasks).get()))!;

  testWidgets('a new task can be put in a block and given a due date',
      (tester) async {
    final day = today();
    await tester.runAsync(() => ScheduleRepositoryImpl(db).createBlock(
        title: 'Deep work',
        startTime: DateTime(day.year, day.month, day.day, 9),
        endTime: DateTime(day.year, day.month, day.day, 10)));
    await pumpScreen(tester, db: db, child: const TodayScreen());

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Add Task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Outline');

    await tester.tap(find.text('Unscheduled').last);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Deep work ·').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('No due date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK')); // date picker: keep today
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK')); // time picker: 5:00 PM default
    await tester.pumpAndSettle();
    expect(find.textContaining('Due '), findsOneWidget);

    await tester.tap(find.text('Add Task').last);
    await tester.pumpAndSettle();

    final saved = (await tasks(tester)).single;
    expect(saved.title, 'Outline');
    expect(saved.scheduleBlockId, isNotNull);
    expect(saved.dueAt, DateTime(day.year, day.month, day.day, 17));
  });

  testWidgets('editing changes status and can clear the due date (B11)',
      (tester) async {
    await tester.runAsync(() => TaskRepositoryImpl(db).createTask(
        title: 'Review',
        priority: TaskPriority.low,
        dueAt: DateTime(2030, 1, 1, 9)));
    await pumpScreen(tester, db: db, child: const TodayScreen());

    await tester.longPress(find.text('Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Doing'));
    await tester.tap(find.byTooltip('Remove due date'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save Changes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    final saved = (await tasks(tester)).single;
    expect(saved.status, TaskStatus.inProgress);
    expect(saved.dueAt, isNull);
  });

  testWidgets('a task can be deleted from its edit sheet', (tester) async {
    await tester.runAsync(() => TaskRepositoryImpl(db)
        .createTask(title: 'Old idea', priority: TaskPriority.low));
    await pumpScreen(tester, db: db, child: const TodayScreen());

    await tester.longPress(find.text('Old idea'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Delete task'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete task'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(await tasks(tester), isEmpty);
    expect(find.text('Old idea'), findsNothing);
  });
}
