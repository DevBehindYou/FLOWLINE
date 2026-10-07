import 'package:atomic_assist/domain/assistant/voice_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// The voice loop's transitions (docs/05 §22.2), one row each.
void main() {
  const ptt = VoiceMode.pushToTalk;
  const conv = VoiceMode.conversation;

  String describe(VoiceState s) => switch (s) {
        VoiceIdle() => 'idle',
        VoiceListening(:final partial, :final mode) =>
          'listening(${mode.name}, "$partial")',
        VoiceReview(:final text, :final mode) =>
          'review(${mode.name}, "$text")',
        VoiceThinking(:final text, :final mode) =>
          'thinking(${mode.name}, "$text")',
        VoiceSpeaking(:final reply, :final mode, :final spoken) =>
          'speaking(${mode.name}, "$reply", spoken: $spoken)',
        VoiceError(:final kind) => 'error(${kind.name})',
      };

  final cases = <(String, VoiceState, VoiceEvent, String)>[
    // Starting
    (
      'idle + start',
      const VoiceIdle(),
      const VoiceStart(ptt),
      'listening(pushToTalk, "")'
    ),
    (
      'error + start retries',
      const VoiceError(VoiceErrorKind.noSpeech),
      const VoiceStart(ptt),
      'listening(pushToTalk, "")'
    ),
    (
      'speaking + start barges in',
      const VoiceSpeaking('ok', mode: ptt, spoken: true),
      const VoiceStart(ptt),
      'listening(pushToTalk, "")'
    ),
    (
      'thinking + start is ignored',
      const VoiceThinking('x', mode: ptt),
      const VoiceStart(ptt),
      'thinking(pushToTalk, "x")'
    ),
    (
      'listening + start is ignored',
      const VoiceListening(mode: ptt),
      const VoiceStart(conv),
      'listening(pushToTalk, "")'
    ),
    // Hearing
    (
      'partial updates the text',
      const VoiceListening(mode: ptt),
      const VoicePartial('add milk'),
      'listening(pushToTalk, "add milk")'
    ),
    (
      'a sure final acts',
      const VoiceListening(mode: ptt),
      const VoiceFinal(' add milk to shopping ', confidence: 0.9),
      'thinking(pushToTalk, "add milk to shopping")'
    ),
    (
      'an unsure final is reviewed first',
      const VoiceListening(mode: ptt),
      const VoiceFinal('add silk', confidence: 0.4),
      'review(pushToTalk, "add silk")'
    ),
    (
      'exactly the floor is sure',
      const VoiceListening(mode: ptt),
      const VoiceFinal('ok', confidence: voiceConfidenceFloor),
      'thinking(pushToTalk, "ok")'
    ),
    (
      'an empty final: nothing heard',
      const VoiceListening(mode: ptt),
      const VoiceFinal('  '),
      'error(noSpeech)'
    ),
    (
      'an empty final in conversation ends it',
      const VoiceListening(mode: conv),
      const VoiceFinal(''),
      'idle'
    ),
    (
      'silence with nothing heard',
      const VoiceListening(mode: ptt),
      const VoiceSilence(),
      'error(noSpeech)'
    ),
    (
      'silence ends a conversation',
      const VoiceListening(mode: conv),
      const VoiceSilence(),
      'idle'
    ),
    (
      'silence after a partial: review it',
      const VoiceListening(partial: 'call mum', mode: ptt),
      const VoiceSilence(),
      'review(pushToTalk, "call mum")'
    ),
    // Review
    (
      'review + submit acts on the edit',
      const VoiceReview('add silk', mode: ptt),
      const VoiceSubmit('add milk'),
      'thinking(pushToTalk, "add milk")'
    ),
    (
      'review + empty submit gives up',
      const VoiceReview('x', mode: ptt),
      const VoiceSubmit(' '),
      'idle'
    ),
    (
      'review ignores engine events',
      const VoiceReview('x', mode: ptt),
      const VoicePartial('y'),
      'review(pushToTalk, "x")'
    ),
    // Replying
    (
      'thinking + reply speaks',
      const VoiceThinking('x', mode: ptt),
      const VoiceReply('Added', speak: true),
      'speaking(pushToTalk, "Added", spoken: true)'
    ),
    (
      'a silent reply is still shown',
      const VoiceThinking('x', mode: ptt),
      const VoiceReply('Added', speak: false),
      'speaking(pushToTalk, "Added", spoken: false)'
    ),
    (
      'conversation: a silent reply listens again',
      const VoiceThinking('x', mode: conv),
      const VoiceReply('Added', speak: false),
      'listening(conversation, "")'
    ),
    (
      'push-to-talk keeps the caption after speaking',
      const VoiceSpeaking('Added', mode: ptt, spoken: true),
      const VoiceSpeechDone(),
      'speaking(pushToTalk, "Added", spoken: true)'
    ),
    (
      'conversation listens again after speaking',
      const VoiceSpeaking('Added', mode: conv, spoken: true),
      const VoiceSpeechDone(),
      'listening(conversation, "")'
    ),
    (
      'a reply while listening is ignored',
      const VoiceListening(mode: ptt),
      const VoiceReply('late', speak: true),
      'listening(pushToTalk, "")'
    ),
    // Stopping and failing
    (
      'stop from anywhere',
      const VoiceThinking('x', mode: ptt),
      const VoiceStop(),
      'idle'
    ),
    (
      'stop while listening',
      const VoiceListening(mode: conv),
      const VoiceStop(),
      'idle'
    ),
    (
      'failure while listening',
      const VoiceListening(mode: ptt),
      const VoiceFailed(VoiceErrorKind.network),
      'error(network)'
    ),
    (
      'failure while thinking',
      const VoiceThinking('x', mode: ptt),
      const VoiceFailed(VoiceErrorKind.busy),
      'error(busy)'
    ),
    (
      'a late failure after stop changes nothing',
      const VoiceIdle(),
      const VoiceFailed(VoiceErrorKind.network),
      'idle'
    ),
    (
      'idle ignores a stray final',
      const VoiceIdle(),
      const VoiceFinal('x'),
      'idle'
    ),
  ];

  for (final (name, from, event, expected) in cases) {
    test(name, () => expect(describe(reduce(from, event)), expected));
  }

  test('stored enums keep their order (R1: append-only)', () {
    expect(VoiceErrorKind.values.map((e) => e.name), [
      'noPermission',
      'noEngine',
      'noSpeech',
      'network',
      'busy',
      'modelMissing',
    ]);
    expect(VoiceMode.values.map((e) => e.name), ['pushToTalk', 'conversation']);
  });
}
