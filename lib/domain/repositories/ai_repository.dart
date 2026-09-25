import '../entities/ai_conversation.dart';
import '../entities/ai_message.dart';
import '../entities/ai_provider_config.dart';
import '../entities/ai_response.dart';

abstract interface class AIRepository {
  Stream<List<AIProviderConfig>> watchProviders();
  Stream<AIProviderConfig?> watchActiveProvider();

  Future<void> saveProviderKey({
    required AIProviderId id,
    required String apiKey,
    required String model,
    String? baseUrl,
  });
  Future<void> setActiveProvider(AIProviderId id);
  Future<void> removeProviderKey(AIProviderId id);

  /// For Ollama this is always true (no key is required — only
  /// reachability matters, which isn't checked here).
  Future<bool> hasKey(AIProviderId id);

  Stream<List<AIConversation>> watchConversations();
  Stream<List<AIMessage>> watchMessages(int conversationId);
  Future<int> createConversation(
      {required AIProviderId providerId, String? title});
  Future<void> deleteConversation(int id);

  /// Persists the user's message, calls the active client, and persists
  /// the reply (or a visible error message) — see
  /// `AIRepositoryImpl.sendMessage` for the exact sequencing.
  Future<void> sendMessage(
      {required int conversationId, required String prompt});

  /// A single request/response with no conversation history and nothing
  /// persisted to Drift — for features (like schedule conflict
  /// resolution) that need a one-off AI answer without adding noise to
  /// the user's visible Assistant chat.
  Future<AIResponse> completeOnce({required String prompt});
}
