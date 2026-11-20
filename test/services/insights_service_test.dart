import 'package:anchor/data/database.dart';
import 'package:anchor/models/enums.dart';
import 'package:anchor/services/insights_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 22, 18); // Sunday
  DateTime d(int daysAgo, [int h = 10]) => DateTime(2026, 11, 22 - daysAgo, h);
  var nextId = 1;
  Task done(int daysAgo, LifeArea a, {int? goal}) => Task(
    id: nextId++,
    title: 't',
    area: a,
    goalId: goal,
    estimatedMinutes: 25,
    status: TaskStatus.done,
    effort: Effort.medium,
    priority: 2,
    completedAt: d(daysAgo),
    sortOrder: 0,
    createdAt: d(daysAgo),
  );

  test('daily counts and heat levels', () {
    final counts = InsightsService.dailyCounts([
      done(0, LifeArea.startup),
      done(0, LifeArea.cloud),
      done(3, LifeArea.health),
    ]);
    expect(counts[DateTime(2026, 11, 22)], 2);
    expect(counts[DateTime(2026, 11, 19)], 1);
    expect([0, 1, 2, 3, 4, 5, 6, 7, 20].map(InsightsService.heatLevel), [0, 1, 1, 2, 2, 3, 3, 4, 4]);
  });

  group('streaks by life area', () {
    final tasks = [
      for (var i = 0; i < 20; i++) done(i, LifeArea.startup),
      for (var i = 0; i < 30; i += 3) done(i, LifeArea.cloud),
      done(25, LifeArea.personal),
    ];
    final stats = InsightsService.areaStats(tasks, now);

    test('each area gets its own streak and 30-day attention', () {
      final s = stats.firstWhere((x) => x.area == LifeArea.startup);
      expect(s.streak.current, 20);
      expect(s.last30, 20);
      expect(s.attention, hasLength(30));
      expect(s.attention.last, isTrue);
      expect(stats.firstWhere((x) => x.area == LifeArea.cloud).last30, 10);
      expect(stats.firstWhere((x) => x.area == LifeArea.health).last30, 0);
    });

    test('strongest is "on fire", the clearly behind one "needs attention"', () {
      expect(InsightsService.strongest(stats)!.area, LifeArea.startup);
      final n = InsightsService.neglected(stats)!;
      expect(n.last30, 0);
      expect(n.area, isNot(LifeArea.startup));
    });

    test('no flag when every area is roughly balanced', () {
      final even = [
        for (var i = 0; i < 10; i++)
          for (final a in LifeArea.values) done(i, a),
      ];
      expect(InsightsService.neglected(InsightsService.areaStats(even, now)), isNull);
    });

    test('nothing done at all → nothing to celebrate or flag', () {
      final empty = InsightsService.areaStats(const [], now);
      expect(InsightsService.strongest(empty), isNull);
    });
  });

  test('done stack groups by day, week and month with totals', () {
    final tasks = [
      done(0, LifeArea.startup, goal: 1),
      done(0, LifeArea.cloud, goal: 2),
      done(1, LifeArea.startup, goal: 1),
      done(9, LifeArea.health),
    ];
    final sessions = [
      FocusSession(
        id: 1,
        plannedMinutes: 50,
        breakMinutes: 10,
        actualSeconds: 3000,
        startAt: d(0, 9),
        completed: true,
      ),
      FocusSession(
        id: 2,
        plannedMinutes: 25,
        breakMinutes: 5,
        actualSeconds: 1500,
        startAt: d(1, 9),
        completed: true,
      ),
    ];
    final days = InsightsService.groups(tasks, sessions, Period.day, now);
    expect(days.first.start, DateTime(2026, 11, 22));
    expect(days.first.tasks, hasLength(2));
    expect(days.first.goalsAdvanced, 2);
    expect(days.first.focusHours, closeTo(3000 / 3600, 1e-9));
    final weeks = InsightsService.groups(tasks, sessions, Period.week, now);
    expect(weeks.first.tasks, hasLength(3));
    expect(weeks.first.focusHours, closeTo(4500 / 3600, 1e-9));
    expect(weeks, hasLength(2));
    final months = InsightsService.groups(tasks, sessions, Period.month, now);
    expect(months.single.tasks, hasLength(4));
  });

  test('Sunday summary names the most consistent and most neglected area', () {
    final tasks = [
      for (var i = 0; i < 6; i++) done(i, LifeArea.startup),
      done(1, LifeArea.cloud),
      done(2, LifeArea.cloud),
      done(3, LifeArea.sideGigs),
    ];
    final s = InsightsService.sunday(tasks, now)!;
    expect(s.consistent, LifeArea.startup);
    expect([LifeArea.health, LifeArea.personal], contains(s.neglected));
    expect(s.suggestion, contains('20-minute'));
    expect(InsightsService.sunday(const [], now), isNull);
  });

  test('trend series: weekly focus and daily energy, oldest first', () {
    final sessions = [
      FocusSession(
        id: 1,
        plannedMinutes: 60,
        breakMinutes: 10,
        actualSeconds: 7200,
        startAt: d(0),
        completed: true,
      ),
      FocusSession(
        id: 2,
        plannedMinutes: 60,
        breakMinutes: 10,
        actualSeconds: 3600,
        startAt: d(8),
        completed: true,
      ),
    ];
    final wf = InsightsService.weeklyFocus(sessions, now, weeks: 3);
    expect(wf, [0, 1, 2]);
    final es = InsightsService.energySeries(
      [
        EnergyCheckIn(id: 1, date: DateTime(2026, 11, 22), energy: 4, mood: 3),
        EnergyCheckIn(id: 2, date: DateTime(2026, 11, 20), energy: 2, mood: 3),
      ],
      now,
      days: 3,
    );
    expect(es, [2, null, 4]);
  });

  test('energy smoothing averages up to 3 recent check-ins and keeps gaps', () {
    expect(InsightsService.smooth([2, 4, null, 3]), [2.0, 3.0, null, 3.5]);
    expect(InsightsService.smooth([1, 2, 3, 5]), [1.0, 1.5, 2.0, closeTo(10 / 3, 1e-9)]);
  });
}
