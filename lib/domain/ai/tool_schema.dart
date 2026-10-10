// The JSON Schema subset every vendor accepts for tool parameters
// (docs/05 §8.2): Gemini takes an OpenAPI subset, small local models do
// best with simple schemas. One tool definition must work everywhere,
// so the registry checks each schema against this list.

const supportedSchemaKeywords = {
  'type',
  'properties',
  'required',
  'enum',
  'items',
  'description',
  'minimum',
  'maximum',
  'maxLength',
  'minLength',
  'minItems',
  'maxItems',
  'format',
};

/// Keywords in [schema] (at any depth) outside the supported subset, as
/// JSON paths. Empty when the schema is portable. Property names under
/// `properties` are names, not keywords, and are not checked.
List<String> unsupportedSchemaKeywords(Map<String, Object?> schema,
    [String path = r'$']) {
  final problems = <String>[];
  for (final MapEntry(:key, :value) in schema.entries) {
    final at = '$path.$key';
    if (!supportedSchemaKeywords.contains(key)) {
      problems.add(at);
      continue;
    }
    if (key == 'properties' && value is Map) {
      for (final MapEntry(key: name, value: sub) in value.entries) {
        if (sub is Map) {
          problems.addAll(unsupportedSchemaKeywords(
              sub.cast<String, Object?>(), '$at.$name'));
        } else {
          problems.add('$at.$name');
        }
      }
    } else if (key == 'items' && value is Map) {
      problems
          .addAll(unsupportedSchemaKeywords(value.cast<String, Object?>(), at));
    }
  }
  return problems;
}

/// Tool names vendors accept and the ledger can store.
final toolNamePattern = RegExp(r'^[a-z][a-z0-9_]{0,63}$');
