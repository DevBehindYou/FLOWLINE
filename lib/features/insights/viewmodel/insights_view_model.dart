import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/focus_session.dart';
import '../../../domain/services/focus_stats_calculator.dart';

part 'insights_view_model.g.dart';

const _statsWindowDays = 30; // enough history for a real streak, not just the visible week

@riverpod
Stream<List<FocusSession>> recentFocusSessions(RecentFocusSessionsRef ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day)
      .subtract(const Duration(days: _statsWindowDays - 1));
  final end = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  return ref.watch(focusSessionRepositoryProvider).watchSessionsInRange(start, end);
}

@riverpod
Stream<List<DailyFocusTotal>> weeklyFocusTotals(WeeklyFocusTotalsRef ref) {
  return ref
      .watch(recentFocusSessionsProvider.stream)
      .map((sessions) => const FocusStatsCalculator().dailyTotals(sessions, days: 7));
}

@riverpod
Stream<int> currentStreak(CurrentStreakRef ref) {
  return ref
      .watch(recentFocusSessionsProvider.stream)
      .map((sessions) => const FocusStatsCalculator().currentStreak(sessions));
}
