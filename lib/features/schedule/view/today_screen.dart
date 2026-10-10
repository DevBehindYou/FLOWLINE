import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/current_day.dart';
import '../../../design/atomic.dart';
import '../../../domain/time/calendar_day.dart';
import '../../../shared_widgets/empty_state.dart';
import '../../../shared_widgets/error_view.dart';
import '../../../shared_widgets/settings_action.dart';
import '../../plan/view/plan_day_sheet.dart';
import '../../schedule_block_form/view/schedule_block_flow.dart';
import '../../task_form/view/add_edit_task_sheet.dart';
import '../viewmodel/today_view_model.dart';
import '../widgets/day_timeline.dart';
import '../../../l10n/l10n.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selectedDate = ref.watch(selectedDateProvider);
    final planAsync = ref.watch(dayPlanProvider);
    final backlogAsync = ref.watch(openBacklogProvider);
    final doneCount = ref.watch(completedBacklogCountProvider).value ?? 0;
    final loading = AtomicLoading(label: l10n.loadingDay);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (isSameDay(selectedDate, ref.watch(currentDayProvider)))
            AtomicIconButton(
              icon: AtomicIcons.ai,
              semanticLabel: l10n.planMyDay,
              onPressed: () => showPlanDaySheet(context),
            ),
          const SettingsAction(),
        ],
      ),
      body: Column(
        children: [
          _DateHeader(date: selectedDate),
          Expanded(
            child: planAsync.when(
              loading: () => loading,
              error: (error, _) => ErrorView(
                error: error,
                onRetry: () => ref.invalidate(dayPlanProvider),
              ),
              data: (plan) {
                return backlogAsync.when(
                  loading: () => loading,
                  error: (error, _) => ErrorView(
                    error: error,
                    onRetry: () => ref.invalidate(openBacklogProvider),
                  ),
                  data: (backlog) {
                    if (plan.isEmpty && backlog.isEmpty && doneCount == 0) {
                      return EmptyState(
                        icon: AtomicIcons.calendar,
                        title: l10n.todayEmptyTitle,
                        message: l10n.todayEmptyMessage,
                        actionLabel: l10n.addTask,
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
      // The floating action (system §9.6): ink, not Signal, so the screen
      // keeps at most one Signal primary.
      floatingActionButton: AtomicButton(
        label: l10n.addTask,
        icon: AtomicIcons.add,
        variant: AtomicButtonVariant.solid,
        onPressed: () => _openAddTask(context),
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
    final l10n = context.l10n;
    final actions = ref.read(selectedDateProvider.notifier);
    final isToday = isSameDay(date, ref.watch(currentDayProvider));

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AtomicSpace.xs, vertical: AtomicSpace.xs),
      child: Row(
        children: [
          AtomicIconButton(
            icon: AtomicIcons.chevronLeft,
            semanticLabel: l10n.previousDay,
            onPressed: actions.previousDay,
          ),
          Expanded(
            child: Column(
              children: [
                Semantics(
                  header: true,
                  child: AtomicText.display(l10n.dayLong(date),
                      style: AtomicType.cardTitle, textAlign: TextAlign.center),
                ),
                if (!isToday)
                  AtomicButton(
                    label: l10n.jumpToToday,
                    variant: AtomicButtonVariant.text,
                    onPressed: actions.goToToday,
                  ),
              ],
            ),
          ),
          AtomicIconButton(
            icon: AtomicIcons.chevronRight,
            semanticLabel: l10n.nextDay,
            onPressed: actions.nextDay,
          ),
        ],
      ),
    );
  }
}
