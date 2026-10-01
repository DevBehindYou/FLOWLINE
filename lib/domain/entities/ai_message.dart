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
}
