import 'package:atomic_assist/design/atomic.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/features/ai_assistant/view/assistant_screen.dart';
import 'package:flutter/material.dart';
import 'package:atomic_assist/domain/assistant/speech.dart';
import 'package:atomic_assist/features/voice/viewmodel/voice_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_voice.dart';

import '../../support/pump_app.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 5)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets(
        'prompts to connect a provider when none is configured (${mode.name})',
        (tester) async {
      await pumpScreen(tester,
          db: db, themeMode: mode, child: const AssistantScreen());

      expect(find.text('Connect an AI provider'), findsOneWidget);
      expect(find.textContaining('Quick commands work without one'),
          findsOneWidget);
      expect(find.widgetWithText(AtomicButton, 'Go to AI Providers'),
          findsOneWidget);
      // Local commands still have a field.
      expect(
          find.widgetWithText(TextField, 'Try: remind me at 6pm to call Mum'),
          findsOneWidget);
    });
  }

  testWidgets('without a provider, a local command acts and can be undone',
      (tester) async {
    await pumpScreen(tester, db: db, child: const AssistantScreen());

    await tester.enterText(find.byType(TextField), 'add milk to shopping');
    await tester.tap(find.bySemanticsLabel('Send'));
    await settle(tester);
    expect(find.text('add milk to shopping'), findsOneWidget);
    expect(find.text('UNDO'), findsOneWidget);
    Future<List<String>> items() async =>
        (await tester.runAsync(() => db.select(db.listItems).get()))!
            .map((i) => i.body)
            .toList();
    expect(await items(), ['milk']);

    await tester.tap(find.text('UNDO'));
    await settle(tester);
    expect(await items(), isEmpty);
  });

  testWidgets('a spoken command acts locally and the reply is read out',
      (tester) async {
    final engine = FakeSpeechEngine([
      [
        const SpeechPartial('add milk'),
        const SpeechFinal('add milk to shopping', confidence: 0.92),
      ],
    ]);
    final tts = FakeTts();
    await pumpScreen(tester,
        db: db,
        child: const AssistantScreen(),
        extraOverrides: [
          speechEngineProvider.overrideWithValue(engine),
          textToSpeechProvider.overrideWithValue(tts),
        ]);

    await tester.tap(find.bySemanticsLabel('Start listening'));
    await settle(tester);
    final items = (await tester.runAsync(() => db.select(db.listItems).get()))!;
    expect(items.map((i) => i.body), ['milk']);
    // Worded like the action card, shown as a caption and spoken.
    expect(tts.spoken, hasLength(1));
    expect(tts.spoken.single, startsWith('Added to list'));
    expect(find.text(tts.spoken.single), findsOneWidget);
    // It is in the ledger as a voice turn.
    final utterances =
        (await tester.runAsync(() => db.select(db.utterances).get()))!;
    expect(utterances.single.body, 'add milk to shopping');

    await tester.tap(find.widgetWithText(AtomicButton, 'Done'));
    await settle(tester);
    expect(find.text(tts.spoken.single), findsNothing);
  });

  testWidgets('without a provider, anything else says it needs one',
      (tester) async {
    await pumpScreen(tester, db: db, child: const AssistantScreen());

    await tester.enterText(find.byType(TextField), 'write me a poem');
    await tester.tap(find.bySemanticsLabel('Send'));
    await settle(tester);
    expect(find.text('That needs an AI provider.'), findsOneWidget);
  });

  testWidgets('reading the empty state never touches secure storage',
      (tester) async {
    // Regression guard: activeAiProviderProvider only reads the Drift
    // "which provider is active" flag; providerHasKeyProvider (the one
    // that hits flutter_secure_storage) must not be watched just to show
    // this screen, or every widget test here would need a secure-storage
    // platform-channel mock.
    await pumpScreen(tester, db: db, child: const AssistantScreen());
    expect(tester.takeException(), isNull);
  });
}
