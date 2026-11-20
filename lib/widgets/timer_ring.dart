import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Giant draining ring: a thick arc that shrinks from full (start of the
/// phase) to nothing (time's up), with a glowing head and minute ticks.
class TimerRingPainter extends CustomPainter {
  TimerRingPainter({
    required this.fraction,
    required this.color,
    required this.track,
    required this.tick,
    this.stroke = 18,
  });

  /// 1.0 = full, 0.0 = empty.
  final double fraction;
  final Color color;
  final Color track;
  final Color tick;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - stroke / 2 - 10;
    final rect = Rect.fromCircle(center: c, radius: r);

    // 60 ticks just outside the ring.
    final tp = Paint()
      ..color = tick
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 60; i++) {
      final a = -math.pi / 2 + i * math.pi / 30;
      final long = i % 5 == 0;
      final r1 = r + stroke / 2 + 4, r2 = r1 + (long ? 6 : 3);
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * r1,
        c + Offset(math.cos(a), math.sin(a)) * r2,
        tp,
      );
    }

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    if (fraction <= 0) return;
    final sweep = 2 * math.pi * fraction;
    const start = -math.pi / 2;

    // Soft glow under the arc.
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke + 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );

    // Head dot.
    final ha = start + sweep;
    final head = c + Offset(math.cos(ha), math.sin(ha)) * r;
    canvas.drawCircle(head, stroke * 0.32, Paint()..color = track);
  }

  @override
  bool shouldRepaint(TimerRingPainter old) =>
      old.fraction != fraction || old.color != color || old.track != track;
}
