import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/atomic.dart';
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
      () => AtomicButton(
            label: l10n.addScheduleBlock,
            icon: AtomicIcons.add,
            variant: AtomicButtonVariant.ghost,
            expand: true,
            onPressed: onAddBlock,
          ),
      if (open.isNotEmpty || doneCount > 0)
        () => Padding(
              padding: const EdgeInsets.only(
                  top: AtomicSpace.xl, bottom: AtomicSpace.s),
              child: AtomicSectionLabel(l10n.unscheduled),
            ),
      for (final task in open) () => TaskCard(task: task),
      if (hasMore)
        () => AtomicButton(
              label: l10n.showMore,
              variant: AtomicButtonVariant.text,
              onPressed: ref.read(backlogLimitProvider.notifier).showMore,
            ),
      if (doneCount > 0)
        () => Align(
              alignment: Alignment.centerLeft,
              child: AtomicButton(
                label: showDone
                    ? l10n.hideCompleted(doneCount)
                    : l10n.showCompleted(doneCount),
                icon:
                    showDone ? AtomicIcons.expandLess : AtomicIcons.expandMore,
                variant: AtomicButtonVariant.text,
                onPressed:
                    ref.read(showCompletedBacklogProvider.notifier).toggle,
              ),
            ),
      for (final task in done) () => TaskCard(task: task),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AtomicSpace.screenMargin,
          AtomicSpace.xs,
          AtomicSpace.screenMargin,
          AtomicSize.floatingActionClearance),
      itemCount: rows.length,
      itemBuilder: (context, index) => rows[index](),
    );
  }
}

enum _BlockAction { edit, delete }

/// A time block: mono times, Display title, its tasks. An overlapping
/// block gets the danger priority border and says so in words.
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
    final p = context.atomic.palette;
    final timeLabel =
        l10n.timeRange(l10n.time(block.startTime), l10n.time(block.endTime));

    Widget marker(IconData icon, {String? label, Color? color}) => Padding(
          padding: const EdgeInsets.only(right: AtomicSpace.iconLabelGap),
          child: Icon(icon,
              size: AtomicSize.iconTiny,
              color: color ?? p.textMuted,
              semanticLabel: label),
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: AtomicSpace.m),
      child: AtomicCard(
        priorityColor: isConflicting ? p.danger : null,
        padding: const EdgeInsets.fromLTRB(
            AtomicSpace.m, AtomicSpace.xxs, AtomicSpace.xxs, AtomicSpace.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (block.isLocked) marker(AtomicIcons.lock),
                if (block.isOccurrence)
                  marker(AtomicIcons.repeat, label: l10n.repeatingBlock),
                if (isConflicting) marker(AtomicIcons.warning, color: p.danger),
                Expanded(
                  child: AtomicText.mono(timeLabel, style: AtomicType.caption),
                ),
                if (!block.isLocked)
                  PopupMenuButton<_BlockAction>(
                    tooltip: l10n.blockOptions,
                    icon: Icon(AtomicIcons.more,
                        size: AtomicSize.iconSmall, color: p.text),
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
                          leading: const Icon(AtomicIcons.edit),
                          title: Text(l10n.editBlock),
                        ),
                      ),
                      PopupMenuItem(
                        value: _BlockAction.delete,
                        child: ListTile(
                          leading: Icon(AtomicIcons.delete, color: p.danger),
                          title: Text(l10n.deleteBlock),
                        ),
                      ),
                    ],
                  ),
                AtomicIconButton(
                  icon: AtomicIcons.add,
                  semanticLabel: l10n.addTaskToBlock,
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => AddEditTaskSheet(scheduleBlockId: block.id),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: AtomicSpace.s),
              child:
                  AtomicText.display(block.title, style: AtomicType.rowTitle),
            ),
            if (isConflicting) ...[
              const SizedBox(height: AtomicSpace.xxs),
              AtomicText.body(l10n.overlapsAnotherBlock,
                  style: AtomicType.bodySmall.copyWith(color: p.danger)),
            ],
            const SizedBox(height: AtomicSpace.s),
            Padding(
              padding: const EdgeInsets.only(right: AtomicSpace.s),
              child: tasks.isEmpty
                  ? AtomicText.body(l10n.blockEmpty,
                      style: AtomicType.bodySmall.copyWith(color: p.textMuted))
                  : Column(children: [
                      for (final task in tasks) TaskCard(task: task),
                    ]),
            ),
          ],
        ),
      ),
    );
  }
}
