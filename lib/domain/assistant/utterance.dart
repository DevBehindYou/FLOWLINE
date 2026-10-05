// Utterances (docs/05 §11): one input, whatever its surface. Typed text,
// speech, a share and a notification reply all become one of these and
// take the same path through the orchestrator. Pure Dart; the enum is
// stored by index, append-only (R1).

enum UtteranceSource { typed, voice, share, notificationReply }

final class Utterance {
  const Utterance(
    this.text, {
    required this.source,
    this.language,
    this.confidence,
  });

  final String text;
  final UtteranceSource source;

  /// BCP 47, e.g. `en-IN`; null when unknown.
  final String? language;

  /// Speech recognizer confidence in [0, 1]; null for anything else.
  final double? confidence;
}
