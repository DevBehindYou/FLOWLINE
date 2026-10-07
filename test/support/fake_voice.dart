import 'dart:async';

import 'package:atomic_assist/domain/assistant/speech.dart';

/// A recogniser that plays back a script per listening session (docs/05
/// §22.7): partials, then a final, silence or a failure.
final class FakeSpeechEngine implements SpeechEngine {
  FakeSpeechEngine(this.sessions, {this.permitted = true, this.ready = true});

  /// One script per `listen()` call, in order.
  final List<List<SpeechEvent>> sessions;
  bool permitted;
  bool ready;
  int listens = 0;
  int stops = 0;

  @override
  SpeechEngineId get id => SpeechEngineId.platform;

  @override
  Future<bool> ensurePermission() async => permitted;

  @override
  Future<bool> isReady(String languageTag) async => ready;

  @override
  Stream<SpeechEvent> listen({required String languageTag}) {
    final script =
        listens < sessions.length ? sessions[listens] : const <SpeechEvent>[];
    listens++;
    return Stream.fromIterable(script);
  }

  @override
  Future<void> stop() async => stops++;
}

final class FakeTts implements TextToSpeech {
  final spoken = <String>[];
  int stops = 0;

  @override
  Future<void> speak(String text, {required String languageTag}) async =>
      spoken.add(text);

  @override
  Future<void> stop() async => stops++;
}
