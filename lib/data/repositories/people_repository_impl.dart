import 'package:drift/drift.dart';

import '../../domain/entities/person.dart';
import '../../domain/repositories/people_repository.dart';
import '../local/drift/app_database.dart';

class PeopleRepositoryImpl implements PeopleRepository {
  PeopleRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Person>> watchPeople() => (_db.select(_db.people)
        ..orderBy([(p) => OrderingTerm.asc(p.name.collate(Collate.noCase))]))
      .watch()
      .map((rows) => rows.map(_person).toList());

  @override
  Future<Person?> getPerson(int id) async {
    final row = await (_db.select(_db.people)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _person(row);
  }

  @override
  Future<Person?> findExact(String name) async {
    final rows = await _db.customSelect(
      'SELECT * FROM people WHERE name = ? COLLATE NOCASE',
      variables: [Variable.withString(name.trim())],
      readsFrom: {_db.people},
    ).get();
    return rows.isEmpty ? null : _person(_db.people.map(rows.first.data));
  }

  @override
  Future<List<Person>> search(String query, {int limit = 10}) async {
    final needle = query.trim().toLowerCase();
    final rows = await (_db.select(_db.people)
          ..where((p) => FunctionCallExpression<int>(
              'instr', [p.name.lower(), Variable(needle)]).isBiggerThanValue(0))
          ..orderBy([(p) => OrderingTerm.asc(p.id)])
          ..limit(limit))
        .get();
    return rows.map(_person).toList();
  }

  @override
  Future<int> createPerson(String name, {String? relation}) =>
      _db.into(_db.people).insert(
          PeopleCompanion.insert(name: name.trim(), relation: Value(relation)));

  SimpleSelectStatement<$PersonDatesTable, PersonDateRow> _dates(
          int personId) =>
      _db.select(_db.personDates)
        ..where((d) => d.personId.equals(personId))
        ..orderBy(
            [(d) => OrderingTerm.asc(d.month), (d) => OrderingTerm.asc(d.day)]);

  @override
  Stream<List<PersonDate>> watchDates(int personId) =>
      _dates(personId).watch().map((rows) => rows.map(_date).toList());

  @override
  Future<List<PersonDate>> getDates(int personId) async =>
      (await _dates(personId).get()).map(_date).toList();

  @override
  Future<List<PersonDate>> getAllDates() async =>
      (await _db.select(_db.personDates).get()).map(_date).toList();

  @override
  Future<int> addDate({
    required int personId,
    required PersonDateKind kind,
    required int month,
    required int day,
    int? year,
    String? label,
  }) =>
      _db.into(_db.personDates).insert(PersonDatesCompanion.insert(
            personId: personId,
            kind: kind,
            month: month,
            day: day,
            year: Value(year),
            label: Value(label),
          ));

  @override
  Stream<List<FollowUp>> watchFollowUps(int personId) =>
      (_db.select(_db.followUps)
            ..where((f) => f.personId.equals(personId))
            ..orderBy([(f) => OrderingTerm.asc(f.waitUntil)]))
          .watch()
          .map((rows) => rows.map(_followUp).toList());

  @override
  Future<List<FollowUp>> getOpenFollowUps({int limit = 50}) async =>
      (await (_db.select(_db.followUps)
                ..where((f) => f.status.equalsValue(FollowUpStatus.open))
                ..orderBy([(f) => OrderingTerm.asc(f.waitUntil)])
                ..limit(limit))
              .get())
          .map(_followUp)
          .toList();

  @override
  Future<FollowUp?> getFollowUp(int id) async {
    final row = await (_db.select(_db.followUps)..where((f) => f.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _followUp(row);
  }

  @override
  Future<int> createFollowUp({
    required int personId,
    required String about,
    required DateTime waitUntil,
    int? reminderId,
  }) =>
      _db.into(_db.followUps).insert(FollowUpsCompanion.insert(
            personId: personId,
            about: about,
            waitUntil: waitUntil,
            status: FollowUpStatus.open,
            reminderId: Value(reminderId),
          ));

  @override
  Future<void> setFollowUpStatus(int id, FollowUpStatus status) =>
      (_db.update(_db.followUps)..where((f) => f.id.equals(id)))
          .write(FollowUpsCompanion(status: Value(status)));

  Person _person(PersonRow r) =>
      Person(id: r.id, name: r.name, relation: r.relation);

  PersonDate _date(PersonDateRow r) => PersonDate(
        id: r.id,
        personId: r.personId,
        kind: r.kind,
        month: r.month,
        day: r.day,
        year: r.year,
        label: r.label,
      );

  FollowUp _followUp(FollowUpRow r) => FollowUp(
        id: r.id,
        personId: r.personId,
        about: r.about,
        waitUntil: r.waitUntil,
        status: r.status,
        reminderId: r.reminderId,
      );
}
