import '../../domain/assistant/action_preview.dart';
import '../../domain/assistant/autonomy.dart';
import '../../domain/assistant/ledger.dart';
import '../../domain/assistant/tool.dart';
import '../../domain/entities/checklist.dart';
import 'args.dart';
import 'checks.dart';

// Lists (docs/05 §17). A list is named by its name, ignoring case; an
// unknown name is not created silently: the model is told the lists
// that exist and asks.

const _listName = {
  'type': 'string',
  'maxLength': 60,
  'description': 'The list name, e.g. Shopping.',
};

Future<Resolved<Checklist>> _resolveList(ToolEnv env, String name) async {
  final list = await env.lists.findByName(name);
  if (list != null) return Found(list);
  final names = [for (final l in await env.lists.getLists()) l.name];
  return NotResolved(
      Invalid(InvalidReason.notFound, 'lists: ${names.join(', ')}'));
}

Checklist _found(Resolved<Checklist> r) => switch (r) {
      Found(:final value) => value,
      NotResolved(:final invalid) => throw StateError('$invalid'),
    };

final class ListItemsTool extends AssistantTool<String> {
  const ListItemsTool();

  @override
  String get name => 'list_items';
  @override
  String get description => 'The items on a list, open ones first.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {'list': _listName},
        'required': ['list'],
      };
  @override
  ActionRisk get risk => ActionRisk.read;

  @override
  String parse(Map<String, Object?> json) =>
      requireString(json, 'list', maxLength: 60);

  @override
  Future<ToolValidation> validate(String list, ToolEnv env) async =>
      switch (await _resolveList(env, list)) {
        Found() => const Valid(),
        NotResolved(:final invalid) => invalid,
      };

  @override
  Future<ActionPreview> preview(String list, ToolEnv env) async =>
      const ReadPreview(ReadKind.list);

  @override
  Future<ToolOutcome> run(String list, ToolEnv env) async {
    final l = _found(await _resolveList(env, list));
    final items = await env.lists.getItems(l.id);
    return ToolOutcome(result: {
      'list': l.name,
      'items': [
        for (final i in items.take(50))
          {'id': i.id, 'text': i.text, 'checked': i.checked},
      ],
    });
  }
}

typedef AddItemsArgs = ({String list, List<String> items});

final class AddListItemsTool extends AssistantTool<AddItemsArgs> {
  const AddListItemsTool();

  @override
  String get name => 'add_list_items';
  @override
  String get description =>
      'Adds items to a list. Items already on it (unchecked) are skipped.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {
          'list': _listName,
          'items': {
            'type': 'array',
            'items': {'type': 'string', 'maxLength': 200},
            'minItems': 1,
            'maxItems': 30,
          },
        },
        'required': ['list', 'items'],
      };
  @override
  ActionRisk get risk => ActionRisk.reversible;

  @override
  AddItemsArgs parse(Map<String, Object?> json) => (
        list: requireString(json, 'list', maxLength: 60),
        items: requireStringList(json, 'items', minItems: 1, maxItems: 30),
      );

  /// What would actually be added: not already open on the list, and
  /// each once (ignoring case).
  Future<List<String>> _new(
      Checklist list, List<String> items, ToolEnv env) async {
    final open = {
      for (final i in await env.lists.getItems(list.id))
        if (!i.checked) i.text.toLowerCase(),
    };
    final out = <String>[];
    for (final item in items) {
      if (open.add(item.toLowerCase())) out.add(item);
    }
    return out;
  }

  @override
  Future<ToolValidation> validate(AddItemsArgs a, ToolEnv env) async {
    final resolved = await _resolveList(env, a.list);
    if (resolved case NotResolved(:final invalid)) return invalid;
    if ((await _new(_found(resolved), a.items, env)).isEmpty) {
      return const Invalid(
          InvalidReason.nothingToChange, 'already on the list');
    }
    return const Valid();
  }

  @override
  Future<ActionPreview> preview(AddItemsArgs a, ToolEnv env) async {
    final list = _found(await _resolveList(env, a.list));
    return AddListItemsPreview(
        list: list.name, items: await _new(list, a.items, env));
  }

  @override
  Future<ToolOutcome> run(AddItemsArgs a, ToolEnv env) async {
    final list = _found(await _resolveList(env, a.list));
    final added = await _new(list, a.items, env);
    final ids = await env.lists.addItems(list.id, added, at: env.now);
    return ToolOutcome(
      result: {'list': list.name, 'added': added},
      undo: DeleteRows(UndoTable.listItems, ids),
    );
  }
}

