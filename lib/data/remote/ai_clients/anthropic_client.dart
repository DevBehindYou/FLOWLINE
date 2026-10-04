import '../../../domain/ai/ai_contract.dart';
import '../../../domain/entities/ai_provider_config.dart';
import 'http_ai_client.dart';

class AnthropicClient extends HttpAIClient {
  AnthropicClient(super.dio);

  static const _base = 'https://api.anthropic.com/v1';

  @override
  AIProviderId get id => AIProviderId.anthropic;

  Map<String, String> _headers(String apiKey) => {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      };

  @override
  VendorCall buildChat(AIRequest request) {
    var system = request.system;
    if (request.format == AIResponseFormat.json) {
      // No JSON mode in the Messages API: ask for it in the instructions.
      system = [system, 'Reply with one JSON value only, no prose.']
          .whereType<String>()
          .join('\n\n');
    }
    return (
      url: '$_base/messages',
      headers: _headers(request.apiKey),
      body: {
        'model': request.config.defaultModel,
        'max_tokens': request.maxOutputTokens,
        'stream': true,
        if (system != null) 'system': system,
        'messages': chatTurns(request.history, request.prompt),
      },
    );
  }

  // Events (each data line carries its own "type"): message_start (input
  // tokens), content_block_delta (text), message_delta (stop reason,
  // output tokens), message_stop, ping, and error.
  @override
  String? readChunk(Map<String, Object?> chunk, StreamState state) {
    switch (jsonString(chunk['type'])) {
      case 'message_start':
        state.inputTokens = jsonInt(
            jsonMap(jsonMap(chunk['message'])?['usage'])?['input_tokens']);
      case 'content_block_delta':
        final delta = jsonMap(chunk['delta']);
        if (delta?['type'] == 'text_delta') return jsonString(delta?['text']);
      case 'message_delta':
        state.stopReason =
            switch (jsonString(jsonMap(chunk['delta'])?['stop_reason'])) {
          'end_turn' || 'stop_sequence' => AIStopReason.complete,
          'max_tokens' => AIStopReason.maxTokens,
          _ => AIStopReason.other,
        };
        state.outputTokens = jsonInt(jsonMap(chunk['usage'])?['output_tokens']);
      case 'error':
        state.failure = switch (jsonString(jsonMap(chunk['error'])?['type'])) {
          'overloaded_error' =>
            const AIFailure(AIFailureKind.serverError, status: 529),
          'rate_limit_error' => const AIFailure(AIFailureKind.rateLimited),
          'authentication_error' => const AIFailure(AIFailureKind.invalidKey),
          _ => const AIFailure(AIFailureKind.unknown),
        };
    }
    return null;
  }

  @override
  VendorCall buildModels(AIProviderConfig config, String apiKey) =>
      (url: '$_base/models', headers: _headers(apiKey), body: null);

  @override
  List<AIModelInfo> readModels(Map<String, Object?>? body) => [
        for (final m in jsonList(body?['data']).map(jsonMap))
          if (jsonString(m?['id']) case final id?)
            AIModelInfo(id, displayName: jsonString(m?['display_name'])),
      ];
}
