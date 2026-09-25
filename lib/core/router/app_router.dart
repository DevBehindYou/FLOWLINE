import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/ai_assistant/view/assistant_screen.dart';
import '../../features/focus_timer/view/focus_screen.dart';
import '../../features/insights/view/insights_screen.dart';
import '../../features/schedule/view/today_screen.dart';
import '../../features/settings/view/ai_providers_screen.dart';
import '../../features/settings/view/settings_home_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/task_detail/view/task_detail_screen.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/today',
    routes: [
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
                path: '/assistant',
                builder: (context, state) => const AssistantScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/insights',
                builder: (context, state) => const InsightsScreen(),
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
        ],
      ),
    ],
  );
}
