import 'package:flutter/material.dart';

import '../foundation/atomic_text.dart';
import '../theme/atomic_theme.dart';
import '../tokens/atomic_metrics.dart';
import '../tokens/atomic_motion.dart';
import '../tokens/atomic_type.dart';

/// Filter chip (§9.2): pill, mono caps. Off: paper fill, line border,
/// slate text. On: ink fill, paper text. 48 dp hit area around a 32 dp
/// visual (§13.8).
class AtomicChip extends StatelessWidget {
  const AtomicChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final p = context.atomic.palette;
    final motion = context.atomicMotion;
    final (Color fill, Color border, Color text) = selected
        ? (p.inverse, p.inverse, p.onInverse)
        : (p.background, p.hairline, p.textMuted);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onSelected == null ? null : () => onSelected!(!selected),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onSelected == null ? null : () => onSelected!(!selected),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AtomicSize.touchTarget),
          child: Center(
            widthFactor: 1,
            child: AnimatedContainer(
              duration: motion.toggle,
              curve: AtomicMotion.curve,
              constraints: const BoxConstraints(minHeight: AtomicSize.chip),
              padding: const EdgeInsets.symmetric(
                  horizontal: AtomicSpace.chipPadding),
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(AtomicRadius.pill),
                border:
                    Border.all(color: border, width: AtomicStroke.structure),
              ),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: AtomicText.mono(label,
                    style: AtomicType.caption.copyWith(color: text)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
