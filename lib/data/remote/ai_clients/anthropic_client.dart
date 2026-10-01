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
        if (system != null) 'system': system,
        'messages': chatTurns(request.history, request.prompt),
      },
    );
  }

  @override
  VendorReply? readChat(Map<String, Object?>? body) {
    final text = jsonList(body?['content'])
        .map(jsonMap)
        .whereType<Map<String, Object?>>()
        .where((block) => block['type'] == 'text')
        .map((block) => jsonString(block['text']) ?? '')
        .join();
    final usage = jsonMap(body?['usage']);
    return (
      text: text,
      stopReason: switch (jsonString(body?['stop_reason'])) {
        'end_turn' || 'stop_sequence' => AIStopReason.complete,
        'max_tokens' => AIStopReason.maxTokens,
        _ => AIStopReason.other,
      },
      usage: AIUsage(
        inputTokens: jsonInt(usage?['input_tokens']),
        outputTokens: jsonInt(usage?['output_tokens']),
      ),
    );
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
