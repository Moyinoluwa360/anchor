import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../models/dates.dart';
import '../../models/enums.dart';
import '../../providers/data_providers.dart';
import '../../services/planner_service.dart';
import '../../services/timer_logic.dart';
import '../../services/timer_service.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/sheet.dart';
import '../reminders/reminders_screen.dart';

enum BlockSheetResult { saved, deleted, startedTimer }

/// Create or edit a time block: label, type, exact times, attached task,
/// its 5-minute alert, a reminder, or start a timer right away.
Future<BlockSheetResult?> showBlockEditor(
  BuildContext context, {
  TimeBlock? block,
  DateTime? start,
  DateTime? end,
  int? taskId,
}) {
  return showExeSheet<BlockSheetResult>(
    context,
    builder: (_) => _BlockEditor(block: block, start: start, end: end, taskId: taskId),
  );
}

class _BlockEditor extends ConsumerStatefulWidget {
  const _BlockEditor({this.block, this.start, this.end, this.taskId});
  final TimeBlock? block;
  final DateTime? start;
  final DateTime? end;
  final int? taskId;

  @override
  ConsumerState<_BlockEditor> createState() => _BlockEditorState();
}

class _BlockEditorState extends ConsumerState<_BlockEditor> {
  late DateTime _s = widget.block?.startAt ?? widget.start!;
  late DateTime _e = widget.block?.endAt ?? widget.end!;
  late BlockType _type = widget.block?.type ?? BlockType.focus;
  late int? _taskId = widget.block?.taskId ?? widget.taskId;
  late bool _remind = widget.block?.remind ?? true;
  late final _label = TextEditingController(text: widget.block?.label ?? '');

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  TimeBlocksCompanion get _companion => TimeBlocksCompanion(
    startAt: Value(_s),
    endAt: Value(_e),
    type: Value(_type),
    label: Value(_label.text.trim()),
    taskId: Value(_taskId),
    remind: Value(_remind),
  );

  Future<int> _save() async {
    final repo = ref.read(plannerRepoProvider);
    if (widget.block == null) {
      return repo.add(_companion);
    }
    await repo.patch(widget.block!.id, _companion);
    return widget.block!.id;
  }

  void _shift({int start = 0, int end = 0}) {
    final s = _s.add(Duration(minutes: start));
    final e = _e.add(Duration(minutes: end));
    if (e.difference(s).inMinutes < 15) return;
    setState(() {
      _s = s;
      _e = e;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final open = ref.watch(openTodayProvider).value ?? const <Task>[];
    final mins = _e.difference(_s).inMinutes;

    Widget stepper(String label, DateTime t, void Function(int) by) => Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(Radii.chip),
          border: Border.all(color: c.border, width: 0.8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.toUpperCase(), style: T.label(c.textDim)),
                  Text(hhmm(t), style: T.number(c.text, size: 26)),
                ],
              ),
            ),
            IconButton(
              tooltip: '$label 15 minutes earlier',
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.remove_rounded, color: c.text, size: 18),
              onPressed: () => by(-15),
            ),
            IconButton(
              tooltip: '$label 15 minutes later',
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.add_rounded, color: c.text, size: 18),
              onPressed: () => by(15),
            ),
          ],
        ),
      ),
    );

    return SheetBody(
      title: widget.block == null ? 'New block' : 'Edit block',
      subtitle: minutesLabel(mins),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in BlockType.values)
              Pill(
                label: t.label,
                icon: t.icon,
                selected: _type == t,
                onTap: () => setState(() => _type = t),
              ),
          ],
        ),
        const SizedBox(height: Space.m),
        TextField(
          controller: _label,
          textCapitalization: TextCapitalization.sentences,
          style: T.body(c.text),
          decoration: const InputDecoration(hintText: 'Label (optional)'),
        ),
        const FieldLabel('Time'),
        Row(
          children: [
            stepper('Start', _s, (m) => _shift(start: m)),
            const SizedBox(width: 8),
            stepper('End', _e, (m) => _shift(end: m)),
          ],
        ),
        if (_type == BlockType.focus || _type == BlockType.admin) ...[
          const FieldLabel('Attach a task'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Pill(label: 'None', selected: _taskId == null, onTap: () => setState(() => _taskId = null)),
              for (final t in open)
                Pill(
                  label: t.title.length > 30 ? '${t.title.substring(0, 29)}…' : t.title,
                  icon: t.area.icon,
                  selected: _taskId == t.id,
                  onTap: () => setState(() => _taskId = t.id),
                ),
            ],
          ),
        ],
        const SizedBox(height: Space.m),
        Row(
          children: [
            Expanded(child: Text('Alert 5 minutes before', style: T.bodyStrong(c.text))),
            Switch.adaptive(value: _remind, onChanged: (v) => setState(() => _remind = v)),
          ],
        ),
        const SizedBox(height: Space.l),
        PrimaryButton(
          label: 'Save',
          onTap: () async {
            final nav = Navigator.of(context);
            await _save();
            nav.pop(BlockSheetResult.saved);
          },
        ),
        const SizedBox(height: Space.m),
        Row(
          children: [
            Expanded(
              child: GhostButton(
                label: 'Start timer',
                icon: Icons.play_arrow_rounded,
                onTap: () async {
                  final nav = Navigator.of(context);
                  await _save();
                  final task = _taskId == null ? null : await ref.read(taskRepoProvider).byId(_taskId!);
                  final focus = mins.clamp(5, 180);
                  await ref
                      .read(timerProvider.notifier)
                      .start(task: task, preset: TimerPreset(focus, PlannerService.breakAfter(focus)));
                  nav.pop(BlockSheetResult.startedTimer);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GhostButton(
                label: 'Reminder',
                icon: Icons.notifications_none_rounded,
                onTap: () async {
                  await _save();
                  if (!context.mounted) return;
                  final title = _label.text.trim().isNotEmpty
                      ? _label.text.trim()
                      : (open.where((t) => t.id == _taskId).firstOrNull?.title ?? _type.label);
                  await showReminderEditor(context, title: title, at: _s, taskId: _taskId);
                },
              ),
            ),
          ],
        ),
        if (widget.block != null)
          Center(
            child: TextButton(
              onPressed: () async {
                final nav = Navigator.of(context);
                await ref.read(plannerRepoProvider).delete(widget.block!.id);
                nav.pop(BlockSheetResult.deleted);
              },
              child: Text('Delete block', style: T.small(c.textDim)),
            ),
          ),
      ],
    );
  }
}
