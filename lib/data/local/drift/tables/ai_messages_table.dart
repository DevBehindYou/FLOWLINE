import 'package:drift/drift.dart';

import '../../../../domain/entities/ai_message.dart';
import 'ai_conversations_table.dart';

@TableIndex(
    name: 'ai_messages_conversation_order',
    columns: {#conversationId, #sentAt, #id})
@DataClassName('AiMessageRow')
class AiMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get conversationId =>
      integer().references(AiConversations, #id, onDelete: KeyAction.cascade)();
  IntColumn get role => intEnum<AIMessageRole>()();
  TextColumn get content => text()();
  BoolColumn get isError => boolean().withDefault(const Constant(false))();
  // Since schema v4: an assistant reply that's been requested but hasn't
  // arrived. Written before the vendor call and filled in afterwards, so a
  // process killed mid-request leaves a visible placeholder that's turned
  // into an error on the next launch, instead of an orphaned prompt (B23).
  BoolColumn get isPending => boolean().withDefault(const Constant(false))();
  DateTimeColumn get sentAt => dateTime().withDefault(currentDateAndTime)();
}
