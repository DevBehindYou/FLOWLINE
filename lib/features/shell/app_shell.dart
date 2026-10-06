import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/window_size.dart';
import '../../design/atomic.dart';
import '../../l10n/l10n.dart';
import '../inbox/viewmodel/inbox_view_model.dart';

/// The top-level frame: the Atomic bottom bar on phones, the rail on
/// wider windows (docs/05 §28, §30). One ink pill marks where you are.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // Ordered by how often a secretary's day uses them (docs/05 §28).
    final destinations = [
      AtomicDestination(icon: AtomicIcons.today, label: l10n.navToday),
      AtomicDestination(
          icon: AtomicIcons.inbox,
          label: l10n.navInbox,
          badgeCount: ref.watch(openProposalCountProvider)),
      AtomicDestination(icon: AtomicIcons.assist, label: l10n.navAssistant),
      AtomicDestination(icon: AtomicIcons.focus, label: l10n.navFocus),
      AtomicDestination(icon: AtomicIcons.library, label: l10n.navLibrary),
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
