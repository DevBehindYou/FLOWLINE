// Lists and their items (docs/05 §17). The enum is stored by index,
// append-only (R1).

enum ListKind { shopping, errands, packing, custom }

final class Checklist {
  const Checklist({
    required this.id,
    required this.name,
    required this.kind,
    this.openCount = 0,
    this.totalCount = 0,
  });

  final int id;
  final String name;
  final ListKind kind;

  /// Unchecked items, and all items: the card's "3 / 9".
  final int openCount;
  final int totalCount;
}

final class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.listId,
    required this.text,
    required this.checked,
    required this.position,
  });

  final int id;
  final int listId;
  final String text;
  final bool checked;
  final int position;
}
