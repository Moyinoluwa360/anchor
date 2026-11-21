import 'package:exe/services/timer_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime(2026, 11, 20, 9, 0);
  Duration m(int x) => Duration(minutes: x);

  group('start and countdown', () {
    test('starts a focus phase that ends after the preset', () {
      final s = TimerLogic.startFocus(const TimerPreset(25, 5), t0, taskId: 7);
      expect(s.phase, TimerPhase.focus);
      expect(s.taskId, 7);
      expect(s.endsAt, t0.add(m(25)));
      expect(s.remaining(t0.add(m(10))), m(15));
      expect(s.fraction(t0), 1.0);
      expect(s.fraction(t0.add(m(5))), closeTo(0.8, 1e-9));
      expect(s.isOver(t0.add(m(24))), isFalse);
      expect(s.isOver(t0.add(m(25))), isTrue);
    });

    test('remaining never goes negative', () {
      final s = TimerLogic.startFocus(const TimerPreset(25, 5), t0);
      expect(s.remaining(t0.add(m(90))), Duration.zero);
      expect(s.fraction(t0.add(m(90))), 0);
    });

    test('presets are 25/5, 50/10, 90/20', () {
      expect(timerPresets.map((p) => p.label), ['25/5', '50/10', '90/20']);
    });
  });

  group('pause, resume, extend', () {
    test('pausing freezes the remaining time', () {
      var s = TimerLogic.startFocus(const TimerPreset(25, 5), t0);
      s = TimerLogic.pause(s, t0.add(m(10)));
      expect(s.isPaused, isTrue);
      expect(s.remaining(t0.add(m(60))), m(15));
      expect(s.isOver(t0.add(m(60))), isFalse);
      s = TimerLogic.resume(s, t0.add(m(60)));
      expect(s.isRunning, isTrue);
      expect(s.endsAt, t0.add(m(75)));
    });

    test('extend adds time to the end and to the ring total', () {
      var s = TimerLogic.startFocus(const TimerPreset(25, 5), t0);
      s = TimerLogic.extend(s, m(5), t0.add(m(20)));
      expect(s.endsAt, t0.add(m(30)));
      expect(s.total, m(30));
      final p = TimerLogic.extend(TimerLogic.pause(s, t0.add(m(20))), m(5), t0.add(m(21)));
      expect(p.remaining(t0.add(m(99))), m(15));
    });

    test('pause/resume on idle is a no-op', () {
      expect(TimerLogic.pause(FocusTimerState.idle, t0).isIdle, isTrue);
      expect(TimerLogic.resume(FocusTimerState.idle, t0).isIdle, isTrue);
    });
  });

  group('hard stop: focus → break → idle', () {
    test('focus end starts the break at exactly the focus end time', () {
      final s = TimerLogic.startFocus(const TimerPreset(25, 5), t0);
      final (next, ended) = TimerLogic.advance(s, t0.add(m(26)));
      expect(ended, [TimerPhase.focus]);
      expect(next.phase, TimerPhase.breakTime);
      expect(next.endsAt, t0.add(m(30)));
      expect(next.event, TimerEvent.focusDone);
      expect(next.remaining(t0.add(m(26))), m(4));
    });

    test('app asleep through focus and break lands idle with both ended', () {
      final s = TimerLogic.startFocus(const TimerPreset(50, 10), t0);
      final (next, ended) = TimerLogic.advance(s, t0.add(m(120)));
      expect(ended, [TimerPhase.focus, TimerPhase.breakTime]);
      expect(next.isIdle, isTrue);
      expect(next.event, TimerEvent.breakDone);
      expect(next.focusMinutes, 50, reason: 'keeps the chosen rhythm');
    });

    test('starter step (5/0) has no break', () {
      final s = TimerLogic.startFocus(starterPreset, t0, taskId: 3);
      final (next, ended) = TimerLogic.advance(s, t0.add(m(5)));
      expect(ended, [TimerPhase.focus]);
      expect(next.isIdle, isTrue);
      expect(next.event, TimerEvent.focusDone);
    });

    test('nothing happens before the end', () {
      final s = TimerLogic.startFocus(const TimerPreset(25, 5), t0);
      final (next, ended) = TimerLogic.advance(s, t0.add(m(10)));
      expect(ended, isEmpty);
      expect(next, same(s));
    });

    test('a paused timer never ends', () {
      final s = TimerLogic.pause(TimerLogic.startFocus(const TimerPreset(25, 5), t0), t0.add(m(1)));
      expect(TimerLogic.advance(s, t0.add(m(500))).$2, isEmpty);
    });

    test('reset break on its own ends idle', () {
      final s = TimerLogic.startBreakOnly(5, t0);
      expect(s.phase, TimerPhase.breakTime);
      final (next, ended) = TimerLogic.advance(s, t0.add(m(6)));
      expect(ended, [TimerPhase.breakTime]);
      expect(next.isIdle, isTrue);
    });
  });

  test('focus seconds counts only time actually spent', () {
    final s = TimerLogic.startFocus(const TimerPreset(25, 5), t0);
    expect(TimerLogic.focusSeconds(s, t0.add(m(10))), 600);
    expect(TimerLogic.focusSeconds(s, t0.add(m(40))), 1500);
    expect(TimerLogic.focusSeconds(TimerLogic.startBreakOnly(5, t0), t0.add(m(3))), 0);
  });

  test('state survives a save/restore round trip (app killed)', () {
    var s = TimerLogic.startFocus(const TimerPreset(50, 10), t0, taskId: 9).copyWith(sessionId: 4);
    s = TimerLogic.pause(s, t0.add(m(7)));
    final r = FocusTimerState.fromJson(s.toJson());
    expect(r.phase, TimerPhase.focus);
    expect(r.taskId, 9);
    expect(r.sessionId, 4);
    expect(r.isPaused, isTrue);
    expect(r.remaining(t0.add(m(99))), m(43));
    expect(r.total, m(50));
  });
}
