import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/async/run_action.dart';
import '../../../design/atomic.dart';
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
    final palette = context.atomic.palette;

    return Dismissible(
      key: ValueKey('task-${task.id}'),
      direction: DismissDirection.horizontal,
      background: _swipeBackground(
        context,
        alignLeft: true,
        icon: AtomicIcons.check,
        color: context.atomic.palette.accentText,
      ),
      secondaryBackground: _swipeBackground(
        context,
        alignLeft: false,
        icon: AtomicIcons.delete,
        color: context.atomic.palette.danger,
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
      child: Padding(
        padding: const EdgeInsets.only(bottom: AtomicSpace.xs),
        child: AtomicCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            // Tight padding: the leading and trailing buttons already bring
            // 48dp touch targets, and on a 360dp phone the title needs the
            // width (seen in the goldens).
            contentPadding:
                const EdgeInsetsDirectional.only(end: AtomicSpace.xxs),
            horizontalTitleGap: 0,
            minLeadingWidth: 0,
            onTap: () => context.push('/today/task/${task.id}'),
            // The spec's accessible alternative to swiping (§8).
            onLongPress: () => _showActions(context, ref),
            // Done is a Signal checkbox and a slate strikethrough
            // (docs/05 DS-5).
            leading: AtomicIconButton(
              icon: isDone ? AtomicIcons.taskDone : AtomicIcons.task,
              semanticLabel:
                  isDone ? context.l10n.markNotDone : context.l10n.markDone,
              color: isDone ? palette.accentText : palette.textMuted,
              onPressed: () => _toggleDone(context, ref),
            ),
            title: AtomicText.body(
              task.title,
              style: isDone
                  ? AtomicType.bodyLarge.copyWith(
                      color: palette.textMuted,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: palette.textMuted)
                  : AtomicType.bodyLarge,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: AtomicSpace.xxs),
              child: Wrap(
                spacing: AtomicSpace.xs,
                runSpacing: AtomicSpace.xxs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  PriorityChip(priority: task.priority),
                  _DueLabel(task: task),
                ],
              ),
            ),
            trailing: isDone
                ? null
                : AtomicIconButton(
                    icon: AtomicIcons.startSession,
                    semanticLabel: context.l10n.startFocusSession,
                    onPressed: () => _startFocus(context, ref),
                  ),
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
    if (task.repeat != null && task.status != TaskStatus.done) {
      final done =
          await runAction(context, () => actions.completeRepeating(task));
      if (done == null) return;
      final next = done.nextDue;
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(next == null
              ? l10n.markedDone(task.title)
              : l10n.markedDoneNext(
                  task.title, '${l10n.dayShort(next)} ${l10n.time(next)}')),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => actions.undoEntry(done.entryId),
          ),
        ));
      return;
    }
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
      // Scrolls when the actions don't fit (short screens, large text).
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: AtomicText.display(task.title,
                    style: AtomicType.rowTitle, maxLines: 1),
              ),
              ListTile(
                leading: const Icon(AtomicIcons.edit),
                title: Text(context.l10n.edit),
                onTap: () => Navigator.pop(context, _TaskAction.edit),
              ),
              if (task.status != TaskStatus.done)
                ListTile(
                  leading: const Icon(AtomicIcons.startSession),
                  title: Text(context.l10n.startFocusSession),
                  onTap: () => Navigator.pop(context, _TaskAction.focus),
                ),
              for (final priority in TaskPriority.values)
                if (priority != task.priority)
                  ListTile(
                    leading: const Icon(AtomicIcons.priority),
                    title: Text(context.l10n
                        .priorityOption(context.l10n.priorityName(priority))),
                    onTap: () =>
                        Navigator.pop(context, _TaskAction.priority(priority)),
                  ),
              ListTile(
                leading: Icon(AtomicIcons.delete,
                    color: context.atomic.palette.danger),
                title: Text(context.l10n.delete),
                onTap: () => Navigator.pop(context, _TaskAction.delete),
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: AtomicSpace.l),
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
    final palette = context.atomic.palette;
    final (text, color) = switch (state) {
      DueState.overdue => (l10n.dueOverdue(l10n.monthDay(due)), palette.danger),
      DueState.dueToday => (l10n.dueToday(l10n.time(due)), palette.accentText),
      _ => (l10n.dueOn(l10n.monthDay(due)), palette.textMuted),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
            state == DueState.overdue ? AtomicIcons.warning : AtomicIcons.event,
            size: AtomicSize.iconTiny,
            color: color),
        const SizedBox(width: AtomicSpace.xxs),
        Flexible(
          child: AtomicText.mono(text,
              style: AtomicType.caption.copyWith(color: color)),
        ),
      ],
    );
  }
}
