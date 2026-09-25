import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/ai_provider_config.dart';

part 'ai_providers_view_model.g.dart';

@riverpod
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
  }) {
    return ref.read(aiRepositoryProvider).saveProviderKey(
          id: id,
          apiKey: apiKey,
          model: model,
          baseUrl: baseUrl,
        );
  }

  Future<void> removeKey(AIProviderId id) {
    return ref.read(aiRepositoryProvider).removeProviderKey(id);
  }
}
