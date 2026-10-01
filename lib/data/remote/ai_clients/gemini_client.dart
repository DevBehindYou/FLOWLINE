import '../../../domain/ai/ai_contract.dart';
import '../../../domain/entities/ai_message.dart';
import '../../../domain/entities/ai_provider_config.dart';
import 'http_ai_client.dart';

class GeminiClient extends HttpAIClient {
  GeminiClient(super.dio);

  static const _base = 'https://generativelanguage.googleapis.com/v1beta';

  @override
  AIProviderId get id => AIProviderId.gemini;

  // Header form rather than a `?key=` query parameter, so the key never
  // ends up in a URL that could be logged somewhere.
  Map<String, String> _headers(String apiKey) => {
        'x-goog-api-key': apiKey,
        'Content-Type': 'application/json',
      };

  Map<String, Object?> _content(String role, String text) => {
        'role': role,
        'parts': [
          {'text': text}
        ],
      };

  @override
  VendorCall buildChat(AIRequest request) => (
        url: '$_base/models/${request.config.defaultModel}:generateContent',
        headers: _headers(request.apiKey),
        body: {
          if (request.system != null)
            'systemInstruction': {
              'parts': [
                {'text': request.system}
              ],
            },
          // Gemini calls its own turns 'model', not 'assistant'.
          'contents': [
            for (final m in request.history)
              _content(
                  m.role == AIMessageRole.user ? 'user' : 'model', m.content),
            _content('user', request.prompt),
          ],
          'generationConfig': {
            'maxOutputTokens': request.maxOutputTokens,
            if (request.format == AIResponseFormat.json)
              'responseMimeType': 'application/json',
          },
        },
      );

  @override
  VendorReply? readChat(Map<String, Object?>? body) {
    final candidate = jsonMap(jsonList(body?['candidates']).firstOrNull);
    final parts = jsonList(jsonMap(candidate?['content'])?['parts']);
    final usage = jsonMap(body?['usageMetadata']);
    return (
      text: parts.map((p) => jsonString(jsonMap(p)?['text']) ?? '').join(),
      stopReason: switch (jsonString(candidate?['finishReason'])) {
        'STOP' => AIStopReason.complete,
        'MAX_TOKENS' => AIStopReason.maxTokens,
        _ => AIStopReason.other,
      },
      usage: AIUsage(
        inputTokens: jsonInt(usage?['promptTokenCount']),
        outputTokens: jsonInt(usage?['candidatesTokenCount']),
      ),
    );
  }

  @override
  VendorCall buildModels(AIProviderConfig config, String apiKey) =>
      (url: '$_base/models', headers: _headers(apiKey), body: null);

  /// Only models that can chat; ids without the `models/` prefix, as
  /// generateContent's URL wants them.
  @override
  List<AIModelInfo> readModels(Map<String, Object?>? body) => [
        for (final m in jsonList(body?['models']).map(jsonMap))
          if (jsonString(m?['name']) case final name?)
            if (jsonList(m?['supportedGenerationMethods'])
                .contains('generateContent'))
              AIModelInfo(name.replaceFirst('models/', ''),
                  displayName: jsonString(m?['displayName'])),
      ];
}
