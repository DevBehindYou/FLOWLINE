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
        // alt=sse: server-sent events, one GenerateContentResponse each.
        url: '$_base/models/${request.config.defaultModel}'
            ':streamGenerateContent?alt=sse',
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
  String? readChunk(Map<String, Object?> chunk, StreamState state) {
    final usage = jsonMap(chunk['usageMetadata']);
    if (usage != null) {
      state.inputTokens = jsonInt(usage['promptTokenCount']);
      state.outputTokens = jsonInt(usage['candidatesTokenCount']);
    }
    final candidate = jsonMap(jsonList(chunk['candidates']).firstOrNull);
    switch (jsonString(candidate?['finishReason'])) {
      case 'STOP':
        state.stopReason = AIStopReason.complete;
      case 'MAX_TOKENS':
        state.stopReason = AIStopReason.maxTokens;
      case null:
        break;
      default:
        state.stopReason = AIStopReason.other;
    }
    final parts = jsonList(jsonMap(candidate?['content'])?['parts']);
    return parts.map((p) => jsonString(jsonMap(p)?['text']) ?? '').join();
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
