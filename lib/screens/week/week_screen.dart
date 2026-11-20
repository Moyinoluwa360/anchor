import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../models/dates.dart';
import '../../models/enums.dart';
import '../../providers/data_providers.dart';
import '../../providers/settings.dart';
import '../../providers/week_providers.dart';
import '../../router.dart';
import '../../services/progress_service.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/glass_bottom_bar.dart';
import '../../widgets/goal_sheets.dart';
import '../../widgets/screen_header.dart';

/// Week: a bento board of mixed-size tiles, not a list.
class WeekScreen extends ConsumerStatefulWidget {
  const WeekScreen({super.key, this.openReview = false});
  final bool openReview;

  @override
  ConsumerState<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends ConsumerState<WeekScreen> {
  int? _dragging;

  @override
  void initState() {
    super.initState();
    if (widget.openReview) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.push(Routes.review);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final now = ref.watch(minuteTickProvider).value ?? DateTime.now();
    final ws = ref.watch(weekStartProvider);
    final blocks = ref.watch(weekBlocksProvider).value ?? const <TimeBlock>[];
    final sessions = ref.watch(weekSessionsProvider).value ?? const <FocusSession>[];
    final targets = ref.watch(weekTargetsProvider).value ?? const <WeeklyTarget>[];
    final tasks = ref.watch(allTasksProvider).value ?? const <Task>[];
    final goals = ref.watch(goalsProvider).value ?? const <Goal>[];
    final milestones = ref.watch(milestonesProvider).value ?? const <Milestone>[];
    final healthy = ref.watch(settingsProvider.select((s) => s.healthyHours));

    final load = ProgressService.weekLoad(blocks, ws);
    final doneWeek = tasks
        .where((t) => t.status == TaskStatus.done && t.completedAt != null && !t.completedAt!.isBefore(ws))
        .where((t) => t.completedAt!.isBefore(addDays(ws, 7)))
        .toList();
    final doneByDay = ProgressService.doneByDay(doneWeek, ws);
    final focusH = ProgressService.focusHours(sessions, ws, addDays(ws, 7));
    final next = ProgressService.nextMilestone(milestones, now);
    final nextGoal = next == null ? null : goals.firstWhereOrNull((g) => g.id == next.goalId);
    final isSunday = now.weekday == DateTime.sunday;
    final todayIdx = today(now).difference(ws).inDays;

    const gap = 10.0;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ScreenHeader(
            title: 'Week',
            kicker: '${dayLabel(ws)} – ${dayLabel(addDays(ws, 6))}',
            actions: [
              HeaderButton(
                icon: Icons.auto_stories_rounded,
                label: 'Weekly review',
                onTap: () => context.push(Routes.review),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(Space.gutter, Space.l, Space.gutter, GlassBottomBar.reserved(context)),
          sliver: SliverList.list(
            children: [
              if (isSunday) ...[
                _Tile(
                  height: 92,
                  lemon: true,
                  onTap: () => context.push(Routes.review),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('IT\'S SUNDAY', style: T.label(c.onAccent)),
                            const SizedBox(height: 4),
                            Text('Close the week in 3 cards', style: T.h3(c.onAccent)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_rounded, color: c.onAccent),
                    ],
                  ),
                ),
                const SizedBox(height: gap),
              ],
              // Week at a glance: one wide tile.
              _Tile(
                height: 176,
                child: _WeekBars(
                  load: load,
                  done: doneByDay,
                  todayIdx: todayIdx,
                  healthyMinutes: healthy * 60,
                ),
              ),
              const SizedBox(height: gap),
              Row(
                children: [
                  Expanded(
                    child: _Tile(
                      height: 132,
                      child: _Stat(
                        label: 'FOCUS SO FAR',
                        value: focusH >= 10 ? focusH.toStringAsFixed(0) : focusH.toStringAsFixed(1),
                        unit: 'h',
                        icon: Icons.bolt_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: gap),
                  Expanded(
                    child: _Tile(
                      height: 132,
                      child: _Stat(
                        label: 'TASKS DONE',
                        value: '${doneWeek.length}',
                        unit: '',
                        icon: Icons.done_all_rounded,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.xl),
              Row(
                children: [
                  Text('WEEKLY TARGETS', style: T.label(c.textDim)),
                  const Spacer(),
                  Text('${targets.length}/5 · hold to reorder', style: T.mono(c.textDim, size: 11)),
                ],
              ),
              const SizedBox(height: Space.m),
              ..._targetRows(context, targets, tasks, goals, ws, gap),
              const SizedBox(height: gap),
              if (next != null)
                _Tile(
                  height: 112,
                  onTap: nextGoal == null ? null : () => context.go(Routes.goals),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: c.accentInk, width: 2),
                        ),
                        child: Icon(Icons.flag_rounded, color: c.accentInk, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'NEXT MILESTONE · ${next.dueDate == null ? 'SOMEDAY' : relativeDay(next.dueDate!, now).toUpperCase()}',
                              style: T.label(c.textDim),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              next.title,
                              style: T.h3(c.text),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (nextGoal != null)
                              Text(
                                nextGoal.title,
                                style: T.small(c.textDim),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Targets as a 2-column bento; an odd one out spans the full width.
  List<Widget> _targetRows(
    BuildContext context,
    List<WeeklyTarget> targets,
    List<Task> tasks,
    List<Goal> goals,
    DateTime ws,
    double gap,
  ) {
    final c = context.c;
    final tiles = <Widget>[
      for (final t in targets)
        _TargetTile(
          key: ValueKey('target-${t.id}'),
          target: t,
          goal: goals.firstWhereOrNull((g) => g.id == t.goalId),
          progress: ProgressService.target(t, tasks),
          dimmed: _dragging == t.id,
          onDragStart: () => setState(() => _dragging = t.id),
          onDragEnd: () => setState(() => _dragging = null),
          onDropOnto: (draggedId) {
            final ids = targets.map((x) => x.id).toList();
            ids.remove(draggedId);
            ids.insert(
              ids.indexOf(t.id) + (targets.indexWhere((x) => x.id == draggedId) < targets.indexOf(t) ? 1 : 0),
              draggedId,
            );
            HapticFeedback.mediumImpact();
            ref.read(goalRepoProvider).reorderTargets(ids);
          },
          onTap: () => showTargetEditor(context, target: t, weekStart: ws),
        ),
      if (targets.length < 5)
        _Tile(
          height: 170,
          dashed: true,
          onTap: () => showTargetEditor(context, weekStart: ws),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: c.textDim, size: 28),
              const SizedBox(height: 6),
              Text(
                targets.isEmpty ? 'Pick 3–5 outcomes\nfor this week' : 'Add a target',
                textAlign: TextAlign.center,
                style: T.small(c.textDim),
              ),
            ],
          ),
        ),
    ];
    final rows = <Widget>[];
    for (var i = 0; i < tiles.length; i += 2) {
      if (i > 0) rows.add(SizedBox(height: gap));
      if (i + 1 < tiles.length) {
        rows.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: tiles[i]),
              SizedBox(width: gap),
              Expanded(child: tiles[i + 1]),
            ],
          ),
        );
      } else {
        rows.add(tiles[i]);
      }
    }
    return rows;
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.child,
    required this.height,
    this.onTap,
    this.lemon = false,
    this.dashed = false,
  });
  final Widget child;
  final double height;
  final VoidCallback? onTap;
  final bool lemon;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap!();
            },
      child: Container(
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: lemon ? c.accent : (dashed ? Colors.transparent : c.surface),
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: lemon ? c.accent : c.border, width: dashed ? 1.2 : 0.8),
        ),
        child: child,
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.unit, required this.icon});
  final String label;
  final String value;
  final String unit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      label: '$label $value $unit',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: c.textDim),
              const SizedBox(width: 6),
              Text(label, style: T.label(c.textDim)),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: T.number(c.text, size: 52)),
              if (unit.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6, left: 2),
                  child: Text(unit, style: T.h2(c.textDim)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Seven vertical bars: planned load per day, today in lemon, with a faint
/// healthy-limit line and dots for tasks done.
class _WeekBars extends StatelessWidget {
  const _WeekBars({
    required this.load,
    required this.done,
    required this.todayIdx,
    required this.healthyMinutes,
  });
  final List<int> load;
  final List<int> done;
  final int todayIdx;
  final int healthyMinutes;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final maxV = math.max(healthyMinutes, load.fold<int>(0, math.max)).toDouble();
    return Semantics(
      label:
          'Week at a glance. ${[for (var i = 0; i < 7; i++) '${weekdayShort[i]} ${minutesLabel(load[i])} planned, ${done[i]} done'].join('. ')}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('WEEK AT A GLANCE', style: T.label(c.textDim)),
              const Spacer(),
              Text(
                '${minutesLabel(load.fold(0, (a, b) => a + b))} planned',
                style: T.mono(c.textDim, size: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                final h = box.maxHeight - 22;
                final limitY = h - h * (healthyMinutes / maxV);
                return Stack(
                  children: [
                    Positioned(
                      top: limitY,
                      left: 0,
                      right: 0,
                      child: Container(height: 0.8, color: c.border),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < 7; i++)
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (var d = 0; d < math.min(done[i], 4); d++)
                                      Container(
                                        width: 4,
                                        height: 4,
                                        margin: const EdgeInsets.symmetric(horizontal: 1),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: i == todayIdx ? c.accentInk : c.textDim,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: (load[i] / maxV).clamp(0.0, 1.0)),
                                  duration: context.motion(Duration(milliseconds: 260 + i * 20)),
                                  curve: Curves.easeOutCubic,
                                  builder: (_, v, _) => Container(
                                    width: 18,
                                    height: math.max(4, (h - 12) * v),
                                    decoration: BoxDecoration(
                                      color: i == todayIdx
                                          ? c.accent
                                          : c.text.withValues(alpha: i < todayIdx ? 0.35 : 0.18),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  weekdayShort[i].substring(0, 1),
                                  style: T.mono(
                                    i == todayIdx ? c.text : c.textDim,
                                    size: 11,
                                    w: i == todayIdx ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetTile extends StatelessWidget {
  const _TargetTile({
    super.key,
    required this.target,
    required this.goal,
    required this.progress,
    required this.onTap,
    required this.onDropOnto,
    required this.onDragStart,
    required this.onDragEnd,
    this.dimmed = false,
  });

  final WeeklyTarget target;
  final Goal? goal;
  final double progress;
  final VoidCallback onTap;
  final ValueChanged<int> onDropOnto;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;
  final bool dimmed;

  Widget _face(BuildContext context, {bool hovering = false}) {
    final c = context.c;
    final hit = progress >= 1;
    final fg = hit ? c.onAccent : c.text;
    return AnimatedContainer(
      duration: context.motion(Motion.fast),
      height: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hit ? c.accent : c.surface,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(
          color: hovering ? c.accentInk : (hit ? c.accent : c.border),
          width: hovering ? 1.6 : 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                goal?.area.icon ?? Icons.flag_rounded,
                size: 16,
                color: hit ? c.onAccent : c.areaTint(goal?.area ?? LifeArea.personal),
              ),
              const Spacer(),
              if (hit) Icon(Icons.check_rounded, size: 18, color: c.onAccent),
            ],
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: context.motion(Motion.slow),
            curve: Curves.easeOutCubic,
            builder: (_, v, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${(v * 100).round()}', style: T.number(fg, size: 40)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('%', style: T.h3(fg.withValues(alpha: 0.6))),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    children: [
                      Container(height: 10, color: hit ? c.onAccent.withValues(alpha: 0.15) : c.surface2),
                      FractionallySizedBox(
                        widthFactor: v.clamp(0.0, 1.0),
                        child: Container(height: 10, color: hit ? c.onAccent : c.accent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            target.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: T.small(fg).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${target.title}, ${(progress * 100).round()} percent. Hold and drag to reorder.',
      excludeSemantics: true,
      child: DragTarget<int>(
        onWillAcceptWithDetails: (d) => d.data != target.id,
        onAcceptWithDetails: (d) => onDropOnto(d.data),
        builder: (context, candidates, _) => LayoutBuilder(
          builder: (context, box) => LongPressDraggable<int>(
            data: target.id,
            onDragStarted: () {
              HapticFeedback.mediumImpact();
              onDragStart();
            },
            onDragEnd: (_) => onDragEnd(),
            feedback: SizedBox(
              width: box.maxWidth,
              child: Material(
                type: MaterialType.transparency,
                child: Transform.scale(
                  scale: 1.04,
                  child: Transform.rotate(angle: 0.03, child: _face(context)),
                ),
              ),
            ),
            childWhenDragging: Opacity(opacity: 0.25, child: _face(context)),
            child: GestureDetector(
              onTap: onTap,
              child: Opacity(
                opacity: dimmed ? 0.25 : 1,
                child: _face(context, hovering: candidates.isNotEmpty),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
