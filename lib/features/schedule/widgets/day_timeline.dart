import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/planned_block.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/services/schedule_conflict_checker.dart';
import '../../schedule_block_form/view/schedule_block_flow.dart';
import '../../task_form/view/add_edit_task_sheet.dart';
import '../viewmodel/today_view_model.dart';
import 'task_card.dart';
import '../../../l10n/l10n.dart';

class DayTimeline extends ConsumerWidget {
  const DayTimeline({
    super.key,
    required this.plan,
    required this.openBacklog,
    required this.onAddBlock,
  });

  final List<PlannedBlock> plan;

  /// As read by [openBacklogProvider]: one more than the page size when
  /// there are more to show.
  final List<Task> openBacklog;
  final VoidCallback onAddBlock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // Cheap to compute here (a handful of blocks per day) rather than a
    // provider of its own — this is the same pure checker used to gate
    // saving a new block, just run over what's already on screen so a
    // "Save anyway" overlap doesn't quietly disappear from view.
    final conflictingIds = const ScheduleConflictChecker()
        .findConflictingBlockIds([for (final p in plan) p.block]);

    final limit = ref.watch(backlogLimitProvider);
    final hasMore = openBacklog.length > limit;
    final open = hasMore ? openBacklog.take(limit).toList() : openBacklog;
    final doneCount = ref.watch(completedBacklogCountProvider).value ?? 0;
    final showDone = ref.watch(showCompletedBacklogProvider);
    final done = showDone
        ? ref.watch(completedBacklogProvider).value ?? const <Task>[]
        : const <Task>[];

    // Rows are built lazily by ListView.builder: only what's on screen
    // is laid out, however long the backlog gets (B21).
    final rows = <Widget Function()>[
      for (final p in plan)
        () => _ScheduleBlockSection(
            planned: p, isConflicting: conflictingIds.contains(p.block.id)),
      () => OutlinedButton.icon(
            onPressed: onAddBlock,
            icon: const Icon(Icons.add),
            label: Text(l10n.addScheduleBlock),
          ),
      if (open.isNotEmpty || doneCount > 0)
        () => Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Text(l10n.unscheduled,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
      for (final task in open) () => TaskCard(task: task),
      if (hasMore)
        () => TextButton(
              onPressed: ref.read(backlogLimitProvider.notifier).showMore,
              child: Text(l10n.showMore),
            ),
      if (doneCount > 0)
        () => Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed:
                    ref.read(showCompletedBacklogProvider.notifier).toggle,
                icon: Icon(showDone ? Icons.expand_less : Icons.expand_more),
                label: Text(showDone
                    ? l10n.hideCompleted(doneCount)
                    : l10n.showCompleted(doneCount)),
              ),
            ),
      for (final task in done) () => TaskCard(task: task),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: rows.length,
      itemBuilder: (context, index) => rows[index](),
    );
  }
}

enum _BlockAction { edit, delete }

class _ScheduleBlockSection extends ConsumerWidget {
  const _ScheduleBlockSection(
      {required this.planned, required this.isConflicting});

  final PlannedBlock planned;
  final bool isConflicting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final block = planned.block;
    final tasks = planned.tasks;
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
            if (tasks.isEmpty)
              Text(l10n.blockEmpty,
                  style: Theme.of(context).textTheme.bodySmall)
            else
              for (final task in tasks) TaskCard(task: task),
          ],
        ),
      ),
    );
  }
}
