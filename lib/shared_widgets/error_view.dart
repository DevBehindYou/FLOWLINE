import 'package:flutter/material.dart';

import '../core/error/user_message.dart';
import '../l10n/l10n.dart';

/// The spec's "Inline error + retry" component (K9): a plain-language
/// message instead of the raw exception, and a Retry that re-runs the
/// failed read. [compact] is for errors inside a section of a screen
/// rather than the whole screen.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.compact = false,
  });

  final Object error;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final message = Text(
      userMessageFor(error, context.l10n),
      textAlign: compact ? TextAlign.start : TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium,
    );
    final retry = onRetry == null
        ? null
        : TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.retry),
          );

    if (compact) {
      return Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: scheme.error),
          const SizedBox(width: 8),
          Expanded(child: message),
          if (retry != null) retry,
        ],
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: scheme.error),
            const SizedBox(height: 12),
            message,
            if (retry != null) ...[const SizedBox(height: 8), retry],
          ],
        ),
      ),
    );
  }
}
