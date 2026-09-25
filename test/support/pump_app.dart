import 'package:flowline/core/providers.dart';
import 'package:flowline/core/theme/app_theme.dart';
import 'package:flowline/data/local/drift/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({
  required AppDatabase db,
  required Widget child,
  required ThemeMode themeMode,
  required List<Override> extraOverrides,
}) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWith((ref) => db),
      ...extraOverrides,
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: child,
    ),
  );
}

/// Pumps [child] as the home of a themed `MaterialApp`, with
/// `appDatabaseProvider` overridden to [db] so nothing under test touches
/// device storage or platform channels, then settles so stream-backed
/// providers have their first value before assertions run.
Future<void> pumpScreen(
  WidgetTester tester, {
  required AppDatabase db,
  required Widget child,
  ThemeMode themeMode = ThemeMode.light,
  List<Override> extraOverrides = const [],
}) async {
  await tester.pumpWidget(_app(
    db: db,
    child: child,
    themeMode: themeMode,
    extraOverrides: extraOverrides,
  ));
  await tester.pumpAndSettle();
}

/// Like [pumpScreen] for screens that never settle on purpose (a running
/// focus timer ticks every second). Pumps a few frames so streams deliver,
/// without waiting for animations or periodic timers to stop. Pair with
/// [disposeScreen] so those timers are cancelled before the test ends.
Future<void> pumpScreenNoSettle(
  WidgetTester tester, {
  required AppDatabase db,
  required Widget child,
  ThemeMode themeMode = ThemeMode.light,
  List<Override> extraOverrides = const [],
}) async {
  await tester.pumpWidget(_app(
    db: db,
    child: child,
    themeMode: themeMode,
    extraOverrides: extraOverrides,
  ));
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Unmounts the ProviderScope so every provider (and any periodic timer or
/// stream subscription it owns) is disposed before the test ends.
Future<void> disposeScreen(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
}
