import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../assistant/assistant_providers.dart';
import '../../../assistant/direct_action.dart';
import '../../../core/providers.dart';
import '../../../data/assistant/tool_executor.dart';
import '../../../domain/entities/checklist.dart';

part 'lists_view_model.g.dart';

@riverpod
Stream<List<Checklist>> checklists(Ref ref) =>
    ref.watch(listRepositoryProvider).watchLists();

@riverpod
Stream<List<ChecklistItem>> checklistItems(Ref ref, int listId) =>
    ref.watch(listRepositoryProvider).watchItems(listId);

// keepAlive (R11): uses ref after awaits.
@Riverpod(keepAlive: true)
class ListsActions extends _$ListsActions {
  @override
  void build() {}

  Future<ExecutionResult> _run(String tool, Map<String, Object?> args) =>
      runDirectAction(
        registry: ref.read(toolRegistryProvider),
        executor: ref.read(toolExecutorProvider),
        tool: tool,
        args: args,
      );

  Future<ExecutionResult> add(String list, String text) =>
      _run('add_list_items', {
        'list': list,
        'items': [text]
      });

  Future<ExecutionResult> setChecked(int itemId, bool checked) =>
      _run('check_list_item', {'item_id': itemId, 'checked': checked});

  /// Destructive: the screen confirms first.
  Future<ExecutionResult> clearChecked(String list) =>
      _run('clear_checked', {'list': list});
}
