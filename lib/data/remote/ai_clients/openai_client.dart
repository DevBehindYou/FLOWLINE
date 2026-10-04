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
          ],
          if (request.format == AIResponseFormat.json)
            'response_format': {'type': 'json_object'},
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
    switch (jsonString(choice?['finish_reason'])) {
      case 'stop':
        state.stopReason = AIStopReason.complete;
      case 'length':
        state.stopReason = AIStopReason.maxTokens;
      case null:
        break;
      default:
        state.stopReason = AIStopReason.other;
    }
    return jsonString(jsonMap(choice?['delta'])?['content']);
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
