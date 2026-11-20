import 'dart:convert';

import 'package:anchor/data/database.dart';
import 'package:anchor/models/enums.dart';
import 'package:anchor/services/timer_logic.dart';
import 'package:anchor/services/widget_sync.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final day = DateTime(2026, 11, 20);
  Task task(int id, {int? top, String? step, TaskStatus status = TaskStatus.todo, int? target}) => Task(
    id: id,
    title: 'Task $id',
    area: LifeArea.cloud,
    estimatedMinutes: 45,
    firstStep: step,
    scheduledDate: day,
    status: status,
    effort: Effort.medium,
    priority: 2,
    topRank: top,
    weeklyTargetId: target,
    sortOrder: 0,
    createdAt: day,
  );

  test('widget snapshot: now card, top 3 (or first 3), target percentages', () {
    final deck = [task(1, step: 'Open the course'), task(2, top: 2), task(3, top: 1), task(4)];
    final targets = [WeeklyTarget(id: 9, weekStart: day, title: 'Ship it', done: false, sortOrder: 0)];
    final all = [...deck, task(5, target: 9, status: TaskStatus.done), task(6, target: 9)];
    final s = WidgetSnapshot.build(deck: deck, targets: targets, allTasks: all);
    expect(s.nowTitle, 'Task 1');
    expect(s.nowStep, 'Open the course');
    expect(s.nowMeta, 'CLOUD · 45m');
    expect(s.top3, ['Task 3', 'Task 2']);
    expect(s.targets.single.percent, 50);
    final store = s.toStore();
    expect(jsonDecode(store['targets']!), [
      {'t': 'Ship it', 'p': 50},
    ]);

    final noTops = WidgetSnapshot.build(
      deck: [task(1), task(4), task(7), task(8)],
      targets: const [],
      allTasks: const [],
    );
    expect(noTops.top3, ['Task 1', 'Task 4', 'Task 7']);
    final empty = WidgetSnapshot.build(deck: const [], targets: const [], allTasks: const []);
    expect(empty.nowTitle, 'Clear deck');
  });

  test('live activity payload: running and paused', () {
    final t0 = DateTime(2026, 11, 20, 9);
    final s = TimerLogic.startFocus(const TimerPreset(25, 5), t0);
    final p = LiveActivityTimer.payload(s, 'Write email', t0.add(const Duration(minutes: 5)));
    expect(p['phase'], 'FOCUS');
    expect(p['title'], 'Write email');
    expect(p['endEpoch'], t0.add(const Duration(minutes: 25)).millisecondsSinceEpoch / 1000);
    expect(p['startEpoch'], t0.millisecondsSinceEpoch / 1000);
    expect(p['paused'], false);
    final paused = TimerLogic.pause(s, t0.add(const Duration(minutes: 10)));
    final pp = LiveActivityTimer.payload(paused, null, t0.add(const Duration(minutes: 30)));
    expect(pp['paused'], true);
    expect(pp['remaining'], 15 * 60);
    expect(pp['title'], 'Focus');
  });

  test('widgets are off unless the build asks for them', () {
    expect(widgetsEnabled, isFalse);
    expect(WidgetKinds.all, ['AnchorNow', 'AnchorTop3', 'AnchorTargets']);
  });
}
