import 'package:drift/drift.dart';

import '../../../../domain/entities/ai_provider_config.dart';

// Named `Ai...` rather than `AI...` deliberately: Drift derives this
// table's database getter from the class name by lowercasing only the
// first letter, and doing that to an all-caps prefix like `AIProvider...`
// produces an awkward, easy-to-mistype getter. `AiProviderConfigs` ->
// `aiProviderConfigs` has no such ambiguity.
@DataClassName('AiProviderConfigRow')
class AiProviderConfigs extends Table {
  IntColumn get providerId => intEnum<AIProviderId>()();
  TextColumn get displayName => text()();
  TextColumn get defaultModel => text()();
  TextColumn get baseUrl => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {providerId};
}
