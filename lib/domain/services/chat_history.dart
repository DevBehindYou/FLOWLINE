import '../entities/ai_message.dart';

/// The conversation history to send to a vendor with the next prompt: only
/// completed exchanges, i.e. a user message immediately followed by a
/// successful assistant reply (B31).
///
/// Error bubbles ("That API key was rejected…") and pending placeholders
/// are app UI, not things the model said, so they must never be sent as
/// assistant turns. Dropping only the error would leave two user turns in
/// a row, which the Anthropic API rejects, so the unanswered prompt is
/// dropped with it. The user can see both in the chat; the model sees a
/// clean, alternating transcript.
List<AIMessage> buildChatHistory(List<AIMessage> messages) {
  final history = <AIMessage>[];
  for (var i = 0; i + 1 < messages.length; i++) {
    final prompt = messages[i];
    final reply = messages[i + 1];
    final completed = prompt.role == AIMessageRole.user &&
        reply.role == AIMessageRole.assistant &&
        !reply.isError &&
        !reply.isPending &&
        !prompt.isError;
    if (completed) {
      history
        ..add(prompt)
        ..add(reply);
      i++; // the reply is consumed with its prompt
    }
  }
  return history;
}
