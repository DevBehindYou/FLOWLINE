import 'dart:async';

import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../domain/assistant/speech.dart';
import '../../domain/assistant/voice_state.dart';

/// Android's own recogniser through `speech_to_text` (docs/05 §22.3): the
/// default for push-to-talk. It may send audio to the recogniser's
/// service; Settings says so. **UNVERIFIED** on a device.
final class PlatformSpeechEngine implements SpeechEngine {
  PlatformSpeechEngine([SpeechToText? stt]) : _stt = stt ?? SpeechToText();

  final SpeechToText _stt;
  // Closed by _close(), when the session ends or stop() is called.
  // ignore: close_sinks
  StreamController<SpeechEvent>? _session;
  Future<bool>? _init;

  @override
  SpeechEngineId get id => SpeechEngineId.platform;

  // initialize() asks for the microphone on Android, once per process.
  Future<bool> _initialize() =>
      _init ??= _stt.initialize(onError: _onError, onStatus: _onStatus);

  @override
  Future<bool> ensurePermission() async =>
      await _initialize() && await _stt.hasPermission;

  @override
  Future<bool> isReady(String languageTag) async =>
      await _initialize() && _stt.isAvailable;

  @override
  Stream<SpeechEvent> listen({required String languageTag}) {
    _close();
    final session = _session = StreamController<SpeechEvent>();
    unawaited(_start(session, languageTag));
    return session.stream;
  }

  Future<void> _start(
      StreamController<SpeechEvent> session, String languageTag) async {
    try {
      if (!await _initialize()) {
        _emit(const SpeechFailure(VoiceErrorKind.noEngine), end: true);
        return;
      }
      await _stt.listen(
        onResult: _onResult,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
          localeId: languageTag.replaceAll('-', '_'),
          pauseFor: const Duration(seconds: 3),
          listenFor: const Duration(seconds: 30),
        ),
      );
    } on Object {
      _emit(const SpeechFailure(VoiceErrorKind.noEngine), end: true);
    }
  }

  void _onResult(SpeechRecognitionResult r) {
    if (r.finalResult) {
      // Android reports 0 (or nothing) when it has no rating.
      final c = r.hasConfidenceRating && r.confidence > 0 ? r.confidence : 1.0;
      _emit(SpeechFinal(r.recognizedWords, confidence: c), end: true);
    } else {
      _emit(SpeechPartial(r.recognizedWords));
    }
  }

  void _onStatus(String status) {
    // "done" without a final result: the speaker never said anything.
    if (status == SpeechToText.doneStatus) {
      _emit(const SpeechSilence(), end: true);
    }
  }

  void _onError(SpeechRecognitionError e) {
    _emit(SpeechFailure(speechErrorKind(e.errorMsg)), end: true);
  }

  void _emit(SpeechEvent event, {bool end = false}) {
    final s = _session;
    if (s == null || s.isClosed) return;
    s.add(event);
    if (end) _close();
  }

  void _close() {
    final s = _session;
    _session = null;
    if (s != null && !s.isClosed) unawaited(s.close());
  }

  @override
  Future<void> stop() async {
    _close();
    await _stt.stop();
  }
}

/// Android's `SpeechRecognizer` error names, as the plugin reports them.
VoiceErrorKind speechErrorKind(String errorMsg) => switch (errorMsg) {
      'error_no_match' || 'error_speech_timeout' => VoiceErrorKind.noSpeech,
      'error_network' ||
      'error_network_timeout' ||
      'error_server' ||
      'error_server_disconnected' =>
        VoiceErrorKind.network,
      'error_insufficient_permissions' ||
      'error_permission' =>
        VoiceErrorKind.noPermission,
      'error_busy' || 'error_recognizer_busy' => VoiceErrorKind.busy,
      'error_language_not_supported' ||
      'error_language_unavailable' =>
        VoiceErrorKind.modelMissing,
      _ => VoiceErrorKind.noEngine,
    };
