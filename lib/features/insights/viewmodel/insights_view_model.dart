import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/focus_session.dart';
import '../../../domain/services/focus_stats_calculator.dart';

part 'insights_view_model.g.dart';

const _statsWindowDays = 30; // enough history for a real streak, not just the visible week

@riverpod
Stream<List<FocusSession>> recentFocusSessions(Ref ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day)
      .subtract(const Duration(days: _statsWindowDays - 1));
  final end = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  return ref.watch(focusSessionRepositoryProvider).watchSessionsInRange(start, end);
}

// Derived synchronously from the one session stream (Riverpod 2.6
// deprecates watching `.stream`), so both stats always come from the
// same snapshot and never flash a loading state of their own.
@riverpod
AsyncValue<List<DailyFocusTotal>> weeklyFocusTotals(Ref ref) {
  return ref
      .watch(recentFocusSessionsProvider)
      .whenData((sessions) => const FocusStatsCalculator().dailyTotals(sessions, days: 7));
}

@riverpod
AsyncValue<int> currentStreak(Ref ref) {
  return ref
      .watch(recentFocusSessionsProvider)
      .whenData((sessions) => const FocusStatsCalculator().currentStreak(sessions));
}
