import 'package:exe/data/database.dart';
import 'package:exe/models/enums.dart';
import 'package:exe/providers/settings.dart';
import 'package:exe/services/notification_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 20, 10, 0); // Friday
  final day = DateTime(2026, 11, 20);
  const planner = NotificationPlanner();
  const quiet = Settings(); // quiet 22:30–07:00, nudges on

  TimeBlock block(
    int id,
    DateTime start, {
    BlockType type = BlockType.focus,
    bool remind = true,
    int? task,
  }) => TimeBlock(
    id: id,
    startAt: start,
    endAt: start.add(const Duration(minutes: 30)),
    label: 'B$id',
    type: type,
    remind: remind,
    taskId: task,
  );

  Reminder reminder(int id, DateTime at, RepeatRule r, {bool enabled = true}) =>
      Reminder(id: id, title: 'R$id', at: at, repeat: r, enabled: enabled);

  List<PlannedNotification> plan({
    Settings s = quiet,
    List<TimeBlock> blocks = const [],
    List<Reminder> reminders = const [],
    Map<int, String> titles = const {},
  }) => planner.plan(settings: s, blocks: blocks, reminders: reminders, taskTitles: titles, now: now);

  group('quiet hours', () {
    const q = QuietHours(22 * 60 + 30, 7 * 60);
    test('window wraps past midnight', () {
      expect(q.containsMinute(23 * 60), isTrue);
      expect(q.containsMinute(3 * 60), isTrue);
      expect(q.containsMinute(7 * 60), isFalse);
      expect(q.containsMinute(12 * 60), isFalse);
    });
    test('a time inside is moved to the end of the window', () {
      expect(q.shift(DateTime(2026, 11, 20, 23, 15)), DateTime(2026, 11, 21, 7));
      expect(q.shift(DateTime(2026, 11, 21, 2, 0)), DateTime(2026, 11, 21, 7));
      expect(q.shift(DateTime(2026, 11, 21, 9, 0)), DateTime(2026, 11, 21, 9));
    });
    test('off means nothing is quiet', () {
      const off = QuietHours(22 * 60, 7 * 60, on: false);
      expect(off.containsMinute(23 * 60), isFalse);
    });
  });

  test('morning, evening and Sunday review repeat; respect toggles', () {
    final p = plan();
    final byId = {for (final n in p) n.id: n};
    expect(byId[NotificationIds.morning]!.repeat, Repeat.daily);
    expect(byId[NotificationIds.morning]!.at, DateTime(2026, 11, 20, 8));
    expect(byId[NotificationIds.evening]!.at, DateTime(2026, 11, 20, 21));
    final sun = byId[NotificationIds.sunday]!;
    expect(sun.repeat, Repeat.weekly);
    expect(sun.at.weekday, DateTime.sunday);
    expect(sun.at.hour, 18);

    final off = plan(s: quiet.copyWith(morningNudge: false, eveningWrap: false, sundayReview: false));
    expect(off, isEmpty);
  });

  test('a nudge set inside quiet hours moves to the end of quiet hours', () {
    final p = plan(s: quiet.copyWith(eveningTime: 23 * 60));
    final ev = p.firstWhere((n) => n.id == NotificationIds.evening);
    expect(ev.at.hour, 7);
  });

  test('blocks alert 5 minutes before, using the task title', () {
    final p = plan(
      blocks: [block(3, day.add(const Duration(hours: 14)), task: 9)],
      titles: {9: 'Edit 2 clips'},
    );
    final b = p.firstWhere((n) => n.id == NotificationIds.blockBase + 3);
    expect(b.at, DateTime(2026, 11, 20, 13, 55));
    expect(b.body, 'Edit 2 clips');
    expect(b.payload, 'block:3');
  });

  test('no alerts for past, rest, muted, quiet-hours or far-off blocks', () {
    final p = plan(
      blocks: [
        block(1, day.add(const Duration(hours: 9))), // past
        block(2, day.add(const Duration(hours: 15)), type: BlockType.rest),
        block(3, day.add(const Duration(hours: 16)), remind: false),
        block(4, day.add(const Duration(hours: 23, minutes: 30))), // quiet
        block(5, day.add(const Duration(days: 3, hours: 10))), // > 36 h
        block(6, now.add(const Duration(minutes: 3))), // alert time already passed
      ],
    );
    expect(p.where((n) => n.id >= NotificationIds.blockBase && n.id < NotificationIds.reminderBase), isEmpty);
  });

  test('block alerts can be switched off', () {
    final p = plan(
      s: quiet.copyWith(blockAlerts: false),
      blocks: [block(1, day.add(const Duration(hours: 15)))],
    );
    expect(p.any((n) => n.id == NotificationIds.blockBase + 1), isFalse);
  });

  group('reminder repeat rules', () {
    test('once: in the future only, quiet hours push it to the morning', () {
      final p = plan(
        reminders: [
          reminder(1, DateTime(2026, 11, 20, 17), RepeatRule.none),
          reminder(2, DateTime(2026, 11, 19, 17), RepeatRule.none), // past
          reminder(3, DateTime(2026, 11, 20, 23, 30), RepeatRule.none), // quiet
          reminder(4, DateTime(2026, 11, 20, 18), RepeatRule.none, enabled: false),
        ],
      );
      final ids = p.map((n) => n.id).toSet();
      expect(ids.contains(NotificationIds.reminderBase + 10), isTrue);
      expect(ids.contains(NotificationIds.reminderBase + 20), isFalse);
      expect(ids.contains(NotificationIds.reminderBase + 40), isFalse);
      final q = p.firstWhere((n) => n.id == NotificationIds.reminderBase + 30);
      expect(q.at, DateTime(2026, 11, 21, 7));
    });

    test('daily repeats at the time of day', () {
      final p = plan(reminders: [reminder(1, DateTime(2026, 1, 1, 12, 15), RepeatRule.daily)]);
      final r = p.firstWhere((n) => n.payload == 'reminder:1');
      expect(r.repeat, Repeat.daily);
      expect((r.at.hour, r.at.minute), (12, 15));
    });

    test('weekdays expands to Monday–Friday weekly slots', () {
      final p = plan(reminders: [reminder(2, DateTime(2026, 1, 1, 9, 0), RepeatRule.weekdays)]);
      final r = p.where((n) => n.payload == 'reminder:2').toList();
      expect(r, hasLength(5));
      expect(r.map((n) => n.at.weekday).toSet(), {1, 2, 3, 4, 5});
      expect(r.every((n) => n.repeat == Repeat.weekly), isTrue);
      expect(r.map((n) => n.id).toSet(), hasLength(5));
    });

    test('weekly keeps its weekday', () {
      final p = plan(reminders: [reminder(3, DateTime(2026, 11, 24, 17), RepeatRule.weekly)]); // a Tuesday
      final r = p.firstWhere((n) => n.payload == 'reminder:3');
      expect(r.at.weekday, DateTime.tuesday);
      expect(r.repeat, Repeat.weekly);
    });
  });

  test('never more than the iOS limit; ids are unique', () {
    final blocks = [for (var i = 1; i <= 100; i++) block(i, now.add(Duration(minutes: 10 + i * 10)))];
    final p = plan(blocks: blocks);
    expect(p.length, lessThanOrEqualTo(60));
    expect(p.map((n) => n.id).toSet().length, p.length);
    expect(p.any((n) => n.id == NotificationIds.morning), isTrue, reason: 'repeating nudges kept first');
  });
}
