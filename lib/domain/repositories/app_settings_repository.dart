import '../entities/app_settings.dart';

abstract interface class AppSettingsRepository {
  Stream<AppSettings> watch();
  Future<AppSettings> get();

  /// Writes every value of [settings]. Only changed rows actually change;
  /// watchers see a single new [AppSettings].
  Future<void> save(AppSettings settings);
}
