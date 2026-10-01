import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/async/run_action.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/services/task_due.dart';
import '../../../shared_widgets/confirm_dialog.dart';
import '../../../shared_widgets/priority_chip.dart';
import '../../focus_timer/viewmodel/focus_timer_view_model.dart';
import '../../task_form/view/add_edit_task_sheet.dart';
import '../viewmodel/today_view_model.dart';
import '../../../l10n/l10n.dart';

class TaskCard extends ConsumerWidget {
  const TaskCard({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = task.status == TaskStatus.done;

    return Dismissible(
      key: ValueKey('task-${task.id}'),
      direction: DismissDirection.horizontal,
      background: _swipeBackground(
        context,
        alignLeft: true,
        icon: Icons.check,
        color: FlowlineSemanticColors.statusDone,
      ),
      secondaryBackground: _swipeBackground(
        context,
        alignLeft: false,
        icon: Icons.delete,
        color: Theme.of(context).colorScheme.error,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _toggleDone(context, ref);
          return false; // stays in the list, just updates status
        }
        return _confirmDelete(context);
      },
      onDismissed: (_) => runAction(
        context,
        () => ref.read(todayActionsProvider.notifier).deleteTask(task.id),
        failureMessage: context.l10n.deleteTaskFailed,
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          onTap: () => context.push('/today/task/${task.id}'),
          // The spec's accessible alternative to swiping (§8).
          onLongPress: () => _showActions(context, ref),
          leading: IconButton(
            tooltip: isDone ? context.l10n.markNotDone : context.l10n.markDone,
            icon: Icon(isDone ? Icons.check_circle : Icons.circle_outlined),
            color: isDone ? FlowlineSemanticColors.statusDone : null,
            onPressed: () => _toggleDone(context, ref),
          ),
          title: Text(
            task.title,
            style: isDone
                ? const TextStyle(decoration: TextDecoration.lineThrough)
                : null,
          ),
          subtitle: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PriorityChip(priority: task.priority),
              _DueLabel(task: task),
            ],
          ),
          trailing: isDone
              ? null
              : IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  tooltip: context.l10n.startFocusSession,
                  onPressed: () => _startFocus(context, ref),
                ),
        ),
      ),
    );
  }

  /// Toggles done and, when the task was just completed, offers Undo
  /// (spec §4 "Snackbar with Undo") that restores the previous status.
  Future<void> _toggleDone(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = context.l10n;
    final actions = ref.read(todayActionsProvider.notifier);
    final previous =
        await runAction(context, () => actions.toggleTaskDone(task));
    if (previous == null || previous == TaskStatus.done) return;
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(l10n.markedDone(task.title)),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () => actions.setStatus(task.id, previous),
        ),
      ));
  }

  void _startFocus(BuildContext context, WidgetRef ref) {
    ref.read(pendingFocusLinkProvider.notifier).set(
          taskId: task.id,
          label: task.title,
        );
    context.go('/focus');
  }

  Future<void> _showActions(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<_TaskAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(task.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(context.l10n.edit),
              onTap: () => Navigator.pop(context, _TaskAction.edit),
            ),
            if (task.status != TaskStatus.done)
              ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: Text(context.l10n.startFocusSession),
                onTap: () => Navigator.pop(context, _TaskAction.focus),
              ),
            for (final priority in TaskPriority.values)
              if (priority != task.priority)
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: Text(context.l10n
                      .priorityOption(context.l10n.priorityName(priority))),
                  onTap: () =>
                      Navigator.pop(context, _TaskAction.priority(priority)),
                ),
            ListTile(
              leading: Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error),
              title: Text(context.l10n.delete),
              onTap: () => Navigator.pop(context, _TaskAction.delete),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    final actions = ref.read(todayActionsProvider.notifier);
    switch (action) {
      case _EditAction():
        await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          builder: (_) => AddEditTaskSheet(existingTask: task),
        );
      case _FocusAction():
        _startFocus(context, ref);
      case _PriorityAction(:final priority):
        await runAction(context, () => actions.setPriority(task, priority));
      case _DeleteAction():
        if (await _confirmDelete(context) && context.mounted) {
          await runAction(context, () => actions.deleteTask(task.id));
        }
    }
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

  Future<bool> _confirmDelete(BuildContext context) => confirmDestructive(
        context,
        title: context.l10n.deleteTaskTitle,
        message: context.l10n.deleteTaskMessage(task.title),
      );
}

sealed class _TaskAction {
  const _TaskAction();
  static const edit = _EditAction();
  static const focus = _FocusAction();
  static const delete = _DeleteAction();
  static _TaskAction priority(TaskPriority p) => _PriorityAction(p);
}

class _EditAction extends _TaskAction {
  const _EditAction();
}

class _FocusAction extends _TaskAction {
  const _FocusAction();
}

class _DeleteAction extends _TaskAction {
  const _DeleteAction();
}

class _PriorityAction extends _TaskAction {
  const _PriorityAction(this.priority);
  final TaskPriority priority;
}

/// "Overdue · Mar 9" / "Due today 5:00 PM" / "Due Mar 12". Text plus
/// colour, never colour alone (spec §9).
class _DueLabel extends StatelessWidget {
  const _DueLabel({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final due = task.dueAt;
    final state = dueStateOf(task);
    if (due == null || state == DueState.none) return const SizedBox.shrink();
    final l10n = context.l10n;
    final (text, color) = switch (state) {
      DueState.overdue => (
          l10n.dueOverdue(l10n.monthDay(due)),
          FlowlineSemanticColors.feedbackOverdue
        ),
      DueState.dueToday => (
          l10n.dueToday(l10n.time(due)),
          Theme.of(context).colorScheme.primary
        ),
      _ => (
          l10n.dueOn(l10n.monthDay(due)),
          Theme.of(context).colorScheme.onSurfaceVariant
        ),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
            state == DueState.overdue
                ? Icons.warning_amber_rounded
                : Icons.event_outlined,
            size: 14,
            color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
