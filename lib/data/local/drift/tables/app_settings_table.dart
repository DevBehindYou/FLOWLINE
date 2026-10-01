import 'package:drift/drift.dart';

/// Key/value preferences (schema v5). Text values parsed by
/// `AppSettings.fromStorage`, which tolerates anything unexpected.
@DataClassName('AppSettingRow')
class AppSettingsEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};

  @override
  String get tableName => 'app_settings';
}
