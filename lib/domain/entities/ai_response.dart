/// What an [AIClient] hands back — always a display-ready string, never
/// a raw vendor payload. Errors are represented in-band (isError: true)
/// rather than thrown, so a failed send becomes a visible chat bubble
/// instead of crashing the send flow.
class AIResponse {
  const AIResponse(this.content) : isError = false;
  const AIResponse.error(this.content) : isError = true;

  final String content;
  final bool isError;
}
