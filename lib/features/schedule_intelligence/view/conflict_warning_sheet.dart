import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/async/run_action.dart';
import '../../../domain/entities/schedule_block.dart';
import '../../../domain/services/conflict_resolution_ai.dart';
import '../../schedule_block_form/viewmodel/add_edit_schedule_block_view_model.dart';
import '../viewmodel/schedule_intelligence_view_model.dart';
import '../../../l10n/l10n.dart';
import '../../../domain/recurrence/recurrence_rule.dart';

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
  String? _aiError;

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

    if (response.isError) {
      setState(() {
        _asking = false;
        _aiError = response.content;
      });
      return;
    }

    final parsed = parseConflictSuggestion(response.content);
    final problem = parsed == null ? null : await _validate(parsed);
    if (!mounted) return;
    setState(() {
      _asking = false;
      if (parsed != null) {
        _suggestion = parsed;
        _suggestionProblem = problem;
      } else {
        _aiRawText = response.content;
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
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: scheme.error),
                const SizedBox(width: 8),
                Text(context.l10n.scheduleConflict,
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.conflictOverlaps(widget.pendingTitle,
                  _fmt(widget.pendingStart), _fmt(widget.pendingEnd)),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            for (final conflict in widget.conflicts)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  context.l10n.conflictItem(conflict.title,
                      _fmt(conflict.startTime), _fmt(conflict.endTime)),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 20),
            if (_suggestion != null)
              _SuggestionCard(
                suggestion: _suggestion!,
                formatTime: _fmt,
                problem: _suggestionProblem,
              ),
            if (_aiRawText != null) _RawAiTextCard(text: _aiRawText!),
            if (_aiError != null) _ErrorCard(message: _aiError!),
            const SizedBox(height: 12),
            if (_suggestion != null) ...[
              ElevatedButton.icon(
                onPressed: _saving || _asking || _suggestionProblem != null
                    ? null
                    : _applySuggestion,
                icon: const Icon(Icons.check),
                label: Text(context.l10n.applySuggestedTime),
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
              onPressed: _asking || _saving ? null : _askAi,
              icon: _asking
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                _asking
                    ? context.l10n.asking
                    : _suggestion == null && _aiRawText == null
                        ? context.l10n.askAiToHelp
                        : context.l10n.askAgain,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              // true = reopen the form with these values (K15).
              onPressed: _saving ? null : () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.edit_outlined),
              label: Text(context.l10n.editTimes),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _saving ? null : _saveAnyway,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.l10n.saveAnyway),
            ),
          ],
        ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.suggestedTime(formatTime(suggestion.newStartTime),
                formatTime(suggestion.newEndTime)),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(suggestion.reason, style: Theme.of(context).textTheme.bodySmall),
          if (problem != null) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.block,
                    size: 16, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.cantApply(_problemText(l10n, problem!)),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RawAiTextCard extends StatelessWidget {
  const _RawAiTextCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.aiRawTextIntro,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          Text(text, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: TextStyle(color: scheme.onErrorContainer)),
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
