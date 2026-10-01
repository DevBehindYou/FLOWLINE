import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/current_day.dart';
import '../../../domain/time/calendar_day.dart';
import '../../../shared_widgets/empty_state.dart';
import '../../../shared_widgets/error_view.dart';
import '../../../shared_widgets/settings_action.dart';
import '../../schedule_block_form/view/schedule_block_flow.dart';
import '../../task_form/view/add_edit_task_sheet.dart';
import '../viewmodel/today_view_model.dart';
import '../widgets/day_timeline.dart';
import '../../../l10n/l10n.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final planAsync = ref.watch(dayPlanProvider);
    final backlogAsync = ref.watch(openBacklogProvider);
    final doneCount = ref.watch(completedBacklogCountProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appTitle),
        actions: const [
          SettingsAction(),
        ],
      ),
      body: Column(
        children: [
          _DateHeader(date: selectedDate),
          Expanded(
            child: planAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorView(
                error: error,
                onRetry: () => ref.invalidate(dayPlanProvider),
              ),
              data: (plan) {
                return backlogAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => ErrorView(
                    error: error,
                    onRetry: () => ref.invalidate(openBacklogProvider),
                  ),
                  data: (backlog) {
                    if (plan.isEmpty && backlog.isEmpty && doneCount == 0) {
                      return EmptyState(
                        icon: Icons.calendar_today_outlined,
                        title: context.l10n.todayEmptyTitle,
                        message: context.l10n.todayEmptyMessage,
                        actionLabel: context.l10n.addTask,
                        onAction: () => _openAddTask(context),
                      );
                    }
                    return DayTimeline(
                      plan: plan,
                      openBacklog: backlog,
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
        label: Text(context.l10n.addTask),
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
            tooltip: context.l10n.previousDay,
            onPressed: actions.previousDay,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  context.l10n.dayLong(date),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (!isToday)
                  TextButton(
                    onPressed: actions.goToToday,
                    child: Text(context.l10n.jumpToToday),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: context.l10n.nextDay,
            onPressed: actions.nextDay,
          ),
        ],
      ),
    );
  }
}
