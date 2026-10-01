import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/schedule_block.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/services/schedule_conflict_checker.dart';
import '../../../shared_widgets/error_view.dart';
import '../../schedule_block_form/view/schedule_block_flow.dart';
import '../../task_form/view/add_edit_task_sheet.dart';
import '../viewmodel/today_view_model.dart';
import 'task_card.dart';
import '../../../l10n/l10n.dart';

class DayTimeline extends StatelessWidget {
  const DayTimeline({
    super.key,
    required this.blocks,
    required this.unscheduledTasks,
    required this.onAddBlock,
  });

  final List<ScheduleBlock> blocks;
  final List<Task> unscheduledTasks;
  final VoidCallback onAddBlock;

  @override
  Widget build(BuildContext context) {
    // Cheap to compute here (a handful of blocks per day) rather than a
    // provider of its own — this is the same pure checker used to gate
    // saving a new block, just run over what's already on screen so a
    // "Save anyway" overlap doesn't quietly disappear from view.
    final conflictingIds =
        const ScheduleConflictChecker().findConflictingBlockIds(blocks);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        for (final block in blocks)
          _ScheduleBlockSection(
              block: block, isConflicting: conflictingIds.contains(block.id)),
        OutlinedButton.icon(
          onPressed: onAddBlock,
          icon: const Icon(Icons.add),
          label: Text(context.l10n.addScheduleBlock),
        ),
        if (unscheduledTasks.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(context.l10n.unscheduled,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final task in unscheduledTasks) TaskCard(task: task),
        ],
      ],
    );
  }
}

enum _BlockAction { edit, delete }

class _ScheduleBlockSection extends ConsumerWidget {
  const _ScheduleBlockSection(
      {required this.block, required this.isConflicting});

  final ScheduleBlock block;
  final bool isConflicting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksForBlockProvider(block.id));
    final l10n = context.l10n;
    final timeLabel =
        l10n.timeRange(l10n.time(block.startTime), l10n.time(block.endTime));
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: isConflicting
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: scheme.error, width: 1.5),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (block.isLocked)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.lock_outline, size: 16),
                  ),
                if (isConflicting)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(Icons.warning_amber_rounded,
                        size: 16, color: scheme.error),
                  ),
                Expanded(
                  child: Text(timeLabel,
                      style: Theme.of(context).textTheme.bodySmall),
                ),
                if (!block.isLocked)
                  PopupMenuButton<_BlockAction>(
                    tooltip: l10n.blockOptions,
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (action) => switch (action) {
                      _BlockAction.edit => openScheduleBlockEditor(context,
                          day: block.startTime, existing: block),
                      _BlockAction.delete =>
                        confirmAndDeleteScheduleBlock(context, ref, block),
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: _BlockAction.edit,
                        child: ListTile(
                          leading: const Icon(Icons.edit_outlined),
                          title: Text(l10n.editBlock),
                        ),
                      ),
                      PopupMenuItem(
                        value: _BlockAction.delete,
                        child: ListTile(
                          leading: const Icon(Icons.delete_outline),
                          title: Text(l10n.deleteBlock),
                        ),
                      ),
                    ],
                  ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  tooltip: l10n.addTaskToBlock,
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => AddEditTaskSheet(scheduleBlockId: block.id),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(block.title, style: Theme.of(context).textTheme.titleMedium),
            if (isConflicting) ...[
              const SizedBox(height: 2),
              Text(
                l10n.overlapsAnotherBlock,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.error),
              ),
            ],
            const SizedBox(height: 12),
            tasksAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (error, _) => ErrorView(
                error: error,
                compact: true,
                onRetry: () => ref.invalidate(tasksForBlockProvider(block.id)),
              ),
              data: (tasks) => tasks.isEmpty
                  ? Text(
                      l10n.blockEmpty,
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  : Column(children: [
                      for (final task in tasks) TaskCard(task: task)
                    ]),
            ),
          ],
        ),
      ),
    );
  }
}
