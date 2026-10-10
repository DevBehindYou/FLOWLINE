// The voice loop as a pure state machine (docs/05 §22.2): the controller
// feeds it engine and assistant events, the listening panel draws its
// state. Pure Dart, so every transition is table-tested.

/// How listening started. Stored nowhere, but kept append-only (R1) like
/// every enum that may be.
enum VoiceMode {
  /// One command: listen until the speaker stops.
  pushToTalk,

  /// Listen again after each reply, until silence or a tap.
  conversation,
}

/// Why the loop stopped with an error (append-only, R1).
enum VoiceErrorKind {
  noPermission,
  noEngine,
  noSpeech,
  network,
  busy,
  modelMissing,
}

/// A recognised final below this goes to an edit-before-acting step.
const voiceConfidenceFloor = 0.6;

sealed class VoiceState {
  const VoiceState();
}

final class VoiceIdle extends VoiceState {
  const VoiceIdle();
}

final class VoiceListening extends VoiceState {
  const VoiceListening({this.partial = '', required this.mode});
  final String partial;
  final VoiceMode mode;
}

/// Heard, but not sure: the transcript is shown to edit before AA acts.
final class VoiceReview extends VoiceState {
  const VoiceReview(this.text, {required this.mode});
  final String text;
  final VoiceMode mode;
}

final class VoiceThinking extends VoiceState {
  const VoiceThinking(this.text, {required this.mode});
  final String text;
  final VoiceMode mode;
}

/// AA's reply, shown as text and, if [spoken], read aloud.
final class VoiceSpeaking extends VoiceState {
  const VoiceSpeaking(this.reply, {required this.mode, required this.spoken});
  final String reply;
  final VoiceMode mode;
  final bool spoken;
}

final class VoiceError extends VoiceState {
  const VoiceError(this.kind);
  final VoiceErrorKind kind;
}

sealed class VoiceEvent {
  const VoiceEvent();
}

final class VoiceStart extends VoiceEvent {
  const VoiceStart(this.mode);
  final VoiceMode mode;
}

final class VoicePartial extends VoiceEvent {
  const VoicePartial(this.text);
  final String text;
}

final class VoiceFinal extends VoiceEvent {
  const VoiceFinal(this.text, {this.confidence = 1});
  final String text;

  /// 0..1; engines that don't report one say 1.
  final double confidence;
}

/// The engine heard nothing more for a while.
final class VoiceSilence extends VoiceEvent {
  const VoiceSilence();
}

/// The (possibly edited) transcript from the review step.
final class VoiceSubmit extends VoiceEvent {
  const VoiceSubmit(this.text);
  final String text;
}

final class VoiceReply extends VoiceEvent {
  const VoiceReply(this.text, {required this.speak});
  final String text;
  final bool speak;
}

final class VoiceSpeechDone extends VoiceEvent {
  const VoiceSpeechDone();
}

final class VoiceStop extends VoiceEvent {
  const VoiceStop();
}

final class VoiceFailed extends VoiceEvent {
  const VoiceFailed(this.kind);
  final VoiceErrorKind kind;
}

/// The next state. Events that don't apply leave the state as it is.
VoiceState reduce(VoiceState state, VoiceEvent event) {
  switch (event) {
    case VoiceStop():
      return const VoiceIdle();
    case VoiceFailed(:final kind):
      return state is VoiceIdle ? state : VoiceError(kind);
    case VoiceStart(:final mode):
      // Barge-in: a tap while AA speaks stops it and listens.
      return switch (state) {
        VoiceIdle() ||
        VoiceError() ||
        VoiceSpeaking() =>
          VoiceListening(mode: mode),
        _ => state,
      };
    default:
  }

  switch (state) {
    case VoiceListening(:final mode, :final partial):
      return switch (event) {
        VoicePartial(:final text) => VoiceListening(partial: text, mode: mode),
        VoiceFinal(:final text, :final confidence) =>
          _heard(text, mode, sure: confidence >= voiceConfidenceFloor),
        // What was heard so far counts, but it was never confirmed final.
        VoiceSilence() => partial.trim().isNotEmpty
            ? VoiceReview(partial.trim(), mode: mode)
            : mode == VoiceMode.conversation
                ? const VoiceIdle()
                : const VoiceError(VoiceErrorKind.noSpeech),
        _ => state,
      };
    case VoiceReview(:final mode):
      return switch (event) {
        VoiceSubmit(:final text) => text.trim().isEmpty
            ? const VoiceIdle()
            : VoiceThinking(text.trim(), mode: mode),
        _ => state,
      };
    case VoiceThinking(:final mode):
      return switch (event) {
        VoiceReply(:final text, :final speak) =>
          // Nothing to say aloud: conversation listens again at once.
          !speak && mode == VoiceMode.conversation
              ? VoiceListening(mode: mode)
              : VoiceSpeaking(text, mode: mode, spoken: speak),
        _ => state,
      };
    case VoiceSpeaking(:final mode):
      return switch (event) {
        VoiceSpeechDone() =>
          mode == VoiceMode.conversation ? VoiceListening(mode: mode) : state,
        _ => state,
      };
    case VoiceIdle() || VoiceError():
      return state;
  }
}

VoiceState _heard(String text, VoiceMode mode, {required bool sure}) {
  final t = text.trim();
  if (t.isEmpty) {
    return mode == VoiceMode.conversation
        ? const VoiceIdle()
        : const VoiceError(VoiceErrorKind.noSpeech);
  }
  return sure ? VoiceThinking(t, mode: mode) : VoiceReview(t, mode: mode);
}
