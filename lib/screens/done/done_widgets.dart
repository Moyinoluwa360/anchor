import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/database.dart';
import '../../models/dates.dart';
import '../../services/insights_service.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/sheet.dart';

// Heat map ------------------------------------------------------------------

/// Contribution-style grid of the last [weeks] weeks. Each day glows brighter
/// lemon the more got done. Tap a day to see its card stack.
class HeatMap extends StatelessWidget {
  const HeatMap({super.key, required this.counts, required this.now, required this.onDay, this.weeks = 26});
  final Map<DateTime, int> counts;
  final DateTime now;
  final int weeks;
  final ValueChanged<DateTime> onDay;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return LayoutBuilder(
      builder: (context, box) {
        const gap = 3.0;
        const labelW = 14.0;
        final cell = ((box.maxWidth - labelW - gap * (weeks - 1)) / weeks).floorToDouble();
        final h = 7 * cell + 6 * gap + 16;
        final start = addDays(weekStartOf(now), -7 * (weeks - 1));
        return SizedBox(
          height: h,
          child: GestureDetector(
            onTapUp: (d) {
              final col = ((d.localPosition.dx - labelW) / (cell + gap)).floor();
              final row = ((d.localPosition.dy - 16) / (cell + gap)).floor();
              if (col < 0 || col >= weeks || row < 0 || row > 6) return;
              final day = addDays(start, col * 7 + row);
              if (day.isAfter(today(now))) return;
              HapticFeedback.selectionClick();
              onDay(day);
            },
            child: Semantics(
              label:
                  'Heat map of the last $weeks weeks. ${counts.values.fold(0, (a, b) => a + b)} tasks done. Tap a day for details.',
              child: CustomPaint(
                size: Size(box.maxWidth, h),
                painter: _HeatPainter(
                  c: c,
                  counts: counts,
                  start: start,
                  weeks: weeks,
                  cell: cell,
                  gap: gap,
                  labelW: labelW,
                  now: now,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeatPainter extends CustomPainter {
  _HeatPainter({
    required this.c,
    required this.counts,
    required this.start,
    required this.weeks,
    required this.cell,
    required this.gap,
    required this.labelW,
    required this.now,
  });
  final ExeColors c;
  final Map<DateTime, int> counts;
  final DateTime start;
  final int weeks;
  final double cell;
  final double gap;
  final double labelW;
  final DateTime now;

  @override
  void paint(Canvas canvas, Size size) {
    final t = today(now);
    final r = Radius.circular(cell * 0.3);
    // Month labels where the month changes; drop a cramped first one.
    final labels = <(int, int)>[];
    for (var w = 0; w < weeks; w++) {
      final m = addDays(start, w * 7).month;
      if (labels.isEmpty || labels.last.$2 != m) labels.add((w, m));
    }
    if (labels.length > 1 && labels[1].$1 - labels[0].$1 < 3) labels.removeAt(0);
    for (final (w, m) in labels) {
      final tp = TextPainter(
        text: TextSpan(text: monthShort[m - 1], style: T.mono(c.textDim, size: 9)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(labelW + w * (cell + gap), 0));
    }
    for (var w = 0; w < weeks; w++) {
      final colStart = addDays(start, w * 7);
      for (var d = 0; d < 7; d++) {
        final day = addDays(colStart, d);
        if (day.isAfter(t)) continue;
        final level = InsightsService.heatLevel(counts[day] ?? 0);
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(labelW + w * (cell + gap), 16 + d * (cell + gap), cell, cell),
          r,
        );
        if (level == 0) {
          canvas.drawRRect(rect, Paint()..color = c.surface2);
        } else {
          final alpha = [0.0, 0.28, 0.5, 0.75, 1.0][level];
          if (level == 4) {
            canvas.drawRRect(
              rect.inflate(1.5),
              Paint()
                ..color = c.accent.withValues(alpha: 0.35)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
            );
          }
          canvas.drawRRect(
            rect,
            Paint()..color = (c.isDark ? c.accent : c.accentInk).withValues(alpha: alpha),
          );
        }
        if (day == t) {
          canvas.drawRRect(
            rect,
            Paint()
              ..color = c.text
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1,
          );
        }
      }
    }
    for (final (i, l) in [(0, 'M'), (2, 'W'), (4, 'F')]) {
      final tp = TextPainter(
        text: TextSpan(text: l, style: T.mono(c.textDim, size: 8)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, 16 + i * (cell + gap) + (cell - tp.height) / 2));
    }
  }

  @override
  bool shouldRepaint(_HeatPainter old) => old.counts != counts || old.c != c || old.cell != cell;
}

// Card stack ----------------------------------------------------------------

/// A fanned stack of completed tasks. Swipe the top card away to see the next.
class CardStack extends StatefulWidget {
  const CardStack({super.key, required this.tasks, this.height = 220});
  final List<Task> tasks;
  final double height;

  @override
  State<CardStack> createState() => _CardStackState();
}

class _CardStackState extends State<CardStack> {
  int _top = 0;
  double _dx = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final n = widget.tasks.length;
    if (n == 0) return const SizedBox.shrink();
    final visible = math.min(4, n);
    return SizedBox(
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var k = visible - 1; k >= 0; k--)
            () {
              final t = widget.tasks[(_top + k) % n];
              final isTop = k == 0;
              final card = Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isTop ? c.surface : Color.lerp(c.surface, c.bg, 0.25 * k),
                  borderRadius: BorderRadius.circular(Radii.card),
                  border: Border.all(color: c.border, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: c.isDark ? 0.35 : 0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(t.area.icon, size: 14, color: c.areaTint(t.area)),
                        const SizedBox(width: 6),
                        Text(t.area.label.toUpperCase(), style: T.label(c.textDim)),
                        const Spacer(),
                        Icon(Icons.check_circle_rounded, size: 18, color: c.accentInk),
                      ],
                    ),
                    const Spacer(),
                    Text(t.title, style: T.h2(c.text), maxLines: 3, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(
                      '${t.completedAt == null ? '' : '${dayLabel(t.completedAt!)} · ${hhmm(t.completedAt!)}'} · ${(_top + k) % n + 1}/$n',
                      style: T.mono(c.textDim, size: 11),
                    ),
                  ],
                ),
              );
              return Positioned(
                left: 0,
                right: 0,
                // Cards behind fan upward so the pile is visible.
                top: (visible - 1 - k) * 9.0,
                bottom: k * 9.0,
                child: Transform.translate(
                  offset: Offset(isTop ? _dx : 0, 0),
                  child: Transform.rotate(
                    angle: isTop ? _dx / 900 : (k.isOdd ? -0.02 : 0.02) * k,
                    child: Transform.scale(
                      scale: 1 - k * 0.04,
                      alignment: Alignment.topCenter,
                      child: isTop
                          ? GestureDetector(
                              onHorizontalDragUpdate: (d) => setState(() => _dx += d.delta.dx),
                              onHorizontalDragEnd: (d) {
                                if (_dx.abs() > 80 || (d.primaryVelocity ?? 0).abs() > 600) {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _top = (_top + 1) % n;
                                    _dx = 0;
                                  });
                                } else {
                                  setState(() => _dx = 0);
                                }
                              },
                              onTap: () => setState(() => _top = (_top + 1) % n),
                              child: card,
                            )
                          : card,
                    ),
                  ),
                ),
              );
            }(),
        ],
      ),
    );
  }
}

