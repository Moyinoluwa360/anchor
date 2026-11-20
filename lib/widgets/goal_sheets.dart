import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../models/dates.dart';
import '../models/enums.dart';
import '../providers/data_providers.dart';
import '../services/progress_service.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'buttons.dart';
import 'sheet.dart';
import 'task_editor_sheet.dart';

// Goal editor --------------------------------------------------------------

Future<int?> showGoalEditor(BuildContext context, {Goal? goal, LifeArea? area}) => showAnchorSheet<int>(
  context,
  builder: (_) => _GoalEditor(goal: goal, area: area),
);

class _GoalEditor extends ConsumerStatefulWidget {
  const _GoalEditor({this.goal, this.area});
  final Goal? goal;
  final LifeArea? area;

  @override
  ConsumerState<_GoalEditor> createState() => _GoalEditorState();
}

class _GoalEditorState extends ConsumerState<_GoalEditor> {
  late final _title = TextEditingController(text: widget.goal?.title ?? '');
  late final _why = TextEditingController(text: widget.goal?.why ?? '');
  late LifeArea _area = widget.goal?.area ?? widget.area ?? LifeArea.startup;
  late GoalStatus _status = widget.goal?.status ?? GoalStatus.active;
  late int _months = _initialMonths();

  int _initialMonths() {
    final t = widget.goal?.targetDate;
    if (t == null) return 6;
    final m = ((t.difference(DateTime.now()).inDays) / 30).round();
    return const [3, 6, 9, 12].reduce((a, b) => (a - m).abs() <= (b - m).abs() ? a : b);
  }

  @override
  void dispose() {
    _title.dispose();
    _why.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = _title.text.trim();
    if (t.isEmpty) return;
    final now = DateTime.now();
    final target = DateTime(now.year, now.month + _months, now.day);
    final repo = ref.read(goalRepoProvider);
    final nav = Navigator.of(context);
    if (widget.goal == null) {
      // New goals land near the middle of their area's cluster.
      final base = _areaHome[_area]!;
      final id = await repo.addGoal(
        GoalsCompanion.insert(
          title: t,
          area: _area,
          why: Value(_why.text.trim()),
          targetDate: Value(target),
          status: Value(_status),
          posX: Value(base.dx + (now.millisecond % 80) - 40),
          posY: Value(base.dy + (now.second % 80) - 40),
        ),
      );
      nav.pop(id);
    } else {
      final changedMonths = _months != _initialMonths();
      await repo.patchGoal(
        widget.goal!.id,
        GoalsCompanion(
          title: Value(t),
          area: Value(_area),
          why: Value(_why.text.trim()),
          status: Value(_status),
          targetDate: changedMonths ? Value(target) : const Value.absent(),
        ),
      );
      nav.pop(widget.goal!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SheetBody(
      title: widget.goal == null ? 'New goal' : 'Edit goal',
      subtitle: 'Something 3 to 12 months out.',
      children: [
        TextField(
          controller: _title,
          autofocus: widget.goal == null,
          textCapitalization: TextCapitalization.sentences,
          style: T.h3(c.text),
          decoration: const InputDecoration(hintText: 'The goal'),
          onChanged: (_) => setState(() {}),
        ),
        const FieldLabel('Why it matters'),
        TextField(
          controller: _why,
          maxLines: 3,
          minLines: 2,
          textCapitalization: TextCapitalization.sentences,
          style: T.body(c.text),
          decoration: const InputDecoration(hintText: 'One or two lines, for the foggy days'),
        ),
        const FieldLabel('Life area'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in LifeArea.values)
              Pill(
                label: a.label,
                icon: a.icon,
                selected: _area == a,
                onTap: () => setState(() => _area = a),
              ),
          ],
        ),
        const FieldLabel('Horizon'),
        Wrap(
          spacing: 8,
          children: [
            for (final m in const [3, 6, 9, 12])
              Pill(
                label: '$m months',
                mono: true,
                selected: _months == m,
                onTap: () => setState(() => _months = m),
              ),
          ],
        ),
        if (widget.goal != null) ...[
          const FieldLabel('Status'),
          Wrap(
            spacing: 8,
            children: [
              for (final s in GoalStatus.values)
                Pill(
                  label: switch (s) {
                    GoalStatus.active => 'Active',
                    GoalStatus.paused => 'Paused',
                    GoalStatus.achieved => 'Achieved',
                  },
                  selected: _status == s,
                  onTap: () => setState(() => _status = s),
                ),
            ],
          ),
        ],
        const SizedBox(height: Space.xl),
        PrimaryButton(
          label: widget.goal == null ? 'Add goal' : 'Save',
          onTap: _title.text.trim().isEmpty ? null : _save,
        ),
        if (widget.goal != null)
          Center(
            child: TextButton(
              onPressed: () async {
                final nav = Navigator.of(context);
                await ref.read(goalRepoProvider).deleteGoal(widget.goal!.id);
                nav.pop();
              },
              child: Text('Delete goal', style: T.small(c.textDim)),
            ),
          ),
      ],
    );
  }
}

