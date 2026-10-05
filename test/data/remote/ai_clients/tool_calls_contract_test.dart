import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:atomic_assist/data/remote/ai_clients/anthropic_client.dart';
import 'package:atomic_assist/data/remote/ai_clients/gemini_client.dart';
import 'package:atomic_assist/data/remote/ai_clients/ollama_client.dart';
import 'package:atomic_assist/data/remote/ai_clients/openai_client.dart';
import 'package:atomic_assist/domain/ai/ai_contract.dart';
import 'package:atomic_assist/domain/entities/ai_provider_config.dart';
import 'package:atomic_assist/domain/repositories/ai_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// Tool calling, per vendor (docs/05 §8.1). The fixtures follow each
// vendor's documented streaming shapes (Verify against the vendor docs
// when they change; that is what these fixtures pin).

class _Canned implements HttpClientAdapter {
  _Canned(this.status, this.body);
  final int status;
  final String body;
  Object? lastBody;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    lastBody = options.data;
    return ResponseBody.fromString(body, status, headers: {
      Headers.contentTypeHeader: ['text/event-stream'],
    });
  }

  @override
  void close({bool force = false}) {}
}

class _Dropping implements HttpClientAdapter {
  _Dropping(this.head);
  final String head;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final body = StreamController<Uint8List>();
    body.add(Uint8List.fromList(utf8.encode(head)));
    scheduleMicrotask(() {
      body.addError(DioException(
          requestOptions: options, type: DioExceptionType.connectionError));
      unawaited(body.close());
    });
    return ResponseBody(body.stream, 200);
  }

  @override
  void close({bool force = false}) {}
}

String _sse(List<Object> chunks) =>
    chunks.map((c) => 'data: ${jsonEncode(c)}\n\n').join();

extension on String {
  /// OpenAI ends its stream with a bare `[DONE]` line.
  String withDone() => '${this}data: [DONE]\n\n';
}

String _ndjson(List<Object> chunks) =>
    chunks.map((c) => '${jsonEncode(c)}\n').join();

/// One vendor's fixtures. Calls are `(id, name, argumentsJson)`.
typedef _Fixtures = ({
  String name,
  AIProviderId id,
  AIClient Function(Dio) create,
  String Function(List<(String, String, String)> calls, {String text}) reply,
  // The first call's opening, without its end: what a drop leaves.
  String Function() cutOff,
  // Whether arguments stream as text (raw passes through) or arrive as
  // objects (always valid JSON).
  bool streamsArgumentText,
  // Whether the vendor sends call ids.
  bool sendsIds,
});

// ---- Anthropic: content_block_start (tool_use) + input_json_delta.
String _anthropic(List<(String, String, String)> calls, {String text = ''}) {
  var index = 0;
  return _sse([
    {
      'type': 'message_start',
      'message': {
        'usage': {'input_tokens': 5}
      },
    },
    if (text.isNotEmpty) ...[
      {
        'type': 'content_block_start',
        'index': index,
        'content_block': {'type': 'text', 'text': ''},
      },
      {
        'type': 'content_block_delta',
        'index': index,
        'delta': {'type': 'text_delta', 'text': text},
      },
      {'type': 'content_block_stop', 'index': index++},
    ],
    for (final (id, name, args) in calls) ...[
      {
        'type': 'content_block_start',
        'index': index,
        'content_block': {
          'type': 'tool_use',
          'id': id,
          'name': name,
          'input': <String, Object?>{},
        },
      },
      // Arguments arrive in two fragments.
      {
        'type': 'content_block_delta',
        'index': index,
        'delta': {
          'type': 'input_json_delta',
          'partial_json': args.substring(0, args.length ~/ 2),
        },
      },
      {
        'type': 'content_block_delta',
        'index': index,
        'delta': {
          'type': 'input_json_delta',
          'partial_json': args.substring(args.length ~/ 2),
        },
      },
      {'type': 'content_block_stop', 'index': index++},
    ],
    {
      'type': 'message_delta',
      'delta': {'stop_reason': calls.isEmpty ? 'end_turn' : 'tool_use'},
      'usage': {'output_tokens': 9},
    },
    {'type': 'message_stop'},
  ]);
}