Future<void> showDaySheet(BuildContext context, DateTime day, List<Task> tasks) => showExeSheet<void>(
  context,
  builder: (ctx) {
    final c = ctx.c;
    return SheetBody(
      title: dayLabel(day),
      subtitle: tasks.isEmpty ? 'A quiet day. Those count too.' : '${tasks.length} done. Swipe through them.',
      children: [
        if (tasks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: CardStack(tasks: tasks),
          ),
        if (tasks.isEmpty) Icon(Icons.spa_rounded, size: 40, color: c.textDim),
      ],
    );
  },
);

// Trend line ----------------------------------------------------------------

/// A soft, smooth line. Gaps (nulls) are skipped. No axes, no judgement.
class TrendLine extends StatelessWidget {
  const TrendLine({super.key, required this.values, this.maxY, this.height = 70});
  final List<double?> values;
  final double? maxY;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _TrendPainter(values: values, maxY: maxY, c: c),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({required this.values, required this.c, this.maxY});
  final List<double?> values;
  final double? maxY;
  final ExeColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final pts = <Offset>[];
    final top = maxY ?? values.whereType<double>().fold<double>(1, math.max);
    for (var i = 0; i < values.length; i++) {
      final v = values[i];
      if (v == null) continue;
      final x = values.length == 1 ? size.width / 2 : i / (values.length - 1) * size.width;
      final y = size.height - 6 - (v / top).clamp(0.0, 1.0) * (size.height - 12);
      pts.add(Offset(x, y));
    }
    if (pts.length < 2) return;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = pts[i], p1 = pts[i + 1];
      final mx = (p0.dx + p1.dx) / 2;
      path.cubicTo(mx, p0.dy, mx, p1.dy, p1.dx, p1.dy);
    }
    final fill = Path.from(path)
      ..lineTo(pts.last.dx, size.height)
      ..lineTo(pts.first.dx, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            c.accent.withValues(alpha: c.isDark ? 0.18 : 0.3),
            c.accent.withValues(alpha: 0),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = c.isDark ? c.accent : c.accentInk
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(pts.last, 4, Paint()..color = c.isDark ? c.accent : c.accentInk);
  }

  @override
  bool shouldRepaint(_TrendPainter old) => true;
}

