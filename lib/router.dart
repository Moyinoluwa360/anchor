import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/done/done_screen.dart';
import 'screens/goals/goals_screen.dart';
import 'screens/now/now_screen.dart';
import 'screens/shell/app_shell.dart';
import 'screens/today/today_screen.dart';
import 'screens/week/week_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Tab paths, in bottom bar order.
abstract final class Routes {
  static const now = '/now';
  static const today = '/today';
  static const week = '/week';
  static const goals = '/goals';
  static const done = '/done';
}

/// Fade-through for tab roots: no abrupt cuts.
Page<void> _fade(GoRouterState s, Widget child) => CustomTransitionPage<void>(
      key: s.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, a, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
        child: child,
      ),
    );

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.now,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.now, pageBuilder: (c, s) => _fade(s, const NowScreen())),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.today, pageBuilder: (c, s) => _fade(s, const TodayScreen())),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.week, pageBuilder: (c, s) => _fade(s, const WeekScreen())),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.goals, pageBuilder: (c, s) => _fade(s, const GoalsScreen())),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.done, pageBuilder: (c, s) => _fade(s, const DoneScreen())),
          ]),
        ],
      ),
    ],
  );
});
