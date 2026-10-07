import 'package:clock/clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../assistant/assistant_providers.dart';
import '../../../assistant/tools/tool_registry.dart';
import '../../../data/assistant/tool_executor.dart';
import '../../../domain/assistant/autonomy.dart';
import '../../../domain/assistant/briefing.dart';
import '../../../domain/assistant/quick_parse.dart' show isoLocal;
import '../../../domain/entities/task.dart';
import '../../../domain/time/calendar_day.dart';
import '../../voice/viewmodel/voice_controller.dart';

part 'briefing_view_model.g.dart';

/// A briefing as of now (docs/05 §21).
@riverpod
Future<Briefing> briefing(Ref ref, BriefingKind kind) async {
  final now = clock.now();
  final facts = await ref.watch(briefingFactsLoaderProvider).load(now);
  return buildBriefing(kind, facts);
}

// keepAlive (R11): its methods use `ref` after awaits.
@Riverpod(keepAlive: true)
class BriefingActions extends _$BriefingActions {
  @override
  void build() {}

  /// MOVE UNFINISHED TO TOMORROW: each task's due time moves to the same
  /// time tomorrow, through `update_task`, in one ledger group, so one
  /// UNDO puts them all back. Returns the group and how many moved.
  Future<({String groupId, int moved})> moveToTomorrow(List<Task> tasks) async {
    final registry = ref.read(toolRegistryProvider);
    final executor = ref.read(toolExecutorProvider);
    final now = clock.now();
    final groupId = 'briefing-move-${now.microsecondsSinceEpoch}';
    final tomorrow = addDays(now, 1);
    var moved = 0;
    for (final t in tasks) {
      final due = t.dueAt;
      if (due == null) continue;
      final next = DateTime(
          tomorrow.year, tomorrow.month, tomorrow.day, due.hour, due.minute);
      final prepared = registry
          .prepareMap('update_task', {'task_id': t.id, 'due': isoLocal(next)});
      if (prepared is! Prepared) continue;
      final result = await executor.execute(prepared.call,
          groupId: groupId,
          origin: ActionOrigin.said,
          decision: Decision.executeWithUndo);
      if (result is Executed) moved++;
    }
    ref.invalidate(briefingProvider);
    return (groupId: groupId, moved: moved);
  }

  Future<void> undo(String groupId) async {
    await ref.read(undoServiceProvider).undoGroup(groupId);
    ref.invalidate(briefingProvider);
  }

  /// READ ALOUD: the same words as the screen.
  Future<void> readAloud(String script) async {
    final tts = ref.read(textToSpeechProvider);
    await tts.stop();
    await tts.speak(script, languageTag: voiceLanguageTag);
  }
}
