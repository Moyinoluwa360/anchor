import 'package:anchor/models/dates.dart';
import 'package:anchor/services/streak_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Mon 16 Nov 2026 … Sun 22 Nov 2026.
  DateTime d(int day) => DateTime(2026, 11, day, 12);
  const svc = StreakService();

  test('no activity → zero, not paused', () {
    final r = svc.compute([], now: d(20));
    expect(r.current, 0);
    expect(r.paused, isFalse);
  });

  test('consecutive days count up; today not done yet is not a miss', () {
    final r = svc.compute([d(16), d(17), d(18), d(19)], now: d(20));
    expect(r.current, 4);
    expect(r.best, 4);
    expect(r.paused, isFalse);
  });

  test('one missed day a week is a free rest day', () {
    final r = svc.compute([d(16), d(17), d(19), d(20)], now: d(20));
    expect(r.current, 4);
    expect(r.paused, isFalse);
    expect(r.restDaysUsed, 1);
  });

  test('a second missed day in the same week pauses, never resets', () {
    final r = svc.compute([d(16), d(19)], now: d(20)); // 17 rest, 18 paused
    expect(r.current, 2);
    expect(r.paused, isFalse, reason: 'activity resumed on the 19th');
    final paused = svc.compute([d(16), d(17)], now: d(20)); // 18 rest, 19 missed
    expect(paused.current, 2);
    expect(paused.paused, isTrue);
  });

  test('a long break quietly starts a new run but keeps the best', () {
    final days = [for (var i = 1; i <= 10; i++) DateTime(2026, 11, i, 9), d(20)];
    final r = svc.compute(days, now: d(20));
    expect(r.best, 10);
    expect(r.current, 1);
  });

  test('rest day can be turned off', () {
    const strict = StreakService(restDayPerWeek: false);
    final r = strict.compute([d(16), d(18)], now: d(19));
    expect(r.current, 2);
    expect(r.paused, isFalse);
    expect(strict.compute([d(16)], now: d(18)).paused, isTrue);
  });

  test('multiple completions on one day count once', () {
    final r = svc.compute([d(19), d(19).add(const Duration(hours: 3)), d(20)], now: d(20));
    expect(r.current, 2);
    expect(dayOf(d(19)), DateTime(2026, 11, 19));
  });
}
