import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;
import 'package:atomic_assist/design/atomic.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/schedule_repository_impl.dart';
import 'package:atomic_assist/data/repositories/task_repository_impl.dart';
import 'package:atomic_assist/domain/entities/task.dart';
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

  DateTime todayAt(int hour) {
    final day = today();
    return DateTime(day.year, day.month, day.day, hour);
  }

  Future<int> seedBlock(WidgetTester tester, String title,
      {int from = 9, int to = 10, bool locked = false}) async {
    final id = await tester.runAsync(() => ScheduleRepositoryImpl(db)
        .createBlock(
            title: title, startTime: todayAt(from), endTime: todayAt(to)));
    if (locked) {
      await tester.runAsync(() => (db.update(db.scheduleBlocks)
            ..where((b) => b.id.equals(id!)))
          .write(const ScheduleBlocksCompanion(isLocked: Value(true))));
    }
    return id!;
  }

  Future<void> openBlockMenu(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Block options'));
    await tester.pumpAndSettle();
  }

  testWidgets('a block can be edited from its menu (D4)', (tester) async {
    await seedBlock(tester, 'Deep work');
    await pumpScreen(tester, db: db, child: const TodayScreen());

    await openBlockMenu(tester);
    await tester.tap(find.text('Edit block'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Schedule Block'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextField, 'Deep work'), 'Writing');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Writing'), findsOneWidget);
    expect(find.text('Deep work'), findsNothing);
  });

  testWidgets('deleting a block keeps its tasks as unscheduled (D4)',
      (tester) async {
    final blockId = await seedBlock(tester, 'Deep work');
    await tester.runAsync(() => TaskRepositoryImpl(db).createTask(
        title: 'Draft chapter',
        priority: TaskPriority.high,
        scheduleBlockId: blockId));
    await pumpScreen(tester, db: db, child: const TodayScreen());

    await openBlockMenu(tester);
    await tester.tap(find.text('Delete block'));
    await tester.pumpAndSettle();
    expect(
        find.text('Its tasks stay and move to Unscheduled.'), findsOneWidget);
    await tester.tap(find.widgetWithText(AtomicButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Deep work'), findsNothing);
    expect(findLabel('Unscheduled'), findsOneWidget);
    expect(find.text('Draft chapter'), findsOneWidget);
  });

  testWidgets('cancelling the delete keeps the block', (tester) async {
    await seedBlock(tester, 'Deep work');
    await pumpScreen(tester, db: db, child: const TodayScreen());

    await openBlockMenu(tester);
    await tester.tap(find.text('Delete block'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Deep work'), findsOneWidget);
  });

  testWidgets('"Edit times" reopens the form with what was typed (K15)',
      (tester) async {
    // The new block's default 09:00-10:30 overlaps this one.
    await seedBlock(tester, 'Standup', from: 9, to: 10);
    await pumpScreen(tester, db: db, child: const TodayScreen());

    await tester.tap(find.text('Add schedule block'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Planning');
    await tester.tap(find.text('Add Block'));
    await tester.pumpAndSettle();

    expect(find.text('Schedule conflict'), findsOneWidget);
    await tester.tap(find.text('Edit times'));
    await tester.pumpAndSettle();

    expect(find.text('Add Schedule Block'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Planning'), findsOneWidget,
        reason: 'the title the user typed is kept');
    expect(find.textContaining('9:00'), findsWidgets);
  });

  testWidgets('a locked calendar block has no edit/delete menu',
      (tester) async {
    await seedBlock(tester, 'Client call', locked: true);
    await pumpScreen(tester, db: db, child: const TodayScreen());

    expect(find.text('Client call'), findsOneWidget);
    expect(find.byTooltip('Block options'), findsNothing);
    expect(clock.now(), isNotNull);
  });
}
