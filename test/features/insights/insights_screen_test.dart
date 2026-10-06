import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/focus_session_repository_impl.dart';
import 'package:atomic_assist/domain/entities/focus_session.dart';
import 'package:atomic_assist/features/insights/view/insights_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/finders.dart';

import '../../support/pump_app.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets(
        'shows the empty state with zero logged sessions (${mode.name})',
        (tester) async {
      await pumpScreen(tester,
          db: db, themeMode: mode, child: const InsightsScreen());

      expect(find.text('Complete a session to see stats'), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart_outlined), findsOneWidget);
      // Stat cards and the 7-day chart must not render over an empty dataset.
      expect(findLabel('Day streak'), findsNothing);
    });
  }

  testWidgets(
      'shows stat cards and the weekly total once a session has completed',
      (tester) async {
    final repo = FocusSessionRepositoryImpl(db);
    final id = await repo.startSession(
        sessionType: FocusSessionType.focus, plannedDurationSec: 1500);
    await repo.completeSession(id, endedEarly: false);

    await pumpScreen(tester, db: db, child: const InsightsScreen());

    expect(find.text('Complete a session to see stats'), findsNothing);
    expect(findLabel('Today'), findsOneWidget);
    expect(findLabel('Day streak'), findsOneWidget);
    expect(findLabel('This week'), findsOneWidget);
    expect(find.text('1'), findsOneWidget); // one-day streak
    expect(findLabel('1 focus session this week'), findsOneWidget);
  });

  testWidgets('an ended-early session still counts toward the weekly total',
      (tester) async {
    final repo = FocusSessionRepositoryImpl(db);
    final id = await repo.startSession(
        sessionType: FocusSessionType.focus, plannedDurationSec: 1500);
    await repo.completeSession(id, endedEarly: true);

    await pumpScreen(tester, db: db, child: const InsightsScreen());

    expect(find.text('Complete a session to see stats'), findsNothing);
    expect(findLabel('1 focus session this week'), findsOneWidget);
  });
}
