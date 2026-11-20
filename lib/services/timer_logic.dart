import 'package:flutter/foundation.dart';

enum TimerPhase { idle, focus, breakTime }

/// What just happened, so the UI can react once (chime, focus guard, toast).
enum TimerEvent { none, focusDone, breakDone, stoppedEarly }

@immutable
class TimerPreset {
  const TimerPreset(this.focus, this.brk);
  final int focus;
  final int brk;
  String get label => '$focus/$brk';

  @override
  bool operator ==(Object other) => other is TimerPreset && other.focus == focus && other.brk == brk;
  @override
  int get hashCode => Object.hash(focus, brk);
}

const timerPresets = [TimerPreset(25, 5), TimerPreset(50, 10), TimerPreset(90, 20)];

/// The 5-minute starter step: a short focus with no break after it.
const starterPreset = TimerPreset(5, 0);

/// Immutable focus-timer state. Everything is derived from wall-clock times,
/// so the timer stays correct while iOS suspends the app.
@immutable
class FocusTimerState {
  const FocusTimerState({
    this.phase = TimerPhase.idle,
    this.focusMinutes = 25,
    this.breakMinutes = 5,
    this.endsAt,
    this.pausedRemaining,
    this.total = Duration.zero,
    this.phaseStartedAt,
    this.taskId,
    this.sessionId,
    this.event = TimerEvent.none,
    this.eventAt,
  });

  final TimerPhase phase;
  final int focusMinutes;
  final int breakMinutes;

  /// When the current phase ends (only meaningful while running).
  final DateTime? endsAt;

  /// Non-null while paused.
  final Duration? pausedRemaining;

  /// Full length of the current phase, including any "+5 min".
  final Duration total;
  final DateTime? phaseStartedAt;
  final int? taskId;
  final int? sessionId;
  final TimerEvent event;
  final DateTime? eventAt;

  static const idle = FocusTimerState();

  bool get isIdle => phase == TimerPhase.idle;
  bool get isPaused => !isIdle && pausedRemaining != null;
  bool get isRunning => !isIdle && pausedRemaining == null;

  Duration remaining(DateTime now) {
    if (isIdle) return Duration.zero;
    if (pausedRemaining != null) return pausedRemaining!;
    final r = endsAt!.difference(now);
    return r.isNegative ? Duration.zero : r;
  }

  /// 1.0 at the start of the phase → 0.0 at the end (the ring drains).
  double fraction(DateTime now) {
    if (isIdle || total.inMilliseconds == 0) return 0;
    return (remaining(now).inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
  }

  bool isOver(DateTime now) => isRunning && !now.isBefore(endsAt!);

  FocusTimerState copyWith({
    TimerPhase? phase,
    int? focusMinutes,
    int? breakMinutes,
    DateTime? endsAt,
    Duration? pausedRemaining,
    bool clearPaused = false,
    Duration? total,
    DateTime? phaseStartedAt,
    int? taskId,
    int? sessionId,
    TimerEvent? event,
    DateTime? eventAt,
  }) => FocusTimerState(
    phase: phase ?? this.phase,
    focusMinutes: focusMinutes ?? this.focusMinutes,
    breakMinutes: breakMinutes ?? this.breakMinutes,
    endsAt: endsAt ?? this.endsAt,
    pausedRemaining: clearPaused ? null : (pausedRemaining ?? this.pausedRemaining),
    total: total ?? this.total,
    phaseStartedAt: phaseStartedAt ?? this.phaseStartedAt,
    taskId: taskId ?? this.taskId,
    sessionId: sessionId ?? this.sessionId,
    event: event ?? this.event,
    eventAt: eventAt ?? this.eventAt,
  );

  Map<String, Object?> toJson() => {
    'phase': phase.name,
    'focus': focusMinutes,
    'break': breakMinutes,
    'endsAt': endsAt?.millisecondsSinceEpoch,
    'paused': pausedRemaining?.inMilliseconds,
    'total': total.inMilliseconds,
    'started': phaseStartedAt?.millisecondsSinceEpoch,
    'task': taskId,
    'session': sessionId,
  };

  static FocusTimerState fromJson(Map<String, Object?> j) {
    DateTime? t(Object? v) => v is int ? DateTime.fromMillisecondsSinceEpoch(v) : null;
    return FocusTimerState(
      phase: TimerPhase.values.asNameMap()[j['phase']] ?? TimerPhase.idle,
      focusMinutes: (j['focus'] as int?) ?? 25,
      breakMinutes: (j['break'] as int?) ?? 5,
      endsAt: t(j['endsAt']),
      pausedRemaining: j['paused'] is int ? Duration(milliseconds: j['paused']! as int) : null,
      total: Duration(milliseconds: (j['total'] as int?) ?? 0),
      phaseStartedAt: t(j['started']),
      taskId: j['task'] as int?,
      sessionId: j['session'] as int?,
    );
  }
}

/// Pure transitions. The controller adds side effects (sound, DB, alerts).
abstract final class TimerLogic {
  static FocusTimerState startFocus(TimerPreset p, DateTime now, {int? taskId}) {
    final total = Duration(minutes: p.focus);
    return FocusTimerState(
      phase: TimerPhase.focus,
      focusMinutes: p.focus,
      breakMinutes: p.brk,
      endsAt: now.add(total),
      total: total,
      phaseStartedAt: now,
      taskId: taskId,
    );
  }

