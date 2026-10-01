import 'package:flowline/data/local/drift/app_database.dart';
import 'package:flowline/data/repositories/schedule_repository_impl.dart';
import 'package:flowline/data/repositories/task_repository_impl.dart';
import 'package:flowline/domain/entities/task.dart';
import 'package:flowline/domain/recurrence/recurrence_rule.dart';
import 'package:flowline/domain/time/calendar_day.dart';
import 'package:flowline/features/schedule/view/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

  // Daily, so the tests don't depend on which weekday they run on.
  Future<void> seedDailySeries(WidgetTester tester, String title) =>
      tester.runAsync(() => ScheduleRepositoryImpl(db).createBlock(
            title: title,
            startTime: todayAt(9),
            endTime: todayAt(10),
            recurrence: RecurrenceRule.daily(),
          ));

  // Today shows its timeline (and "Add schedule block") once anything exists.
  Future<void> seedTask(WidgetTester tester) =>
      tester.runAsync(() => TaskRepositoryImpl(db)
          .createTask(title: 'Backlog item', priority: TaskPriority.low));

  Future<void> nextDay(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Next day'));
    await tester.pumpAndSettle();
  }

  Future<void> openBlockMenu(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Block options'));
    await tester.pumpAndSettle();
  }

  testWidgets('a new block can repeat every day', (tester) async {
    await seedTask(tester);
    await pumpScreen(tester, db: db, child: const TodayScreen());

    await tester.tap(find.text('Add schedule block'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Block title'), 'Standup');
    await tester.tap(find.text('Does not repeat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Every day').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Block'));
    await tester.pumpAndSettle();

    expect(find.text('Standup'), findsOneWidget);
    // Marked as repeating, in words for screen readers too.
    final icon = tester.widget<Icon>(find.byIcon(Icons.repeat));
    expect(icon.semanticLabel, 'Repeating block');
    await nextDay(tester);
    expect(find.text('Standup'), findsOneWidget);
  });

  testWidgets('weekly shows day chips and keeps at least one', (tester) async {
    await seedTask(tester);
    await pumpScreen(tester, db: db, child: const TodayScreen());
    await tester.tap(find.text('Add schedule block'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Does not repeat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weekly on…').last);
    await tester.pumpAndSettle();

    final chips = find.byType(FilterChip);
    expect(chips, findsNWidgets(7));
    final selected =
        tester.widgetList<FilterChip>(chips).where((c) => c.selected).toList();
    expect(selected, hasLength(1));
    // Unselecting the only day is refused.
    selected.single.onSelected!(false);
    await tester.pumpAndSettle();
    expect(tester.widgetList<FilterChip>(chips).where((c) => c.selected),
        hasLength(1));
  });

  testWidgets('deleting one day keeps the other days', (tester) async {
    await seedDailySeries(tester, 'Standup');
    await pumpScreen(tester, db: db, child: const TodayScreen());

    await openBlockMenu(tester);
    await tester.tap(find.text('Delete block'));
    await tester.pumpAndSettle();
    expect(find.text('Delete repeating block'), findsOneWidget);
    await tester.tap(find.text('Only this day'));
    await tester.pumpAndSettle();

    expect(find.text('Standup'), findsNothing);
    await nextDay(tester);
    expect(find.text('Standup'), findsOneWidget);
  });

  testWidgets('"this day and all after it" from the first day ends it',
      (tester) async {
    await seedDailySeries(tester, 'Standup');
    await pumpScreen(tester, db: db, child: const TodayScreen());

    await openBlockMenu(tester);
    await tester.tap(find.text('Delete block'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('This day and all after it'));
    await tester.pumpAndSettle();

    expect(find.text('Standup'), findsNothing);
    await nextDay(tester);
    expect(find.text('Standup'), findsNothing);
  });

  testWidgets('editing all days renames the series', (tester) async {
    await seedDailySeries(tester, 'Standup');
    await pumpScreen(tester, db: db, child: const TodayScreen());

    await openBlockMenu(tester);
    await tester.tap(find.text('Edit block'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All days'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Schedule Block'), findsOneWidget);
    expect(find.text('Every day'), findsOneWidget); // the rule is editable
    await tester.enterText(find.widgetWithText(TextField, 'Standup'), 'Sync');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Sync'), findsOneWidget);
    await nextDay(tester);
    expect(find.text('Sync'), findsOneWidget);
  });

  testWidgets('editing only this day leaves the others', (tester) async {
    await seedDailySeries(tester, 'Standup');
    await pumpScreen(tester, db: db, child: const TodayScreen());

    await openBlockMenu(tester);
    await tester.tap(find.text('Edit block'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Only this day'));
    await tester.pumpAndSettle();

    // One day can't change the series' rule.
    expect(find.text('Repeat'), findsNothing);
    await tester.enterText(
        find.widgetWithText(TextField, 'Standup'), 'Standup (remote)');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Standup (remote)'), findsOneWidget);
    await nextDay(tester);
    expect(find.text('Standup'), findsOneWidget);
  });

  testWidgets('a task added to one day stays on that day', (tester) async {
    await seedDailySeries(tester, 'Standup');
    await pumpScreen(tester, db: db, child: const TodayScreen());

    await tester.tap(find.byTooltip('Add task to this block'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Notes');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Task'));
    await tester.pumpAndSettle();

    expect(find.text('Notes'), findsOneWidget);
    await nextDay(tester);
    expect(find.text('Standup'), findsOneWidget);
    expect(find.text('Notes'), findsNothing);
  });
}
