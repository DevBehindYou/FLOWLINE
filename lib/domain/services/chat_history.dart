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

/// The most recent completed exchanges that fit both limits (K10): at
/// most [maxMessages] messages and [maxChars] characters of content
/// (about 4 characters per token). Exchanges stay whole and in order;
/// older ones are dropped first. Without a window the whole conversation
/// went to the vendor with every message.
List<AIMessage> windowHistory(
  List<AIMessage> history, {
  int maxMessages = defaultHistoryMessages,
  int maxChars = defaultHistoryChars,
}) {
  final kept = <AIMessage>[];
  var chars = 0;
  // Walk back one exchange (user + assistant) at a time.
  for (var i = history.length - 2; i >= 0; i -= 2) {
    final size = history[i].content.length + history[i + 1].content.length;
    if (kept.length + 2 > maxMessages || chars + size > maxChars) break;
    kept.insertAll(0, [history[i], history[i + 1]]);
    chars += size;
  }
  return kept;
}

/// Ten exchanges, or about 6,000 tokens of history, whichever is smaller.
const defaultHistoryMessages = 20;
const defaultHistoryChars = 24000;
