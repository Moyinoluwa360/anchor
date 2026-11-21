import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../models/dates.dart';
import '../../models/enums.dart';
import '../../providers/data_providers.dart';
import '../../services/progress_service.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/goal_sheets.dart';
import '../../widgets/grain_background.dart';
import '../../widgets/task_editor_sheet.dart';
import 'goal_node.dart';

/// Full-screen goal sheet: why it matters, milestones, weekly targets,
/// tasks, and a simple timeline of progress.
class GoalDetailScreen extends ConsumerStatefulWidget {
  const GoalDetailScreen({super.key, required this.goalId});
  final int goalId;

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  final _newMs = TextEditingController();

  @override
  void dispose() {
    _newMs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final pad = MediaQuery.paddingOf(context);
    final now = DateTime.now();
    final goal = (ref.watch(goalsProvider).value ?? const <Goal>[]).firstWhereOrNull(
      (g) => g.id == widget.goalId,
    );
    if (goal == null) {
      return Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => Navigator.maybePop(context),
            child: const Text('Goal not found. Back'),
          ),
        ),
      );
    }
    final ms =
        (ref.watch(milestonesProvider).value ?? const <Milestone>[])
            .where((m) => m.goalId == goal.id)
            .toList()
          ..sort((a, b) => (a.dueDate ?? DateTime(9999)).compareTo(b.dueDate ?? DateTime(9999)));
    final tasks = (ref.watch(allTasksProvider).value ?? const <Task>[])
        .where((t) => t.goalId == goal.id)
        .toList();
    final targets =
        (ref.watch(allTargetsProvider).value ?? const <WeeklyTarget>[])
            .where((t) => t.goalId == goal.id)
            .toList()
          ..sort((a, b) => b.weekStart.compareTo(a.weekStart));
    final allTasks = ref.watch(allTasksProvider).value ?? const <Task>[];
    final p = ProgressService.goal(goal, ms, tasks);
    final open = tasks.where((t) => t.status != TaskStatus.done).toList();
    final done = tasks.where((t) => t.status == TaskStatus.done).toList();

    Widget section(String label, {Widget? action}) => Padding(
      padding: const EdgeInsets.only(top: Space.xl, bottom: Space.m),
      child: Row(
        children: [
          Text(label, style: T.label(c.textDim)),
          const Spacer(),
          ?action,
        ],
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: GrainBackground()),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8, pad.top + 4, 8, 0),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Close',
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: c.text, size: 30),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Edit goal',
                        icon: Icon(Icons.edit_outlined, color: c.text, size: 21),
                        onPressed: () async {
                          await showGoalEditor(context, goal: goal);
                          if (!context.mounted) return;
                          final still = (ref.read(goalsProvider).value ?? const <Goal>[]).any(
                            (g) => g.id == goal.id,
                          );
                          if (!still) Navigator.of(context).maybePop();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, pad.bottom + 40),
                sliver: SliverList.list(
                  children: [
                    Row(
                      children: [
                        Icon(goal.area.icon, size: 15, color: c.areaTint(goal.area)),
                        const SizedBox(width: 6),
                        Text(goal.area.label.toUpperCase(), style: T.label(c.textDim)),
                        if (goal.targetDate != null) ...[
                          Text('  ·  ', style: T.label(c.textDim)),
                          Text(
                            'TARGET ${relativeDay(goal.targetDate!, now).toUpperCase()}',
                            style: T.label(c.textDim),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: Space.m),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(goal.title, style: T.h1(c.text))),
                        const SizedBox(width: 12),
                        SizedBox.square(
                          dimension: 104,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size.square(104),
                                painter: GoalRingPainter(progress: p, milestones: ms, c: c, stroke: 8),
                              ),
                              Text(
                                '${(p * 100).round()}%',
                                style: T.mono(c.text, size: 16, w: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (goal.why.isNotEmpty) ...[
                      const SizedBox(height: Space.l),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
                        decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: c.accentInk, width: 3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('WHY IT MATTERS', style: T.label(c.textDim)),
                            const SizedBox(height: 4),
                            Text(goal.why, style: T.body(c.text).copyWith(fontSize: 17)),
                          ],
                        ),
                      ),
                    ],
                    section('PROGRESS OVER TIME'),
                    SizedBox(
                      height: 130,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _TimelinePainter(c: c, goal: goal, done: done, milestones: ms, now: now),
                      ),
                    ),
                    section('MILESTONES · ${ms.where((m) => m.done).length}/${ms.length}'),
                    for (var i = 0; i < ms.length; i++)
                      _MilestoneRow(m: ms[i], last: i == ms.length - 1, now: now),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, top: 4),
                      child: TextField(
                        controller: _newMs,
                        style: T.body(c.text),
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(hintText: '+ Add a milestone'),
                        onSubmitted: (v) async {
                          if (v.trim().isEmpty) return;
                          await ref
                              .read(goalRepoProvider)
                              .addMilestone(
                                MilestonesCompanion.insert(
                                  goalId: goal.id,
                                  title: v.trim(),
                                  dueDate: Value(addDays(today(now), 30)),
                                ),
                              );
                          _newMs.clear();
                        },
                      ),
                    ),
                    section('WEEKLY TARGETS'),
                    if (targets.isEmpty)
                      Text('None yet. Add one from the Week board.', style: T.small(c.textDim)),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final t in targets.take(8))
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                            decoration: BoxDecoration(
                              color: ProgressService.target(t, allTasks) >= 1 ? c.accent : c.surface,
                              borderRadius: BorderRadius.circular(Radii.chip),
                              border: Border.all(color: c.border, width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(ProgressService.target(t, allTasks) * 100).round()}%',
                                  style: T.mono(
                                    ProgressService.target(t, allTasks) >= 1 ? c.onAccent : c.accentInk,
                                    w: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 220),
                                  child: Text(
                                    t.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: T.small(
                                      ProgressService.target(t, allTasks) >= 1 ? c.onAccent : c.text,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    section(
                      'TASKS · ${done.length} DONE, ${open.length} OPEN',
                      action: GestureDetector(
                        onTap: () => showTaskEditor(context, goalId: goal.id, area: goal.area),
                        child: Text('+ ADD', style: T.label(c.accentInk)),
                      ),
                    ),
                    for (final t in open.take(10))
                      GestureDetector(
                        onTap: () => showTaskEditor(context, task: t),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Icon(Icons.radio_button_unchecked_rounded, size: 18, color: c.textDim),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  t.title,
                                  style: T.body(c.text),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                t.scheduledDate == null ? 'someday' : dayLabel(t.scheduledDate!),
                                style: T.mono(c.textDim, size: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (done.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${done.length} done so far: the line above is all of them.',
                          style: T.small(c.textDim),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Milestones as a vertical timeline with dots, tap to tick, hold to remove.
class _MilestoneRow extends ConsumerWidget {
  const _MilestoneRow({required this.m, required this.last, required this.now});
  final Milestone m;
  final bool last;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final accent = c.isDark ? c.accent : c.accentInk;
    return Semantics(
      button: true,
      checked: m.done,
      label:
          '${m.title}${m.dueDate != null ? ', ${relativeDay(m.dueDate!, now)}' : ''}. Tap to ${m.done ? 'reopen' : 'tick off'}.',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!m.done) HapticFeedback.heavyImpact();
          ref.read(goalRepoProvider).setMilestoneDone(m.id, !m.done);
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          ref.read(goalRepoProvider).deleteMilestone(m.id);
        },
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 22,
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: context.motion(Motion.fast),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: m.done ? accent : c.bg,
                        border: Border.all(color: m.done ? accent : c.textDim, width: 1.5),
                      ),
                      child: m.done ? Icon(Icons.check_rounded, size: 11, color: c.onAccent) : null,
                    ),
                    if (!last) Expanded(child: Container(width: 1.2, color: c.border)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.title, style: T.bodyStrong(m.done ? c.textDim : c.text)),
                      if (m.dueDate != null)
                        Text(
                          m.done && m.doneAt != null
                              ? 'done ${relativeDay(m.doneAt!, now)}'
                              : relativeDay(m.dueDate!, now),
                          style: T.mono(c.textDim, size: 11),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cumulative tasks done for this goal over time, with milestone dots and a
/// "today" tick. Simple and gentle: it only ever goes up.
class _TimelinePainter extends CustomPainter {
  _TimelinePainter({
    required this.c,
    required this.goal,
    required this.done,
    required this.milestones,
    required this.now,
  });
  final ExeColors c;
  final Goal goal;
  final List<Task> done;
  final List<Milestone> milestones;
  final DateTime now;

  @override
  void paint(Canvas canvas, Size size) {
    final points = done.map((t) => t.completedAt).whereType<DateTime>().toList()..sort();
    final starts = [
      goal.createdAt,
      if (points.isNotEmpty) points.first,
      ...milestones.where((m) => m.doneAt != null).map((m) => m.doneAt!),
    ];
    final start = starts.reduce((a, b) => a.isBefore(b) ? a : b);
    final end = goal.targetDate != null && goal.targetDate!.isAfter(now)
        ? goal.targetDate!
        : now.add(const Duration(days: 14));
    final span = math.max(1, end.difference(start).inHours).toDouble();
    double x(DateTime t) => (t.difference(start).inHours / span).clamp(0.0, 1.0) * size.width;
    final maxY = math.max(1, points.length).toDouble();
    double y(int n) => size.height - 18 - (n / maxY) * (size.height - 34);

    final base = Paint()
      ..color = c.border
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height - 18), Offset(size.width, size.height - 18), base);

    // Today marker.
    final tx = x(now);
    canvas.drawLine(
      Offset(tx, 8),
      Offset(tx, size.height - 18),
      Paint()
        ..color = c.textDim.withValues(alpha: 0.5)
        ..strokeWidth = 1,
    );
    final tp = TextPainter(
      text: TextSpan(text: 'today', style: T.mono(c.textDim, size: 10)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((tx - tp.width / 2).clamp(0, size.width - tp.width), size.height - 14));

    if (points.isNotEmpty) {
      final path = Path()..moveTo(0, y(0));
      final fill = Path()..moveTo(0, size.height - 18);
      for (var i = 0; i < points.length; i++) {
        final px = x(points[i]);
        path.lineTo(px, y(i));
        path.lineTo(px, y(i + 1));
        fill.lineTo(px, y(i));
        fill.lineTo(px, y(i + 1));
      }
      path.lineTo(tx, y(points.length));
      fill.lineTo(tx, y(points.length));
      fill.lineTo(tx, size.height - 18);
      fill.close();
      canvas.drawPath(fill, Paint()..color = c.accent.withValues(alpha: c.isDark ? 0.10 : 0.25));
      canvas.drawPath(
        path,
        Paint()
          ..color = c.isDark ? c.accent : c.accentInk
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Milestones: filled when done, hollow when ahead.
    for (final m in milestones) {
      final at = m.done ? (m.doneAt ?? m.dueDate) : m.dueDate;
      if (at == null) continue;
      final p = Offset(x(at), 10);
      if (m.done) {
        canvas.drawCircle(p, 4.5, Paint()..color = c.isDark ? c.accent : c.accentInk);
      } else {
        canvas.drawCircle(
          p,
          4.5,
          Paint()
            ..color = c.textDim
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_TimelinePainter old) => true;
}
