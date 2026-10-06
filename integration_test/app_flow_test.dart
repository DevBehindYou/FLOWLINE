import 'package:atomic_assist/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:atomic_assist/design/atomic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// The real app on an Android emulator (CI job "Integration tests"):
/// real SQLite file, real plugins, real lifecycle. Covers what widget
/// tests can't: startup, routing from a fresh install, and the plugins
/// behind a focus session.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Pumps until [finder] matches, for screens that never settle (a
  /// running timer) or that wait on the database or a plugin.
  Future<void> pumpUntil(WidgetTester tester, Finder finder,
      {Duration timeout = const Duration(seconds: 20)}) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return;
    }
    throw TestFailure('Timed out waiting for $finder');
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await pumpUntil(tester, finder);
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('fresh install: onboarding, a task, a focus session',
      (tester) async {
    app.main();

    // First launch opens onboarding.
    // Mono labels draw capitals and keep the words for screen readers.
    final skip = find.byWidgetPredicate(
        (w) => w is Text && (w.data == 'Skip' || w.semanticsLabel == 'Skip'));
    await pumpUntil(tester, skip);
    await tap(tester, skip);
    await pumpUntil(tester, find.text('No tasks yet'));

    // Session alerts off, so Android 13+ never shows its permission
    // dialog (a system window the test can't tap).
    await tap(tester, find.byTooltip('Settings'));
    await tap(tester, find.text('Notifications'));
    await tap(tester, find.byType(Switch));
    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 300));

    // A task, stored in the real database.
    await tap(tester, find.widgetWithText(AtomicButton, 'Add Task').last);
    await pumpUntil(tester, find.widgetWithText(TextField, 'Title'));
    await tester.enterText(
        find.widgetWithText(TextField, 'Title'), 'Write the report');
    // The sheet's button; the empty state behind it has one too.
    await tap(tester, find.widgetWithText(AtomicButton, 'Add Task').last);
    await pumpUntil(tester, find.text('Write the report'));

    // Focus on it: start, pause, end early, then the summary.
    await tap(tester, find.byTooltip('Start focus session'));
    await tap(tester, find.text('Start'));
    await pumpUntil(tester, find.byTooltip('Pause'));
    await tap(tester, find.byTooltip('Pause'));
    await pumpUntil(tester, find.text('PAUSED'));
    await tap(tester, find.byTooltip('End'));
    await pumpUntil(tester, find.text('Session ended early'));
    await tap(tester, find.text('Back to Today'));
    await pumpUntil(tester, find.text('Write the report'));
  });
}
