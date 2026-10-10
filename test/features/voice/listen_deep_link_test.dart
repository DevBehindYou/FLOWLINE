import 'package:atomic_assist/core/providers.dart';
import 'package:atomic_assist/core/riverpod_config.dart';
import 'package:atomic_assist/core/router/app_router.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/design/atomic.dart';
import 'package:atomic_assist/domain/assistant/speech.dart';
import 'package:atomic_assist/features/voice/view/listening_panel.dart';
import 'package:atomic_assist/features/voice/viewmodel/voice_controller.dart';
import 'package:atomic_assist/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/fake_voice.dart';
import '../../support/test_database.dart';

/// The QS tile and the launcher shortcut open
/// atomicassist://app/assistant?listen=1; Flutter hands go_router the
/// path and query.
void main() {
  late AppDatabase db;
  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  testWidgets('/assistant?listen=1 opens Assist and starts listening',
      (tester) async {
    final engine = FakeSpeechEngine([
      [const SpeechPartial('add milk')],
    ]);
    late GoRouter router;
    await tester.pumpWidget(ProviderScope(
      retry: noAutomaticRetry,
      overrides: [
        appDatabaseProvider.overrideWith((ref) => db),
        speechEngineProvider.overrideWithValue(engine),
        textToSpeechProvider.overrideWithValue(FakeTts()),
      ],
      child: Consumer(builder: (context, ref, _) {
        router = ref.watch(appRouterProvider);
        return MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AtomicTheme.light(),
          routerConfig: router,
        );
      }),
    ));
    await tester.pumpAndSettle();

    router.go('/assistant?listen=1');
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 5)));
      await tester.pump();
    }
    expect(find.byType(ListeningPanel), findsOneWidget);
    expect(engine.listens, 1);
    // The query isn't kept: coming back to Assist doesn't listen again.
    expect(router.routeInformationProvider.value.uri.toString(), '/assistant');
  });
}