typedef CheckArgs = ({int itemId, bool checked});

final class CheckListItemTool extends AssistantTool<CheckArgs> {
  const CheckListItemTool();

  @override
  String get name => 'check_list_item';
  @override
  String get description => 'Ticks (or unticks) one list item.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {
          'item_id': {'type': 'integer'},
          'checked': {'type': 'boolean'},
        },
        'required': ['item_id'],
      };
  @override
  ActionRisk get risk => ActionRisk.reversible;

  @override
  CheckArgs parse(Map<String, Object?> json) {
    final checked = json['checked'];
    if (checked != null && checked is! bool) {
      throw const ToolArgumentError('checked', 'must be a boolean');
    }
    return (
      itemId: requireInt(json, 'item_id', min: 1, max: 1 << 52),
      checked: checked != false,
    );
  }

  @override
  Future<ToolValidation> validate(CheckArgs a, ToolEnv env) async {
    final item = await env.lists.getItem(a.itemId);
    if (item == null) {
      return Invalid(InvalidReason.notFound, 'item_id ${a.itemId}');
    }
    if (item.checked == a.checked) {
      return const Invalid(InvalidReason.nothingToChange);
    }
    return const Valid();
  }

  @override
  Future<ActionPreview> preview(CheckArgs a, ToolEnv env) async {
    final item = (await env.lists.getItem(a.itemId))!;
    final list = await env.lists.getList(item.listId);
    return CheckListItemPreview(
        list: list?.name ?? '', text: item.text, checked: a.checked);
  }

  @override
  Future<ToolOutcome> run(CheckArgs a, ToolEnv env) async {
    final before = await mustRow(env, UndoTable.listItems, a.itemId);
    await env.lists.setChecked(a.itemId, a.checked, at: env.now);
    final after = await mustRow(env, UndoTable.listItems, a.itemId);
    return ToolOutcome(
      result: {'item_id': a.itemId, 'checked': a.checked},
      undo: fieldsUndo(UndoTable.listItems, a.itemId, before, after),
    );
  }
}

final class ClearCheckedTool extends AssistantTool<String> {
  const ClearCheckedTool();

  @override
  String get name => 'clear_checked';
  @override
  String get description =>
      'Removes the ticked items from a list. Always confirmed by the user.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {'list': _listName},
        'required': ['list'],
      };
  @override
  ActionRisk get risk => ActionRisk.destructive;

  @override
  String parse(Map<String, Object?> json) =>
      requireString(json, 'list', maxLength: 60);

  Future<List<ChecklistItem>> _checked(Checklist l, ToolEnv env) async => [
        for (final i in await env.lists.getItems(l.id))
          if (i.checked) i
      ];

  @override
  Future<ToolValidation> validate(String list, ToolEnv env) async {
    final resolved = await _resolveList(env, list);
    if (resolved case NotResolved(:final invalid)) return invalid;
    if ((await _checked(_found(resolved), env)).isEmpty) {
      return const Invalid(InvalidReason.nothingToChange, 'nothing ticked');
    }
    return const Valid();
  }

  @override
  Future<ActionPreview> preview(String list, ToolEnv env) async {
    final l = _found(await _resolveList(env, list));
    final checked = await _checked(l, env);
    return DeletePreview(
        kind: DeleteKind.checkedItems,
        titles: [l.name],
        subtaskCount: checked.length);
  }

  @override
  Future<ToolOutcome> run(String list, ToolEnv env) async {
    final l = _found(await _resolveList(env, list));
    final rows =
        await env.storedRowsWhere(UndoTable.listItems, 'list_id', l.id);
    final checked = [
      for (final r in rows)
        if (r['checked'] == 1) r
    ];
    await env.lists.clearChecked(l.id);
    return ToolOutcome(
      result: {'list': l.name, 'removed': checked.length},
      undo: RestoreRows(UndoTable.listItems, checked),
    );
  }
}
