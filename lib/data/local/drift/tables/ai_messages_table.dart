import 'package:drift/drift.dart';

import '../../../../domain/entities/ai_message.dart';
import 'ai_conversations_table.dart';

@DataClassName('AiMessageRow')
class AiMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get conversationId =>
      integer().references(AiConversations, #id, onDelete: KeyAction.cascade)();
  IntColumn get role => intEnum<AIMessageRole>()();
  TextColumn get content => text()();
  BoolColumn get isError => boolean().withDefault(const Constant(false))();
  DateTimeColumn get sentAt => dateTime().withDefault(currentDateAndTime)();
}
