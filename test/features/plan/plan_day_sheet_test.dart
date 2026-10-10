import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/task_repository_impl.dart';
import 'package:atomic_assist/design/atomic.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:atomic_assist/features/plan/view/plan_day_sheet.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_app.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 5)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  // Monday 5 October 2026, 08:00.
  final early = DateTime(2026, 10, 5, 8);

  testWidgets('preview, APPLY as one group, one UNDO takes it back',
      (tester) async {
    await withClock(Clock.fixed(early), () async {
      await tester.runAsync(() async {
        final tasks = TaskRepositoryImpl(db);
        await tasks.createTask(
            title: 'Write report', priority: TaskPriority.high);
        await tasks.createTask(title: 'Call bank', priority: TaskPriority.low);
      });
      await pumpScreen(tester,
          db: db,
          child: Builder(
              builder: (context) => Scaffold(
                    body: Center(
                      child: TextButton(
                        onPressed: () => showPlanDaySheet(context),
                        child: const Text('open'),
                      ),
                    ),
                  )));
      await tester.tap(find.text('open'));
      await settle(tester);
      expect(find.text('Write report'), findsOneWidget);
      // (intl puts a narrow no-break space before AM.)
      expect(find.textContaining(RegExp(r'^9:00.AM–9:30.AM$')), findsOneWidget);
      expect(
          find.textContaining(RegExp(r'^9:30.AM–10:00.AM$')), findsOneWidget);

      await tester.tap(find.widgetWithText(AtomicButton, 'Apply plan'));
      await settle(tester);
      expect(find.text('Planned 2 tasks'), findsOneWidget);
      final ledger =
          (await tester.runAsync(() => db.select(db.assistantActions).get()))!;
      expect(ledger.map((a) => a.toolName), ['schedule_task', 'schedule_task']);
      expect(ledger.map((a) => a.groupId).toSet(), hasLength(1));
      expect((await tester.runAsync(() => db.select(db.scheduleBlocks).get()))!,
          hasLength(2));

      await tester.tap(find.text('Undo'));
      await settle(tester);
      expect((await tester.runAsync(() => db.select(db.scheduleBlocks).get()))!,
          isEmpty);
      final tasks = (await tester.runAsync(() => db.select(db.tasks).get()))!;
      expect(tasks.every((t) => t.scheduleBlockId == null), isTrue);
    });
  });

  testWidgets('nothing to plan says so', (tester) async {
    await withClock(Clock.fixed(early), () async {
      await pumpScreen(tester,
          db: db, child: const Scaffold(body: PlanDaySheet()));
      await settle(tester);
      expect(find.textContaining('Nothing to plan'), findsOneWidget);
    });
  });
}
