import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/window_size.dart';
import '../../design/atomic.dart';
import '../../l10n/l10n.dart';

/// The top-level frame: the Atomic bottom bar on phones, the rail on
/// wider windows (docs/05 §28, §30). One ink pill marks where you are.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final destinations = [
      AtomicDestination(icon: AtomicIcons.today, label: l10n.navToday),
      AtomicDestination(icon: AtomicIcons.focus, label: l10n.navFocus),
      AtomicDestination(icon: AtomicIcons.assist, label: l10n.navAssistant),
      AtomicDestination(icon: AtomicIcons.review, label: l10n.navInsights),
    ];
    void select(int index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );

    if (WindowSizeClass.of(context) == WindowSizeClass.compact) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: AtomicBottomBar(
          destinations: destinations,
          selectedIndex: navigationShell.currentIndex,
          onSelected: select,
        ),
      );
    }

    // Medium and expanded: a side rail keeps the full height for content
    // (a foldable unfolded, a tablet, a phone in landscape).
    return Scaffold(
      body: Row(
        children: [
          AtomicNavRail(
            destinations: destinations,
            selectedIndex: navigationShell.currentIndex,
            onSelected: select,
          ),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
