import 'package:atomic_assist/domain/services/ai_settings_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateModelName', () {
    test('accepts a model id', () {
      expect(validateModelName('llama3.2'), isNull);
      expect(validateModelName('  gpt-4o-mini  '), isNull);
    });
    test('rejects empty and spaced names', () {
      expect(validateModelName(''), isNotNull);
      expect(validateModelName('   '), isNotNull);
      expect(validateModelName('llama 3'), isNotNull);
    });
  });

  group('validateOllamaBaseUrl', () {
    for (final ok in [
      '',
      'http://localhost:11434',
      'http://192.168.1.20:11434',
      'http://192.168.1.20:11434/',
      'https://ollama.example.com',
    ]) {
      test('accepts "$ok"', () => expect(validateOllamaBaseUrl(ok), isNull));
    }
    for (final bad in [
      '192.168.1.20:11434',
      'localhost',
      'ftp://host',
      'http://',
      'http://host:11434/api/chat',
      'http://host:11434?x=1',
    ]) {
      test('rejects "$bad"',
          () => expect(validateOllamaBaseUrl(bad), isNotNull));
    }
  });

  test('normalizeOllamaBaseUrl trims and drops a trailing slash', () {
    expect(normalizeOllamaBaseUrl(' http://h:11434/ '), 'http://h:11434');
    expect(normalizeOllamaBaseUrl(''), isNull);
  });

  group('validateApiKey', () {
    test('requires a key when none is saved', () {
      expect(validateApiKey('', hasSavedKey: false), isNotNull);
      expect(validateApiKey('', hasSavedKey: true), isNull);
    });
    test('rejects keys with spaces inside, allows surrounding whitespace', () {
      expect(validateApiKey('sk-abc def', hasSavedKey: false), isNotNull);
      expect(validateApiKey('  sk-abc  ', hasSavedKey: false), isNull);
    });
  });
}
