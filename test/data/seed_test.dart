import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:anchor/data/seed.dart';
import 'package:anchor/models/dates.dart';
import 'package:anchor/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  final now = DateTime(2026, 11, 20, 10); // a Friday

  test('seeds the four goals from the spec, with milestones and targets', () async {
    final db = memoryDb();
    final s = Seeder(db, now: now);
    expect(await s.isEmpty(), isTrue);
    await s.seed();
    expect(await s.isEmpty(), isFalse);

    final goals = await db.select(db.goals).get();
    expect(goals.map((g) => g.title), [
      'Grow the startup to 1,000 daily users',
      'Learn cloud engineering',
      'Earn short-term income from clipping gigs',
      'Ship the AI outfit search system',
    ]);
    expect(await db.milestones.count().getSingle(), 15);
    final targets = await db.select(db.weeklyTargets).get();
    expect(targets, hasLength(4));
    expect(targets.every((t) => t.weekStart == weekStartOf(now)), isTrue);
    await db.close();
  });

  test('today has open tasks with tiny first steps and blocks', () async {
    final db = memoryDb();
    await Seeder(db, now: now).seed();
    final open = await (db.select(db.tasks)
          ..where((t) => t.scheduledDate.equals(today(now)) & t.status.equals(TaskStatus.todo.name)))
        .get();
    expect(open.length, greaterThanOrEqualTo(6));
    expect(open.where((t) => t.firstStep != null).length, greaterThanOrEqualTo(6));
    expect(await db.timeBlocks.count().getSingle(), greaterThanOrEqualTo(8));
    await db.close();
  });

  test('history fills months of completions, sessions and check-ins (none today)', () async {
    final db = memoryDb();
    await Seeder(db, now: now).seed();
    final done = await (db.select(db.tasks)..where((t) => t.status.equals(TaskStatus.done.name))).get();
    final days = done.map((t) => dayOf(t.completedAt!)).toSet();
    expect(days.length, greaterThan(100));
    expect(days.contains(today(now)), isFalse);
    final checkins = await db.select(db.energyCheckIns).get();
    expect(checkins, isNotEmpty);
    expect(checkins.any((c) => c.date == today(now)), isFalse, reason: 'check-in card must show');
    // The last few days are not a low-energy run (no support message on first launch).
    final recent = checkins.where((c) => c.date.isAfter(addDays(today(now), -5)));
    expect(recent.every((c) => c.energy >= 3 && c.mood >= 3), isTrue);
    await db.close();
  });

  test('seeding is deterministic', () async {
    final a = memoryDb(), b = memoryDb();
    await Seeder(a, now: now).seed();
    await Seeder(b, now: now).seed();
    expect(await a.tasks.count().getSingle(), await b.tasks.count().getSingle());
    await a.close();
    await b.close();
  });
}
