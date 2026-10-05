import 'dart:async';

import '../entities/ai_message.dart';
import '../entities/ai_provider_config.dart';

// The AI contract, v3 (docs/04 §4.1, docs/05 §8): v2 plus tools. Every vendor client speaks it; the
// features above it (chat, conflict help, Task Breakdown later) never see
// a vendor payload. Streaming, structured output, cancellation and usage
// are fields or events, so adding them doesn't change the interface.

enum AIResponseFormat { text, json }

/// One request to one vendor.
final class AIRequest {
  const AIRequest({
    required this.config,
    required this.apiKey,
    required this.prompt,
    this.history = const [],
    this.system,
    this.maxOutputTokens = 1024,
    this.format = AIResponseFormat.text,
    this.tools = const [],
    this.toolChoice = AIToolChoice.auto,
    this.continuation = const [],
  });

  final AIProviderConfig config;

  /// Empty for vendors that need none (Ollama). Never logged or put in a
  /// URL (see the client contract tests).
  final String apiKey;

  /// Feature-specific instructions, sent the way each vendor expects.
  final String? system;

  /// Completed exchanges only (buildChatHistory), already windowed.
  final List<AIMessage> history;
  final String prompt;
  final int maxOutputTokens;
  final AIResponseFormat format;

  /// Functions the model may call (empty: a plain text request).
  final List<AIToolSpec> tools;
  final AIToolChoice toolChoice;

  /// This request's own earlier rounds, after [prompt]: the model's tool
  /// calls and the results the app sent back (docs/05 §9.3).
  final List<AITurn> continuation;
}

/// A function the model may call. [parameters] is a JSON Schema object
/// limited to the subset every vendor accepts (docs/05 §8.2): type,
/// properties, required, enum, items, description, minimum, maximum,
/// maxLength.
final class AIToolSpec {
  const AIToolSpec({
    required this.name,
    required this.description,
    required this.parameters,
  });

  /// `^[a-z][a-z0-9_]{0,63}$`: stable, stored in the ledger.
  final String name;

  /// For the model only; never shown in the UI.
  final String description;
  final Map<String, Object?> parameters;
}

enum AIToolChoice { auto, none, required }

/// A turn inside one assistant request, replayed on the next round.
sealed class AITurn {
  const AITurn();
}

/// What the model said in a round: text and/or tool calls.
final class AIAssistantTurn extends AITurn {
  const AIAssistantTurn({this.text = '', this.toolCalls = const []});
  final String text;
  final List<AIToolCall> toolCalls;
}

/// The app's answer to one tool call.
final class AIToolResultTurn extends AITurn {
  const AIToolResultTurn({
    required this.callId,
    required this.name,
    required this.json,
    this.isError = false,
  });
  final String callId;
  final String name;

  /// Compact JSON the tool returned (validated, size-capped).
  final String json;
  final bool isError;
}

/// Why a reply ended.
enum AIStopReason { complete, maxTokens, cancelled, other, toolUse }

/// What went wrong, for the UI to put in words (and localize). Stored by
/// index with error replies: append-only (R1).
enum AIFailureKind {
  /// 401/403: the key was rejected.
  invalidKey,

  /// 429.
  rateLimited,

  /// Any other HTTP error; see [AIFailure.status].
  serverError,

  /// No connection, DNS, refused, or timed out.
  unreachable,

  /// A 200 with no usable text.
  emptyResponse,

  /// Ollama 404: the model isn't pulled.
  modelNotFound,

  /// No key saved for a vendor that needs one.
  missingKey,

  /// No provider is active.
  noActiveProvider,

  /// The user stopped it.
  cancelled,

  /// Anything else. The detail is never shown (it can hold request data).
  unknown,

  /// The app was closed while the reply was on its way (B23).
  interrupted,

  /// The model or server rejected a request with tools (docs/05 §8.2);
  /// the caller falls back to a JSON plan.
  toolsUnsupported,
}

final class AIUsage {
  const AIUsage({this.inputTokens, this.outputTokens});
  final int? inputTokens;
  final int? outputTokens;
}

/// What a client emits: text as it arrives, then exactly one [AIDone] or
/// [AIFailure], and nothing after that.
sealed class AIEvent {
  const AIEvent();
}

final class AITextDelta extends AIEvent {
  const AITextDelta(this.text);
  final String text;
}

