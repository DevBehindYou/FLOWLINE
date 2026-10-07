import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'assistant/assistant_providers.dart';
import 'assistant/briefing_schedule.dart';
import 'assistant/reminder_sync.dart';
import 'core/providers.dart';
import 'core/router/app_router.dart';
import 'domain/entities/app_settings.dart';
import 'design/atomic.dart';
import 'core/time/current_day.dart';
import 'l10n/l10n.dart';
import 'features/focus_timer/viewmodel/focus_timer_view_model.dart';

class AtomicAssistApp extends ConsumerStatefulWidget {
  const AtomicAssistApp({super.key});

  @override
  ConsumerState<AtomicAssistApp> createState() => _AtomicAssistAppState();
}

class _AtomicAssistAppState extends ConsumerState<AtomicAssistApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // A focus session can run out while the app is backgrounded or dead,
    // and otherwise stays "active" until the Focus tab happens to be
    // built. Reconcile after the first frame (never delaying startup) and
    // on every resume.
    _lifecycle = AppLifecycleListener(onResume: _onResume);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reconcileFocusSession();
      unawaited(_listenForNotificationTaps());
      unawaited(_topUpReminders());
      unawaited(_runScanners());
    });
  }

  DateTime? _lastScan;

  /// The context scanners (docs/05 §9.6): on start and resume, at most
  /// every 10 minutes. Suggestions are a convenience; a failure is quiet.
  Future<void> _runScanners() async {
    final now = clock.now();
    final last = _lastScan;
    if (last != null && now.difference(last) < const Duration(minutes: 10)) {
      return;
    }
    _lastScan = now;
    try {
      await ref.read(scannerRunnerProvider).run(now);
    } catch (_) {}
  }

  StreamSubscription<void>? _notificationTaps;
  StreamSubscription<void>? _reminderActions;
  StreamSubscription<void>? _briefingTaps;

  /// Morning and shutdown notifications, per Settings → Assistant.
  Future<void> _syncBriefings() async {
    try {
      final settings = await ref.read(appSettingsRepositoryProvider).get();
      final service = await ref.read(notificationServiceProvider.future);
      await syncBriefingNotifications(service,
          enabled: settings.briefings, l10n: deviceLocalizations());
    } catch (_) {
      // A convenience: the briefings are a screen away anyway.
    }
  }

  /// Marks what fired while the app was away and schedules the next two
  /// weeks of reminder alerts (docs/05 §13).
  Future<void> _topUpReminders() async {
    try {
      await ref.read(reminderSyncProvider).topUp();
    } catch (_) {
      // Alerts are a convenience on top of the stored reminders.
    }
  }

  /// A tapped session notification opens the Focus tab, where the
  /// session's summary is waiting (B24).
  Future<void> _listenForNotificationTaps() async {
    try {
      final service = await ref.read(notificationServiceProvider.future);
      if (!mounted) return;
      void openFocus() => ref.read(appRouterProvider).go('/focus');
      _notificationTaps = service.taps.listen((_) => openFocus());
      void openBriefing(String kind) =>
          ref.read(appRouterProvider).go('/briefing/$kind');
      _briefingTaps = service.briefingTaps.listen(openBriefing);
      _reminderActions = service.reminderActions.listen((press) async {
        final touched = await applyReminderAction(
          actionId: press.action,
          reminderId: press.reminderId,
          reminders: ref.read(reminderRepositoryProvider),
          registry: ref.read(toolRegistryProvider),
          executor: ref.read(toolExecutorProvider),
        );
        if (touched != null) {
          try {
            await ref.read(reminderSyncProvider).sync(touched);
          } catch (_) {
            // Saved; the next top-up schedules the alert.
          }
        }
      });
      final briefing = await service.launchBriefingKind();
      if (briefing != null) {
        openBriefing(briefing);
      } else if (await service.launchedFromNotification()) {
        openFocus();
      }
      await _syncBriefings();
    } catch (_) {
      // Notifications are a convenience; the app works without them.
    }
  }

  void _onResume() {
    // A suspended app's midnight timer doesn't fire on time; re-read the
    // clock so every "today" window catches up immediately.
    ref.read(currentDayProvider.notifier).refresh();
    _reconcileFocusSession();
    unawaited(_topUpReminders());
    unawaited(_runScanners());
  }

  void _reconcileFocusSession() {
    unawaited(
        ref.read(focusTimerViewModelProvider.notifier).completeIfElapsed());
  }

  @override
  void dispose() {
    unawaited(_notificationTaps?.cancel());
    unawaited(_reminderActions?.cancel());
    unawaited(_briefingTaps?.cancel());
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    // Turning briefings on or off schedules or cancels them at once.
    ref.listen(appSettingsProvider, (prev, next) {
      final was = prev?.value?.briefings, now = next.value?.briefings;
      if (was != null && now != null && was != now) unawaited(_syncBriefings());
    });
    // The native splash stays up until the first frame; until the settings
    // are read (a local query, normally one frame) show the same plain
    // surface, because the router's first location depends on them.
    if (settings.isLoading && !settings.hasValue) {
      return const _SplashSurface();
    }
    final router = ref.watch(appRouterProvider);
    final themeMode = settings.value?.themeMode ?? AppThemeMode.system;

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: AtomicTheme.light(),
      darkTheme: AtomicTheme.dark(),
      themeMode: switch (themeMode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      },
      routerConfig: router,
    );
  }
}

class _SplashSurface extends StatelessWidget {
  const _SplashSurface();

  @override
  Widget build(BuildContext context) {
    // Above MaterialApp there is no MediaQuery yet.
    final dark = View.of(context).platformDispatcher.platformBrightness ==
        Brightness.dark;
    return ColoredBox(
      color:
          (dark ? AtomicTheme.dark() : AtomicTheme.light()).colorScheme.surface,
    );
  }
}
