import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/app_settings_repository_impl.dart';
import 'package:atomic_assist/domain/entities/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  test('defaults on a fresh database, then saved values persist', () async {
    final repo = AppSettingsRepositoryImpl(db);
    expect(await repo.get(), const AppSettings());

    final changed = const AppSettings()
        .copyWith(themeMode: AppThemeMode.light, focusMinutes: 45);
    await repo.save(changed);
    expect(await repo.get(), changed);

    await repo.save(changed.copyWith(focusMinutes: 30));
    expect((await repo.get()).focusMinutes, 30);
    expect(await db.select(db.appSettingsEntries).get(),
        hasLength(changed.toStorage().length),
        reason: 'saving again updates rows instead of duplicating them');
  });

  test('watch emits the new settings after a save', () async {
    final repo = AppSettingsRepositoryImpl(db);
    final expectation = expectLater(
      repo.watch().map((s) => s.sessionAlerts),
      emitsThrough(false),
    );
    await repo.save(const AppSettings(sessionAlerts: false));
    await expectation;
  });
}
