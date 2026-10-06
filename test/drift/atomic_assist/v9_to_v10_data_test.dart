import 'package:drift_dev/api/migrations_native.dart';
import 'package:drift/drift.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v9.dart' as v9;
import 'generated/schema_v10.dart' as v10;

/// v10 adds assistant_actions.preview_json and ai_messages.turn_group_id.
/// Existing ledger rows and messages keep every value, with both null.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  final nine = DateTime(2026, 10, 5, 9).millisecondsSinceEpoch ~/ 1000;

  test('v9 -> v10 keeps the ledger and messages', () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 9,
      newVersion: 10,
      createOld: v9.DatabaseAtV9.new,
      createNew: v10.DatabaseAtV10.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.assistantActions, [
          v9.AssistantActionsData(
              id: 1,
              at: nine,
              groupId: 'g1',
              toolName: 'create_task',
              argsJson: '{"title":"x"}',
              origin: 0,
              decision: 1,
              status: 0,
              undoJson: '{"op":"delete","table":"tasks","ids":[1]}'),
        ]);
        batch.insertAll(oldDb.aiConversations, [
          v9.AiConversationsData(
              id: 1, providerId: 0, title: 'Chat', createdAt: nine),
        ]);
        batch.insertAll(oldDb.aiMessages, [
          v9.AiMessagesData(
              id: 1,
              conversationId: 1,
              role: 1,
              content: 'Hi',
              isError: 0,
              isPending: 0,
              sentAt: nine,
              stopReason: 0),
        ]);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.assistantActions).get(), [
          v10.AssistantActionsData(
              id: 1,
              at: nine,
              groupId: 'g1',
              toolName: 'create_task',
              argsJson: '{"title":"x"}',
              origin: 0,
              decision: 1,
              status: 0,
              undoJson: '{"op":"delete","table":"tasks","ids":[1]}'),
        ]);
        expect(await newDb.select(newDb.aiMessages).get(), [
          v10.AiMessagesData(
              id: 1,
              conversationId: 1,
              role: 1,
              content: 'Hi',
              isError: 0,
              isPending: 0,
              sentAt: nine,
              stopReason: 0),
        ]);
      },
    );
  });
}
