import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/async/run_action.dart';
import '../../../domain/entities/schedule_block.dart';
import '../../../domain/entities/task.dart';
import '../../../shared_widgets/confirm_dialog.dart';
import '../../schedule/viewmodel/today_view_model.dart';
import '../viewmodel/add_edit_task_view_model.dart';

/// Handles both create and edit — pass [existingTask] to edit it in place,
/// or [scheduleBlockId] to create a new task pre-assigned to a block.
///
/// Pops `true` when the task was deleted (so a detail screen showing it
/// can close too), otherwise null.
class AddEditTaskSheet extends ConsumerStatefulWidget {
  const AddEditTaskSheet({super.key, this.existingTask, this.scheduleBlockId});

  final Task? existingTask;
  final int? scheduleBlockId;

  @override
  ConsumerState<AddEditTaskSheet> createState() => _AddEditTaskSheetState();
}

class _AddEditTaskSheetState extends ConsumerState<AddEditTaskSheet> {
  late final TextEditingController _titleController =
      TextEditingController(text: widget.existingTask?.title ?? '');
  late final TextEditingController _notesController =
      TextEditingController(text: widget.existingTask?.notes ?? '');
  late TaskPriority _priority =
      widget.existingTask?.priority ?? TaskPriority.medium;
  late TaskStatus _status = widget.existingTask?.status ?? TaskStatus.todo;
  late int? _blockId =
      widget.existingTask?.scheduleBlockId ?? widget.scheduleBlockId;
  late DateTime? _dueAt = widget.existingTask?.dueAt;
  bool _saving = false;
  String? _titleError;

  bool get _isEditing => widget.existingTask != null;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final initial = _dueAt ?? clock.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(initial.year - 1),
      lastDate: DateTime(initial.year + 5),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _dueAt != null
          ? TimeOfDay.fromDateTime(_dueAt!)
          : const TimeOfDay(hour: 17, minute: 0),
    );
    if (!mounted) return;
    setState(() => _dueAt = DateTime(
        date.year, date.month, date.day, time?.hour ?? 23, time?.minute ?? 59));
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Title is required');
      return;
    }

    setState(() => _saving = true);
    final viewModel = ref.read(addEditTaskViewModelProvider.notifier);
    final notes = _notesController.text.trim();

    final saved = await runAction(
      context,
      () async {
        if (_isEditing) {
          await viewModel.updateTask(
            widget.existingTask!.copyWith(
              title: title,
              notes: notes,
              priority: _priority,
              status: _status,
              scheduleBlockId: () => _blockId,
              dueAt: () => _dueAt,
            ),
          );
        } else {
          await viewModel.createTask(
            title: title,
            notes: notes,
            priority: _priority,
            scheduleBlockId: _blockId,
            dueAt: _dueAt,
          );
        }
        return true;
      },
      failureMessage: "Couldn't save the task — please try again.",
    );

    if (!mounted) return;
    if (saved == true) {
      Navigator.of(context).pop();
    } else {
      setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final task = widget.existingTask!;
    final confirmed = await confirmDestructive(
      context,
      title: 'Delete task?',
      message: '"${task.title}" and its subtasks will be removed permanently.',
    );
    if (!confirmed || !mounted) return;
    setState(() => _saving = true);
    final deleted = await runAction(
      context,
      () async {
        await ref
            .read(addEditTaskViewModelProvider.notifier)
            .deleteTask(task.id);
        return true;
      },
      failureMessage: "Couldn't delete the task — please try again.",
    );
    if (!mounted) return;
    if (deleted == true) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final blocks =
        ref.watch(scheduleBlocksForSelectedDateProvider).value ?? const [];

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
            Center(
              child: Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              _isEditing ? 'Edit Task' : 'Add Task',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              autofocus: !_isEditing,
              decoration:
                  InputDecoration(labelText: 'Title', errorText: _titleError),
              onChanged: (_) {
                if (_titleError != null) setState(() => _titleError = null);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            Text('Priority', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<TaskPriority>(
              segments: const [
                ButtonSegment(value: TaskPriority.low, label: Text('Low')),
                ButtonSegment(
                    value: TaskPriority.medium, label: Text('Medium')),
                ButtonSegment(value: TaskPriority.high, label: Text('High')),
              ],
              selected: {_priority},
              onSelectionChanged: (selection) =>
                  setState(() => _priority = selection.first),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 12),
              Text('Status', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<TaskStatus>(
                segments: const [
                  ButtonSegment(value: TaskStatus.todo, label: Text('To do')),
                  ButtonSegment(
                      value: TaskStatus.inProgress, label: Text('Doing')),
                  ButtonSegment(value: TaskStatus.done, label: Text('Done')),
                ],
                selected: {_status},
                onSelectionChanged: (selection) =>
                    setState(() => _status = selection.first),
              ),
            ],
            const SizedBox(height: 12),
            _BlockPicker(
              blocks: blocks,
              selectedId: _blockId,
              onChanged: (id) => setState(() => _blockId = id),
            ),
            const SizedBox(height: 12),
            _DueField(
              dueAt: _dueAt,
              onPick: _pickDue,
              onClear: () => setState(() => _dueAt = null),
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
                  : Text(_isEditing ? 'Save Changes' : 'Add Task'),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _saving ? null : _delete,
                  style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete task'),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// "Unscheduled" or one of the blocks on the day shown on Today. A task
/// already in a block on another day keeps it ("Keep current block").
class _BlockPicker extends StatelessWidget {
  const _BlockPicker({
    required this.blocks,
    required this.selectedId,
    required this.onChanged,
  });

  final List<ScheduleBlock> blocks;
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final onThisDay = blocks.any((b) => b.id == selectedId);
    final time = DateFormat.jm();
    return DropdownButtonFormField<int?>(
      initialValue: selectedId,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Schedule block'),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('Unscheduled')),
        if (selectedId != null && !onThisDay)
          DropdownMenuItem<int?>(
              value: selectedId, child: const Text('Keep current block')),
        for (final block in blocks)
          DropdownMenuItem<int?>(
            value: block.id,
            child: Text(
              '${block.title} · ${time.format(block.startTime)}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _DueField extends StatelessWidget {
  const _DueField({
    required this.dueAt,
    required this.onPick,
    required this.onClear,
  });

  final DateTime? dueAt;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final label = dueAt == null
        ? 'No due date'
        : 'Due ${DateFormat('EEE, MMM d').format(dueAt!)} '
            '${DateFormat.jm().format(dueAt!)}';
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.event_outlined),
            label: Text(label, overflow: TextOverflow.ellipsis),
          ),
        ),
        if (dueAt != null)
          IconButton(
            tooltip: 'Remove due date',
            icon: const Icon(Icons.close),
            onPressed: onClear,
          ),
      ],
    );
  }
}
