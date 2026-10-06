import 'package:flutter/widgets.dart';

import '../core/error/user_message.dart';
import '../design/atomic.dart';
import '../l10n/l10n.dart';

/// The spec's "Inline error + retry" component (K9, R14): a plain-language
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
  Widget build(BuildContext context) => AtomicErrorState(
        message: userMessageFor(error, context.l10n),
        retryLabel: context.l10n.retry,
        onRetry: onRetry,
        compact: compact,
      );
}
