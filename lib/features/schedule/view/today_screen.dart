import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared_widgets/empty_state.dart';
import '../../schedule_block_form/view/add_edit_schedule_block_sheet.dart';
import '../../schedule_intelligence/view/conflict_warning_sheet.dart';
import '../../task_form/view/add_edit_task_sheet.dart';
import '../viewmodel/today_view_model.dart';
import '../widgets/day_timeline.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final blocksAsync = ref.watch(scheduleBlocksForSelectedDateProvider);
    final unscheduledAsync = ref.watch(unscheduledTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flowline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          _DateHeader(date: selectedDate),
          Expanded(
            child: blocksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Something went wrong: $error')),
              data: (blocks) {
                return unscheduledAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Something went wrong: $error')),
                  data: (unscheduled) {
                    if (blocks.isEmpty && unscheduled.isEmpty) {
                      return EmptyState(
                        icon: Icons.calendar_today_outlined,
                        title: 'No tasks yet',
                        message: 'Add your first task to start planning today.',
                        actionLabel: 'Add Task',
                        onAction: () => _openAddTask(context),
                      );
                    }
                    return DayTimeline(
                      blocks: blocks,
                      unscheduledTasks: unscheduled,
                      onAddBlock: () => _openAddBlock(context, selectedDate),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddTask(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  void _openAddTask(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddEditTaskSheet(),
    );
  }

  void _openAddBlock(BuildContext context, DateTime date) async {
    final pendingConflict = await showModalBottomSheet<ScheduleConflictPending>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddEditScheduleBlockSheet(initialDate: date),
    );
    if (pendingConflict != null && context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => ConflictWarningSheet(
          pendingTitle: pendingConflict.title,
          pendingStart: pendingConflict.start,
          pendingEnd: pendingConflict.end,
          conflicts: pendingConflict.conflicts,
          existingBlock: pendingConflict.existingBlock,
        ),
      );
    }
  }
}

class _DateHeader extends ConsumerWidget {
  const _DateHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.read(selectedDateProvider.notifier);
    final isToday = _isSameDay(date, DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: actions.previousDay,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  DateFormat('EEEE, MMM d').format(date),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (!isToday)
                  TextButton(
                    onPressed: actions.goToToday,
                    child: const Text('Jump to today'),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: actions.nextDay,
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
