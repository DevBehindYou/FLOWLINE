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
  VendorReply? readChat(Map<String, Object?>? body) {
    final choice = jsonMap(jsonList(body?['choices']).firstOrNull);
    final text = jsonString(jsonMap(choice?['message'])?['content']);
    if (text == null) return null;
    final usage = jsonMap(body?['usage']);
    return (
      text: text,
      stopReason: switch (jsonString(choice?['finish_reason'])) {
        'stop' => AIStopReason.complete,
        'length' => AIStopReason.maxTokens,
        _ => AIStopReason.other,
      },
      usage: AIUsage(
        inputTokens: jsonInt(usage?['prompt_tokens']),
        outputTokens: jsonInt(usage?['completion_tokens']),
      ),
    );
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
