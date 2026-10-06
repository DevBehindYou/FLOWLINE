// Field validation for the AI provider form (B17). Pure functions, so the
// rules are unit-tested and the sheet only maps the result onto a field.
// Each returns what is wrong, or null when the value is valid; the sheet
// turns that into localized text (domain/ has no access to l10n).

/// Append-only, like every enum that might be persisted or logged (R1).
enum AiFieldError {
  modelEmpty,
  modelHasSpaces,
  urlNeedsScheme,
  urlNeedsHost,
  urlHasPath,
  keyEmpty,
  keyHasSpaces,
}

AiFieldError? validateModelName(String value) {
  final model = value.trim();
  if (model.isEmpty) return AiFieldError.modelEmpty;
  if (model.contains(RegExp(r'\s'))) return AiFieldError.modelHasSpaces;
  return null;
}

/// An Ollama server address: http(s), a host, optionally a port. Paths and
/// query strings are rejected because the client appends `/api/chat`.
AiFieldError? validateOllamaBaseUrl(String value) {
  final text = value.trim();
  if (text.isEmpty) return null; // empty means the default localhost URL
  final uri = Uri.tryParse(text);
  if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
    return AiFieldError.urlNeedsScheme;
  }
  if (uri.host.isEmpty) return AiFieldError.urlNeedsHost;
  if ((uri.path.isNotEmpty && uri.path != '/') ||
      uri.hasQuery ||
      uri.hasFragment) {
    return AiFieldError.urlHasPath;
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
AiFieldError? validateApiKey(String value, {required bool hasSavedKey}) {
  final key = value.trim();
  if (key.isEmpty) return hasSavedKey ? null : AiFieldError.keyEmpty;
  if (key.contains(RegExp(r'\s'))) {
    return AiFieldError.keyHasSpaces;
  }
  return null;
}
