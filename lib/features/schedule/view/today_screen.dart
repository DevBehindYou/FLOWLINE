import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/time/current_day.dart';
import '../../../domain/time/calendar_day.dart';
import '../../../shared_widgets/empty_state.dart';
import '../../../shared_widgets/error_view.dart';
import '../../../shared_widgets/settings_action.dart';
import '../../schedule_block_form/view/schedule_block_flow.dart';
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
        actions: const [
          SettingsAction(),
        ],
      ),
      body: Column(
        children: [
          _DateHeader(date: selectedDate),
          Expanded(
            child: blocksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorView(
                error: error,
                onRetry: () =>
                    ref.invalidate(scheduleBlocksForSelectedDateProvider),
              ),
              data: (blocks) {
                return unscheduledAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => ErrorView(
                    error: error,
                    onRetry: () => ref.invalidate(unscheduledTasksProvider),
                  ),
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
    unawaited(showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddEditTaskSheet(),
    ));
  }

  Future<void> _openAddBlock(BuildContext context, DateTime date) =>
      openScheduleBlockEditor(context, day: date);
}

class _DateHeader extends ConsumerWidget {
  const _DateHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.read(selectedDateProvider.notifier);
    final isToday = isSameDay(date, ref.watch(currentDayProvider));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous day',
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
            tooltip: 'Next day',
            onPressed: actions.nextDay,
          ),
        ],
      ),
    );
  }
}
