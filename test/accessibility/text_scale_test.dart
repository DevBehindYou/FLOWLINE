import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;
import 'package:atomic_assist/core/notifications/notification_service.dart';
import 'package:atomic_assist/core/providers.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/schedule_repository_impl.dart';
import 'package:atomic_assist/data/repositories/task_repository_impl.dart';
import 'package:atomic_assist/domain/entities/focus_session.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:atomic_assist/features/focus_timer/view/focus_screen.dart';
import 'package:atomic_assist/features/onboarding/onboarding_screen.dart';
import 'package:atomic_assist/features/insights/view/insights_screen.dart';
import 'package:atomic_assist/features/schedule/view/today_screen.dart';
import 'package:atomic_assist/features/settings/view/settings_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_app.dart';
import '../support/test_database.dart';

class _QuietNotifications implements NotificationService {
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
  Future<void> scheduleSessionComplete(
      {required DateTime fireAt,
      required String title,
      required String body}) async {}
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

/// Spec §1 / §9: layouts must survive 200% system font scaling without
/// clipping, on a small phone. A RenderFlex overflow is reported by the
/// framework as an exception, so "no exception" is the assertion.
void main() {
  late AppDatabase db;
  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  Widget scaled(Widget screen) => Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: screen,
        ),
      );

  void smallPhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 1920); // 360 x 640 dp
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  Future<void> seed() async {
    final blockId = await ScheduleRepositoryImpl(db).createBlock(
      title: 'A fairly long schedule block title for wrapping',
      startTime: DateTime(2026, 3, 10, 9),
      endTime: DateTime(2026, 3, 10, 10, 30),
    );
    final tasks = TaskRepositoryImpl(db);
    await tasks.createTask(
        title: 'Write the quarterly planning document draft',
        priority: TaskPriority.high,
        scheduleBlockId: blockId);
    await tasks.createTask(
        title: 'Unscheduled backlog item with a long name',
        priority: TaskPriority.low);
  }

  for (final (name, screen) in [
    ('Today (empty)', const TodayScreen()),
    ('Settings', const SettingsHomeScreen()),
    ('Insights (empty)', const InsightsScreen()),
    ('Focus (idle)', const FocusScreen()),
    ('Onboarding', OnboardingScreen(onFinished: (_) {})),
  ]) {
    testWidgets('$name fits at 200% text on a 360dp phone', (tester) async {
      smallPhone(tester);
      await pumpScreen(tester, db: db, child: scaled(screen), extraOverrides: [
        notificationServiceProvider
            .overrideWith((ref) async => _QuietNotifications()),
      ]);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Today with blocks and tasks fits at 200% text', (tester) async {
    smallPhone(tester);
    await tester.runAsync(seed);
    await pumpScreen(tester, db: db, child: scaled(const TodayScreen()));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Insights with data fits at 200% text', (tester) async {
    smallPhone(tester);
    final now = clock.now();
    await tester.runAsync(() => db.into(db.focusSessions).insert(
          FocusSessionsCompanion.insert(
            sessionType: FocusSessionType.focus,
            plannedDurationSec: 1500,
            startedAt: now.subtract(const Duration(minutes: 30)),
            remainingSecAtSegmentStart: 0,
            completedAt: Value(now.subtract(const Duration(minutes: 5))),
            actualDurationSec: const Value(7260),
          ),
        ));
    await pumpScreen(tester, db: db, child: scaled(const InsightsScreen()));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a running timer fits at 200% text and is announced',
      (tester) async {
    smallPhone(tester);
    final handle = tester.ensureSemantics();
    final anchor = clock.now().subtract(const Duration(seconds: 90));
    await tester.runAsync(() => db.into(db.focusSessions).insert(
          FocusSessionsCompanion.insert(
            sessionType: FocusSessionType.focus,
            plannedDurationSec: 1500,
            startedAt: anchor,
            segmentStartedAt: Value(anchor),
            remainingSecAtSegmentStart: 1500,
          ),
        ));
    await pumpScreenNoSettle(tester,
        db: db,
        child: scaled(const FocusScreen()),
        extraOverrides: [
          notificationServiceProvider
              .overrideWith((ref) async => _QuietNotifications()),
        ]);
    expect(tester.takeException(), isNull);
    expect(
      find.bySemanticsLabel('Timer'),
      findsOneWidget,
    );
    final node = tester.getSemantics(find.bySemanticsLabel('Timer'));
    expect(node.value, contains('remaining'));
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
    handle.dispose();
    await disposeScreen(tester);
  });
}
