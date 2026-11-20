import 'package:drift/drift.dart' show Value;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../models/dates.dart';
import '../../models/enums.dart';
import '../../providers/data_providers.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/grain_background.dart';
import '../../widgets/sheet.dart';
import 'notification_settings_sheet.dart';

/// All reminders as a wrap of time tiles (not a plain list), each with its
/// repeat rule. Tap to edit, long-press to switch off.
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final list = ref.watch(remindersProvider).value ?? const <Reminder>[];
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: GrainBackground()),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8, pad.top + 4, Space.gutter, 0),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.text, size: 20),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Notification settings',
                        icon: Icon(Icons.tune_rounded, color: c.text, size: 22),
                        onPressed: () => showNotificationSettings(context),
                      ),
                      const SizedBox(width: 4),
                      GhostButton(
                        label: 'New',
                        icon: Icons.add_rounded,
                        height: 40,
                        onTap: () => showReminderEditor(context),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(Space.gutter, Space.l, Space.gutter, Space.l),
                sliver: SliverToBoxAdapter(child: Text('Reminders', style: T.h1(c.text))),
              ),
              if (list.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
                  sliver: SliverToBoxAdapter(
                    child: Text('Nothing to remember. Lovely.', style: T.body(c.textDim)),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, pad.bottom + 32),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.05,
                    children: [for (final r in list) _ReminderTile(r)],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReminderTile extends ConsumerWidget {
  const _ReminderTile(this.r);
  final Reminder r;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final on = r.enabled;
    return Semantics(
      button: true,
      label: '${r.title}, ${r.repeat.label} at ${hhmm(r.at)}, ${on ? 'on' : 'off'}. Long press to switch.',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => showReminderEditor(context, reminder: r),
        onLongPress: () {
          HapticFeedback.mediumImpact();
          ref.read(journalRepoProvider).patchReminder(r.id, RemindersCompanion(enabled: Value(!on)));
        },
        child: AnimatedOpacity(
          opacity: on ? 1 : 0.45,
          duration: context.motion(Motion.fast),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(Radii.card),
              border: Border.all(color: c.border, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.repeat.label.toUpperCase(), style: T.label(on ? c.accentInk : c.textDim)),
                const Spacer(),
                Text(hhmm(r.at), style: T.number(c.text, size: 34)),
                if (r.repeat == RepeatRule.none || r.repeat == RepeatRule.weekly)
                  Text(
                    r.repeat == RepeatRule.weekly
                        ? 'every ${weekdayShort[r.at.weekday - 1]}'
                        : dayLabel(r.at),
                    style: T.mono(c.textDim, size: 11),
                  ),
                const SizedBox(height: 6),
                Text(r.title, style: T.small(c.text), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Create or edit a reminder (optionally tied to a task).
Future<void> showReminderEditor(
  BuildContext context, {
  Reminder? reminder,
  int? taskId,
  String? title,
  DateTime? at,
}) {
  return showAnchorSheet<void>(
    context,
    builder: (_) => _ReminderEditor(reminder: reminder, taskId: taskId, title: title, at: at),
  );
}

class _ReminderEditor extends ConsumerStatefulWidget {
  const _ReminderEditor({this.reminder, this.taskId, this.title, this.at});
  final Reminder? reminder;
  final int? taskId;
  final String? title;
  final DateTime? at;

  @override
  ConsumerState<_ReminderEditor> createState() => _ReminderEditorState();
}

class _ReminderEditorState extends ConsumerState<_ReminderEditor> {
  late final _title = TextEditingController(text: widget.reminder?.title ?? widget.title ?? '');
  late DateTime _at = widget.reminder?.at ?? widget.at ?? DateTime.now().add(const Duration(hours: 1));
  late RepeatRule _repeat = widget.reminder?.repeat ?? RepeatRule.none;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = _title.text.trim();
    if (t.isEmpty) return;
    final repo = ref.read(journalRepoProvider);
    final nav = Navigator.of(context);
    if (widget.reminder == null) {
      await repo.addReminder(
        RemindersCompanion.insert(title: t, at: _at, repeat: Value(_repeat), taskId: Value(widget.taskId)),
      );
    } else {
      await repo.patchReminder(
        widget.reminder!.id,
        RemindersCompanion(title: Value(t), at: Value(_at), repeat: Value(_repeat)),
      );
    }
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SheetBody(
      title: widget.reminder == null ? 'New reminder' : 'Edit reminder',
      children: [
        TextField(
          controller: _title,
          autofocus: widget.reminder == null && widget.title == null,
          textCapitalization: TextCapitalization.sentences,
          style: T.h3(c.text),
          decoration: const InputDecoration(hintText: 'Remind me to…'),
          onChanged: (_) => setState(() {}),
        ),
        const FieldLabel('When'),
        SizedBox(
          height: 160,
          child: CupertinoTheme(
            data: CupertinoThemeData(
              brightness: c.isDark ? Brightness.dark : Brightness.light,
              textTheme: CupertinoTextThemeData(dateTimePickerTextStyle: T.h3(c.text)),
            ),
            child: CupertinoDatePicker(
              mode: _repeat == RepeatRule.none || _repeat == RepeatRule.weekly
                  ? CupertinoDatePickerMode.dateAndTime
                  : CupertinoDatePickerMode.time,
              initialDateTime: _at,
              minuteInterval: 1,
              use24hFormat: true,
              onDateTimeChanged: (v) => setState(() => _at = v),
            ),
          ),
        ),
        const FieldLabel('Repeat'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final r in RepeatRule.values)
              Pill(label: r.label, selected: _repeat == r, onTap: () => setState(() => _repeat = r)),
          ],
        ),
        if (_repeat == RepeatRule.weekly)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Every ${weekdayShort[_at.weekday - 1]} at ${hhmm(_at)}', style: T.mono(c.textDim)),
          ),
        const SizedBox(height: Space.xl),
        PrimaryButton(label: 'Save', onTap: _title.text.trim().isEmpty ? null : _save),
        if (widget.reminder != null)
          Center(
            child: TextButton(
              onPressed: () async {
                final nav = Navigator.of(context);
                await ref.read(journalRepoProvider).deleteReminder(widget.reminder!.id);
                nav.pop();
              },
              child: Text('Delete reminder', style: T.small(c.textDim)),
            ),
          ),
      ],
    );
  }
}
