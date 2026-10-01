import 'package:flowline/core/providers.dart';
import 'package:flowline/core/riverpod_config.dart';
import 'package:flowline/data/local/drift/app_database.dart';
import 'package:flowline/data/local/secure/secure_key_store.dart';
import 'package:flowline/domain/entities/ai_provider_config.dart';
import 'package:flowline/features/ai_assistant/viewmodel/assistant_view_model.dart';
import 'package:flowline/features/settings/viewmodel/ai_providers_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

/// In-memory stand-in for the Keystore-backed store.
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
  late ProviderContainer container;

  setUp(() {
    db = createTestDatabase();
    container = ProviderContainer(retry: noAutomaticRetry, overrides: [
      appDatabaseProvider.overrideWith((ref) => db),
      secureKeyStoreProvider.overrideWith((ref) => _FakeKeyStore()),
    ]);
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('the "has key" status refreshes after saving and removing (K4)',
      () async {
    const id = AIProviderId.anthropic;
    // Keep it alive the way a mounted provider card does.
    final sub = container.listen(providerHasKeyProvider(id), (_, __) {});
    addTearDown(sub.close);
    expect(await container.read(providerHasKeyProvider(id).future), isFalse);

    final viewModel = container.read(aiProvidersViewModelProvider.notifier);
    await viewModel.saveKey(id: id, apiKey: 'sk-test', model: 'some-model');
    expect(await container.read(providerHasKeyProvider(id).future), isTrue);

    await viewModel.removeKey(id);
    expect(await container.read(providerHasKeyProvider(id).future), isFalse);
  });
}
