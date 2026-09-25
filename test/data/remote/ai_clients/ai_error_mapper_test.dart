import 'package:dio/dio.dart';
import 'package:flowline/data/remote/ai_clients/ai_error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _withStatus(int? status) {
  final options = RequestOptions(path: '/test');
  return DioException(
    requestOptions: options,
    response: status == null ? null : Response(requestOptions: options, statusCode: status),
    type: DioExceptionType.badResponse,
  );
}

DioException _withType(DioExceptionType type) {
  return DioException(requestOptions: RequestOptions(path: '/test'), type: type);
}

void main() {
  group('describeDioError', () {
    test('401 reads as a rejected API key, not a raw status code', () {
      final message = describeDioError(_withStatus(401), 'Anthropic');
      expect(message, 'That API key was rejected by Anthropic.');
    });

    test('403 also reads as a rejected API key', () {
      final message = describeDioError(_withStatus(403), 'OpenAI');
      expect(message, 'That API key was rejected by OpenAI.');
    });

    test('429 reads as a rate limit, not a generic error', () {
      final message = describeDioError(_withStatus(429), 'Gemini');
      expect(message, 'Gemini rate-limited this request — try again shortly.');
    });

    test('any other HTTP status includes the code without a stack trace', () {
      final message = describeDioError(_withStatus(500), 'Ollama');
      expect(message, 'Ollama returned an error (HTTP 500).');
    });

    test('a connection timeout reads as a network problem', () {
      final message = describeDioError(_withType(DioExceptionType.connectionTimeout), 'Anthropic');
      expect(message, "Couldn't reach Anthropic — check your connection.");
    });

    test('a receive timeout reads as a network problem', () {
      final message = describeDioError(_withType(DioExceptionType.receiveTimeout), 'OpenAI');
      expect(message, "Couldn't reach OpenAI — check your connection.");
    });

    test('a connection error reads as a network problem', () {
      final message = describeDioError(_withType(DioExceptionType.connectionError), 'Gemini');
      expect(message, "Couldn't reach Gemini — check your connection.");
    });

    test('an unrecognized failure with no status still returns an honest fallback', () {
      final message = describeDioError(_withType(DioExceptionType.unknown), 'Ollama');
      expect(message, "Couldn't reach Ollama.");
    });

    test('never leaks the raw exception string to the message', () {
      final message = describeDioError(_withStatus(401), 'Anthropic');
      expect(message, isNot(contains('DioException')));
      expect(message, isNot(contains('statusCode')));
    });
  });
}
