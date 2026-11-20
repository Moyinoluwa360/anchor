import 'package:anchor/data/database.dart';
import 'package:anchor/models/enums.dart';
import 'package:anchor/services/progress_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 20, 10); // Friday
  final ws = DateTime(2026, 11, 16); // Monday

  Goal goal(int id, {GoalStatus status = GoalStatus.active}) =>
      Goal(id: id, title: 'G$id', area: LifeArea.startup, why: '', status: status, createdAt: ws);
  Milestone ms(int id, int goalId, {bool done = false, DateTime? due}) =>
      Milestone(id: id, goalId: goalId, title: 'M$id', done: done, dueDate: due);
  Task task(int id, {int? goal, int? target, bool done = false, DateTime? day, DateTime? doneAt}) => Task(
    id: id,
    title: 'T$id',
    area: LifeArea.startup,
    goalId: goal,
    weeklyTargetId: target,
    estimatedMinutes: 25,
    scheduledDate: day ?? ws,
    status: done ? TaskStatus.done : TaskStatus.todo,
    effort: Effort.medium,
    priority: 2,
    completedAt: doneAt ?? (done ? ws : null),
    sortOrder: 0,
    createdAt: ws,
  );

  group('goal progress', () {
    test('milestones 60 %, tasks 40 %', () {
      final p = ProgressService.goal(
        goal(1),
        [ms(1, 1, done: true), ms(2, 1)],
        [task(1, goal: 1, done: true), task(2, goal: 1), task(3, goal: 1), task(4, goal: 1)],
      );
      expect(p, closeTo(0.5 * 0.6 + 0.25 * 0.4, 1e-9));
    });
    test('only milestones or only tasks carry full weight; nothing linked is 0', () {
      expect(ProgressService.goal(goal(1), [ms(1, 1, done: true), ms(2, 1)], const []), 0.5);
      expect(ProgressService.goal(goal(1), const [], [task(1, goal: 1, done: true)]), 1);
      expect(ProgressService.goal(goal(1), const [], const []), 0);
    });
    test('ignores other goals; achieved is 100 %', () {
      expect(ProgressService.goal(goal(1), [ms(1, 2, done: true)], const []), 0);
      expect(ProgressService.goal(goal(1, status: GoalStatus.achieved), const [], const []), 1);
    });
  });

  group('weekly target progress', () {
    final w = WeeklyTarget(id: 5, weekStart: ws, title: 'W', done: false, sortOrder: 0);
    test('share of linked tasks done', () {
      expect(ProgressService.target(w, [task(1, target: 5, done: true), task(2, target: 5), task(3)]), 0.5);
    });
    test('done flag is 100 %; nothing linked is 0', () {
      expect(ProgressService.target(w.copyWith(done: true), const []), 1);
      expect(ProgressService.target(w, const []), 0);
    });
  });

  test('week load sums working blocks per day, skipping breaks and rest', () {
    TimeBlock b(int day, int mins, BlockType t) => TimeBlock(
      id: day * 10 + mins,
      startAt: ws.add(Duration(days: day, hours: 9)),
      endAt: ws.add(Duration(days: day, hours: 9, minutes: mins)),
      label: '',
      type: t,
      remind: true,
    );
    final load = ProgressService.weekLoad([
      b(0, 90, BlockType.focus),
      b(0, 15, BlockType.breakTime),
      b(2, 60, BlockType.fixed),
      b(6, 30, BlockType.admin),
      b(4, 400, BlockType.rest),
    ], ws);
    expect(load, [90, 0, 60, 0, 0, 0, 30]);
  });

  test('done by day and focus hours this week', () {
    final done = [
      task(1, done: true, doneAt: ws.add(const Duration(hours: 10))),
      task(2, done: true, doneAt: ws.add(const Duration(days: 4, hours: 9))),
      task(3, done: true, doneAt: ws.subtract(const Duration(days: 1))),
    ];
    expect(ProgressService.doneByDay(done, ws), [1, 0, 0, 0, 1, 0, 0]);
    FocusSession s(int day, int secs) => FocusSession(
      id: day,
      plannedMinutes: 25,
      breakMinutes: 5,
      actualSeconds: secs,
      startAt: ws.add(Duration(days: day)),
      completed: true,
    );
    expect(
      ProgressService.focusHours([s(0, 3600), s(3, 1800), s(8, 3600)], ws, ws.add(const Duration(days: 7))),
      1.5,
    );
  });

  test('next milestone is the soonest open one from today', () {
    final list = [
      ms(1, 1, due: now.subtract(const Duration(days: 3))), // past, still open
      ms(2, 1, due: now.add(const Duration(days: 20))),
      ms(3, 1, due: now.add(const Duration(days: 5))),
      ms(4, 1, due: now.add(const Duration(days: 1)), done: true),
    ];
    expect(ProgressService.nextMilestone(list, now)!.id, 3);
    expect(ProgressService.nextMilestone([ms(9, 1)], now)!.id, 9);
    expect(ProgressService.nextMilestone(const [], now), isNull);
  });

  test('carry-over: unfinished tasks scheduled this week or earlier', () {
    final all = [
      task(1, day: ws.add(const Duration(days: 2))),
      task(2, day: ws.add(const Duration(days: 2)), done: true),
      task(3, day: ws.add(const Duration(days: 9))),
      task(4, day: ws.subtract(const Duration(days: 3))),
    ];
    expect(ProgressService.carryOver(all, ws).map((t) => t.id), [1, 4]);
  });

  test('suggested targets: one per active goal from its next milestone', () {
    final s = ProgressService.suggestTargets(
      [goal(1), goal(2, status: GoalStatus.paused), goal(3)],
      [ms(1, 1, due: now.add(const Duration(days: 4)))],
      now,
    );
    expect(s.map((e) => e.$1.id), [1, 3]);
    expect(s.first.$2, contains('M1'));
  });
}
