import 'package:drift/drift.dart';

import '../../../../domain/entities/ai_provider_config.dart';

@DataClassName('AiConversationRow')
class AiConversations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get providerId => intEnum<AIProviderId>()();
  TextColumn get title => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
