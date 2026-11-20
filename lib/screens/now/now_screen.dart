import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../models/dates.dart';
import '../../models/enums.dart';
import '../../providers/data_providers.dart';
import '../../services/deck_order.dart';
import '../../services/timer_logic.dart';
import '../../services/timer_service.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';
import '../../widgets/check_in_card.dart';
import '../../widgets/glass_bottom_bar.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/task_editor_sheet.dart';
import 'now_sheets.dart';
import 'task_card.dart';
import 'timer_view.dart';
import 'up_next_rail.dart';

/// Today's open tasks, with the one to do right now first.
final nowDeckProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(openTodayProvider).value ?? const <Task>[];
  final blocks = ref.watch(todayBlocksProvider).value ?? const <TimeBlock>[];
  final now = ref.watch(minuteTickProvider).value ?? DateTime.now();
  return orderDeck(tasks, blocks, now);
});

/// Home: what is the one thing I do right now?
class NowScreen extends ConsumerStatefulWidget {
  const NowScreen({super.key});

  @override
  ConsumerState<NowScreen> createState() => _NowScreenState();
}

class _NowScreenState extends ConsumerState<NowScreen> {
  final _pc = PageController(viewportFraction: 0.88);
  double _page = 0;

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
        action: undo == null
            ? null
            : SnackBarAction(label: 'Undo', textColor: context.c.accentInk, onPressed: undo),
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

  Future<void> _stuck(Task t, List<Task> deck, int offset) async {
    final choice = await showStuckSheet(context, t, easierThan(t, deck));
    if (choice == null || !mounted) return;
    final timer = ref.read(timerProvider.notifier);
    switch (choice) {
      case ShrinkIt(:final firstStep):
        await ref.read(taskRepoProvider).patch(t.id, TasksCompanion(firstStep: Value(firstStep)));
        final fresh = await ref.read(taskRepoProvider).byId(t.id);
        await timer.start(task: fresh ?? t, preset: starterPreset);
      case SwapTo(:final task):
        final idx = deck.indexWhere((x) => x.id == task.id);
        if (idx >= 0 && mounted) {
          await _pc.animateToPage(idx + offset, duration: context.motion(Motion.slow), curve: Motion.curve);
        }
      case ResetBreak():
        await timer.startReset();
    }
  }

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
      _toast(msg);
      ref.read(timerProvider.notifier).ackEvent();
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
    final blocks = ref.watch(todayBlocksProvider).value ?? const <TimeBlock>[];
    final now = ref.watch(minuteTickProvider).value ?? DateTime.now();
    final timer = ref.watch(timerProvider);
    final pad = MediaQuery.paddingOf(context);

    final offset = needsCheckIn ? 1 : 0;
    final count = deck.length + offset;
    final pageIndex = _page.round().clamp(0, count == 0 ? 0 : count - 1);
    final ti = pageIndex - offset;
    final current = ti >= 0 && ti < deck.length ? deck[ti] : null;
    final onCheckIn = needsCheckIn && pageIndex == 0;
    final blockById = {for (final b in blocks) b.id: b};
    final energy = checkIn == null ? '' : ' · ENERGY ${checkIn.energy}/5';

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
                      icon: Icons.add_rounded,
                      label: 'Add task',
                      onTap: () => showTaskEditor(context),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.gutter, 8, Space.gutter, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${dayLabel(now).toUpperCase()} · ${deck.length} TO GO$energy',
                      style: T.label(c.textDim),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: !loaded
                  ? const SizedBox.shrink()
                  : count == 0
                  ? _EmptyDeck(onAdd: () => showTaskEditor(context))
                  : PageView.builder(
                      controller: _pc,
                      itemCount: count,
                      padEnds: false,
                      itemBuilder: (context, i) {
                        final delta = (i - _page).abs().clamp(0.0, 1.0);
                        final Widget card;
                        if (needsCheckIn && i == 0) {
                          card = CheckInCard(onSaved: () => _toast('Thanks. Your day is set to match.'));
                        } else {
                          final t = deck[i - offset];
                          card = TaskCard(
                            key: ValueKey('task-${t.id}'),
                            task: t,
                            block: t.timeBlockId == null ? null : blockById[t.timeBlockId],
                            active: i == pageIndex,
                            now: now,
                            onComplete: () => _complete(t),
                            onSnooze: () => _snooze(t),
                            onEdit: () => showTaskEditor(context, task: t),
                          );
                        }
                        return Padding(
                          padding: EdgeInsets.only(left: i == 0 ? Space.gutter : 6, right: 6, bottom: 4),
                          child: Transform.scale(
                            scale: 1 - 0.06 * delta,
                            alignment: i < _page ? Alignment.centerRight : Alignment.centerLeft,
                            child: Opacity(opacity: 1 - 0.35 * delta, child: card),
                          ),
                        );
                      },
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
                  Expanded(
                    child: onCheckIn
                        ? PrimaryButton(
                            label: deck.isEmpty ? 'Check in above' : 'Skip for now',
                            onTap: deck.isEmpty
                                ? null
                                : () => _pc.animateToPage(
                                    1,
                                    duration: context.motion(Motion.slow),
                                    curve: Motion.curve,
                                  ),
                          )
                        : PrimaryButton(
                            label: 'Start',
                            icon: Icons.play_arrow_rounded,
                            trailing: '${timer.focusMinutes} min',
                            onTap: current == null
                                ? null
                                : () => ref.read(timerProvider.notifier).start(task: current),
                          ),
                  ),
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
                              _stuck(current, deck, offset);
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
        Positioned(
          right: 0,
          top: pad.top + 52,
          child: UpNextRail(blocks: blocks, now: now),
        ),
      ],
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
