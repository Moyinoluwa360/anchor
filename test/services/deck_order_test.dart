import 'package:exe/data/database.dart';
import 'package:exe/models/enums.dart';
import 'package:exe/services/deck_order.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 20, 10, 30);
  final day = DateTime(2026, 11, 20);

  Task task(
    int id, {
    int prio = 2,
    int? block,
    int? top,
    TaskStatus status = TaskStatus.todo,
    DateTime? snoozed,
    Effort effort = Effort.medium,
    int mins = 25,
  }) => Task(
    id: id,
    title: 'T$id',
    area: LifeArea.startup,
    estimatedMinutes: mins,
    scheduledDate: day,
    timeBlockId: block,
    status: status,
    effort: effort,
    priority: prio,
    snoozedUntil: snoozed,
    topRank: top,
    sortOrder: 0,
    createdAt: day,
  );

  TimeBlock block(int id, int h, int m, int mins) => TimeBlock(
    id: id,
    startAt: day.add(Duration(hours: h, minutes: m)),
    endAt: day.add(Duration(hours: h, minutes: m + mins)),
    label: '',
    type: BlockType.focus,
    remind: true,
  );

  test('the task in the block happening now comes first', () {
    final blocks = [block(1, 10, 0, 60), block(2, 14, 0, 60)];
    final out = orderDeck(
      [task(1, prio: 1), task(2, top: 1), task(3, block: 2), task(4, block: 1)],
      blocks,
      now,
    );
    expect(out.map((t) => t.id), [4, 2, 3, 1]);
  });

  test('top 3 in rank order, then later blocks by start, then priority', () {
    final blocks = [block(1, 15, 0, 30), block(2, 12, 0, 30)];
    final out = orderDeck(
      [
        task(1, prio: 3),
        task(2, top: 2),
        task(3, top: 1),
        task(4, block: 1),
        task(5, block: 2),
        task(6, prio: 1),
      ],
      blocks,
      now,
    );
    expect(out.map((t) => t.id), [3, 2, 5, 4, 6, 1]);
  });

  test('snoozed tasks wait at the back until their time', () {
    final later = now.add(const Duration(hours: 1));
    final out = orderDeck([task(1, status: TaskStatus.snoozed, snoozed: later), task(2)], const [], now);
    expect(out.map((t) => t.id), [2, 1]);
    final woken = orderDeck(
      [
        task(1, status: TaskStatus.snoozed, snoozed: now.subtract(const Duration(minutes: 1)), prio: 1),
        task(2),
      ],
      const [],
      now,
    );
    expect(woken.first.id, 1);
  });

  test('snooze is one hour, or tomorrow 9:00 when late', () {
    expect(snoozeUntil(now), now.add(const Duration(hours: 1)));
    expect(snoozeUntil(DateTime(2026, 11, 20, 20, 30)), DateTime(2026, 11, 21, 9));
    expect(snoozeUntil(DateTime(2026, 11, 20, 23, 30)), DateTime(2026, 11, 21, 9));
  });

  test('easier options are lighter or shorter, lightest first, max 3', () {
    final cur = task(1, effort: Effort.heavy, mins: 60);
    final out = easierThan(cur, [
      cur,
      task(2, effort: Effort.light, mins: 30),
      task(3, effort: Effort.light, mins: 10),
      task(4, effort: Effort.medium, mins: 25),
      task(5, effort: Effort.heavy, mins: 90),
      task(6, effort: Effort.light, mins: 15),
    ]);
    expect(out.map((t) => t.id), [3, 6, 2]);
  });
}
