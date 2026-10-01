import 'package:dio/dio.dart';

import '../../../domain/entities/ai_message.dart';
import '../../../domain/entities/ai_provider_config.dart';
import '../../../domain/entities/ai_response.dart';
import '../../../domain/repositories/ai_client.dart';
import 'json_read.dart';

class OllamaClient implements AIClient {
  OllamaClient(this._dio);

  final Dio _dio;

  @override
  AIProviderId get id => AIProviderId.ollama;

  @override
  Future<AIResponse> sendMessage({
    required AIProviderConfig config,
    required String apiKey,
    required String prompt,
    required List<AIMessage> history,
  }) async {
    final baseUrl = (config.baseUrl == null || config.baseUrl!.isEmpty)
        ? 'http://localhost:11434'
        : config.baseUrl!;

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
        '$baseUrl/api/chat',
        data: {
          'model': config.defaultModel,
          'messages': messages,
          'stream': false,
        },
      );

      final data = jsonMap(response.data);
      final text = jsonString(jsonMap(data?['message'])?['content']);
      if (text == null || text.isEmpty) {
        return const AIResponse.error('Ollama returned an empty response.');
      }
      return AIResponse(text);
    } on DioException catch (e) {
      return AIResponse.error(_describeOllamaError(e, baseUrl));
    } catch (_) {
      // No exception text in the bubble (K9): it's unreadable for users and
      // can include request details.
      return const AIResponse.error(
          'Something went wrong talking to Ollama. Please try again.');
    }
  }

  String _describeOllamaError(DioException e, String baseUrl) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      // The single most common way this integration breaks in practice:
      // on a phone, 'localhost' means the phone itself, not the computer
      // running Ollama. Worth saying plainly rather than a generic
      // connection-failed message.
      return "Couldn't reach Ollama at $baseUrl. If it's running on a "
          "computer, use that computer's LAN IP here, not \"localhost\" \u2014 "
          "on a phone, localhost means the phone itself.";
    }
    final status = e.response?.statusCode;
    if (status == 404) {
      return "Ollama responded, but that model isn't pulled yet. "
          "Run: ollama pull ${e.requestOptions.data is Map ? (e.requestOptions.data as Map)['model'] : ''}";
    }
    if (status != null) {
      return 'Ollama returned an error (HTTP $status).';
    }
    return "Couldn't reach Ollama at $baseUrl.";
  }
}
