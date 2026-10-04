import 'package:flutter/widgets.dart';

import '../foundation/atomic_text.dart';
import '../theme/atomic_theme.dart';
import '../tokens/atomic_metrics.dart';
import '../tokens/atomic_type.dart';

/// How loud a tag is. Meaning comes from the words; the treatment only
/// sets the weight (§9.2, docs/05 DS-4/DS-5, rule U19).
enum AtomicTagTone {
  /// Ink fill, paper text: the strongest ("HIGH", "SHIPPED").
  solid,

  /// Ink outline: normal weight ("MEDIUM").
  outline,

  /// Hairline outline, muted text: the quietest ("LOW", "NEXT").
  quiet,

  /// Signal fill, white text: on/active ("NOW", "ON").
  accent,

  /// Error outline and text ("OVERDUE").
  danger,
}

/// A small mono caps pill: status, priority, state.
class AtomicTag extends StatelessWidget {
  const AtomicTag(this.label, {super.key, this.tone = AtomicTagTone.quiet});

  final String label;
  final AtomicTagTone tone;

  @override
  Widget build(BuildContext context) {
    final p = context.atomic.palette;
    final (Color? fill, Color border, Color text) = switch (tone) {
      AtomicTagTone.solid => (p.inverse, p.inverse, p.onInverse),
      AtomicTagTone.outline => (null, p.rule, p.text),
      AtomicTagTone.quiet => (null, p.hairline, p.textMuted),
      AtomicTagTone.accent => (p.accent, p.accent, p.onAccent),
      AtomicTagTone.danger => (null, p.danger, p.danger),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AtomicSpace.xs, vertical: AtomicSpace.xxs / 2),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AtomicRadius.pill),
        border: Border.all(color: border, width: AtomicStroke.structure),
      ),
      child: AtomicText.mono(label,
          style: AtomicType.caption.copyWith(color: text)),
    );
  }
}
