import '../../../domain/ai/ai_contract.dart';
import '../../../domain/entities/ai_provider_config.dart';
import 'http_ai_client.dart';

class OpenAIClient extends HttpAIClient {
  OpenAIClient(super.dio);

  static const _base = 'https://api.openai.com/v1';

  @override
  AIProviderId get id => AIProviderId.openai;

  Map<String, String> _headers(String apiKey) => {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };

  @override
  VendorCall buildChat(AIRequest request) => (
        url: '$_base/chat/completions',
        headers: _headers(request.apiKey),
        body: {
          'model': request.config.defaultModel,
          // max_tokens is deprecated, and refused by reasoning models.
          'max_completion_tokens': request.maxOutputTokens,
          'stream': true,
          // A last chunk with token usage (no choices).
          'stream_options': {'include_usage': true},
          'messages': [
            if (request.system != null)
              {'role': 'system', 'content': request.system},
            ...chatTurns(request.history, request.prompt),
            ...openAiContinuation(request.continuation),
          ],
          if (request.format == AIResponseFormat.json)
            'response_format': {'type': 'json_object'},
          if (request.tools.isNotEmpty) ...{
            'tools': openAiTools(request.tools),
            'tool_choice': switch (request.toolChoice) {
              AIToolChoice.auto => 'auto',
              AIToolChoice.none => 'none',
              AIToolChoice.required => 'required',
            },
          },
        },
      );

  @override
  String? readChunk(Map<String, Object?> chunk, StreamState state) {
    final usage = jsonMap(chunk['usage']);
    if (usage != null) {
      state.inputTokens = jsonInt(usage['prompt_tokens']);
      state.outputTokens = jsonInt(usage['completion_tokens']);
    }
    if (chunk['error'] != null) {
      state.failure = const AIFailure(AIFailureKind.unknown);
      return null;
    }
    final choice = jsonMap(jsonList(chunk['choices']).firstOrNull);
    final delta = jsonMap(choice?['delta']);
    // Calls stream as fragments keyed by index: the first carries id and
    // name, later ones more of the arguments string.
    for (final call in jsonList(delta?['tool_calls']).map(jsonMap)) {
      final key = jsonInt(call?['index']) ?? 0;
      final function = jsonMap(call?['function']);
      state.startToolCall(key,
          id: jsonString(call?['id']), name: jsonString(function?['name']));
      if (jsonString(function?['arguments']) case final args?) {
        state.appendToolArguments(key, args);
      }
    }
    switch (jsonString(choice?['finish_reason'])) {
      case 'stop':
        state.stopReason = AIStopReason.complete;
      case 'length':
        state.stopReason = AIStopReason.maxTokens;
      case 'tool_calls':
        state.stopReason = AIStopReason.toolUse;
      case null:
        break;
      default:
        state.stopReason = AIStopReason.other;
    }
    return jsonString(delta?['content']);
  }

  @override
  VendorCall buildModels(AIProviderConfig config, String apiKey) =>
      (url: '$_base/models', headers: _headers(apiKey), body: null);

  @override
  List<AIModelInfo> readModels(Map<String, Object?>? body) => [
        for (final m in jsonList(body?['data']).map(jsonMap))
          if (jsonString(m?['id']) case final id?) AIModelInfo(id),
      ];
}

/// Tools in the OpenAI function format (also used by Ollama).
List<Map<String, Object?>> openAiTools(List<AIToolSpec> tools) => [
      for (final t in tools)
        {
          'type': 'function',
          'function': {
            'name': t.name,
            'description': t.description,
            'parameters': t.parameters,
          },
        },
    ];

/// The model's calls as an assistant message, each result as a `tool`
/// message.
List<Map<String, Object?>> openAiContinuation(List<AITurn> turns) => [
      for (final t in turns)
        switch (t) {
          AIAssistantTurn() => {
              'role': 'assistant',
              'content': t.text.isEmpty ? null : t.text,
              if (t.toolCalls.isNotEmpty)
                'tool_calls': [
                  for (final c in t.toolCalls)
                    {
                      'id': c.id,
                      'type': 'function',
                      'function': {
                        'name': c.name,
                        'arguments': c.argumentsJson,
                      },
                    },
                ],
            },
          AIToolResultTurn() => {
              'role': 'tool',
              'tool_call_id': t.callId,
              'content': t.json,
            },
        },
    ];
