import 'package:flutter/material.dart';

import '../foundation/atomic_text.dart';
import '../theme/atomic_theme.dart';
import '../tokens/atomic_metrics.dart';
import '../tokens/atomic_motion.dart';
import '../tokens/atomic_type.dart';

/// One destination of the bottom bar or rail.
@immutable
class AtomicDestination {
  const AtomicDestination(
      {required this.icon, required this.label, this.badgeCount});

  final IconData icon;
  final String label;

  /// A Signal count badge (the Inbox); null or 0 hides it.
  final int? badgeCount;
}

/// The bottom bar (§9.6): paper, 1 dp ink top border; the active
/// destination is an ink pill with icon and mono caps label; the others
/// are 48 dp icon-only buttons with their label for screen readers.
class AtomicBottomBar extends StatelessWidget {
  const AtomicBottomBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<AtomicDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final p = context.atomic.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.background,
        border:
            Border(top: BorderSide(color: p.rule, width: AtomicStroke.rule)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AtomicSize.bottomBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final (i, d) in destinations.indexed)
                _NavItem(
                  destination: d,
                  selected: i == selectedIndex,
                  onTap: () => onSelected(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The rail for medium and expanded windows: the same pills, stacked.
class AtomicNavRail extends StatelessWidget {
  const AtomicNavRail({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<AtomicDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final p = context.atomic.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.background,
        border:
            Border(right: BorderSide(color: p.rule, width: AtomicStroke.rule)),
      ),
      child: SafeArea(
        right: false,
        child: SizedBox(
          width: AtomicSize.navPillWidth + AtomicSpace.m,
          child: Column(children: [
            const SizedBox(height: AtomicSpace.m),
            for (final (i, d) in destinations.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: AtomicSpace.xs),
                child: _NavItem(
                  destination: d,
                  selected: i == selectedIndex,
                  onTap: () => onSelected(i),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem(
      {required this.destination, required this.selected, required this.onTap});

  final AtomicDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.atomic.palette;
    final motion = context.atomicMotion;
    final count = destination.badgeCount ?? 0;
    final icon = Icon(destination.icon,
        color: selected ? p.onInverse : p.text, size: AtomicSize.icon);
    final iconWithBadge = count == 0
        ? icon
        : Badge(
            label: Text('$count',
                style: AtomicType.caption.copyWith(color: p.onAccent)),
            backgroundColor: p.accent,
            child: icon,
          );
    return Semantics(
      button: true,
      selected: selected,
      label: count == 0 ? destination.label : '${destination.label}, $count',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: motion.toggle,
          curve: AtomicMotion.curve,
          height: AtomicSize.navPillHeight,
          constraints: BoxConstraints(
              minWidth:
                  selected ? AtomicSize.navPillWidth : AtomicSize.touchTarget),
          padding: const EdgeInsets.symmetric(horizontal: AtomicSpace.s),
          decoration: BoxDecoration(
            color: selected ? p.inverse : null,
            borderRadius: BorderRadius.circular(AtomicRadius.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWithBadge,
              if (selected) ...[
                const SizedBox(width: AtomicSpace.iconLabelGap),
                Flexible(
                  child: AtomicText.mono(destination.label,
                      maxLines: 1,
                      style: AtomicType.caption.copyWith(color: p.onInverse)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
