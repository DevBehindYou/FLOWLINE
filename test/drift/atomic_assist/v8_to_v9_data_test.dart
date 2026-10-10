import 'package:drift_dev/api/migrations_native.dart';
import 'package:drift/drift.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v8.dart' as v8;
import 'generated/schema_v9.dart' as v9;

/// v9 adds ai_messages.stop_reason (B18). Existing messages keep every
/// value and have no stop reason.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  final nine = DateTime(2026, 10, 5, 9).millisecondsSinceEpoch ~/ 1000;

  test('v8 -> v9 keeps messages, stop reason unknown', () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 8,
      newVersion: 9,
      createOld: v8.DatabaseAtV8.new,
      createNew: v9.DatabaseAtV9.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.aiConversations, [
          v8.AiConversationsData(
              id: 1, providerId: 0, title: 'Chat', createdAt: nine),
        ]);
        batch.insertAll(oldDb.aiMessages, [
          v8.AiMessagesData(
              id: 1,
              conversationId: 1,
              role: 1,
              content: 'An old reply',
              isError: 0,
              isPending: 0,
              sentAt: nine),
        ]);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.aiMessages).get(), [
          v9.AiMessagesData(
              id: 1,
              conversationId: 1,
              role: 1,
              content: 'An old reply',
              isError: 0,
              isPending: 0,
              sentAt: nine),
        ]);
      },
    );
  });
}