// ---- OpenAI: delta.tool_calls fragments keyed by index.
String _openai(List<(String, String, String)> calls, {String text = ''}) =>
    _sse([
      if (text.isNotEmpty)
        {
          'choices': [
            {
              'delta': {'content': text},
            },
          ],
        },
      for (final (i, (id, name, args)) in calls.indexed) ...[
        {
          'choices': [
            {
              'delta': {
                'tool_calls': [
                  {
                    'index': i,
                    'id': id,
                    'type': 'function',
                    'function': {'name': name, 'arguments': ''},
                  },
                ],
              },
            },
          ],
        },
        for (final part in [
          args.substring(0, args.length ~/ 2),
          args.substring(args.length ~/ 2),
        ])
          {
            'choices': [
              {
                'delta': {
                  'tool_calls': [
                    {
                      'index': i,
                      'function': {'arguments': part},
                    },
                  ],
                },
              },
            ],
          },
      ],
      {
        'choices': [
          {
            'delta': <String, Object?>{},
            'finish_reason': calls.isEmpty ? 'stop' : 'tool_calls',
          },
        ],
      },
    ]).withDone();

// ---- Gemini: functionCall parts, whole; finishReason STOP.
String _gemini(List<(String, String, String)> calls, {String text = ''}) =>
    _sse([
      {
        'candidates': [
          {
            'content': {
              'role': 'model',
              'parts': [
                if (text.isNotEmpty) {'text': text},
                for (final (_, name, args) in calls)
                  {
                    'functionCall': {
                      'name': name,
                      'args': jsonDecode(args),
                    },
                  },
              ],
            },
            'finishReason': 'STOP',
          },
        ],
        'usageMetadata': {'promptTokenCount': 5, 'candidatesTokenCount': 9},
      },
    ]);

// ---- Ollama: message.tool_calls, whole, arguments as an object.
String _ollama(List<(String, String, String)> calls, {String text = ''}) =>
    _ndjson([
      {
        'message': {
          'role': 'assistant',
          'content': text,
          if (calls.isNotEmpty)
            'tool_calls': [
              for (final (_, name, args) in calls)
                {
                  'function': {'name': name, 'arguments': jsonDecode(args)},
                },
            ],
        },
        'done': false,
      },
      {
        'message': {'role': 'assistant', 'content': ''},
        'done': true,
        'done_reason': 'stop',
        'prompt_eval_count': 5,
        'eval_count': 9,
      },
    ]);

final _vendors = <_Fixtures>[
  (
    name: 'Anthropic',
    id: AIProviderId.anthropic,
    create: AnthropicClient.new,
    reply: _anthropic,
    cutOff: () => _sse([
          {
            'type': 'content_block_start',
            'index': 0,
            'content_block': {
              'type': 'tool_use',
              'id': 'toolu_1',
              'name': 'create_task',
            },
          },
          {
            'type': 'content_block_delta',
            'index': 0,
            'delta': {'type': 'input_json_delta', 'partial_json': '{"ti'},
          },
        ]),
    streamsArgumentText: true,
    sendsIds: true,
  ),
  (
    name: 'OpenAI',
    id: AIProviderId.openai,
    create: OpenAIClient.new,
    reply: _openai,
    cutOff: () => _sse([
          {
            'choices': [
              {
                'delta': {
                  'tool_calls': [
                    {
                      'index': 0,
                      'id': 'call_1',
                      'function': {'name': 'create_task', 'arguments': '{"ti'},
                    },
                  ],
                },
              },
            ],
          },
        ]),
    streamsArgumentText: true,
    sendsIds: true,
  ),
  (
    name: 'Gemini',
    id: AIProviderId.gemini,
    create: GeminiClient.new,
    reply: _gemini,
    // A whole call that arrives before the stream's end is still only
    // emitted once the stream ends cleanly.
    cutOff: () => _sse([
          {
            'candidates': [
              {
                'content': {
                  'parts': [
                    {
                      'functionCall': {
                        'name': 'create_task',
                        'args': {'title': 'x'},
                      },
                    },
                  ],
                },
              },
            ],
          },
        ]),
    streamsArgumentText: false,
    sendsIds: false,
  ),
  (
    name: 'Ollama',
    id: AIProviderId.ollama,
    create: OllamaClient.new,
    reply: _ollama,
    cutOff: () => _ndjson([
          {
            'message': {
              'role': 'assistant',
              'content': '',
              'tool_calls': [
                {
                  'function': {
                    'name': 'create_task',
                    'arguments': {'title': 'x'},
                  },
                },
              ],
            },
            'done': false,
          },
        ]),
    streamsArgumentText: false,
    sendsIds: false,
  ),
];

