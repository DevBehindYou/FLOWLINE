import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../../../core/time/current_day.dart';
import '../../../domain/entities/export_format.dart';
import '../../../domain/services/focus_stats_calculator.dart';
import '../../../domain/time/calendar_day.dart';

part 'export_view_model.g.dart';

// keepAlive (rule R11): an action surface whose methods use `ref` after
// an `await`. Auto-dispose would let it be disposed mid-action (the sheet
// or screen that called it closes), and Riverpod 3 throws on any use of a
// disposed Ref.
@Riverpod(keepAlive: true)
class ExportViewModel extends _$ExportViewModel {
  @override
  bool build() => false; // true while an export is in flight

  /// Same 7-day window as the Insights dashboard — exporting a range the
  /// person isn't currently looking at would be a surprising mismatch.
  Future<void> export(ExportFormat format) async {
    state = true;
    try {
      final day = ref.read(currentDayProvider);
      final rangeStart = addDays(day, -6);
      final rangeEnd = addDays(day, 1);

      final sessions = await ref
          .read(focusSessionRepositoryProvider)
          .watchCompletedSessionsInRange(rangeStart, rangeEnd)
          .first;
      final streak = const FocusStatsCalculator().currentStreak(sessions);
      final service = ref.read(exportServiceProvider);

      switch (format) {
        case ExportFormat.pdf:
          await service.sharePdf(sessions,
              rangeStart: rangeStart, rangeEnd: rangeEnd, streak: streak);
        case ExportFormat.csv:
          await service.shareCsv(sessions,
              rangeStart: rangeStart, rangeEnd: rangeEnd);
        case ExportFormat.json:
          await service.shareJson(sessions,
              rangeStart: rangeStart, rangeEnd: rangeEnd);
      }
    } finally {
      state = false;
    }
  }
}
