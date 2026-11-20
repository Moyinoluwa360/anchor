import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings.dart';
import '../providers/ui_providers.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'glass.dart';

/// Small liquid glass bubble on the left edge: flame + streak number in lemon.
/// Drag it up and down along the edge (position is remembered), it tucks
/// partly off-screen while scrolling down, and tapping it opens Done.
class StreakBubble extends ConsumerStatefulWidget {
  const StreakBubble({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  ConsumerState<StreakBubble> createState() => _StreakBubbleState();
}

class _StreakBubbleState extends ConsumerState<StreakBubble> {
  double? _dragY; // fraction while dragging
  bool _countedUp = false;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final streak = ref.watch(streakProvider);
    final s = ref.watch(settingsProvider);
    final visible = ref.watch(chromeVisibleProvider);
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final minY = (pad.top + 6) / size.height;
    final maxY = 0.72;
    final y = (_dragY ?? s.streakBubbleY).clamp(minY, maxY);
    final d = context.motion(Motion.med);
    final accent = c.isDark ? c.accent : c.accentInk;

    // Count up briefly once on app open.
    final countFrom = _countedUp ? streak.current : 0;
    if (!_countedUp && streak.current > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _countedUp = true);
    }

    return AnimatedPositioned(
      duration: _dragY != null ? Duration.zero : d,
      curve: Motion.curve,
      left: visible ? 10 : -34,
      top: y * size.height,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0.7,
        duration: d,
        child: Semantics(
          button: true,
          label: streak.paused
              ? 'Streak ${streak.current} days, resting. Open Done'
              : 'Streak ${streak.current} days. Open Done',
          excludeSemantics: true,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onTap();
            },
            onVerticalDragStart: (_) => setState(() => _dragY = y),
            onVerticalDragUpdate: (e) =>
                setState(() => _dragY = ((_dragY ?? y) + e.delta.dy / size.height).clamp(minY, maxY)),
            onVerticalDragEnd: (_) {
              final v = _dragY ?? y;
              ref.read(settingsProvider.notifier).update((st) => st.copyWith(streakBubbleY: v));
              HapticFeedback.lightImpact();
              setState(() => _dragY = null);
            },
            child: Glass(
              radius: 22,
              blur: 16,
              padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.local_fire_department_rounded,
                    size: 18, color: streak.paused ? c.textDim : accent),
                const SizedBox(width: 4),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: countFrom.toDouble(), end: streak.current.toDouble()),
                  duration: context.motion(const Duration(milliseconds: 400)),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, _) => Text('${v.round()}', style: T.mono(accent, size: 15, w: FontWeight.w700)),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
