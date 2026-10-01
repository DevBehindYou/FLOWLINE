import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/ai_provider_config.dart';
import '../../ai_assistant/viewmodel/assistant_view_model.dart';

part 'ai_providers_view_model.g.dart';

// keepAlive (rule R11): an action surface whose methods use `ref` after
// an `await`. Auto-dispose would let it be disposed mid-action (the sheet
// or screen that called it closes), and Riverpod 3 throws on any use of a
// disposed Ref.
@Riverpod(keepAlive: true)
class AiProvidersViewModel extends _$AiProvidersViewModel {
  @override
  void build() {}

  Future<void> setActive(AIProviderId id) {
    return ref.read(aiRepositoryProvider).setActiveProvider(id);
  }

  Future<void> saveKey({
    required AIProviderId id,
    required String apiKey,
    required String model,
    String? baseUrl,
  }) async {
    await ref.read(aiRepositoryProvider).saveProviderKey(
          id: id,
          apiKey: apiKey,
          model: model,
          baseUrl: baseUrl,
        );
    // The key lives in the Keystore, not Drift, so nothing re-reads it on
    // its own: without this the card and radio stay "Not connected" (K4).
    ref.invalidate(providerHasKeyProvider(id));
  }

  Future<void> removeKey(AIProviderId id) async {
    await ref.read(aiRepositoryProvider).removeProviderKey(id);
    ref.invalidate(providerHasKeyProvider(id));
  }
}
