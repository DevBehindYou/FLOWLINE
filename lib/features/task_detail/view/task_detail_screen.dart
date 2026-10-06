import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/async/run_action.dart';
import '../../../design/atomic.dart';
import '../../../domain/entities/focus_session.dart';
import '../../../domain/entities/subtask.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/services/task_due.dart';
import '../../../shared_widgets/confirm_dialog.dart';
import '../../../shared_widgets/error_view.dart';
import '../../../shared_widgets/priority_chip.dart';
import '../../../shared_widgets/status_chip.dart';
import '../../focus_timer/viewmodel/focus_timer_view_model.dart';
import '../../task_form/view/add_edit_task_sheet.dart';
import '../viewmodel/task_detail_view_model.dart';
import '../../../l10n/l10n.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskByIdProvider(taskId));
    final actions = ref.read(taskDetailActionsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.taskTitle),
        actions: [
          taskAsync.maybeWhen(
            data: (task) => task == null
                ? const SizedBox.shrink()
                : AtomicIconButton(
                    icon: AtomicIcons.edit,
                    semanticLabel: context.l10n.editTask,
                    onPressed: () async {
                      final deleted = await showModalBottomSheet<bool>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => AddEditTaskSheet(existingTask: task),
                      );
                      // Deleted from the sheet: nothing left to show here.
                      if (deleted == true && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          AtomicIconButton(
            icon: AtomicIcons.delete,
            semanticLabel: context.l10n.deleteTask,
            onPressed: () async {
              final confirmed = await confirmDestructive(
                context,
                title: context.l10n.deleteTaskTitle,
                message: context.l10n.deleteTaskWithSubtasksMessage,
              );
              if (confirmed) {
                await actions.deleteTask(taskId);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: taskAsync.when(
        loading: () => AtomicLoading(label: context.l10n.loadingTask),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(taskByIdProvider(taskId)),
        ),
        data: (task) {
          final l10n = context.l10n;
          final p = context.atomic.palette;
          if (task == null) {
            return AtomicEmptyState(
                title: l10n.taskTitle, message: l10n.taskMissing);
          }
          const gap = SizedBox(height: AtomicSpace.m);
          return ListView(
            padding: const EdgeInsets.all(AtomicSpace.screenMargin),
            children: [
              Wrap(
                spacing: AtomicSpace.chipGap,
                runSpacing: AtomicSpace.xxs,
                children: [
                  PriorityChip(priority: task.priority),
                  StatusChip(status: task.status),
                ],
              ),
              gap,
              Semantics(
                header: true,
                child: AtomicText.display(task.title,
                    style: AtomicType.pushedTitle),
              ),
              if (task.dueAt != null) ...[
                const SizedBox(height: AtomicSpace.xs),
                Row(
                  children: [
                    Icon(AtomicIcons.event,
                        size: AtomicSize.iconTiny,
                        color: dueStateOf(task) == DueState.overdue
                            ? p.danger
                            : p.textMuted),
                    const SizedBox(width: AtomicSpace.iconLabelGap),
                    Expanded(
                      child: AtomicText.body(
                        _dueText(l10n, task),
                        style: dueStateOf(task) == DueState.overdue
                            ? AtomicType.body.copyWith(color: p.danger)
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
              if (task.notes.isNotEmpty) ...[
                const SizedBox(height: AtomicSpace.xs),
                AtomicText.body(task.notes),
              ],
              const SizedBox(height: AtomicSpace.l),
              AtomicButton(
                label: l10n.startFocusSessionButton,
                icon: AtomicIcons.play,
                expand: true,
                onPressed: () => _startFocus(context, ref,
                    taskId: task.id, label: task.title),
              ),
              const SizedBox(height: AtomicSpace.xxl),
              AtomicSectionLabel(l10n.subtasks),
              const SizedBox(height: AtomicSpace.xs),
              _SubtaskList(taskId: taskId),
              const SizedBox(height: AtomicSpace.xs),
              AtomicButton(
                label: l10n.addSubtask,
                icon: AtomicIcons.add,
                variant: AtomicButtonVariant.ghost,
                expand: true,
                onPressed: () => _promptAddSubtask(context, ref),
              ),
              const SizedBox(height: AtomicSpace.xxl),
              AtomicSectionLabel(l10n.focusHistory),
              const SizedBox(height: AtomicSpace.xs),
              _SessionHistory(taskId: taskId),
            ],
          );
        },
      ),
    );
  }

  Future<void> _promptAddSubtask(BuildContext context, WidgetRef ref) async {
    final title = await showAtomicSheet<String>(
      context: context,
      label: context.l10n.newSubtask,
      builder: (context) => const _NewSubtaskForm(),
    );
    if (title != null && title.isNotEmpty) {
      await ref
          .read(taskDetailActionsProvider.notifier)
          .addSubtask(taskId, title);
    }
  }
}

void _startFocus(
  BuildContext context,
  WidgetRef ref, {
  required int taskId,
  int? subtaskId,
  required String label,
}) {
  ref.read(pendingFocusLinkProvider.notifier).set(
        taskId: taskId,
        subtaskId: subtaskId,
        label: label,
      );
  context.go('/focus');
}

/// Owns its controller so it's disposed with the sheet, after the exit
/// animation, rather than leaked or disposed while still on screen (K16).
class _NewSubtaskForm extends StatefulWidget {
  const _NewSubtaskForm();

  @override
  State<_NewSubtaskForm> createState() => _NewSubtaskFormState();
}

class _NewSubtaskFormState extends State<_NewSubtaskForm> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text.trim());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(labelText: l10n.titleField),
        ),
        const SizedBox(height: AtomicSpace.xl),
        AtomicButton(label: l10n.addSubtask, expand: true, onPressed: _submit),
        const SizedBox(height: AtomicSpace.s),
        AtomicButton(
          label: l10n.cancel,
          variant: AtomicButtonVariant.ghost,
          expand: true,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class _SubtaskList extends ConsumerWidget {
  const _SubtaskList({required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtasksAsync = ref.watch(subtasksForTaskProvider(taskId));
    final actions = ref.read(taskDetailActionsProvider.notifier);

    return subtasksAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, _) => ErrorView(
        error: error,
        compact: true,
        onRetry: () => ref.invalidate(subtasksForTaskProvider(taskId)),
      ),
      data: (subtasks) {
        if (subtasks.isEmpty) {
          return AtomicText.body(context.l10n.subtasksEmpty,
              style: AtomicType.bodySmall
                  .copyWith(color: context.atomic.palette.textMuted));
        }
        // Drag by the handle, or use the screen reader's move actions,
        // which ReorderableListView adds to every item.
        return ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: subtasks.length,
          // onReorderItem gives the index after removal, ready to insert.
          onReorderItem: (from, to) {
            final ids = [for (final s in subtasks) s.id];
            ids.insert(to, ids.removeAt(from));
            unawaited(
                runAction(context, () => actions.reorderSubtasks(taskId, ids)));
          },
          itemBuilder: (context, index) {
            final subtask = subtasks[index];
            final done = subtask.status == SubtaskStatus.done;
            final p = context.atomic.palette;
            return CheckboxListTile(
              key: ValueKey(subtask.id),
              contentPadding: EdgeInsets.zero,
              // Checkbox first and only the drag handle at the end: the
              // title gets the width, and the row's actions sit under it
              // and wrap at large text sizes.
              controlAffinity: ListTileControlAffinity.leading,
              value: done,
              onChanged: (_) => actions.toggleSubtask(subtask),
              title: AtomicText.body(
                subtask.title,
                style: done
                    ? AtomicType.bodyLarge.copyWith(
                        color: p.textMuted,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: p.textMuted)
                    : AtomicType.bodyLarge,
              ),
              subtitle: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AtomicText.mono(
                    context.l10n.subtaskSprints(
                        subtask.completedSprints, subtask.plannedSprints),
                    style: AtomicType.caption,
                  ),
                  AtomicIconButton(
                    icon: AtomicIcons.startSession,
                    semanticLabel: context.l10n.startFocusSession,
                    onPressed: () => _startFocus(
                      context,
                      ref,
                      taskId: taskId,
                      subtaskId: subtask.id,
                      label: subtask.title,
                    ),
                  ),
                  AtomicIconButton(
                    icon: AtomicIcons.close,
                    semanticLabel: context.l10n.deleteSubtask,
                    onPressed: () async {
                      final confirmed = await confirmDestructive(
                        context,
                        title: context.l10n.deleteSubtaskTitle,
                        message:
                            context.l10n.deleteSubtaskMessage(subtask.title),
                      );
                      if (confirmed) await actions.deleteSubtask(subtask.id);
                    },
                  ),
                ],
              ),
              // No Tooltip here: its long-press would win the gesture
              // from a finger that rests before dragging.
              secondary: ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.all(AtomicSpace.s),
                  child: Icon(AtomicIcons.dragHandle,
                      size: AtomicSize.iconSmall,
                      semanticLabel: context.l10n.reorderSubtask),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Spec §5.6: the focus sessions logged against this task, newest first.
class _SessionHistory extends ConsumerWidget {
  const _SessionHistory({required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsForTaskProvider(taskId));
    final l10n = context.l10n;
    final small =
        AtomicType.bodySmall.copyWith(color: context.atomic.palette.textMuted);
    return sessionsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, _) => ErrorView(
        error: error,
        compact: true,
        onRetry: () => ref.invalidate(sessionsForTaskProvider(taskId)),
      ),
      data: (sessions) {
        final done = sessions
            .where((s) =>
                s.completedAt != null &&
                s.sessionType == FocusSessionType.focus)
            .toList();
        if (done.isEmpty) {
          return AtomicText.body(l10n.focusHistoryEmpty, style: small);
        }
        final total =
            done.fold<int>(0, (sum, s) => sum + (s.actualDurationSec ?? 0));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AtomicText.body(
              l10n.focusHistorySummary(done.length, (total / 60).round()),
              style: small,
            ),
            for (final s in done.take(20))
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                    s.endedEarly ? AtomicIcons.endSession : AtomicIcons.done,
                    size: AtomicSize.iconSmall),
                title: Text(l10n.dateTime(
                    l10n.dayShort(s.completedAt!), l10n.time(s.startedAt))),
                subtitle: Text(s.endedEarly
                    ? l10n.minutesEndedEarly(
                        ((s.actualDurationSec ?? 0) / 60).round())
                    : l10n.minutesShort(
                        ((s.actualDurationSec ?? 0) / 60).round())),
              ),
          ],
        );
      },
    );
  }
}

String _dueText(AppLocalizations l10n, Task task) {
  final date = l10n.dayShort(task.dueAt!);
  final time = l10n.time(task.dueAt!);
  return dueStateOf(task) == DueState.overdue
      ? l10n.dueOverdueAt(date, time)
      : l10n.dueAt(date, time);
}