const _createTask = AIToolSpec(
  name: 'create_task',
  description: 'Create a task.',
  parameters: {
    'type': 'object',
    'properties': {
      'title': {'type': 'string', 'maxLength': 140},
    },
    'required': ['title'],
  },
);

void main() {
  for (final v in _vendors) {
    group('${v.name} tools', () {
      final config = AIProviderConfig(
        id: v.id,
        displayName: v.name,
        defaultModel: 'test-model',
        isActive: true,
      );
      AIRequest request({
        AIToolChoice choice = AIToolChoice.auto,
        List<AITurn> continuation = const [],
      }) =>
          AIRequest(
            config: config,
            apiKey: 'k',
            prompt: 'remind me to call Mum at 7',
            tools: const [_createTask],
            toolChoice: choice,
            continuation: continuation,
          );

      Future<(List<AIEvent>, _Canned)> send(String body,
          {int status = 200, AIRequest? with_}) async {
        final adapter = _Canned(status, body);
        final client = v.create(Dio()..httpClientAdapter = adapter);
        return (await client.send(with_ ?? request()).toList(), adapter);
      }

      test('one call: emitted whole, then Done(toolUse)', () async {
        final (events, _) = await send(
            v.reply([('c1', 'create_task', '{"title":"Call Mum"}')]));
        final call = events.whereType<AIToolCall>().single;
        expect(call.name, 'create_task');
        expect(jsonDecode(call.argumentsJson), {'title': 'Call Mum'});
        expect(call.id, v.sendsIds ? 'c1' : isNotEmpty);
        expect((events.last as AIDone).stopReason, AIStopReason.toolUse);
        expect(events.whereType<AIFailure>(), isEmpty);
      });

      test('two calls keep their order and distinct ids', () async {
        final (events, _) = await send(v.reply([
          ('c1', 'create_task', '{"title":"A"}'),
          ('c2', 'create_task', '{"title":"B"}'),
        ]));
        final calls = events.whereType<AIToolCall>().toList();
        expect(calls.map((c) => (jsonDecode(c.argumentsJson) as Map)['title']),
            ['A', 'B']);
        expect(calls.map((c) => c.id).toSet(), hasLength(2));
      });

      test('text, then a call: the text streams first', () async {
        final (events, _) = await send(
            v.reply([('c1', 'create_task', '{"title":"A"}')], text: 'On it.'));
        final textAt = events.indexWhere((e) => e is AITextDelta);
        final callAt = events.indexWhere((e) => e is AIToolCall);
        expect(textAt, isNonNegative);
        expect(callAt, greaterThan(textAt));
        final turn = await collectToolTurn(Stream.fromIterable(events));
        expect((turn as AIToolTurnReply).text, 'On it.');
        expect(turn.calls, hasLength(1));
      });

      if (v.streamsArgumentText) {
        test('malformed arguments pass through raw (R16: callers validate)',
            () async {
          final (events, _) =
              await send(v.reply([('c1', 'create_task', '{"title": oops')]));
          expect(events.whereType<AIToolCall>().single.argumentsJson,
              '{"title": oops');
        });
      }

      test('a drop mid-call emits no call (an incomplete call never runs)',
          () async {
        final client =
            v.create(Dio()..httpClientAdapter = _Dropping(v.cutOff()));
        final events = await client.send(request()).toList();
        expect(events.whereType<AIToolCall>(), isEmpty);
        expect(events.single, isA<AIFailure>());
      });

      test('a 400 that rejects tools is toolsUnsupported', () async {
        final (events, _) = await send(
            '{"error":"registry.ollama.ai/library/x does not support tools"}',
            status: 400);
        expect(
            (events.single as AIFailure).kind, AIFailureKind.toolsUnsupported);
      });

      test('a 400 about something else stays a server error', () async {
        final (events, _) =
            await send('{"error":"bad request: prompt too long"}', status: 400);
        final failure = events.single as AIFailure;
        expect(failure.kind, AIFailureKind.serverError);
        expect(failure.status, 400);
      });

      test('sends the tools, the choice and the replayed round', () async {
        const continuation = [
          AIAssistantTurn(toolCalls: [
            AIToolCall(
                id: 'c1', name: 'create_task', argumentsJson: '{"title":"A"}'),
          ]),
          AIToolResultTurn(
              callId: 'c1', name: 'create_task', json: '{"ok":true,"id":7}'),
        ];
        final (_, adapter) = await send(v.reply(const []),
            with_: request(
                choice: AIToolChoice.required, continuation: continuation));
        final body = jsonEncode(adapter.lastBody);
        expect(body, contains('create_task'));
        expect(body, contains('Create a task.'));
        expect(body, contains('maxLength'), reason: 'the schema is sent');
        // The replayed call and its result.
        // OpenAI carries arguments as a JSON string (escaped quotes).
        expect(body, matches(RegExp(r'\\?"title\\?":\\?"A\\?"')));
        expect(body, contains(v.id == AIProviderId.gemini ? '"id":7' : 'ok'));
        if (v.id != AIProviderId.ollama) {
          expect(
              body,
              contains(switch (v.id) {
                AIProviderId.anthropic => '"type":"any"',
                AIProviderId.openai => '"tool_choice":"required"',
                _ => '"mode":"ANY"',
              }));
        }
      });

      test('no tools: the request has no tool fields', () async {
        final (_, adapter) = await send(v.reply(const [], text: 'hi'),
            with_: AIRequest(config: config, apiKey: 'k', prompt: 'hi'));
        final body = jsonEncode(adapter.lastBody);
        expect(body, isNot(contains('tool')));
        expect(body, isNot(contains('functionDeclarations')));
      });
    });
  }

  test('Ollama: choice "none" sends no tools (it has no tool_choice)',
      () async {
    final adapter = _Canned(200, _ollama(const [], text: 'ok'));
    await OllamaClient(Dio()..httpClientAdapter = adapter)
        .send(const AIRequest(
          config: AIProviderConfig(
              id: AIProviderId.ollama,
              displayName: 'Ollama',
              defaultModel: 'm',
              isActive: true),
          apiKey: '',
          prompt: 'hi',
          tools: [_createTask],
          toolChoice: AIToolChoice.none,
        ))
        .toList();
    expect(jsonEncode(adapter.lastBody), isNot(contains('"tools"')));
  });

  group('collectToolTurn', () {
    test('no text and no calls is an empty response', () async {
      final r = await collectToolTurn(Stream.value(const AIDone()));
      expect((r as AIToolTurnFailed).failure.kind, AIFailureKind.emptyResponse);
    });

    test('a failure passes through', () async {
      final r = await collectToolTurn(
          Stream.value(const AIFailure(AIFailureKind.rateLimited)));
      expect((r as AIToolTurnFailed).failure.kind, AIFailureKind.rateLimited);
    });
  });
}
