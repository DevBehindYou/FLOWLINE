import 'package:flutter/material.dart';

import '../foundation/atomic_text.dart';
import '../theme/atomic_theme.dart';
import '../tokens/atomic_colors.dart';
import '../tokens/atomic_metrics.dart';
import '../tokens/atomic_type.dart';
import 'atomic_pressable.dart';

/// Button variants (system §9.1). One [primary] per view; pair it with a
/// [ghost], never a second primary.
enum AtomicButtonVariant {
  /// Signal fill, white label, ink border, 3 px ink shadow.
  primary,

  /// Ink fill, paper label: strong secondary ("SAVE CHANGES").
  solid,

  /// Transparent, ink border and label: secondary.
  ghost,

  /// Error-container fill, error label and border: "DELETE", "EXECUTE".
  destructive,

  /// No box: Signal mono caps ("MARK ALL READ", "OPEN →").
  text,
}

/// The Atomic button. Labels are verb + object, shown upper-case.
class AtomicButton extends StatelessWidget {
  const AtomicButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AtomicButtonVariant.primary,
    this.icon,
    this.busyLabel,
    this.busy = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AtomicButtonVariant variant;
  final IconData? icon;

  /// While [busy], the button shows this ("SAVING…") and ignores taps:
  /// the busy flag of rule R12.
  final String? busyLabel;
  final bool busy;

  /// Full width (primary actions in sheets and cards, §9.1).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final p = context.atomic.palette;
    final enabled = onPressed != null && !busy;
    final shown = busy && busyLabel != null ? busyLabel! : label;

    if (variant == AtomicButtonVariant.text) {
      return Semantics(
        button: true,
        enabled: enabled,
        label: shown,
        onTap: enabled ? onPressed : null,
        excludeSemantics: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
              minHeight: AtomicSize.touchTarget,
              minWidth: AtomicSize.touchTarget),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? onPressed : null,
            child: Opacity(
              opacity: enabled ? 1 : atomicDisabledOpacity,
              child: Center(
                widthFactor: 1,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (icon != null) ...[
                    Icon(icon, size: AtomicSize.iconSmall, color: p.accentText),
                    const SizedBox(width: AtomicSpace.iconLabelGap),
                  ],
                  AtomicText.mono(shown,
                      style: AtomicType.label.copyWith(color: p.accentText)),
                ]),
              ),
            ),
          ),
        ),
      );
    }

    final (Color fill, Color fg, Color border, double width, int shadow) =
        switch (variant) {
      AtomicButtonVariant.primary => (
          p.accent,
          p.onAccent,
          AtomicColors.ink,
          AtomicStroke.control,
          2
        ),
      AtomicButtonVariant.solid => (
          p.inverse,
          p.onInverse,
          p.inverse,
          AtomicStroke.control,
          0
        ),
      AtomicButtonVariant.ghost => (
          const Color(0x00000000),
          p.text,
          p.rule,
          AtomicStroke.control,
          0
        ),
      AtomicButtonVariant.destructive => (
          p.dangerContainer,
          p.onDangerContainer,
          p.danger,
          AtomicStroke.structure,
          0
        ),
      AtomicButtonVariant.text => throw StateError('handled above'),
    };
    final height = variant == AtomicButtonVariant.primary
        ? AtomicSize.buttonPrimary
        : AtomicSize.buttonSecondary;
    final textStyle = (variant == AtomicButtonVariant.primary
            ? AtomicType.button
            : AtomicType.buttonSmall)
        .copyWith(color: fg);

    final face = Container(
      constraints:
          BoxConstraints(minHeight: height, minWidth: AtomicSize.touchTarget),
      padding: const EdgeInsets.symmetric(horizontal: AtomicSpace.l),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AtomicRadius.sm),
        border: Border.all(color: border, width: width),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AtomicSize.iconSmall, color: fg),
            const SizedBox(width: AtomicSpace.xs),
          ],
          Flexible(
            child: Text(shown,
                style: textStyle,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2),
          ),
        ],
      ),
    );

    // The Semantics node carries the tap itself: excluding the children's
    // semantics would otherwise hide the gesture from TalkBack.
    return Semantics(
      button: true,
      enabled: enabled,
      label: shown,
      onTap: enabled ? onPressed : null,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : atomicDisabledOpacity,
        child: FocusableActionDetector(
          enabled: enabled,
          mouseCursor:
              enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) => onPressed?.call()),
          },
          // The visual can be 44 dp; the touch target is always 48 dp
          // (§11.3), so taps just outside the face still count.
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? onPressed : null,
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(minHeight: AtomicSize.touchTarget),
              child: Center(
                widthFactor: expand ? null : 1,
                heightFactor: 1,
                child: AtomicPressable(
                  onTap: enabled ? onPressed : null,
                  shadowLevel: enabled ? shadow : 0,
                  child: face,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon-only button with a 48 dp hit area (§7.2, §11.3).
enum AtomicIconButtonStyle {
  /// No box: ink icon (toolbar, row actions).
  plain,

  /// Ink square, paper icon (back button, editor toolbar).
  ink,

  /// Signal fill, white icon (the one primary icon action).
  signal,

  /// Error fill, white icon (delete in a toolbar).
  destructive,
}

class AtomicIconButton extends StatelessWidget {
  const AtomicIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.style = AtomicIconButtonStyle.plain,
    this.color,
  });

  final IconData icon;

  /// Read by screen readers and shown as the tooltip on long-press-free
  /// surfaces. Required: an icon alone is not a label (§11.7).
  final String semanticLabel;
  final VoidCallback? onPressed;
  final AtomicIconButtonStyle style;

  /// Overrides the icon colour for [AtomicIconButtonStyle.plain].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.atomic.palette;
    final enabled = onPressed != null;
    final (Color? fill, Color fg, int shadow) = switch (style) {
      AtomicIconButtonStyle.plain => (null, color ?? p.text, 0),
      AtomicIconButtonStyle.ink => (p.inverse, p.onInverse, 0),
      AtomicIconButtonStyle.signal => (p.accent, p.onAccent, 1),
      AtomicIconButtonStyle.destructive => (p.danger, p.onAccent, 1),
    };
    final box = fill == null
        ? SizedBox.square(
            dimension: AtomicSize.touchTarget,
            child: Icon(icon, color: fg, size: AtomicSize.icon))
        : SizedBox.square(
            dimension: AtomicSize.touchTarget,
            child: Center(
              child: AtomicPressable(
                onTap: onPressed,
                shadowLevel: shadow,
                child: Container(
                  width: AtomicSize.backButton,
                  height: AtomicSize.backButton,
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(AtomicRadius.sm),
                  ),
                  child: Icon(icon, color: fg, size: AtomicSize.iconSmall),
                ),
              ),
            ),
          );
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      onTap: onPressed,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : atomicDisabledOpacity,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: box,
        ),
      ),
    );
  }
}
