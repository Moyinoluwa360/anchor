import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/database.dart';
import '../../models/dates.dart';
import '../../models/enums.dart';
import '../../services/planner_service.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'dial_painter.dart';

enum _Mode { none, create, resizeStart, resizeEnd, pinch }

/// The circular 24-hour planner. Drag on the ring to create a block, drag a
/// selected block's ends to resize, tap a block to edit it, pinch or
/// double-tap to zoom between 24 h and a 6-hour window, and drop task chips
/// onto the ring to schedule them.
class DayDial extends StatefulWidget {
  const DayDial({
    super.key,
    required this.day,
    required this.now,
    required this.blocks,
    required this.capacity,
    required this.zoomed,
    required this.onZoom,
    required this.onCreate,
    required this.onResize,
    required this.onTapBlock,
    required this.onDropTask,
    required this.center,
    this.preview = const [],
    this.previewProgress = 1,
    this.selectedId,
  });

  final DateTime day;
  final DateTime now;
  final List<TimeBlock> blocks;
  final Capacity capacity;
  final bool zoomed;
  final ValueChanged<bool> onZoom;
  final void Function(DateTime start, DateTime end) onCreate;
  final void Function(TimeBlock b, DateTime start, DateTime end) onResize;
  final ValueChanged<TimeBlock> onTapBlock;
  final void Function(Task t, DateTime start) onDropTask;
  final Widget center;
  final List<BlockDraft> preview;
  final double previewProgress;
  final int? selectedId;

  @override
  State<DayDial> createState() => _DayDialState();
}

class _DayDialState extends State<DayDial> {
  _Mode _mode = _Mode.none;
  TimeBlock? _target;
  DateTime? _anchor;
  DateTime? _ghostStart;
  DateTime? _ghostEnd;
  double _pinchScale = 1;
  DateTime? _lastSnap;
  Offset? _hover; // drag-target hover point

  DialWindow get _window => widget.zoomed ? DialWindow.focused(widget.now) : DialWindow.fullDay;

  double _angle(Offset local, Size size) {
    final g = DialGeometry(size, zoomed: widget.zoomed);
    final d = local - g.center;
    return PlannerService.angleFromOffset(d.dx, d.dy);
  }

  DateTime _timeAt(Offset local, Size size) =>
      PlannerService.timeAt(_angle(local, size), widget.day, _window);

  TimeBlock? _blockAt(DateTime t) {
    for (final b in widget.blocks.reversed) {
      if (!t.isBefore(b.startAt) && t.isBefore(b.endAt)) return b;
    }
    return null;
  }

  void _tick(DateTime t) {
    if (_lastSnap != t) {
      _lastSnap = t;
      HapticFeedback.selectionClick();
    }
  }

  void _start(ScaleStartDetails d, Size size) {
    if (d.pointerCount > 1) {
      _mode = _Mode.pinch;
      _pinchScale = 1;
      return;
    }
    final g = DialGeometry(size, zoomed: widget.zoomed);
    if (!g.onRing(d.localFocalPoint)) {
      _mode = _Mode.none;
      return;
    }
    final a = _angle(d.localFocalPoint, size);
    final tol = widget.zoomed ? 0.16 : 0.07;
    // Ends of the selected block (or any block) start a resize.
    for (final b in widget.blocks) {
      if (widget.selectedId != null && b.id != widget.selectedId) continue;
      final a0 = PlannerService.angleOf(b.startAt, widget.day, _window);
      final a1 = PlannerService.angleOf(b.endAt, widget.day, _window);
      if ((a - a0).abs() < tol) {
        _begin(_Mode.resizeStart, b);
        return;
      }
      if ((a - a1).abs() < tol) {
        _begin(_Mode.resizeEnd, b);
        return;
      }
    }
    final t = _timeAt(d.localFocalPoint, size);
    if (_blockAt(t) != null) {
      _mode = _Mode.none; // body drag does nothing; tap edits
      return;
    }
    setState(() {
      _mode = _Mode.create;
      _anchor = t;
      _ghostStart = t;
      _ghostEnd = t.add(const Duration(minutes: 15));
    });
    HapticFeedback.lightImpact();
  }

