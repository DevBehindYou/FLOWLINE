import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flowline/data/remote/ai_clients/anthropic_client.dart';
import 'package:flowline/data/remote/ai_clients/gemini_client.dart';
import 'package:flowline/data/remote/ai_clients/ollama_client.dart';
import 'package:flowline/data/remote/ai_clients/openai_client.dart';
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

typedef _Vendor = ({
  String name,
  AIClient Function(Dio) create,
  AIProviderId id,
  Object okBody,
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
    },
  ),
  (
    name: 'OpenAI',
    create: OpenAIClient.new,
    id: AIProviderId.openai,
    okBody: {
      'choices': [
        {
          'message': {'role': 'assistant', 'content': 'Hello'},
        },
      ],
    },
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
        },
      ],
    },
  ),
  (
    name: 'Ollama',
    create: OllamaClient.new,
    id: AIProviderId.ollama,
    okBody: {
      'message': {'role': 'assistant', 'content': 'Hello'},
    },
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

      Future<({String content, bool isError, _CannedAdapter adapter})> send(
          int status, Object body) async {
        final adapter = _CannedAdapter(status, body);
        final dio = Dio()..httpClientAdapter = adapter;
        final response = await vendor.create(dio).sendMessage(
              config: config,
              apiKey: 'secret-key',
              prompt: 'hi',
              history: history,
            );
        return (
          content: response.content,
          isError: response.isError,
          adapter: adapter
        );
      }

      test('joins the text of a successful reply', () async {
        final result = await send(200, vendor.okBody);
        expect(result.isError, isFalse);
        expect(result.content, 'Hello');
      });

      test('sends history then the prompt, and the configured model', () async {
        final result = await send(200, vendor.okBody);
        final body = jsonEncode(result.adapter.lastBody);
        // Gemini names the model in the URL, the others in the body.
        expect(
            '${result.adapter.lastRequest!.uri} $body', contains('test-model'));
        expect(body.indexOf('earlier'), lessThan(body.indexOf('reply')));
        expect(body.indexOf('reply'), lessThan(body.lastIndexOf('"hi"')));
      });

      test('never puts the API key in the URL', () async {
        final result = await send(200, vendor.okBody);
        expect(result.adapter.lastRequest!.uri.toString(),
            isNot(contains('secret-key')));
      });

      for (final (label, body) in [
        ('an empty object', <String, Object?>{}),
        (
          'the wrong shapes',
          {'content': 'x', 'choices': 5, 'message': <Object?>[]}
        ),
        ('a JSON list', <Object?>[1, 2]),
      ]) {
        test('turns $label into an error message, never a crash', () async {
          final result = await send(200, body);
          expect(result.isError, isTrue);
          expect(result.content, contains('empty response'));
        });
      }

      test('maps a rejected key or failure to plain language', () async {
        final result = await send(401, {'error': 'nope'});
        expect(result.isError, isTrue);
        expect(result.content, isNot(contains('DioException')));
        expect(result.content, isNot(contains('secret-key')));
      });
    });
  }

  group('Ollama error messages', () {
    const config = AIProviderConfig(
      id: AIProviderId.ollama,
      displayName: 'Ollama',
      defaultModel: 'llama3.2',
      baseUrl: 'http://192.168.1.20:11434',
      isActive: true,
    );

    test('a 404 tells the user to pull the model', () async {
      final dio = Dio()
        ..httpClientAdapter = _CannedAdapter(404, {'error': 'x'});
      final response = await OllamaClient(dio).sendMessage(
          config: config, apiKey: '', prompt: 'hi', history: const []);
      expect(response.isError, isTrue);
      expect(response.content, contains('ollama pull llama3.2'));
    });

    test('an unreachable server explains what localhost means on a phone',
        () async {
      final dio = Dio()..httpClientAdapter = _FailingAdapter();
      final response = await OllamaClient(dio).sendMessage(
          config: config, apiKey: '', prompt: 'hi', history: const []);
      expect(response.isError, isTrue);
      expect(response.content, contains('192.168.1.20'));
      expect(response.content, contains('localhost'));
    });

    test('an empty base URL falls back to the default server', () async {
      final adapter = _CannedAdapter(200, {
        'message': {'content': 'ok'},
      });
      final dio = Dio()..httpClientAdapter = adapter;
      await OllamaClient(dio).sendMessage(
        config: const AIProviderConfig(
            id: AIProviderId.ollama,
            displayName: 'Ollama',
            defaultModel: 'm',
            baseUrl: '',
            isActive: true),
        apiKey: '',
        prompt: 'hi',
        history: const [],
      );
      expect(adapter.lastRequest!.uri.toString(),
          'http://localhost:11434/api/chat');
    });
  });
}

class _FailingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) {
    throw DioException.connectionError(
        requestOptions: options, reason: 'refused');
  }

  @override
  void close({bool force = false}) {}
}
