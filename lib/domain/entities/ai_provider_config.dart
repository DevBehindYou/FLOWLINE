enum AIProviderId { anthropic, openai, gemini, ollama }

/// Metadata only — never the API key itself. The key lives exclusively
/// in `SecureKeyStore` (Android Keystore-backed), keyed by [id].
class AIProviderConfig {
  const AIProviderConfig({
    required this.id,
    required this.displayName,
    required this.defaultModel,
    this.baseUrl,
    required this.isActive,
  });

  final AIProviderId id;
  final String displayName;
  final String defaultModel;

  /// Only meaningful for [AIProviderId.ollama] — the local/LAN server
  /// address. Null for the hosted vendors.
  final String? baseUrl;

  final bool isActive;

  /// Ollama runs unauthenticated on a local network; the other three
  /// need a bring-your-own API key.
  bool get requiresApiKey => id != AIProviderId.ollama;
}