  void _begin(_Mode m, TimeBlock b) {
    setState(() {
      _mode = m;
      _target = b;
      _ghostStart = b.startAt;
      _ghostEnd = b.endAt;
    });
    HapticFeedback.lightImpact();
  }

  void _update(ScaleUpdateDetails d, Size size) {
    switch (_mode) {
      case _Mode.pinch:
        _pinchScale = d.scale;
      case _Mode.create:
        final t = _timeAt(d.localFocalPoint, size);
        _tick(t);
        final a = _anchor!;
        var s = t.isBefore(a) ? t : a;
        var e = t.isBefore(a) ? a : t;
        if (e.difference(s).inMinutes < 15) e = s.add(const Duration(minutes: 15));
        if (e.difference(s).inHours > 12) s = e.subtract(const Duration(hours: 12));
        setState(() {
          _ghostStart = s;
          _ghostEnd = e;
        });
      case _Mode.resizeStart:
        final t = _timeAt(d.localFocalPoint, size);
        _tick(t);
        if (_ghostEnd!.difference(t).inMinutes >= 15) setState(() => _ghostStart = t);
      case _Mode.resizeEnd:
        var t = _timeAt(d.localFocalPoint, size);
        if (t == dayOf(widget.day) && _ghostStart!.isAfter(t)) t = addDays(dayOf(widget.day), 1);
        _tick(t);
        if (t.difference(_ghostStart!).inMinutes >= 15) setState(() => _ghostEnd = t);
      case _Mode.none:
        break;
    }
  }

  void _end() {
    switch (_mode) {
      case _Mode.pinch:
        if (_pinchScale > 1.15 && !widget.zoomed) widget.onZoom(true);
        if (_pinchScale < 0.87 && widget.zoomed) widget.onZoom(false);
      case _Mode.create:
        if (_ghostStart != null && _ghostEnd != null) {
          HapticFeedback.mediumImpact();
          widget.onCreate(_ghostStart!, _ghostEnd!);
        }
      case _Mode.resizeStart:
      case _Mode.resizeEnd:
        if (_target != null && (_ghostStart != _target!.startAt || _ghostEnd != _target!.endAt)) {
          HapticFeedback.mediumImpact();
          widget.onResize(_target!, _ghostStart!, _ghostEnd!);
        }
      case _Mode.none:
        break;
    }
    setState(() {
      _mode = _Mode.none;
      _target = null;
      _anchor = null;
      _ghostStart = null;
      _ghostEnd = null;
      _lastSnap = null;
    });
  }