final class AIDone extends AIEvent {
  const AIDone({this.stopReason = AIStopReason.complete, this.usage});
  final AIStopReason stopReason;
  final AIUsage? usage;
}

/// One complete tool call. Clients assemble streamed argument fragments
/// themselves and emit the call once, after the text. [argumentsJson] is
/// raw model output (R16): callers parse and validate it, clients never
/// do.
final class AIToolCall extends AIEvent {
  const AIToolCall({
    required this.id,
    required this.name,
    required this.argumentsJson,
  });
  final String id;
  final String name;
  final String argumentsJson;
}

final class AIFailure extends AIEvent {
  const AIFailure(this.kind, {this.status});
  final AIFailureKind kind;

  /// The HTTP status, when there was one.
  final int? status;
}

/// Thrown by calls that return a value rather than a stream
/// ([AIClient.listModels]), carrying the same typed failure.
final class AIFailureException implements Exception {
  const AIFailureException(this.failure);
  final AIFailure failure;

  @override
  String toString() => 'AIFailureException(${failure.kind.name})';
}

/// Lets the caller stop a request in flight (the chat's Stop button).
/// Plain Dart, so domain/ stays free of Dio; clients bridge it to their
/// HTTP library.
final class AICancelToken {
  final _cancelled = Completer<void>();

  bool get isCancelled => _cancelled.isCompleted;

  /// Completes when [cancel] is called.
  Future<void> get whenCancelled => _cancelled.future;

  void cancel() {
    if (!_cancelled.isCompleted) _cancelled.complete();
  }
}

/// A model a vendor offers to this key.
final class AIModelInfo {
  const AIModelInfo(this.id, {this.displayName});
  final String id;
  final String? displayName;

  String get label => displayName ?? id;
}

/// The result of a whole request, for callers that don't stream.
sealed class AICompletion {
  const AICompletion();
}

final class AIText extends AICompletion {
  const AIText(this.text, {this.stopReason = AIStopReason.complete});
  final String text;
  final AIStopReason stopReason;
}

final class AIError extends AICompletion {
  const AIError(this.failure);
  final AIFailure failure;
}

/// Collects a client's event stream into one [AICompletion].
Future<AICompletion> collect(Stream<AIEvent> events) async {
  final buffer = StringBuffer();
  await for (final event in events) {
    switch (event) {
      case AITextDelta(:final text):
        buffer.write(text);
      case AIDone(:final stopReason):
        return buffer.isEmpty && stopReason != AIStopReason.cancelled
            ? const AIError(AIFailure(AIFailureKind.emptyResponse))
            : AIText(buffer.toString(), stopReason: stopReason);
      case AIFailure():
        return AIError(event);
      case AIToolCall():
        break; // text callers send no tools; a stray call is ignored
    }
  }
  // A stream that ended without Done or Failure broke the contract.
  return const AIError(AIFailure(AIFailureKind.unknown));
}

/// One round of a request with tools: what the model said and the calls
/// it made, or why it failed.
sealed class AIToolTurnResult {
  const AIToolTurnResult();
}

final class AIToolTurnReply extends AIToolTurnResult {
  const AIToolTurnReply({
    this.text = '',
    this.calls = const [],
    this.stopReason = AIStopReason.complete,
  });
  final String text;
  final List<AIToolCall> calls;
  final AIStopReason stopReason;
}

final class AIToolTurnFailed extends AIToolTurnResult {
  const AIToolTurnFailed(this.failure);
  final AIFailure failure;
}

/// Collects a client's event stream into one [AIToolTurnResult].
Future<AIToolTurnResult> collectToolTurn(Stream<AIEvent> events) async {
  final text = StringBuffer();
  final calls = <AIToolCall>[];
  await for (final event in events) {
    switch (event) {
      case AITextDelta(text: final t):
        text.write(t);
      case AIToolCall():
        calls.add(event);
      case AIDone(:final stopReason):
        if (text.isEmpty && calls.isEmpty) {
          return AIToolTurnFailed(AIFailure(stopReason == AIStopReason.cancelled
              ? AIFailureKind.cancelled
              : AIFailureKind.emptyResponse));
        }
        return AIToolTurnReply(
            text: text.toString(), calls: calls, stopReason: stopReason);
      case AIFailure():
        return AIToolTurnFailed(event);
    }
  }
  return const AIToolTurnFailed(AIFailure(AIFailureKind.unknown));
}
