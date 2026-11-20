import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/database.dart';
import '../../models/dates.dart';
import '../../models/enums.dart';
import '../../services/planner_service.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'dial_painter.dart';

/// Flat timeline of the same blocks for precise editing: drag a block to move
/// it, drag its bottom edge to resize, tap empty space to add an hour.
class TimelineView extends StatefulWidget {
  const TimelineView({
    super.key,
    required this.day,
    required this.now,
    required this.blocks,
    required this.taskTitles,
    required this.onTap,
    required this.onChange,
    required this.onCreate,
    required this.bottomPadding,
  });

  final DateTime day;
  final DateTime now;
  final List<TimeBlock> blocks;
  final Map<int, String> taskTitles;
  final ValueChanged<TimeBlock> onTap;
  final void Function(TimeBlock b, DateTime start, DateTime end) onChange;
  final void Function(DateTime start, DateTime end) onCreate;
  final double bottomPadding;

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  static const hourH = 72.0;
  static const gutter = 56.0;
  late final ScrollController _sc = ScrollController(
    initialScrollOffset: ((widget.now.hour - 1).clamp(0, 23)) * hourH,
  );
  int? _dragId;
  double _dragDy = 0;
  bool _resizing = false;

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  double _y(DateTime t) => t.difference(widget.day).inMinutes / 60 * hourH;
  int _snapMinutes(double dy) => PlannerService.snap(dy / hourH * 60);

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final total = 24 * hourH;
    final nowY = _y(widget.now);
    return SingleChildScrollView(
      controller: _sc,
      padding: EdgeInsets.only(bottom: widget.bottomPadding, top: 8),
      child: SizedBox(
        height: total + 20,
        child: LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth - gutter - Space.gutter;
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapUp: (d) {
                final m = PlannerService.snap(d.localPosition.dy / hourH * 60, 30);
                final s = widget.day.add(Duration(minutes: m.clamp(0, 23 * 60)));
                final hit = widget.blocks.any((b) => !s.isBefore(b.startAt) && s.isBefore(b.endAt));
                if (!hit && d.localPosition.dx > gutter) widget.onCreate(s, s.add(const Duration(hours: 1)));
              },
              child: Stack(
                children: [
                  for (var h = 0; h <= 24; h++) ...[
                    Positioned(
                      top: h * hourH,
                      left: gutter,
                      right: Space.gutter,
                      child: Container(height: 0.6, color: c.border),
                    ),
                    if (h < 24)
                      Positioned(
                        top: h * hourH - 7,
                        left: Space.gutter,
                        child: Text(h.toString().padLeft(2, '0'), style: T.mono(c.textDim, size: 11)),
                      ),
                  ],
                  for (final b in widget.blocks) _block(context, b, w),
                  if (sameDay(widget.now, widget.day))
                    Positioned(
                      top: nowY - 4,
                      left: gutter - 4,
                      right: Space.gutter,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: c.isDark ? c.accent : c.accentInk,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(child: Container(height: 1.6, color: c.isDark ? c.accent : c.accentInk)),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _block(BuildContext context, TimeBlock b, double width) {
    final c = context.c;
    final dragging = _dragId == b.id;
    final moveBy = dragging && !_resizing ? _snapMinutes(_dragDy) : 0;
    final growBy = dragging && _resizing ? _snapMinutes(_dragDy) : 0;
    final s = b.startAt.add(Duration(minutes: moveBy));
    var e = b.endAt.add(Duration(minutes: moveBy + growBy));
    if (e.difference(s).inMinutes < 15) e = s.add(const Duration(minutes: 15));
    final top = _y(s);
    final h = (_y(e) - top).clamp(24.0, 24 * hourH);
    final compact = h < 40;
    final color = arcColor(c, b.type);
    final solid = b.type == BlockType.focus || b.type == BlockType.fixed;
    final fg = solid ? (b.type == BlockType.fixed ? c.bg : c.onAccent) : c.text;
    final title = b.taskId != null && widget.taskTitles[b.taskId] != null
        ? widget.taskTitles[b.taskId]!
        : (b.label.isEmpty ? b.type.label : b.label);

    void finish() {
      if (moveBy != 0 || growBy != 0) {
        HapticFeedback.mediumImpact();
        widget.onChange(b, s, e);
      }
      setState(() {
        _dragId = null;
        _dragDy = 0;
        _resizing = false;
      });
    }

    return Positioned(
      top: top + 1,
      left: gutter + 6,
      width: width - 6,
      height: h - 2,
      child: Semantics(
        button: true,
        label: '$title, ${hhmm(s)} to ${hhmm(e)}. Drag to move.',
        child: GestureDetector(
          onTap: () => widget.onTap(b),
          onVerticalDragStart: (_) => setState(() {
            _dragId = b.id;
            _resizing = false;
            HapticFeedback.lightImpact();
          }),
          onVerticalDragUpdate: (d) => setState(() => _dragDy += d.delta.dy),
          onVerticalDragEnd: (_) => finish(),
          child: AnimatedScale(
            scale: dragging ? 1.02 : 1,
            duration: context.motion(Motion.fast),
            child: Container(
              padding: EdgeInsets.fromLTRB(12, compact ? 2 : 6, 10, 0),
              alignment: compact ? Alignment.centerLeft : Alignment.topLeft,
              decoration: BoxDecoration(
                color: solid ? color : c.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: solid ? color : c.border, width: 0.8),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!solid)
                        Container(
                          width: 3,
                          height: (h - 16).clamp(6.0, 40.0),
                          margin: const EdgeInsets.only(right: 8, top: 2),
                          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                        ),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: h > 50 ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: T.small(fg).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text('${hhmm(s)}–${hhmm(e)}', style: T.mono(fg.withValues(alpha: 0.7), size: 10)),
                    ],
                  ),
                  // Bottom-edge resize handle.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: -4,
                    height: 18,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragStart: (_) => setState(() {
                        _dragId = b.id;
                        _resizing = true;
                        HapticFeedback.lightImpact();
                      }),
                      onVerticalDragUpdate: (d) => setState(() => _dragDy += d.delta.dy),
                      onVerticalDragEnd: (_) => finish(),
                      child: Center(
                        child: Container(
                          width: 28,
                          height: 3,
                          decoration: BoxDecoration(
                            color: fg.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
