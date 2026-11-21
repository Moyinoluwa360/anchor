import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/dates.dart';
import '../../providers/data_providers.dart';
import '../../providers/settings.dart';
import '../../router.dart';
import '../../services/backup_service.dart';
import '../../services/timer_logic.dart';
import '../../services/timer_service.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/grain_background.dart';
import '../../widgets/sheet.dart';
import '../reminders/notification_settings_sheet.dart';

const appVersion = '1.0.0';

/// Settings: appearance, rhythm, healthy limit, notifications, data.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;

  void _toast(String m) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(m), margin: const EdgeInsets.all(16)));

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final data = await BackupService.export(ref.read(dbProvider), ref.read(settingsProvider));
      final dir = await getTemporaryDirectory();
      final d = DateTime.now();
      final name =
          'exe-backup-${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}.json';
      final file = File(p.join(dir.path, name));
      await file.writeAsString(BackupService.encode(data));
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          subject: 'exe backup',
          sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (e) {
      _toast('Export did not work: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirm(String title, String body, String action) async {
    final ok = await showExeSheet<bool>(
      context,
      builder: (ctx) => SheetBody(
        title: title,
        subtitle: body,
        children: [
          PrimaryButton(label: action, onTap: () => Navigator.pop(ctx, true)),
          const SizedBox(height: Space.s),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: T.small(ctx.c.textDim)),
            ),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _import() async {
    final file = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(
          label: 'exe backup',
          extensions: ['json'],
          uniformTypeIdentifiers: ['public.json'],
        ),
      ],
    );
    if (file == null || !mounted) return;
    final ok = await _confirm(
      'Restore this backup?',
      'Everything on this phone is replaced by ${file.name}. Export first if you want to keep what is here.',
      'Replace and restore',
    );
    if (!ok) return;
    setState(() => _busy = true);
    try {
      final result = await BackupService.import(ref.read(dbProvider), await file.readAsString());
      final s = result.settings;
      if (s != null) {
        await ref.read(settingsProvider.notifier).replace(s.copyWith(notificationsAsked: true));
      }
      HapticFeedback.heavyImpact();
      _toast('Restored ${result.total} items.');
    } on BackupException catch (e) {
      _toast(e.message);
    } catch (e) {
      _toast('Could not read that file.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startFresh() async {
    final ok = await _confirm(
      'Start fresh?',
      'Removes every goal, task, block and record, including the sample data. Settings stay. This cannot be undone.',
      'Erase everything',
    );
    if (!ok) return;
    final db = ref.read(dbProvider);
    await ref.read(timerProvider.notifier).stop();
    await db.transaction(() async {
      for (final t in db.orderedTables.reversed) {
        await db.delete(t).go();
      }
    });
    HapticFeedback.heavyImpact();
    _toast('A clean slate. Add one small thing to start.');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final s = ref.watch(settingsProvider);
    final ctl = ref.read(settingsProvider.notifier);
    final pad = MediaQuery.paddingOf(context);

    Widget section(String t) => Padding(
      padding: const EdgeInsets.only(top: Space.xxl, bottom: Space.s),
      child: Text(t, style: T.label(c.textDim)),
    );
    Widget row(String title, {String? sub, Widget? trailing, VoidCallback? onTap, IconData? icon}) =>
        Semantics(
          button: onTap != null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  if (icon != null) ...[Icon(icon, size: 20, color: c.text), const SizedBox(width: 12)],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: T.bodyStrong(c.text)),
                        if (sub != null) Text(sub, style: T.small(c.textDim)),
                      ],
                    ),
                  ),
                  trailing ??
                      (onTap != null
                          ? Icon(Icons.chevron_right_rounded, color: c.textDim)
                          : const SizedBox()),
                ],
              ),
            ),
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
                  padding: EdgeInsets.fromLTRB(8, pad.top + 4, Space.gutter, 0),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.text, size: 20),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      if (_busy)
                        SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: c.accentInk),
                        ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(Space.gutter, Space.m, Space.gutter, pad.bottom + 40),
                sliver: SliverList.list(
                  children: [
                    Text('Settings', style: T.h1(c.text)),
                    section('APPEARANCE'),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final (m, l) in [
                          (ThemeMode.dark, 'Dark'),
                          (ThemeMode.light, 'Light'),
                          (ThemeMode.system, 'Match iPhone'),
                        ])
                          Pill(
                            label: l,
                            selected: s.themeMode == m,
                            onTap: () => ctl.update((x) => x.copyWith(themeMode: m)),
                          ),
                      ],
                    ),
                    section('FOCUS RHYTHM'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final pr in timerPresets)
                          Pill(
                            label: pr.label,
                            mono: true,
                            selected: s.focusMinutes == pr.focus && s.breakMinutes == pr.brk,
                            onTap: () => ref.read(timerProvider.notifier).setDefaultPreset(pr),
                          ),
                      ],
                    ),
                    row(
                      'Focus guard',
                      sub: 'Ask what pulled you away after a block',
                      trailing: Switch.adaptive(
                        value: s.distractionPrompt,
                        onChanged: (v) => ctl.update((x) => x.copyWith(distractionPrompt: v)),
                      ),
                    ),
                    section('A HEALTHY DAY'),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: s.healthyHours.toDouble(),
                            min: 4,
                            max: 12,
                            divisions: 8,
                            label: '${s.healthyHours}h',
                            onChanged: (v) => ctl.update((x) => x.copyWith(healthyHours: v.round())),
                          ),
                        ),
                        SizedBox(
                          width: 44,
                          child: Text(
                            '${s.healthyHours}h',
                            style: T.mono(c.text, w: FontWeight.w700),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Planned work beyond this turns the capacity ring amber.',
                      style: T.small(c.textDim),
                    ),
                    row(
                      'Free rest day each week',
                      sub: 'One missed day a week never touches the streak',
                      trailing: Switch.adaptive(
                        value: s.restDayOn,
                        onChanged: (v) => ctl.update((x) => x.copyWith(restDayOn: v)),
                      ),
                    ),
                    section('NOTIFICATIONS'),
                    const NotificationSettingsBody(embedded: true),
                    row(
                      'Reminders',
                      icon: Icons.notifications_none_rounded,
                      onTap: () => context.push(Routes.reminders),
                    ),
                    section('CAPTURE'),
                    row(
                      'Brain dump inbox',
                      icon: Icons.edit_note_rounded,
                      onTap: () => context.push(Routes.inbox),
                    ),
                    section('YOUR DATA'),
                    Text(
                      'Everything lives on this phone. No account, no server, no tracking.',
                      style: T.small(c.textDim),
                    ),
                    const SizedBox(height: 4),
                    row(
                      'Export a backup',
                      sub: 'One JSON file. Save it to Files or send it to yourself.',
                      icon: Icons.ios_share_rounded,
                      onTap: _busy ? null : _export,
                    ),
                    row(
                      'Import a backup',
                      sub: 'Replaces what is on this phone',
                      icon: Icons.download_rounded,
                      onTap: _busy ? null : _import,
                    ),
                    row(
                      'Start fresh',
                      sub: 'Clear the sample data and everything else',
                      icon: Icons.restart_alt_rounded,
                      onTap: _startFresh,
                    ),
                    section('ABOUT'),
                    Text('exe $appVersion · One thing at a time.', style: T.mono(c.textDim)),
                    const SizedBox(height: 4),
                    Text('Made for a calmer head. ${dayLabel(DateTime.now())}.', style: T.small(c.textDim)),
                    const SizedBox(height: Space.m),
                    GestureDetector(
                      onTap: () => showLicensePage(
                        context: context,
                        applicationName: 'exe',
                        applicationVersion: appVersion,
                      ),
                      child: Text('Open-source licences', style: T.small(c.accentInk)),
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
