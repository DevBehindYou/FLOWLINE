import 'package:drift/drift.dart';

import '../../../../domain/entities/checklist.dart';

/// Lists (schema v12, docs/05 §17). Names are unique ignoring case
/// (`lists_name_nocase`), so "Shopping" and "shopping" are one list.
@TableIndex
    .sql('CREATE UNIQUE INDEX lists_name_nocase ON lists (name COLLATE NOCASE)')
@DataClassName('ListRow')
class Lists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name =>
      // Drift's documented pattern for a column CHECK.
      // ignore: recursive_getters
      text().check(name.length.isBetweenValues(1, 60))();
  IntColumn get kind => intEnum<ListKind>()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

@TableIndex(name: 'list_items_list_position', columns: {#listId, #position})
@DataClassName('ListItemRow')
class ListItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get listId =>
      integer().references(Lists, #id, onDelete: KeyAction.cascade)();
  TextColumn get body =>
      // `text` would shadow Drift's builder (as in utterances).
      // ignore: recursive_getters
      text().check(body.length.isBetweenValues(1, 200))();
  BoolColumn get checked => boolean().withDefault(const Constant(false))();
  IntColumn get position => integer()();
  DateTimeColumn get addedAt => dateTime()();
  DateTimeColumn get checkedAt => dateTime().nullable()();
}
