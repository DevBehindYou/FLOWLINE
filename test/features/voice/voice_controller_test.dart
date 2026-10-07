import 'package:atomic_assist/assistant/orchestrator.dart';
import 'package:atomic_assist/core/providers.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/app_settings_repository_impl.dart';
import 'package:atomic_assist/domain/entities/app_settings.dart';
import 'package:atomic_assist/assistant/tools/tool_registry.dart';
import 'package:atomic_assist/domain/ai/ai_contract.dart';
import 'package:atomic_assist/data/voice/platform_speech_engine.dart';
import 'package:atomic_assist/domain/assistant/action_preview.dart';
import 'package:atomic_assist/domain/assistant/speech.dart';
import 'package:atomic_assist/domain/assistant/voice_state.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:atomic_assist/features/voice/viewmodel/voice_controller.dart';
import 'package:atomic_assist/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_voice.dart';
import '../../support/test_database.dart';

void main() {
  late FakeSpeechEngine engine;
  late FakeTts tts;
  late List<String> heard;
  late ProviderContainer container;
  late AppDatabase db;
  setUp(() => db = createTestDatabase());

  ProviderContainer make(List<List<SpeechEvent>> sessions,
      {TurnResult Function(String)? turn}) {
    engine = FakeSpeechEngine(sessions);
    tts = FakeTts();
    heard = [];
    return ProviderContainer(overrides: [
      appDatabaseProvider.overrideWith((ref) => db),
      speechEngineProvider.overrideWithValue(engine),
      textToSpeechProvider.overrideWithValue(tts),
      voiceTurnRunnerProvider.overrideWithValue((text) async {
        heard.add(text);
        return turn?.call(text) ?? const TurnAnswered('g', [], text: 'Done.');
      }),
    ]);
  }

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> pumpEvents() async {
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  test('a spoken command runs one turn and the reply is spoken', () async {
    container = make([
      [
        const SpeechPartial('add milk'),
        const SpeechFinal('add milk to shopping')
      ],
    ]);
    final voice = container.read(voiceControllerProvider.notifier);
    container.listen(voiceControllerProvider, (a, b) {});
    await voice.start();
    await pumpEvents();
    expect(heard, ['add milk to shopping']);
    expect(tts.spoken, ['Done.']);
    final s = container.read(voiceControllerProvider);
    expect(s, isA<VoiceSpeaking>());
    expect((s as VoiceSpeaking).reply, 'Done.');
  });

  test('speak replies OFF: the reply is shown, not spoken', () async {
    container = make([
      [const SpeechFinal('add milk to shopping')],
    ]);
    await AppSettingsRepositoryImpl(container.read(appDatabaseProvider))
        .save(const AppSettings(speakReplies: SpeakReplies.off));
    final voice = container.read(voiceControllerProvider.notifier);
    container.listen(voiceControllerProvider, (a, b) {});
    await voice.start();
    await pumpEvents();
    expect(tts.spoken, isEmpty);
    expect(container.read(voiceControllerProvider),
        isA<VoiceSpeaking>().having((s) => s.spoken, 'spoken', isFalse));
  });

  test('keep listening: after the reply, AA listens again', () async {
    container = make([
      [const SpeechFinal('add milk to shopping')],
      [const SpeechFinal('add eggs to shopping')],
      [const SpeechSilence()],
    ]);
    await AppSettingsRepositoryImpl(container.read(appDatabaseProvider))
        .save(const AppSettings(keepListening: true));
    final voice = container.read(voiceControllerProvider.notifier);
    container.listen(voiceControllerProvider, (a, b) {});
    await voice.start();
    await pumpEvents();
    expect(heard, ['add milk to shopping', 'add eggs to shopping']);
    // Silence ends the conversation.
    expect(container.read(voiceControllerProvider), isA<VoiceIdle>());
    expect(engine.listens, 3);
  });

  test('an unsure final waits for the edit, then acts on it', () async {
    container = make([
      [const SpeechFinal('add silk to shopping', confidence: 0.3)],
    ]);
    final voice = container.read(voiceControllerProvider.notifier);
    container.listen(voiceControllerProvider, (a, b) {});
    await voice.start();
    await pumpEvents();
    expect(container.read(voiceControllerProvider), isA<VoiceReview>());
    expect(heard, isEmpty);

    voice.submit('add milk to shopping');
    await pumpEvents();
    expect(heard, ['add milk to shopping']);
  });

  test('no microphone permission: an error, and nothing listens', () async {
    container = make([]);
    engine.permitted = false;
    final voice = container.read(voiceControllerProvider.notifier);
    await voice.start();
    expect(
        container.read(voiceControllerProvider),
        isA<VoiceError>()
            .having((e) => e.kind, 'kind', VoiceErrorKind.noPermission));
    expect(engine.listens, 0);
  });

  test('an engine failure shows as an error, no turn runs', () async {
    container = make([
      [const SpeechFailure(VoiceErrorKind.network)],
    ]);
    final voice = container.read(voiceControllerProvider.notifier);
    container.listen(voiceControllerProvider, (a, b) {});
    await voice.start();
    await pumpEvents();
    expect((container.read(voiceControllerProvider) as VoiceError).kind,
        VoiceErrorKind.network);
    expect(heard, isEmpty);
  });

  test('stop ends the session and silences the voice', () async {
    container = make([
      [const SpeechPartial('add')],
    ]);
    final voice = container.read(voiceControllerProvider.notifier);
    container.listen(voiceControllerProvider, (a, b) {});
    await voice.start();
    await pumpEvents();
    await voice.stop();
    expect(container.read(voiceControllerProvider), isA<VoiceIdle>());
    expect(engine.stops, greaterThan(0));
    expect(tts.stops, greaterThan(0));
  });

  group('spokenReply', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    const created = ActedCall(
      toolName: 'create_task',
      status: CallStatus.done,
      preview:
          CreateTaskPreview(title: 'Call bank', priority: TaskPriority.low),
    );

    test('the model\'s words when it said something', () {
      expect(spokenReply(l10n, const TurnAnswered('g', [], text: ' Sure. ')),
          'Sure.');
    });

    test('otherwise what AA did, worded like the action card', () {
      expect(spokenReply(l10n, const TurnAnswered('g', [created])),
          'Created task: Call bank');
    });

    test('a confirmation points at the screen', () {
      final prepared =
          ToolRegistry().prepareMap('delete_task', {'task_id': 1}) as Prepared;
      final pending = PendingConfirmation(
          groupId: 'g',
          call: prepared.call,
          preview: const DeletePreview(
              kind: DeleteKind.task, titles: ['Call bank']));
      expect(
          spokenReply(l10n, TurnNeedsConfirmation('g', [], pending: pending)),
          l10n.voiceNeedsConfirm);
    });

    test('no provider and nothing understood', () {
      expect(
          spokenReply(
              l10n, const TurnFailed('g', [], AIFailureKind.noActiveProvider)),
          l10n.localNeedsProvider);
    });
  });

  test('Android error names map to typed kinds', () {
    expect(speechErrorKind('error_no_match'), VoiceErrorKind.noSpeech);
    expect(speechErrorKind('error_network_timeout'), VoiceErrorKind.network);
    expect(speechErrorKind('error_insufficient_permissions'),
        VoiceErrorKind.noPermission);
    expect(speechErrorKind('error_busy'), VoiceErrorKind.busy);
    expect(speechErrorKind('error_language_unavailable'),
        VoiceErrorKind.modelMissing);
    expect(speechErrorKind('something new'), VoiceErrorKind.noEngine);
  });
}
