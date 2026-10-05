import 'package:drift/drift.dart' show Value;
import 'package:atomic_assist/design/atomic.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/task_repository_impl.dart';
import 'package:atomic_assist/domain/entities/subtask.dart';
import 'package:atomic_assist/domain/entities/focus_session.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:atomic_assist/features/task_detail/view/task_detail_screen.dart';
import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/material.dart' show Scrollable, TextField;
import 'package:flutter_test/flutter_test.dart';

import '../../support/finders.dart';
import '../../support/pump_app.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  testWidgets('shows the focus sessions logged against the task',
      (tester) async {
    final id = (await tester.runAsync(() => TaskRepositoryImpl(db)
        .createTask(title: 'Write', priority: TaskPriority.high)))!;
    for (final early in [false, true]) {
      await tester.runAsync(() => db.into(db.focusSessions).insert(
            FocusSessionsCompanion.insert(
              taskId: Value(id),
              sessionType: FocusSessionType.focus,
              plannedDurationSec: 1500,
              startedAt: DateTime(2026, 3, 10, 9),
              remainingSecAtSegmentStart: 0,
              completedAt: Value(DateTime(2026, 3, 10, 9, 25)),
              actualDurationSec: Value(early ? 600 : 1500),
              endedEarly: Value(early),
            ),
          ));
    }
    await pumpScreen(tester, db: db, child: TaskDetailScreen(taskId: id));

    await tester.scrollUntilVisible(findLabel('Focus history'), 200);
    expect(find.text('2 sessions · 35 min total'), findsOneWidget);
    expect(find.text('10 min · ended early'), findsOneWidget);
  });

  testWidgets('says so when there is no history yet', (tester) async {
    final id = (await tester.runAsync(() => TaskRepositoryImpl(db)
        .createTask(title: 'Write', priority: TaskPriority.high)))!;
    await pumpScreen(tester, db: db, child: TaskDetailScreen(taskId: id));
    await tester.scrollUntilVisible(find.text('No focus sessions yet.'), 200);
    expect(find.text('No focus sessions yet.'), findsOneWidget);
  });

  testWidgets('subtasks can be reordered by dragging the handle',
      (tester) async {
    final id = (await tester.runAsync(() async {
      final repo = TaskRepositoryImpl(db);
      final task =
          await repo.createTask(title: 'Write', priority: TaskPriority.high);
      for (final t in ['Outline', 'Draft', 'Polish']) {
        await repo.createSubtask(taskId: task, title: t);
      }
      return task;
    }))!;
    await pumpScreen(tester, db: db, child: TaskDetailScreen(taskId: id));
    // The subtask list is a (non-scrolling) list inside the page's list.
    await tester.scrollUntilVisible(find.text('Polish'), 200,
        scrollable: find.byType(Scrollable).first);

    // Drag "Outline" below "Polish".
    final handle = find.byIcon(AtomicIcons.dragHandle).first;
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await tester.pump(kLongPressTimeout);
    // In steps, as a finger moves, so the drag starts before the page's
    // own scrolling claims the gesture.
    for (var i = 0; i < 15; i++) {
      await gesture.moveBy(const Offset(0, 20));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    final order = (await tester
            .runAsync(() => TaskRepositoryImpl(db).watchSubtasks(id).first))!
        .map((s) => s.title)
        .toList();
    expect(order, ['Draft', 'Polish', 'Outline']);
  });

  testWidgets('a subtask is added from the sheet, and cancel adds nothing',
      (tester) async {
    final id = (await tester.runAsync(() => TaskRepositoryImpl(db)
        .createTask(title: 'Write', priority: TaskPriority.high)))!;
    await pumpScreen(tester, db: db, child: TaskDetailScreen(taskId: id));
    Future<List<Subtask>> subtasks() async => (await tester
        .runAsync(() => TaskRepositoryImpl(db).watchSubtasks(id).first))!;

    final add = find.widgetWithText(AtomicButton, 'Add subtask');
    await tester.scrollUntilVisible(add, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(findLabel('New subtask'), findsOneWidget);
    await tester.tap(find.widgetWithText(AtomicButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(await subtasks(), isEmpty);

    await tester.tap(add);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Outline');
    await tester.tap(find.widgetWithText(AtomicButton, 'Add subtask').last);
    await tester.pumpAndSettle();
    expect((await subtasks()).map((s) => s.title), ['Outline']);
  });
}
