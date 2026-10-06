import 'package:drift/drift.dart';

import '../../domain/entities/checklist.dart';
import '../../domain/repositories/list_repository.dart';
import '../local/drift/app_database.dart';

class ListRepositoryImpl implements ListRepository {
  ListRepositoryImpl(this._db);

  final AppDatabase _db;

  // One query for the lists and their counts, live on both tables.
  static const _listsSql = 'SELECT l.id, l.name, l.kind, '
      'COUNT(i.id) AS total, '
      'COALESCE(SUM(CASE WHEN i.checked = 0 THEN 1 ELSE 0 END), 0) AS open '
      'FROM lists l LEFT JOIN list_items i ON i.list_id = l.id '
      'WHERE l.archived = 0';

  Checklist _list(QueryRow r) => Checklist(
        id: r.read<int>('id'),
        name: r.read<String>('name'),
        kind: ListKind.values[r.read<int>('kind')],
        totalCount: r.read<int>('total'),
        openCount: r.read<int>('open'),
      );

  Selectable<Checklist> _select(String where, List<Variable> vars) =>
      _db.customSelect('$_listsSql$where GROUP BY l.id ORDER BY l.id',
          variables: vars, readsFrom: {_db.lists, _db.listItems}).map(_list);

  @override
  Stream<List<Checklist>> watchLists() => _select('', const []).watch();

  @override
  Future<List<Checklist>> getLists() => _select('', const []).get();

  @override
  Future<Checklist?> findByName(String name) async {
    final found = await _select(' AND l.name = ? COLLATE NOCASE',
        [Variable.withString(name.trim())]).get();
    return found.isEmpty ? null : found.first;
  }

  @override
  Future<Checklist?> getList(int id) async {
    final found = await _select(' AND l.id = ?', [Variable.withInt(id)]).get();
    return found.isEmpty ? null : found.first;
  }

  SimpleSelectStatement<$ListItemsTable, ListItemRow> _items(int listId) =>
      _db.select(_db.listItems)
        ..where((i) => i.listId.equals(listId))
        ..orderBy([
          (i) => OrderingTerm.asc(i.checked),
          (i) => OrderingTerm.asc(i.position),
          (i) => OrderingTerm.asc(i.id),
        ]);

  @override
  Stream<List<ChecklistItem>> watchItems(int listId) =>
      _items(listId).watch().map((rows) => rows.map(_item).toList());

  @override
  Future<List<ChecklistItem>> getItems(int listId) async =>
      (await _items(listId).get()).map(_item).toList();

  @override
  Future<ChecklistItem?> getItem(int id) async {
    final row = await (_db.select(_db.listItems)..where((i) => i.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _item(row);
  }

  @override
  Future<List<int>> addItems(int listId, List<String> texts,
      {required DateTime at}) {
    // Reads the last position and inserts in one transaction, so two
    // quick adds can't take the same place.
    return _db.transaction(() async {
      final last = _db.listItems.position.max();
      final row = await (_db.selectOnly(_db.listItems)
            ..addColumns([last])
            ..where(_db.listItems.listId.equals(listId)))
          .getSingle();
      var next = (row.read(last) ?? -1) + 1;
      return [
        for (final t in texts)
          await _db.into(_db.listItems).insert(ListItemsCompanion.insert(
                listId: listId,
                body: t,
                position: next++,
                addedAt: at,
              )),
      ];
    });
  }

  @override
  Future<void> setChecked(int itemId, bool checked, {required DateTime at}) =>
      (_db.update(_db.listItems)..where((i) => i.id.equals(itemId))).write(
          ListItemsCompanion(
              checked: Value(checked), checkedAt: Value(checked ? at : null)));

  @override
  Future<int> clearChecked(int listId) => (_db.delete(_db.listItems)
        ..where((i) => i.listId.equals(listId) & i.checked.equals(true)))
      .go();

  ChecklistItem _item(ListItemRow r) => ChecklistItem(
        id: r.id,
        listId: r.listId,
        text: r.body,
        checked: r.checked,
        position: r.position,
      );
}
