import 'package:atomic_assist/assistant/orchestrator.dart';
import 'package:atomic_assist/assistant/reminder_sync.dart';
import 'package:atomic_assist/assistant/tools/tool_registry.dart';
import 'package:atomic_assist/core/notifications/notification_service.dart';
import 'package:atomic_assist/data/assistant/drift_tool_env.dart';
import 'package:atomic_assist/data/assistant/stored_rows.dart';
import 'package:atomic_assist/data/assistant/tool_executor.dart';
import 'package:atomic_assist/data/assistant/undo_service.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/app_settings_repository_impl.dart';
import 'package:atomic_assist/data/repositories/assistant_repository_impl.dart';
import 'package:atomic_assist/data/repositories/focus_session_repository_impl.dart';
import 'package:atomic_assist/data/repositories/list_repository_impl.dart';
import 'package:atomic_assist/data/repositories/reminder_repository_impl.dart';
import 'package:atomic_assist/data/repositories/schedule_repository_impl.dart';
import 'package:atomic_assist/data/repositories/task_repository_impl.dart';
import 'package:atomic_assist/domain/assistant/autonomy.dart';
import 'package:atomic_assist/domain/assistant/utterance.dart';
import 'package:atomic_assist/domain/entities/reminder.dart';
import 'package:atomic_assist/domain/repositories/ai_repository.dart';
import 'package:atomic_assist/domain/services/reminder_actions.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_database.dart';

