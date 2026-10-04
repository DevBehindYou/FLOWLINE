@Tags(['golden'])
library;

import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;
import 'package:atomic_assist/core/notifications/notification_service.dart';
import 'package:atomic_assist/core/providers.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/schedule_repository_impl.dart';
import 'package:atomic_assist/data/repositories/task_repository_impl.dart';
import 'package:atomic_assist/domain/entities/focus_session.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:atomic_assist/domain/recurrence/recurrence_rule.dart';
import 'package:atomic_assist/features/focus_timer/view/focus_screen.dart';
import 'package:atomic_assist/features/insights/view/insights_screen.dart';
import 'package:atomic_assist/features/onboarding/onboarding_screen.dart';
import 'package:atomic_assist/features/schedule/view/today_screen.dart';
import 'package:atomic_assist/features/settings/view/settings_home_screen.dart';
import 'package:atomic_assist/features/task_detail/view/task_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_app.dart';
import '../support/test_database.dart';

/// Every screen in light and dark, at 100% and 200% text, on a 360dp
/// phone (docs/04 Phase 3 exit gate). The bundled fonts and the Material
/// icon font are loaded, so the images show real text, not test boxes.
///
/// After an intended visual change (or a Flutter bump), regenerate with
///   flutter test --update-goldens test/goldens
/// and look at the changed images before committing them. CI uploads the
/// diffs of a failing run (artifact "golden-failures").
class _QuietNotifications implements NotificationService {
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
}

Future<void> _loadFonts() async {
  Future<void> family(String name, List<String> files) async {
    final loader = FontLoader(name);
    for (final file in files) {
      loader.addFont(rootBundle.load(file));
    }
    await loader.load();
  }

  await family('BebasNeue', ['assets/fonts/BebasNeue-Regular.ttf']);
  await family('HankenGrotesk', [
    for (final w in ['Regular', 'Medium', 'Bold'])
      'assets/fonts/HankenGrotesk-$w.ttf',
  ]);
  await family('JetBrainsMono', [
    for (final w in ['Regular', 'Medium', 'Bold'])
      'assets/fonts/JetBrainsMono-$w.ttf',
  ]);
  await family('MaterialIcons', ['fonts/MaterialIcons-Regular.otf']);
}

// Tuesday 10 March 2026, 9:30: every date on screen is fixed.
final _now = DateTime(2026, 3, 10, 9, 30);
DateTime _at(int hour, [int minute = 0]) => DateTime(2026, 3, 10, hour, minute);

void main() {
  late AppDatabase db;
  setUpAll(_loadFonts);
  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  Future<void> seedDay() async {
    final schedule = ScheduleRepositoryImpl(db);
    final tasks = TaskRepositoryImpl(db);
    final deep = await schedule.createBlock(
        title: 'Deep work', startTime: _at(9), endTime: _at(11));
    await schedule.createBlock(
      title: 'Standup',
      startTime: _at(11, 30),
      endTime: _at(11, 45),
      recurrence: RecurrenceRule.weekdays(),
    );
    final draft = await tasks.createTask(
        title: 'Draft the Q2 plan',
        priority: TaskPriority.high,
        scheduleBlockId: deep);
    await tasks.setTaskStatus(draft, TaskStatus.inProgress);
    await tasks.createTask(
        title: 'Reply to design review',
        priority: TaskPriority.medium,
        scheduleBlockId: deep,
        dueAt: _at(17));
    await tasks.createTask(
        title: 'Book dentist', priority: TaskPriority.low, dueAt: _at(8));
  }

  Future<int> seedTaskWithSubtasks() async {
    final tasks = TaskRepositoryImpl(db);
    final id = await tasks.createTask(
        title: 'Draft the Q2 plan',
        notes: 'Goals, staffing and the two open risks.',
        priority: TaskPriority.high,
        dueAt: _at(17));
    for (final t in ['Outline', 'First draft', 'Review with Sam']) {
      await tasks.createSubtask(taskId: id, title: t, plannedSprints: 2);
    }
    await db.into(db.focusSessions).insert(FocusSessionsCompanion.insert(
          taskId: Value(id),
          sessionType: FocusSessionType.focus,
          plannedDurationSec: 1500,
          startedAt: _at(8),
          remainingSecAtSegmentStart: 0,
          completedAt: Value(_at(8, 25)),
          actualDurationSec: const Value(1500),
        ));
    return id;
  }

  Future<void> seedWeek() async {
    for (var d = 0; d < 7; d++) {
      final day = DateTime(2026, 3, 4 + d, 10);
      for (var i = 0; i <= d % 3; i++) {
        final start = day.add(Duration(minutes: i * 40));
        await db.into(db.focusSessions).insert(FocusSessionsCompanion.insert(
              sessionType: FocusSessionType.focus,
              plannedDurationSec: 1500,
              startedAt: start,
              remainingSecAtSegmentStart: 0,
              completedAt: Value(start.add(const Duration(minutes: 25))),
              actualDurationSec: const Value(1500),
            ));
      }
    }
  }

  Future<void> seedPausedSession() => db.into(db.focusSessions).insert(
        FocusSessionsCompanion.insert(
          sessionType: FocusSessionType.focus,
          plannedDurationSec: 1500,
          startedAt: _at(9),
          remainingSecAtSegmentStart: 754,
          isPaused: const Value(true),
        ),
      );

  final screens =
      <(String, Future<Object?> Function()?, Widget Function(Object?))>[
    ('today_empty', null, (_) => const TodayScreen()),
    ('today', seedDay, (_) => const TodayScreen()),
    (
      'task_detail',
      seedTaskWithSubtasks,
      (id) => TaskDetailScreen(taskId: id! as int)
    ),
    ('focus_idle', null, (_) => const FocusScreen()),
    ('focus_paused', seedPausedSession, (_) => const FocusScreen()),
    ('insights', seedWeek, (_) => const InsightsScreen()),
    ('settings', null, (_) => const SettingsHomeScreen()),
    ('onboarding', null, (_) => OnboardingScreen(onFinished: (_) {})),
  ];

  for (final (name, seed, build) in screens) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      for (final scale in [1.0, 2.0]) {
        final file = '${name}_${mode.name}_${scale == 1 ? '1x' : '2x'}';
        testWidgets(file, (tester) async {
          tester.view.physicalSize = const Size(360, 740);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          // Real shadows: flutter_test otherwise draws elevation as a solid
          // black outline.
          // (Restored in `finally` below: the binding checks it before
          // tear-downs run.)
          debugDisableShadows = false;
          // A phone: no keyboard-focus rings (tests default to desktop).
          FocusManager.instance.highlightStrategy =
              FocusHighlightStrategy.alwaysTouch;
          addTearDown(() => FocusManager.instance.highlightStrategy =
              FocusHighlightStrategy.automatic);
          final seeded = seed == null ? null : await tester.runAsync(seed);

          await withClock(Clock.fixed(_now), () async {
            await pumpScreen(
              tester,
              db: db,
              themeMode: mode,
              child: Builder(
                builder: (context) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: build(seeded),
                ),
              ),
              extraOverrides: [
                notificationServiceProvider
                    .overrideWith((ref) async => _QuietNotifications()),
              ],
            );
            try {
              await expectLater(find.byType(MaterialApp),
                  matchesGoldenFile('images/$file.png'));
            } finally {
              debugDisableShadows = true;
            }
            await disposeScreen(tester);
          });
        });
      }
    }
  }
}
