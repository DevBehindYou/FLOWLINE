import 'package:atomic_assist/design/atomic.dart';
import 'package:atomic_assist/features/shell/app_shell.dart';
import 'package:atomic_assist/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// The real AppShell over four placeholder branches.
Widget _app() {
  StatefulShellBranch branch(String path) => StatefulShellBranch(routes: [
        GoRoute(
          path: path,
          builder: (_, __) => Center(child: Text('screen $path')),
        ),
      ]);
  final router = GoRouter(
    initialLocation: '/today',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => AppShell(navigationShell: shell),
        branches: [
          branch('/today'),
          branch('/focus'),
          branch('/assistant'),
          branch('/insights'),
        ],
      ),
    ],
  );
  return MaterialApp.router(
    theme: AtomicTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    routerConfig: router,
  );
}

void main() {
  void size(WidgetTester tester, double width, double height) {
    tester.view.physicalSize = Size(width * 2, height * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

  testWidgets('a phone gets the bottom navigation bar', (tester) async {
    size(tester, 360, 740);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.byType(AtomicBottomBar), findsOneWidget);
    expect(find.byType(AtomicNavRail), findsNothing);
  });

  testWidgets('a medium window gets the rail', (tester) async {
    size(tester, 700, 900);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.byType(AtomicNavRail), findsOneWidget);
    expect(find.byType(AtomicBottomBar), findsNothing);

    // Inactive destinations are icon-only; their label is for TalkBack.
    await tester.tap(find.byIcon(AtomicIcons.review));
    await tester.pumpAndSettle();
    expect(find.text('screen /insights'), findsOneWidget);
  });

  testWidgets('every destination is labelled for screen readers',
      (tester) async {
    final handle = tester.ensureSemantics();
    size(tester, 360, 740);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    for (final label in ['Today', 'Focus', 'Assistant', 'Insights']) {
      expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
    }
    handle.dispose();
  });
}
