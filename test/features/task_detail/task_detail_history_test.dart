import 'package:drift/drift.dart' show Value;
import 'package:flowline/data/local/drift/app_database.dart';
import 'package:flowline/data/repositories/task_repository_impl.dart';
import 'package:flowline/domain/entities/focus_session.dart';
import 'package:flowline/domain/entities/task.dart';
import 'package:flowline/features/task_detail/view/task_detail_screen.dart';
import 'package:flutter_test/flutter_test.dart';

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

    await tester.scrollUntilVisible(find.text('Focus history'), 200);
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
}
