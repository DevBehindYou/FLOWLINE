import 'package:flowline/core/providers.dart';
import 'package:flowline/core/theme/app_theme.dart';
import 'package:flowline/data/local/drift/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [child] as the body of a themed `MaterialApp`, with
/// `appDatabaseProvider` overridden to [db] so nothing under test touches
/// device storage or platform channels. Settles the first frame so async
/// (stream-backed) providers have resolved their initial value before the
/// test starts making assertions.
Future<void> pumpScreen(
  WidgetTester tester, {
  required AppDatabase db,
  required Widget child,
  ThemeMode themeMode = ThemeMode.light,
  List<Override> extraOverrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
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
    ),
  );
  await tester.pumpAndSettle();
}
