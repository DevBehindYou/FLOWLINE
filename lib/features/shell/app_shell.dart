import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/window_size.dart';
import '../../l10n/l10n.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final destinations = [
      (Icons.calendar_today_outlined, Icons.calendar_today, l10n.navToday),
      (Icons.hourglass_empty_outlined, Icons.hourglass_bottom, l10n.navFocus),
      (Icons.auto_awesome_outlined, Icons.auto_awesome, l10n.navAssistant),
      (Icons.bar_chart_outlined, Icons.bar_chart, l10n.navInsights),
    ];
    void select(int index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );

    final sizeClass = WindowSizeClass.of(context);
    if (sizeClass == WindowSizeClass.compact) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: select,
          destinations: [
            for (final (icon, selectedIcon, label) in destinations)
              NavigationDestination(
                icon: Icon(icon),
                selectedIcon: Icon(selectedIcon),
                label: label,
              ),
          ],
        ),
      );
    }

    // Medium and expanded: a side rail keeps the full height for content
    // (a foldable unfolded, a tablet, a phone in landscape).
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            right: false,
            child: NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: select,
              extended: sizeClass == WindowSizeClass.expanded,
              labelType: sizeClass == WindowSizeClass.expanded
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              destinations: [
                for (final (icon, selectedIcon, label) in destinations)
                  NavigationRailDestination(
                    icon: Icon(icon),
                    selectedIcon: Icon(selectedIcon),
                    label: Text(label),
                  ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
