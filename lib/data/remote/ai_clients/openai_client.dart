import 'package:dio/dio.dart';

import '../../../domain/entities/ai_message.dart';
import '../../../domain/entities/ai_provider_config.dart';
import '../../../domain/entities/ai_response.dart';
import '../../../domain/repositories/ai_client.dart';
import 'json_read.dart';
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

      // Untyped on purpose: a 200 with an unexpected body must read as
      // "empty response", not fail the cast and look like a network error.
      final response = await _dio.post<Object?>(
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

      final data = jsonMap(response.data);
      final choice = jsonMap(jsonList(data?['choices']).firstOrNull);
      final text = jsonString(jsonMap(choice?['message'])?['content']);

      if (text == null || text.isEmpty) {
        return const AIResponse.error('OpenAI returned an empty response.');
      }
      return AIResponse(text);
    } on DioException catch (e) {
      return AIResponse.error(describeDioError(e, 'OpenAI'));
    } catch (_) {
      // No exception text in the bubble (K9): it's unreadable for users and
      // can include request details.
      return const AIResponse.error(
          'Something went wrong talking to OpenAI. Please try again.');
    }
  }
}
