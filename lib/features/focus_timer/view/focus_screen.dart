import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/focus_session.dart';
import '../../task_detail/viewmodel/task_detail_view_model.dart';
import '../viewmodel/focus_timer_view_model.dart';
import '../widgets/timer_ring.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(activeFocusSessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Focus')),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Something went wrong: $error')),
        data: (session) {
          if (session != null && session.isRunning) {
            // Ticks once a second purely to force this subtree to
            // rebuild so the wall-clock-derived countdown stays current,
            // and to notice the moment it reaches zero. The displayed
            // value always comes from `session.remainingSec` itself.
            ref.watch(secondsTickerProvider);
            if (session.remainingSec <= 0) {
              Future.microtask(
                () => ref
                    .read(focusTimerViewModelProvider.notifier)
                    .complete(session, endedEarly: false),
              );
            }
          }
          return session == null
              ? const _IdleView()
              : _RunningView(session: session);
        },
      ),
    );
  }
}

class _IdleView extends ConsumerWidget {
  const _IdleView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedSessionTypeProvider);
    final pendingLink = ref.watch(pendingFocusLinkProvider);
    final viewModel = ref.read(focusTimerViewModelProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (pendingLink != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: const Icon(Icons.link, size: 16),
                  label:
                      Text(pendingLink.label, overflow: TextOverflow.ellipsis),
                  onDeleted: () =>
                      ref.read(pendingFocusLinkProvider.notifier).clear(),
                ),
              ),
            ),
          SegmentedButton<FocusSessionType>(
            segments: const [
              ButtonSegment(
                  value: FocusSessionType.focus, label: Text('Focus (25m)')),
              ButtonSegment(
                  value: FocusSessionType.shortBreak,
                  label: Text('Short (5m)')),
              ButtonSegment(
                  value: FocusSessionType.longBreak, label: Text('Long (15m)')),
            ],
            selected: {selectedType},
            onSelectionChanged: (selection) => ref
                .read(selectedSessionTypeProvider.notifier)
                .set(selection.first),
          ),
          const Spacer(),
          Icon(Icons.hourglass_empty,
              size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => viewModel.startSession(
              type: selectedType,
              taskId: pendingLink?.taskId,
              subtaskId: pendingLink?.subtaskId,
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start'),
          ),
          const Spacer(),
          const _TodaysFocusFooter(),
        ],
      ),
    );
  }
}

class _RunningView extends ConsumerWidget {
  const _RunningView({required this.session});

  final FocusSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(focusTimerViewModelProvider.notifier);
    final color = switch (session.sessionType) {
      FocusSessionType.focus => FlowlineSemanticColors.sessionFocus,
      FocusSessionType.shortBreak => FlowlineSemanticColors.sessionShortBreak,
      FocusSessionType.longBreak => FlowlineSemanticColors.sessionLongBreak,
    };

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (session.taskId != null) _LinkedTaskChip(taskId: session.taskId!),
          const SizedBox(height: 24),
          TimerRing(
            remainingSec: session.remainingSec,
            plannedSec: session.plannedDurationSec,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            session.isPaused ? 'PAUSED' : _typeLabel(session.sessionType),
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlButton(
                icon: Icons.stop,
                label: 'End',
                onPressed: () => viewModel.complete(session, endedEarly: true),
              ),
              const SizedBox(width: 24),
              _ControlButton(
                icon: session.isPaused ? Icons.play_arrow : Icons.pause,
                label: session.isPaused ? 'Resume' : 'Pause',
                filled: true,
                onPressed: () => session.isPaused
                    ? viewModel.resume(session)
                    : viewModel.pause(session),
              ),
              const SizedBox(width: 24),
              _ControlButton(
                icon: Icons.add,
                label: '+5 min',
                onPressed: () => viewModel.extend(session),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const _TodaysFocusFooter(),
        ],
      ),
    );
  }

  String _typeLabel(FocusSessionType type) => switch (type) {
        FocusSessionType.focus => 'FOCUS',
        FocusSessionType.shortBreak => 'SHORT BREAK',
        FocusSessionType.longBreak => 'LONG BREAK',
      };
}

class _LinkedTaskChip extends ConsumerWidget {
  const _LinkedTaskChip({required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskByIdProvider(taskId));
    return taskAsync.maybeWhen(
      data: (task) => task == null
          ? const SizedBox.shrink()
          : Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: const Icon(Icons.link, size: 16),
                label: Text(task.title, overflow: TextOverflow.ellipsis),
              ),
            ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        filled
            ? FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                child: Icon(icon),
              )
            : OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                ),
                child: Icon(icon),
              ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _TodaysFocusFooter extends ConsumerWidget {
  const _TodaysFocusFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(todaysFocusSummaryProvider);
    return summaryAsync.maybeWhen(
      data: (summary) {
        final hours = summary.totalSeconds ~/ 3600;
        final minutes = (summary.totalSeconds % 3600) ~/ 60;
        final label = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.bolt,
                      size: 18, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text("Today's Focus"),
                ],
              ),
              Text(
                '$label \u2022 ${summary.sessionCount} '
                'session${summary.sessionCount == 1 ? '' : 's'}',
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
