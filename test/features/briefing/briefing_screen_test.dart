import 'package:atomic_assist/assistant/briefing_schedule.dart';
import 'package:atomic_assist/core/notifications/notification_service.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/task_repository_impl.dart';
import 'package:atomic_assist/design/atomic.dart';
import 'package:atomic_assist/domain/assistant/briefing.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:atomic_assist/domain/time/calendar_day.dart';
import 'package:atomic_assist/features/briefing/view/briefing_screen.dart';
import 'package:atomic_assist/features/voice/viewmodel/voice_controller.dart';
import 'package:atomic_assist/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_voice.dart';
import '../../support/pump_app.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 5)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets('shutdown: move unfinished to tomorrow, one UNDO puts it back',
      (tester) async {
    final day = today();
    // Due earlier today: unfinished at any time of day.
    final due = DateTime(day.year, day.month, day.day, 0, 1);
    final id = (await tester.runAsync(() => TaskRepositoryImpl(db).createTask(
        title: 'Send invoice', priority: TaskPriority.high, dueAt: due)))!;
    await pumpScreen(tester,
        db: db, child: const BriefingScreen(kind: BriefingKind.shutdown));
    await settle(tester);
    expect(find.textContaining('Send invoice'), findsOneWidget);

    await tester
        .tap(find.widgetWithText(AtomicButton, 'Move unfinished to tomorrow'));
    await settle(tester);
    Future<DateTime?> dueNow() async =>
        (await tester.runAsync(() => TaskRepositoryImpl(db).getTask(id)))!
            .dueAt;
    final next = addDays(day, 1);
    expect(await dueNow(), DateTime(next.year, next.month, next.day, 0, 1));
    expect(find.text('Moved 1 task to tomorrow'), findsOneWidget);
    expect(
        (await tester.runAsync(() => db.select(db.assistantActions).get()))!
            .map((a) => a.toolName),
        ['update_task']);

    await tester.tap(find.text('Undo'));
    await settle(tester);
    expect(await dueNow(), due);
  });

  testWidgets('READ ALOUD speaks what the screen shows', (tester) async {
    final tts = FakeTts();
    await pumpScreen(tester,
        db: db,
        child: const BriefingScreen(kind: BriefingKind.morning),
        extraOverrides: [textToSpeechProvider.overrideWithValue(tts)]);
    await settle(tester);
    expect(find.text('A clear day. Nothing due.'), findsOneWidget);
    await tester.tap(find.widgetWithText(AtomicButton, 'Read aloud'));
    await settle(tester);
    expect(tts.spoken.single, startsWith('A clear day. Nothing due.'));
  });

  test('briefing notifications: both scheduled, or both cancelled', () async {
    final service = _RecordingNotifications();
    final l10n = lookupAppLocalizations(const Locale('en'));
    await syncBriefingNotifications(service, enabled: true, l10n: l10n);
    expect(service.scheduled, [
      ('morning', 7, 30, 'Your morning briefing'),
      ('shutdown', 18, 30, 'Time to wrap up the day'),
    ]);
    await syncBriefingNotifications(service, enabled: false, l10n: l10n);
    expect(service.cancelled, [2001, 2002]);
  });
}

final class _RecordingNotifications implements NotificationService {
  final scheduled = <(String, int, int, String)>[];
  final cancelled = <int>[];

  @override
  Future<void> scheduleDailyBriefing({
    required int notificationId,
    required String kind,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String channelName,
    required String channelDescription,
  }) async =>
      scheduled.add((kind, hour, minute, title));

  @override
  Future<void> cancel(int notificationId) async =>
      cancelled.add(notificationId);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
