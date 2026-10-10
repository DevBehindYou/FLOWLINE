import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/people_repository_impl.dart';
import 'package:atomic_assist/data/repositories/reminder_repository_impl.dart';
import 'package:atomic_assist/design/atomic.dart';
import 'package:atomic_assist/domain/entities/person.dart';
import 'package:atomic_assist/domain/entities/reminder.dart';
import 'package:atomic_assist/features/people/view/people_screen.dart';
import 'package:atomic_assist/features/people/view/person_screen.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_app.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late PeopleRepositoryImpl people;
  setUp(() {
    db = createTestDatabase();
    people = PeopleRepositoryImpl(db);
  });
  tearDown(() => db.close());

  test('names are one person whatever the case', () async {
    await people.createPerson('Priya');
    expect((await people.findExact('PRIYA'))!.name, 'Priya');
    await expectLater(people.createPerson('priya'), throwsA(isA<Exception>()));
  });

  test('a person deleted takes their dates and follow-ups with them', () async {
    final id = await people.createPerson('Ravi');
    await people.addDate(
        personId: id, kind: PersonDateKind.birthday, month: 1, day: 2);
    await people.createFollowUp(
        personId: id, about: 'x', waitUntil: DateTime(2026, 10, 9));
    await (db.delete(db.people)..where((p) => p.id.equals(id))).go();
    expect(await db.select(db.personDates).get(), isEmpty);
    expect(await db.select(db.followUps).get(), isEmpty);
  });

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 5)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets('People lists everyone', (tester) async {
    await tester.runAsync(() async {
      await people.createPerson('Zoe');
      await people.createPerson('asha', relation: 'sister');
    });
    await pumpScreen(tester, db: db, child: const PeopleScreen());
    expect(find.text('asha'), findsOneWidget);
    expect(find.text('sister'), findsOneWidget);
    expect(find.text('Zoe'), findsOneWidget);
  });

  testWidgets('a person: next date with age, and Replied closes a follow-up',
      (tester) async {
    final today = clock.now();
    final soon = DateTime(today.year, today.month, today.day + 3);
    final ids = (await tester.runAsync(() async {
      final id = await people.createPerson('Priya');
      await people.addDate(
          personId: id,
          kind: PersonDateKind.birthday,
          month: soon.month,
          day: soon.day,
          year: soon.year - 30);
      final rid = await ReminderRepositoryImpl(db).create(
          title: 'Priya · deck',
          fireAt: today.add(const Duration(hours: 5)),
          kind: ReminderKind.followUp);
      final fid = await people.createFollowUp(
          personId: id,
          about: 'the deck',
          waitUntil: today.add(const Duration(hours: 5)),
          reminderId: rid);
      return (id: id, fid: fid, rid: rid);
    }))!;
    await pumpScreen(tester, db: db, child: PersonScreen(personId: ids.id));
    await settle(tester);
    expect(find.text('In 3 days · turns 30'), findsOneWidget);
    expect(find.text('the deck'), findsOneWidget);

    await tester.tap(find.widgetWithText(AtomicButton, 'Replied'));
    await settle(tester);
    expect(find.text('the deck'), findsNothing);
    expect(find.text('No open follow-ups.'), findsOneWidget);
    expect((await tester.runAsync(() => people.getFollowUp(ids.fid)))!.status,
        FollowUpStatus.replied);
    expect(
        (await tester.runAsync(() => ReminderRepositoryImpl(db).get(ids.rid)))!
            .status,
        ReminderStatus.done);
  });
}
