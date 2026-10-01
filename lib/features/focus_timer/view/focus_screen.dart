import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/async/run_action.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers.dart';
import '../../../domain/entities/app_settings.dart';
import '../../../domain/entities/focus_session.dart';
import '../../../shared_widgets/error_view.dart';
import '../../../shared_widgets/settings_action.dart';
import '../../task_detail/viewmodel/task_detail_view_model.dart';
import '../viewmodel/focus_timer_view_model.dart';
import '../widgets/timer_ring.dart';
import 'session_summary_sheet.dart';
import '../../../l10n/l10n.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  bool _summaryOpen = false;

  @override
  void initState() {
    super.initState();
    // A session can end while another tab (or no screen) is showing; its
    // summary waits for Focus to be built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = ref.read(lastSessionOutcomeProvider);
      if (pending != null) unawaited(_showSummary(pending));
    });
  }

  Future<void> _showSummary(SessionOutcome outcome) async {
    if (_summaryOpen || !mounted) return;
    _summaryOpen = true;
    if (!outcome.endedEarly) {
      // A distinct cue for "time's up" (spec §8): the phone may be face
      // down on the desk.
      unawaited(HapticFeedback.heavyImpact());
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SessionSummarySheet(outcome: outcome),
    );
    _summaryOpen = false;
    if (mounted) ref.read(lastSessionOutcomeProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(lastSessionOutcomeProvider, (_, next) {
      if (next != null) unawaited(_showSummary(next));
    });
    final sessionAsync = ref.watch(activeFocusSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.navFocus),
        actions: const [SettingsAction()],
      ),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(activeFocusSessionProvider),
        ),
        data: (session) => session == null
            ? const _IdleView()
            : _RunningView(session: session),
      ),
    );
  }
}

/// One in-flight timer action at a time per view (rule R12): a double tap
/// on Start used to create two sessions, the first then closed as "ended
/// early" (B6), and End followed quickly by Pause raced each other.
/// Failures surface as a snackbar instead of an unhandled error.
mixin _GuardedFocusActions<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  bool _busy = false;

  FocusTimerViewModel get viewModel =>
      ref.read(focusTimerViewModelProvider.notifier);

  Future<void> guard(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await runAction(context, action);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _IdleView extends ConsumerStatefulWidget {
  const _IdleView();

  @override
  ConsumerState<_IdleView> createState() => _IdleViewState();
}

class _IdleViewState extends ConsumerState<_IdleView>
    with _GuardedFocusActions {
  @override
  Widget build(BuildContext context) {
    final selectedType = ref.watch(selectedSessionTypeProvider);
    final pendingLink = ref.watch(pendingFocusLinkProvider);

    return _ScrollSafeColumn(
      children: [
        if (pendingLink != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: const Icon(Icons.link, size: 16),
                label: Text(pendingLink.label, overflow: TextOverflow.ellipsis),
                deleteButtonTooltipMessage: context.l10n.unlinkTask,
                onDeleted: () =>
                    ref.read(pendingFocusLinkProvider.notifier).clear(),
              ),
            ),
          ),
        _SessionTypeSelector(
          selected: selectedType,
          onChanged: (type) =>
              ref.read(selectedSessionTypeProvider.notifier).set(type),
        ),
        const Spacer(),
        Icon(Icons.hourglass_empty,
            size: 64, color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _busy
              ? null
              : () => guard(() => viewModel.startSession(
                    type: selectedType,
                    taskId: pendingLink?.taskId,
                    subtaskId: pendingLink?.subtaskId,
                  )),
          icon: const Icon(Icons.play_arrow),
          label: Text(context.l10n.start),
        ),
        const Spacer(),
        const _TodaysFocusFooter(),
      ],
    );
  }
}

class _RunningView extends ConsumerStatefulWidget {
  const _RunningView({required this.session});

  final FocusSession session;

  @override
  ConsumerState<_RunningView> createState() => _RunningViewState();
}

