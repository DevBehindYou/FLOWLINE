import '../ai/ai_contract.dart';
import '../entities/ai_conversation.dart';
import '../entities/ai_message.dart';
import '../entities/ai_provider_config.dart';

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

  /// "Test connection": the models [id] offers, using [apiKey] if given
  /// (typed but not saved yet), else the saved key, and [baseUrl] for
  /// Ollama. Throws [AIFailureException] with what went wrong.
  Future<List<AIModelInfo>> listModels({
    required AIProviderId id,
    String? apiKey,
    String? baseUrl,
  });

  Stream<List<AIConversation>> watchConversations();
  Stream<List<AIMessage>> watchMessages(int conversationId);
  Future<int> createConversation(
      {required AIProviderId providerId, String? title});
  Future<void> deleteConversation(int id);

  /// Persists the user's message, calls the active client, and persists
  /// the reply (or a visible error message) — see
  /// `AIRepositoryImpl.sendMessage` for the exact sequencing.
  /// [cancel] stops the request; the reply then reads "Stopped".
  Future<void> sendMessage({
    required int conversationId,
    required String prompt,
    AICancelToken? cancel,
  });

  /// A single request/response with no conversation history and nothing
  /// persisted to Drift — for features (like schedule conflict
  /// resolution) that need a one-off AI answer without adding noise to
  /// the user's visible Assistant chat.
  Future<AICompletion> completeOnce({
    required String prompt,
    String? system,
    AIResponseFormat format = AIResponseFormat.text,
  });

  /// One round of a request with tools, against the active provider, with
  /// nothing persisted (the orchestrator keeps its own ledger). When the
  /// model or server refuses tools, it retries once asking for a JSON plan
  /// and returns the plan's actions as calls (docs/05 §8.2).
  Future<AIToolTurnResult> completeWithTools({
    required String prompt,
    required List<AIToolSpec> tools,
    String? system,
    List<AITurn> continuation = const [],
    AIToolChoice toolChoice = AIToolChoice.auto,
    AICancelToken? cancel,
  });
}
