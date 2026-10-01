import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

/// The one confirmation dialog for destructive actions (spec §3: dialogs
/// are for destructive confirmations only). Returns true only when the
/// user explicitly confirmed; dismissing the dialog counts as cancel.
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel ?? context.l10n.delete),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
