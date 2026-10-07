import 'voice_state.dart';

// What the voice loop needs from a recogniser and a voice (docs/05
// §22.3–22.4). The platform implementations live in data/voice/; tests
// and the emulator use scripted fakes.

/// Append-only (R1): settings may store the chosen engine by index.
enum SpeechEngineId { platform, vosk, whisper }

sealed class SpeechEvent {
  const SpeechEvent();
}

final class SpeechPartial extends SpeechEvent {
  const SpeechPartial(this.text);
  final String text;
}

final class SpeechFinal extends SpeechEvent {
  const SpeechFinal(this.text, {this.confidence = 1});
  final String text;
  final double confidence;
}

/// The speaker stopped, with nothing final.
final class SpeechSilence extends SpeechEvent {
  const SpeechSilence();
}

final class SpeechFailure extends SpeechEvent {
  const SpeechFailure(this.kind);
  final VoiceErrorKind kind;
}

abstract interface class SpeechEngine {
  SpeechEngineId get id;

  /// Asks for the microphone if needed; false when it isn't granted.
  Future<bool> ensurePermission();

  /// Whether this engine can listen in [languageTag] (e.g. "en-IN").
  Future<bool> isReady(String languageTag);

  /// One listening session: partials, then a final, silence or a failure.
  /// The stream closes when the session ends.
  Stream<SpeechEvent> listen({required String languageTag});

  Future<void> stop();
}

abstract interface class TextToSpeech {
  /// Completes when the text has been spoken (or [stop] cut it short).
  /// [rate] is the platform's 0.2–1.0, 0.5 normal.
  Future<void> speak(String text,
      {required String languageTag, double rate = 0.5});

  Future<void> stop();
}
