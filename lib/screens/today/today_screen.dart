import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../models/dates.dart';
import '../../models/enums.dart';
import '../../providers/data_providers.dart';
import '../../providers/settings.dart';
import '../../router.dart';
import '../../services/planner_service.dart';
import '../../services/timer_logic.dart';
import '../../services/timer_service.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/glass.dart';
import '../../widgets/glass_bottom_bar.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/sheet.dart';
import 'block_editor_sheet.dart';
import 'day_dial.dart';
import 'timeline_view.dart';

/// Today: the day as a 24-hour dial (or a flat timeline for precise edits).
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> with SingleTickerProviderStateMixin {
  bool _zoomed = false;
  bool _timeline = false;
  int? _selected;
  List<BlockDraft> _preview = const [];
  late final AnimationController _grow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  @override
  void dispose() {
    _grow.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    final m = ScaffoldMessenger.of(context);
    m.hideCurrentSnackBar();
    m.showSnackBar(
      SnackBar(
        content: Text(msg),
        margin: EdgeInsets.fromLTRB(16, 0, 16, GlassBottomBar.reserved(context) + 8),
      ),
    );
  }

  Future<void> _edit(TimeBlock b) async {
    setState(() => _selected = b.id);
    await showBlockEditor(context, block: b);
  }

  Future<void> _create(DateTime s, DateTime e) async {
    final r = await showBlockEditor(context, start: s, end: e);
    if (r == BlockSheetResult.saved) _toast('Block added.');
  }

  Future<void> _resize(TimeBlock b, DateTime s, DateTime e) =>
      ref.read(plannerRepoProvider).patch(b.id, TimeBlocksCompanion(startAt: Value(s), endAt: Value(e)));

  Future<void> _drop(Task t, DateTime start) async {
    await ref
        .read(plannerRepoProvider)
        .add(
          TimeBlocksCompanion.insert(
            startAt: start,
            endAt: start.add(Duration(minutes: t.estimatedMinutes.clamp(15, 180))),
            type: BlockType.focus,
            label: Value(t.title),
            taskId: Value(t.id),
          ),
        );
    _toast('${t.title} → ${hhmm(start)}');
  }

  void _suggest() {
    final now = DateTime.now();
    final tasks = ref.read(openTodayProvider).value ?? const <Task>[];
    final blocks = ref.read(todayBlocksProvider).value ?? const <TimeBlock>[];
    final energy = ref.read(todayCheckInProvider)?.energy;
    final drafts = PlannerService.suggest(
      tasks: tasks,
      existing: blocks,
      now: now,
      energy: energy,
      healthyHours: ref.read(settingsProvider).healthyHours,
    );
    if (drafts.isEmpty) {
      _toast('Nothing left to plan. Enjoy the space.');
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _timeline = false;
      _zoomed = false;
      _preview = drafts;
    });
    _grow.forward(from: context.reduceMotion ? 1 : 0);
  }

  Future<void> _accept() async {
    final drafts = _preview;
    await ref.read(plannerRepoProvider).applySuggestion(ref.read(todayProvider), DateTime.now(), [
      for (final d in drafts)
        TimeBlocksCompanion.insert(
          startAt: d.start,
          endAt: d.end,
          type: d.type,
          label: Value(d.label),
          taskId: Value(d.taskId),
        ),
    ]);
    HapticFeedback.heavyImpact();
    setState(() => _preview = const []);
    _toast('Plan set. One block at a time.');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final day = ref.watch(todayProvider);
    final now = ref.watch(minuteTickProvider).value ?? DateTime.now();
    final blocks = ref.watch(todayBlocksProvider).value ?? const <TimeBlock>[];
    final open = ref.watch(openTodayProvider).value ?? const <Task>[];
    final allTasks = ref.watch(allTasksProvider).value ?? const <Task>[];
    final titles = {for (final t in allTasks) t.id: t.title};
    final healthy = ref.watch(settingsProvider.select((s) => s.healthyHours));
    final checkIn = ref.watch(todayCheckInProvider);
    final cap = PlannerService.capacity(blocks, healthy);
    final unscheduled = open.where((t) => t.timeBlockId == null).toList();
    final previewing = _preview.isNotEmpty;

    return Stack(
      children: [
        Column(
          children: [
            ScreenHeader(
              title: 'Today',
              kicker: '${dayLabel(day)} · ${minutesLabel(cap.plannedMinutes)} planned',
              actions: [
                HeaderButton(
                  icon: Icons.notifications_none_rounded,
                  label: 'Reminders',
                  onTap: () => context.push(Routes.reminders),
                ),
                HeaderButton(icon: Icons.auto_awesome_rounded, label: 'Suggest a plan', onTap: _suggest),
                HeaderButton(
                  icon: _timeline ? Icons.donut_large_rounded : Icons.view_agenda_rounded,
                  label: _timeline ? 'Show dial' : 'Show timeline',
                  onTap: () => setState(() => _timeline = !_timeline),
                ),
              ],
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: context.motion(Motion.med),
                child: _timeline
                    ? TimelineView(
                        key: const ValueKey('timeline'),
                        day: day,
                        now: now,
                        blocks: blocks,
                        taskTitles: titles,
                        onTap: _edit,
                        onChange: _resize,
                        onCreate: _create,
                        bottomPadding: GlassBottomBar.reserved(context),
                      )
                    : Padding(
                        key: const ValueKey('dial'),
                        padding: EdgeInsets.only(bottom: GlassBottomBar.reserved(context) - 8),
                        child: Column(
                          children: [
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, box) {
                                  return Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 34),
                                          child: AnimatedBuilder(
                                            animation: _grow,
                                            builder: (context, _) => DayDial(
                                              day: day,
                                              now: now,
                                              blocks: blocks,
                                              capacity: cap,
                                              zoomed: _zoomed,
                                              onZoom: (z) => setState(() => _zoomed = z),
                                              onCreate: _create,
                                              onResize: _resize,
                                              onTapBlock: _edit,
                                              onDropTask: _drop,
                                              preview: _preview,
                                              previewProgress: _grow.value,
                                              selectedId: _selected,
                                              center: _DialCenter(
                                                blocks: blocks,
                                                now: now,
                                                zoomed: _zoomed,
                                                titles: titles,
                                                day: day,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      ..._chips(context, unscheduled, box.biggest),
                                    ],
                                  );
                                },
                              ),
                            ),
                            _CapacityLine(cap: cap, energy: checkIn?.energy),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
        if (previewing)
          Positioned(
            left: Space.gutter,
            right: Space.gutter,
            bottom: GlassBottomBar.reserved(context) + 4,
            child: Glass(
              radius: Radii.card,
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SUGGESTED · ${EnergyProfile.of(checkIn?.energy).name.toUpperCase()} DAY · '
                    '${_preview.where((d) => d.type == BlockType.focus).length} FOCUS BLOCKS',
                    style: T.label(c.textDim),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    checkIn == null
                        ? 'Planned for a steady day. Check in for a better fit.'
                        : (checkIn.energy <= 2
                              ? 'Lighter today: short blocks, easy wins first.'
                              : (checkIn.energy >= 4
                                    ? 'Big energy: hardest thing first.'
                                    : 'A steady rhythm with breaks.')),
                    style: T.small(c.text),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(label: 'Use this plan', height: 48, onTap: _accept),
                      ),
                      const SizedBox(width: 8),
                      GhostButton(
                        label: 'Not now',
                        height: 48,
                        onTap: () => setState(() => _preview = const []),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Unscheduled tasks floating in the corners around the ring.
  List<Widget> _chips(BuildContext context, List<Task> tasks, Size area) {
    if (tasks.isEmpty || _preview.isNotEmpty) return const [];
    const slots = [Alignment.topLeft, Alignment.topRight, Alignment.bottomLeft, Alignment.bottomRight];
    final show = tasks.length > slots.length ? slots.length - 1 : tasks.length;
    final out = <Widget>[];
    for (var i = 0; i < show; i++) {
      out.add(
        Align(
          alignment: slots[i],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: _Float(
              index: i,
              child: TaskChip(task: tasks[i]),
            ),
          ),
        ),
      );
    }
    if (tasks.length > slots.length) {
      final rest = tasks.sublist(show);
      out.add(
        Align(
          alignment: slots.last,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: GestureDetector(
              onTap: () => _moreChips(rest),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: context.c.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.c.border, width: 0.8),
                ),
                child: Text('+${rest.length} more', style: T.mono(context.c.text, size: 11)),
              ),
            ),
          ),
        ),
      );
    }
    return out;
  }

  void _moreChips(List<Task> rest) {
    showExeSheet<void>(
      context,
      builder: (ctx) => SheetBody(
        title: 'Not on the dial yet',
        subtitle: 'Long-press and drag a chip onto the ring, or add it at the next free slot.',
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: [
              for (final t in rest)
                TaskChip(
                  task: t,
                  onTap: () async {
                    final nav = Navigator.of(ctx);
                    final blocks = ref.read(todayBlocksProvider).value ?? const <TimeBlock>[];
                    final now = DateTime.now();
                    final draft = PlannerService.suggest(
                      tasks: [t],
                      existing: blocks,
                      now: now,
                      energy: 5,
                    ).firstWhereOrNull((d) => d.type == BlockType.focus);
                    if (draft != null) await _drop(t, draft.start);
                    nav.pop();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Gentle bobbing so chips feel like they float (off with reduced motion).
class _Float extends StatefulWidget {
  const _Float({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<_Float> createState() => _FloatState();
}

class _FloatState extends State<_Float> with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 2600 + widget.index * 300),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _a.stop();
    } else if (!_a.isAnimating) {
      _a.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _a,
    builder: (_, child) => Transform.translate(
      offset: Offset(0, (Curves.easeInOut.transform(_a.value) - 0.5) * 6),
      child: child,
    ),
    child: widget.child,
  );
}

class _DialCenter extends ConsumerWidget {
  const _DialCenter({
    required this.blocks,
    required this.now,
    required this.zoomed,
    required this.titles,
    required this.day,
  });
  final List<TimeBlock> blocks;
  final DateTime now;
  final bool zoomed;
  final Map<int, String> titles;
  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final current = blocks.firstWhereOrNull((b) => !now.isBefore(b.startAt) && now.isBefore(b.endAt));
    final next = blocks.firstWhereOrNull((b) => b.startAt.isAfter(now));
    String name(TimeBlock b) => b.taskId != null && titles[b.taskId] != null
        ? titles[b.taskId]!
        : (b.label.isEmpty ? b.type.label : b.label);

    if (current != null) {
      final left = current.endAt.difference(now);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${current.type.label.toUpperCase()} · NOW', style: T.label(c.accentInk)),
          const SizedBox(height: 4),
          Text(
            name(current),
            style: T.small(c.text),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          FittedBox(
            child: Text(
              minutesLabel(left.inMinutes + 1),
              style: T.mega(c.text).copyWith(fontSize: 40, letterSpacing: -2),
            ),
          ),
          Text('left', style: T.mono(c.textDim, size: 11)),
          const SizedBox(height: 8),
          _StartPill(
            onTap: () async {
              final task = current.taskId == null
                  ? null
                  : await ref.read(taskRepoProvider).byId(current.taskId!);
              final mins = left.inMinutes.clamp(5, 180);
              await ref
                  .read(timerProvider.notifier)
                  .start(task: task, preset: TimerPreset(mins, PlannerService.breakAfter(mins)));
              if (context.mounted) context.go(Routes.now);
            },
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(zoomed ? 'ZOOMED · 6 H' : 'NEXT', style: T.label(c.textDim)),
        const SizedBox(height: 6),
        if (next != null) ...[
          Text(hhmm(next.startAt), style: T.mega(c.text).copyWith(fontSize: 44)),
          const SizedBox(height: 2),
          Text(
            name(next),
            style: T.small(c.textDim),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            'in ${minutesLabel(next.startAt.difference(now).inMinutes)}',
            style: T.mono(c.textDim, size: 11),
          ),
        ] else ...[
          Text('Free', style: T.number(c.text, size: 34)),
          Text('Drag on the ring to plan', style: T.mono(c.textDim, size: 11)),
        ],
      ],
    );
  }
}

class _StartPill extends StatelessWidget {
  const _StartPill({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      button: true,
      label: 'Start timer for this block',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_arrow_rounded, size: 16, color: c.onAccent),
              const SizedBox(width: 4),
              Text('Start', style: T.button(c.onAccent).copyWith(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CapacityLine extends StatelessWidget {
  const _CapacityLine({required this.cap, this.energy});
  final Capacity cap;
  final int? energy;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final (msg, col) = switch (cap.level) {
      CapacityLevel.calm => ('Room to breathe.', c.textDim),
      CapacityLevel.full => ('Nicely full.', c.accentInk),
      CapacityLevel.over => ("That's a lot. Something can move to tomorrow.", c.warn),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, 8),
      child: Column(
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${minutesLabel(cap.plannedMinutes)} of ${cap.limitMinutes ~/ 60}h  ',
                  style: T.mono(c.text, w: FontWeight.w700),
                ),
                TextSpan(text: msg, style: T.small(col)),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 4,
            children: [
              for (final t in BlockType.values)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: switch (t) {
                          BlockType.focus => c.accent,
                          BlockType.admin => c.text.withValues(alpha: 0.55),
                          BlockType.fixed => c.text.withValues(alpha: 0.9),
                          BlockType.breakTime => c.text.withValues(alpha: 0.22),
                          BlockType.rest => c.textDim.withValues(alpha: 0.28),
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(t.label, style: T.mono(c.textDim, size: 10)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