void main() {
  // Monday 2026-10-05, 16:40.
  final now = DateTime(2026, 10, 5, 16, 40);

  Reminder reminder(
          {ReminderStatus status = ReminderStatus.scheduled, DateTime? at}) =>
      Reminder(
          id: 7,
          title: 'Call Mum',
          fireAt: at ?? DateTime(2026, 10, 5, 19),
          status: status);

  group('notification buttons map to tool calls', () {
    test('done', () {
      final call = reminderActionCall(ReminderAction.done, reminder(), now)!;
      expect(call.tool, 'complete_reminder');
      expect(call.args, {'reminder_id': 7});
    });

    test('snooze 10 minutes from the press, whole minutes', () {
      final pressed = DateTime(2026, 10, 5, 19, 0, 42);
      final call =
          reminderActionCall(ReminderAction.snooze10, reminder(), pressed)!;
      expect(call.tool, 'snooze_reminder');
      expect(call.args, {'reminder_id': 7, 'until': '2026-10-05T19:10'});
    });

    test('tomorrow keeps the time of day, across a DST change', () {
      final r = reminder(at: DateTime(2026, 10, 31, 19));
      final pressed = DateTime(2026, 10, 31, 19, 1);
      expect(
          reminderActionCall(ReminderAction.tomorrow, r, pressed)!
              .args['until'],
          '2026-11-01T19:00');
    });

    test('a reminder already done or cancelled does nothing', () {
      for (final s in [ReminderStatus.done, ReminderStatus.cancelled]) {
        expect(
            reminderActionCall(ReminderAction.done, reminder(status: s), now),
            isNull);
      }
      // A missed one can still be dealt with.
      expect(
          reminderActionCall(
              ReminderAction.done, reminder(status: ReminderStatus.fired), now),
          isNotNull);
    });

    test('notification ids are stable and clear of the focus alert', () {
      expect(reminderNotificationId(7), reminderNotificationId(7));
      expect(reminderNotificationId(1), greaterThan(1001));
    });
  });

  group('with the database', () {
    late AppDatabase db;
    late ReminderRepositoryImpl reminders;
    late _FakeNotifications notifications;
    late ReminderSync sync;
    late ToolExecutor executor;

    setUp(() {
      db = createTestDatabase();
      reminders = ReminderRepositoryImpl(db);
      notifications = _FakeNotifications();
      sync = ReminderSync(
          reminders: reminders, notifications: () async => notifications);
      executor = ToolExecutor(
        db: db,
        env: () => DriftToolEnv(
          tasks: TaskRepositoryImpl(db),
          schedule: ScheduleRepositoryImpl(db),
          focus: FocusSessionRepositoryImpl(db),
          reminders: reminders,
          lists: ListRepositoryImpl(db),
          settings: AppSettingsRepositoryImpl(db),
          rows: StoredRows(db),
        ),
      );
    });
    tearDown(() => db.close());

    Future<T> at<T>(Future<T> Function() body, [DateTime? t]) =>
        withClock(Clock.fixed(t ?? now), body);

    test('sync schedules a future reminder, with its buttons', () async {
      final id = await reminders.create(
          title: 'Call Mum', fireAt: DateTime(2026, 10, 5, 19));
      await at(() => sync.sync(id));
      final s = notifications.scheduled.single;
      expect(s.notificationId, reminderNotificationId(id));
      expect(s.fireAt, DateTime(2026, 10, 5, 19));
      expect(s.actions.map((a) => a.id), ['done', 'snooze10', 'tomorrow']);
      expect(notifications.permissionAsked, isTrue);
    });

    test('sync cancels one that is done, gone or past', () async {
      final done =
          await reminders.create(title: 'a', fireAt: DateTime(2026, 10, 5, 19));
      await reminders.setStatus(done, ReminderStatus.done);
      final past =
          await reminders.create(title: 'b', fireAt: DateTime(2026, 10, 5, 9));
      await at(() async {
        await sync.sync(done);
        await sync.sync(past);
        await sync.sync(999);
      });
      expect(notifications.scheduled, isEmpty);
      expect(notifications.cancelled, [
        reminderNotificationId(done),
        reminderNotificationId(past),
        reminderNotificationId(999),
      ]);
    });

    test('top-up marks what fired and schedules two weeks ahead only',
        () async {
      final missed = await reminders.create(
          title: 'missed', fireAt: DateTime(2026, 10, 5, 9));
      await reminders.create(title: 'soon', fireAt: DateTime(2026, 10, 6, 9));
      await reminders.create(title: 'far', fireAt: DateTime(2026, 11, 30, 9));
      await at(() => sync.topUp());
      expect((await reminders.get(missed))!.status, ReminderStatus.fired);
      expect(notifications.scheduled.map((s) => s.title), ['soon']);
    });

    test('a button press is a logged, undoable action', () async {
      final id = await reminders.create(
          title: 'Call Mum', fireAt: DateTime(2026, 10, 5, 19));
      final touched = await at(
          () => applyReminderAction(
                actionId: 'snooze10',
                reminderId: id,
                reminders: reminders,
                registry: ToolRegistry(),
                executor: executor,
              ),
          DateTime(2026, 10, 5, 19, 0, 30));
      expect(touched, id);
      final moved = (await reminders.get(id))!;
      expect(moved.fireAt, DateTime(2026, 10, 5, 19, 10));
      expect(moved.snoozeCount, 1);
      final entry = await db.select(db.assistantActions).getSingle();
      expect(entry.toolName, 'snooze_reminder');
      expect(entry.origin, ActionOrigin.said);
      expect(
          await at(() =>
              UndoService(db: db, focus: FocusSessionRepositoryImpl(db))
                  .undoGroup(entry.groupId)),
          UndoResult.undone);
      expect((await reminders.get(id))!.fireAt, DateTime(2026, 10, 5, 19));
    });

    test('an unknown button or reminder does nothing', () async {
      expect(
          await applyReminderAction(
              actionId: 'launch',
              reminderId: 1,
              reminders: reminders,
              registry: ToolRegistry(),
              executor: executor),
          isNull);
      expect(await db.select(db.assistantActions).get(), isEmpty);
    });

    test('"remind me to call Mum at 7" sets it locally, no model', () async {
      final orchestrator = AssistantOrchestrator(
        registry: ToolRegistry(),
        ai: _NoAi(),
        executor: executor,
        store: AssistantRepositoryImpl(db),
        env: () => DriftToolEnv(
          tasks: TaskRepositoryImpl(db),
          schedule: ScheduleRepositoryImpl(db),
          focus: FocusSessionRepositoryImpl(db),
          reminders: reminders,
          lists: ListRepositoryImpl(db),
          settings: AppSettingsRepositoryImpl(db),
          rows: StoredRows(db),
          now: clock.now(),
        ),
        autonomy: () async => AutonomyPreset.balanced,
      );
      final r = await at(() => orchestrator.handle(const Utterance(
          'remind me to call Mum at 7',
          source: UtteranceSource.voice)));
      expect(r, isA<TurnAnswered>());
      final set = (await reminders.watchOpen().first).single;
      expect(set.title, 'call Mum');
      expect(set.fireAt, DateTime(2026, 10, 5, 19));
    });
  });
}

final class _NoAi implements AIRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('the local grammar should have handled this');
}

final class _FakeNotifications implements NotificationService {
  final scheduled = <({
    int notificationId,
    DateTime fireAt,
    String title,
    List<({String id, String label})> actions
  })>[];
  final cancelled = <int>[];
  bool permissionAsked = false;

  @override
  Future<void> scheduleReminder({
    required int notificationId,
    required int reminderId,
    required DateTime fireAt,
    required String title,
    required String channelName,
    required String channelDescription,
    required List<({String id, String label})> actions,
  }) async =>
      scheduled.add((
        notificationId: notificationId,
        fireAt: fireAt,
        title: title,
        actions: actions,
      ));

  @override
  Future<void> cancel(int notificationId) async =>
      cancelled.add(notificationId);

  @override
  Future<void> requestPermission() async => permissionAsked = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
