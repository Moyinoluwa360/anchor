import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../models/dates.dart';
import '../../models/enums.dart';
import '../../providers/data_providers.dart';
import '../../providers/week_providers.dart';
import '../../services/progress_service.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/grain_background.dart';

/// Sunday review as story cards: what got done → what carries over → next
/// week's targets → closed. Tap the right side to go on, left to go back.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final _pc = PageController();
  int _page = 0;
  static const _count = 4;

  /// Task id → carry over (true) or let go to someday (false).
  final Map<int, bool> _carry = {};

  /// Next week's chosen targets: (goal id or null, title).
  final List<(int?, String)> _next = [];
  bool _seeded = false;
  final _custom = TextEditingController();

  @override
  void dispose() {
    _pc.dispose();
    _custom.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final p = (_page + delta).clamp(0, _count - 1);
    if (p == _page) return;
    HapticFeedback.selectionClick();
    _pc.animateToPage(p, duration: context.motion(Motion.med), curve: Motion.curve);
  }

  Future<void> _finish() async {
    final ws = ref.read(weekStartProvider);
    final nextWs = addDays(ws, 7);
    final repo = ref.read(taskRepoProvider);
    for (final e in _carry.entries) {
      await repo.patch(
        e.key,
        TasksCompanion(
          scheduledDate: Value(e.value ? nextWs : null),
          timeBlockId: const Value(null),
          topDate: const Value(null),
          topRank: const Value(null),
        ),
      );
    }
    final goals = ref.read(goalRepoProvider);
    final existing = ref.read(nextWeekTargetsProvider).value ?? const <WeeklyTarget>[];
    for (var i = 0; i < _next.length; i++) {
      if (existing.any((t) => t.title == _next[i].$2)) continue;
      await goals.addTarget(
        WeeklyTargetsCompanion.insert(
          weekStart: nextWs,
          title: _next[i].$2,
          goalId: Value(_next[i].$1),
          sortOrder: Value(i),
        ),
      );
    }
    HapticFeedback.heavyImpact();
    _go(1);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final now = DateTime.now();
    final ws = ref.watch(weekStartProvider);
    final tasks = ref.watch(allTasksProvider).value ?? const <Task>[];
    final goals = ref.watch(goalsProvider).value ?? const <Goal>[];
    final milestones = ref.watch(milestonesProvider).value ?? const <Milestone>[];
    final targets = ref.watch(weekTargetsProvider).value ?? const <WeeklyTarget>[];
    final sessions = ref.watch(weekSessionsProvider).value ?? const <FocusSession>[];
    final pad = MediaQuery.paddingOf(context);

    final done =
        tasks
            .where(
              (t) =>
                  t.status == TaskStatus.done &&
                  t.completedAt != null &&
                  !t.completedAt!.isBefore(ws) &&
                  t.completedAt!.isBefore(addDays(ws, 7)),
            )
            .toList()
          ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
    final carry = ProgressService.carryOver(tasks, ws);
    for (final t in carry) {
      _carry.putIfAbsent(t.id, () => true);
    }
    if (!_seeded && goals.isNotEmpty) {
      _seeded = true;
      for (final s in ProgressService.suggestTargets(goals, milestones, now).take(4)) {
        _next.add((s.$1.id, s.$2));
      }
    }
    final focusH = ProgressService.focusHours(sessions, ws, addDays(ws, 7));
    final hit = targets.where((t) => ProgressService.target(t, tasks) >= 1).length;

    final pages = [
      _StoryCard(
        kicker: 'THIS WEEK · 1/3',
        title: 'Look what got done.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Big(value: '${done.length}', label: 'tasks'),
                const SizedBox(width: 28),
                _Big(value: focusH.toStringAsFixed(1), label: 'focus hours'),
                const SizedBox(width: 28),
                _Big(value: '$hit/${targets.length}', label: 'targets'),
              ],
            ),
            const SizedBox(height: Space.xl),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final t in done.take(12))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          Icon(Icons.check_rounded, size: 16, color: c.accentInk),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              t.title,
                              style: T.body(c.text),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(weekdayShort[t.completedAt!.weekday - 1], style: T.mono(c.textDim, size: 11)),
                        ],
                      ),
                    ),
                  if (done.length > 12) Text('+ ${done.length - 12} more', style: T.mono(c.textDim)),
                  if (done.isEmpty)
                    Text('A quiet week. Rest is part of the work too.', style: T.body(c.textDim)),
                ],
              ),
            ),
          ],
        ),
      ),
      _StoryCard(
        kicker: 'CARRY OVER · 2/3',
        title: carry.isEmpty ? 'Nothing left behind.' : 'What comes with you?',
        subtitle: carry.isEmpty ? null : 'Tap to let something go to someday. No guilt either way.',
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            for (final t in carry)
              GestureDetector(
                onTap: () => setState(() => _carry[t.id] = !(_carry[t.id] ?? true)),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: (_carry[t.id] ?? true) ? c.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(Radii.chip),
                    border: Border.all(color: c.border, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      Icon(t.area.icon, size: 16, color: c.areaTint(t.area)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t.title,
                          style: T.body((_carry[t.id] ?? true) ? c.text : c.textDim),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        (_carry[t.id] ?? true) ? 'NEXT WEEK' : 'SOMEDAY',
                        style: T.label((_carry[t.id] ?? true) ? c.accentInk : c.textDim),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      _StoryCard(
        kicker: 'NEXT WEEK · 3/3',
        title: 'Pick 3 to 5 outcomes.',
        subtitle: 'Small enough to finish. Tap to remove.',
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (var i = 0; i < _next.length; i++)
                    GestureDetector(
                      onTap: () => setState(() => _next.removeAt(i)),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(Radii.chip),
                          border: Border.all(color: c.border, width: 0.8),
                        ),
                        child: Row(
                          children: [
                            Text('${i + 1}', style: T.number(c.accentInk, size: 22)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _next[i].$2,
                                style: T.body(c.text),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.close_rounded, size: 16, color: c.textDim),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_next.length < 5)
              TextField(
                controller: _custom,
                style: T.body(c.text),
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Add your own…'),
                onSubmitted: (v) {
                  if (v.trim().isEmpty) return;
                  setState(() => _next.add((null, v.trim())));
                  _custom.clear();
                },
              ),
            const SizedBox(height: Space.m),
            PrimaryButton(label: 'Close the week', onTap: _next.isEmpty ? null : _finish),
          ],
        ),
      ),
      _StoryCard(
        kicker: 'DONE',
        title: 'Week closed.\nRest well.',
        subtitle:
            '${_next.length} targets set for next week. '
            '${_carry.values.where((v) => v).length} tasks coming along.',
        child: Align(
          alignment: Alignment.bottomCenter,
          child: PrimaryButton(label: 'Back to it', onTap: () => Navigator.of(context).maybePop()),
        ),
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: GrainBackground()),
          PageView(
            controller: _pc,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (p) => setState(() => _page = p),
            children: pages,
          ),
          // Story taps: left third back, right third forward (not on the last pages' buttons).
          if (_page < 2)
            Positioned.fill(
              top: pad.top + 60,
              bottom: 120,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: () => _go(-1)),
                  ),
                  const Spacer(),
                  Expanded(
                    child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: () => _go(1)),
                  ),
                ],
              ),
            ),
          Positioned(
            top: pad.top + 10,
            left: Space.gutter,
            right: 8,
            child: Row(
              children: [
                for (var i = 0; i < _count; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(
                    child: AnimatedContainer(
                      duration: context.motion(Motion.med),
                      height: 3,
                      decoration: BoxDecoration(
                        color: i <= _page ? c.accent : c.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
                IconButton(
                  tooltip: 'Close review',
                  icon: Icon(Icons.close_rounded, color: c.text),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
          if (_page < 2)
            Positioned(
              right: Space.gutter,
              bottom: pad.bottom + 20,
              child: GhostButton(label: 'Next', icon: Icons.arrow_forward_rounded, onTap: () => _go(1)),
            ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.kicker, required this.title, required this.child, this.subtitle});
  final String kicker;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final pad = MediaQuery.paddingOf(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(Space.gutter, pad.top + 64, Space.gutter, pad.bottom + 84),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(kicker, style: T.label(c.accentInk)),
          const SizedBox(height: Space.m),
          Text(title, style: T.display(c.text)),
          if (subtitle != null) ...[
            const SizedBox(height: Space.s),
            Text(subtitle!, style: T.body(c.textDim)),
          ],
          const SizedBox(height: Space.xl),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Big extends StatelessWidget {
  const _Big({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: T.number(c.text, size: 44)),
        Text(label, style: T.mono(c.textDim, size: 11)),
      ],
    );
  }
}
