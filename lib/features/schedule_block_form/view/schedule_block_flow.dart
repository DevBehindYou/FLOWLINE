import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/atomic.dart';

import '../../../core/async/run_action.dart';
import '../../../domain/entities/schedule_block.dart';
import '../../../shared_widgets/confirm_dialog.dart';
import '../../schedule_intelligence/view/conflict_warning_sheet.dart';
import '../viewmodel/add_edit_schedule_block_view_model.dart';
import 'add_edit_schedule_block_sheet.dart';
import '../../../l10n/l10n.dart';

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
  // One day of a repeating block: edit just that day, or the series.
  if (existing != null && existing.isOccurrence) {
    final scope = await _askScope(context,
        title: context.l10n.editRepeatingTitle,
        thisDay: context.l10n.editThisOccurrence,
        rest: context.l10n.editAllOccurrences);
    if (scope == null || !context.mounted) return;
    if (scope == _Scope.rest) {
      final series = await runAction(
        context,
        () => ProviderScope.containerOf(context, listen: false)
            .read(addEditScheduleBlockViewModelProvider.notifier)
            .getSeries(existing!),
      );
      if (series == null || !context.mounted) return;
      existing = series;
      day = DateTime(
          series.startTime.year, series.startTime.month, series.startTime.day);
    }
  }

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
        recurrence: pending.recurrence,
      ),
    );
    if (editAgain != true || !context.mounted) return;
    draft = pending;
  }
}

/// Confirms, then deletes [block]. Its tasks move to Unscheduled. For one
/// day of a repeating block, asks whether to delete that day or that day
/// and everything after it.
Future<void> confirmAndDeleteScheduleBlock(
  BuildContext context,
  WidgetRef ref,
  ScheduleBlock block,
) async {
  final viewModel = ref.read(addEditScheduleBlockViewModelProvider.notifier);
  if (block.isOccurrence) {
    final scope = await _askScope(context,
        title: context.l10n.deleteRepeatingTitle,
        thisDay: context.l10n.deleteThisOccurrence,
        rest: context.l10n.deleteThisAndFollowing,
        destructive: true);
    if (scope == null || !context.mounted) return;
    await runAction(
      context,
      () => scope == _Scope.thisDay
          ? viewModel.deleteBlock(block.id)
          : viewModel.endSeriesAt(block),
      failureMessage: context.l10n.deleteBlockFailed,
    );
    return;
  }

  final confirmed = await confirmDestructive(
    context,
    title: context.l10n.deleteBlockTitle(block.title),
    message: context.l10n.deleteBlockMessage,
  );
  if (!confirmed || !context.mounted) return;
  await runAction(
    context,
    () => viewModel.deleteBlock(block.id),
    failureMessage: context.l10n.deleteBlockFailed,
  );
}

enum _Scope { thisDay, rest }

Future<_Scope?> _askScope(
  BuildContext context, {
  required String title,
  required String thisDay,
  required String rest,
  bool destructive = false,
}) {
  return showAtomicSheet<_Scope>(
    context: context,
    label: title,
    builder: (context) {
      final color = destructive ? context.atomic.palette.danger : null;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(AtomicIcons.today, color: color),
            title: Text(thisDay),
            onTap: () => Navigator.pop(context, _Scope.thisDay),
          ),
          ListTile(
            leading: Icon(AtomicIcons.repeat, color: color),
            title: Text(rest),
            onTap: () => Navigator.pop(context, _Scope.rest),
          ),
          const SizedBox(height: AtomicSpace.s),
          AtomicButton(
            label: context.l10n.cancel,
            variant: AtomicButtonVariant.ghost,
            expand: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}
