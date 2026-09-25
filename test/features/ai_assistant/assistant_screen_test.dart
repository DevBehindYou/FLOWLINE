import 'package:flowline/data/local/drift/app_database.dart';
import 'package:flowline/features/ai_assistant/view/assistant_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_app.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets(
        'prompts to connect a provider when none is configured (${mode.name})',
        (tester) async {
      await pumpScreen(tester,
          db: db, themeMode: mode, child: const AssistantScreen());

      expect(find.text('Connect an AI provider'), findsOneWidget);
      expect(find.text('Add an API key in Settings to start chatting.'),
          findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Go to AI Providers'),
          findsOneWidget);
      // No provider means no chat composer should be reachable yet.
      expect(find.byType(TextField), findsNothing);
    });
  }

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
