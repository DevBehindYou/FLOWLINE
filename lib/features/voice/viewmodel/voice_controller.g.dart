// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(speechEngine)
final speechEngineProvider = SpeechEngineProvider._();

final class SpeechEngineProvider
    extends $FunctionalProvider<SpeechEngine, SpeechEngine, SpeechEngine>
    with $Provider<SpeechEngine> {
  SpeechEngineProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'speechEngineProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$speechEngineHash();

  @$internal
  @override
  $ProviderElement<SpeechEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SpeechEngine create(Ref ref) {
    return speechEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpeechEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpeechEngine>(value),
    );
  }
}

String _$speechEngineHash() => r'4dce0127604246c270e46975aa38cf04b239ae5e';

@ProviderFor(textToSpeech)
final textToSpeechProvider = TextToSpeechProvider._();

final class TextToSpeechProvider
    extends $FunctionalProvider<TextToSpeech, TextToSpeech, TextToSpeech>
    with $Provider<TextToSpeech> {
  TextToSpeechProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'textToSpeechProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$textToSpeechHash();

  @$internal
  @override
  $ProviderElement<TextToSpeech> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TextToSpeech create(Ref ref) {
    return textToSpeech(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TextToSpeech value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TextToSpeech>(value),
    );
  }
}

String _$textToSpeechHash() => r'27d5f6977d7485c0da39d88abbcf90c4d6232392';

/// Runs what was heard as one assistant turn: through the chat when a
/// provider is active, the local grammar otherwise. Overridden in tests.

@ProviderFor(voiceTurnRunner)
final voiceTurnRunnerProvider = VoiceTurnRunnerProvider._();

/// Runs what was heard as one assistant turn: through the chat when a
/// provider is active, the local grammar otherwise. Overridden in tests.

final class VoiceTurnRunnerProvider extends $FunctionalProvider<
        Future<TurnResult> Function(String text),
        Future<TurnResult> Function(String text),
        Future<TurnResult> Function(String text)>
    with $Provider<Future<TurnResult> Function(String text)> {
  /// Runs what was heard as one assistant turn: through the chat when a
  /// provider is active, the local grammar otherwise. Overridden in tests.
  VoiceTurnRunnerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'voiceTurnRunnerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$voiceTurnRunnerHash();

  @$internal
  @override
  $ProviderElement<Future<TurnResult> Function(String text)> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Future<TurnResult> Function(String text) create(Ref ref) {
    return voiceTurnRunner(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Future<TurnResult> Function(String text) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Future<TurnResult> Function(String text)>(value),
    );
  }
}

String _$voiceTurnRunnerHash() => r'84bb5d5f9b148043c2280fbfef72654b0077cf72';

/// The voice loop (docs/05 §22.7): owns the engine session, applies
/// [reduce], hands what was heard to the assistant and speaks the reply.
/// The UI only watches this state.
// keepAlive (R11): it uses `ref` after awaits, and a session outlives the
// panel that started it.

@ProviderFor(VoiceController)
final voiceControllerProvider = VoiceControllerProvider._();

/// The voice loop (docs/05 §22.7): owns the engine session, applies
/// [reduce], hands what was heard to the assistant and speaks the reply.
/// The UI only watches this state.
// keepAlive (R11): it uses `ref` after awaits, and a session outlives the
// panel that started it.
final class VoiceControllerProvider
    extends $NotifierProvider<VoiceController, VoiceState> {
  /// The voice loop (docs/05 §22.7): owns the engine session, applies
  /// [reduce], hands what was heard to the assistant and speaks the reply.
  /// The UI only watches this state.
// keepAlive (R11): it uses `ref` after awaits, and a session outlives the
// panel that started it.
  VoiceControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'voiceControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$voiceControllerHash();

  @$internal
  @override
  VoiceController create() => VoiceController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoiceState>(value),
    );
  }
}

String _$voiceControllerHash() => r'28739505a5171918008f699433698a448c69dce6';

/// The voice loop (docs/05 §22.7): owns the engine session, applies
/// [reduce], hands what was heard to the assistant and speaks the reply.
/// The UI only watches this state.
// keepAlive (R11): it uses `ref` after awaits, and a session outlives the
// panel that started it.

abstract class _$VoiceController extends $Notifier<VoiceState> {
  VoiceState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<VoiceState, VoiceState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<VoiceState, VoiceState>, VoiceState, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