/// Where each life area's cluster sits on the constellation canvas.
const _areaHome = {
  LifeArea.startup: Offset(330, 450),
  LifeArea.cloud: Offset(830, 400),
  LifeArea.sideGigs: Offset(600, 800),
  LifeArea.health: Offset(250, 900),
  LifeArea.personal: Offset(950, 850),
};
Offset areaHome(LifeArea a) => _areaHome[a]!;

// Weekly target editor -----------------------------------------------------

Future<void> showTargetEditor(BuildContext context, {WeeklyTarget? target, required DateTime weekStart}) =>
    showAnchorSheet<void>(
      context,
      builder: (_) => _TargetEditor(target: target, weekStart: weekStart),
    );

class _TargetEditor extends ConsumerStatefulWidget {
  const _TargetEditor({this.target, required this.weekStart});
  final WeeklyTarget? target;
  final DateTime weekStart;

  @override
  ConsumerState<_TargetEditor> createState() => _TargetEditorState();
}

class _TargetEditorState extends ConsumerState<_TargetEditor> {
  late final _title = TextEditingController(text: widget.target?.title ?? '');
  late int? _goalId = widget.target?.goalId;
  late bool _done = widget.target?.done ?? false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final goals = ref.watch(goalsProvider).value ?? const <Goal>[];
    final tasks = ref.watch(allTasksProvider).value ?? const <Task>[];
    final linked = widget.target == null
        ? const <Task>[]
        : tasks.where((t) => t.weeklyTargetId == widget.target!.id).toList();
    final pct = widget.target == null
        ? 0.0
        : ProgressService.target(widget.target!.copyWith(done: _done), tasks);

    return SheetBody(
      title: widget.target == null ? 'New weekly target' : 'Weekly target',
      subtitle: widget.target == null
          ? 'An outcome for this week, tied to a goal.'
          : '${(pct * 100).round()}% there',
      children: [
        TextField(
          controller: _title,
          autofocus: widget.target == null,
          textCapitalization: TextCapitalization.sentences,
          style: T.h3(c.text),
          decoration: const InputDecoration(hintText: 'e.g. Referral loop live for all users'),
          onChanged: (_) => setState(() {}),
        ),
        const FieldLabel('Moves this goal'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final g in goals)
              Pill(
                label: g.title.length > 30 ? '${g.title.substring(0, 29)}…' : g.title,
                icon: g.area.icon,
                selected: _goalId == g.id,
                onTap: () => setState(() => _goalId = g.id),
              ),
          ],
        ),
        if (widget.target != null) ...[
          const FieldLabel('Linked tasks'),
          for (final t in linked)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    t.status == TaskStatus.done
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 18,
                    color: t.status == TaskStatus.done ? c.accentInk : c.textDim,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(t.title, style: T.body(c.text), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          GhostButton(
            label: 'Add a task for this',
            icon: Icons.add_rounded,
            height: 44,
            onTap: () {
              final g = goals.firstWhereOrNull((g) => g.id == _goalId);
              showTaskEditor(context, goalId: _goalId, weeklyTargetId: widget.target!.id, area: g?.area);
            },
          ),
          const SizedBox(height: Space.m),
          Row(
            children: [
              Expanded(child: Text('Mark as hit', style: T.bodyStrong(c.text))),
              Switch.adaptive(value: _done, onChanged: (v) => setState(() => _done = v)),
            ],
          ),
        ],
        const SizedBox(height: Space.l),
        PrimaryButton(
          label: widget.target == null ? 'Add target' : 'Save',
          onTap: _title.text.trim().isEmpty
              ? null
              : () async {
                  final nav = Navigator.of(context);
                  final repo = ref.read(goalRepoProvider);
                  if (widget.target == null) {
                    await repo.addTarget(
                      WeeklyTargetsCompanion.insert(
                        weekStart: weekStartOf(widget.weekStart),
                        title: _title.text.trim(),
                        goalId: Value(_goalId),
                        sortOrder: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
                      ),
                    );
                  } else {
                    if (_done && !widget.target!.done) HapticFeedback.heavyImpact();
                    await repo.patchTarget(
                      widget.target!.id,
                      WeeklyTargetsCompanion(
                        title: Value(_title.text.trim()),
                        goalId: Value(_goalId),
                        done: Value(_done),
                      ),
                    );
                  }
                  nav.pop();
                },
        ),
        if (widget.target != null)
          Center(
            child: TextButton(
              onPressed: () async {
                final nav = Navigator.of(context);
                await ref.read(goalRepoProvider).deleteTarget(widget.target!.id);
                nav.pop();
              },
              child: Text('Remove target', style: T.small(c.textDim)),
            ),
          ),
      ],
    );
  }
}

/// "in 3 months" / "in 12 days" / "today" / "3 days ago" — never alarming.
String relativeDay(DateTime d, DateTime now) {
  final days = dayOf(d).difference(today(now)).inDays;
  if (days == 0) return 'today';
  if (days > 0) return days >= 60 ? 'in ${(days / 30).round()} months' : 'in $days days';
  return days <= -60 ? '${(-days / 30).round()} months ago' : '${-days} days ago';
}
