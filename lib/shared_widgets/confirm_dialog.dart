import 'package:flutter/widgets.dart';

import '../design/atomic.dart';
import '../l10n/l10n.dart';

/// The one confirmation for destructive actions: an Atomic sheet that
/// states the effect, a destructive confirm and a ghost cancel (system
/// §9.9). Returns true only when the user explicitly confirmed;
/// dismissing counts as cancel.
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
}) {
  final l10n = context.l10n;
  return showAtomicConfirm(
    context: context,
    label: l10n.confirmSheetLabel,
    title: title,
    message: message,
    confirmLabel: confirmLabel ?? l10n.delete,
    cancelLabel: l10n.cancel,
  );
}
