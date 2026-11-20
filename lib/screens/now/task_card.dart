import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/database.dart';
import '../../models/dates.dart';
import '../../models/enums.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';

/// One card in the Now deck. Swipe up to complete (flies off with a snap),
/// swipe down to snooze. Sideways swipes belong to the deck.
class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.active,
    required this.onComplete,
    required this.onSnooze,
    required this.onEdit,
    this.block,
    this.now,
    this.hint,
  });

  final Task task;
  final TimeBlock? block;
  final bool active;
  final DateTime? now;

  /// Small lemon nudge on the card (e.g. "Hardest first" on a high-energy day).
  final String? hint;
  final Future<void> Function() onComplete;
  final Future<void> Function() onSnooze;
  final VoidCallback onEdit;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  late final AnimationController _fly = AnimationController.unbounded(vsync: this);
  double _drag = 0;
  bool _gone = false;

  @override
  void dispose() {
    _fly.dispose();
    super.dispose();
  }

  Future<void> _release(DragEndDetails d, double h) async {
    final v = d.primaryVelocity ?? 0;
    final up = _drag < -h * 0.18 || v < -900;
    final down = _drag > h * 0.18 || v > 900;
    if (!up && !down) {
      // Spring back.
      _fly.value = _drag;
      setState(() => _drag = 0);
      await _fly.animateTo(0, duration: context.motion(Motion.med), curve: Curves.easeOutBack);
      return;
    }
    final target = up ? -h * 1.4 : h * 1.4;
    _fly.value = _drag;
    setState(() {
      _drag = 0;
      _gone = true;
    });
    if (up) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
    await _fly.animateTo(target, duration: context.motion(Motion.slow), curve: Curves.easeInCubic);
    if (up) {
      await widget.onComplete();
    } else {
      await widget.onSnooze();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.task;
    return LayoutBuilder(
      builder: (context, box) {
        final h = box.maxHeight;
        return GestureDetector(
          onVerticalDragUpdate: (d) => setState(() => _drag += d.delta.dy),
          onVerticalDragEnd: (d) => _release(d, h),
          onLongPress: () {
            HapticFeedback.mediumImpact();
            widget.onEdit();
          },
          child: AnimatedBuilder(
            animation: _fly,
            builder: (context, child) {
              final dy = _gone || _fly.isAnimating ? _fly.value : _drag;
              final tilt = (dy / h).clamp(-1.0, 1.0) * 0.06;
              final pull = (dy.abs() / (h * 0.18)).clamp(0.0, 1.0);
              return Transform.translate(
                offset: Offset(0, dy),
                child: Transform.rotate(
                  angle: tilt,
                  child: Stack(
                    children: [
                      child!,
                      if (pull > 0)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: _SwipeHint(up: dy < 0, amount: pull),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
            child: _CardFace(
              task: t,
              block: widget.block,
              active: widget.active,
              now: widget.now,
              hint: widget.hint,
            ),
          ),
        );
      },
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({required this.task, required this.active, this.block, this.now, this.hint});
  final Task task;
  final TimeBlock? block;
  final bool active;
  final DateTime? now;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = task;
    final n = now ?? DateTime.now();
    final inBlock = block != null && !n.isBefore(block!.startAt) && n.isBefore(block!.endAt);
    final countdown = inBlock ? block!.endAt.difference(n) : Duration(minutes: t.estimatedMinutes);
    final sub = inBlock
        ? 'left in block · ${hhmm(block!.startAt)}–${hhmm(block!.endAt)}'
        : block != null
        ? 'planned ${hhmm(block!.startAt)}–${hhmm(block!.endAt)}'
        : 'estimated';
    final titleSize = t.title.length > 48 ? 30.0 : (t.title.length > 28 ? 36.0 : 44.0);

    return Semantics(
      label:
          '${t.title}. ${t.area.label}. '
          '${t.firstStep != null ? 'First step: ${t.firstStep}. ' : ''}'
          'Swipe up to complete, down to snooze, long press to edit.',
      child: AnimatedContainer(
        duration: context.motion(Motion.med),
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.big),
          border: Border.all(
            color: active ? c.accentInk.withValues(alpha: c.isDark ? 0.55 : 0.8) : c.border,
            width: active ? 1.2 : 0.8,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: c.accent.withValues(alpha: c.isDark ? 0.08 : 0.18),
                    blurRadius: 40,
                    spreadRadius: -8,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(t.area.icon, size: 15, color: c.areaTint(t.area)),
                const SizedBox(width: 6),
                Text(t.area.label.toUpperCase(), style: T.label(c.textDim)),
                const Spacer(),
                if (t.topRank != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(8)),
                    child: Text('TOP ${t.topRank}', style: T.label(c.onAccent)),
                  )
                else if (t.status == TaskStatus.snoozed)
                  Text('SNOOZED', style: T.label(c.textDim)),
              ],
            ),
            if (hint != null) ...[const SizedBox(height: Space.s), Text(hint!, style: T.small(c.accentInk))],
            const SizedBox(height: Space.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Hero(
                      tag: 'task-title-${t.id}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          t.title,
                          style: T.display(c.text).copyWith(fontSize: titleSize),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  if (t.firstStep != null) ...[
                    const SizedBox(height: Space.l),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 7),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: c.accentInk, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('FIRST STEP', style: T.label(c.textDim)),
                              const SizedBox(height: 3),
                              Text(
                                t.firstStep!,
                                style: T.bodyStrong(c.text),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                clock(countdown),
                style: T.mega(active ? c.text : c.textDim).copyWith(fontSize: 76),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(sub, style: T.mono(c.textDim, size: 12)),
                const Spacer(),
                Icon(Icons.arrow_upward_rounded, size: 13, color: c.textDim),
                Text(' done  ', style: T.mono(c.textDim, size: 11)),
                Icon(Icons.arrow_downward_rounded, size: 13, color: c.textDim),
                Text(' later', style: T.mono(c.textDim, size: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint({required this.up, required this.amount});
  final bool up;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final bg = up ? c.accent : c.surface2;
    final fg = up ? c.onAccent : c.text;
    return Opacity(
      opacity: amount * 0.92,
      child: Container(
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Radii.big)),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(up ? Icons.check_rounded : Icons.snooze_rounded, size: 56, color: fg),
            const SizedBox(height: 8),
            Text(up ? 'Done' : 'Later', style: T.h2(fg)),
          ],
        ),
      ),
    );
  }
}