// Area tiles ------------------------------------------------------------------

/// One life area: current and best streak, and 30 ticks of attention.
class AreaTile extends StatelessWidget {
  const AreaTile({
    super.key,
    required this.stat,
    this.onFire = false,
    this.needsAttention = false,
    this.onSchedule,
  });
  final AreaStat stat;
  final bool onFire;
  final bool needsAttention;
  final VoidCallback? onSchedule;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final fg = onFire ? c.onAccent : c.text;
    final dim = onFire ? c.onAccent.withValues(alpha: 0.6) : c.textDim;
    return Semantics(
      label:
          '${stat.area.label}: ${stat.streak.current} day streak, best ${stat.streak.best}, '
          '${stat.last30} of the last 30 days.${onFire ? ' On fire.' : ''}${needsAttention ? ' Needs attention.' : ''}',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: onFire ? c.accent : c.surface,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(
            color: onFire ? c.accent : (needsAttention ? c.text.withValues(alpha: 0.5) : c.border),
            width: needsAttention ? 1.2 : 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(stat.area.icon, size: 15, color: onFire ? c.onAccent : c.areaTint(stat.area)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    stat.area.short.toUpperCase(),
                    style: T.label(dim),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onFire) Text('ON FIRE', style: T.label(c.onAccent).copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${stat.streak.current}', style: T.number(fg, size: 36)),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'day${stat.streak.current == 1 ? '' : 's'} · best ${stat.streak.best}',
                    style: T.mono(dim, size: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final on in stat.attention)
                  Expanded(
                    child: Container(
                      height: 14,
                      margin: const EdgeInsets.symmetric(horizontal: 0.6),
                      decoration: BoxDecoration(
                        color: on
                            ? (onFire ? c.onAccent : (c.isDark ? c.accent : c.accentInk))
                            : (onFire ? c.onAccent.withValues(alpha: 0.12) : c.surface2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text('${stat.last30}/30 days', style: T.mono(dim, size: 10)),
            if (needsAttention) ...[
              const SizedBox(height: 10),
              Text('Needs attention', style: T.small(c.text)),
              const SizedBox(height: 8),
              Semantics(
                button: true,
                label: 'Schedule 15 minutes of ${stat.area.label} today',
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: onSchedule,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: c.text, borderRadius: BorderRadius.circular(12)),
                    child: Text('+ 15 min today', style: T.mono(c.bg, size: 11, w: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