  void _tap(TapUpDetails d, Size size) {
    final g = DialGeometry(size, zoomed: widget.zoomed);
    if (!g.onRing(d.localPosition, slop: 10)) return;
    final m = PlannerService.minutesAt(_angle(d.localPosition, size), _window);
    final t = dayOf(widget.day).add(Duration(minutes: m.round()));
    final b = _blockAt(t);
    if (b != null) {
      HapticFeedback.selectionClick();
      widget.onTapBlock(b);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return LayoutBuilder(
      builder: (context, box) {
        final side = math.min(box.maxWidth, box.maxHeight);
        final size = Size.square(side);

        final arcs = <DialArc>[
          for (final b in widget.blocks)
            // While a suggestion is previewed, hide the blocks it would replace.
            if (_target?.id != b.id && (widget.preview.isEmpty || PlannerService.isLocked(b, widget.now)))
              DialArc(
                start: b.startAt,
                end: b.endAt,
                type: b.type,
                id: b.id,
                selected: b.id == widget.selectedId,
              ),
          for (var i = 0; i < widget.preview.length; i++)
            DialArc(
              start: widget.preview[i].start,
              end: widget.preview[i].end,
              type: widget.preview[i].type,
              preview: true,
              grow: ((widget.previewProgress * (widget.preview.length + 2)) - i).clamp(0.0, 1.0),
            ),
        ];
        DialArc? ghost;
        if (_ghostStart != null && _ghostEnd != null) {
          ghost = DialArc(start: _ghostStart!, end: _ghostEnd!, type: _target?.type ?? BlockType.focus);
        } else if (_hover != null) {
          final t = _timeAt(_hover!, size);
          ghost = DialArc(start: t, end: t.add(const Duration(minutes: 30)), type: BlockType.focus);
        }

        return Center(
          child: SizedBox.square(
            dimension: side,
            child: DragTarget<Task>(
              onMove: (d) {
                final rb = context.findRenderObject() as RenderBox?;
                if (rb == null) return;
                final local =
                    rb.globalToLocal(d.offset + const Offset(50, 18)) -
                    Offset((box.maxWidth - side) / 2, (box.maxHeight - side) / 2);
                setState(() => _hover = local);
              },
              onLeave: (_) => setState(() => _hover = null),
              onAcceptWithDetails: (d) {
                final rb = context.findRenderObject() as RenderBox?;
                if (rb == null) return;
                final local =
                    rb.globalToLocal(d.offset + const Offset(50, 18)) -
                    Offset((box.maxWidth - side) / 2, (box.maxHeight - side) / 2);
                setState(() => _hover = null);
                HapticFeedback.heavyImpact();
                widget.onDropTask(d.data, _timeAt(local, size));
              },
              builder: (context, _, _) => Semantics(
                label:
                    'Day dial. ${widget.blocks.length} blocks planned. '
                    'Drag on the ring to add a block; double tap to zoom.',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onScaleStart: (d) => _start(d, size),
                  onScaleUpdate: (d) => _update(d, size),
                  onScaleEnd: (_) => _end(),
                  onTapUp: (d) => _tap(d, size),
                  onDoubleTap: () {
                    HapticFeedback.selectionClick();
                    widget.onZoom(!widget.zoomed);
                  },
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: size,
                        painter: DialPainter(
                          c: c,
                          day: widget.day,
                          window: _window,
                          now: widget.now,
                          arcs: arcs,
                          capacity: widget.capacity,
                          zoomed: widget.zoomed,
                          ghost: ghost,
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: SizedBox.square(
                            dimension: (DialGeometry(size, zoomed: widget.zoomed).capacityRadius - 12) * 2,
                            child: Center(
                              // Scales down inside the ring with large text sizes.
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        (DialGeometry(size, zoomed: widget.zoomed).capacityRadius - 12) * 2,
                                  ),
                                  child: widget.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (ghost != null && _hover == null)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: side * 0.5 + DialGeometry(size, zoomed: widget.zoomed).capacityRadius - 30,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: c.text,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${hhmm(ghost.start)}–${hhmm(ghost.end)}',
                                style: T.mono(c.bg, w: FontWeight.w700),
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
      },
    );
  }
}

/// A small floating task chip that can be dragged onto the dial.
class TaskChip extends StatelessWidget {
  const TaskChip({super.key, required this.task, this.onTap});
  final Task task;
  final VoidCallback? onTap;

  Widget _face(BuildContext context, {bool lifted = false}) {
    final c = context.c;
    return Material(
      type: MaterialType.transparency,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 118),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: lifted ? c.accent : c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: lifted ? c.accent : c.border, width: 0.8),
          boxShadow: lifted
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(task.area.icon, size: 12, color: lifted ? c.onAccent : c.areaTint(task.area)),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: T.small(lifted ? c.onAccent : c.text).copyWith(fontSize: 11.5),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              minutesLabel(task.estimatedMinutes),
              style: T.mono(lifted ? c.onAccent : c.textDim, size: 10),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${task.title}, ${minutesLabel(task.estimatedMinutes)}. Drag onto the dial to schedule.',
      child: LongPressDraggable<Task>(
        data: task,
        delay: const Duration(milliseconds: 120),
        hapticFeedbackOnStart: true,
        feedback: _face(context, lifted: true),
        childWhenDragging: Opacity(opacity: 0.3, child: _face(context)),
        child: GestureDetector(onTap: onTap, child: _face(context)),
      ),
    );
  }
}
