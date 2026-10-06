import 'package:atomic_assist/domain/entities/ai_message.dart';
import 'package:atomic_assist/domain/services/chat_history.dart';
import 'package:flutter_test/flutter_test.dart';

var _id = 0;
AIMessage _user(String text) => AIMessage(
    id: ++_id,
    conversationId: 1,
    role: AIMessageRole.user,
    content: text,
    sentAt: DateTime(2026));
AIMessage _reply(String text, {bool error = false, bool pending = false}) =>
    AIMessage(
        id: ++_id,
        conversationId: 1,
        role: AIMessageRole.assistant,
        content: text,
        isError: error,
        isPending: pending,
        sentAt: DateTime(2026));

void main() {
  List<String> texts(List<AIMessage> m) => m.map((e) => e.content).toList();

  test('keeps completed exchanges in order', () {
    expect(
      texts(
          buildChatHistory([_user('a'), _reply('A'), _user('b'), _reply('B')])),
      ['a', 'A', 'b', 'B'],
    );
  });

  test('drops an assistant turn with no text (vendors reject empty turns)', () {
    expect(
      texts(buildChatHistory(
          [_user('add a task milk'), _reply(''), _user('b'), _reply('B')])),
      ['b', 'B'],
    );
  });

  test('drops an error reply together with its prompt (B31)', () {
    final history = buildChatHistory([
      _user('a'),
      _reply('That API key was rejected by Anthropic.', error: true),
      _user('a again'),
      _reply('A'),
    ]);
    expect(texts(history), ['a again', 'A']);
  });

  test('never includes a pending reply or a trailing unanswered prompt', () {
    expect(
      texts(buildChatHistory(
          [_user('a'), _reply('A'), _user('b'), _reply('', pending: true)])),
      ['a', 'A'],
    );
    expect(texts(buildChatHistory([_user('a'), _reply('A'), _user('b')])),
        ['a', 'A']);
  });

  test('always alternates user, assistant (Anthropic requires it)', () {
    final history = buildChatHistory([
      _user('a'),
      _user('b'),
      _reply('B'),
      _reply('stray'),
      _user('c'),
      _reply('C', error: true),
    ]);
    for (var i = 0; i < history.length; i++) {
      expect(history[i].role,
          i.isEven ? AIMessageRole.user : AIMessageRole.assistant);
    }
    expect(texts(history), ['b', 'B']);
  });

  test(
      'empty in, empty out', () => expect(buildChatHistory(const []), isEmpty));

  group('windowHistory (K10)', () {
    List<AIMessage> exchanges(int n, {int size = 10}) => [
          for (var i = 0; i < n; i++) ...[
            _user('q$i'.padRight(size, '.')),
            _reply('a$i'.padRight(size, '.')),
          ],
        ];

    test('keeps everything that fits', () {
      final all = exchanges(3);
      expect(windowHistory(all), all);
    });

    test('keeps only the most recent exchanges, whole and in order', () {
      final window = windowHistory(exchanges(15), maxMessages: 4);
      expect(texts(window).map((t) => t.substring(0, 3)),
          ['q13', 'a13', 'q14', 'a14']);
    });

    test('stops at the character budget', () {
      // Each exchange is 2 x 10 characters.
      final window = windowHistory(exchanges(5), maxChars: 45);
      expect(window, hasLength(4), reason: 'two exchanges fit, three do not');
    });

    test('one exchange larger than the budget sends no history', () {
      expect(windowHistory(exchanges(1, size: 100), maxChars: 50), isEmpty);
    });

    test('the default window is ten exchanges', () {
      expect(windowHistory(exchanges(30)), hasLength(defaultHistoryMessages));
    });
  });
}
