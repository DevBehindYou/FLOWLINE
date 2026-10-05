import '../../../domain/ai/ai_contract.dart';
import '../../../domain/entities/ai_provider_config.dart';
import 'http_ai_client.dart';

class AnthropicClient extends HttpAIClient {
  AnthropicClient(super.dio);

  static const _base = 'https://api.anthropic.com/v1';

  @override
  AIProviderId get id => AIProviderId.anthropic;

  Map<String, String> _headers(String apiKey) => {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      };

  @override
  VendorCall buildChat(AIRequest request) {
    var system = request.system;
    if (request.format == AIResponseFormat.json) {
      // No JSON mode in the Messages API: ask for it in the instructions.
      system = [system, 'Reply with one JSON value only, no prose.']
          .whereType<String>()
          .join('\n\n');
    }
    return (
      url: '$_base/messages',
      headers: _headers(request.apiKey),
      body: {
        'model': request.config.defaultModel,
        'max_tokens': request.maxOutputTokens,
        'stream': true,
        if (system != null) 'system': system,
        'messages': [
          ...chatTurns(request.history, request.prompt),
          ..._continuation(request.continuation),
        ],
        if (request.tools.isNotEmpty) ...{
          'tools': [
            for (final t in request.tools)
              {
                'name': t.name,
                'description': t.description,
                'input_schema': t.parameters,
              },
          ],
          'tool_choice': {
            'type': switch (request.toolChoice) {
              AIToolChoice.auto => 'auto',
              AIToolChoice.none => 'none',
              AIToolChoice.required => 'any',
            },
          },
        },
      },
    );
  }

  // The model's round as content blocks; all of a round's results go back
  // in one user message (the Messages API requires that).
  List<Map<String, Object?>> _continuation(List<AITurn> turns) => [
        for (final t in groupToolResults(turns))
          if (t is AIAssistantTurn)
            {
              'role': 'assistant',
              'content': [
                if (t.text.isNotEmpty) {'type': 'text', 'text': t.text},
                for (final c in t.toolCalls)
                  {
                    'type': 'tool_use',
                    'id': c.id,
                    'name': c.name,
                    'input': jsonObjectOf(c.argumentsJson),
                  },
              ],
            }
          else if (t is List<AIToolResultTurn>)
            {
              'role': 'user',
              'content': [
                for (final r in t)
                  {
                    'type': 'tool_result',
                    'tool_use_id': r.callId,
                    'content': r.json,
                    if (r.isError) 'is_error': true,
                  },
              ],
            },
      ];

  // Events (each data line carries its own "type"): message_start (input
  // tokens), content_block_start (a tool_use block: id and name),
  // content_block_delta (text, or input_json_delta fragments of a call's
  // arguments), message_delta (stop reason, output tokens), message_stop,
  // ping, and error.
  @override
  String? readChunk(Map<String, Object?> chunk, StreamState state) {
    switch (jsonString(chunk['type'])) {
      case 'message_start':
        state.inputTokens = jsonInt(
            jsonMap(jsonMap(chunk['message'])?['usage'])?['input_tokens']);
      case 'content_block_start':
        final block = jsonMap(chunk['content_block']);
        if (block?['type'] == 'tool_use') {
          state.startToolCall(jsonInt(chunk['index']) ?? -1,
              id: jsonString(block?['id']), name: jsonString(block?['name']));
        }
      case 'content_block_delta':
        final delta = jsonMap(chunk['delta']);
        switch (delta?['type']) {
          case 'text_delta':
            return jsonString(delta?['text']);
          case 'input_json_delta':
            state.appendToolArguments(jsonInt(chunk['index']) ?? -1,
                jsonString(delta?['partial_json']) ?? '');
        }
      case 'message_delta':
        state.stopReason =
            switch (jsonString(jsonMap(chunk['delta'])?['stop_reason'])) {
          'end_turn' || 'stop_sequence' => AIStopReason.complete,
          'max_tokens' => AIStopReason.maxTokens,
          'tool_use' => AIStopReason.toolUse,
          _ => AIStopReason.other,
        };
        state.outputTokens = jsonInt(jsonMap(chunk['usage'])?['output_tokens']);
      case 'error':
        state.failure = switch (jsonString(jsonMap(chunk['error'])?['type'])) {
          'overloaded_error' =>
            const AIFailure(AIFailureKind.serverError, status: 529),
          'rate_limit_error' => const AIFailure(AIFailureKind.rateLimited),
          'authentication_error' => const AIFailure(AIFailureKind.invalidKey),
          _ => const AIFailure(AIFailureKind.unknown),
        };
    }
    return null;
  }

  @override
  VendorCall buildModels(AIProviderConfig config, String apiKey) =>
      (url: '$_base/models', headers: _headers(apiKey), body: null);

  @override
  List<AIModelInfo> readModels(Map<String, Object?>? body) => [
        for (final m in jsonList(body?['data']).map(jsonMap))
          if (jsonString(m?['id']) case final id?)
            AIModelInfo(id, displayName: jsonString(m?['display_name'])),
      ];
}
