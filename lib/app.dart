import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/focus_timer/viewmodel/focus_timer_view_model.dart';

class FlowlineApp extends ConsumerStatefulWidget {
  const FlowlineApp({super.key});

  @override
  ConsumerState<FlowlineApp> createState() => _FlowlineAppState();
}

class _FlowlineAppState extends ConsumerState<FlowlineApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // A focus session can run out while the app is backgrounded or dead,
    // and otherwise stays "active" until the Focus tab happens to be
    // built. Reconcile after the first frame (never delaying startup) and
    // on every resume.
    _lifecycle = AppLifecycleListener(onResume: _reconcileFocusSession);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _reconcileFocusSession());
  }

  void _reconcileFocusSession() {
    ref.read(focusTimerViewModelProvider.notifier).completeIfElapsed();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Flowline',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
