import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../../services/planner_service.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';

/// One arc on the dial.
class DialArc {
  const DialArc({
    required this.start,
    required this.end,
    required this.type,
    this.id,
    this.selected = false,
    this.preview = false,
    this.grow = 1,
  });
  final DateTime start;
  final DateTime end;
  final BlockType type;
  final int? id;
  final bool selected;
  final bool preview;

  /// 0 → 1 while a suggested arc animates onto the ring.
  final double grow;
}

/// Dial measurements shared by the painter and the gesture code.
class DialGeometry {
  DialGeometry(Size size, {required bool zoomed})
    : center = size.center(Offset.zero),
      outer = size.shortestSide / 2 - 4,
      band = zoomed ? 40 : 32;
  final Offset center;
  final double outer;
  final double band;
  double get ringMid => outer - band / 2;
  double get ringInner => outer - band;
  double get capacityRadius => ringInner - 46;
  double get handleRadius => 9;

  bool onRing(Offset local, {double slop = 16}) {
    final d = (local - center).distance;
    return d >= ringInner - slop && d <= outer + slop;
  }

  Offset point(double angle, double radius) => center + Offset(math.sin(angle), -math.cos(angle)) * radius;
}

Color arcColor(AnchorColors c, BlockType t) => switch (t) {
  BlockType.focus => c.accent,
  BlockType.admin => c.text.withValues(alpha: 0.55),
  BlockType.fixed => c.text.withValues(alpha: 0.9),
  BlockType.breakTime => c.text.withValues(alpha: 0.22),
  BlockType.rest => c.textDim.withValues(alpha: 0.28),
};

class DialPainter extends CustomPainter {
  DialPainter({
    required this.c,
    required this.day,
    required this.window,
    required this.now,
    required this.arcs,
    required this.capacity,
    required this.zoomed,
    this.ghost,
  });

  final AnchorColors c;
  final DateTime day;
  final DialWindow window;
  final DateTime now;
  final List<DialArc> arcs;
  final Capacity capacity;
  final bool zoomed;
  final DialArc? ghost;

  @override
  void paint(Canvas canvas, Size size) {
    final g = DialGeometry(size, zoomed: zoomed);
    final rect = Rect.fromCircle(center: g.center, radius: g.ringMid);

    // Track and hairlines.
    canvas.drawCircle(
      g.center,
      g.ringMid,
      Paint()
        ..color = c.surface
        ..style = PaintingStyle.stroke
        ..strokeWidth = g.band,
    );
    final hair = Paint()
      ..color = c.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(g.center, g.outer, hair);
    canvas.drawCircle(g.center, g.ringInner, hair);

    _ticks(canvas, g);
    _capacity(canvas, g);

    // Arcs.
    for (final a in arcs) {
      _arc(canvas, g, rect, a);
      // On the 24-hour dial a block that runs past midnight (sleep) wraps
      // around to the top again.
      if (window.isFull && a.end.isAfter(day.add(const Duration(days: 1)))) {
        _arc(
          canvas,
          g,
          rect,
          DialArc(
            start: a.start.subtract(const Duration(days: 1)),
            end: a.end.subtract(const Duration(days: 1)),
            type: a.type,
            preview: a.preview,
            grow: a.grow,
          ),
        );
      }
    }
    if (ghost != null) _arc(canvas, g, rect, ghost!, isGhost: true);

    _nowHand(canvas, g);
  }

  ({double a0, double a1})? _span(DateTime s, DateTime e) {
    var a0 = PlannerService.angleOf(s, day, window);
    var a1 = PlannerService.angleOf(e, day, window);
    if (a1 <= 0 || a0 >= 2 * math.pi) return null; // outside the window
    a0 = math.max(a0, 0);
    a1 = math.min(a1, 2 * math.pi);
    if (a1 - a0 <= 0) return null;
    return (a0: a0, a1: a1);
  }

  void _arc(Canvas canvas, DialGeometry g, Rect rect, DialArc a, {bool isGhost = false}) {
    final span = _span(a.start, a.end);
    if (span == null) return;
    const gap = 0.012;
    final sweepFull = math.max(0.0, span.a1 - span.a0 - gap * 2);
    final sweep = sweepFull * a.grow.clamp(0.0, 1.0);
    if (sweep <= 0) return;
    final start = span.a0 + gap - math.pi / 2;
    final stroke = g.band - 6;
    final color = arcColor(c, a.type);

    if (a.preview || isGhost) {
      final p = Paint()
        ..color = (a.type == BlockType.focus ? c.accent : c.text).withValues(alpha: isGhost ? 0.55 : 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, start, sweep, false, p);
      final outline = Paint()
        ..color = c.accentInk
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      final r1 = Rect.fromCircle(center: g.center, radius: g.ringMid + stroke / 2);
      final r2 = Rect.fromCircle(center: g.center, radius: g.ringMid - stroke / 2);
      canvas.drawArc(r1, start, sweep, false, outline);
      canvas.drawArc(r2, start, sweep, false, outline);
      return;
    }

    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt,
    );

