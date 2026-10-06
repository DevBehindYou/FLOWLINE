import '../entities/person.dart';

abstract interface class PeopleRepository {
  Stream<List<Person>> watchPeople();
  Future<Person?> getPerson(int id);

  /// Exact name, ignoring case.
  Future<Person?> findExact(String name);

  /// Names containing [query], ignoring case, at most [limit].
  Future<List<Person>> search(String query, {int limit = 10});
  Future<int> createPerson(String name, {String? relation});

  Stream<List<PersonDate>> watchDates(int personId);
  Future<List<PersonDate>> getDates(int personId);
  Future<List<PersonDate>> getAllDates();
  Future<int> addDate({
    required int personId,
    required PersonDateKind kind,
    required int month,
    required int day,
    int? year,
    String? label,
  });

  Stream<List<FollowUp>> watchFollowUps(int personId);
  Future<List<FollowUp>> getOpenFollowUps({int limit = 50});
  Future<FollowUp?> getFollowUp(int id);
  Future<int> createFollowUp({
    required int personId,
    required String about,
    required DateTime waitUntil,
    int? reminderId,
  });
  Future<void> setFollowUpStatus(int id, FollowUpStatus status);
}
