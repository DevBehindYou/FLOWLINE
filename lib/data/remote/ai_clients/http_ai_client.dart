import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../domain/ai/ai_contract.dart';
import '../../../domain/entities/ai_message.dart';
import '../../../domain/entities/ai_provider_config.dart';
import '../../../domain/repositories/ai_client.dart';

/// What a vendor needs to describe one HTTP call.
typedef VendorCall = ({
  String url,
  Map<String, String> headers,
  Object? body,
});

/// How a vendor's streaming body is framed.
enum StreamFraming {
  /// Server-sent events: `data: {json}` lines (Anthropic, OpenAI, Gemini).
  sse,

  /// One JSON object per line (Ollama).
  ndjson,
}

/// What a vendor learns while reading a stream, besides the text.
class StreamState {
  AIStopReason stopReason = AIStopReason.complete;
  int? inputTokens;
  int? outputTokens;

  /// Set when the vendor reports an error inside the stream.
  AIFailure? failure;

  AIUsage? get usage => inputTokens == null && outputTokens == null
      ? null
      : AIUsage(inputTokens: inputTokens, outputTokens: outputTokens);
}

/// The shared request/stream/error handling for every HTTP vendor. A
/// vendor subclass only says how to build its call and how to read one
/// chunk of its stream; failures, cancellation and the event order of the
/// contract are handled here once.
abstract class HttpAIClient implements AIClient {
  HttpAIClient(this.dio);

  final Dio dio;

  StreamFraming get framing => StreamFraming.sse;

  /// A streaming chat call.
  VendorCall buildChat(AIRequest request);

  /// The text in one decoded chunk (null or empty for none), recording
  /// stop reason, usage or an in-stream error on [state]. Must not throw;
  /// a throw counts as an unreadable chunk and is skipped.
  String? readChunk(Map<String, Object?> chunk, StreamState state);

  VendorCall buildModels(AIProviderConfig config, String apiKey);
  List<AIModelInfo> readModels(Map<String, Object?>? body);

  /// Vendor-specific status meanings (Ollama's 404); null = the default.
  AIFailureKind? failureForStatus(int status) => null;

  @override
  Stream<AIEvent> send(AIRequest request, {AICancelToken? cancel}) async* {
    if (cancel?.isCancelled ?? false) {
      yield const AIDone(stopReason: AIStopReason.cancelled);
      return;
    }
    final dioCancel = CancelToken();
    unawaited(cancel?.whenCancelled.then((_) => dioCancel.cancel()));
    final call = buildChat(request);
    final state = StreamState();
    var gotText = false;
    try {
      final response = await dio.post<ResponseBody>(
        call.url,
        data: call.body,
        options:
            Options(headers: call.headers, responseType: ResponseType.stream),
        cancelToken: dioCancel,
      );
      final lines = response.data!.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());
      await for (final line in lines) {
        final chunk = _chunk(line);
        if (chunk == null) continue;
        String? text;
        try {
          text = readChunk(chunk, state);
        } catch (_) {
          continue; // a vendor body is untrusted input
        }
        if (state.failure != null) {
          // Text already shown stays; the reply just ends there.
          yield gotText
              ? const AIDone(stopReason: AIStopReason.other)
              : state.failure!;
          return;
        }
        if (text != null && text.isNotEmpty) {
          gotText = true;
          yield AITextDelta(text);
        }
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        yield const AIDone(stopReason: AIStopReason.cancelled);
      } else {
        // Dropped mid-reply: keep what arrived.
        yield gotText
            ? const AIDone(stopReason: AIStopReason.other)
            : _failureFor(e);
      }
      return;
    } catch (_) {
      yield gotText
          ? const AIDone(stopReason: AIStopReason.other)
          : const AIFailure(AIFailureKind.unknown);
      return;
    }
    yield gotText
        ? AIDone(stopReason: state.stopReason, usage: state.usage)
        : const AIFailure(AIFailureKind.emptyResponse);
  }

  /// One decoded JSON chunk from a line of the stream, or null for
  /// framing, keep-alives, `[DONE]` and anything that isn't JSON.
  Map<String, Object?>? _chunk(String line) {
    var payload = line.trim();
    if (framing == StreamFraming.sse) {
      if (!payload.startsWith('data:')) return null;
      payload = payload.substring(5).trim();
      if (payload == '[DONE]') return null;
    }
    if (payload.isEmpty) return null;
    return jsonMap(_decode(payload));
  }

  @override
  Future<List<AIModelInfo>> listModels(
      AIProviderConfig config, String apiKey) async {
    final call = buildModels(config, apiKey);
    final Response<Object?> response;
    try {
      response = await dio.get<Object?>(
        call.url,
        options: Options(headers: call.headers),
      );
    } on DioException catch (e) {
      throw AIFailureException(_failureFor(e));
    }
    final models = readModels(jsonMap(_decode(response.data)))
      ..sort((a, b) => a.id.compareTo(b.id));
    if (models.isEmpty) {
      throw const AIFailureException(AIFailure(AIFailureKind.emptyResponse));
    }
    return models;
  }

  /// Dio decodes a JSON content type itself; a body that arrives as text
  /// or bytes (another content type) is decoded here. Null if it isn't
  /// JSON.
  static Object? _decode(Object? body) {
    try {
      return switch (body) {
        final String text => jsonDecode(text),
        final List<int> bytes => jsonDecode(utf8.decode(bytes)),
        _ => body,
      };
    } on FormatException {
      return null;
    }
  }

  AIFailure _failureFor(DioException e) {
    // Dio's JSON decoder threw: the vendor answered, with a body that
    // isn't JSON.
    if (e.error is FormatException) {
      return const AIFailure(AIFailureKind.emptyResponse);
    }
    final status = e.response?.statusCode;
    if (status != null) {
      final kind = failureForStatus(status) ??
          switch (status) {
            401 || 403 => AIFailureKind.invalidKey,
            429 => AIFailureKind.rateLimited,
            _ => AIFailureKind.serverError,
          };
      return AIFailure(kind, status: status);
    }
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.connectionError =>
        const AIFailure(AIFailureKind.unreachable),
      _ => const AIFailure(AIFailureKind.unknown),
    };
  }
}

/// [AIMessage] history as `{role, content}` maps, the shape OpenAI,
/// Anthropic and Ollama share; [assistantRole] for vendors that name it
/// differently.
List<Map<String, Object?>> chatTurns(
  List<AIMessage> history,
  String prompt, {
  String assistantRole = 'assistant',
}) =>
    [
      for (final m in history)
        {
          'role': m.role == AIMessageRole.user ? 'user' : assistantRole,
          'content': m.content,
        },
      {'role': 'user', 'content': prompt},
    ];

// Typed, never-throwing reads of a decoded JSON response. Vendors change
// response shapes, and a malformed or unexpected body must become an
// "empty response", not a TypeError from a blind cast.

Map<String, Object?>? jsonMap(Object? value) =>
    value is Map ? value.cast<String, Object?>() : null;

List<Object?> jsonList(Object? value) =>
    value is List ? value.cast<Object?>() : const [];

String? jsonString(Object? value) => value is String ? value : null;

int? jsonInt(Object? value) => value is int ? value : null;
