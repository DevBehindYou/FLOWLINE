import 'package:flowline/data/local/drift/app_database.dart';
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
    testWidgets('shows the idle start screen when there is no active session (${mode.name})',
        (tester) async {
      await pumpScreen(tester, db: db, themeMode: mode, child: const FocusScreen());

      expect(find.text('Focus (25m)'), findsOneWidget);
      expect(find.text('Short (5m)'), findsOneWidget);
      expect(find.text('Long (15m)'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Start'), findsOneWidget);
      // No active session and no completed sessions today, so today's
      // focus footer must not render at all rather than showing 0m.
      expect(find.text("Today's Focus"), findsNothing);
    });
  }

  testWidgets('does not start a repeating ticker while idle (pumpAndSettle would hang if it did)',
      (tester) async {
    // pumpScreen already calls pumpAndSettle internally; reaching this
    // line at all is the regression check for a Stream.periodic leaking
    // into the idle state.
    await pumpScreen(tester, db: db, child: const FocusScreen());
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
