import '../ai/ai_contract.dart';
import '../entities/ai_provider_config.dart';

/// The Strategy interface for talking to one AI vendor (v2, docs/04 §4.1).
/// One implementation per vendor lives in `data/remote/ai_clients/`, all
/// called identically. Adding a fifth vendor means one new class; nothing
/// in the features or AIRepository changes.
abstract interface class AIClient {
  AIProviderId get id;

  /// Text as it arrives, then exactly one AIDone or AIFailure. Never
  /// throws: every failure is an [AIFailure] event, and cancelling via
  /// [cancel] ends with `AIDone(stopReason: cancelled)`.
  Stream<AIEvent> send(AIRequest request, {AICancelToken? cancel});

  /// The models this key can use, by id. Throws [AIFailureException] on
  /// failure (shown next to the settings screen's Test connection).
  Future<List<AIModelInfo>> listModels(AIProviderConfig config, String apiKey);
}
