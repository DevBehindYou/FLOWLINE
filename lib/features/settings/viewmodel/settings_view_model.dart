import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/ai_provider_config.dart';
import '../../../domain/entities/app_settings.dart';
import '../../ai_assistant/viewmodel/assistant_view_model.dart';

part 'settings_view_model.g.dart';

// keepAlive (rule R11): uses ref after awaits.
@Riverpod(keepAlive: true)
class SettingsViewModel extends _$SettingsViewModel {
  @override
  void build() {}

  /// Read-modify-write against the stored settings (not a cached copy),
  /// so two quick changes on different screens can't overwrite each other.
  Future<void> update(AppSettings Function(AppSettings current) change) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    await repo.save(change(await repo.get()));
  }

  /// "Clear all data": every table and every saved API key. Irreversible;
  /// the screen confirms first.
  Future<void> clearAllData() async {
    final keys = ref.read(secureKeyStoreProvider);
    for (final id in AIProviderId.values) {
      await keys.deleteKey(id);
      ref.invalidate(providerHasKeyProvider(id));
    }
    await ref.read(appDatabaseProvider).wipeAllData();
  }
}
