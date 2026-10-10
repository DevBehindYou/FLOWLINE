import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/async/run_action.dart';
import '../../../design/atomic.dart';
import '../../../domain/entities/schedule_block.dart';
import '../../../domain/services/conflict_resolution_ai.dart';
import '../../schedule_block_form/viewmodel/add_edit_schedule_block_view_model.dart';
import '../viewmodel/schedule_intelligence_view_model.dart';
import '../../../l10n/l10n.dart';
import '../../../domain/recurrence/recurrence_rule.dart';
import '../../ai_assistant/viewmodel/assistant_view_model.dart';
import '../../../domain/ai/ai_contract.dart';

/// Shown instead of saving directly when the pending block overlaps one
/// or more existing blocks. Three ways out: ask the AI for a suggested
/// non-overlapping time, go back and edit the times by hand, or save the
/// overlap anyway (it'll show a conflict indicator on the Today
/// timeline rather than being hidden).
///
/// Pops `true` for "Edit times" (the caller reopens the form with the
/// pending values), `false` after saving, null when dismissed.
class ConflictWarningSheet extends ConsumerStatefulWidget {
  const ConflictWarningSheet({
    super.key,
    required this.pendingTitle,
    required this.pendingStart,
    required this.pendingEnd,
    required this.conflicts,
    this.existingBlock,
    this.recurrence,
  });

  final String pendingTitle;
  final DateTime pendingStart;
  final DateTime pendingEnd;
  final List<ScheduleBlock> conflicts;

  /// Non-null when this conflict came from editing an existing block.
  final ScheduleBlock? existingBlock;

  /// Set when the pending block is a new repeating one.
  final RecurrenceRule? recurrence;

  @override
  ConsumerState<ConflictWarningSheet> createState() =>
      _ConflictWarningSheetState();
}

class _ConflictWarningSheetState extends ConsumerState<ConflictWarningSheet> {
  bool _asking = false;
  bool _saving = false;
  ConflictResolutionSuggestion? _suggestion;

  /// Why [_suggestion] can't be applied; null when it passed validation.
  SuggestionProblem? _suggestionProblem;
  String? _aiRawText;
  AIFailure? _aiError;

  ScheduleIntelligenceViewModel get _viewModel =>
      ref.read(scheduleIntelligenceViewModelProvider.notifier);

  Future<SuggestionProblem?> _validate(
      ConflictResolutionSuggestion suggestion) {
    return _viewModel.validateSuggestion(
      suggestion: suggestion,
      pendingStart: widget.pendingStart,
      pendingEnd: widget.pendingEnd,
      excludeBlockId: widget.existingBlock?.id,
    );
  }

  Future<void> _askAi() async {
    setState(() {
      _asking = true;
      _suggestion = null;
      _suggestionProblem = null;
      _aiRawText = null;
      _aiError = null;
    });

    final response = await _viewModel.suggestResolution(
      pendingTitle: widget.pendingTitle,
      pendingStart: widget.pendingStart,
      pendingEnd: widget.pendingEnd,
      conflicts: widget.conflicts,
      excludeBlockId: widget.existingBlock?.id,
    );

    if (!mounted) return;

    final String text;
    switch (response) {
      case AIError(:final failure):
        setState(() {
          _asking = false;
          _aiError = failure;
        });
        return;
      case AIText():
        text = response.text;
    }

    final parsed = parseConflictSuggestion(text);
    final problem = parsed == null ? null : await _validate(parsed);
    if (!mounted) return;
    setState(() {
      _asking = false;
      if (parsed != null) {
        _suggestion = parsed;
        _suggestionProblem = problem;
      } else {
        _aiRawText = text;
      }
    });
  }

  Future<void> _applySuggestion() async {
    final suggestion = _suggestion;
    if (suggestion == null || _suggestionProblem != null) return;
    // The schedule may have changed since the suggestion arrived.
    final problem = await _validate(suggestion);
    if (!mounted) return;
    if (problem != null) {
      setState(() => _suggestionProblem = problem);
      return;
    }
    await _commit(suggestion.newStartTime, suggestion.newEndTime);
  }

  Future<void> _saveAnyway() async {
    await _commit(widget.pendingStart, widget.pendingEnd);
  }

  Future<void> _commit(DateTime start, DateTime end) async {
    setState(() => _saving = true);
    final viewModel = ref.read(addEditScheduleBlockViewModelProvider.notifier);
    final saved = await runAction(
      context,
      () async {
        if (widget.existingBlock != null) {
          await viewModel.updateBlock(
            widget.existingBlock!.copyWith(
                title: widget.pendingTitle, startTime: start, endTime: end),
          );
        } else {
          await viewModel.createBlock(
              title: widget.pendingTitle,
              startTime: start,
              endTime: end,
              recurrence: widget.recurrence);
        }
        return true;
      },
      failureMessage: context.l10n.saveBlockFailed,
    );
    if (!mounted) return;
    if (saved == true) {
      Navigator.of(context).pop(false);
    } else {
      setState(() => _saving = false);
    }
  }

