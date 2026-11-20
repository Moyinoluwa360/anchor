import 'package:anchor/data/database.dart';
import 'package:anchor/models/enums.dart';
import 'package:anchor/services/deck_order.dart';
import 'package:anchor/services/energy_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 20, 9);
  EnergyCheckIn ci(int daysAgo, int energy, int mood) =>
      EnergyCheckIn(id: daysAgo, date: DateTime(2026, 11, 20 - daysAgo), energy: energy, mood: mood);

  group('advice by energy', () {
    test('low: lighter deck of 3, 25/5 rhythm', () {
      final a = EnergyAdvice.of(2);
      expect(a.isLow, isTrue);
      expect(a.deckLimit, 3);
      expect(a.preset.focus, 25);
    });
    test('high: no limit, longer rhythm, hardest first', () {
      final a = EnergyAdvice.of(5);
      expect(a.isHigh, isTrue);
      expect(a.deckLimit, isNull);
      expect(a.preset.focus, 50);
      expect(a.hint, contains('Hardest'));
    });
    test('no check-in: no change, no copy', () {
      final a = EnergyAdvice.of(null);
      expect(a.deckLimit, isNull);
      expect(a.headline, isEmpty);
    });
  });

  group('several low days in a row', () {
    test('three low days ending today → show support', () {
      expect(EnergyService.lowStretch([ci(2, 2, 3), ci(1, 3, 1), ci(0, 1, 1)], now), isTrue);
    });
    test('three low days ending yesterday (not checked in yet today) → show', () {
      expect(EnergyService.lowStretch([ci(3, 1, 2), ci(2, 2, 2), ci(1, 2, 4)], now), isTrue);
    });
    test('a good day in between → no', () {
      expect(EnergyService.lowStretch([ci(2, 2, 2), ci(1, 4, 4), ci(0, 1, 1)], now), isFalse);
    });
    test('a missing day breaks the run (not consecutive)', () {
      expect(EnergyService.lowStretch([ci(3, 1, 1), ci(1, 1, 1), ci(0, 1, 1)], now), isFalse);
    });
    test('only two days → no', () {
      expect(EnergyService.lowStretch([ci(1, 1, 1), ci(0, 1, 1)], now), isFalse);
    });
    test('energy and mood both 3+ is fine', () {
      expect(EnergyService.lowStretch([ci(2, 3, 3), ci(1, 3, 3), ci(0, 3, 3)], now), isFalse);
    });
  });

  group('deck adapts to energy', () {
    final day = DateTime(2026, 11, 20);
    Task task(int id, {Effort effort = Effort.medium, int mins = 25, int prio = 2}) => Task(
      id: id,
      title: 'T$id',
      area: LifeArea.startup,
      estimatedMinutes: mins,
      scheduledDate: day,
      status: TaskStatus.todo,
      effort: effort,
      priority: prio,
      sortOrder: 0,
      createdAt: day,
    );
    final tasks = [
      task(1, effort: Effort.heavy, mins: 90, prio: 2),
      task(2, effort: Effort.light, mins: 15, prio: 2),
      task(3, effort: Effort.medium, mins: 30, prio: 2),
    ];

    test('low energy: easy wins first', () {
      expect(orderDeck(tasks, const [], now, energy: 1).map((t) => t.id), [2, 3, 1]);
    });
    test('high energy: heaviest first among equally important', () {
      expect(orderDeck(tasks, const [], now, energy: 5).map((t) => t.id), [1, 3, 2]);
    });
    test('importance still wins on a high day', () {
      final t = [...tasks, task(4, effort: Effort.light, prio: 1)];
      expect(orderDeck(t, const [], now, energy: 5).first.id, 4);
    });
  });
}
