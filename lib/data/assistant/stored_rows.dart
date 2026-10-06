import 'package:drift/drift.dart';

import '../../domain/assistant/ledger.dart';
import '../local/drift/app_database.dart';

/// Raw row access for undo (docs/05 §9.4): rows as stored, keyed by SQL
/// column name, with JSON-safe values (date-times are Unix seconds, as
/// Drift stores them). Table and column names come only from the schema,
/// never from a recipe, so nothing a recipe holds becomes SQL text.
final class StoredRows {
  StoredRows(this._db);

  final AppDatabase _db;

  TableInfo<Table, Object?> table(UndoTable t) => switch (t) {
        UndoTable.tasks => _db.tasks,
        UndoTable.subtasks => _db.subtasks,
        UndoTable.scheduleBlocks => _db.scheduleBlocks,
        UndoTable.scheduleBlockExceptions => _db.scheduleBlockExceptions,
        UndoTable.focusSessions => _db.focusSessions,
        UndoTable.reminders => _db.reminders,
      };

  Set<String> columns(UndoTable t) =>
      {for (final c in table(t).$columns) c.$name};

  String _name(UndoTable t) => table(t).actualTableName;

  /// Throws [ArgumentError] for a column [t] doesn't have.
  void checkColumns(UndoTable t, Iterable<String> names) {
    final known = columns(t);
    for (final n in names) {
      if (!known.contains(n)) {
        throw ArgumentError('${_name(t)} has no column $n');
      }
    }
  }

  Future<Map<String, Object?>?> row(UndoTable t, int id) async {
    final rows = await rowsWhere(t, 'id', id);
    return rows.isEmpty ? null : rows.single;
  }

  Future<List<Map<String, Object?>>> rowsWhere(
      UndoTable t, String column, int value) async {
    checkColumns(t, [column]);
    final rows = await _db.customSelect(
      'SELECT * FROM ${_name(t)} WHERE $column = ? ORDER BY rowid',
      variables: [Variable.withInt(value)],
    ).get();
    return [for (final r in rows) Map<String, Object?>.of(r.data)];
  }

  Future<void> deleteIds(UndoTable t, List<int> ids) async {
    checkColumns(t, ['id']);
    await _db.customUpdate(
      'DELETE FROM ${_name(t)} WHERE id IN (${_marks(ids.length)})',
      variables: [for (final id in ids) Variable.withInt(id)],
      updates: {table(t)},
      updateKind: UpdateKind.delete,
    );
  }

  Future<void> insert(UndoTable t, Map<String, Object?> row) async {
    checkColumns(t, row.keys);
    final cols = row.keys.toList();
    await _db.customInsert(
      'INSERT INTO ${_name(t)} (${cols.join(', ')}) '
      'VALUES (${_marks(cols.length)})',
      variables: [for (final c in cols) _variable(row[c])],
      updates: {table(t)},
    );
  }

  Future<void> update(UndoTable t, int id, Map<String, Object?> values) async {
    checkColumns(t, values.keys);
    final cols = values.keys.toList();
    await _db.customUpdate(
      'UPDATE ${_name(t)} SET ${cols.map((c) => '$c = ?').join(', ')} '
      'WHERE id = ?',
      variables: [
        for (final c in cols) _variable(values[c]),
        Variable.withInt(id),
      ],
      updates: {table(t)},
      updateKind: UpdateKind.update,
    );
  }

  static String _marks(int n) => List.filled(n, '?').join(', ');

  static Variable<Object> _variable(Object? v) => switch (v) {
        null => const Variable<Object>(null),
        final int i => Variable<Object>(i),
        final double d => Variable<Object>(d),
        final String s => Variable<Object>(s),
        // SQLite has no booleans; Drift stores them as 0/1.
        final bool b => Variable<Object>(b ? 1 : 0),
        _ => throw ArgumentError('Unsupported value $v'),
      };
}
