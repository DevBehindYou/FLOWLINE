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

/// What a vendor reads back from a successful reply.
typedef VendorReply = ({
  String text,
  AIStopReason stopReason,
  AIUsage? usage,
});

/// The shared request/response/error handling for every HTTP vendor. A
/// vendor subclass only says how to build its call and how to read its
/// reply; failures, cancellation and the event order of the contract are
/// handled here once.
abstract class HttpAIClient implements AIClient {
  HttpAIClient(this.dio);

  final Dio dio;

  VendorCall buildChat(AIRequest request);

  /// Null when the body has no usable text (reported as empty).
  VendorReply? readChat(Map<String, Object?>? body);

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
    final Response<Object?> response;
    try {
      // Untyped on purpose: a 200 with an unexpected body must read as
      // "empty response", not fail a cast and look like a network error.
      response = await dio.post<Object?>(
        call.url,
        data: call.body,
        // Plain text, decoded below: a 200 whose body isn't JSON must be
        // an empty response, not a decoder error that looks like a crash.
        options:
            Options(headers: call.headers, responseType: ResponseType.plain),
        cancelToken: dioCancel,
      );
    } on DioException catch (e) {
      yield e.type == DioExceptionType.cancel
          ? const AIDone(stopReason: AIStopReason.cancelled)
          : _failureFor(e);
      return;
    } catch (_) {
      yield const AIFailure(AIFailureKind.unknown);
      return;
    }

    final VendorReply? reply;
    try {
      reply = readChat(jsonMap(_decode(response.data)));
    } catch (_) {
      // A reader must never throw, but a vendor body is untrusted input.
      yield const AIFailure(AIFailureKind.emptyResponse);
      return;
    }
    if (reply == null || reply.text.isEmpty) {
      yield const AIFailure(AIFailureKind.emptyResponse);
      return;
    }
    yield AITextDelta(reply.text);
    yield AIDone(stopReason: reply.stopReason, usage: reply.usage);
  }

  @override
  Future<List<AIModelInfo>> listModels(
      AIProviderConfig config, String apiKey) async {
    final call = buildModels(config, apiKey);
    final response = await dio.get<Object?>(
      call.url,
      options: Options(headers: call.headers),
    );
    final models = readModels(jsonMap(_decode(response.data)))
      ..sort((a, b) => a.id.compareTo(b.id));
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
