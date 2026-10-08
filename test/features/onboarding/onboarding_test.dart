import 'package:atomic_assist/core/notifications/notification_service.dart';
import 'package:atomic_assist/core/providers.dart';
import 'package:atomic_assist/core/riverpod_config.dart';
import 'package:atomic_assist/core/router/app_router.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/app_settings_repository_impl.dart';
import 'package:atomic_assist/domain/entities/app_settings.dart';
import 'package:atomic_assist/features/onboarding/onboarding_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/finders.dart';

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

  _FakeNotificationService({this.denied = false});
  final bool denied;
  int permissionRequests = 0;

  @override
  Future<void> init() async {}

  @override
  Future<void> scheduleSessionComplete({
    required DateTime fireAt,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> requestPermission() async {
    permissionRequests++;
    if (denied) throw Exception('permission denied');
  }

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

  Future<AppSettings> stored(WidgetTester tester) async =>
      (await tester.runAsync(() => AppSettingsRepositoryImpl(db).get()))!;

  Future<List<bool>> pumpOnboarding(
    WidgetTester tester,
    _FakeNotificationService notifications,
  ) async {
    final finished = <bool>[];
    await pumpScreen(
      tester,
      db: db,
      child: OnboardingScreen(onFinished: finished.add),
      extraOverrides: [
        notificationServiceProvider.overrideWith((ref) async => notifications),
      ],
    );
    return finished;
  }

  testWidgets('walks all three steps and asks for notifications once',
      (tester) async {
    final notifications = _FakeNotificationService();
    final finished = await pumpOnboarding(tester, notifications);
    expect(find.bySemanticsLabel('Step 1 of 3'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Know when a session ends'), findsOneWidget);

    await tester.tap(find.text('Allow notifications'));
    await tester.pumpAndSettle();
    expect(notifications.permissionRequests, 1);
    expect(find.text('Connect an AI assistant (optional)'), findsOneWidget);
    // The last step has its own skip; the app-bar one is gone.
    expect(findLabel('Skip'), findsNothing);

    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();
    expect(finished, [false]);
    expect((await stored(tester)).onboardingDone, isTrue);
  });

  testWidgets('a denied permission still moves on', (tester) async {
    final notifications = _FakeNotificationService(denied: true);
    final finished = await pumpOnboarding(tester, notifications);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Allow notifications'));
    await tester.pumpAndSettle();

    expect(find.text('Connect an AI assistant (optional)'), findsOneWidget);
    expect(finished, isEmpty);
  });

  testWidgets('"Not now" skips the permission prompt', (tester) async {
    final notifications = _FakeNotificationService();
    await pumpOnboarding(tester, notifications);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(notifications.permissionRequests, 0);
    expect(find.text('Connect an AI assistant (optional)'), findsOneWidget);
  });

  testWidgets('Skip on the first step finishes onboarding', (tester) async {
    final finished = await pumpOnboarding(tester, _FakeNotificationService());

    await tester.tap(findLabel('Skip'));
    await tester.pumpAndSettle();

    expect(finished, [false]);
    expect((await stored(tester)).onboardingDone, isTrue);
  });

  testWidgets('"Connect a provider" finishes and asks for the AI screen',
      (tester) async {
    final finished = await pumpOnboarding(tester, _FakeNotificationService());
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Connect a provider'));
    await tester.pumpAndSettle();
    expect(finished, [true]);
    expect((await stored(tester)).onboardingDone, isTrue);
  });

  group('first location', () {
    Future<String> initialLocation({required bool failSettings}) async {
      final container = ProviderContainer(retry: noAutomaticRetry, overrides: [
        appDatabaseProvider.overrideWith((ref) => db),
        if (failSettings)
          appSettingsProvider
              .overrideWith((ref) => Stream.error(StateError('disk'))),
      ]);
      addTearDown(container.dispose);
      final sub = container.listen(appSettingsProvider, (_, __) {});
      addTearDown(sub.close);
      try {
        await container.read(appSettingsProvider.future);
      } catch (_) {}
      final router = container.read(appRouterProvider);
      addTearDown(router.dispose);
      return router.routeInformationProvider.value.uri.path;
    }

    test('is onboarding on a first launch', () async {
      expect(await initialLocation(failSettings: false), '/onboarding');
    });

    test('is Today once onboarding is done', () async {
      await AppSettingsRepositoryImpl(db)
          .save(const AppSettings(onboardingDone: true));
      expect(await initialLocation(failSettings: false), '/today');
    });

    test('is Today when the settings cannot be read', () async {
      expect(await initialLocation(failSettings: true), '/today');
    });
  });
}
