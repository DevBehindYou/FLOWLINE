import '../ai/ai_contract.dart';

enum AIMessageRole { user, assistant }

class AIMessage {
  const AIMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.isError = false,
    this.isPending = false,
    required this.sentAt,
    this.failure,
    this.stopReason,
  });

  final int id;
  final int conversationId;
  final AIMessageRole role;
  final String content;

  /// True when [content] is actually an error description shown in place
  /// of a real reply (bad key, network failure, vendor error) — the chat
  /// bubble renders these distinctly rather than pretending they're a
  /// normal assistant response.
  final bool isError;

  /// An assistant reply that has been requested but hasn't arrived yet.
  /// Rendered as a placeholder; never sent to a vendor as history.
  final bool isPending;

  final DateTime sentAt;

  /// For an error reply written since schema v7: what went wrong, for the
  /// UI to word. Null for older error rows, whose [content] is the text.
  final AIFailure? failure;

  /// Why a finished reply ended (since schema v9; null before).
  final AIStopReason? stopReason;

  /// The reply hit its length limit and is incomplete (B18).
  bool get wasCutOff =>
      !isError && !isPending && stopReason == AIStopReason.maxTokens;
}
