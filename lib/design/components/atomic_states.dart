import 'package:flutter/material.dart';

import '../foundation/atomic_icons.dart';
import '../foundation/atomic_text.dart';
import '../theme/atomic_theme.dart';
import '../tokens/atomic_metrics.dart';
import '../tokens/atomic_type.dart';
import 'atomic_button.dart';

/// Loading (§9.9): mono caps text with an ellipsis and an ink 2 dp
/// indeterminate bar. No spinners on content.
class AtomicLoading extends StatelessWidget {
  const AtomicLoading({super.key, required this.label, this.compact = false});

  /// "LOADING THE DAY…" — say what is loading.
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          compact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Semantics(liveRegion: true, child: AtomicText.mono(label)),
        const SizedBox(height: AtomicSpace.xs),
        const SizedBox(
            width: AtomicSize.navPillWidth, child: AtomicLoadingBar()),
      ],
    );
    return compact
        ? Padding(padding: const EdgeInsets.all(AtomicSpace.m), child: body)
        : Center(child: body);
  }
}

/// The 2 dp ink indeterminate bar (or determinate with [value]).
class AtomicLoadingBar extends StatelessWidget {
  const AtomicLoadingBar({super.key, this.value});
  final double? value;

  @override
  Widget build(BuildContext context) {
    final p = context.atomic.palette;
    return LinearProgressIndicator(
      value: value,
      minHeight: AtomicSize.loadingBar,
      color: p.rule,
      backgroundColor: p.track,
      borderRadius: BorderRadius.zero,
    );
  }
}

/// Empty (§9.9): a surface module with one plain sentence and a next
/// step. Scrolls so large text never clips the action.
class AtomicEmptyState extends StatelessWidget {
  const AtomicEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = context.atomic.palette;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AtomicSpace.screenMargin),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AtomicSize.readingWidth),
          child: Container(
            padding: const EdgeInsets.all(AtomicSpace.xl),
            decoration: BoxDecoration(
              color: p.panel,
              borderRadius: BorderRadius.circular(AtomicRadius.sm),
              border: Border.all(color: p.hairline, width: AtomicStroke.hair),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: p.textMuted, size: AtomicSize.icon),
                  const SizedBox(height: AtomicSpace.s),
                ],
                AtomicText.display(title, style: AtomicType.cardTitle),
                const SizedBox(height: AtomicSpace.xs),
                AtomicText.body(message,
                    style: AtomicType.body.copyWith(color: p.textMuted)),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: AtomicSpace.l),
                  AtomicButton(
                      label: actionLabel!, onPressed: onAction, expand: true),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline error (§9.9): what happened, in plain words, and how to retry.
class AtomicErrorState extends StatelessWidget {
  const AtomicErrorState({
    super.key,
    required this.message,
    this.retryLabel,
    this.onRetry,
    this.compact = false,
  });

  final String message;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = context.atomic.palette;
    final text = AtomicText.body(message,
        style: AtomicType.body.copyWith(color: p.text),
        textAlign: compact ? TextAlign.start : TextAlign.center);
    final retry = onRetry == null || retryLabel == null
        ? null
        : AtomicButton(
            label: retryLabel!,
            onPressed: onRetry,
            icon: AtomicIcons.refresh,
            variant: AtomicButtonVariant.text);
    final icon =
        Icon(AtomicIcons.error, color: p.danger, size: AtomicSize.iconSmall);
    if (compact) {
      return Row(children: [
        icon,
        const SizedBox(width: AtomicSpace.xs),
        Expanded(child: text),
        if (retry != null) retry,
      ]);
    }
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AtomicSpace.xxl),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          icon,
          const SizedBox(height: AtomicSpace.s),
          text,
          if (retry != null) ...[const SizedBox(height: AtomicSpace.xs), retry],
        ]),
      ),
    );
  }
}

/// Warning / requirement box (§9.9): error-container fill, mono caps
/// title and body in on-error-container.
class AtomicWarningBox extends StatelessWidget {
  const AtomicWarningBox(
      {super.key, required this.title, required this.message, this.action});

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = context.atomic.palette;
    return Container(
      padding: const EdgeInsets.all(AtomicSpace.m),
      decoration: BoxDecoration(
        color: p.dangerContainer,
        borderRadius: BorderRadius.circular(AtomicRadius.sm),
        border: Border.all(color: p.hairline, width: AtomicStroke.structure),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AtomicText.mono(title,
              style: AtomicType.label.copyWith(color: p.onDangerContainer)),
          const SizedBox(height: AtomicSpace.xxs),
          AtomicText.body(message,
              style: AtomicType.body.copyWith(color: p.onDangerContainer)),
          if (action != null) ...[
            const SizedBox(height: AtomicSpace.xs),
            action!,
          ],
        ],
      ),
    );
  }
}
