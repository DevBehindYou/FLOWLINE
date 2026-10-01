import 'package:dio/dio.dart';

import '../../../domain/entities/ai_message.dart';
import '../../../domain/entities/ai_provider_config.dart';
import '../../../domain/entities/ai_response.dart';
import '../../../domain/repositories/ai_client.dart';
import 'json_read.dart';
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

      // Untyped on purpose: a 200 with an unexpected body must read as
      // "empty response", not fail the cast and look like a network error.
      final response = await _dio.post<Object?>(
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

      final data = jsonMap(response.data);
      final candidate = jsonMap(jsonList(data?['candidates']).firstOrNull);
      final parts = jsonList(jsonMap(candidate?['content'])?['parts']);
      final text =
          parts.map((part) => jsonString(jsonMap(part)?['text']) ?? '').join();

      if (text.isEmpty) {
        return const AIResponse.error('Gemini returned an empty response.');
      }
      return AIResponse(text);
    } on DioException catch (e) {
      return AIResponse.error(describeDioError(e, 'Gemini'));
    } catch (_) {
      // No exception text in the bubble (K9): it's unreadable for users and
      // can include request details.
      return const AIResponse.error(
          'Something went wrong talking to Gemini. Please try again.');
    }
  }
}
