import '../data/remote/ai_clients/ollama_client.dart';
import '../domain/ai/ai_contract.dart';
import '../domain/entities/ai_provider_config.dart';
import 'app_localizations.dart';

/// Words an [AIFailure] for the user, naming the vendor it came from.
/// Raw exception text never reaches the screen (K9).
extension L10nAiFailure on AppLocalizations {
  String aiFailure(AIFailure failure, AIProviderConfig? provider) {
    final vendor = provider?.displayName ?? aiProviderGeneric;
    return switch (failure.kind) {
      AIFailureKind.invalidKey => aiErrorInvalidKey(vendor),
      AIFailureKind.rateLimited => aiErrorRateLimited(vendor),
      AIFailureKind.serverError when failure.status != null =>
        aiErrorServer(vendor, failure.status!),
      AIFailureKind.unreachable when provider?.id == AIProviderId.ollama =>
        aiErrorOllamaUnreachable(OllamaClient.baseUrlOf(provider!)),
      AIFailureKind.unreachable => aiErrorUnreachable(vendor),
      AIFailureKind.emptyResponse => aiErrorEmpty(vendor),
      AIFailureKind.modelNotFound =>
        aiErrorModelNotFound(provider?.defaultModel ?? ''),
      AIFailureKind.missingKey => aiErrorMissingKey(vendor),
      AIFailureKind.noActiveProvider => aiErrorNoProvider,
      AIFailureKind.cancelled => aiStopped,
      AIFailureKind.interrupted => aiErrorInterrupted,
      AIFailureKind.serverError ||
      AIFailureKind.unknown =>
        aiErrorUnknown(vendor),
    };
  }
}
