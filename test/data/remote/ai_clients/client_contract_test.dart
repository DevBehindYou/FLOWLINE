import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flowline/data/remote/ai_clients/anthropic_client.dart';
import 'package:flowline/data/remote/ai_clients/gemini_client.dart';
import 'package:flowline/data/remote/ai_clients/ollama_client.dart';
import 'package:flowline/data/remote/ai_clients/openai_client.dart';
import 'package:flowline/domain/ai/ai_contract.dart';
import 'package:flowline/domain/entities/ai_message.dart';
import 'package:flowline/domain/entities/ai_provider_config.dart';
import 'package:flowline/domain/repositories/ai_client.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers every request with one canned status + body and records it.
class _CannedAdapter implements HttpClientAdapter {
  _CannedAdapter(this.status, this.body);

  final int status;
  final Object body;
  RequestOptions? lastRequest;
  Object? lastBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    lastBody = options.data;
    return ResponseBody.fromString(
      body is String ? body as String : jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Fails like an unreachable host, or a timeout.
class _FailingAdapter implements HttpClientAdapter {
  _FailingAdapter(this.type);
  final DioExceptionType type;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) {
    throw DioException(requestOptions: options, type: type);
  }

  @override
  void close({bool force = false}) {}
}

/// Never answers until the request is cancelled.
class _HangingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    await cancelFuture;
    throw DioException.requestCancelled(
        requestOptions: options, reason: 'stop');
  }

  @override
  void close({bool force = false}) {}
}

typedef _Vendor = ({
  String name,
  AIClient Function(Dio) create,
  AIProviderId id,
  Object okBody,
  Object cutOffBody,
  Object modelsBody,
  List<String> modelIds,
});

final _vendors = <_Vendor>[
  (
    name: 'Anthropic',
    create: AnthropicClient.new,
    id: AIProviderId.anthropic,
    okBody: {
      'content': [
        {'type': 'text', 'text': 'Hel'},
        {'type': 'tool_use', 'id': 'x'},
        {'type': 'text', 'text': 'lo'},
      ],
      'stop_reason': 'end_turn',
      'usage': {'input_tokens': 12, 'output_tokens': 3},
    },
    cutOffBody: {
      'content': [
        {'type': 'text', 'text': 'Hel'},
      ],
      'stop_reason': 'max_tokens',
    },
    modelsBody: {
      'data': [
        {'id': 'claude-b', 'display_name': 'Claude B'},
        {'id': 'claude-a', 'display_name': 'Claude A'},
      ],
    },
    modelIds: ['claude-a', 'claude-b'],
  ),
  (
    name: 'OpenAI',
    create: OpenAIClient.new,
    id: AIProviderId.openai,
    okBody: {
      'choices': [
        {
          'message': {'role': 'assistant', 'content': 'Hello'},
          'finish_reason': 'stop',
        },
      ],
      'usage': {'prompt_tokens': 12, 'completion_tokens': 3},
    },
    cutOffBody: {
      'choices': [
        {
          'message': {'content': 'Hel'},
          'finish_reason': 'length',
        },
      ],
    },
    modelsBody: {
      'data': [
        {'id': 'gpt-b'},
        {'id': 'gpt-a'},
      ],
    },
    modelIds: ['gpt-a', 'gpt-b'],
  ),
  (
    name: 'Gemini',
    create: GeminiClient.new,
    id: AIProviderId.gemini,
    okBody: {
      'candidates': [
        {
          'content': {
            'parts': [
              {'text': 'Hel'},
              {'text': 'lo'},
            ],
          },
          'finishReason': 'STOP',
        },
      ],
      'usageMetadata': {'promptTokenCount': 12, 'candidatesTokenCount': 3},
    },
    cutOffBody: {
      'candidates': [
        {
          'content': {
            'parts': [
              {'text': 'Hel'},
            ],
          },
          'finishReason': 'MAX_TOKENS',
        },
      ],
    },
    modelsBody: {
      'models': [
        {
          'name': 'models/gemini-b',
          'supportedGenerationMethods': ['generateContent'],
        },
        {
          'name': 'models/embedding-x',
          'supportedGenerationMethods': ['embedContent'],
        },
        {
          'name': 'models/gemini-a',
          'displayName': 'Gemini A',
          'supportedGenerationMethods': ['generateContent'],
        },
      ],
    },
    modelIds: ['gemini-a', 'gemini-b'],
  ),
  (
    name: 'Ollama',
    create: OllamaClient.new,
    id: AIProviderId.ollama,
    okBody: {
      'message': {'role': 'assistant', 'content': 'Hello'},
      'done_reason': 'stop',
      'prompt_eval_count': 12,
      'eval_count': 3,
    },
    cutOffBody: {
      'message': {'content': 'Hel'},
      'done_reason': 'length',
    },
    modelsBody: {
      'models': [
        {'name': 'mistral'},
        {'name': 'llama3.2'},
      ],
    },
    modelIds: ['llama3.2', 'mistral'],
  ),
];

