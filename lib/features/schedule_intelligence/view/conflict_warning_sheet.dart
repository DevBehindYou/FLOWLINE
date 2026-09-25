import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/schedule_block.dart';
import '../../../domain/services/conflict_resolution_ai.dart';
import '../../schedule_block_form/viewmodel/add_edit_schedule_block_view_model.dart';
import '../viewmodel/schedule_intelligence_view_model.dart';

/// Shown instead of saving directly when the pending block overlaps one
/// or more existing blocks. Three ways out: ask the AI for a suggested
/// non-overlapping time, go back and edit the times by hand, or save the
/// overlap anyway (it'll show a conflict indicator on the Today
/// timeline rather than being hidden).
class ConflictWarningSheet extends ConsumerStatefulWidget {
  const ConflictWarningSheet({
    super.key,
    required this.pendingTitle,
    required this.pendingStart,
    required this.pendingEnd,
    required this.conflicts,
    this.existingBlock,
  });

  final String pendingTitle;
  final DateTime pendingStart;
  final DateTime pendingEnd;
  final List<ScheduleBlock> conflicts;

  /// Non-null when this conflict came from editing an existing block.
  final ScheduleBlock? existingBlock;

  @override
  ConsumerState<ConflictWarningSheet> createState() => _ConflictWarningSheetState();
}

class _ConflictWarningSheetState extends ConsumerState<ConflictWarningSheet> {
  bool _asking = false;
  bool _saving = false;
  ConflictResolutionSuggestion? _suggestion;
  String? _aiRawText;
  String? _aiError;

  Future<void> _askAi() async {
    setState(() {
      _asking = true;
      _suggestion = null;
      _aiRawText = null;
      _aiError = null;
    });

    final response = await ref.read(scheduleIntelligenceViewModelProvider.notifier).suggestResolution(
          pendingTitle: widget.pendingTitle,
          pendingStart: widget.pendingStart,
          pendingEnd: widget.pendingEnd,
          conflicts: widget.conflicts,
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
    setState(() {
      _asking = false;
      if (parsed != null) {
        _suggestion = parsed;
      } else {
        _aiRawText = response.content;
      }
    });
  }

  Future<void> _applySuggestion() async {
    final suggestion = _suggestion;
    if (suggestion == null) return;
    await _commit(suggestion.newStartTime, suggestion.newEndTime);
  }

  Future<void> _saveAnyway() async {
    await _commit(widget.pendingStart, widget.pendingEnd);
  }

  Future<void> _commit(DateTime start, DateTime end) async {
    setState(() => _saving = true);
    final viewModel = ref.read(addEditScheduleBlockViewModelProvider.notifier);
    if (widget.existingBlock != null) {
      await viewModel.updateBlock(
        widget.existingBlock!.copyWith(title: widget.pendingTitle, startTime: start, endTime: end),
      );
    } else {
      await viewModel.createBlock(title: widget.pendingTitle, startTime: start, endTime: end);
    }
    if (mounted) Navigator.of(context).pop();
  }

  String _fmt(DateTime d) => DateFormat.jm().format(d);

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
                Text('Schedule conflict', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '"${widget.pendingTitle}" (${_fmt(widget.pendingStart)} \u2013 ${_fmt(widget.pendingEnd)}) '
              'overlaps:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            for (final conflict in widget.conflicts)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '\u2022 "${conflict.title}" (${_fmt(conflict.startTime)} \u2013 ${_fmt(conflict.endTime)})',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 20),
            if (_suggestion != null) _SuggestionCard(suggestion: _suggestion!, formatTime: _fmt),
            if (_aiRawText != null) _RawAiTextCard(text: _aiRawText!),
            if (_aiError != null) _ErrorCard(message: _aiError!),
            const SizedBox(height: 12),
            if (_suggestion != null)
              ElevatedButton.icon(
                onPressed: _saving ? null : _applySuggestion,
                icon: const Icon(Icons.check),
                label: const Text('Apply suggested time'),
              )
            else
              OutlinedButton.icon(
                onPressed: _asking ? null : _askAi,
                icon: _asking
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_asking ? 'Asking\u2026' : 'Ask AI to help'),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _saving ? null : () => Navigator.of(context).pop(),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit times'),
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
                  : const Text('Save anyway (overlap allowed)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.suggestion, required this.formatTime});

  final ConflictResolutionSuggestion suggestion;
  final String Function(DateTime) formatTime;

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
            'Suggested: ${formatTime(suggestion.newStartTime)} \u2013 ${formatTime(suggestion.newEndTime)}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(suggestion.reason, style: Theme.of(context).textTheme.bodySmall),
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
            "Couldn't turn that into a specific time automatically:",
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
