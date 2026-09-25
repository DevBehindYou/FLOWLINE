import '../entities/ai_message.dart';
import '../entities/ai_provider_config.dart';
import '../entities/ai_response.dart';

/// The Strategy interface for talking to one AI vendor. One implementation
/// per vendor lives in `data/remote/ai_clients/`, all called identically —
/// adding a fifth vendor later means one new class here; nothing in the
/// Assistant UI or AIRepository changes.
abstract interface class AIClient {
  AIProviderId get id;

  Future<AIResponse> sendMessage({
    required AIProviderConfig config,
    required String apiKey,
    required String prompt,
    required List<AIMessage> history,
  });
}
