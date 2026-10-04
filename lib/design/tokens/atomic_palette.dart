import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'atomic_colors.dart';

/// Semantic colour roles for one theme. Components ask for a role ("the
/// card", "muted text", "the accent as text"), so the dark theme can
/// change values without changing meaning.
@immutable
final class AtomicPalette {
  const AtomicPalette({
    required this.background,
    required this.card,
    required this.panel,
    required this.raised,
    required this.text,
    required this.textMuted,
    required this.rule,
    required this.hairline,
    required this.accent,
    required this.onAccent,
    required this.accentText,
    required this.danger,
    required this.dangerContainer,
    required this.onDangerContainer,
    required this.shadow,
    required this.inverse,
    required this.onInverse,
    required this.track,
  });

  /// Screen background.
  final Color background;

  /// Things the user owns or acts on (white cards on light).
  final Color card;

  /// Inset groups and settings (surface on light).
  final Color panel;

  /// Notification cards, a step above the background.
  final Color raised;
  final Color text;
  final Color textMuted;

  /// Rules that matter: header divider, title underline, control borders.
  final Color rule;

  /// Decorative dividers between rows.
  final Color hairline;

  /// Fill for the one primary action, selected and "on" states.
  final Color accent;
  final Color onAccent;

  /// The accent used as text or a thin line on [background]/[card].
  final Color accentText;
  final Color danger;
  final Color dangerContainer;
  final Color onDangerContainer;

  /// Hard offset shadows (ink on light, Signal on dark).
  final Color shadow;

  /// Dark modules on light (and the reverse).
  final Color inverse;
  final Color onInverse;

  /// The empty part of a progress bar.
  final Color track;

  static const light = AtomicPalette(
    background: AtomicColors.paper,
    card: AtomicColors.white,
    panel: AtomicColors.surface,
    raised: AtomicColors.raised,
    text: AtomicColors.ink,
    textMuted: AtomicColors.slate,
    rule: AtomicColors.ink,
    hairline: AtomicColors.line,
    accent: AtomicColors.signal,
    onAccent: AtomicColors.white,
    accentText: AtomicColors.signal,
    danger: AtomicColors.error,
    dangerContainer: AtomicColors.errorContainer,
    onDangerContainer: AtomicColors.onErrorContainer,
    shadow: AtomicColors.ink,
    inverse: AtomicColors.ink,
    onInverse: AtomicColors.paper,
    track: AtomicColors.track,
  );

  static const dark = AtomicPalette(
    background: AtomicColors.ink,
    card: AtomicColors.darkCard,
    panel: AtomicColors.darkCard,
    raised: AtomicColors.darkCard,
    text: AtomicColors.paper,
    textMuted: AtomicColors.paperMuted,
    rule: AtomicColors.paper,
    hairline: AtomicColors.paperHairline,
    accent: AtomicColors.signal,
    onAccent: AtomicColors.white,
    accentText: AtomicColors.signalLight,
    danger: AtomicColors.negativeOnDark,
    dangerContainer: AtomicColors.onErrorContainer,
    onDangerContainer: AtomicColors.errorContainer,
    shadow: AtomicColors.signal,
    inverse: AtomicColors.paper,
    onInverse: AtomicColors.ink,
    track: AtomicColors.paperHairline,
  );
}
