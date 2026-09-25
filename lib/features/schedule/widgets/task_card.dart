import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/task.dart';
import '../../../shared_widgets/priority_chip.dart';
import '../../focus_timer/viewmodel/focus_timer_view_model.dart';
import '../viewmodel/today_view_model.dart';

class TaskCard extends ConsumerWidget {
  const TaskCard({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = task.status == TaskStatus.done;
    final actions = ref.read(todayActionsProvider.notifier);

    return Dismissible(
      key: ValueKey('task-${task.id}'),
      direction: DismissDirection.horizontal,
      background: _swipeBackground(
        context,
        alignLeft: true,
        icon: Icons.check,
        color: Colors.green,
      ),
      secondaryBackground: _swipeBackground(
        context,
        alignLeft: false,
        icon: Icons.delete,
        color: Theme.of(context).colorScheme.error,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await actions.toggleTaskDone(task);
          return false; // stays in the list, just updates status
        }
        return _confirmDelete(context);
      },
      onDismissed: (_) => actions.deleteTask(task.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          onTap: () => context.push('/today/task/${task.id}'),
          leading: IconButton(
            icon: Icon(isDone ? Icons.check_circle : Icons.circle_outlined),
            color: isDone ? Colors.green : null,
            onPressed: () => actions.toggleTaskDone(task),
          ),
          title: Text(
            task.title,
            style: isDone
                ? const TextStyle(decoration: TextDecoration.lineThrough)
                : null,
          ),
          subtitle: PriorityChip(priority: task.priority),
          trailing: isDone
              ? null
              : IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  tooltip: 'Start focus session',
                  onPressed: () {
                    ref.read(pendingFocusLinkProvider.notifier).set(
                          taskId: task.id,
                          label: task.title,
                        );
                    context.go('/focus');
                  },
                ),
        ),
      ),
    );
  }

  Widget _swipeBackground(
    BuildContext context, {
    required bool alignLeft,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      color: color.withValues(alpha: 0.15),
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: color),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('"${task.title}" will be removed permanently.'),
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
    return result ?? false;
  }
}
