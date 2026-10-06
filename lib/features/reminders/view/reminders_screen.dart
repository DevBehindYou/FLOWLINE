import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/async/run_action.dart';
import '../../../design/atomic.dart';
import '../../../domain/entities/reminder.dart';
import '../../../domain/services/reminder_actions.dart';
import '../../../l10n/l10n.dart';
import '../../../shared_widgets/empty_state.dart';
import '../../../shared_widgets/error_view.dart';
import '../viewmodel/reminders_view_model.dart';

/// Open reminders, soonest first (docs/05 §13), with the notification's
/// own buttons. A missed one says so.
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(openRemindersProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.remindersTitle)),
      body: async.when(
        loading: () => AtomicLoading(label: l10n.loadingReminders),
        error: (error, _) => ErrorView(
            error: error, onRetry: () => ref.invalidate(openRemindersProvider)),
        data: (reminders) => reminders.isEmpty
            ? EmptyState(
                icon: AtomicIcons.notifications,
                title: l10n.remindersEmptyTitle,
                message: l10n.remindersEmptyMessage,
              )
            : ListView(
                padding: const EdgeInsets.all(AtomicSpace.s),
                children: [
                  for (final r in reminders)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AtomicSpace.xs),
                      child: _ReminderRow(key: ValueKey(r.id), reminder: r),
                    ),
                ],
              ),
      ),
    );
  }
}

class _ReminderRow extends ConsumerStatefulWidget {
  const _ReminderRow({super.key, required this.reminder});

  final Reminder reminder;

  @override
  ConsumerState<_ReminderRow> createState() => _ReminderRowState();
}

class _ReminderRowState extends ConsumerState<_ReminderRow> {
  bool _busy = false;

  Future<void> _act(ReminderAction action) async {
    setState(() => _busy = true);
    await runAction(
        context,
        () => ref
            .read(remindersActionsProvider.notifier)
            .act(action, widget.reminder.id));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = widget.reminder;
    final missed =
        r.status == ReminderStatus.fired || !r.fireAt.isAfter(clock.now());
    return AtomicCard(
      kind: AtomicCardKind.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AtomicText.mono(
            missed
                ? '${l10n.reminderOverdue} · ${l10n.dayShort(r.fireAt)} ${l10n.time(r.fireAt)}'
                : '${l10n.dayShort(r.fireAt)} ${l10n.time(r.fireAt)}',
            style: AtomicType.caption,
          ),
          const SizedBox(height: AtomicSpace.xxs),
          AtomicText.body(r.title),
          const SizedBox(height: AtomicSpace.s),
          Wrap(
            spacing: AtomicSpace.xs,
            runSpacing: AtomicSpace.xs,
            children: [
              AtomicButton(
                label: l10n.reminderDone,
                busy: _busy,
                onPressed: _busy ? null : () => _act(ReminderAction.done),
              ),
              AtomicButton(
                label: l10n.reminderSnooze10,
                variant: AtomicButtonVariant.ghost,
                onPressed: _busy ? null : () => _act(ReminderAction.snooze10),
              ),
              AtomicButton(
                label: l10n.reminderTomorrow,
                variant: AtomicButtonVariant.ghost,
                onPressed: _busy ? null : () => _act(ReminderAction.tomorrow),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
