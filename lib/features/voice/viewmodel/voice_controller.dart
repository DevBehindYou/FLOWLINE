import 'dart:async';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../assistant/orchestrator.dart';
import '../../../core/providers.dart';
import '../../../domain/entities/app_settings.dart';
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

/// Set when the app was opened to listen (the Quick Settings tile or the
/// launcher shortcut, through `atomicassist://app/assistant?listen=1`);
/// the Assist screen takes it and opens the listening panel once.
@Riverpod(keepAlive: true)
class PendingListen extends _$PendingListen {
  @override
  bool build() => false;

  void request() => state = true;

  /// Whether listening was asked for; clears the request.
  bool take() {
    final asked = state;
    state = false;
    return asked;
  }
}

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

  AppSettings _settings = const AppSettings();

  /// The mic button: listen (or, while AA speaks, stop it and listen).
  /// Without a [mode], Settings → Voice decides (keep listening or not).
  Future<void> start([VoiceMode? mode]) async {
    if (state is VoiceThinking || state is VoiceListening) return;
    _settings = await ref.read(appSettingsRepositoryProvider).get();
    final chosen = mode ??
        (_settings.keepListening
            ? VoiceMode.conversation
            : VoiceMode.pushToTalk);
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
    _apply(VoiceStart(chosen));
  }

  /// A typed reply, read aloud when Settings → Voice says ALWAYS.
  Future<void> sayTyped(TurnResult result) async {
    final settings = await ref.read(appSettingsRepositoryProvider).get();
    if (settings.speakReplies != SpeakReplies.always) return;
    await ref.read(textToSpeechProvider).speak(
        spokenReply(deviceLocalizations(), result),
        languageTag: voiceLanguageTag,
        rate: settings.speechRatePercent / 100);
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
        _cue(listening: true);
        _listen();
      case VoiceThinking(:final text):
        _cue(listening: false);
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

  /// A haptic tick and a short click mark the start and end of listening
  /// (docs/05 §22.4), so it's clear without looking. Never fatal.
  void _cue({required bool listening}) {
    Future<void> safely(Future<void> Function() cue) async {
      try {
        await cue();
      } on Object {
        // No platform (a unit test) or no vibrator: carry on.
      }
    }

    unawaited(safely(listening
        ? HapticFeedback.mediumImpact
        : HapticFeedback.selectionClick));
    unawaited(safely(() => SystemSound.play(SystemSoundType.click)));
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
    // The user spoke, so "when I spoke" and "always" both read it out.
    _apply(
        VoiceReply(reply, speak: _settings.speakReplies != SpeakReplies.off));
  }

  Future<void> _speak(String reply) async {
    try {
      await ref.read(textToSpeechProvider).speak(reply,
          languageTag: voiceLanguageTag,
          rate: _settings.speechRatePercent / 100);
    } on Object {
      // A missing voice leaves the caption; the loop goes on.
    }
    _apply(const VoiceSpeechDone());
  }
}
