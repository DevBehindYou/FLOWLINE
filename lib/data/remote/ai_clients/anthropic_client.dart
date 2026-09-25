import 'package:dio/dio.dart';

import '../../../domain/entities/ai_message.dart';
import '../../../domain/entities/ai_provider_config.dart';
import '../../../domain/entities/ai_response.dart';
import '../../../domain/repositories/ai_client.dart';
import 'ai_error_mapper.dart';

class AnthropicClient implements AIClient {
  AnthropicClient(this._dio);

  final Dio _dio;

  @override
  AIProviderId get id => AIProviderId.anthropic;

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
        'https://api.anthropic.com/v1/messages',
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
        ),
        data: {
          'model': config.defaultModel,
          'max_tokens': 1024,
          'messages': messages,
        },
      );

      final blocks = (response.data?['content'] as List?) ?? const [];
      final text = blocks
          .whereType<Map>()
          .where((b) => b['type'] == 'text')
          .map((b) => b['text'] as String? ?? '')
          .join();

      if (text.isEmpty) {
        return const AIResponse.error('Anthropic returned an empty response.');
      }
      return AIResponse(text);
    } on DioException catch (e) {
      return AIResponse.error(describeDioError(e, 'Anthropic'));
    } catch (e) {
      return AIResponse.error('Unexpected error talking to Anthropic: $e');
    }
  }
}
