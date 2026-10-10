import 'package:clock/clock.dart';

import '../domain/ai/ai_contract.dart';
import '../domain/assistant/utterance.dart';
import '../domain/repositories/ai_repository.dart';
import 'orchestrator.dart';

/// The Assist chat on top of the orchestrator (docs/05 §29.10): what the
/// user types is one turn. The prompt and a pending reply are written
/// first (so the chat shows "thinking" and a killed app leaves a visible
/// error, B23); the reply carries the turn's ledger group, so its actions
/// show under it, live, with UNDO.
final class AssistChat {
  AssistChat({required this.ai, required this.orchestrator});

  final AIRepository ai;
  final AssistantOrchestrator orchestrator;

  int _seq = 0;

  Future<TurnResult> send({
    required int conversationId,
    required String text,
    AICancelToken? cancel,
    UtteranceSource source = UtteranceSource.typed,
  }) async {
    final history = await ai.chatHistory(conversationId);
    final groupId = 'chat-$conversationId-'
        '${clock.now().microsecondsSinceEpoch}-${_seq++}';
    final replyId = await ai.beginTurnReply(
        conversationId: conversationId, prompt: text, groupId: groupId);
    TurnResult result;
    try {
      result = await orchestrator.handle(
        Utterance(text, source: source),
        history: history,
        cancel: cancel,
        groupId: groupId,
        localReads: false,
      );
    } on Object {
      await ai.finishTurnReply(replyId,
          failure: const AIFailure(AIFailureKind.unknown));
      rethrow;
    }
    switch (result) {
      case TurnAnswered(:final text):
      case TurnNeedsConfirmation(:final text):
        await ai.finishTurnReply(replyId, text: text);
      case TurnFailed(:final failure):
        await ai.finishTurnReply(replyId, failure: AIFailure(failure));
      case TurnStopped():
        // The actions that ran show under the reply; the screen says why
        // the turn stopped.
        await ai.finishTurnReply(replyId);
    }
    return result;
  }
}
