import 'package:flowline/features/shell/app_shell.dart';
import 'package:flowline/l10n/l10n.dart';
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
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('a medium window gets a labelled rail', (tester) async {
    size(tester, 700, 900);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.extended, isFalse);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();
    expect(find.text('screen /insights'), findsOneWidget);
  });

  testWidgets('an expanded window gets an extended rail', (tester) async {
    size(tester, 1200, 800);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue);
  });
}
