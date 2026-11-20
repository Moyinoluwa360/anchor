import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../models/enums.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';

/// Progress ring with milestones orbiting as small dots (done = lemon).
class GoalRingPainter extends CustomPainter {
  GoalRingPainter({
    required this.progress,
    required this.milestones,
    required this.c,
    this.orbit = 0,
    this.stroke = 7,
  });

  final double progress;
  final List<Milestone> milestones;
  final AnchorColors c;

  /// Orbit rotation in radians (slow drift).
  final double orbit;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 14;
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = c.surface2
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        Paint()
          ..color = c.isDark ? c.accent : c.accentInk
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round,
      );
    }
    // Milestone orbit.
    final orbitR = r + 10;
    canvas.drawCircle(
      center,
      orbitR,
      Paint()
        ..color = c.border.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );
    final n = milestones.length;
    for (var i = 0; i < n; i++) {
      final a = orbit + i * 2 * math.pi / math.max(n, 1) - math.pi / 2;
      final p = center + Offset(math.cos(a), math.sin(a)) * orbitR;
      final done = milestones[i].done;
      if (done) {
        canvas.drawCircle(p, 4.2, Paint()..color = c.isDark ? c.accent : c.accentInk);
      } else {
        canvas.drawCircle(p, 4.2, Paint()..color = c.bg);
        canvas.drawCircle(
          p,
          4.2,
          Paint()
            ..color = c.textDim
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(GoalRingPainter old) =>
      old.progress != progress || old.orbit != orbit || old.milestones != milestones || old.c != c;
}

/// One star in the constellation.
class GoalNode extends StatelessWidget {
  const GoalNode({
    super.key,
    required this.goal,
    required this.progress,
    required this.milestones,
    required this.orbit,
    this.lifted = false,
  });

  static const width = 160.0;
  static const ring = 118.0;

  final Goal goal;
  final double progress;
  final List<Milestone> milestones;
  final double orbit;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final paused = goal.status == GoalStatus.paused;
    return Opacity(
      opacity: paused ? 0.5 : 1,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: lifted ? 1.08 : 1,
              duration: context.motion(Motion.fast),
              child: SizedBox.square(
                dimension: ring,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: ring - 40,
                      height: ring - 40,
                      decoration: BoxDecoration(
                        color: c.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (c.isDark ? c.accent : Colors.black).withValues(
                              alpha: progress >= 1 ? 0.25 : 0.06,
                            ),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                    ),
                    CustomPaint(
                      size: const Size.square(ring),
                      painter: GoalRingPainter(
                        progress: progress,
                        milestones: milestones,
                        c: c,
                        orbit: orbit,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(goal.area.icon, size: 16, color: c.areaTint(goal.area)),
                        Text(
                          '${(progress * 100).round()}%',
                          style: T.mono(c.text, size: 15, w: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              goal.title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: T.small(c.text).copyWith(fontWeight: FontWeight.w600, height: 1.25),
            ),
          ],
        ),
      ),
    );
  }
}
