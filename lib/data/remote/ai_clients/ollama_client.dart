import '../../../domain/ai/ai_contract.dart';
import '../../../domain/entities/ai_provider_config.dart';
import 'http_ai_client.dart';

class OllamaClient extends HttpAIClient {
  OllamaClient(super.dio);

  static const defaultBaseUrl = 'http://localhost:11434';

  @override
  AIProviderId get id => AIProviderId.ollama;

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
          'stream': false,
          'options': {'num_predict': request.maxOutputTokens},
          if (request.format == AIResponseFormat.json) 'format': 'json',
        },
      );

  @override
  VendorReply? readChat(Map<String, Object?>? body) {
    final text = jsonString(jsonMap(body?['message'])?['content']);
    if (text == null) return null;
    return (
      text: text,
      stopReason: switch (jsonString(body?['done_reason'])) {
        'stop' || null => AIStopReason.complete,
        'length' => AIStopReason.maxTokens,
        _ => AIStopReason.other,
      },
      usage: AIUsage(
        inputTokens: jsonInt(body?['prompt_eval_count']),
        outputTokens: jsonInt(body?['eval_count']),
      ),
    );
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
