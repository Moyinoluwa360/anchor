import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../models/dates.dart';
import '../models/enums.dart';
import '../providers/data_providers.dart';
import '../providers/week_providers.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'buttons.dart';
import 'sheet.dart';

enum _Day { today, tomorrow, someday }

/// Add or edit a task. Returns the task id, or null if cancelled/deleted.
Future<int?> showTaskEditor(
  BuildContext context, {
  Task? task,
  LifeArea? area,
  int? goalId,
  int? weeklyTargetId,
  DateTime? day,
  String? title,
}) {
  return showExeSheet<int>(
    context,
    builder: (_) => _TaskEditor(
      task: task,
      area: area,
      goalId: goalId,
      weeklyTargetId: weeklyTargetId,
      day: day,
      title: title,
    ),
  );
}

class _TaskEditor extends ConsumerStatefulWidget {
  const _TaskEditor({this.task, this.area, this.goalId, this.weeklyTargetId, this.day, this.title});
  final Task? task;
  final LifeArea? area;
  final int? goalId;
  final int? weeklyTargetId;
  final DateTime? day;
  final String? title;

  @override
  ConsumerState<_TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends ConsumerState<_TaskEditor> {
  late final _title = TextEditingController(text: widget.task?.title ?? widget.title ?? '');
  late final _step = TextEditingController(text: widget.task?.firstStep ?? '');
  late LifeArea _area = widget.task?.area ?? widget.area ?? LifeArea.startup;
  late int _minutes = widget.task?.estimatedMinutes ?? 25;
  late Effort _effort = widget.task?.effort ?? Effort.medium;
  late int _priority = widget.task?.priority ?? 2;
  late int? _goalId = widget.task?.goalId ?? widget.goalId;
  late int? _targetId = widget.task?.weeklyTargetId ?? widget.weeklyTargetId;
  late _Day _day = _initialDay();

  _Day _initialDay() {
    final d = widget.task != null ? widget.task!.scheduledDate : (widget.day ?? today());
    if (d == null) return _Day.someday;
    final t = today();
    if (dayOf(d).isAfter(t)) return _Day.tomorrow;
    return _Day.today;
  }

  @override
  void dispose() {
    _title.dispose();
    _step.dispose();
    super.dispose();
  }

  DateTime? get _scheduled => switch (_day) {
    _Day.today => today(),
    _Day.tomorrow => addDays(today(), 1),
    _Day.someday => null,
  };

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final repo = ref.read(taskRepoProvider);
    final step = _step.text.trim();
    final c = TasksCompanion(
      title: Value(title),
      area: Value(_area),
      estimatedMinutes: Value(_minutes),
      firstStep: Value(step.isEmpty ? null : step),
      effort: Value(_effort),
      priority: Value(_priority),
      goalId: Value(_goalId),
      weeklyTargetId: Value(_targetId),
      scheduledDate: Value(_scheduled),
    );
    final nav = Navigator.of(context);
    if (widget.task == null) {
      final id = await repo.add(c);
      nav.pop(id);
    } else {
      await repo.patch(widget.task!.id, c);
      nav.pop(widget.task!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final goals = ref.watch(goalsProvider).value ?? const <Goal>[];
    // This week's targets, narrowed to the chosen goal.
    final targets = (ref.watch(weekTargetsProvider).value ?? const <WeeklyTarget>[])
        .where((t) => _goalId == null || t.goalId == _goalId)
        .toList();
    return SheetBody(
      title: widget.task == null ? 'New task' : 'Edit task',
      children: [
        TextField(
          controller: _title,
          autofocus: widget.task == null,
          textCapitalization: TextCapitalization.sentences,
          style: T.h3(c.text),
          decoration: const InputDecoration(hintText: 'What needs doing?'),
          onChanged: (_) => setState(() {}),
        ),
        const FieldLabel('Tiny first step (5 minutes)'),
        TextField(
          controller: _step,
          textCapitalization: TextCapitalization.sentences,
          style: T.body(c.text),
          decoration: const InputDecoration(hintText: 'e.g. Open the doc and write one line'),
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
        const FieldLabel('Estimate'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in const [5, 15, 25, 45, 60, 90])
              Pill(
                label: minutesLabel(m),
                mono: true,
                selected: _minutes == m,
                onTap: () => setState(() => _minutes = m),
              ),
          ],
        ),
        const FieldLabel('How heavy does it feel?'),
        Wrap(
          spacing: 8,
          children: [
            for (final e in Effort.values)
              Pill(label: e.label, selected: _effort == e, onTap: () => setState(() => _effort = e)),
          ],
        ),
        const FieldLabel('Importance'),
        Wrap(
          spacing: 8,
          children: [
            Pill(label: 'Must', selected: _priority == 1, onTap: () => setState(() => _priority = 1)),
            Pill(label: 'Should', selected: _priority == 2, onTap: () => setState(() => _priority = 2)),
            Pill(label: 'Nice', selected: _priority == 3, onTap: () => setState(() => _priority = 3)),
          ],
        ),
        const FieldLabel('When'),
        Wrap(
          spacing: 8,
          children: [
            Pill(
              label: 'Today',
              selected: _day == _Day.today,
              onTap: () => setState(() => _day = _Day.today),
            ),
            Pill(
              label: 'Tomorrow',
              selected: _day == _Day.tomorrow,
              onTap: () => setState(() => _day = _Day.tomorrow),
            ),
            Pill(
              label: 'Someday',
              selected: _day == _Day.someday,
              onTap: () => setState(() => _day = _Day.someday),
            ),
          ],
        ),
        if (goals.isNotEmpty) ...[
          const FieldLabel('Moves a goal forward'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Pill(
                label: 'None',
                selected: _goalId == null,
                onTap: () => setState(() {
                  _goalId = null;
                  _targetId = null;
                }),
              ),
              for (final g in goals)
                Pill(
                  label: g.title.length > 28 ? '${g.title.substring(0, 27)}…' : g.title,
                  icon: g.area.icon,
                  selected: _goalId == g.id,
                  onTap: () => setState(() {
                    if (_goalId != g.id) _targetId = null;
                    _goalId = g.id;
                    _area = g.area;
                  }),
                ),
            ],
          ),
        ],
        if (targets.isNotEmpty) ...[
          const FieldLabel('Counts toward this week\'s target'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Pill(label: 'None', selected: _targetId == null, onTap: () => setState(() => _targetId = null)),
              for (final t in targets)
                Pill(
                  label: t.title.length > 30 ? '${t.title.substring(0, 29)}…' : t.title,
                  icon: Icons.flag_rounded,
                  selected: _targetId == t.id,
                  onTap: () => setState(() {
                    _targetId = t.id;
                    if (t.goalId != null) _goalId = t.goalId;
                  }),
                ),
            ],
          ),
        ],
        const SizedBox(height: Space.xl),
        PrimaryButton(
          label: widget.task == null ? 'Add task' : 'Save',
          onTap: _title.text.trim().isEmpty ? null : _save,
        ),
        if (widget.task != null) ...[
          const SizedBox(height: Space.m),
          Center(
            child: TextButton(
              onPressed: () async {
                final nav = Navigator.of(context);
                await ref.read(taskRepoProvider).delete(widget.task!.id);
                nav.pop();
              },
              child: Text('Delete task', style: T.small(c.textDim)),
            ),
          ),
        ],
      ],
    );
  }
}
