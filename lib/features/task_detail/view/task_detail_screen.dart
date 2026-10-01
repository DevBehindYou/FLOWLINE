import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/async/run_action.dart';
import '../../../core/theme/app_theme.dart';
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
                : IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: context.l10n.editTask,
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
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: context.l10n.deleteTask,
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(taskByIdProvider(taskId)),
        ),
        data: (task) {
          if (task == null) {
            return Center(child: Text(context.l10n.taskMissing));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 8,
                children: [
                  PriorityChip(priority: task.priority),
                  StatusChip(status: task.status),
                ],
              ),
              const SizedBox(height: 16),
              Text(task.title,
                  style: Theme.of(context).textTheme.headlineSmall),
              if (task.dueAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.event_outlined,
                        size: 18,
                        color: dueStateOf(task) == DueState.overdue
                            ? FlowlineSemanticColors.feedbackOverdue
                            : Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _dueText(context.l10n, task),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
              if (task.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(task.notes, style: Theme.of(context).textTheme.bodyMedium),
              ],
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _startFocus(context, ref,
                    taskId: task.id, label: task.title),
                icon: const Icon(Icons.play_arrow),
                label: Text(context.l10n.startFocusSessionButton),
              ),
              const SizedBox(height: 24),
              Text(context.l10n.subtasks,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _SubtaskList(taskId: taskId),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _promptAddSubtask(context, ref),
                icon: const Icon(Icons.add),
                label: Text(context.l10n.addSubtask),
              ),
              const SizedBox(height: 24),
              Text(context.l10n.focusHistory,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _SessionHistory(taskId: taskId),
            ],
          );
        },
      ),
    );
  }

  Future<void> _promptAddSubtask(BuildContext context, WidgetRef ref) async {
    final title = await showDialog<String>(
      context: context,
      builder: (context) => const _NewSubtaskDialog(),
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

/// Owns its controller so it's disposed with the dialog, after the exit
/// animation, rather than leaked or disposed while still on screen (K16).
class _NewSubtaskDialog extends StatefulWidget {
  const _NewSubtaskDialog();

  @override
  State<_NewSubtaskDialog> createState() => _NewSubtaskDialogState();
}

class _NewSubtaskDialogState extends State<_NewSubtaskDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.newSubtask),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(labelText: context.l10n.titleField),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        TextButton(onPressed: _submit, child: Text(context.l10n.add)),
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
          return Text(context.l10n.subtasksEmpty,
              style: Theme.of(context).textTheme.bodySmall);
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
            return CheckboxListTile(
              key: ValueKey(subtask.id),
              contentPadding: EdgeInsets.zero,
              // Checkbox first, actions and the drag handle at the end, so
              // the title isn't squeezed behind three icons.
              controlAffinity: ListTileControlAffinity.leading,
              value: subtask.status == SubtaskStatus.done,
              onChanged: (_) => actions.toggleSubtask(subtask),
              title: Text(
                subtask.title,
                style: subtask.status == SubtaskStatus.done
                    ? const TextStyle(decoration: TextDecoration.lineThrough)
                    : null,
              ),
              subtitle: Text(
                context.l10n.subtaskSprints(
                    subtask.completedSprints, subtask.plannedSprints),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              secondary: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_circle_outline, size: 20),
                    tooltip: context.l10n.startFocusSession,
                    onPressed: () => _startFocus(
                      context,
                      ref,
                      taskId: taskId,
                      subtaskId: subtask.id,
                      label: subtask.title,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: context.l10n.deleteSubtask,
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
                  // No Tooltip here: its long-press would win the gesture
                  // from a finger that rests before dragging.
                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.drag_indicator,
                          size: 20, semanticLabel: context.l10n.reorderSubtask),
                    ),
                  ),
                ],
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
    final small = Theme.of(context).textTheme.bodySmall;
    final l10n = context.l10n;
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
          return Text(l10n.focusHistoryEmpty, style: small);
        }
        final total =
            done.fold<int>(0, (sum, s) => sum + (s.actualDurationSec ?? 0));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.focusHistorySummary(done.length, (total / 60).round()),
              style: small,
            ),
            for (final s in done.take(20))
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                    s.endedEarly
                        ? Icons.stop_circle_outlined
                        : Icons.check_circle_outline,
                    size: 20),
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