  /// A break on its own (the "5-minute reset" from Stuck?).
  static FocusTimerState startBreakOnly(int minutes, DateTime now) {
    final total = Duration(minutes: minutes);
    return FocusTimerState(
      phase: TimerPhase.breakTime,
      focusMinutes: 0,
      breakMinutes: minutes,
      endsAt: now.add(total),
      total: total,
      phaseStartedAt: now,
    );
  }

  static FocusTimerState pause(FocusTimerState s, DateTime now) =>
      s.isRunning ? s.copyWith(pausedRemaining: s.remaining(now)) : s;

  static FocusTimerState resume(FocusTimerState s, DateTime now) =>
      s.isPaused ? s.copyWith(endsAt: now.add(s.pausedRemaining!), clearPaused: true) : s;

  static FocusTimerState extend(FocusTimerState s, Duration by, DateTime now) {
    if (s.isIdle) return s;
    if (s.isPaused) return s.copyWith(pausedRemaining: s.pausedRemaining! + by, total: s.total + by);
    return s.copyWith(endsAt: s.endsAt!.add(by), total: s.total + by);
  }

  /// Moves past every phase that has ended by [now] (the app may have been
  /// asleep through both focus and break). Returns the new state and the
  /// phases that ended, in order.
  static (FocusTimerState, List<TimerPhase>) advance(FocusTimerState s, DateTime now) {
    final ended = <TimerPhase>[];
    var cur = s;
    while (cur.isOver(now)) {
      ended.add(cur.phase);
      if (cur.phase == TimerPhase.focus && cur.breakMinutes > 0) {
        // Hard stop: the break starts exactly when focus ended.
        final start = cur.endsAt!;
        final total = Duration(minutes: cur.breakMinutes);
        cur = cur.copyWith(
          phase: TimerPhase.breakTime,
          endsAt: start.add(total),
          total: total,
          phaseStartedAt: start,
          event: TimerEvent.focusDone,
          eventAt: start,
        );
      } else {
        cur = FocusTimerState(
          focusMinutes: cur.focusMinutes,
          breakMinutes: cur.breakMinutes,
          taskId: cur.taskId,
          event: cur.phase == TimerPhase.focus ? TimerEvent.focusDone : TimerEvent.breakDone,
          eventAt: cur.endsAt,
        );
      }
    }
    return (cur, ended);
  }

  /// Seconds of focus actually spent in a focus phase that is ending now.
  static int focusSeconds(FocusTimerState s, DateTime now) {
    if (s.phase != TimerPhase.focus) return 0;
    return (s.total - s.remaining(now)).inSeconds.clamp(0, s.total.inSeconds);
  }
}
