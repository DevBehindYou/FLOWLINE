import 'package:atomic_assist/core/providers.dart';
import 'package:atomic_assist/core/riverpod_config.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/local/secure/secure_key_store.dart';
import 'package:atomic_assist/data/repositories/app_settings_repository_impl.dart';
import 'package:atomic_assist/data/repositories/task_repository_impl.dart';
import 'package:atomic_assist/domain/entities/ai_provider_config.dart';
import 'package:atomic_assist/domain/entities/app_settings.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:atomic_assist/features/settings/view/settings_screens.dart';
import 'package:atomic_assist/features/settings/viewmodel/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/finders.dart';

import '../../support/pump_app.dart';
import '../../support/test_database.dart';

class _FakeKeyStore implements SecureKeyStore {
  final keys = <AIProviderId, String>{};
  @override
  Future<String?> getKey(AIProviderId id) async => keys[id];
  @override
  Future<void> setKey(AIProviderId id, String value) async => keys[id] = value;
  @override
  Future<void> deleteKey(AIProviderId id) async => keys.remove(id);
}

void main() {
  late AppDatabase db;
  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  Future<AppSettings> stored(WidgetTester tester) async =>
      (await tester.runAsync(() => AppSettingsRepositoryImpl(db).get()))!;

  testWidgets('Appearance saves the chosen theme mode', (tester) async {
    await pumpScreen(tester, db: db, child: const AppearanceScreen());
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect((await stored(tester)).themeMode, AppThemeMode.dark);
  });

  testWidgets('Focus timer steppers change and persist lengths',
      (tester) async {
    await pumpScreen(tester, db: db, child: const FocusTimerSettingsScreen());
    expect(findLabel('25 min'), findsOneWidget);

    await tester.tap(find.byTooltip('Increase Focus'));
    await tester.pumpAndSettle();
    expect(findLabel('30 min'), findsOneWidget);
    expect((await stored(tester)).focusMinutes, 30);

    await tester.tap(find.byTooltip('Decrease Short break'));
    await tester.pumpAndSettle();
    expect((await stored(tester)).shortBreakMinutes, 4);
  });

  testWidgets('Session alerts can be turned off', (tester) async {
    await pumpScreen(tester, db: db, child: const NotificationSettingsScreen());
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect((await stored(tester)).sessionAlerts, isFalse);
  });

  test('clearAllData empties every table and every saved key', () async {
    final keys = _FakeKeyStore()..keys[AIProviderId.openai] = 'sk-x';
    final container = ProviderContainer(retry: noAutomaticRetry, overrides: [
      appDatabaseProvider.overrideWith((ref) => db),
      secureKeyStoreProvider.overrideWith((ref) => keys),
    ]);
    addTearDown(container.dispose);
    final tasks = TaskRepositoryImpl(db);
    final id = await tasks.createTask(title: 'x', priority: TaskPriority.low);
    await tasks.createSubtask(taskId: id, title: 'y');
    await AppSettingsRepositoryImpl(db)
        .save(const AppSettings(focusMinutes: 40));

    await container.read(settingsViewModelProvider.notifier).clearAllData();

    expect(await db.select(db.tasks).get(), isEmpty);
    expect(await db.select(db.subtasks).get(), isEmpty);
    expect(await db.select(db.appSettingsEntries).get(), isEmpty);
    expect(keys.keys, isEmpty);
  });

  testWidgets('Clear all data asks before deleting', (tester) async {
    await tester.runAsync(() => TaskRepositoryImpl(db)
        .createTask(title: 'keep?', priority: TaskPriority.low));
    await pumpScreen(tester,
        db: db,
        child: const DataPrivacyScreen(),
        extraOverrides: [
          secureKeyStoreProvider.overrideWith((ref) => _FakeKeyStore()),
        ]);

    await tester.ensureVisible(find.text('Clear all data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear all data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(
        await tester.runAsync(() => db.select(db.tasks).get()), hasLength(1));

    await tester.ensureVisible(find.text('Clear all data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear all data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear everything'));
    await tester.pumpAndSettle();
    expect(await tester.runAsync(() => db.select(db.tasks).get()), isEmpty);
    expect(find.text('All data cleared'), findsOneWidget);
  });
}
