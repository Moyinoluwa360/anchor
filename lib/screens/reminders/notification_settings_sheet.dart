import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings.dart';
import '../../services/notification_service.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/sheet.dart';

String _hm(int m) => '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

/// Notification toggles, their times, and quiet hours. Also used inside Settings.
Future<void> showNotificationSettings(BuildContext context) =>
    showAnchorSheet<void>(context, builder: (_) => const NotificationSettingsBody());

class NotificationSettingsBody extends ConsumerStatefulWidget {
  const NotificationSettingsBody({super.key, this.embedded = false});

  /// When true, renders without the sheet title (inside the Settings screen).
  final bool embedded;

  @override
  ConsumerState<NotificationSettingsBody> createState() => _NotificationSettingsBodyState();
}

class _NotificationSettingsBodyState extends ConsumerState<NotificationSettingsBody> {
  bool? _allowed;

  @override
  void initState() {
    super.initState();
    ref.read(notificationServiceProvider).isAllowed().then((v) {
      if (mounted) setState(() => _allowed = v);
    });
  }

  Future<void> _pickTime(int current, ValueChanged<int> onPicked) async {
    var picked = current;
    final c = context.c;
    await showAnchorSheet<void>(
      context,
      builder: (ctx) => SizedBox(
        height: 300,
        child: Column(
          children: [
            Expanded(
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: c.isDark ? Brightness.dark : Brightness.light,
                  textTheme: CupertinoTextThemeData(dateTimePickerTextStyle: T.h3(c.text)),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  minuteInterval: 5,
                  initialDateTime: DateTime(2000, 1, 1, current ~/ 60, (current % 60) ~/ 5 * 5),
                  onDateTimeChanged: (d) => picked = d.hour * 60 + d.minute,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Done', style: T.bodyStrong(c.accentInk)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final s = ref.watch(settingsProvider);
    final ctl = ref.read(settingsProvider.notifier);

    Widget row(
      String title,
      String? sub,
      bool value,
      ValueChanged<bool> onChanged, {
      int? time,
      ValueChanged<int>? onTime,
    }) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: T.bodyStrong(c.text)),
                if (sub != null) Text(sub, style: T.small(c.textDim)),
              ],
            ),
          ),
          if (time != null && onTime != null && value)
            GestureDetector(
              onTap: () => _pickTime(time, onTime),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(10)),
                child: Text(_hm(time), style: T.mono(c.text, w: FontWeight.w700)),
              ),
            ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );

    final children = <Widget>[
      if (_allowed == false)
        Container(
          margin: const EdgeInsets.only(bottom: Space.m),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(Radii.chip)),
          child: Row(
            children: [
              Icon(Icons.notifications_off_rounded, color: c.textDim, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Notifications are off for Anchor. Turn them on in iPhone Settings → Anchor.',
                  style: T.small(c.textDim),
                ),
              ),
            ],
          ),
        ),
      const FieldLabel('Nudges'),
      row(
        'Morning check-in',
        'A 10-second energy check',
        s.morningNudge,
        (v) => ctl.update((x) => x.copyWith(morningNudge: v)),
        time: s.morningTime,
        onTime: (m) => ctl.update((x) => x.copyWith(morningTime: m)),
      ),
      row(
        'Evening wrap-up',
        'See what you did today',
        s.eveningWrap,
        (v) => ctl.update((x) => x.copyWith(eveningWrap: v)),
        time: s.eveningTime,
        onTime: (m) => ctl.update((x) => x.copyWith(eveningTime: m)),
      ),
      row(
        'Sunday review',
        'Close the week, pick next targets',
        s.sundayReview,
        (v) => ctl.update((x) => x.copyWith(sundayReview: v)),
        time: s.sundayTime,
        onTime: (m) => ctl.update((x) => x.copyWith(sundayTime: m)),
      ),
      row(
        'Block starting',
        '5 minutes before each block',
        s.blockAlerts,
        (v) => ctl.update((x) => x.copyWith(blockAlerts: v)),
      ),
      row(
        'Timer chime',
        'Sound when focus or a break ends',
        s.timerSound,
        (v) => ctl.update((x) => x.copyWith(timerSound: v)),
      ),
      const FieldLabel('Quiet hours'),
      row(
        'Respect my sleep',
        'Nudges and reminders wait until morning',
        s.quietHoursOn,
        (v) => ctl.update((x) => x.copyWith(quietHoursOn: v)),
      ),
      if (s.quietHoursOn)
        Row(
          children: [
            Expanded(
              child: _TimeTile(
                label: 'From',
                value: _hm(s.quietStart),
                onTap: () => _pickTime(s.quietStart, (m) => ctl.update((x) => x.copyWith(quietStart: m))),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TimeTile(
                label: 'Until',
                value: _hm(s.quietEnd),
                onTap: () => _pickTime(s.quietEnd, (m) => ctl.update((x) => x.copyWith(quietEnd: m))),
              ),
            ),
          ],
        ),
      const SizedBox(height: Space.s),
      Text('The focus timer still chimes during quiet hours: you started it.', style: T.small(c.textDim)),
    ];

    if (widget.embedded) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
    }
    return SheetBody(title: 'Notifications', children: children);
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({required this.label, required this.value, required this.onTap});
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      button: true,
      label: '$label $value',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.surface2,
            borderRadius: BorderRadius.circular(Radii.chip),
            border: Border.all(color: c.border, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: T.label(c.textDim)),
              const SizedBox(height: 4),
              Text(value, style: T.number(c.text, size: 28)),
            ],
          ),
        ),
      ),
    );
  }
}
