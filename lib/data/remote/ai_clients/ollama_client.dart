import 'dart:convert';

import '../../../domain/ai/ai_contract.dart';
import '../../../domain/entities/ai_provider_config.dart';
import 'http_ai_client.dart';
import 'openai_client.dart' show openAiTools;

class OllamaClient extends HttpAIClient {
  OllamaClient(super.dio);

  static const defaultBaseUrl = 'http://localhost:11434';

  @override
  AIProviderId get id => AIProviderId.ollama;

  @override
  StreamFraming get framing => StreamFraming.ndjson;

  static String baseUrlOf(AIProviderConfig config) =>
      (config.baseUrl == null || config.baseUrl!.isEmpty)
          ? defaultBaseUrl
          : config.baseUrl!;

  @override
  VendorCall buildChat(AIRequest request) => (
        url: '${baseUrlOf(request.config)}/api/chat',
        headers: const {},
        body: {
          'model': request.config.defaultModel,
          'messages': [
            if (request.system != null)
              {'role': 'system', 'content': request.system},
            ...chatTurns(request.history, request.prompt),
            ..._continuation(request.continuation),
          ],
          'stream': true,
          // No tool_choice in Ollama: "none" means send no tools.
          if (request.tools.isNotEmpty &&
              request.toolChoice != AIToolChoice.none)
            'tools': openAiTools(request.tools),
          'options': {'num_predict': request.maxOutputTokens},
          if (request.format == AIResponseFormat.json) 'format': 'json',
        },
      );

  // OpenAI's shape, except arguments are objects and results carry the
  // tool's name.
  List<Map<String, Object?>> _continuation(List<AITurn> turns) => [
        for (final t in turns)
          switch (t) {
            AIAssistantTurn() => {
                'role': 'assistant',
                'content': t.text,
                if (t.toolCalls.isNotEmpty)
                  'tool_calls': [
                    for (final c in t.toolCalls)
                      {
                        'function': {
                          'name': c.name,
                          'arguments': jsonObjectOf(c.argumentsJson),
                        },
                      },
                  ],
              },
            AIToolResultTurn() => {
                'role': 'tool',
                'content': t.json,
                'tool_name': t.name,
              },
          },
      ];

  // One JSON object per line: message.content until done: true, which
  // carries done_reason and the token counts. Tool calls arrive whole in
  // message.tool_calls.
  @override
  String? readChunk(Map<String, Object?> chunk, StreamState state) {
    if (chunk['error'] != null) {
      state.failure = const AIFailure(AIFailureKind.unknown);
      return null;
    }
    if (chunk['done'] == true) {
      state.stopReason = switch (jsonString(chunk['done_reason'])) {
        'stop' || null => AIStopReason.complete,
        'length' => AIStopReason.maxTokens,
        _ => AIStopReason.other,
      };
      state.inputTokens = jsonInt(chunk['prompt_eval_count']);
      state.outputTokens = jsonInt(chunk['eval_count']);
    }
    final message = jsonMap(chunk['message']);
    for (final call in jsonList(message?['tool_calls']).map(jsonMap)) {
      final function = jsonMap(call?['function']);
      if (jsonString(function?['name']) case final name?) {
        state.addToolCall(
            id: jsonString(call?['id']),
            name: name,
            json: jsonEncode(function?['arguments'] ?? const {}));
      }
    }
    return jsonString(message?['content']);
  }

  /// Ollama answers 404 for a model that isn't pulled.
  @override
  AIFailureKind? failureForStatus(int status) =>
      status == 404 ? AIFailureKind.modelNotFound : null;

  @override
  VendorCall buildModels(AIProviderConfig config, String apiKey) =>
      (url: '${baseUrlOf(config)}/api/tags', headers: const {}, body: null);

  @override
  List<AIModelInfo> readModels(Map<String, Object?>? body) => [
        for (final m in jsonList(body?['models']).map(jsonMap))
          if (jsonString(m?['name']) case final name?) AIModelInfo(name),
      ];
}
