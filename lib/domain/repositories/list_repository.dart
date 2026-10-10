import '../entities/checklist.dart';

abstract interface class ListRepository {
  /// Not archived, in creation order, with item counts.
  Stream<List<Checklist>> watchLists();

  /// By name, ignoring case; null when there's no such list.
  Future<Checklist?> findByName(String name);
  Future<Checklist?> getList(int id);
  Future<List<Checklist>> getLists();

  /// Unchecked first (in order), then checked.
  Stream<List<ChecklistItem>> watchItems(int listId);
  Future<List<ChecklistItem>> getItems(int listId);
  Future<ChecklistItem?> getItem(int id);

  /// Appends [texts] after the list's last item; returns their ids.
  Future<List<int>> addItems(int listId, List<String> texts,
      {required DateTime at});

  Future<void> setChecked(int itemId, bool checked, {required DateTime at});

  /// Deletes the checked items; returns how many went.
  Future<int> clearChecked(int listId);
}
