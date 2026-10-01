import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/app_settings_repository.dart';
import '../local/drift/app_database.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  AppSettingsRepositoryImpl(this._db);

  final AppDatabase _db;

  AppSettings _fromRows(List<AppSettingRow> rows) =>
      AppSettings.fromStorage({for (final r in rows) r.key: r.value});

  @override
  Stream<AppSettings> watch() =>
      _db.select(_db.appSettingsEntries).watch().map(_fromRows);

  @override
  Future<AppSettings> get() async =>
      _fromRows(await _db.select(_db.appSettingsEntries).get());

  @override
  Future<void> save(AppSettings settings) {
    return _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.appSettingsEntries, [
        for (final entry in settings.toStorage().entries)
          AppSettingsEntriesCompanion.insert(
              key: entry.key, value: entry.value),
      ]);
    });
  }
}
