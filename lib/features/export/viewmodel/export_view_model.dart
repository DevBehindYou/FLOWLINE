import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/export_format.dart';
import '../../../domain/services/focus_stats_calculator.dart';

part 'export_view_model.g.dart';

@riverpod
class ExportViewModel extends _$ExportViewModel {
  @override
  bool build() => false; // true while an export is in flight

  /// Same 7-day window as the Insights dashboard — exporting a range the
  /// person isn't currently looking at would be a surprising mismatch.
  Future<void> export(ExportFormat format) async {
    state = true;
    try {
      final now = DateTime.now();
      final rangeStart =
          DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
      final rangeEnd = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

      final sessions =
          await ref.read(focusSessionRepositoryProvider).watchSessionsInRange(rangeStart, rangeEnd).first;
      final streak = const FocusStatsCalculator().currentStreak(sessions);
      final service = ref.read(exportServiceProvider);

      switch (format) {
        case ExportFormat.pdf:
          await service.sharePdf(sessions, rangeStart: rangeStart, rangeEnd: rangeEnd, streak: streak);
        case ExportFormat.csv:
          await service.shareCsv(sessions, rangeStart: rangeStart, rangeEnd: rangeEnd);
        case ExportFormat.json:
          await service.shareJson(sessions, rangeStart: rangeStart, rangeEnd: rangeEnd);
      }
    } finally {
      state = false;
    }
  }
}
