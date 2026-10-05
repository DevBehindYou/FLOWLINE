import 'package:atomic_assist/assistant/assistant_providers.dart';
import 'package:atomic_assist/assistant/orchestrator.dart';
import 'package:atomic_assist/core/providers.dart';
import 'package:atomic_assist/data/assistant/undo_service.dart';
import 'package:atomic_assist/domain/assistant/autonomy.dart';
import 'package:atomic_assist/domain/assistant/utterance.dart';
import 'package:atomic_assist/domain/entities/app_settings.dart';
import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_database.dart';

/// The app's wiring: a typed request goes through the real providers to
/// the database, the autonomy setting is read, and one UNDO reverts it.
void main() {
  final now = DateTime(2026, 10, 5, 9);

  late ProviderContainer container;
  setUp(() {
    final db = createTestDatabase();
    container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWith((ref) => db)]);
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
  });

  Future<TurnResult> say(String text) => withClock(
      Clock.fixed(now),
      () => container
          .read(assistantOrchestratorProvider)
          .handle(Utterance(text, source: UtteranceSource.typed)));

  test('a typed request creates a task, and UNDO removes it', () async {
    final r = await say('add a task book train tickets');
    expect(r, isA<TurnAnswered>());
    final tasks = container.read(taskRepositoryProvider);
    expect(await tasks.findTasks('train'), hasLength(1));
    expect(
        await withClock(Clock.fixed(now),
            () => container.read(undoServiceProvider).undoGroup(r.groupId)),
        UndoResult.undone);
    expect(await tasks.findTasks('train'), isEmpty);
  });

  test('the autonomy setting is read on every turn', () async {
    final settings = container.read(appSettingsRepositoryProvider);
    await settings.save(const AppSettings(autonomy: AutonomyPreset.careful));
    expect(await say('add a task one'), isA<TurnNeedsConfirmation>());
    await settings.save(const AppSettings());
    expect(await say('add a task two'), isA<TurnAnswered>());
  });

  test('the singletons are kept alive', () async {
    expect(container.read(assistantOrchestratorProvider),
        same(container.read(assistantOrchestratorProvider)));
    expect(container.read(proposalServiceProvider),
        same(container.read(proposalServiceProvider)));
    // The AI repository seeds its rows when it's built; let that finish
    // before the database closes.
    await container.read(aiRepositoryProvider).watchProviders().first;
  });
}