  String _fmt(DateTime d) => context.l10n.time(d);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.atomic.palette;
    final busy = _asking || _saving;

    return AtomicSheetFrame(
      label: l10n.scheduleConflict,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtomicText.body(
            l10n.conflictOverlaps(widget.pendingTitle,
                _fmt(widget.pendingStart), _fmt(widget.pendingEnd)),
            style: AtomicType.body.copyWith(color: p.danger),
          ),
          const SizedBox(height: AtomicSpace.xs),
          for (final conflict in widget.conflicts)
            Padding(
              padding: const EdgeInsets.only(bottom: AtomicSpace.xxs),
              child: AtomicText.mono(
                l10n.conflictItem(conflict.title, _fmt(conflict.startTime),
                    _fmt(conflict.endTime)),
                style: AtomicType.caption,
              ),
            ),
          const SizedBox(height: AtomicSpace.m),
          if (_suggestion != null)
            _SuggestionCard(
              suggestion: _suggestion!,
              formatTime: _fmt,
              problem: _suggestionProblem,
            ),
          if (_aiRawText != null) _RawAiTextCard(text: _aiRawText!),
          if (_aiError != null)
            AtomicWarningBox(
              title: l10n.aiCouldNotHelp,
              message: l10n.aiFailure(
                  _aiError!, ref.watch(activeAiProviderProvider).value),
            ),
          const SizedBox(height: AtomicSpace.s),
          if (_suggestion != null) ...[
            AtomicButton(
              label: l10n.applySuggestedTime,
              icon: AtomicIcons.check,
              expand: true,
              onPressed:
                  busy || _suggestionProblem != null ? null : _applySuggestion,
            ),
            const SizedBox(height: AtomicSpace.s),
          ],
          AtomicButton(
            label: _suggestion == null && _aiRawText == null
                ? l10n.askAiToHelp
                : l10n.askAgain,
            busyLabel: l10n.asking,
            busy: _asking,
            icon: AtomicIcons.ai,
            variant: AtomicButtonVariant.ghost,
            expand: true,
            onPressed: _saving ? null : _askAi,
          ),
          const SizedBox(height: AtomicSpace.s),
          AtomicButton(
            label: l10n.editTimes,
            icon: AtomicIcons.edit,
            variant: AtomicButtonVariant.ghost,
            expand: true,
            // true = reopen the form with these values (K15).
            onPressed: _saving ? null : () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: AtomicSpace.xs),
          Center(
            child: AtomicButton(
              label: l10n.saveAnyway,
              busyLabel: l10n.saving,
              busy: _saving,
              variant: AtomicButtonVariant.text,
              onPressed: _asking ? null : _saveAnyway,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.formatTime,
    this.problem,
  });

  final ConflictResolutionSuggestion suggestion;
  final String Function(DateTime) formatTime;
  final SuggestionProblem? problem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.atomic.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: AtomicSpace.xs),
      child: AtomicCard(
        kind: problem == null ? AtomicCardKind.selected : AtomicCardKind.panel,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AtomicText.display(
              l10n.suggestedTime(formatTime(suggestion.newStartTime),
                  formatTime(suggestion.newEndTime)),
              style: AtomicType.rowTitle,
            ),
            const SizedBox(height: AtomicSpace.xxs),
            AtomicText.body(suggestion.reason),
            if (problem != null) ...[
              const SizedBox(height: AtomicSpace.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(AtomicIcons.blocked,
                      size: AtomicSize.iconTiny, color: p.danger),
                  const SizedBox(width: AtomicSpace.iconLabelGap),
                  Expanded(
                    child: AtomicText.body(
                      l10n.cantApply(_problemText(l10n, problem!)),
                      style: AtomicType.bodySmall.copyWith(color: p.danger),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RawAiTextCard extends StatelessWidget {
  const _RawAiTextCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AtomicSpace.xs),
      child: AtomicCard(
        kind: AtomicCardKind.panel,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AtomicText.mono(context.l10n.aiRawTextIntro,
                style: AtomicType.caption),
            const SizedBox(height: AtomicSpace.xxs),
            AtomicText.body(text),
          ],
        ),
      ),
    );
  }
}

String _problemText(AppLocalizations l10n, SuggestionProblem problem) =>
    switch (problem) {
      SuggestionEndNotAfterStart() => l10n.problemEndNotAfterStart,
      SuggestionNotSameDay() => l10n.problemNotSameDay,
      SuggestionLengthChanged(:final got, :final wanted) =>
        l10n.problemLengthChanged(got, wanted),
      SuggestionStillOverlaps(:final blockTitle) =>
        l10n.problemStillOverlaps(blockTitle),
    };
