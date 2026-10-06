import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers.dart';

import '../../features/ai_assistant/view/assistant_screen.dart';
import '../../features/focus_timer/view/focus_screen.dart';
import '../../features/inbox/view/activity_screen.dart';
import '../../features/inbox/view/inbox_screen.dart';
import '../../features/insights/view/insights_screen.dart';
import '../../features/library/view/library_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/schedule/view/today_screen.dart';
import '../../features/settings/view/ai_providers_screen.dart';
import '../../features/settings/view/settings_home_screen.dart';
import '../../features/settings/view/settings_screens.dart';
import '../../features/shell/app_shell.dart';
import '../../features/task_detail/view/task_detail_screen.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Built once, after AtomicAssistApp has the stored settings: the first
/// location is decided then, so a first launch opens onboarding without
/// flashing Today first, and finishing it can't race a redirect against
/// the settings stream. If the settings can't be read, the app opens
/// normally rather than trapping the user in onboarding.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final onboardingDone =
      ref.read(appSettingsProvider).value?.onboardingDone ?? true;
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: onboardingDone ? '/today' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingScreen(
          onFinished: (connectAi) {
            final router = GoRouter.of(context);
            router.go('/today');
            if (connectAi) unawaited(router.push('/settings/ai-providers'));
          },
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: '/today',
                builder: (context, state) => const TodayScreen(),
                routes: [
                  GoRoute(
                    path: 'task/:taskId',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => TaskDetailScreen(
                      taskId: int.parse(state.pathParameters['taskId']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // TODAY · INBOX · ASSIST · FOCUS · LIBRARY (docs/05 §28).
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inbox',
                builder: (context, state) => const InboxScreen(),
                routes: [
                  GoRoute(
                    path: 'activity',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const ActivityScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/assistant',
                builder: (context, state) => const AssistantScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/focus',
                builder: (context, state) => const FocusScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
                routes: [
                  GoRoute(
                    path: 'review',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const InsightsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsHomeScreen(),
        routes: [
          GoRoute(
            path: 'ai-providers',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const AiProvidersScreen(),
          ),
          GoRoute(
            path: 'focus',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const FocusTimerSettingsScreen(),
          ),
          GoRoute(
            path: 'notifications',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const NotificationSettingsScreen(),
          ),
          GoRoute(
            path: 'appearance',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const AppearanceScreen(),
          ),
          GoRoute(
            path: 'data',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const DataPrivacyScreen(),
          ),
        ],
      ),
    ],
  );
}
