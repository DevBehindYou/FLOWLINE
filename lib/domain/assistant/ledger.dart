import 'dart:convert';

import 'action_preview.dart';
import 'autonomy.dart';

// The action ledger (docs/05 §6.3, §9.4). Pure Dart. Every action AA
// executes writes one entry in the same transaction as the change,
// carrying what it takes to reverse it. Enums here are stored by index
// and are append-only (R1).

/// What became of a ledger entry.
enum LedgerStatus {
  /// Ran; can be undone if it has an [UndoRecipe].
  done,

  /// Ran, then was undone.
  undone,

  /// Was attempted and failed; nothing changed.
  failed,

  /// Opened another app, where the user finishes it.
  handedOff,
}

/// The tables an undo recipe may touch. Recipes store the *name* (JSON),
/// so this enum may grow in any order, but keep it append-only anyway:
/// the ledger outlives any one version of the app.
enum UndoTable {
  tasks,
  subtasks,
  scheduleBlocks,
  scheduleBlockExceptions,
  focusSessions,
}

/// How to reverse one action. Stored as JSON in the ledger row
/// ([encodeUndoRecipe] / [decodeUndoRecipe]). Row values are plain JSON
/// (numbers, strings, booleans, null), in the table's SQL column names.
sealed class UndoRecipe {
  const UndoRecipe();
}

/// Undo a create: delete these rows.
final class DeleteRows extends UndoRecipe {
  const DeleteRows(this.table, this.ids);
  final UndoTable table;
  final List<int> ids;
}

/// Undo a delete: put these rows back exactly.
final class RestoreRows extends UndoRecipe {
  const RestoreRows(this.table, this.rows);
  final UndoTable table;
  final List<Map<String, Object?>> rows;
}

/// Undo an update: set [before] again, but only while the row still
/// matches [after]. If the user changed it since, undo refuses rather
/// than overwrite their edit ("Changed since. Not undone.").
final class RestoreFields extends UndoRecipe {
  const RestoreFields(
    this.table,
    this.id, {
    required this.before,
    required this.after,
  });
  final UndoTable table;
  final int id;
  final Map<String, Object?> before;
  final Map<String, Object?> after;
}

/// Undo a started focus session: remove it if it ran under a minute
/// (no history for a slip), otherwise end it early so the time spent
/// still counts. Refuses once the session has ended on its own.
final class StopFocus extends UndoRecipe {
  const StopFocus(this.sessionId);
  final int sessionId;
}

/// Several steps, listed in the order the action did them; undone in
/// reverse order, all or nothing.
final class UndoAll extends UndoRecipe {
  const UndoAll(this.steps);
  final List<UndoRecipe> steps;
}

/// One row of the ledger.
final class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.at,
    required this.groupId,
    required this.toolName,
    required this.argsJson,
    required this.origin,
    required this.decision,
    required this.status,
    this.undo,
    this.utteranceId,
    this.preview,
  });

  final int id;
  final DateTime at;

  /// Shared by every call of one turn: one UNDO reverses the turn.
  final String groupId;
  final String toolName;
  final String argsJson;
  final ActionOrigin origin;
  final Decision decision;
  final LedgerStatus status;

  /// Null for reads, hand-offs, failures, and a recipe that no longer
  /// decodes (an entry is never lost because its recipe is unreadable).
  final UndoRecipe? undo;
  final int? utteranceId;

  /// What it did, for wording; null for rows from before schema v10.
  final ActionPreview? preview;

  bool get canUndo => status == LedgerStatus.done && undo != null;
}

/// [recipe] as the JSON stored in `assistant_actions.undo_json`.
String encodeUndoRecipe(UndoRecipe recipe) => jsonEncode(_toJson(recipe));

/// The recipe in [json], or null when it isn't one this version
/// understands. Never throws: a ledger row with an unreadable recipe
/// just can't be undone.
UndoRecipe? decodeUndoRecipe(String? json) {
  if (json == null) return null;
  try {
    return _fromJson(jsonDecode(json));
  } on FormatException {
    return null;
  }
}

Map<String, Object?> _toJson(UndoRecipe recipe) => switch (recipe) {
      DeleteRows(:final table, :final ids) => {
          'op': 'delete',
          'table': table.name,
          'ids': ids,
        },
      RestoreRows(:final table, :final rows) => {
          'op': 'restore',
          'table': table.name,
          'rows': rows,
        },
      RestoreFields(:final table, :final id, :final before, :final after) => {
          'op': 'fields',
          'table': table.name,
          'id': id,
          'before': before,
          'after': after,
        },
      StopFocus(:final sessionId) => {
          'op': 'stopFocus',
          'id': sessionId,
        },
      UndoAll(:final steps) => {
          'op': 'all',
          'steps': [for (final s in steps) _toJson(s)],
        },
    };

/// Throws [FormatException] on anything malformed.
UndoRecipe _fromJson(Object? json) {
  if (json is! Map) throw const FormatException('recipe is not an object');
  final op = json['op'];
  if (op == 'all') {
    final steps = json['steps'];
    if (steps is! List || steps.isEmpty) {
      throw const FormatException('steps');
    }
    return UndoAll([for (final s in steps) _fromJson(s)]);
  }
  if (op == 'stopFocus') return StopFocus(_id(json['id']));
  final table = _table(json['table']);
  return switch (op) {
    'delete' => DeleteRows(table, _ids(json['ids'])),
    'restore' => RestoreRows(table, _rows(json['rows'])),
    'fields' => RestoreFields(
        table,
        _id(json['id']),
        before: _row(json['before']),
        after: _row(json['after']),
      ),
    _ => throw FormatException('op $op'),
  };
}

UndoTable _table(Object? name) {
  for (final t in UndoTable.values) {
    if (t.name == name) return t;
  }
  throw FormatException('table $name');
}

int _id(Object? v) => v is int ? v : throw const FormatException('id');

List<int> _ids(Object? v) {
  if (v is! List || v.isEmpty) throw const FormatException('ids');
  return [for (final id in v) _id(id)];
}

Map<String, Object?> _row(Object? v) {
  if (v is! Map || v.isEmpty) throw const FormatException('row');
  final row = <String, Object?>{};
  for (final MapEntry(:key, :value) in v.entries) {
    if (key is! String || !_isScalar(value)) {
      throw FormatException('column $key');
    }
    row[key] = value;
  }
  return row;
}

List<Map<String, Object?>> _rows(Object? v) {
  if (v is! List || v.isEmpty) throw const FormatException('rows');
  return [for (final r in v) _row(r)];
}

bool _isScalar(Object? v) => v == null || v is num || v is String || v is bool;
