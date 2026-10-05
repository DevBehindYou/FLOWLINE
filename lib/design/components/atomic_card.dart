import 'package:flutter/material.dart';

import '../theme/atomic_theme.dart';
import '../tokens/atomic_metrics.dart';
import 'atomic_pressable.dart';

/// Card treatments (system §9.3).
enum AtomicCardKind {
  /// White card, 1 px hairline: things the user owns or acts on.
  content,

  /// Surface panel, 1.5 px hairline: settings groups and tools.
  panel,

  /// Raised (notification cards).
  raised,

  /// Ink module with paper text: emphasis (energy/day-load, briefing).
  dark,

  /// 2 px Signal border: selected, or an "on" setting.
  selected,

  /// Surface fill, 2 px danger border: the danger zone container.
  danger,
}

/// The one card. Either a hard shadow ([shadowLevel] > 0) or a left
/// [priorityColor] border, never both (§9.3).
class AtomicCard extends StatelessWidget {
  const AtomicCard({
    super.key,
    required this.child,
    this.kind = AtomicCardKind.content,
    this.padding = const EdgeInsets.all(AtomicSpace.cardPadding),
    this.shadowLevel = 0,
    this.priorityColor,
    this.onTap,
    this.onLongPress,
  }) : assert(shadowLevel == 0 || priorityColor == null,
            'A card has a hard shadow or a priority border, never both');

  final Widget child;
  final AtomicCardKind kind;
  final EdgeInsetsGeometry padding;
  final int shadowLevel;
  final Color? priorityColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final p = context.atomic.palette;
    final (Color fill, Color border, double width) = switch (kind) {
      AtomicCardKind.content => (p.card, p.hairline, AtomicStroke.hair),
      AtomicCardKind.panel => (p.panel, p.hairline, AtomicStroke.structure),
      AtomicCardKind.raised => (p.raised, p.hairline, AtomicStroke.structure),
      AtomicCardKind.dark => (p.inverse, p.inverse, AtomicStroke.hair),
      AtomicCardKind.selected => (p.card, p.accent, AtomicStroke.selected),
      AtomicCardKind.danger => (p.panel, p.danger, AtomicStroke.danger),
    };
    final side = BorderSide(color: border, width: width);
    Widget body = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AtomicRadius.sm),
        border: priorityColor == null
            ? Border.fromBorderSide(side)
            : Border(
                top: side,
                right: side,
                bottom: side,
                left: BorderSide(
                    color: priorityColor!, width: AtomicStroke.priority),
              ),
      ),
      child: kind == AtomicCardKind.dark ? _Inverted(child: child) : child,
    );
    if (onTap != null || onLongPress != null || shadowLevel > 0) {
      body = AtomicPressable(
        onTap: onTap,
        onLongPress: onLongPress,
        shadowLevel: shadowLevel,
        child: body,
      );
    }
    return body;
  }
}

/// Content of an inverse module reads the inverted palette, so Atomic
/// components inside it pick their on-ink colours by themselves.
class _Inverted extends StatelessWidget {
  const _Inverted({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inverted = context.atomic.palette.inverted;
    return Theme(
      data: theme.copyWith(extensions: [AtomicThemeData(palette: inverted)]),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: inverted.text),
        child: IconTheme.merge(
            data: IconThemeData(color: inverted.text), child: child),
      ),
    );
  }
}
