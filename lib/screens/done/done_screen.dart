import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../models/dates.dart';
import '../../models/enums.dart';
import '../../providers/data_providers.dart';
import '../../providers/settings.dart';
import '../../providers/ui_providers.dart';
import '../../services/insights_service.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/glass_bottom_bar.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/sheet.dart';
import '../../widgets/task_editor_sheet.dart';
import 'done_widgets.dart';

/// Done: a heat map, a stack of wins, gentle streaks and trends. No guilt.
class DoneScreen extends ConsumerStatefulWidget {
  const DoneScreen({super.key});

  @override
  ConsumerState<DoneScreen> createState() => _DoneScreenState();
}

class _DoneScreenState extends ConsumerState<DoneScreen> {
  Period _period = Period.day;
  final _stackPc = PageController(viewportFraction: 0.86);

  @override
  void dispose() {
    _stackPc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final now = ref.watch(minuteTickProvider).value ?? DateTime.now();
    final done = ref.watch(doneTasksProvider).value ?? const <Task>[];
    final sessions = ref.watch(allSessionsProvider).value ?? const <FocusSession>[];
    final checkIns = ref.watch(checkInsProvider).value ?? const <EnergyCheckIn>[];
    final highlights = ref.watch(highlightsProvider).value ?? const <Highlight>[];
    final streak = ref.watch(streakProvider);
    final restDay = ref.watch(settingsProvider.select((s) => s.restDayOn));

    final counts = InsightsService.dailyCounts(done);
    final stats = InsightsService.areaStats(done, now, restDay: restDay);
    final strong = InsightsService.strongest(stats);
    final weak = InsightsService.neglected(stats);
    final groups = InsightsService.groups(done, sessions, _period, now);
    final summary = now.weekday == DateTime.sunday ? InsightsService.sunday(done, now) : null;
    final focus = InsightsService.weeklyFocus(sessions, now);
    final energy = InsightsService.energySeries(checkIns, now);

    Widget label(String t, {Widget? trailing}) => Padding(
      padding: const EdgeInsets.only(top: Space.xxl, bottom: Space.m),
      child: Row(
        children: [
          Text(t, style: T.label(c.textDim)),
          const Spacer(),
          ?trailing,
        ],
      ),
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ScreenHeader(
            title: 'Done',
            kicker: '${done.length} things finished, all time',
            actions: [
              HeaderButton(
                icon: Icons.emoji_events_outlined,
                label: 'Add a big win',
                onTap: () => _addWin(context),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(Space.gutter, Space.l, Space.gutter, GlassBottomBar.reserved(context)),
          sliver: SliverList.list(
            children: [
              // Streak hero.
              Semantics(
                label: 'Current streak ${streak.current} days. Best ever ${streak.best}.',
                excludeSemantics: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 40,
                      color: streak.paused ? c.textDim : c.accentInk,
                    ),
                    const SizedBox(width: 6),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: streak.current.toDouble()),
                      duration: context.motion(Motion.slow),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, _) => Text('${v.round()}', style: T.number(c.text, size: 88)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('day streak', style: T.h3(c.text)),
                            Text(
                              streak.paused
                                  ? 'Resting. It picks up when you do.'
                                  : 'Best ever: ${streak.best}',
                              style: T.small(c.textDim),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${streak.best}', style: T.number(c.textDim, size: 28)),
                          Text('BEST', style: T.label(c.textDim)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (restDay)
                Text(
                  streak.restDaysUsed > 0
                      ? 'Rest day used this week. Well spent.'
                      : 'One free rest day a week never breaks it.',
                  style: T.mono(c.textDim, size: 11),
                ),
              if (summary != null) ...[
                const SizedBox(height: Space.xl),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(Radii.card),
                    border: Border.all(color: c.border, width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('YOUR WEEK · SUNDAY SUMMARY', style: T.label(c.accentInk)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCell(
                              label: 'Most consistent',
                              area: summary.consistent,
                              lemon: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SummaryCell(label: 'Most neglected', area: summary.neglected),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(summary.suggestion, style: T.body(c.text)),
                    ],
                  ),
                ),
              ],
              label('LAST 6 MONTHS', trailing: Text('tap a day', style: T.mono(c.textDim, size: 11))),
              HeatMap(
                counts: counts,
                now: now,
                onDay: (d) => showDaySheet(
                  context,
                  d,
                  done.where((t) => t.completedAt != null && sameDay(t.completedAt!, d)).toList(),
                ),
              ),
              if (highlights.isNotEmpty) ...[
                label('BIG WINS'),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    itemCount: highlights.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, i) => _WinCard(h: highlights[i]),
                  ),
                ),
              ],
              label('DONE STACK'),
              _PeriodSwitch(value: _period, onChanged: (p) => setState(() => _period = p)),
              const SizedBox(height: Space.l),
              if (groups.isEmpty)
                Text('Your first finished task will land here.', style: T.body(c.textDim))
              else
                SizedBox(
                  height: 380,
                  child: PageView.builder(
                    controller: _stackPc,
                    padEnds: false,
                    itemCount: groups.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _GroupStack(group: groups[i], period: _period, now: now),
                    ),
                  ),
                ),
              label('STREAKS BY LIFE AREA'),
              _AreaGrid(stats: stats, strong: strong, weak: weak),
              label('GENTLE TRENDS'),
              Row(
                children: [
                  Expanded(
                    child: _TrendTile(
                      title: 'Focus hours / week',
                      value: focus.isEmpty ? '0' : focus.last.toStringAsFixed(1),
                      child: TrendLine(values: focus),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TrendTile(
                      title: 'Energy, 30 days',
                      value: energy.lastWhere((e) => e != null, orElse: () => null)?.toString() ?? '–',
                      child: TrendLine(values: InsightsService.smooth(energy), maxY: 5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _addWin(BuildContext context) async {
    final ctl = TextEditingController();
    await showAnchorSheet<void>(
      context,
      builder: (ctx) => SheetBody(
        title: 'A big win',
        subtitle: 'Shipped something? Landed a client? Put it here.',
        children: [
          TextField(
            controller: ctl,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            style: T.h3(ctx.c.text),
            decoration: const InputDecoration(hintText: 'e.g. Shipped the app to the App Store'),
          ),
          const SizedBox(height: Space.l),
          PrimaryButton(
            label: 'Celebrate it',
            onTap: () async {
              final t = ctl.text.trim();
              if (t.isEmpty) return;
              final nav = Navigator.of(ctx);
              await ref
                  .read(journalRepoProvider)
                  .addHighlight(HighlightsCompanion.insert(title: t, date: DateTime.now()));
              HapticFeedback.heavyImpact();
              nav.pop();
            },
          ),
        ],
      ),
    );
    ctl.dispose();
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({required this.label, required this.area, this.lemon = false});
  final String label;
  final LifeArea area;
  final bool lemon;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: lemon ? c.accent : c.surface2,
        borderRadius: BorderRadius.circular(Radii.chip),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: T.label(lemon ? c.onAccent : c.textDim).copyWith(fontSize: 9)),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(area.icon, size: 16, color: lemon ? c.onAccent : c.text),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  area.label,
                  style: T.bodyStrong(lemon ? c.onAccent : c.text),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WinCard extends StatelessWidget {
  const _WinCard({required this.h});
  final Highlight h;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.accent,
        borderRadius: BorderRadius.circular(Radii.card),
        boxShadow: [
          BoxShadow(
            color: c.accent.withValues(alpha: 0.25),
            blurRadius: 20,
            spreadRadius: -6,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded, size: 16, color: c.onAccent),
              const SizedBox(width: 6),
              Text(dayLabel(h.date).toUpperCase(), style: T.label(c.onAccent)),
            ],
          ),
          const Spacer(),
          Text(h.title, style: T.h3(c.onAccent), maxLines: 3, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _PeriodSwitch extends StatelessWidget {
  const _PeriodSwitch({required this.value, required this.onChanged});
  final Period value;
  final ValueChanged<Period> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border, width: 0.8),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth / 3;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: context.motion(Motion.med),
                curve: Curves.easeOutBack,
                left: value.index * w,
                top: 0,
                bottom: 0,
                width: w,
                child: Container(
                  decoration: BoxDecoration(color: c.text, borderRadius: BorderRadius.circular(17)),
                ),
              ),
              Row(
                children: [
                  for (final p in Period.values)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: p == value,
                        label: 'Group by ${p.name}',
                        excludeSemantics: true,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onChanged(p);
                          },
                          child: Center(
                            child: Text(
                              p.name[0].toUpperCase() + p.name.substring(1),
                              style: T
                                  .small(p == value ? c.bg : c.textDim)
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GroupStack extends StatelessWidget {
  const _GroupStack({required this.group, required this.period, required this.now});
  final DoneGroup group;
  final Period period;
  final DateTime now;

  String get _title {
    switch (period) {
      case Period.day:
        if (sameDay(group.start, now)) return 'Today';
        if (sameDay(group.start, addDays(today(now), -1))) return 'Yesterday';
        return dayLabel(group.start);
      case Period.week:
        if (group.start == weekStartOf(now)) return 'This week';
        return 'Week of ${dayLabel(group.start)}';
      case Period.month:
        return '${monthShort[group.start.month - 1]} ${group.start.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_title, style: T.h2(c.text)),
        const SizedBox(height: Space.m),
        Row(
          children: [
            _Num(value: '${group.tasks.length}', label: 'finished'),
            const SizedBox(width: 22),
            _Num(value: group.focusHours.toStringAsFixed(1), label: 'focus hours'),
            const SizedBox(width: 22),
            _Num(value: '${group.goalsAdvanced}', label: 'goals moved'),
          ],
        ),
        const SizedBox(height: Space.l),
        Expanded(child: CardStack(tasks: group.tasks, height: 200)),
      ],
    );
  }
}

class _Num extends StatelessWidget {
  const _Num({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: T.number(c.text, size: 40)),
        Text(label, style: T.mono(c.textDim, size: 11)),
      ],
    );
  }
}

class _AreaGrid extends ConsumerWidget {
  const _AreaGrid({required this.stats, required this.strong, required this.weak});
  final List<AreaStat> stats;
  final AreaStat? strong;
  final AreaStat? weak;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Strongest first, the flagged one last, others in between.
    final ordered = [...stats]
      ..sort((a, b) {
        int rank(AreaStat s) => s.area == strong?.area ? 0 : (s.area == weak?.area ? 2 : 1);
        final r = rank(a).compareTo(rank(b));
        return r != 0 ? r : b.last30.compareTo(a.last30);
      });
    Widget tile(AreaStat s) => AreaTile(
      stat: s,
      onFire: s.area == strong?.area,
      needsAttention: s.area == weak?.area,
      onSchedule: () =>
          showTaskEditor(
            context,
            area: s.area,
            title: '15 minutes on ${s.area.label.toLowerCase()}',
            day: today(),
          ).then((id) async {
            if (id == null) return;
            await ref
                .read(taskRepoProvider)
                .patch(id, const TasksCompanion(estimatedMinutes: Value(15), effort: Value(Effort.light)));
          }),
    );
    return Column(
      children: [
        tile(ordered.first),
        const SizedBox(height: 10),
        for (var i = 1; i < ordered.length; i += 2) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: tile(ordered[i])),
              const SizedBox(width: 10),
              Expanded(child: i + 1 < ordered.length ? tile(ordered[i + 1]) : const SizedBox()),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _TrendTile extends StatelessWidget {
  const _TrendTile({required this.title, required this.value, required this.child});
  final String title;
  final String value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: c.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: T.label(c.textDim).copyWith(fontSize: 9)),
          const SizedBox(height: 4),
          Text(value, style: T.number(c.text, size: 28)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
