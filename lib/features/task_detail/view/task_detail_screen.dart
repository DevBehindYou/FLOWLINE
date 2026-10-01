import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/subtask.dart';
import '../../../domain/services/task_due.dart';
import '../../../shared_widgets/confirm_dialog.dart';
import '../../../shared_widgets/error_view.dart';
import '../../../shared_widgets/priority_chip.dart';
import '../../../shared_widgets/status_chip.dart';
import '../../focus_timer/viewmodel/focus_timer_view_model.dart';
import '../../task_form/view/add_edit_task_sheet.dart';
import '../viewmodel/task_detail_view_model.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskByIdProvider(taskId));
    final actions = ref.read(taskDetailActionsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task'),
        actions: [
          taskAsync.maybeWhen(
            data: (task) => task == null
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit task',
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
            tooltip: 'Delete task',
            onPressed: () async {
              final confirmed = await confirmDestructive(
                context,
                title: 'Delete task?',
                message: 'This removes the task and its subtasks permanently.',
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
            return const Center(child: Text('This task no longer exists.'));
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
                        '${dueStateOf(task) == DueState.overdue ? 'Overdue \u00b7 ' : 'Due '}'
                        '${DateFormat('EEE, MMM d').format(task.dueAt!)} '
                        '${DateFormat.jm().format(task.dueAt!)}',
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
                label: const Text('Start Focus Session'),
              ),
              const SizedBox(height: 24),
              Text('Subtasks', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _SubtaskList(taskId: taskId),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _promptAddSubtask(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Add subtask'),
              ),
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
      title: const Text('New subtask'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: const InputDecoration(labelText: 'Title'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _submit, child: const Text('Add')),
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
          return Text('No subtasks yet.',
              style: Theme.of(context).textTheme.bodySmall);
        }
        return Column(
          children: [
            for (final subtask in subtasks)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: subtask.status == SubtaskStatus.done,
                onChanged: (_) => actions.toggleSubtask(subtask),
                title: Text(
                  subtask.title,
                  style: subtask.status == SubtaskStatus.done
                      ? const TextStyle(decoration: TextDecoration.lineThrough)
                      : null,
                ),
                subtitle: Text(
                  '${subtask.completedSprints} of ${subtask.plannedSprints} pomodoros logged',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                secondary: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.play_circle_outline, size: 20),
                      tooltip: 'Start focus session',
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
                      tooltip: 'Delete subtask',
                      onPressed: () async {
                        final confirmed = await confirmDestructive(
                          context,
                          title: 'Delete subtask?',
                          message: '"${subtask.title}" and its logged '
                              'pomodoro count will be removed.',
                        );
                        if (confirmed) await actions.deleteSubtask(subtask.id);
                      },
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