    // Type icon in the middle of long-enough arcs.
    final arcLen = sweep * g.ringMid;
    if (arcLen > 26) {
      final mid = span.a0 + (span.a1 - span.a0) / 2;
      final p = g.point(mid, g.ringMid);
      final onArc = a.type == BlockType.focus || a.type == BlockType.fixed ? c.onAccent : c.text;
      final tp = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(a.type.icon.codePoint),
          style: TextStyle(
            fontFamily: a.type.icon.fontFamily,
            package: a.type.icon.fontPackage,
            fontSize: zoomed ? 15 : 12,
            color: a.type == BlockType.fixed ? c.bg : onArc,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }

    if (a.selected) {
      for (final ang in [span.a0, span.a1]) {
        final p = g.point(ang, g.ringMid);
        canvas.drawCircle(p, g.handleRadius + 2, Paint()..color = c.bg);
        canvas.drawCircle(p, g.handleRadius, Paint()..color = c.text);
        canvas.drawCircle(p, g.handleRadius - 4, Paint()..color = c.accent);
      }
    }
  }

  void _ticks(Canvas canvas, DialGeometry g) {
    final tick = Paint()
      ..color = c.textDim.withValues(alpha: 0.6)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    final step = zoomed ? 0.25 : 1.0;
    final labelEvery = zoomed ? 1.0 : 3.0;
    for (var h = window.startHour; h <= window.startHour + window.spanHours - 0.001; h += step) {
      final a = (h - window.startHour) / window.spanHours * 2 * math.pi;
      final major = (h % labelEvery).abs() < 0.001;
      final r0 = g.ringInner - 5;
      final r1 = r0 - (major ? 7 : 3);
      canvas.drawLine(g.point(a, r0), g.point(a, r1), tick);
      if (major) {
        final hh = h.round() % 24;
        final strong = zoomed || hh % 6 == 0;
        final tp = TextPainter(
          text: TextSpan(
            text: hh.toString().padLeft(2, '0'),
            style: T.mono(
              strong ? c.text : c.textDim,
              size: strong ? 12 : 10,
              w: strong ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final p = g.point(a, r1 - 12);
        tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
      }
    }
  }

  void _capacity(Canvas canvas, DialGeometry g) {
    final r = Rect.fromCircle(center: g.center, radius: g.capacityRadius);
    final track = Paint()
      ..color = c.surface2
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawCircle(g.center, g.capacityRadius, track);
    final ratio = capacity.ratio;
    if (ratio <= 0) return;
    final col = switch (capacity.level) {
      CapacityLevel.calm => c.text,
      CapacityLevel.full => c.isDark ? c.accent : c.accentInk,
      CapacityLevel.over => c.warn,
    };
    final p = Paint()
      ..color = col
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(r, -math.pi / 2, 2 * math.pi * ratio.clamp(0.0, 1.0), false, p);
    if (ratio > 1) {
      final inner = Rect.fromCircle(center: g.center, radius: g.capacityRadius - 9);
      canvas.drawArc(
        inner,
        -math.pi / 2,
        2 * math.pi * (ratio - 1).clamp(0.0, 1.0),
        false,
        p..strokeWidth = 3,
      );
    }
  }

  void _nowHand(Canvas canvas, DialGeometry g) {
    if (now.isBefore(day) || !now.isBefore(day.add(const Duration(days: 1)))) return;
    final a = PlannerService.angleOf(now, day, window);
    if (a < 0 || a > 2 * math.pi) return;
    final col = c.isDark ? c.accent : c.accentInk;
    final p = Paint()
      ..color = col
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(g.point(a, g.capacityRadius + 10), g.point(a, g.outer + 2), p);
    canvas.drawCircle(g.point(a, g.outer + 2), 4.5, Paint()..color = col);
    canvas.drawCircle(g.point(a, g.outer + 2), 2, Paint()..color = c.bg);
  }

  @override
  bool shouldRepaint(DialPainter old) => true;
}
