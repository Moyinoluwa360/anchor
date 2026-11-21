import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../models/enums.dart';
import '../../providers/data_providers.dart';
import '../../router.dart';
import '../../services/progress_service.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/glass_bottom_bar.dart';
import '../../widgets/goal_sheets.dart';
import '../../widgets/screen_header.dart';
import 'goal_node.dart';

const _canvas = Size(1200, 1200);

/// Goals as a constellation on a pannable, zoomable canvas (or a carousel).
class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> with SingleTickerProviderStateMixin {
  final _tc = TransformationController();
  late final AnimationController _orbit = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 90),
  );
  bool _carousel = false;
  bool _fitted = false;
  final Map<int, Offset> _dragPos = {};
  int? _lifted;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _orbit.stop();
    } else if (!_orbit.isAnimating) {
      _orbit.repeat();
    }
  }

  @override
  void dispose() {
    _tc.dispose();
    _orbit.dispose();
    super.dispose();
  }

  Offset _pos(Goal g) =>
      _dragPos[g.id] ?? Offset(g.posX ?? areaHome(g.area).dx, g.posY ?? areaHome(g.area).dy);

  /// Frame all goals in the viewport.
  void _fit(Size view, List<Goal> goals) {
    if (goals.isEmpty) return;
    final ps = goals.map(_pos).toList();
    final minX = ps.map((p) => p.dx).reduce(math.min) - 120;
    final maxX = ps.map((p) => p.dx).reduce(math.max) + 120;
    final minY = ps.map((p) => p.dy).reduce(math.min) - 130;
    final maxY = ps.map((p) => p.dy).reduce(math.max) + 150;
    final s = math.min(1.0, math.min(view.width / (maxX - minX), view.height / (maxY - minY)));
    final dx = (view.width - (maxX - minX) * s) / 2 - minX * s;
    final dy = (view.height - (maxY - minY) * s) / 2 - minY * s;
    _tc.value = Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(s, s, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalsProvider).value ?? const <Goal>[];
    final milestones = ref.watch(milestonesProvider).value ?? const <Milestone>[];
    final tasks = ref.watch(allTasksProvider).value ?? const <Task>[];
    final progress = {for (final g in goals) g.id: ProgressService.goal(g, milestones, tasks)};

    return Column(
      children: [
        ScreenHeader(
          title: 'Goals',
          kicker:
              '${goals.where((g) => g.status == GoalStatus.active).length} active · '
              '${(progress.values.fold<double>(0, (a, b) => a + b) / math.max(1, goals.length) * 100).round()}% overall',
          actions: [
            HeaderButton(
              icon: _carousel ? Icons.hub_rounded : Icons.view_carousel_rounded,
              label: _carousel ? 'Show constellation' : 'Show carousel',
              onTap: () => setState(() {
                _carousel = !_carousel;
                _fitted = false;
              }),
            ),
            HeaderButton(icon: Icons.add_rounded, label: 'New goal', onTap: () => showGoalEditor(context)),
          ],
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: context.motion(Motion.med),
            child: goals.isEmpty
                ? _Empty(onAdd: () => showGoalEditor(context))
                : _carousel
                ? _Carousel(
                    key: const ValueKey('carousel'),
                    goals: goals,
                    milestones: milestones,
                    progress: progress,
                  )
                : _constellation(context, goals, milestones, progress),
          ),
        ),
      ],
    );
  }

  Widget _constellation(
    BuildContext context,
    List<Goal> goals,
    List<Milestone> milestones,
    Map<int, double> progress,
  ) {
    final c = context.c;
    return LayoutBuilder(
      key: const ValueKey('constellation'),
      builder: (context, box) {
        if (!_fitted) {
          _fitted = true;
          final view = Size(box.maxWidth, box.maxHeight - GlassBottomBar.reserved(context) + 40);
          WidgetsBinding.instance.addPostFrameCallback((_) => _fit(view, goals));
        }
        return Semantics(
          label: 'Goal constellation. Pinch to zoom, drag to pan, hold a goal to move it.',
          child: InteractiveViewer(
            transformationController: _tc,
            constrained: false,
            minScale: 0.35,
            maxScale: 2.2,
            boundaryMargin: const EdgeInsets.all(500),
            child: SizedBox.fromSize(
              size: _canvas,
              child: AnimatedBuilder(
                animation: _orbit,
                builder: (context, _) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _SkyPainter(c: c, goals: goals, pos: _pos),
                      ),
                    ),
                    for (final a in LifeArea.values)
                      if (goals.any((g) => g.area == a))
                        Positioned(
                          left: _areaCenter(goals, a).dx - 120,
                          top: _areaCenter(goals, a).dy - 150,
                          width: 240,
                          child: Text(
                            a.label.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: T
                                .label(c.textDim.withValues(alpha: 0.6))
                                .copyWith(fontSize: 13, letterSpacing: 4),
                          ),
                        ),
                    for (final g in goals) _node(context, g, milestones, progress[g.id] ?? 0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Offset _areaCenter(List<Goal> goals, LifeArea a) {
    final ps = goals.where((g) => g.area == a).map(_pos).toList();
    final top = ps.map((p) => p.dy).reduce(math.min);
    final cx = ps.map((p) => p.dx).reduce((x, y) => x + y) / ps.length;
    return Offset(cx, top);
  }

  Widget _node(BuildContext context, Goal g, List<Milestone> milestones, double progress) {
    final p = _pos(g);
    final ms = milestones.where((m) => m.goalId == g.id).toList();
    Offset? start;
    return Positioned(
      left: p.dx - GoalNode.width / 2,
      top: p.dy - GoalNode.ring / 2,
      child: Semantics(
        button: true,
        label: '${g.title}, ${(progress * 100).round()} percent. Hold to move.',
        excludeSemantics: true,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            context.push('${Routes.goals}/${g.id}');
          },
          onLongPressStart: (_) {
            start = p;
            HapticFeedback.mediumImpact();
            setState(() => _lifted = g.id);
          },
          onLongPressMoveUpdate: (d) {
            final s = _tc.value.getMaxScaleOnAxis();
            final o = (start ?? p) + d.offsetFromOrigin / s;
            setState(
              () => _dragPos[g.id] = Offset(
                o.dx.clamp(80, _canvas.width - 80),
                o.dy.clamp(80, _canvas.height - 120),
              ),
            );
          },
          onLongPressEnd: (_) async {
            final np = _dragPos[g.id];
            setState(() => _lifted = null);
            if (np != null) {
              HapticFeedback.lightImpact();
              await ref.read(goalRepoProvider).moveGoal(g.id, np.dx, np.dy);
            }
          },
          child: GoalNode(
            goal: g,
            progress: progress,
            milestones: ms,
            orbit: _orbit.value * 2 * math.pi,
            lifted: _lifted == g.id,
          ),
        ),
      ),
    );
  }
}

/// Faint stars, and hairlines joining goals in the same life area.
class _SkyPainter extends CustomPainter {
  _SkyPainter({required this.c, required this.goals, required this.pos});
  final ExeColors c;
  final List<Goal> goals;
  final Offset Function(Goal) pos;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(42);
    final star = Paint()..color = c.textDim.withValues(alpha: 0.25);
    for (var i = 0; i < 140; i++) {
      canvas.drawCircle(
        Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height),
        rnd.nextDouble() * 1.2 + 0.3,
        star,
      );
    }
    final line = Paint()
      ..color = c.border
      ..strokeWidth = 1;
    for (final a in LifeArea.values) {
      final ps = goals.where((g) => g.area == a).map(pos).toList();
      for (var i = 0; i < ps.length - 1; i++) {
        canvas.drawLine(ps[i], ps[i + 1], line);
      }
    }
  }

  @override
  bool shouldRepaint(_SkyPainter old) => true;
}

class _Carousel extends StatelessWidget {
  const _Carousel({super.key, required this.goals, required this.milestones, required this.progress});
  final List<Goal> goals;
  final List<Milestone> milestones;
  final Map<int, double> progress;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final now = DateTime.now();
    return Padding(
      padding: EdgeInsets.only(top: Space.l, bottom: GlassBottomBar.reserved(context)),
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.84),
        itemCount: goals.length,
        itemBuilder: (context, i) {
          final g = goals[i];
          final ms = milestones.where((m) => m.goalId == g.id).toList();
          final next = ProgressService.nextMilestone(ms, now);
          final p = progress[g.id] ?? 0;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () => context.push('${Routes.goals}/${g.id}'),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(Radii.big),
                  border: Border.all(color: c.border, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(g.area.icon, size: 15, color: c.areaTint(g.area)),
                        const SizedBox(width: 6),
                        Text(g.area.label.toUpperCase(), style: T.label(c.textDim)),
                        const Spacer(),
                        if (g.targetDate != null)
                          Text(relativeDay(g.targetDate!, now).toUpperCase(), style: T.label(c.textDim)),
                      ],
                    ),
                    const SizedBox(height: Space.l),
                    Center(
                      child: SizedBox.square(
                        dimension: 170,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size.square(170),
                              painter: GoalRingPainter(progress: p, milestones: ms, c: c, stroke: 10),
                            ),
                            Text('${(p * 100).round()}%', style: T.number(c.text, size: 40)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Space.l),
                    Text(
                      g.title,
                      style: T.h1(c.text).copyWith(fontSize: 26),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Space.s),
                    if (g.why.isNotEmpty)
                      Text(
                        '“${g.why}”',
                        style: T.body(c.textDim),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Spacer(),
                    if (next != null) ...[
                      Text('NEXT MILESTONE', style: T.label(c.textDim)),
                      const SizedBox(height: 4),
                      Text(
                        next.title,
                        style: T.bodyStrong(c.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.all(Space.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('An empty sky.', style: T.display(c.text)),
          const SizedBox(height: Space.m),
          Text('Add a goal you want 3 to 12 months from now.', style: T.body(c.textDim)),
          const SizedBox(height: Space.xl),
          GhostButton(label: 'Add a goal', icon: Icons.add_rounded, onTap: onAdd),
        ],
      ),
    );
  }
}
