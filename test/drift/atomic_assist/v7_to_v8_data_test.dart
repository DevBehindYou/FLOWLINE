import 'package:drift_dev/api/migrations_native.dart';
import 'package:drift/drift.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v7.dart' as v7;
import 'generated/schema_v8.dart' as v8;

/// v8 only adds the assistant tables (ledger, proposals, utterances).
/// Existing rows must come through untouched and the new tables start
/// empty.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  // Unix seconds, as these schema versions store date-times.
  final nine = DateTime(2026, 10, 5, 9).millisecondsSinceEpoch ~/ 1000;

  test('v7 -> v8 keeps tasks and chat history, new tables empty', () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 7,
      newVersion: 8,
      createOld: v7.DatabaseAtV7.new,
      createNew: v8.DatabaseAtV8.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.tasks, [
          v7.TasksData(
              id: 1,
              title: 'Send deck to Priya',
              notes: 'v2',
              priority: 2,
              status: 0,
              dueAt: nine + 3600,
              createdAt: nine),
        ]);
        batch.insertAll(oldDb.aiConversations, [
          v7.AiConversationsData(
              id: 1, providerId: 0, title: 'Chat', createdAt: nine),
        ]);
        batch.insertAll(oldDb.aiMessages, [
          v7.AiMessagesData(
              id: 1,
              conversationId: 1,
              role: 1,
              content: 'Rate limited',
              isError: 1,
              isPending: 0,
              sentAt: nine,
              errorKind: 3,
              errorStatus: 429),
        ]);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.tasks).get(), [
          v8.TasksData(
              id: 1,
              title: 'Send deck to Priya',
              notes: 'v2',
              priority: 2,
              status: 0,
              dueAt: nine + 3600,
              createdAt: nine),
        ]);
        expect(await newDb.select(newDb.aiMessages).get(), [
          v8.AiMessagesData(
              id: 1,
              conversationId: 1,
              role: 1,
              content: 'Rate limited',
              isError: 1,
              isPending: 0,
              sentAt: nine,
              errorKind: 3,
              errorStatus: 429),
        ]);
        expect(await newDb.select(newDb.utterances).get(), isEmpty);
        expect(await newDb.select(newDb.assistantActions).get(), isEmpty);
        expect(await newDb.select(newDb.proposals).get(), isEmpty);
      },
    );
  });
}
