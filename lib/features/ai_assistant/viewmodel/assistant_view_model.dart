import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../assistant/assistant_providers.dart';
import '../../../assistant/orchestrator.dart';
import '../../../core/providers.dart';
import '../../../data/assistant/undo_service.dart';
import '../../../domain/ai/ai_contract.dart';
import '../../../domain/entities/ai_conversation.dart';
import '../../../domain/entities/ai_message.dart';
import '../../../domain/assistant/ledger.dart';
import '../../../domain/entities/ai_provider_config.dart';
import '../../../domain/assistant/utterance.dart';

part 'assistant_view_model.g.dart';

@riverpod
Stream<List<AIProviderConfig>> aiProviders(Ref ref) {
  return ref.watch(aiRepositoryProvider).watchProviders();
}

@riverpod
Stream<AIProviderConfig?> activeAiProvider(Ref ref) {
  return ref.watch(aiRepositoryProvider).watchActiveProvider();
}

@riverpod
Future<bool> providerHasKey(Ref ref, AIProviderId id) {
  return ref.watch(aiRepositoryProvider).hasKey(id);
}

/// The Assistant tab keeps one ongoing thread per provider rather than a
/// full conversation list (that's a natural Phase 3b addition once this
/// is in use) — this picks the most recent one, if any.
@riverpod
Stream<AIConversation?> latestConversationForProvider(
  Ref ref,
  AIProviderId providerId,
) {
  return ref
      .watch(aiRepositoryProvider)
      .watchConversations()
      .map((conversations) {
    final matching =
        conversations.where((c) => c.providerId == providerId).toList();
    return matching.isEmpty ? null : matching.first;
  });
}

@riverpod
Stream<List<AIMessage>> conversationMessages(Ref ref, int conversationId) {
  return ref.watch(aiRepositoryProvider).watchMessages(conversationId);
}

/// One assistant turn's actions, live: the cards under a chat reply.
@riverpod
Stream<List<LedgerEntry>> turnActions(Ref ref, String groupId) {
  return ref.watch(assistantRepositoryProvider).watchGroup(groupId);
}

/// A call the policy held for the user's yes, waiting for the confirm
/// sheet; or why the last turn stopped early. Cleared once shown.
sealed class AssistNotice {
  const AssistNotice();
}

final class AssistConfirm extends AssistNotice {
  const AssistConfirm(this.pending);
  final PendingConfirmation pending;
}

final class AssistStopped extends AssistNotice {
  const AssistStopped(this.limit);
  final TurnLimit limit;
}

// keepAlive: written after an await, when the screen may be gone (R11).
@Riverpod(keepAlive: true)
class AssistNotices extends _$AssistNotices {
  @override
  AssistNotice? build() => null;

  void show(AssistNotice notice) => state = notice;
  void clear() => state = null;
}

/// What a command typed without an AI provider came to.
enum LocalOutcome {
  /// The local grammar understood it and AA acted (see the ledger group).
  acted,

  /// Understood, but it didn't fit (e.g. a title that matches two tasks).
  rejected,

  /// Not a command the phone knows: it needs a provider.
  needsProvider,
}

/// A command run with no AI provider: the local grammar only. Held for
/// the session (there is no conversation without a provider); what it did
/// is in the ledger, with UNDO, like any other turn.
final class LocalTurn {
  const LocalTurn(
      {required this.text, required this.groupId, required this.outcome});
  final String text;
  final String groupId;
  final LocalOutcome outcome;
}

@Riverpod(keepAlive: true)
class LocalTurns extends _$LocalTurns {
  @override
  List<LocalTurn> build() => const [];

  void add(LocalTurn turn) => state = [...state, turn];
}

// keepAlive (rule R11): an action surface whose methods use `ref` after
// an `await`. Auto-dispose would let it be disposed mid-action (the sheet
// or screen that called it closes), and Riverpod 3 throws on any use of a
// disposed Ref.
@Riverpod(keepAlive: true)
class AssistantViewModel extends _$AssistantViewModel {
  @override
  bool build() => false; // true while a send is in flight

  AICancelToken? _cancel;

  /// Stops the turn in flight; actions that already ran stay done.
  void stop() => _cancel?.cancel();

  /// One assistant turn: the orchestrator acts through its tools, and the
  /// reply (with the turn's actions under it) lands in the conversation.
  Future<void> send({
    required AIProviderId providerId,
    required int? existingConversationId,
    required String prompt,
  }) async {
    state = true;
    final cancel = _cancel = AICancelToken();
    try {
      final conversationId = existingConversationId ??
          await ref
              .read(aiRepositoryProvider)
              .createConversation(providerId: providerId);
      final result = await ref
          .read(assistChatProvider)
          .send(conversationId: conversationId, text: prompt, cancel: cancel);
      final notices = ref.read(assistNoticesProvider.notifier);
      switch (result) {
        case TurnNeedsConfirmation(:final pending):
          notices.show(AssistConfirm(pending));
        case TurnStopped(:final limit):
          notices.show(AssistStopped(limit));
        case TurnAnswered() || TurnFailed():
          break;
      }
    } finally {
      if (identical(_cancel, cancel)) _cancel = null;
      state = false;
    }
  }

  /// A command with no provider: the orchestrator tries the local grammar
  /// and, finding no model, stops there.
  Future<void> sendLocal(String prompt) async {
    state = true;
    try {
      final result = await ref.read(assistantOrchestratorProvider).handle(
          Utterance(prompt, source: UtteranceSource.typed),
          localReads: false);
      final outcome = result is TurnNeedsConfirmation ||
              result.acted.any((a) => a.status == CallStatus.done)
          ? LocalOutcome.acted
          : result.acted.isEmpty
              ? LocalOutcome.needsProvider
              : LocalOutcome.rejected;
      ref.read(localTurnsProvider.notifier).add(
          LocalTurn(text: prompt, groupId: result.groupId, outcome: outcome));
      if (result case TurnNeedsConfirmation(:final pending)) {
        ref.read(assistNoticesProvider.notifier).show(AssistConfirm(pending));
      }
    } finally {
      state = false;
    }
  }

  /// The user said yes on the confirm sheet.
  Future<void> confirm(PendingConfirmation pending) async {
    state = true;
    try {
      await ref.read(assistantOrchestratorProvider).confirm(pending);
    } finally {
      state = false;
    }
  }

  /// UNDO on a turn's card: the whole turn goes back, or nothing does.
  Future<UndoResult> undoTurn(String groupId) =>
      ref.read(undoServiceProvider).undoGroup(groupId);
}
