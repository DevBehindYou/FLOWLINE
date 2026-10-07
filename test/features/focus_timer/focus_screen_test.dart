import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;
import 'package:atomic_assist/core/notifications/notification_service.dart';
import 'package:atomic_assist/core/providers.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/focus_session_repository_impl.dart';
import 'package:atomic_assist/domain/entities/focus_session.dart';
import 'package:atomic_assist/features/focus_timer/view/focus_screen.dart';
import 'package:flutter/material.dart';
import 'package:atomic_assist/design/atomic.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_app.dart';
import '../../support/test_database.dart';

class _FakeNotificationService implements NotificationService {
  // Reminder alerts (unused by these tests).
  @override
  Stream<({String action, int reminderId})> get reminderActions =>
      const Stream.empty();

  @override
  Future<void> scheduleReminder({
    required int notificationId,
    required int reminderId,
    required DateTime fireAt,
    required String title,
    required String channelName,
    required String channelDescription,
    required List<({String id, String label})> actions,
  }) async {}

  @override
  Future<void> cancel(int notificationId) async {}

  @override
  Future<void> init() async {}

  @override
  Future<void> scheduleSessionComplete({
    required DateTime fireAt,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> requestPermission() async {}

  @override
  Future<bool> launchedFromNotification() async => false;

  @override
  Stream<void> get taps => const Stream.empty();

  @override
  Future<void> cancelSessionNotification() async {}

  @override
  Stream<String> get briefingTaps => const Stream.empty();

  @override
  Future<String?> launchBriefingKind() async => null;

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
  }) async {}
}

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  final fakeNotifications = [
    notificationServiceProvider
        .overrideWith((ref) async => _FakeNotificationService()),
  ];

  // Inside testWidgets, clock.now() is FakeAsync's clock, so an anchor
  // taken from it gives exact, deterministic remaining times — as long as
  // it sits on a whole second: Drift stores date-times at second
  // precision, and FakeAsync's clock starts at the real time with a
  // random sub-second part, which made the per-second assertions flaky.
  Future<int> insertRunning(
    WidgetTester tester, {
    required int elapsedSec,
    int plannedSec = 1500,
  }) async {
    final now = clock.now();
    final fraction = now.millisecond * 1000 + now.microsecond;
    if (fraction > 0) {
      await tester.pump(Duration(microseconds: 1000000 - fraction));
    }
    final anchor = clock.now().subtract(Duration(seconds: elapsedSec));
    return db.into(db.focusSessions).insert(
          FocusSessionsCompanion.insert(
            sessionType: FocusSessionType.focus,
            plannedDurationSec: plannedSec,
            startedAt: anchor,
            segmentStartedAt: Value(anchor),
            remainingSecAtSegmentStart: plannedSec,
          ),
        );
  }

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('idle start screen with no active session (${mode.name})',
        (tester) async {
      await pumpScreen(
        tester,
        db: db,
        themeMode: mode,
        child: const FocusScreen(),
      );

      expect(find.text('Focus (25m)'), findsOneWidget);
      expect(find.text('Short (5m)'), findsOneWidget);
      expect(find.text('Long (15m)'), findsOneWidget);
      // FilledButton.icon builds a private subclass, so match by subtype.
      expect(
        find.ancestor(
          of: find.text('Start'),
          matching: find.byType(AtomicButton),
        ),
        findsOneWidget,
      );
      expect(find.text("Today's Focus"), findsOneWidget);
      expect(find.text('0m • 0 sessions'), findsOneWidget);
    });
  }

  testWidgets('idle state settles, so no per-second ticker is running',
      (tester) async {
    await pumpScreen(tester, db: db, child: const FocusScreen());
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('today summary uses the singular for one session',
      (tester) async {
    final repo = FocusSessionRepositoryImpl(db);
    final id = await repo.startSession(
      sessionType: FocusSessionType.focus,
      plannedDurationSec: 1500,
    );
    await repo.completeSession(id, endedEarly: true);

    await pumpScreen(tester, db: db, child: const FocusScreen());

    expect(find.textContaining('1 session'), findsOneWidget);
    expect(find.textContaining('1 sessions'), findsNothing);
  });

  testWidgets(
      'a running session shows wall-clock remaining time on first frame',
      (tester) async {
    // Reopening the app 10 minutes into a 25-minute session: remaining
    // time must come from the persisted anchor, not a restarted counter.
    await insertRunning(tester, elapsedSec: 600);

    await pumpScreenNoSettle(tester, db: db, child: const FocusScreen());

    expect(find.text('15:00'), findsOneWidget);
    expect(find.text('FOCUS'), findsOneWidget);
    await disposeScreen(tester);
  });

  testWidgets('the countdown advances once per second', (tester) async {
    await insertRunning(tester, elapsedSec: 600);
    await pumpScreenNoSettle(tester, db: db, child: const FocusScreen());
    expect(find.text('15:00'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('14:59'), findsOneWidget);

    await tester.pump(const Duration(seconds: 59));
    expect(find.text('14:00'), findsOneWidget);
    await disposeScreen(tester);
  });

  testWidgets('pausing within the first second stops the ticker',
      (tester) async {
    // Regression: the old Riverpod stream ticker was never cancelled if
    // disposed before its first tick, leaking a 1 Hz timer. flutter_test
    // fails this test if any timer is still pending at the end, so it
    // runs without disposeScreen on purpose.
    final id = await insertRunning(tester, elapsedSec: 600);
    await pumpScreenNoSettle(tester, db: db, child: const FocusScreen());

    await FocusSessionRepositoryImpl(db).pauseSession(id);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('PAUSED'), findsOneWidget);
    final frozen = find.text('15:00');
    expect(frozen, findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    expect(frozen, findsOneWidget, reason: 'paused time must not drain');
  });

  testWidgets('reaching zero completes the session at its natural end',
      (tester) async {
    final id = await insertRunning(tester, elapsedSec: 1498);
    final naturalEnd = clock.now().add(const Duration(seconds: 2));
    await pumpScreenNoSettle(
      tester,
      db: db,
      child: const FocusScreen(),
      extraOverrides: fakeNotifications,
    );
    expect(find.text('00:02'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 100));

    final row = await (db.select(db.focusSessions)
          ..where((s) => s.id.equals(id)))
        .getSingle();
    expect(row.completedAt, isNotNull);
    expect(
      row.completedAt!.difference(naturalEnd).inSeconds.abs(),
      lessThanOrEqualTo(1),
    );
    expect(row.endedEarly, isFalse);
    expect(row.actualDurationSec, 1500);
    // Back to the idle view once the session is closed.
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('a double tap on Start starts exactly one session (B6)',
      (tester) async {
    await pumpScreenNoSettle(
      tester,
      db: db,
      child: const FocusScreen(),
      extraOverrides: fakeNotifications,
    );

    // Two taps before any rebuild: the second must hit the busy guard.
    await tester.tap(find.text('Start'));
    await tester.tap(find.text('Start'), warnIfMissed: false);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    final rows = await tester.runAsync(() => db.select(db.focusSessions).get());
    expect(rows, hasLength(1));
    expect(rows!.single.endedEarly, isFalse);
    expect(rows.single.completedAt, isNull);
    await disposeScreen(tester);
  });

  testWidgets('End shows the session summary, which starts the break',
      (tester) async {
    await insertRunning(tester, elapsedSec: 600);
    await pumpScreenNoSettle(tester,
        db: db, child: const FocusScreen(), extraOverrides: fakeNotifications);

    await tester.tap(find.byTooltip('End'));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Session ended early'), findsOneWidget);
    expect(find.textContaining('10 min of focus logged'), findsOneWidget);

    await tester.tap(find.text('Start short break (5m)'));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    final rows = await tester.runAsync(() => db.select(db.focusSessions).get());
    expect(rows!.last.sessionType, FocusSessionType.shortBreak);
    expect(rows.last.completedAt, isNull);
    expect(find.byTooltip('Skip'), findsOneWidget,
        reason: 'breaks are skipped');
    await disposeScreen(tester);
  });
}
