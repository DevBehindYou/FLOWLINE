import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../../../core/time/current_day.dart';
import '../../../domain/entities/focus_session.dart';
import '../../../domain/services/focus_stats_calculator.dart';
import '../../../domain/time/calendar_day.dart';

part 'insights_view_model.g.dart';

const _statsWindowDays =
    30; // enough history for a real streak, not just the visible week

@riverpod
Stream<List<FocusSession>> recentFocusSessions(Ref ref) {
  final day = ref.watch(currentDayProvider);
  return ref
      .watch(focusSessionRepositoryProvider)
      .watchCompletedSessionsInRange(
        addDays(day, -(_statsWindowDays - 1)),
        addDays(day, 1),
      );
}

// Derived synchronously from the one session stream (Riverpod 2.6
// deprecates watching `.stream`), so both stats always come from the
// same snapshot and never flash a loading state of their own.
@riverpod
AsyncValue<List<DailyFocusTotal>> weeklyFocusTotals(Ref ref) {
  return ref.watch(recentFocusSessionsProvider).whenData((sessions) =>
      const FocusStatsCalculator().dailyTotals(sessions, days: 7));
}

@riverpod
AsyncValue<int> currentStreak(Ref ref) {
  return ref.watch(recentFocusSessionsProvider).whenData(
      (sessions) => const FocusStatsCalculator().currentStreak(sessions));
}
