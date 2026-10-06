import 'package:drift_dev/api/migrations_native.dart';
import 'package:drift/drift.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v12.dart' as v12;
import 'generated/schema_v13.dart' as v13;

/// v13 adds people, their dates and follow-ups. Lists and their items
/// come through unchanged.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  final nine = DateTime(2026, 10, 5, 9).millisecondsSinceEpoch ~/ 1000;

  test('v12 -> v13 keeps lists and items, no people yet', () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 12,
      newVersion: 13,
      createOld: v12.DatabaseAtV12.new,
      createNew: v13.DatabaseAtV13.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.lists, [
          const v12.ListsData(id: 10, name: 'Hardware', kind: 3, archived: 0),
        ]);
        batch.insertAll(oldDb.listItems, [
          v12.ListItemsData(
              id: 1,
              listId: 10,
              body: 'Screws',
              checked: 0,
              position: 0,
              addedAt: nine),
        ]);
      },
      validateItems: (newDb) async {
        expect(
            (await newDb.select(newDb.lists).get())
                .where((l) => l.id == 10)
                .single,
            const v13.ListsData(
                id: 10, name: 'Hardware', kind: 3, archived: 0));
        expect(await newDb.select(newDb.listItems).get(), [
          v13.ListItemsData(
              id: 1,
              listId: 10,
              body: 'Screws',
              checked: 0,
              position: 0,
              addedAt: nine),
        ]);
        expect(await newDb.select(newDb.people).get(), isEmpty);
        expect(await newDb.select(newDb.followUps).get(), isEmpty);
      },
    );
  });
}
