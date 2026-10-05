import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/async/run_action.dart';
import '../../../core/providers.dart';
import '../../../design/atomic.dart';
import '../../../domain/entities/app_settings.dart';
import '../../../domain/entities/focus_session.dart';
import '../../task_detail/viewmodel/task_detail_view_model.dart';
import '../viewmodel/focus_timer_view_model.dart';
import '../../../l10n/l10n.dart';

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
    final settings =
        ref.watch(appSettingsProvider).value ?? const AppSettings();
    final wasFocus = outcome.session.sessionType == FocusSessionType.focus;
    final minutes = (outcome.actualSec / 60).round();
    final taskId = outcome.session.taskId;
    final taskTitle = taskId == null
        ? null
        : ref.watch(taskByIdProvider(taskId)).value?.title;

    final l10n = context.l10n;
    final title = outcome.endedEarly
        ? (wasFocus ? l10n.summaryEndedEarly : l10n.summaryBreakSkipped)
        : (wasFocus ? l10n.summaryFocusComplete : l10n.summaryBreakOver);

    final p = context.atomic.palette;
    return AtomicSheetFrame(
      label: l10n.navFocus,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                outcome.endedEarly ? AtomicIcons.endSession : AtomicIcons.done,
                color: p.accentText,
              ),
              const SizedBox(width: AtomicSpace.xs),
              Expanded(
                child: Semantics(
                  header: true,
                  child: AtomicText.display(title, style: AtomicType.cardTitle),
                ),
              ),
            ],
          ),
          const SizedBox(height: AtomicSpace.s),
          if (wasFocus)
            AtomicText.body(
              outcome.endedEarly
                  ? l10n.summaryLoggedEarly(minutes)
                  : l10n.summaryLogged(minutes),
              style: AtomicType.bodyLarge,
            ),
          if (taskTitle != null) ...[
            const SizedBox(height: AtomicSpace.xxs),
            AtomicText.body(l10n.summaryOnTask(taskTitle)),
          ],
          const SizedBox(height: AtomicSpace.xxs),
          AtomicText.mono(
            l10n.summarySessionsToday(outcome.focusSessionsToday),
            style: AtomicType.caption,
          ),
          const SizedBox(height: AtomicSpace.l),
          AtomicButton(
            label: _startLabel(
                l10n, outcome.next, settings.minutesFor(outcome.next)),
            icon: AtomicIcons.play,
            expand: true,
            busy: _starting,
            onPressed: _startNext,
          ),
          const SizedBox(height: AtomicSpace.s),
          AtomicButton(
            label: l10n.backToToday,
            variant: AtomicButtonVariant.ghost,
            expand: true,
            onPressed: _starting
                ? null
                : () {
                    Navigator.of(context).pop();
                    context.go('/today');
                  },
          ),
        ],
      ),
    );
  }
}

String _startLabel(AppLocalizations l10n, FocusSessionType next, int minutes) =>
    switch (next) {
      FocusSessionType.focus => l10n.startFocusMinutes(minutes),
      FocusSessionType.shortBreak => l10n.startShortBreakMinutes(minutes),
      FocusSessionType.longBreak => l10n.startLongBreakMinutes(minutes),
    };
