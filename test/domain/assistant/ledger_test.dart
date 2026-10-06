import 'package:atomic_assist/domain/assistant/autonomy.dart';
import 'package:atomic_assist/domain/assistant/ledger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('undo recipe JSON', () {
    UndoRecipe roundTrip(UndoRecipe r) =>
        decodeUndoRecipe(encodeUndoRecipe(r))!;

    test('DeleteRows round-trips', () {
      final r =
          roundTrip(const DeleteRows(UndoTable.tasks, [3, 4])) as DeleteRows;
      expect(r.table, UndoTable.tasks);
      expect(r.ids, [3, 4]);
    });

    test('RestoreRows keeps every column value, null included', () {
      const row = {
        'id': 7,
        'title': 'Send deck, "v2"',
        'notes': '',
        'due_at': null,
        'is_locked': false,
        'score': 1.5,
      };
      final r = roundTrip(const RestoreRows(UndoTable.scheduleBlocks, [row]))
          as RestoreRows;
      expect(r.table, UndoTable.scheduleBlocks);
      expect(r.rows, [row]);
    });

    test('RestoreFields keeps before and after', () {
      final r = roundTrip(const RestoreFields(UndoTable.tasks, 9,
          before: {'status': 0}, after: {'status': 2})) as RestoreFields;
      expect(r.id, 9);
      expect(r.before, {'status': 0});
      expect(r.after, {'status': 2});
    });

    test('UndoAll keeps its steps in order, nested', () {
      final r = roundTrip(const UndoAll([
        DeleteRows(UndoTable.scheduleBlocks, [1]),
        UndoAll([
          RestoreFields(UndoTable.tasks, 2,
              before: {'schedule_block_id': null},
              after: {'schedule_block_id': 1}),
        ]),
      ])) as UndoAll;
      expect(r.steps, hasLength(2));
      expect(r.steps.first, isA<DeleteRows>());
      final inner = r.steps.last as UndoAll;
      expect((inner.steps.single as RestoreFields).id, 2);
    });

    test('StopFocus round-trips', () {
      expect((roundTrip(const StopFocus(12)) as StopFocus).sessionId, 12);
    });

    test('every table name survives the trip', () {
      for (final t in UndoTable.values) {
        expect((roundTrip(DeleteRows(t, const [1])) as DeleteRows).table, t);
      }
    });
  });

  group('decodeUndoRecipe never throws on bad input', () {
    const bad = <String, String?>{
      'null': null,
      'not JSON': 'undo me',
      'not an object': '[1, 2]',
      'no op': '{"table": "tasks", "ids": [1]}',
      'unknown op': '{"op": "drop", "table": "tasks", "ids": [1]}',
      'unknown table': '{"op": "delete", "table": "payments", "ids": [1]}',
      'missing table': '{"op": "delete", "ids": [1]}',
      'empty ids': '{"op": "delete", "table": "tasks", "ids": []}',
      'string id': '{"op": "delete", "table": "tasks", "ids": ["1"]}',
      'fractional id': '{"op": "delete", "table": "tasks", "ids": [1.5]}',
      'empty rows': '{"op": "restore", "table": "tasks", "rows": []}',
      'row not an object': '{"op": "restore", "table": "tasks", "rows": [1]}',
      'nested column value':
          '{"op": "restore", "table": "tasks", "rows": [{"id": {"x": 1}}]}',
      'list column value':
          '{"op": "restore", "table": "tasks", "rows": [{"id": [1]}]}',
      'fields without after':
          '{"op": "fields", "table": "tasks", "id": 1, "before": {"a": 1}}',
      'fields with empty before': '{"op": "fields", "table": "tasks", '
          '"id": 1, "before": {}, "after": {"a": 1}}',
      'empty steps': '{"op": "all", "steps": []}',
      'stopFocus without id': '{"op": "stopFocus"}',
      'one bad step': '{"op": "all", "steps": ['
          '{"op": "delete", "table": "tasks", "ids": [1]}, {"op": "?"}]}',
    };
    for (final MapEntry(:key, :value) in bad.entries) {
      test(key, () => expect(decodeUndoRecipe(value), isNull));
    }
  });

  group('LedgerEntry.canUndo', () {
    LedgerEntry entry(LedgerStatus status, UndoRecipe? undo) => LedgerEntry(
          id: 1,
          at: DateTime(2026, 10, 5, 9),
          groupId: 'g1',
          toolName: 'create_task',
          argsJson: '{}',
          origin: ActionOrigin.said,
          decision: Decision.executeWithUndo,
          status: status,
          undo: undo,
        );
    const recipe = DeleteRows(UndoTable.tasks, [1]);

    test('only a done entry with a recipe', () {
      expect(entry(LedgerStatus.done, recipe).canUndo, isTrue);
      expect(entry(LedgerStatus.done, null).canUndo, isFalse);
      expect(entry(LedgerStatus.undone, recipe).canUndo, isFalse);
      expect(entry(LedgerStatus.failed, recipe).canUndo, isFalse);
      expect(entry(LedgerStatus.handedOff, recipe).canUndo, isFalse);
    });
  });

  test('stored enums keep their indexes (R1: append-only)', () {
    expect(LedgerStatus.values.map((e) => e.name),
        ['done', 'undone', 'failed', 'handedOff']);
  });
}
