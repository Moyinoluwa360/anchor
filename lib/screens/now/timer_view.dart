import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../models/dates.dart';
import '../../providers/data_providers.dart';
import '../../services/timer_logic.dart';
import '../../services/timer_service.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/timer_ring.dart';

/// Full-screen timer: the card has become a giant draining lemon ring.
class TimerView extends ConsumerStatefulWidget {
  const TimerView({super.key, this.task});
  final Task? task;

  @override
  ConsumerState<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends ConsumerState<TimerView> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Repaint every frame so the ring drains smoothly; text only changes per second.
    _ticker = createTicker((_) => setState(() => _now = ref.read(clockProvider)()))..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final s = ref.watch(timerProvider);
    final timer = ref.read(timerProvider.notifier);
    final isBreak = s.phase == TimerPhase.breakTime;
    final ringColor = isBreak ? c.text : c.accent;
    final remaining = s.remaining(_now);
    final size = MediaQuery.sizeOf(context);
    final ring = (size.width - 40).clamp(220.0, 360.0);
    final pad = MediaQuery.paddingOf(context);

    final label = isBreak
        ? (s.focusMinutes == 0 ? 'RESET · ${s.breakMinutes} MIN' : 'BREAK · ${s.breakMinutes} MIN')
        : 'FOCUS · ${s.total.inMinutes} MIN';
    final title = isBreak ? 'Step away. Breathe.' : (widget.task?.title ?? 'Focus');

    return Padding(
      padding: EdgeInsets.fromLTRB(Space.gutter, pad.top + 16, Space.gutter, pad.bottom + 16),
      child: Column(
        children: [
          Row(
            children: [
              Text(label, style: T.label(isBreak ? c.textDim : c.accentInk)),
              const Spacer(),
              if (s.isPaused) Text('PAUSED', style: T.label(c.textDim)),
            ],
          ),
          const SizedBox(height: Space.m),
          Align(
            alignment: Alignment.centerLeft,
            child: Hero(
              tag: 'task-title-${widget.task?.id}',
              child: Material(
                type: MaterialType.transparency,
                child: Text(title, style: T.h1(c.text), maxLines: 3, overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
          if (!isBreak && widget.task?.firstStep != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Start with: ${widget.task!.firstStep}', style: T.body(c.textDim)),
            ),
          ],
          const Spacer(),
          Semantics(
            label:
                '${isBreak ? 'Break' : 'Focus'} timer, ${remaining.inMinutes} minutes '
                '${remaining.inSeconds % 60} seconds left',
            excludeSemantics: true,
            child: SizedBox(
              width: ring,
              height: ring,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size.square(ring),
                    painter: TimerRingPainter(
                      fraction: s.fraction(_now),
                      color: ringColor,
                      track: c.surface2,
                      tick: c.border,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        child: Text(
                          clock(remaining + const Duration(milliseconds: 999)),
                          style: T.mega(c.text).copyWith(fontSize: ring * 0.24),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (s.endsAt != null && s.isRunning)
                        Text('ends ${hhmm(s.endsAt!)}', style: T.mono(c.textDim, size: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoundButton(
                icon: Icons.stop_rounded,
                label: isBreak ? 'End break' : 'Stop timer',
                onTap: isBreak ? null : timer.stop,
              ),
              const SizedBox(width: 22),
              RoundButton(
                icon: s.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                label: s.isPaused ? 'Resume' : 'Pause',
                size: 84,
                filled: true,
                onTap: s.isPaused ? timer.resume : timer.pause,
              ),
              const SizedBox(width: 22),
              RoundButton(icon: Icons.add_rounded, label: 'Add 5 minutes', onTap: timer.extend),
            ],
          ),
          const SizedBox(height: Space.xl),
          if (!isBreak && widget.task != null)
            PrimaryButton(
              label: 'Done with this',
              icon: Icons.check_rounded,
              onTap: () async {
                await ref.read(taskRepoProvider).complete(widget.task!.id);
                await timer.finishFocusEarly();
              },
            )
          else if (isBreak)
            _HoldToEnd(onDone: timer.stop),
        ],
      ),
    );
  }
}

/// Breaks are protected: ending one early takes a deliberate long press.
class _HoldToEnd extends StatefulWidget {
  const _HoldToEnd({required this.onDone});
  final VoidCallback onDone;

  @override
  State<_HoldToEnd> createState() => _HoldToEndState();
}

class _HoldToEndState extends State<_HoldToEnd> with SingleTickerProviderStateMixin {
  late final _a = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        widget.onDone();
      }
    });

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      button: true,
      label: 'Hold to end the break early',
      onTap: widget.onDone,
      excludeSemantics: true,
      child: GestureDetector(
        onLongPressStart: (_) => _a.forward(from: 0),
        onLongPressEnd: (_) {
          if (_a.status != AnimationStatus.completed) _a.reverse();
        },
        child: AnimatedBuilder(
          animation: _a,
          builder: (context, _) => Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: c.border),
              gradient: LinearGradient(
                colors: [c.surface2, c.surface2, c.surface, c.surface],
                stops: [0, _a.value, _a.value, 1],
              ),
            ),
            alignment: Alignment.center,
            child: Text('Hold to end break early', style: T.small(c.textDim)),
          ),
        ),
      ),
    );
  }
}
