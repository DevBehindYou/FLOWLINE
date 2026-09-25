import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/subtask.dart';
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
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => AddEditTaskSheet(existingTask: task),
                    ),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete task?'),
                  content: const Text('This removes the task and its subtasks permanently.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await actions.deleteTask(taskId);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: taskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Something went wrong: $error')),
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
              Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
              if (task.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(task.notes, style: Theme.of(context).textTheme.bodyMedium),
              ],
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _startFocus(context, ref, taskId: task.id, label: task.title),
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
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New subtask'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (title != null && title.isNotEmpty) {
      await ref.read(taskDetailActionsProvider.notifier).addSubtask(taskId, title);
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

class _SubtaskList extends ConsumerWidget {
  const _SubtaskList({required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtasksAsync = ref.watch(subtasksForTaskProvider(taskId));
    final actions = ref.read(taskDetailActionsProvider.notifier);

    return subtasksAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, _) => Text("Couldn't load subtasks: $error"),
      data: (subtasks) {
        if (subtasks.isEmpty) {
          return Text('No subtasks yet.', style: Theme.of(context).textTheme.bodySmall);
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
                      onPressed: () => actions.deleteSubtask(subtask.id),
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
