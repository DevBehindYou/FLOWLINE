import 'package:flutter_tts/flutter_tts.dart';

import '../../domain/assistant/speech.dart';

/// The phone's own voices through `flutter_tts` (docs/05 §22.4), on
/// device. **UNVERIFIED** on a device.
final class PlatformTts implements TextToSpeech {
  PlatformTts([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool _configured = false;

  @override
  Future<void> speak(String text, {required String languageTag}) async {
    if (!_configured) {
      // speak() then completes when the utterance ends, not when it starts.
      await _tts.awaitSpeakCompletion(true);
      _configured = true;
    }
    await _tts.setLanguage(languageTag);
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }
}
