// Field validation for the AI provider form (B17). Pure functions, so the
// rules are unit-tested and the sheet only maps a message onto a field.
// Each returns a user-facing message, or null when the value is valid.

String? validateModelName(String value) {
  final model = value.trim();
  if (model.isEmpty) return 'Enter a model name';
  if (model.contains(RegExp(r'\s'))) return 'Model names have no spaces';
  return null;
}

/// An Ollama server address: http(s), a host, optionally a port. Paths and
/// query strings are rejected because the client appends `/api/chat`.
String? validateOllamaBaseUrl(String value) {
  final text = value.trim();
  if (text.isEmpty) return null; // empty means the default localhost URL
  final uri = Uri.tryParse(text);
  if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
    return 'Start with http:// or https://, e.g. http://192.168.1.20:11434';
  }
  if (uri.host.isEmpty) return 'Add the computer\'s address after http://';
  if ((uri.path.isNotEmpty && uri.path != '/') ||
      uri.hasQuery ||
      uri.hasFragment) {
    return 'Use only the server address, e.g. http://192.168.1.20:11434';
  }
  return null;
}

/// [validateOllamaBaseUrl]-valid input in the canonical form the client
/// expects: no trailing slash. Null for empty input.
String? normalizeOllamaBaseUrl(String value) {
  final text = value.trim();
  if (text.isEmpty) return null;
  return text.endsWith('/') ? text.substring(0, text.length - 1) : text;
}

/// API keys are pasted, so trim whitespace and reject anything with spaces
/// inside, which is always a copy/paste mistake. Empty means "keep the
/// saved key" on edit.
String? validateApiKey(String value, {required bool hasSavedKey}) {
  final key = value.trim();
  if (key.isEmpty) return hasSavedKey ? null : 'Paste your API key';
  if (key.contains(RegExp(r'\s'))) {
    return 'The key contains spaces — paste it again';
  }
  return null;
}
