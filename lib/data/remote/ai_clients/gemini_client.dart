import 'package:dio/dio.dart';

import '../../../domain/entities/ai_message.dart';
import '../../../domain/entities/ai_provider_config.dart';
import '../../../domain/entities/ai_response.dart';
import '../../../domain/repositories/ai_client.dart';
import 'ai_error_mapper.dart';

class GeminiClient implements AIClient {
  GeminiClient(this._dio);

  final Dio _dio;

  @override
  AIProviderId get id => AIProviderId.gemini;

  @override
  Future<AIResponse> sendMessage({
    required AIProviderConfig config,
    required String apiKey,
    required String prompt,
    required List<AIMessage> history,
  }) async {
    try {
      // Gemini uses 'model' rather than 'assistant' for its own turns.
      final contents = [
        ...history.map(
          (m) => {
            'role': m.role == AIMessageRole.user ? 'user' : 'model',
            'parts': [
              {'text': m.content}
            ],
          },
        ),
        {
          'role': 'user',
          'parts': [
            {'text': prompt}
          ],
        },
      ];

      final response = await _dio.post<Map<String, dynamic>>(
        'https://generativelanguage.googleapis.com/v1beta/models/${config.defaultModel}:generateContent',
        options: Options(
          headers: {
            // Header form rather than a `?key=` query param, so the key
            // never ends up in a URL that could be logged somewhere.
            'x-goog-api-key': apiKey,
            'Content-Type': 'application/json',
          },
        ),
        data: {'contents': contents},
      );

      final candidates = (response.data?['candidates'] as List?) ?? const [];
      final parts = candidates.isEmpty
          ? const []
          : ((candidates.first as Map)['content']?['parts'] as List?) ?? const [];
      final text = parts.map((p) => (p as Map)['text'] as String? ?? '').join();

      if (text.isEmpty) {
        return const AIResponse.error('Gemini returned an empty response.');
      }
      return AIResponse(text);
    } on DioException catch (e) {
      return AIResponse.error(describeDioError(e, 'Gemini'));
    } catch (e) {
      return AIResponse.error('Unexpected error talking to Gemini: $e');
    }
  }
}
