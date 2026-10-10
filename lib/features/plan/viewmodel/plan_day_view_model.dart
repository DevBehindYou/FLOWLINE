import 'package:clock/clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../assistant/assistant_providers.dart';
import '../../../assistant/tools/tool_registry.dart';
import '../../../core/providers.dart';
import '../../../data/assistant/tool_executor.dart';
import '../../../domain/assistant/autonomy.dart';
import '../../../domain/assistant/day_planner.dart';
import '../../../domain/assistant/quick_parse.dart' show isoLocal;
import '../../../domain/time/calendar_day.dart';

part 'plan_day_view_model.g.dart';

/// What PLAN MY DAY would do now (docs/05 §12.3): a preview, nothing
/// written.
@riverpod
Future<List<PlannedTask>> dayPlanPreview(Ref ref) async {
  final now = clock.now();
  return planDay(
    now: now,
    tasks: await ref.watch(taskRepositoryProvider).findTasks('', limit: 500),
    blocks: await ref
        .watch(scheduleRepositoryProvider)
        .getBlocksForDay(startOfDay(now)),
  );
}

// keepAlive (R11): its methods use `ref` after awaits.
@Riverpod(keepAlive: true)
class PlanDayActions extends _$PlanDayActions {
  @override
  void build() {}

  /// APPLY: each item through `schedule_task` (validated against the day
  /// as it is now), in one ledger group, so one UNDO takes the plan back.
  Future<({String groupId, int planned})> apply(List<PlannedTask> plan) async {
    final registry = ref.read(toolRegistryProvider);
    final executor = ref.read(toolExecutorProvider);
    final groupId = 'plan-${clock.now().microsecondsSinceEpoch}';
    var planned = 0;
    for (final p in plan) {
      final prepared = registry.prepareMap('schedule_task', {
        'task_id': p.task.id,
        'start': isoLocal(p.start),
        'minutes': p.minutes,
      });
      if (prepared is! Prepared) continue;
      final result = await executor.execute(prepared.call,
          groupId: groupId,
          origin: ActionOrigin.said,
          decision: Decision.executeWithUndo);
      if (result is Executed) planned++;
    }
    ref.invalidate(dayPlanPreviewProvider);
    return (groupId: groupId, planned: planned);
  }

  Future<void> undo(String groupId) async {
    await ref.read(undoServiceProvider).undoGroup(groupId);
    ref.invalidate(dayPlanPreviewProvider);
  }
}
