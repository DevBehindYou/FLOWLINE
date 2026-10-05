import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/async/run_action.dart';
import '../../../design/atomic.dart';
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
        loading: () => AtomicLoading(label: context.l10n.loadingFocus),
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
            padding: const EdgeInsets.only(bottom: AtomicSpace.m),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: const Icon(AtomicIcons.link, size: AtomicSize.iconTiny),
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
        const AtomMark(size: AtomicSize.heroMark),
        const SizedBox(height: AtomicSpace.xl),
        AtomicButton(
          label: context.l10n.start,
          icon: AtomicIcons.play,
          onPressed: _busy
              ? null
              : () => guard(() => viewModel.startSession(
                    type: selectedType,
                    taskId: pendingLink?.taskId,
                    subtaskId: pendingLink?.subtaskId,
                  )),
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
      // Focus is the accented state; breaks are ink (docs/05 DS-6).
      FocusSessionType.focus => context.atomic.palette.accentText,
      FocusSessionType.shortBreak ||
      FocusSessionType.longBreak =>
        context.atomic.palette.text,
    };

    return _ScrollSafeColumn(
      children: [
        if (session.taskId != null) _LinkedTaskChip(taskId: session.taskId!),
        const SizedBox(height: AtomicSpace.xl),
        _Countdown(session: session, color: color),
        const SizedBox(height: AtomicSpace.xs),
        AtomicText.mono(
          session.isPaused
              ? context.l10n.timerPaused
              : _typeLabel(context.l10n, session.sessionType),
          style: AtomicType.label
              .copyWith(color: color, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        // Wraps onto two lines instead of overflowing at large text.
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AtomicSpace.xl,
          runSpacing: AtomicSpace.m,
          children: [
            _ControlButton(
              // A break is skipped rather than "ended" (spec §5.7).
              icon: session.sessionType == FocusSessionType.focus
                  ? AtomicIcons.endSession
                  : AtomicIcons.skip,
              label: session.sessionType == FocusSessionType.focus
                  ? context.l10n.end
                  : context.l10n.skip,
              onPressed: _busy
                  ? null
                  : () => guard(
                      () => viewModel.complete(session, endedEarly: true)),
            ),
            _ControlButton(
              icon: session.isPaused ? AtomicIcons.play : AtomicIcons.pause,
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
              icon: AtomicIcons.add,
              label: context.l10n.addFiveMinutes,
              onPressed:
                  _busy ? null : () => guard(() => viewModel.extend(session)),
            ),
          ],
        ),
        const SizedBox(height: AtomicSpace.xxl),
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
        padding: const EdgeInsets.all(AtomicSpace.xl),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (constraints.maxHeight - 2 * AtomicSpace.xl)
                .clamp(0, double.infinity),
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
        spacing: AtomicSpace.chipGap,
        children: [
          for (final entry in labels.entries)
            AtomicChip(
              label: entry.value,
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
                avatar: const Icon(AtomicIcons.link, size: AtomicSize.iconTiny),
                label: Text(task.title, overflow: TextOverflow.ellipsis),
              ),
            ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

/// A square timer control (system: rectangles are nearly square). The
/// filled one is the Signal primary with a hard shadow; the others are
/// 2 dp ink outlines. The label under it is visual only: the button
/// carries its own name and a long-press tooltip.
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
    final p = context.atomic.palette;
    final enabled = onPressed != null;
    final side =
        filled ? AtomicSize.controlPrimary : AtomicSize.controlSecondary;
    return Column(
      children: [
        Tooltip(
          message: label,
          excludeFromSemantics: true,
          child: Semantics(
            button: true,
            enabled: enabled,
            label: label,
            onTap: onPressed,
            excludeSemantics: true,
            child: Opacity(
              opacity: enabled ? 1 : atomicDisabledOpacity,
              child: AtomicPressable(
                onTap: onPressed,
                shadowLevel: filled && enabled ? 2 : 0,
                child: Container(
                  width: side,
                  height: side,
                  decoration: BoxDecoration(
                    color: filled ? p.accent : null,
                    borderRadius: BorderRadius.circular(AtomicRadius.sm),
                    border: Border.all(
                        color: filled ? AtomicColors.ink : p.rule,
                        width: AtomicStroke.control),
                  ),
                  child: Icon(icon, color: filled ? p.onAccent : p.text),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AtomicSpace.xxs),
        ExcludeSemantics(
          child: AtomicText.mono(label, style: AtomicType.caption),
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
        final p = context.atomic.palette;
        return SizedBox(
          width: double.infinity,
          child: AtomicCard(
            kind: AtomicCardKind.panel,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AtomicSpace.s,
              runSpacing: AtomicSpace.xxs,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(AtomicIcons.energy,
                        size: AtomicSize.iconTiny, color: p.accentText),
                    const SizedBox(width: AtomicSpace.xs),
                    Flexible(child: AtomicText.body(l10n.todaysFocus)),
                  ],
                ),
                AtomicText.body(
                  l10n.focusFooterSummary(label, summary.sessionCount),
                ),
              ],
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
