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
import '../../services/deck_order.dart';
import '../../services/energy_service.dart';
import '../../services/timer_logic.dart';
import '../../services/timer_service.dart';
import '../../router.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/check_in_card.dart';
import '../../widgets/focus_guard_sheet.dart';
import '../../widgets/glass_bottom_bar.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/sheet.dart';
import '../../widgets/support_card.dart';
import '../../widgets/task_editor_sheet.dart';
import '../../widgets/top_three_sheet.dart';
import 'now_sheets.dart';
import 'task_card.dart';
import 'timer_view.dart';
import 'up_next_rail.dart';

/// Today's open tasks, with the one to do right now first (energy-aware).
final nowDeckProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(openTodayProvider).value ?? const <Task>[];
  final blocks = ref.watch(todayBlocksProvider).value ?? const <TimeBlock>[];
  final now = ref.watch(minuteTickProvider).value ?? DateTime.now();
  final energy = ref.watch(todayCheckInProvider)?.energy;
  return orderDeck(tasks, blocks, now, energy: energy);
});

/// Today's energy advice (lighter deck, rhythm, copy).
final energyAdviceProvider = Provider<EnergyAdvice>(
  (ref) => EnergyAdvice.of(ref.watch(todayCheckInProvider)?.energy),
);

/// Several low days in a row and not set aside today → show the support card.
final showSupportProvider = Provider<bool>((ref) {
  final list = ref.watch(checkInsProvider).value ?? const <EnergyCheckIn>[];
  final now = ref.watch(minuteTickProvider).value ?? DateTime.now();
  final dismissed = ref.watch(prefsProvider).getString('support.dismissed');
  if (dismissed == dayOf(now).toIso8601String()) return false;
  return EnergyService.lowStretch(list, now);
});

sealed class _Item {
  const _Item();
}

class _CheckInItem extends _Item {
  const _CheckInItem();
}

class _SupportItem extends _Item {
  const _SupportItem();
}

class _TaskItem extends _Item {
  const _TaskItem(this.task);
  final Task task;
}

class _RestingItem extends _Item {
  const _RestingItem(this.count);
  final int count;
}

/// Home: what is the one thing I do right now?
class NowScreen extends ConsumerStatefulWidget {
  const NowScreen({super.key});

  @override
  ConsumerState<NowScreen> createState() => _NowScreenState();
}

class _NowScreenState extends ConsumerState<NowScreen> {
  final _pc = PageController(viewportFraction: 0.88);
  double _page = 0;
  bool _showAll = false;
  bool _supportHidden = false;

