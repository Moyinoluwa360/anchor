import 'dart:math' as math;

import 'package:anchor/data/database.dart';
import 'package:anchor/models/enums.dart';
import 'package:anchor/services/planner_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final day = DateTime(2026, 11, 20);
  DateTime at(int h, [int m = 0]) => day.add(Duration(hours: h, minutes: m));

  Task task(int id, {int mins = 25, Effort effort = Effort.medium, int prio = 2, int? top}) => Task(
    id: id,
    title: 'T$id',
    area: LifeArea.startup,
    estimatedMinutes: mins,
    scheduledDate: day,
    status: TaskStatus.todo,
    effort: effort,
    priority: prio,
    topRank: top,
    sortOrder: 0,
    createdAt: day,
  );

  TimeBlock block(int id, DateTime s, int mins, BlockType type, {int? taskId}) => TimeBlock(
    id: id,
    startAt: s,
    endAt: s.add(Duration(minutes: mins)),
    label: '',
    type: type,
    remind: true,
    taskId: taskId,
  );

  group('dial geometry', () {
    test('full day: midnight up, 6:00 right, noon down, 18:00 left', () {
      const w = DialWindow.fullDay;
      expect(PlannerService.angleOf(at(0), day, w), 0);
      expect(PlannerService.angleOf(at(6), day, w), closeTo(math.pi / 2, 1e-9));
      expect(PlannerService.angleOf(at(12), day, w), closeTo(math.pi, 1e-9));
      expect(PlannerService.angleOf(at(18), day, w), closeTo(3 * math.pi / 2, 1e-9));
    });

    test('angle → time round-trips and snaps to 15 minutes', () {
      const w = DialWindow.fullDay;
      for (final t in [at(9), at(13, 45), at(22, 15)]) {
        expect(PlannerService.timeAt(PlannerService.angleOf(t, day, w), day, w), t);
      }
      final a = PlannerService.angleOf(at(9, 7), day, w);
      expect(PlannerService.timeAt(a, day, w), at(9, 0));
      final b = PlannerService.angleOf(at(9, 8), day, w);
      expect(PlannerService.timeAt(b, day, w), at(9, 15));
    });

    test('focused 6-hour window starts the hour before now', () {
      final w = DialWindow.focused(at(10, 40));
      expect(w.startHour, 9);
      expect(w.spanHours, 6);
      expect(PlannerService.angleOf(at(9), day, w), 0);
      expect(PlannerService.angleOf(at(12), day, w), closeTo(math.pi, 1e-9));
      expect(PlannerService.timeAt(math.pi / 2, day, w), at(10, 30));
      expect(DialWindow.focused(at(23, 30)).startHour, 18, reason: 'never runs past midnight');
    });

    test('offset → angle (0 up, clockwise)', () {
      expect(PlannerService.angleFromOffset(0, -10), 0);
      expect(PlannerService.angleFromOffset(10, 0), closeTo(math.pi / 2, 1e-9));
      expect(PlannerService.angleFromOffset(0, 10), closeTo(math.pi, 1e-9));
      expect(PlannerService.angleFromOffset(-10, 0), closeTo(3 * math.pi / 2, 1e-9));
    });
  });

  group('capacity', () {
    test('counts focus, admin and fixed; never breaks or rest', () {
      final c = PlannerService.capacity([
        block(1, at(9), 90, BlockType.focus),
        block(2, at(10, 30), 15, BlockType.breakTime),
        block(3, at(12), 60, BlockType.fixed),
        block(4, at(16), 30, BlockType.admin),
        block(5, at(23), 420, BlockType.rest),
      ], 8);
      expect(c.plannedMinutes, 180);
      expect(c.level, CapacityLevel.calm);
    });

    test('calm → full → over', () {
      expect(const Capacity(300, 480).level, CapacityLevel.calm);
      expect(const Capacity(400, 480).level, CapacityLevel.full);
      expect(const Capacity(480, 480).level, CapacityLevel.full);
      expect(const Capacity(500, 480).level, CapacityLevel.over);
    });
  });

  group('auto-suggest', () {
    final tasks = [
      task(1, mins: 90, effort: Effort.heavy, prio: 1),
      task(2, mins: 15, effort: Effort.light, prio: 3),
      task(3, mins: 45, effort: Effort.medium, prio: 2),
      task(4, mins: 30, effort: Effort.light, prio: 2),
    ];

    test('high energy puts the hardest, most important task first', () {
      final d = PlannerService.suggest(tasks: tasks, existing: const [], now: at(9), energy: 5);
      expect(d.first.taskId, 1);
      expect(d.first.minutes, 90);
      expect(d.first.start, at(9));
      expect(d[1].type, BlockType.breakTime);
      expect(d[1].minutes, 15);
    });

    test('low energy: easy wins first, short blocks, lighter total', () {
      final d = PlannerService.suggest(tasks: tasks, existing: const [], now: at(9), energy: 1);
      final focus = d.where((b) => b.type == BlockType.focus).toList();
      expect(focus.first.taskId, 2);
      expect(focus.every((b) => b.minutes <= 25), isTrue);
      expect(focus.fold<int>(0, (s, b) => s + b.minutes), lessThanOrEqualTo(180));
    });

    test('every focus block is followed by a break, and the plan never ends on one', () {
      final d = PlannerService.suggest(tasks: tasks, existing: const [], now: at(9), energy: 3);
      for (var i = 0; i < d.length - 1; i++) {
        if (d[i].type == BlockType.focus) expect(d[i + 1].type, BlockType.breakTime);
      }
      expect(d.last.type, BlockType.focus);
    });

    test('starts at the next quarter hour, never in the past or before 08:00', () {
      expect(
        PlannerService.suggest(tasks: tasks, existing: const [], now: at(10, 7)).first.start,
        at(10, 15),
      );
      expect(PlannerService.suggest(tasks: tasks, existing: const [], now: at(6)).first.start, at(8));
    });

    test('flows around fixed commitments and leaves them alone', () {
      final lunch = block(9, at(9, 30), 60, BlockType.fixed);
      final d = PlannerService.suggest(tasks: tasks, existing: [lunch], now: at(9), energy: 3);
      for (final b in d) {
        final overlaps = b.start.isBefore(lunch.endAt) && b.end.isAfter(lunch.startAt);
        expect(overlaps, isFalse, reason: '$b overlaps lunch');
      }
    });

    test('stops at the end of the day and at the healthy limit', () {
      final many = [for (var i = 1; i <= 20; i++) task(i, mins: 60)];
      final late = PlannerService.suggest(tasks: many, existing: const [], now: at(19), energy: 4);
      expect(late.every((b) => !b.end.isAfter(at(21))), isTrue);
      final capped = PlannerService.suggest(
        tasks: many,
        existing: const [],
        now: at(8),
        energy: 5,
        healthyHours: 3,
      );
      final focus = capped.where((b) => b.type == BlockType.focus).fold<int>(0, (s, b) => s + b.minutes);
      expect(focus, lessThanOrEqualTo(180));
    });

    test('tasks already in a kept block are not planned twice', () {
      final kept = block(1, at(8), 60, BlockType.focus, taskId: 1); // already started → locked
      final d = PlannerService.suggest(tasks: tasks, existing: [kept], now: at(8, 30), energy: 5);
      expect(d.any((b) => b.taskId == 1), isFalse);
    });

    test('nothing to plan → empty', () {
      expect(PlannerService.suggest(tasks: const [], existing: const [], now: at(9)), isEmpty);
    });
  });
}
