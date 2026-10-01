import 'package:flutter/material.dart';

import '../error/user_message.dart';

/// Runs a user-triggered write and reports a failure as a snackbar instead
/// of an unhandled future error (rule R12). Returns the action's result,
/// or null when it failed. Pair it with a busy flag on the trigger so it
/// can't be double-submitted.
Future<T?> runAction<T>(
  BuildContext context,
  Future<T> Function() action, {
  String? failureMessage,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    return await action();
  } catch (error) {
    messenger?.showSnackBar(
      SnackBar(content: Text(failureMessage ?? userMessageFor(error))),
    );
    return null;
  }
}