  @override
  void initState() {
    super.initState();
    _pc.addListener(() => setState(() => _page = _pc.page ?? 0));
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _toast(String text, {VoidCallback? undo}) {
    final m = ScaffoldMessenger.of(context);
    m.hideCurrentSnackBar();
    m.showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.fromLTRB(16, 0, 16, GlassBottomBar.reserved(context) + 70),
        action: undo == null ? null : SnackBarAction(label: 'Undo', onPressed: undo),
      ),
    );
  }

  Future<void> _complete(Task t) async {
    final repo = ref.read(taskRepoProvider);
    final left = ref.read(nowDeckProvider).length;
    await repo.complete(t.id);
    if (!mounted) return;
    _toast(left <= 1 ? 'Deck cleared. Look at you.' : 'Nice. One down.', undo: () => repo.reopen(t.id));
  }

  Future<void> _snooze(Task t) async {
    final repo = ref.read(taskRepoProvider);
    final until = snoozeUntil(DateTime.now());
    await repo.snooze(t.id, until);
    if (!mounted) return;
    final when = sameDay(until, DateTime.now()) ? hhmm(until) : 'tomorrow';
    _toast(
      'Later it is: back at $when.',
      undo: () => repo.patch(
        t.id,
        TasksCompanion(
          status: const Value(TaskStatus.todo),
          snoozedUntil: const Value(null),
          scheduledDate: Value(today()),
        ),
      ),
    );
  }

  Future<void> _stuck(Task t, List<Task> deck, List<_Item> items) async {
    final choice = await showStuckSheet(context, t, easierThan(t, deck));
    if (choice == null || !mounted) return;
    final timer = ref.read(timerProvider.notifier);
    switch (choice) {
      case ShrinkIt(:final firstStep):
        await ref.read(taskRepoProvider).patch(t.id, TasksCompanion(firstStep: Value(firstStep)));
        final fresh = await ref.read(taskRepoProvider).byId(t.id);
        await timer.start(task: fresh ?? t, preset: starterPreset);
      case SwapTo(:final task):
        var idx = items.indexWhere((x) => x is _TaskItem && x.task.id == task.id);
        if (idx < 0) {
          // It was resting behind a low-energy limit: show everything.
          setState(() => _showAll = true);
          idx = deck.indexWhere((x) => x.id == task.id) + items.indexWhere((x) => x is _TaskItem);
        }
        if (idx >= 0 && mounted) {
          await _pc.animateToPage(idx, duration: context.motion(Motion.slow), curve: Motion.curve);
        }
      case ResetBreak():
        await timer.startReset();
    }
  }

  /// After a check-in, match the timer rhythm to the energy.
  Future<void> _afterCheckIn() async {
    final advice = ref.read(energyAdviceProvider);
    final timer = ref.read(timerProvider);
    var msg = 'Thanks. Your day is set to match.';
    if (advice.isLow && timer.focusMinutes > 25) {
      await ref.read(timerProvider.notifier).setDefaultPreset(advice.preset);
      msg = 'Low battery noted: shorter 25-minute blocks today.';
    } else if (advice.isHigh) {
      msg = 'Good energy. Hardest thing first.';
    }
    if (mounted) _toast(msg);
  }

  Future<void> _recheck() => showExeSheet<void>(
    context,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, Space.xl),
      child: SizedBox(
        height: 470,
        child: CheckInCard(
          onSaved: () {
            Navigator.pop(ctx);
            _afterCheckIn();
          },
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(timerProvider);

    ref.listen(timerProvider.select((s) => s.event), (_, e) {
      if (e == TimerEvent.none) return;
      final msg = switch (e) {
        TimerEvent.focusDone => 'Focus block done. Break time: hard stop.',
        TimerEvent.breakDone => "Break's over. Ready when you are.",
        TimerEvent.stoppedEarly => 'Stopped. The minutes you did still count.',
        TimerEvent.none => '',
      };
      final service = ref.read(timerProvider.notifier);
      final brk = ref.read(timerProvider).breakMinutes;
      service.ackEvent();
      if (e == TimerEvent.focusDone && ref.read(settingsProvider).distractionPrompt) {
        // Focus guard: a gentle stop and an optional distraction note.
        showFocusGuard(context, sessionId: service.lastSessionId, breakMinutes: brk);
      } else {
        _toast(msg);
      }
    });

    final allTasks = ref.watch(allTasksProvider).value ?? const <Task>[];
    final timerTask = allTasks.firstWhereOrNull((t) => t.id == timer.taskId);

    return AnimatedSwitcher(
      duration: context.motion(Motion.slow),
      switchInCurve: Motion.curve,
      transitionBuilder: (child, a) => FadeTransition(
        opacity: a,
        child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(a), child: child),
      ),
      child: timer.isIdle
          ? KeyedSubtree(key: const ValueKey('deck'), child: _deck(context))
          : TimerView(key: const ValueKey('timer'), task: timerTask),
    );
  }

  Widget _deck(BuildContext context) {
    final c = context.c;
    final deck = ref.watch(nowDeckProvider);
    final loaded = ref.watch(openTodayProvider).hasValue;
    final checkIn = ref.watch(todayCheckInProvider);
    final needsCheckIn = ref.watch(checkInsProvider).hasValue && checkIn == null;
    final support = ref.watch(showSupportProvider) && !_supportHidden;
    final advice = ref.watch(energyAdviceProvider);
    final blocks = ref.watch(todayBlocksProvider).value ?? const <TimeBlock>[];
    final now = ref.watch(minuteTickProvider).value ?? DateTime.now();
    final timer = ref.watch(timerProvider);
    final pad = MediaQuery.paddingOf(context);

    // A low-energy day shows a lighter deck; the rest are "resting".
    final limit = _showAll ? null : advice.deckLimit;
    final visible = limit == null ? deck : deck.take(limit).toList();
    final resting = deck.length - visible.length;
    final items = <_Item>[
      if (needsCheckIn) const _CheckInItem(),
      if (support) const _SupportItem(),
      for (final t in visible) _TaskItem(t),
      if (resting > 0) _RestingItem(resting),
    ];

    final pageIndex = _page.round().clamp(0, items.isEmpty ? 0 : items.length - 1);
    final currentItem = items.isEmpty ? null : items[pageIndex];
    final current = currentItem is _TaskItem ? currentItem.task : null;
    final blockById = {for (final b in blocks) b.id: b};
    final tops = deck.where((t) => t.topRank != null).toList()
      ..sort((a, b) => a.topRank!.compareTo(b.topRank!));
    final kicker = [
      dayLabel(now).toUpperCase(),
      '${deck.length} TO GO',
      if (checkIn != null) 'ENERGY ${checkIn.energy}/5',
    ].join(' · ');

    Widget card(int i) {
      final item = items[i];
      return switch (item) {
        _CheckInItem() => CheckInCard(onSaved: _afterCheckIn),
        _SupportItem() => SupportCard(
          onDismiss: () async {
            await ref
                .read(prefsProvider)
                .setString('support.dismissed', dayOf(DateTime.now()).toIso8601String());
            setState(() => _supportHidden = true);
          },
        ),
        _RestingItem(:final count) => _RestingCard(
          count: count,
          onShow: () => setState(() => _showAll = true),
        ),
        _TaskItem(:final task) => TaskCard(
          key: ValueKey('task-${task.id}'),
          task: task,
          block: task.timeBlockId == null ? null : blockById[task.timeBlockId],
          active: i == pageIndex,
          now: now,
          hint: i == pageIndex && advice.isHigh && task.effort == Effort.heavy
              ? 'Hardest first. You\'ve got this.'
              : null,
          onComplete: () => _complete(task),
          onSnooze: () => _snooze(task),
          onEdit: () => showTaskEditor(context, task: task),
        ),
      };
    }

    Widget primary() {
      return switch (currentItem) {
        _CheckInItem() => PrimaryButton(
          label: items.length > 1 ? 'Skip for now' : 'Check in above',
          onTap: items.length > 1
              ? () => _pc.animateToPage(1, duration: context.motion(Motion.slow), curve: Motion.curve)
              : null,
        ),
        _SupportItem() => PrimaryButton(
          label: 'Continue gently',
          onTap: () =>
              _pc.animateToPage(pageIndex + 1, duration: context.motion(Motion.slow), curve: Motion.curve),
        ),
        _RestingItem() => PrimaryButton(label: 'Show the rest', onTap: () => setState(() => _showAll = true)),
        _ => PrimaryButton(
          label: 'Start',
          icon: Icons.play_arrow_rounded,
          trailing: '${timer.focusMinutes} min',
          onTap: current == null ? null : () => ref.read(timerProvider.notifier).start(task: current),
        ),
      };
    }

    Widget deckView() => !loaded
        ? const SizedBox.shrink()
        : items.isEmpty
        ? _EmptyDeck(onAdd: () => showTaskEditor(context))
        : PageView.builder(
            controller: _pc,
            itemCount: items.length,
            padEnds: false,
            itemBuilder: (context, i) {
              final delta = (i - _page).abs().clamp(0.0, 1.0);
              return Padding(
                padding: EdgeInsets.only(left: i == 0 ? Space.gutter : 6, right: 6, bottom: 4),
                child: Transform.scale(
                  scale: 1 - 0.06 * delta,
                  alignment: i < _page ? Alignment.centerRight : Alignment.centerLeft,
                  child: Opacity(opacity: 1 - 0.35 * delta, child: card(i)),
                ),
              );
            },
          );

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(Space.gutter, pad.top + 4, 8, 0),
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    const Spacer(),
                    HeaderButton(
                      icon: Icons.star_outline_rounded,
                      label: 'Today\'s top 3',
                      onTap: () => showTopThreeSheet(context),
                    ),
                    HeaderButton(
                      icon: Icons.add_rounded,
                      label: 'Add task',
                      onTap: () => showTaskEditor(context),
                    ),
                    HeaderButton(
                      icon: Icons.tune_rounded,
                      label: 'Settings',
                      onTap: () => context.push(Routes.settings),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.gutter, 8, Space.gutter, 0),
              child: GestureDetector(
                onTap: checkIn == null ? null : _recheck,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(kicker, style: T.label(c.textDim), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ),
            if (advice.headline.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.gutter, 4, Space.gutter, 0),
                child: Row(
                  children: [
                    Text('${advice.headline}. ', style: T.small(advice.isLow ? c.text : c.accentInk)),
                    Expanded(
                      child: Text(
                        advice.hint,
                        style: T.small(c.textDim),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            if (tops.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.gutter, 8, Space.gutter, 0),
                child: _TopStrip(tops: tops, onTap: () => showTopThreeSheet(context)),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: deckView()),
                  // Peeks in from the right edge, in the calm middle band of the cards.
                  Align(
                    alignment: const Alignment(1, 0.05),
                    child: UpNextRail(blocks: blocks, now: now),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                Space.gutter,
                Space.l,
                Space.gutter,
                GlassBottomBar.reserved(context) - 4,
              ),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: 'Focus rhythm ${timer.focusMinutes} minutes, break ${timer.breakMinutes}',
                    excludeSemantics: true,
                    child: GestureDetector(
                      onTap: () async {
                        final p = await showPresetSheet(
                          context,
                          TimerPreset(timer.focusMinutes, timer.breakMinutes),
                        );
                        if (p != null) await ref.read(timerProvider.notifier).setDefaultPreset(p);
                      },
                      child: Container(
                        height: 60,
                        width: 64,
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: c.border, width: 0.8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${timer.focusMinutes}/${timer.breakMinutes}',
                          style: T.mono(c.text, size: 13, w: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: primary()),
                  const SizedBox(width: 10),
                  Semantics(
                    button: true,
                    enabled: current != null,
                    label: 'Stuck? Shrink this task',
                    excludeSemantics: true,
                    child: GestureDetector(
                      onTap: current == null
                          ? null
                          : () {
                              HapticFeedback.selectionClick();
                              _stuck(current, deck, items);
                            },
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: c.border, width: 0.8),
                        ),
                        alignment: Alignment.center,
                        child: Text('Stuck?', style: T.bodyStrong(current == null ? c.textDim : c.text)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Today's top 3 as three slim slots.
class _TopStrip extends StatelessWidget {
  const _TopStrip({required this.tops, required this.onTap});
  final List<Task> tops;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      button: true,
      label: 'Top 3: ${tops.map((t) => t.title).join(', ')}. Tap to change.',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: i < tops.length ? c.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.border, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${i + 1}',
                        style: T.mono(
                          i < tops.length ? c.accentInk : c.textDim,
                          w: FontWeight.w700,
                          size: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          i < tops.length ? tops[i].title : '—',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: T.small(c.text).copyWith(fontSize: 11.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RestingCard extends StatelessWidget {
  const _RestingCard({required this.count, required this.onShow});
  final int count;
  final VoidCallback onShow;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.big),
        border: Border.all(color: c.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RESTING', style: T.label(c.textDim)),
          const SizedBox(height: Space.m),
          Text('$count more can wait.', style: T.display(c.text).copyWith(fontSize: 36)),
          const SizedBox(height: Space.m),
          Text('Low energy means a lighter day. These stay safe for later.', style: T.body(c.textDim)),
          const Spacer(),
          GhostButton(label: 'Show them anyway', onTap: onShow),
        ],
      ),
    );
  }
}

class _EmptyDeck extends StatelessWidget {
  const _EmptyDeck({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.big),
          border: Border.all(color: c.border, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CLEAR DECK', style: T.label(c.accentInk)),
            const SizedBox(height: Space.m),
            Text('Nothing left\nfor today.', style: T.display(c.text)),
            const SizedBox(height: Space.m),
            Text('Go outside, rest, or add one small thing.', style: T.body(c.textDim)),
            const Spacer(),
            GhostButton(label: 'Add one thing', icon: Icons.add_rounded, onTap: onAdd),
          ],
        ),
      ),
    );
  }
}
