import 'package:drift_dev/api/migrations_native.dart';
import 'package:drift/drift.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v11.dart' as v11;
import 'generated/schema_v12.dart' as v12;

/// v12 adds lists and list items, with the three default lists.
/// Existing reminders come through unchanged.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  final seven = DateTime(2026, 10, 5, 19).millisecondsSinceEpoch ~/ 1000;

  test('v11 -> v12 keeps reminders and adds the default lists', () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 11,
      newVersion: 12,
      createOld: v11.DatabaseAtV11.new,
      createNew: v12.DatabaseAtV12.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.reminders, [
          v11.RemindersData(
              id: 1,
              title: 'Call Mum',
              fireAt: seven,
              kind: 0,
              status: 0,
              snoozeCount: 0),
        ]);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.reminders).get(), [
          v12.RemindersData(
              id: 1,
              title: 'Call Mum',
              fireAt: seven,
              kind: 0,
              status: 0,
              snoozeCount: 0),
        ]);
        final lists = await newDb.select(newDb.lists).get();
        expect(lists.map((l) => (l.name, l.kind)),
            [('Shopping', 0), ('Errands', 1), ('Packing', 2)]);
        expect(await newDb.select(newDb.listItems).get(), isEmpty);
      },
    );
  });
}
