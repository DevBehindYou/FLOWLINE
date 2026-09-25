import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/schedule_block.dart';
import '../../schedule_intelligence/viewmodel/schedule_intelligence_view_model.dart';
import '../viewmodel/add_edit_schedule_block_view_model.dart';

/// Returned by [AddEditScheduleBlockSheet] (via `Navigator.pop`) instead
/// of saving directly when the pending block overlaps an existing one.
/// The caller — whichever screen opened this sheet — is responsible for
/// showing `ConflictWarningSheet` with a context that's still valid,
/// since this sheet's own context won't be by the time that needs to
/// happen (it's already popped itself).
class ScheduleConflictPending {
  const ScheduleConflictPending({
    required this.title,
    required this.start,
    required this.end,
    required this.conflicts,
    this.existingBlock,
  });

  final String title;
  final DateTime start;
  final DateTime end;
  final List<ScheduleBlock> conflicts;
  final ScheduleBlock? existingBlock;
}

class AddEditScheduleBlockSheet extends ConsumerStatefulWidget {
  const AddEditScheduleBlockSheet({
    super.key,
    required this.initialDate,
    this.existingBlock,
  });

  final DateTime initialDate;
  final ScheduleBlock? existingBlock;

  @override
  ConsumerState<AddEditScheduleBlockSheet> createState() => _AddEditScheduleBlockSheetState();
}

class _AddEditScheduleBlockSheetState extends ConsumerState<AddEditScheduleBlockSheet> {
  late final TextEditingController _titleController =
      TextEditingController(text: widget.existingBlock?.title ?? '');
  late TimeOfDay _startTime = widget.existingBlock != null
      ? TimeOfDay.fromDateTime(widget.existingBlock!.startTime)
      : const TimeOfDay(hour: 9, minute: 0);
  late TimeOfDay _endTime = widget.existingBlock != null
      ? TimeOfDay.fromDateTime(widget.existingBlock!.endTime)
      : const TimeOfDay(hour: 10, minute: 30);
  String? _error;
  bool _saving = false;

  bool get _isEditing => widget.existingBlock != null;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  DateTime _combine(TimeOfDay time) => DateTime(
        widget.initialDate.year,
        widget.initialDate.month,
        widget.initialDate.day,
        time.hour,
        time.minute,
      );

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() => isStart ? _startTime = picked : _endTime = picked);
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Title is required');
      return;
    }
    final start = _combine(_startTime);
    final end = _combine(_endTime);
    if (!end.isAfter(start)) {
      setState(() => _error = 'End time must be after start time');
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    final conflicts = await ref.read(scheduleIntelligenceViewModelProvider.notifier).findConflicts(
          date: widget.initialDate,
          startTime: start,
          endTime: end,
          excludeBlockId: widget.existingBlock?.id,
        );

    if (!mounted) return;

    if (conflicts.isNotEmpty) {
      // Hand off to the caller rather than opening ConflictWarningSheet
      // from here — by the time a user taps through it, this sheet's
      // own context will already be gone.
      Navigator.of(context).pop(
        ScheduleConflictPending(
          title: title,
          start: start,
          end: end,
          conflicts: conflicts,
          existingBlock: widget.existingBlock,
        ),
      );
      return;
    }

    final viewModel = ref.read(addEditScheduleBlockViewModelProvider.notifier);
    if (_isEditing) {
      await viewModel.updateBlock(
        widget.existingBlock!.copyWith(title: title, startTime: start, endTime: end),
      );
    } else {
      await viewModel.createBlock(title: title, startTime: start, endTime: end);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? 'Edit Schedule Block' : 'Add Schedule Block',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              autofocus: !_isEditing,
              decoration: InputDecoration(labelText: 'Block title', errorText: _error),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(isStart: true),
                    child: Text('Start: ${_startTime.format(context)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickTime(isStart: false),
                    child: Text('End: ${_endTime.format(context)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Save Changes' : 'Add Block'),
            ),
          ],
        ),
      ),
    );
  }
}
