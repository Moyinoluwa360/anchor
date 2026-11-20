import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/ui_providers.dart';
import '../../services/timer_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/glass_bottom_bar.dart';
import '../../widgets/grain_background.dart';
import '../../widgets/streak_bubble.dart';

/// Shell around the five main tabs: grain background, the active branch,
/// the floating streak bubble (top-left) and the liquid glass bottom bar.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The full-screen timer on Now owns the whole screen.
    final immersive = shell.currentIndex == 0 && !ref.watch(timerProvider.select((s) => s.isIdle));
    Widget chrome(Widget child) => IgnorePointer(
      ignoring: immersive,
      child: AnimatedOpacity(opacity: immersive ? 0 : 1, duration: context.motion(Motion.med), child: child),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const Positioned.fill(child: GrainBackground()),
          Positioned.fill(
            child: NotificationListener<UserScrollNotification>(
              onNotification: (n) {
                if (n.metrics.axis != Axis.vertical) return false;
                final chrome = ref.read(chromeVisibleProvider.notifier);
                if (n.direction == ScrollDirection.reverse) chrome.set(false);
                if (n.direction == ScrollDirection.forward) chrome.set(true);
                return false;
              },
              child: shell,
            ),
          ),
          Positioned.fill(
            child: chrome(Stack(children: [StreakBubble(onTap: () => _go(ref, 4))])),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: chrome(GlassBottomBar(index: shell.currentIndex, onTap: (i) => _go(ref, i))),
          ),
        ],
      ),
    );
  }

  void _go(WidgetRef ref, int i) {
    ref.read(chromeVisibleProvider.notifier).set(true);
    shell.goBranch(i, initialLocation: i == shell.currentIndex);
  }
}
