import 'package:drift_dev/api/migrations_native.dart';
import 'package:drift/drift.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v10.dart' as v10;
import 'generated/schema_v11.dart' as v11;

/// v11 adds reminders. Tasks come through unchanged; no reminders yet.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  final nine = DateTime(2026, 10, 5, 9).millisecondsSinceEpoch ~/ 1000;

  test('v10 -> v11 keeps tasks, starts with no reminders', () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 10,
      newVersion: 11,
      createOld: v10.DatabaseAtV10.new,
      createNew: v11.DatabaseAtV11.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.tasks, [
          v10.TasksData(
              id: 1,
              title: 'Call Mum',
              notes: '',
              priority: 1,
              status: 0,
              createdAt: nine),
        ]);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.tasks).get(), [
          v11.TasksData(
              id: 1,
              title: 'Call Mum',
              notes: '',
              priority: 1,
              status: 0,
              createdAt: nine),
        ]);
        expect(await newDb.select(newDb.reminders).get(), isEmpty);
      },
    );
  });
}
