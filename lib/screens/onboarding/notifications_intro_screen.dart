import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings.dart';
import '../../services/notification_service.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/grain_background.dart';

/// Friendly explanation before the iOS permission prompt. Shown once.
class NotificationsIntroScreen extends ConsumerWidget {
  const NotificationsIntroScreen({super.key});

  Future<void> _finish(BuildContext context, WidgetRef ref, {required bool ask}) async {
    final nav = Navigator.of(context);
    if (ask) await ref.read(notificationServiceProvider).requestPermission();
    await ref.read(settingsProvider.notifier).update((s) => s.copyWith(notificationsAsked: true));
    ref.read(notificationSyncProvider.notifier).schedule();
    if (nav.canPop()) nav.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final pad = MediaQuery.paddingOf(context);
    Widget row(IconData i, String title, String body) => Padding(
      padding: const EdgeInsets.only(bottom: Space.l),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.surface,
              shape: BoxShape.circle,
              border: Border.all(color: c.border),
            ),
            child: Icon(i, size: 19, color: c.accentInk),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: T.bodyStrong(c.text)),
                Text(body, style: T.small(c.textDim)),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: GrainBackground()),
          Padding(
            padding: EdgeInsets.fromLTRB(Space.gutter, pad.top + 40, Space.gutter, pad.bottom + 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
                  child: Icon(Icons.notifications_active_rounded, size: 34, color: c.onAccent),
                ),
                const SizedBox(height: Space.xl),
                Text('A gentle tap\non the shoulder.', style: T.display(c.text)),
                const SizedBox(height: Space.m),
                Text(
                  'exe only nudges you when it helps. Everything stays on your phone.',
                  style: T.body(c.textDim),
                ),
                const SizedBox(height: Space.xxl),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        row(
                          Icons.timer_rounded,
                          'Timer chime',
                          'A clear sound when focus or a break ends, even with the app closed.',
                        ),
                        row(
                          Icons.schedule_rounded,
                          'Blocks starting',
                          'Five minutes before each planned block.',
                        ),
                        row(
                          Icons.wb_sunny_rounded,
                          'Morning and evening',
                          'A 10-second check-in, and a calm wrap-up.',
                        ),
                        row(
                          Icons.bedtime_rounded,
                          'Quiet hours',
                          'Nothing while you sleep. You choose the hours.',
                        ),
                      ],
                    ),
                  ),
                ),
                PrimaryButton(label: 'Turn on notifications', onTap: () => _finish(context, ref, ask: true)),
                const SizedBox(height: Space.s),
                Center(
                  child: TextButton(
                    onPressed: () => _finish(context, ref, ask: false),
                    child: Text('Not now', style: T.small(c.textDim)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
