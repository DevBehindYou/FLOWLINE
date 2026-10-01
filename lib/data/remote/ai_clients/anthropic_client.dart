import 'package:dio/dio.dart';

import '../../../domain/entities/ai_message.dart';
import '../../../domain/entities/ai_provider_config.dart';
import '../../../domain/entities/ai_response.dart';
import '../../../domain/repositories/ai_client.dart';
import 'json_read.dart';
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

      // Untyped on purpose: a 200 with an unexpected body must read as
      // "empty response", not fail the cast and look like a network error.
      final response = await _dio.post<Object?>(
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

      final data = jsonMap(response.data);
      final text = jsonList(data?['content'])
          .map(jsonMap)
          .whereType<Map<String, Object?>>()
          .where((block) => block['type'] == 'text')
          .map((block) => jsonString(block['text']) ?? '')
          .join();

      if (text.isEmpty) {
        return const AIResponse.error('Anthropic returned an empty response.');
      }
      return AIResponse(text);
    } on DioException catch (e) {
      return AIResponse.error(describeDioError(e, 'Anthropic'));
    } catch (_) {
      // No exception text in the bubble (K9): it's unreadable for users and
      // can include request details.
      return const AIResponse.error(
          'Something went wrong talking to Anthropic. Please try again.');
    }
  }
}
