import '../../../domain/ai/ai_contract.dart';
import '../../../domain/entities/ai_provider_config.dart';
import 'http_ai_client.dart';

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
          ],
          'stream': true,
          'options': {'num_predict': request.maxOutputTokens},
          if (request.format == AIResponseFormat.json) 'format': 'json',
        },
      );

  // One JSON object per line: message.content until done: true, which
  // carries done_reason and the token counts.
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
    return jsonString(jsonMap(chunk['message'])?['content']);
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
