import 'package:drift/drift.dart' show Value;
import 'package:flowline/data/local/drift/app_database.dart';
import 'package:flowline/data/repositories/focus_session_repository_impl.dart';
import 'package:flowline/domain/entities/focus_session.dart';
import 'package:flowline/features/focus_timer/view/focus_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_app.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('shows the idle start screen with no active session (${mode.name})',
        (tester) async {
      await pumpScreen(tester, db: db, themeMode: mode, child: const FocusScreen());

      expect(find.text('Focus (25m)'), findsOneWidget);
      expect(find.text('Short (5m)'), findsOneWidget);
      expect(find.text('Long (15m)'), findsOneWidget);
      // FilledButton.icon builds a private subclass, so match by subtype.
      expect(
        find.ancestor(of: find.text('Start'), matching: find.bySubtype<FilledButton>()),
        findsOneWidget,
      );
      expect(find.text("Today's Focus"), findsOneWidget);
      expect(find.text('0m • 0 sessions'), findsOneWidget);
    });
  }

  testWidgets('idle state settles, so no per-second ticker is running', (tester) async {
    // pumpScreen ends in pumpAndSettle, which would time out if the idle
    // view watched the Stream.periodic ticker.
    await pumpScreen(tester, db: db, child: const FocusScreen());
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('today summary uses the singular for one session', (tester) async {
    final repo = FocusSessionRepositoryImpl(db);
    final id = await repo.startSession(
      sessionType: FocusSessionType.focus,
      plannedDurationSec: 1500,
    );
    await repo.completeSession(id, endedEarly: true);

    await pumpScreen(tester, db: db, child: const FocusScreen());

    expect(find.textContaining('1 session'), findsOneWidget);
    expect(find.textContaining('1 sessions'), findsNothing);
  });

  testWidgets('a running session shows wall-clock remaining time on first frame',
      (tester) async {
    // Simulates reopening the app 10 minutes into a 25-minute session:
    // remaining time must come from the persisted anchor, not a counter
    // that restarted with the process.
    final tenMinutesAgo = DateTime.now().subtract(const Duration(minutes: 10));
    await db.into(db.focusSessions).insert(
          FocusSessionsCompanion.insert(
            sessionType: FocusSessionType.focus,
            plannedDurationSec: 1500,
            startedAt: tenMinutesAgo,
            segmentStartedAt: Value(tenMinutesAgo),
            remainingSecAtSegmentStart: 1500,
          ),
        );

    // Not pumpAndSettle: a running session deliberately ticks every second.
    await pumpScreenNoSettle(tester, db: db, child: const FocusScreen());

    // 15:00 exactly, or 14:59 if a second boundary passed mid-test.
    expect(find.textContaining(RegExp(r'^(15:00|14:59)$')), findsOneWidget);
    expect(find.text('FOCUS'), findsOneWidget);

    await disposeScreen(tester);
  });
}
