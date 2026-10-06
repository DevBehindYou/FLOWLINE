import 'package:drift/drift.dart';

import '../../../../domain/ai/ai_contract.dart';
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

  // Since schema v7: what went wrong with an error reply, so the chat can
  // word it in the user's language. Rows from before v7 keep their
  // English text in `content` and have no kind.
  IntColumn get errorKind => intEnum<AIFailureKind>().nullable()();
  IntColumn get errorStatus => integer().nullable()();

  // Since schema v9: why a finished reply ended, so a reply cut off at
  // the length limit can say so (B18). Null for older rows and errors.
  IntColumn get stopReason => intEnum<AIStopReason>().nullable()();

  // Since schema v10: the assistant turn this reply belongs to (the ledger
  // group), so the chat shows that turn's actions under the reply.
  TextColumn get turnGroupId => text().nullable()();
}
