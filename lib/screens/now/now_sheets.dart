import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../models/dates.dart';
import '../../models/enums.dart';
import '../../services/timer_logic.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/sheet.dart';

sealed class StuckChoice {
  const StuckChoice();
}

class ShrinkIt extends StuckChoice {
  const ShrinkIt(this.firstStep);
  final String firstStep;
}

class SwapTo extends StuckChoice {
  const SwapTo(this.task);
  final Task task;
}

class ResetBreak extends StuckChoice {
  const ResetBreak();
}

/// "Stuck?": shrink the task to a 5-minute starter, swap it for something
/// easier, or take a 5-minute reset.
Future<StuckChoice?> showStuckSheet(BuildContext context, Task task, List<Task> easier) {
  return showExeSheet<StuckChoice>(
    context,
    builder: (_) => _StuckSheet(task: task, easier: easier),
  );
}

class _StuckSheet extends StatefulWidget {
  const _StuckSheet({required this.task, required this.easier});
  final Task task;
  final List<Task> easier;

  @override
  State<_StuckSheet> createState() => _StuckSheetState();
}

class _StuckSheetState extends State<_StuckSheet> {
  late final _step = TextEditingController(text: widget.task.firstStep ?? _suggest(widget.task));
  bool _shrinking = false;

  static String _suggest(Task t) => switch (t.area) {
    LifeArea.startup => 'Open the project and write one sentence about the next change',
    LifeArea.cloud => 'Open the course and watch just the first 5 minutes',
    LifeArea.sideGigs => 'Open the editor and drop in the first clip',
    LifeArea.health => 'Put on your shoes and step outside',
    LifeArea.personal => 'Do the smallest visible part for 5 minutes',
  };

  @override
  void dispose() {
    _step.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SheetBody(
      title: 'Stuck? Totally normal.',
      subtitle: 'Fog lifts once you start. Pick the gentlest way in.',
      children: [
        _Option(
          icon: Icons.compress_rounded,
          title: 'Shrink it to 5 minutes',
          body: 'One tiny starter step, then decide.',
          onTap: () => setState(() => _shrinking = !_shrinking),
          expanded: _shrinking,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Space.m),
              TextField(
                controller: _step,
                maxLines: 2,
                minLines: 1,
                style: T.body(c.text),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: Space.m),
              PrimaryButton(
                label: 'Start 5 minutes',
                height: 52,
                onTap: () {
                  final s = _step.text.trim();
                  Navigator.pop(context, ShrinkIt(s.isEmpty ? _suggest(widget.task) : s));
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.m),
        _Option(
          icon: Icons.swap_horiz_rounded,
          title: 'Swap for an easier one',
          body: widget.easier.isEmpty
              ? 'This is already the lightest thing today.'
              : 'Momentum first, big thing after.',
          onTap: null,
          expanded: widget.easier.isNotEmpty,
          child: Column(
            children: [
              const SizedBox(height: Space.s),
              for (final t in widget.easier)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pop(context, SwapTo(t)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Icon(t.area.icon, size: 16, color: c.areaTint(t.area)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            t.title,
                            style: T.body(c.text),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(minutesLabel(t.estimatedMinutes), style: T.mono(c.textDim)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: Space.m),
        _Option(
          icon: Icons.self_improvement_rounded,
          title: 'Take a 5-minute reset',
          body: 'Water, window, breathe. Then come back.',
          onTap: () => Navigator.pop(context, const ResetBreak()),
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
    this.child,
    this.expanded = false,
  });
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? onTap;
  final Widget? child;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: c.border, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: c.bg, shape: BoxShape.circle),
                  child: Icon(icon, size: 20, color: c.accentInk),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: T.bodyStrong(c.text)),
                      Text(body, style: T.small(c.textDim)),
                    ],
                  ),
                ),
              ],
            ),
            if (child != null)
              AnimatedSize(
                duration: context.motion(Motion.med),
                curve: Motion.curve,
                child: expanded ? child! : const SizedBox(width: double.infinity),
              ),
          ],
        ),
      ),
    );
  }
}

/// Pick 25/5, 50/10, 90/20 or a custom focus/break length.
Future<TimerPreset?> showPresetSheet(BuildContext context, TimerPreset current) {
  return showExeSheet<TimerPreset>(context, builder: (_) => _PresetSheet(current: current));
}

class _PresetSheet extends StatefulWidget {
  const _PresetSheet({required this.current});
  final TimerPreset current;

  @override
  State<_PresetSheet> createState() => _PresetSheetState();
}

class _PresetSheetState extends State<_PresetSheet> {
  late double _focus = widget.current.focus.toDouble();
  late double _brk = widget.current.brk.toDouble();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final custom = TimerPreset(_focus.round(), _brk.round());
    return SheetBody(
      title: 'Focus rhythm',
      subtitle: 'Every focus block ends with a break. That part is not optional.',
      children: [
        Row(
          children: [
            for (final p in timerPresets) ...[
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, p),
                  child: Container(
                    height: 96,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: p == widget.current ? c.accent : c.surface2,
                      borderRadius: BorderRadius.circular(Radii.card),
                      border: Border.all(color: c.border, width: 0.8),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${p.focus}',
                          style: T.number(p == widget.current ? c.onAccent : c.text, size: 34),
                        ),
                        Text(
                          '+${p.brk} break',
                          style: T.mono(p == widget.current ? c.onAccent : c.textDim, size: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const FieldLabel('Custom'),
        Row(
          children: [
            SizedBox(width: 70, child: Text('Focus', style: T.small(c.textDim))),
            Expanded(
              child: Slider(
                value: _focus,
                min: 5,
                max: 180,
                divisions: 35,
                label: '${_focus.round()}m',
                onChanged: (v) => setState(() => _focus = v),
              ),
            ),
            SizedBox(
              width: 48,
              child: Text('${_focus.round()}m', style: T.mono(c.text), textAlign: TextAlign.right),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(width: 70, child: Text('Break', style: T.small(c.textDim))),
            Expanded(
              child: Slider(
                value: _brk,
                min: 1,
                max: 45,
                divisions: 44,
                label: '${_brk.round()}m',
                onChanged: (v) => setState(() => _brk = v),
              ),
            ),
            SizedBox(
              width: 48,
              child: Text('${_brk.round()}m', style: T.mono(c.text), textAlign: TextAlign.right),
            ),
          ],
        ),
        const SizedBox(height: Space.l),
        PrimaryButton(label: 'Use ${custom.label}', height: 54, onTap: () => Navigator.pop(context, custom)),
      ],
    );
  }
}
