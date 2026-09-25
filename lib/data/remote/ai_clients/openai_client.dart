import 'package:dio/dio.dart';

import '../../../domain/entities/ai_message.dart';
import '../../../domain/entities/ai_provider_config.dart';
import '../../../domain/entities/ai_response.dart';
import '../../../domain/repositories/ai_client.dart';
import 'ai_error_mapper.dart';

class OpenAIClient implements AIClient {
  OpenAIClient(this._dio);

  final Dio _dio;

  @override
  AIProviderId get id => AIProviderId.openai;

  @override
  Future<AIResponse> sendMessage({
    required AIProviderConfig config,
    required String apiKey,
    required String prompt,
    required List<AIMessage> history,
  }) async {
    try {
      final messages = [
        ...history.map(
          (m) => {
            'role': m.role == AIMessageRole.user ? 'user' : 'assistant',
            'content': m.content,
          },
        ),
        {'role': 'user', 'content': prompt},
      ];

      final response = await _dio.post<Map<String, dynamic>>(
        'https://api.openai.com/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': config.defaultModel,
          'messages': messages,
        },
      );

      final choices = (response.data?['choices'] as List?) ?? const [];
      final text = choices.isEmpty
          ? null
          : (choices.first as Map)['message']?['content'] as String?;

      if (text == null || text.isEmpty) {
        return const AIResponse.error('OpenAI returned an empty response.');
      }
      return AIResponse(text);
    } on DioException catch (e) {
      return AIResponse.error(describeDioError(e, 'OpenAI'));
    } catch (e) {
      return AIResponse.error('Unexpected error talking to OpenAI: $e');
    }
  }
}