class _RunningViewState extends ConsumerState<_RunningView>
    with _GuardedFocusActions {
  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final color = switch (session.sessionType) {
      FocusSessionType.focus => FlowlineSemanticColors.sessionFocus,
      FocusSessionType.shortBreak => FlowlineSemanticColors.sessionShortBreak,
      FocusSessionType.longBreak => FlowlineSemanticColors.sessionLongBreak,
    };

    return _ScrollSafeColumn(
      children: [
        if (session.taskId != null) _LinkedTaskChip(taskId: session.taskId!),
        const SizedBox(height: 24),
        _Countdown(session: session, color: color),
        const SizedBox(height: 8),
        Text(
          session.isPaused
              ? context.l10n.timerPaused
              : _typeLabel(context.l10n, session.sessionType),
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        // Wraps onto two lines instead of overflowing at large text.
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 16,
          children: [
            _ControlButton(
              // A break is skipped rather than "ended" (spec §5.7).
              icon: session.sessionType == FocusSessionType.focus
                  ? Icons.stop
                  : Icons.skip_next,
              label: session.sessionType == FocusSessionType.focus
                  ? context.l10n.end
                  : context.l10n.skip,
              onPressed: _busy
                  ? null
                  : () => guard(
                      () => viewModel.complete(session, endedEarly: true)),
            ),
            _ControlButton(
              icon: session.isPaused ? Icons.play_arrow : Icons.pause,
              label:
                  session.isPaused ? context.l10n.resume : context.l10n.pause,
              filled: true,
              onPressed: _busy
                  ? null
                  : () => guard(() => session.isPaused
                      ? viewModel.resume(session)
                      : viewModel.pause(session)),
            ),
            _ControlButton(
              icon: Icons.add,
              label: context.l10n.addFiveMinutes,
              onPressed:
                  _busy ? null : () => guard(() => viewModel.extend(session)),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const _TodaysFocusFooter(),
      ],
    );
  }

  String _typeLabel(AppLocalizations l10n, FocusSessionType type) =>
      switch (type) {
        FocusSessionType.focus => l10n.timerLabelFocus,
        FocusSessionType.shortBreak => l10n.timerLabelShortBreak,
        FocusSessionType.longBreak => l10n.timerLabelLongBreak,
      };
}

/// The only part of the Focus screen that changes every second. It owns
/// its ticker (a plain [Timer] cancelled in [dispose]) rather than
/// watching a Riverpod stream provider: Riverpod 2.6 defers cancelling a
/// stream provider that is disposed before its first event, so an
/// infinite periodic stream leaked a 1 Hz timer whenever the session was
/// paused or ended within a second of (re)starting. The tick only
/// triggers a redraw; the value shown always comes from the session's
/// persisted wall-clock anchor.
class _Countdown extends ConsumerStatefulWidget {
  const _Countdown({required this.session, required this.color});

  final FocusSession session;
  final Color color;

  @override
  ConsumerState<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends ConsumerState<_Countdown> {
  Timer? _ticker;
  bool _completionRequested = false;

  @override
  void initState() {
    super.initState();
    _syncTicker();
  }

  @override
  void didUpdateWidget(_Countdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session.id != widget.session.id) {
      _completionRequested = false;
    }
    _syncTicker();
  }

  void _syncTicker() {
    if (widget.session.isRunning) {
      _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      _checkCompletion();
    } else {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  void _tick() {
    if (!mounted) return;
    setState(() {});
    _checkCompletion();
  }

  void _checkCompletion() {
    if (_completionRequested || widget.session.remainingSec > 0) return;
    _completionRequested = true;
    // Idempotent: the app-resume reconciliation may race this, and the
    // repository guarantees only one of them completes the session.
    unawaited(
        ref.read(focusTimerViewModelProvider.notifier).completeIfElapsed());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: TimerRing(
        remainingSec: widget.session.remainingSec,
        plannedSec: widget.session.plannedDurationSec,
        color: widget.color,
      ),
    );
  }
}

/// The Focus views' column: Spacers keep the ring centred on a normal
/// screen, and the whole thing scrolls instead of clipping when a large
/// system font or a short screen makes it taller than the viewport.
class _ScrollSafeColumn extends StatelessWidget {
  const _ScrollSafeColumn({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (constraints.maxHeight - 48).clamp(0, double.infinity),
          ),
          child: IntrinsicHeight(child: Column(children: children)),
        ),
      ),
    );
  }
}

/// Focus / short break / long break. A segmented control at normal text
/// sizes; wrapping chips when large text wouldn't fit three segments on
/// one line (spec: survive 200% text scale).
class _SessionTypeSelector extends ConsumerWidget {
  const _SessionTypeSelector({required this.selected, required this.onChanged});

  final FocusSessionType selected;
  final ValueChanged<FocusSessionType> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(appSettingsProvider).value ?? const AppSettings();
    final l10n = context.l10n;
    final labels = {
      for (final type in FocusSessionType.values)
        type: switch (type) {
          FocusSessionType.focus =>
            l10n.selectorFocus(settings.minutesFor(type)),
          FocusSessionType.shortBreak =>
            l10n.selectorShortBreak(settings.minutesFor(type)),
          FocusSessionType.longBreak =>
            l10n.selectorLongBreak(settings.minutesFor(type)),
        },
    };
    final largeText = MediaQuery.textScalerOf(context).scale(14) > 14 * 1.3;
    if (largeText) {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final entry in labels.entries)
            ChoiceChip(
              label: Text(entry.value),
              selected: entry.key == selected,
              onSelected: (_) => onChanged(entry.key),
            ),
        ],
      );
    }
    return SegmentedButton<FocusSessionType>(
      segments: [
        for (final entry in labels.entries)
          ButtonSegment(value: entry.key, label: Text(entry.value)),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
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
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // The label under the button isn't part of it, so the button
        // carries its own accessible name (and a long-press tooltip).
        Tooltip(
          message: label,
          child: filled
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
        ),
        const SizedBox(height: 4),
        ExcludeSemantics(
          child: Text(label, style: Theme.of(context).textTheme.labelSmall),
        ),
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
        final l10n = context.l10n;
        final label = hours > 0
            ? l10n.durationHoursMinutes(hours, minutes)
            : l10n.durationMinutes(minutes);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt,
                      size: 18, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Flexible(child: Text(l10n.todaysFocus)),
                ],
              ),
              Text(
                l10n.focusFooterSummary(label, summary.sessionCount),
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
