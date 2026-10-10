import 'package:atomic_assist/core/providers.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/reminder_repository_impl.dart';
import 'package:atomic_assist/design/atomic.dart';
import 'package:atomic_assist/domain/entities/reminder.dart';
import 'package:atomic_assist/features/reminders/view/reminders_screen.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_app.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late ReminderRepositoryImpl reminders;
  setUp(() {
    db = createTestDatabase();
    reminders = ReminderRepositoryImpl(db);
  });
  tearDown(() => db.close());

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 5)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets('empty: tells you how to set one', (tester) async {
    await pumpScreen(tester, db: db, child: const RemindersScreen());
    expect(find.text('No reminders'), findsOneWidget);
  });

  testWidgets('Done goes through the tool and leaves the list', (tester) async {
    final id = (await tester.runAsync(() => reminders.create(
        title: 'Call Mum',
        fireAt: clock.now().add(const Duration(hours: 2)))))!;
    await pumpScreen(tester,
        db: db,
        child: const RemindersScreen(),
        // No alerts in tests: the sync's notification service never
        // resolves, so nothing reaches the plugin.
        extraOverrides: [
          notificationServiceProvider
              .overrideWith((ref) => Future.error('off')),
        ]);
    expect(find.text('Call Mum'), findsOneWidget);
    await tester.tap(find.widgetWithText(AtomicButton, 'Done'));
    await settle(tester);
    expect(find.text('Call Mum'), findsNothing);
    expect((await tester.runAsync(() => reminders.get(id)))!.status,
        ReminderStatus.done);
    final logged =
        await tester.runAsync(() => db.select(db.assistantActions).get());
    expect(logged!.single.toolName, 'complete_reminder');
  });
}
