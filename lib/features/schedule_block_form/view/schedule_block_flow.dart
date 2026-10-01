import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/async/run_action.dart';
import '../../../domain/entities/schedule_block.dart';
import '../../../shared_widgets/confirm_dialog.dart';
import '../../schedule_intelligence/view/conflict_warning_sheet.dart';
import '../viewmodel/add_edit_schedule_block_view_model.dart';
import 'add_edit_schedule_block_sheet.dart';

/// Create ([existing] null) or edit a schedule block, including the
/// conflict hand-off: the form returns a pending conflict instead of
/// saving, the conflict sheet resolves it, and "Edit times" brings the
/// form back with what the user typed (K15). Every screen that edits
/// blocks goes through here, so the flow can't drift between them.
Future<void> openScheduleBlockEditor(
  BuildContext context, {
  required DateTime day,
  ScheduleBlock? existing,
}) async {
  ScheduleConflictPending? draft;
  while (true) {
    if (!context.mounted) return;
    final pending = await showModalBottomSheet<ScheduleConflictPending>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddEditScheduleBlockSheet(
        initialDate: day,
        existingBlock: existing,
        draft: draft,
      ),
    );
    if (pending == null || !context.mounted) return;

    final editAgain = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ConflictWarningSheet(
        pendingTitle: pending.title,
        pendingStart: pending.start,
        pendingEnd: pending.end,
        conflicts: pending.conflicts,
        existingBlock: pending.existingBlock,
      ),
    );
    if (editAgain != true || !context.mounted) return;
    draft = pending;
  }
}

/// Confirms, then deletes [block]. Its tasks move to Unscheduled.
Future<void> confirmAndDeleteScheduleBlock(
  BuildContext context,
  WidgetRef ref,
  ScheduleBlock block,
) async {
  final confirmed = await confirmDestructive(
    context,
    title: 'Delete "${block.title}"?',
    message: 'Its tasks stay and move to Unscheduled.',
  );
  if (!confirmed || !context.mounted) return;
  await runAction(
    context,
    () => ref
        .read(addEditScheduleBlockViewModelProvider.notifier)
        .deleteBlock(block.id),
    failureMessage: "Couldn't delete the block — please try again.",
  );
}
