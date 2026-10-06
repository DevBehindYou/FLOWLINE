import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/providers.dart';
import '../data/assistant/drift_tool_env.dart';
import '../data/assistant/stored_rows.dart';
import '../data/assistant/tool_executor.dart';
import '../data/assistant/undo_service.dart';
import '../domain/assistant/tool.dart';
import '../features/focus_timer/viewmodel/focus_timer_view_model.dart';
import 'assist_chat.dart';
import 'orchestrator.dart';
import 'proposal_service.dart';
import 'reminder_sync.dart';
import 'tools/tool_registry.dart';

part 'assistant_providers.g.dart';

// The assistant core's wiring (docs/05 §9.9). All keepAlive (R11): they
// use `ref` after awaits, and a turn outlives the widget that started it.

@Riverpod(keepAlive: true)
ToolRegistry toolRegistry(Ref ref) => ToolRegistry();

/// A fresh env per call: "now" is read when it's made.
@Riverpod(keepAlive: true)
ToolEnv Function() toolEnvFactory(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final rows = StoredRows(db);
  return () => DriftToolEnv(
        tasks: ref.read(taskRepositoryProvider),
        schedule: ref.read(scheduleRepositoryProvider),
        focus: ref.read(focusSessionRepositoryProvider),
        reminders: ref.read(reminderRepositoryProvider),
        lists: ref.read(listRepositoryProvider),
        people: ref.read(peopleRepositoryProvider),
        settings: ref.read(appSettingsRepositoryProvider),
        rows: rows,
      );
}

/// Effects after a commit: the focus alert for a session AA started, and
/// its cancellation when the start is undone.
final class _AppAfterCommit implements AfterCommitHandler {
  _AppAfterCommit(this._ref);
  final Ref _ref;

  @override
  Future<void> handle(AfterCommit effect) {
    final focus = _ref.read(focusTimerViewModelProvider.notifier);
    return switch (effect) {
      FocusStarted(:final sessionId) => focus.alertForStartedSession(sessionId),
      FocusStopped() => focus.cancelAlert(),
      ReminderTouched(:final reminderId) =>
        _ref.read(reminderSyncProvider).sync(reminderId),
    };
  }
}

@Riverpod(keepAlive: true)
AfterCommitHandler afterCommitHandler(Ref ref) => _AppAfterCommit(ref);

@Riverpod(keepAlive: true)
ToolExecutor toolExecutor(Ref ref) => ToolExecutor(
      db: ref.watch(appDatabaseProvider),
      env: ref.watch(toolEnvFactoryProvider),
      effects: ref.watch(afterCommitHandlerProvider),
    );

@Riverpod(keepAlive: true)
UndoService undoService(Ref ref) => UndoService(
      db: ref.watch(appDatabaseProvider),
      focus: ref.watch(focusSessionRepositoryProvider),
      effects: ref.watch(afterCommitHandlerProvider),
    );

@Riverpod(keepAlive: true)
AssistantOrchestrator assistantOrchestrator(Ref ref) => AssistantOrchestrator(
      registry: ref.watch(toolRegistryProvider),
      ai: ref.watch(aiRepositoryProvider),
      executor: ref.watch(toolExecutorProvider),
      store: ref.watch(assistantRepositoryProvider),
      env: ref.watch(toolEnvFactoryProvider),
      autonomy: () async =>
          (await ref.read(appSettingsRepositoryProvider).get()).autonomy,
    );

@Riverpod(keepAlive: true)
ProposalService proposalService(Ref ref) => ProposalService(
      registry: ref.watch(toolRegistryProvider),
      executor: ref.watch(toolExecutorProvider),
      store: ref.watch(assistantRepositoryProvider),
      env: ref.watch(toolEnvFactoryProvider),
    );

@Riverpod(keepAlive: true)
AssistChat assistChat(Ref ref) => AssistChat(
      ai: ref.watch(aiRepositoryProvider),
      orchestrator: ref.watch(assistantOrchestratorProvider),
    );

@Riverpod(keepAlive: true)
ReminderSync reminderSync(Ref ref) => ReminderSync(
      reminders: ref.watch(reminderRepositoryProvider),
      notifications: () => ref.read(notificationServiceProvider.future),
    );
