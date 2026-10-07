import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../assistant/orchestrator.dart';
import '../../../data/voice/platform_speech_engine.dart';
import '../../../data/voice/platform_tts.dart';
import '../../../domain/assistant/speech.dart';
import '../../../domain/assistant/utterance.dart';
import '../../../domain/assistant/voice_state.dart';
import '../../../l10n/l10n.dart';
import '../../ai_assistant/viewmodel/assistant_view_model.dart';

part 'voice_controller.g.dart';

/// v1 listens and speaks in Indian English; the quick parser understands
/// Hinglish keywords (docs/05 §22.6).
const voiceLanguageTag = 'en-IN';

@Riverpod(keepAlive: true)
SpeechEngine speechEngine(Ref ref) => PlatformSpeechEngine();

@Riverpod(keepAlive: true)
TextToSpeech textToSpeech(Ref ref) => PlatformTts();

/// Runs what was heard as one assistant turn: through the chat when a
/// provider is active, the local grammar otherwise. Overridden in tests.
@Riverpod(keepAlive: true)
Future<TurnResult> Function(String text) voiceTurnRunner(Ref ref) =>
    (text) async {
      final assistant = ref.read(assistantViewModelProvider.notifier);
      final provider = ref.read(activeAiProviderProvider).value;
      if (provider == null) {
        return assistant.sendLocal(text, source: UtteranceSource.voice);
      }
      final conversation =
          ref.read(latestConversationForProviderProvider(provider.id)).value;
      return assistant.send(
        providerId: provider.id,
        existingConversationId: conversation?.id,
        prompt: text,
        source: UtteranceSource.voice,
      );
    };

/// What AA says back after a spoken command (and shows as the caption).
String spokenReply(AppLocalizations l10n, TurnResult result) {
  final done = [
    for (final a in result.acted)
      if (a.status == CallStatus.done && a.preview != null)
        '${l10n.actionLabel(a.preview!)}: ${l10n.actionDetail(a.preview!)}',
  ];
  return switch (result) {
    TurnAnswered(:final text) when text.trim().isNotEmpty => text.trim(),
    TurnNeedsConfirmation() => l10n.voiceNeedsConfirm,
    TurnFailed() when done.isEmpty =>
      result.acted.isEmpty ? l10n.localNeedsProvider : l10n.voiceTurnFailed,
    _ when done.isNotEmpty => done.join('. '),
    TurnStopped() => l10n.voiceTurnFailed,
    _ => l10n.turnNothingDone,
  };
}

/// The voice loop (docs/05 §22.7): owns the engine session, applies
/// [reduce], hands what was heard to the assistant and speaks the reply.
/// The UI only watches this state.
// keepAlive (R11): it uses `ref` after awaits, and a session outlives the
// panel that started it.
@Riverpod(keepAlive: true)
class VoiceController extends _$VoiceController {
  StreamSubscription<SpeechEvent>? _session;

  @override
  VoiceState build() {
    ref.onDispose(() => _session?.cancel());
    return const VoiceIdle();
  }

  /// The mic button: listen (or, while AA speaks, stop it and listen).
  Future<void> start([VoiceMode mode = VoiceMode.pushToTalk]) async {
    if (state is VoiceThinking || state is VoiceListening) return;
    await ref.read(textToSpeechProvider).stop();
    final engine = ref.read(speechEngineProvider);
    if (!await engine.ensurePermission()) {
      state = const VoiceError(VoiceErrorKind.noPermission);
      return;
    }
    if (!await engine.isReady(voiceLanguageTag)) {
      state = const VoiceError(VoiceErrorKind.noEngine);
      return;
    }
    _apply(VoiceStart(mode));
  }

  /// The edited transcript from the review step.
  void submit(String text) => _apply(VoiceSubmit(text));

  /// STOP, or the panel closing: everything ends, nothing more is done.
  Future<void> stop() async {
    _apply(const VoiceStop());
  }

  void _apply(VoiceEvent event) {
    final before = state;
    final next = reduce(before, event);
    if (identical(next, before)) return;
    state = next;
    switch (next) {
      case VoiceListening() when before is! VoiceListening:
        _listen();
      case VoiceThinking(:final text):
        _closeSession();
        unawaited(_think(text));
      case VoiceSpeaking(:final reply, spoken: true):
        unawaited(_speak(reply));
      case VoiceIdle() || VoiceError() || VoiceReview():
        _closeSession();
        if (next is! VoiceReview) {
          unawaited(ref.read(textToSpeechProvider).stop());
        }
      default:
    }
  }

  void _listen() {
    _closeSession();
    _session = ref
        .read(speechEngineProvider)
        .listen(languageTag: voiceLanguageTag)
        .listen((e) => _apply(switch (e) {
              SpeechPartial(:final text) => VoicePartial(text),
              SpeechFinal(:final text, :final confidence) =>
                VoiceFinal(text, confidence: confidence),
              SpeechSilence() => const VoiceSilence(),
              SpeechFailure(:final kind) => VoiceFailed(kind),
            }));
  }

  void _closeSession() {
    final s = _session;
    _session = null;
    if (s == null) return;
    unawaited(s.cancel());
    unawaited(ref.read(speechEngineProvider).stop());
  }

  Future<void> _think(String text) async {
    final l10n = deviceLocalizations();
    String reply;
    try {
      reply = spokenReply(l10n, await ref.read(voiceTurnRunnerProvider)(text));
    } on Object {
      reply = l10n.voiceTurnFailed;
    }
    // Stopped while AA was working: the turn still ran, but say nothing.
    if (state is! VoiceThinking) return;
    _apply(VoiceReply(reply, speak: true));
  }

  Future<void> _speak(String reply) async {
    try {
      await ref
          .read(textToSpeechProvider)
          .speak(reply, languageTag: voiceLanguageTag);
    } on Object {
      // A missing voice leaves the caption; the loop goes on.
    }
    _apply(const VoiceSpeechDone());
  }
}
