import 'package:clock/clock.dart';
import 'package:drift/drift.dart';

import '../../domain/assistant/ledger.dart';
import '../../domain/assistant/tool.dart';
import '../../domain/repositories/focus_session_repository.dart';
import '../local/drift/app_database.dart';
import 'stored_rows.dart';
import 'tool_executor.dart';

/// The result of an undo (docs/05 §9.4), worded by l10n.
enum UndoResult {
  /// Everything in the turn was put back.
  undone,

  /// Nothing left to undo (already undone, or nothing undoable).
  nothing,

  /// The user changed something since; nothing was undone ("Changed
  /// since. Not undone.").
  changedSince,
}

final class _ChangedSince implements Exception {
  const _ChangedSince();
}

/// Applies undo recipes from the ledger. One turn is undone as a whole,
/// in one transaction, newest action first; if any step finds that the
/// user changed the data since, the whole undo rolls back.
final class UndoService {
  UndoService({
    required AppDatabase db,
    required FocusSessionRepository focus,
    AfterCommitHandler effects = const NoAfterCommit(),
  })  : _db = db,
        _rows = StoredRows(db),
        _focus = focus,
        _effects = effects;

  final AppDatabase _db;
  final StoredRows _rows;
  final FocusSessionRepository _focus;
  final AfterCommitHandler _effects;

  /// Undoes every action of one turn.
  Future<UndoResult> undoGroup(String groupId) =>
      _undo((a) => a.groupId.equals(groupId));

  /// Undoes one action.
  Future<UndoResult> undoEntry(int id) => _undo((a) => a.id.equals(id));

  Future<UndoResult> _undo(
      Expression<bool> Function($AssistantActionsTable) filter) async {
    final effects = <AfterCommit>[];
    final UndoResult result;
    try {
      result = await _db.transaction(() async {
        final rows = await (_db.select(_db.assistantActions)
              ..where(
                  (a) => filter(a) & a.status.equalsValue(LedgerStatus.done))
              ..orderBy([(a) => OrderingTerm.desc(a.id)]))
            .get();
        final recipes = [
          for (final r in rows)
            if (decodeUndoRecipe(r.undoJson) case final recipe?)
              (id: r.id, recipe: recipe),
        ];
        // A turn with an action that can't be undone isn't undone in
        // part: that would leave a half-reverted state behind.
        if (recipes.isEmpty || recipes.length != rows.length) {
          return UndoResult.nothing;
        }
        for (final r in recipes) {
          await _apply(r.recipe, effects);
        }
        await (_db.update(_db.assistantActions)
              ..where((a) => a.id.isIn([for (final r in recipes) r.id])))
            .write(const AssistantActionsCompanion(
                status: Value(LedgerStatus.undone)));
        return UndoResult.undone;
      });
    } on _ChangedSince {
      return UndoResult.changedSince;
    }
    for (final e in effects) {
      try {
        await _effects.handle(e);
      } on Object {
        // The data is back; a stale alert is the lesser problem.
      }
    }
    return result;
  }

  Future<void> _apply(UndoRecipe recipe, List<AfterCommit> effects) async {
    switch (recipe) {
      case DeleteRows(:final table, :final ids):
        await _rows.deleteIds(table, ids);
        _touched(table, ids, effects);
      case RestoreRows(:final table, :final rows):
        for (final row in rows) {
          final id = row['id'];
          if (id is int && await _rows.row(table, id) != null) {
            throw const _ChangedSince(); // something took its place
          }
          try {
            await _rows.insert(table, row);
          } on Exception {
            // A constraint fails: what it pointed at is gone since.
            throw const _ChangedSince();
          }
          if (id is int) _touched(table, [id], effects);
        }
      case RestoreFields(:final table, :final id, :final before, :final after):
        _rows.checkColumns(table, [...before.keys, ...after.keys]);
        final current = await _rows.row(table, id);
        if (current == null) throw const _ChangedSince();
        for (final MapEntry(:key, :value) in after.entries) {
          if (!_same(current[key], value)) throw const _ChangedSince();
        }
        await _rows.update(table, id, before);
        _touched(table, [id], effects);
      case StopFocus(:final sessionId):
        final session = await _focus.getSession(sessionId);
        if (session == null || session.completedAt != null) {
          throw const _ChangedSince();
        }
        final ran = clock.now().difference(session.startedAt);
        if (ran < const Duration(minutes: 1)) {
          await _rows.deleteIds(UndoTable.focusSessions, [sessionId]);
        } else {
          await _focus.completeSession(sessionId, endedEarly: true);
        }
        effects.add(FocusStopped(sessionId));
      case UndoAll(:final steps):
        for (final step in steps.reversed) {
          await _apply(step, effects);
        }
    }
  }

  /// A reminder changed by undo needs its notification brought in line.
  static void _touched(
      UndoTable table, List<int> ids, List<AfterCommit> effects) {
    if (table != UndoTable.reminders) return;
    for (final id in ids) {
      effects.add(ReminderTouched(id));
    }
  }

  /// Stored values compare as SQLite returns them: booleans as 0/1.
  static bool _same(Object? stored, Object? expected) {
    if (expected is bool) return stored == (expected ? 1 : 0);
    if (stored is num && expected is num) return stored == expected;
    return stored == expected;
  }
}
