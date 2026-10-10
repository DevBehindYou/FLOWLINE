import 'package:atomic_assist/domain/ai/tool_schema.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a portable schema has no problems', () {
    expect(
        unsupportedSchemaKeywords({
          'type': 'object',
          'properties': {
            'title': {'type': 'string', 'maxLength': 140, 'description': 'x'},
            'priority': {
              'type': 'string',
              'enum': ['low', 'medium', 'high'],
            },
            'items': {
              'type': 'array',
              'items': {'type': 'string'},
            },
          },
          'required': ['title'],
        }),
        isEmpty);
  });

  test('flags keywords outside the subset, at their path', () {
    expect(
        unsupportedSchemaKeywords({
          'type': 'object',
          'additionalProperties': false,
          'properties': {
            'when': {r'$ref': '#/defs/date'},
            'tags': {
              'type': 'array',
              'items': {'type': 'string', 'pattern': '^x'},
            },
          },
          'oneOf': <Object?>[],
        }),
        [
          r'$.additionalProperties',
          r'$.properties.when.$ref',
          r'$.properties.tags.items.pattern',
          r'$.oneOf',
        ]);
  });

  test('a property that is not a schema is flagged', () {
    expect(
        unsupportedSchemaKeywords({
          'properties': {'x': 'string'},
        }),
        [r'$.properties.x']);
  });

  test('tool names: lower snake case, starting with a letter, max 64', () {
    for (final ok in ['create_task', 'a', 'get_agenda2']) {
      expect(toolNamePattern.hasMatch(ok), isTrue, reason: ok);
    }
    for (final bad in ['CreateTask', '1x', 'with-dash', '', 'x' * 65]) {
      expect(toolNamePattern.hasMatch(bad), isFalse, reason: bad);
    }
  });
}
