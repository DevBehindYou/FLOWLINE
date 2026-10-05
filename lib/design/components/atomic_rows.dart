import 'package:flutter/material.dart';

import '../foundation/atomic_icons.dart';
import '../foundation/atomic_text.dart';
import '../theme/atomic_theme.dart';
import '../tokens/atomic_metrics.dart';
import '../tokens/atomic_type.dart';
import 'atomic_labels.dart';

/// A full-width settings row: Display title, optional body subtitle, a
/// trailing widget or the accent arrow, hairline below (§9.4).
class AtomicSettingsRow extends StatelessWidget {
  const AtomicSettingsRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.divider = true,
  });

  final String title;
  final String? subtitle;
  final IconData? leading;

  /// Defaults to the accent "→" when [onTap] is set.
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final p = context.atomic.palette;
    final trail = trailing ??
        (onTap == null
            ? null
            : Icon(AtomicIcons.forward,
                color: p.accentText, size: AtomicSize.iconSmall));
    return MergeSemantics(
      child: Semantics(
        button: onTap != null,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConstrainedBox(
                constraints:
                    const BoxConstraints(minHeight: AtomicSize.rowHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AtomicSpace.screenMargin,
                      vertical: AtomicSpace.s),
                  child: Row(children: [
                    if (leading != null) ...[
                      Icon(leading, color: p.text, size: AtomicSize.icon),
                      const SizedBox(width: AtomicSpace.m),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AtomicText.display(title, style: AtomicType.rowTitle),
                          if (subtitle != null) ...[
                            const SizedBox(height: AtomicSpace.xxs),
                            AtomicText.body(subtitle!,
                                style: AtomicType.bodySmall
                                    .copyWith(color: p.textMuted)),
                          ],
                        ],
                      ),
                    ),
                    if (trail != null) ...[
                      const SizedBox(width: AtomicSpace.s),
                      trail,
                    ],
                  ]),
                ),
              ),
              if (divider) const AtomicRule(hairline: true),
            ],
          ),
        ),
      ),
    );
  }
}

/// A danger zone (§9.4): section label, a warning sentence in the danger
/// colour, then a bordered container holding the destructive rows.
class AtomicDangerZone extends StatelessWidget {
  const AtomicDangerZone({
    super.key,
    required this.label,
    required this.warning,
    required this.children,
  });

  final String label;
  final String warning;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.atomic.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AtomicSectionLabel(label),
        const SizedBox(height: AtomicSpace.s),
        AtomicText.body(warning,
            style: AtomicType.body.copyWith(color: p.danger)),
        const SizedBox(height: AtomicSpace.s),
        Container(
          decoration: BoxDecoration(
            color: p.panel,
            borderRadius: BorderRadius.circular(AtomicRadius.sm),
            border: Border.all(color: p.danger, width: AtomicStroke.danger),
          ),
          padding: const EdgeInsets.all(AtomicSpace.s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ],
    );
  }
}
