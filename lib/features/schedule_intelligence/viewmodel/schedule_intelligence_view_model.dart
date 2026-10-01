import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/ai_response.dart';
import '../../../domain/entities/schedule_block.dart';
import '../../../domain/services/conflict_resolution_ai.dart';
import '../../../domain/services/schedule_conflict_checker.dart';

part 'schedule_intelligence_view_model.g.dart';

/// No state of its own — this is a thin orchestration surface over
/// `ScheduleRepository` + `AIRepository` + the pure domain services in
/// `domain/services/`. It's the first ViewModel in the app to read from
/// two repositories, which is exactly the "genuinely cross-repository
/// orchestration" case the earlier phases' READMEs said would justify
/// stepping past a plain repository call — still not a full Use Case
/// class, since there's only one call site (the conflict sheet) so far.
@riverpod
class ScheduleIntelligenceViewModel extends _$ScheduleIntelligenceViewModel {
  @override
  void build() {}

  Future<List<ScheduleBlock>> findConflicts({
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    int? excludeBlockId,
  }) async {
    final blocksForDay = await ref
        .read(scheduleRepositoryProvider)
        .watchBlocksForDay(date)
        .first;
    return const ScheduleConflictChecker().findConflicts(
      startTime: startTime,
      endTime: endTime,
      existingBlocks: blocksForDay,
      excludeBlockId: excludeBlockId,
    );
  }

  Future<AIResponse> suggestResolution({
    required String pendingTitle,
    required DateTime pendingStart,
    required DateTime pendingEnd,
    required List<ScheduleBlock> conflicts,
    int? excludeBlockId,
  }) async {
    // The whole day, minus the block being edited (its old slot is about
    // to be freed), so the model sees everything the suggestion will be
    // validated against.
    final dayBlocks = (await ref
            .read(scheduleRepositoryProvider)
            .watchBlocksForDay(pendingStart)
            .first)
        .where((b) => b.id != excludeBlockId)
        .toList();
    final prompt = buildConflictResolutionPrompt(
      pendingTitle: pendingTitle,
      pendingStart: pendingStart,
      pendingEnd: pendingEnd,
      conflicts: conflicts,
      dayBlocks: dayBlocks,
    );
    return ref.read(aiRepositoryProvider).completeOnce(prompt: prompt);
  }

  /// Re-checks a parsed AI suggestion against the schedule as it is now.
  /// Returns a user-facing reason when it can't be applied, else null.
  Future<String?> validateSuggestion({
    required ConflictResolutionSuggestion suggestion,
    required DateTime pendingStart,
    required DateTime pendingEnd,
    int? excludeBlockId,
  }) async {
    final blocksForDay = await ref
        .read(scheduleRepositoryProvider)
        .watchBlocksForDay(pendingStart)
        .first;
    return validateConflictSuggestion(
      suggestion: suggestion,
      pendingStart: pendingStart,
      pendingEnd: pendingEnd,
      blocksForDay: blocksForDay,
      excludeBlockId: excludeBlockId,
    );
  }
}