void main() {
  final history = [
    AIMessage(
        id: 1,
        conversationId: 1,
        role: AIMessageRole.user,
        content: 'earlier',
        sentAt: DateTime(2026)),
    AIMessage(
        id: 2,
        conversationId: 1,
        role: AIMessageRole.assistant,
        content: 'reply',
        sentAt: DateTime(2026)),
  ];

  for (final vendor in _vendors) {
    group(vendor.name, () {
      final config = AIProviderConfig(
        id: vendor.id,
        displayName: vendor.name,
        defaultModel: 'test-model',
        baseUrl: vendor.id == AIProviderId.ollama
            ? 'http://192.168.1.20:11434'
            : null,
        isActive: true,
      );
      AIRequest request({
        String? system,
        AIResponseFormat format = AIResponseFormat.text,
      }) =>
          AIRequest(
            config: config,
            apiKey: 'secret-key',
            prompt: 'hi',
            history: history,
            system: system,
            maxOutputTokens: 321,
            format: format,
          );

      Future<(List<AIEvent>, _CannedAdapter)> send(int status, Object body,
          {AIRequest? with_}) async {
        final adapter = _CannedAdapter(status, body);
        final client = vendor.create(Dio()..httpClientAdapter = adapter);
        final events = await client.send(with_ ?? request()).toList();
        return (events, adapter);
      }

      AIFailure failureOf(List<AIEvent> events) => events.single as AIFailure;

      test('a reply is text, then Done with stop reason and usage', () async {
        final (events, _) = await send(200, vendor.okBody);
        expect(events, hasLength(2));
        expect((events[0] as AITextDelta).text, 'Hello');
        final done = events[1] as AIDone;
        expect(done.stopReason, AIStopReason.complete);
        expect(done.usage?.inputTokens, 12);
        expect(done.usage?.outputTokens, 3);
      });

      test('a cut-off reply says so (B18)', () async {
        final (events, _) = await send(200, vendor.cutOffBody);
        expect((events.last as AIDone).stopReason, AIStopReason.maxTokens);
      });

      test('sends history then the prompt, the model and the token limit',
          () async {
        final (_, adapter) = await send(200, vendor.okBody);
        final body = jsonEncode(adapter.lastBody);
        // Gemini names the model in the URL, the others in the body.
        expect('${adapter.lastRequest!.uri} $body', contains('test-model'));
        expect(body.indexOf('earlier'), lessThan(body.indexOf('reply')));
        expect(body.indexOf('reply'), lessThan(body.lastIndexOf('"hi"')));
        expect(body, contains('321'));
      });

      test('sends the system prompt as instructions, not as a user turn',
          () async {
        final (_, adapter) =
            await send(200, vendor.okBody, with_: request(system: 'Be brief'));
        final body = jsonEncode(adapter.lastBody);
        expect(body, contains('Be brief'));
        expect(body.indexOf('Be brief'), lessThan(body.indexOf('earlier')));
      });

      test('asks for JSON when the request wants it', () async {
        final (_, adapter) = await send(200, vendor.okBody,
            with_: request(format: AIResponseFormat.json));
        expect(jsonEncode(adapter.lastBody).toLowerCase(), contains('json'));
      });

      test('never puts the API key in the URL', () async {
        final (_, adapter) = await send(200, vendor.okBody);
        expect(
            adapter.lastRequest!.uri.toString(), isNot(contains('secret-key')));
      });

      for (final (label, body) in [
        ('an empty object', <String, Object?>{}),
        (
          'the wrong shapes',
          {'content': 'x', 'choices': 5, 'message': <Object?>[]}
        ),
        ('a JSON list', <Object?>[1, 2]),
        ('not JSON at all', '<html>oops</html>'),
      ]) {
        test('turns $label into an empty-response failure', () async {
          final (events, _) = await send(200, body);
          expect(failureOf(events).kind, AIFailureKind.emptyResponse);
        });
      }

      for (final (status, kind) in [
        (401, AIFailureKind.invalidKey),
        (403, AIFailureKind.invalidKey),
        (429, AIFailureKind.rateLimited),
        (500, AIFailureKind.serverError),
        (503, AIFailureKind.serverError),
      ]) {
        test('HTTP $status is a ${kind.name} failure with its status',
            () async {
          final (events, _) = await send(status, {'error': 'nope'});
          expect(failureOf(events).kind, kind);
          expect(failureOf(events).status, status);
        });
      }

      for (final type in [
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        test('${type.name} is unreachable', () async {
          final client =
              vendor.create(Dio()..httpClientAdapter = _FailingAdapter(type));
          final events = await client.send(request()).toList();
          expect(failureOf(events).kind, AIFailureKind.unreachable);
        });
      }

      test('cancelling ends with Done(cancelled), not a failure', () async {
        final client =
            vendor.create(Dio()..httpClientAdapter = _HangingAdapter());
        final cancel = AICancelToken();
        final events = client.send(request(), cancel: cancel).toList();
        cancel.cancel();
        final result = await events;
        expect((result.single as AIDone).stopReason, AIStopReason.cancelled);
      });

      test('lists models, sorted, without the key in the URL', () async {
        final adapter = _CannedAdapter(200, vendor.modelsBody);
        final client = vendor.create(Dio()..httpClientAdapter = adapter);
        final models = await client.listModels(config, 'secret-key');
        expect(models.map((m) => m.id), vendor.modelIds);
        expect(
            adapter.lastRequest!.uri.toString(), isNot(contains('secret-key')));
      });
    });
  }

  group('Ollama', () {
    const config = AIProviderConfig(
      id: AIProviderId.ollama,
      displayName: 'Ollama',
      defaultModel: 'llama3.2',
      baseUrl: 'http://192.168.1.20:11434',
      isActive: true,
    );

    test('a 404 means the model is not pulled', () async {
      final dio = Dio()
        ..httpClientAdapter = _CannedAdapter(404, {'error': 'x'});
      final events = await OllamaClient(dio)
          .send(const AIRequest(config: config, apiKey: '', prompt: 'hi'))
          .toList();
      expect((events.single as AIFailure).kind, AIFailureKind.modelNotFound);
    });

    test('an empty base URL falls back to the default server', () async {
      final adapter = _CannedAdapter(200, {
        'message': {'content': 'ok'},
      });
      await OllamaClient(Dio()..httpClientAdapter = adapter)
          .send(const AIRequest(
            config: AIProviderConfig(
                id: AIProviderId.ollama,
                displayName: 'Ollama',
                defaultModel: 'm',
                baseUrl: '',
                isActive: true),
            apiKey: '',
            prompt: 'hi',
          ))
          .toList();
      expect(adapter.lastRequest!.uri.toString(),
          'http://localhost:11434/api/chat');
    });
  });

  group('collect', () {
    test('joins deltas into the text and keeps the stop reason', () async {
      final result = await collect(Stream.fromIterable(const [
        AITextDelta('Hel'),
        AITextDelta('lo'),
        AIDone(stopReason: AIStopReason.maxTokens),
      ]));
      expect((result as AIText).text, 'Hello');
      expect(result.stopReason, AIStopReason.maxTokens);
    });

    test('passes a failure through', () async {
      final result = await collect(
          Stream.value(const AIFailure(AIFailureKind.rateLimited)));
      expect((result as AIError).failure.kind, AIFailureKind.rateLimited);
    });

    test('a stream that just ends broke the contract', () async {
      final result = await collect(const Stream.empty());
      expect((result as AIError).failure.kind, AIFailureKind.unknown);
    });
  });
}
