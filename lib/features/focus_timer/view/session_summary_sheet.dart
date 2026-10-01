import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/async/run_action.dart';
import '../../../core/providers.dart';
import '../../../domain/entities/app_settings.dart';
import '../../../domain/entities/focus_session.dart';
import '../../task_detail/viewmodel/task_detail_view_model.dart';
import '../viewmodel/focus_timer_view_model.dart';

/// Spec §5.8: closes the loop on a finished session and offers the next
/// step of the Pomodoro rhythm in one tap.
class SessionSummarySheet extends ConsumerStatefulWidget {
  const SessionSummarySheet({super.key, required this.outcome});

  final SessionOutcome outcome;

  @override
  ConsumerState<SessionSummarySheet> createState() =>
      _SessionSummarySheetState();
}

class _SessionSummarySheetState extends ConsumerState<SessionSummarySheet> {
  bool _starting = false;

  static String _name(FocusSessionType type) => switch (type) {
        FocusSessionType.focus => 'focus session',
        FocusSessionType.shortBreak => 'short break',
        FocusSessionType.longBreak => 'long break',
      };

  Future<void> _startNext() async {
    final outcome = widget.outcome;
    setState(() => _starting = true);
    // Keep working on the same task after a break; breaks themselves
    // aren't linked to a task.
    final keepLink = outcome.next == FocusSessionType.focus;
    final started = await runAction(context, () async {
      await ref.read(focusTimerViewModelProvider.notifier).startSession(
            type: outcome.next,
            taskId: keepLink ? outcome.session.taskId : null,
            subtaskId: keepLink ? outcome.session.subtaskId : null,
          );
      return true;
    });
    if (!mounted) return;
    if (started == true) {
      Navigator.of(context).pop();
    } else {
      setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final outcome = widget.outcome;
    final text = Theme.of(context).textTheme;
    final settings =
        ref.watch(appSettingsProvider).value ?? const AppSettings();
    final wasFocus = outcome.session.sessionType == FocusSessionType.focus;
    final minutes = (outcome.actualSec / 60).round();
    final taskId = outcome.session.taskId;
    final taskTitle = taskId == null
        ? null
        : ref.watch(taskByIdProvider(taskId)).value?.title;

    final title = outcome.endedEarly
        ? (wasFocus ? 'Session ended early' : 'Break skipped')
        : (wasFocus ? 'Focus session complete' : 'Break over');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  outcome.endedEarly
                      ? Icons.stop_circle_outlined
                      : Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: text.titleLarge)),
              ],
            ),
            const SizedBox(height: 12),
            if (wasFocus)
              Text(
                outcome.endedEarly
                    ? '$minutes min of focus logged. Every bit counts.'
                    : '$minutes min of focus logged.',
                style: text.bodyLarge,
              ),
            if (taskTitle != null) ...[
              const SizedBox(height: 4),
              Text('On: $taskTitle', style: text.bodyMedium),
            ],
            const SizedBox(height: 4),
            Text(
              '${outcome.focusSessionsToday} focus '
              'session${outcome.focusSessionsToday == 1 ? '' : 's'} today',
              style: text.bodySmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _starting ? null : _startNext,
              icon: const Icon(Icons.play_arrow),
              label: Text('Start ${_name(outcome.next)} '
                  '(${settings.minutesFor(outcome.next)}m)'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _starting
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      context.go('/today');
                    },
              child: const Text('Back to Today'),
            ),
          ],
        ),
      ),
    );
  }
}
