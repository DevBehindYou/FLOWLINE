// People, their dates and follow-ups (docs/05 §13.4, §15). Enums are
// stored by index, append-only (R1).

enum PersonDateKind { birthday, anniversary, other }

enum FollowUpStatus { open, replied, cancelled }

final class Person {
  const Person({required this.id, required this.name, this.relation});
  final int id;
  final String name;

  /// "sister", "client": the user's own word.
  final String? relation;
}

final class PersonDate {
  const PersonDate({
    required this.id,
    required this.personId,
    required this.kind,
    required this.month,
    required this.day,
    this.year,
    this.label,
  });

  final int id;
  final int personId;
  final PersonDateKind kind;
  final int month;
  final int day;

  /// The year it began (a birth year), when known.
  final int? year;
  final String? label;
}

final class FollowUp {
  const FollowUp({
    required this.id,
    required this.personId,
    required this.about,
    required this.waitUntil,
    required this.status,
    this.reminderId,
  });

  final int id;
  final int personId;
  final String about;

  /// When to chase if nothing was heard back.
  final DateTime waitUntil;
  final FollowUpStatus status;

  /// The reminder that fires at [waitUntil].
  final int? reminderId;
}
