import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers.dart';
import 'core/router/app_router.dart';
import 'domain/entities/app_settings.dart';
import 'core/theme/app_theme.dart';
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
    });
  }

  StreamSubscription<void>? _notificationTaps;

  /// A tapped session notification opens the Focus tab, where the
  /// session's summary is waiting (B24).
  Future<void> _listenForNotificationTaps() async {
    try {
      final service = await ref.read(notificationServiceProvider.future);
      if (!mounted) return;
      void openFocus() => ref.read(appRouterProvider).go('/focus');
      _notificationTaps = service.taps.listen((_) => openFocus());
      if (await service.launchedFromNotification()) openFocus();
    } catch (_) {
      // Notifications are a convenience; the app works without them.
    }
  }

  void _onResume() {
    // A suspended app's midnight timer doesn't fire on time; re-read the
    // clock so every "today" window catches up immediately.
    ref.read(currentDayProvider.notifier).refresh();
    _reconcileFocusSession();
  }

  void _reconcileFocusSession() {
    unawaited(
        ref.read(focusTimerViewModelProvider.notifier).completeIfElapsed());
  }

  @override
  void dispose() {
    unawaited(_notificationTaps?.cancel());
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
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
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
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
      color: (dark ? AppTheme.dark() : AppTheme.light()).colorScheme.surface,
    );
  }
}
