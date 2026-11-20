import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/done/done_screen.dart';
import 'screens/goals/goal_detail_screen.dart';
import 'screens/goals/goals_screen.dart';
import 'screens/inbox/inbox_screen.dart';
import 'screens/now/now_screen.dart';
import 'screens/onboarding/notifications_intro_screen.dart';
import 'screens/reminders/reminders_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/shell/app_shell.dart';
import 'screens/today/today_screen.dart';
import 'screens/week/review_screen.dart';
import 'screens/week/week_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Tab paths, in bottom bar order.
abstract final class Routes {
  static const now = '/now';
  static const today = '/today';
  static const week = '/week';
  static const goals = '/goals';
  static const done = '/done';
  static const reminders = '/reminders';
  static const review = '/review';
  static const inbox = '/inbox';
  static const settings = '/settings';
  static const notificationsIntro = '/welcome/notifications';
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

/// Full-screen sheet that slides up (goal detail).
Page<void> _sheet(GoRouterState s, Widget child) => CustomTransitionPage<void>(
  key: s.pageKey,
  child: child,
  transitionDuration: const Duration(milliseconds: 340),
  reverseTransitionDuration: const Duration(milliseconds: 260),
  transitionsBuilder: (context, a, _, child) => SlideTransition(
    position: Tween(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
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
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.now, pageBuilder: (c, s) => _fade(s, const NowScreen()))],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.today, pageBuilder: (c, s) => _fade(s, const TodayScreen()))],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.week,
                pageBuilder: (c, s) =>
                    _fade(s, WeekScreen(openReview: s.uri.queryParameters['review'] == '1')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.goals, pageBuilder: (c, s) => _fade(s, const GoalsScreen()))],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.done, pageBuilder: (c, s) => _fade(s, const DoneScreen()))],
          ),
        ],
      ),
      GoRoute(path: Routes.reminders, builder: (c, s) => const RemindersScreen()),
      GoRoute(path: Routes.inbox, builder: (c, s) => const InboxScreen()),
      GoRoute(path: Routes.settings, builder: (c, s) => const SettingsScreen()),
      GoRoute(
        path: Routes.review,
        pageBuilder: (c, s) => const MaterialPage(fullscreenDialog: true, child: ReviewScreen()),
      ),
      GoRoute(
        path: '${Routes.goals}/:id',
        pageBuilder: (c, s) =>
            _sheet(s, GoalDetailScreen(goalId: int.tryParse(s.pathParameters['id'] ?? '') ?? -1)),
      ),
      GoRoute(
        path: Routes.notificationsIntro,
        pageBuilder: (c, s) => const MaterialPage(fullscreenDialog: true, child: NotificationsIntroScreen()),
      ),
    ],
  );
});

/// Where a tapped notification should land.
String routeForPayload(String payload) {
  if (payload.startsWith('block:')) return Routes.today;
  return switch (payload) {
    'done' => Routes.done,
    'review' => '${Routes.week}?review=1',
    _ => Routes.now,
  };
}
