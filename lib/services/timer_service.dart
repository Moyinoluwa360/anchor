import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../providers/data_providers.dart';
import '../providers/settings.dart';
import 'alarm_player.dart';
import 'timer_logic.dart';

/// Things outside the app that must follow the timer: the scheduled "time's
/// up" notification (Stage 3) and the lock-screen Live Activity (Stage 9).
abstract class TimerSideEffect {
  Future<void> onPhaseScheduled(FocusTimerState s, {String? taskTitle});
  Future<void> onCleared();
}

/// Registered side effects. Later stages add theirs to this list.
final timerSideEffectsProvider = Provider<List<TimerSideEffect>>((ref) => const []);

final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final alarmPlayerProvider = Provider<AlarmPlayer>((ref) {
  final p = AlarmPlayer();
  ref.onDispose(p.dispose);
  return p;
});

/// The one focus timer. Survives the app being suspended or killed: state is
/// saved to preferences and re-evaluated against the clock on resume.
class TimerService extends Notifier<FocusTimerState> {
  static const _key = 'timer.state';
  Timer? _end;
  AppLifecycleListener? _life;

  DateTime get _now => ref.read(clockProvider)();

  @override
  FocusTimerState build() {
    _life = AppLifecycleListener(onResume: _catchUp);
    ref.onDispose(() {
      _end?.cancel();
      _life?.dispose();
    });
    final raw = ref.read(prefsProvider).getString(_key);
    var s = FocusTimerState.idle;
    if (raw != null) {
      try {
        s = FocusTimerState.fromJson((jsonDecode(raw) as Map).cast<String, Object?>());
      } catch (_) {}
    }
    final focus = ref.read(settingsProvider).focusMinutes;
    final brk = ref.read(settingsProvider).breakMinutes;
    if (s.isIdle) s = s.copyWith(focusMinutes: focus, breakMinutes: brk);
    Future.microtask(_catchUp);
    return s;
  }

  // Public API ---------------------------------------------------------------

  Future<void> start({Task? task, TimerPreset? preset}) async {
    final p = preset ?? TimerPreset(state.focusMinutes, state.breakMinutes);
    final now = _now;
    var s = TimerLogic.startFocus(p, now, taskId: task?.id);
    final sid = await ref
        .read(journalRepoProvider)
        .startSession(
          FocusSessionsCompanion.insert(
            taskId: Value(task?.id),
            plannedMinutes: p.focus,
            breakMinutes: Value(p.brk),
            startAt: now,
          ),
        );
    s = s.copyWith(sessionId: sid);
    unawaited(HapticFeedback.mediumImpact());
    await _set(s, taskTitle: task?.title);
  }

  Future<void> startReset({int minutes = 5}) async {
    unawaited(HapticFeedback.mediumImpact());
    await _set(TimerLogic.startBreakOnly(minutes, _now));
  }

  Future<void> pause() async {
    unawaited(HapticFeedback.selectionClick());
    await _set(TimerLogic.pause(state, _now));
  }

  Future<void> resume() async {
    unawaited(HapticFeedback.selectionClick());
    await _set(TimerLogic.resume(state, _now));
  }

  Future<void> extend([Duration by = const Duration(minutes: 5)]) async {
    unawaited(HapticFeedback.selectionClick());
    await _set(TimerLogic.extend(state, by, _now));
  }

  /// Stop early. Focus time already spent still counts.
  Future<void> stop() async {
    final now = _now;
    await _closeSession(state, now, completed: false);
    unawaited(HapticFeedback.lightImpact());
    await _set(
      FocusTimerState(
        focusMinutes: state.focusMinutes,
        breakMinutes: state.breakMinutes,
        event: TimerEvent.stoppedEarly,
        eventAt: now,
      ),
    );
  }

  /// Skip the rest of a focus block straight into its break (task finished early).
  Future<void> finishFocusEarly() async {
    if (state.phase != TimerPhase.focus) return;
    final now = _now;
    final ended = state.copyWith(endsAt: now, clearPaused: true);
    await _set(ended);
    await _catchUp();
  }

  Future<void> setDefaultPreset(TimerPreset p) async {
    await ref
        .read(settingsProvider.notifier)
        .update((s) => s.copyWith(focusMinutes: p.focus, breakMinutes: p.brk));
    if (state.isIdle) await _set(state.copyWith(focusMinutes: p.focus, breakMinutes: p.brk));
  }

  /// The UI has shown the latest event (chime, guard prompt).
  void ackEvent() {
    if (state.event != TimerEvent.none) {
      state = FocusTimerState(
        phase: state.phase,
        focusMinutes: state.focusMinutes,
        breakMinutes: state.breakMinutes,
        endsAt: state.endsAt,
        pausedRemaining: state.pausedRemaining,
        total: state.total,
        phaseStartedAt: state.phaseStartedAt,
        taskId: state.taskId,
        sessionId: state.sessionId,
      );
    }
  }

  // Internals ----------------------------------------------------------------

  Future<void> _catchUp() async {
    final now = _now;
    final before = state;
    final (next, ended) = TimerLogic.advance(before, now);
    if (ended.isEmpty) {
      _schedule();
      return;
    }
    if (ended.first == TimerPhase.focus) {
      await _closeSession(before, before.endsAt!, completed: true);
    }
    // Only ring if the end was moments ago (otherwise the notification already did).
    final endedAt = next.eventAt ?? now;
    if (now.difference(endedAt).inSeconds < 5) {
      await ref.read(alarmPlayerProvider).ring(sound: ref.read(settingsProvider).timerSound);
    }
    await _set(next);
  }

  Future<void> _closeSession(FocusTimerState s, DateTime at, {required bool completed}) async {
    final id = s.sessionId;
    if (id == null || s.phase != TimerPhase.focus) return;
    await ref
        .read(journalRepoProvider)
        .patchSession(
          id,
          FocusSessionsCompanion(
            endAt: Value(at),
            actualSeconds: Value(TimerLogic.focusSeconds(s, at)),
            completed: Value(completed),
          ),
        );
  }

  Future<void> _set(FocusTimerState s, {String? taskTitle}) async {
    state = s;
    await ref.read(prefsProvider).setString(_key, jsonEncode(s.toJson()));
    _schedule();
    for (final fx in ref.read(timerSideEffectsProvider)) {
      try {
        if (s.isIdle) {
          await fx.onCleared();
        } else {
          await fx.onPhaseScheduled(s, taskTitle: taskTitle);
        }
      } catch (e) {
        debugPrint('Timer side effect failed: $e');
      }
    }
  }

  void _schedule() {
    _end?.cancel();
    if (!state.isRunning) return;
    final wait = state.endsAt!.difference(_now);
    _end = Timer(wait.isNegative ? Duration.zero : wait, _catchUp);
  }
}

final timerProvider = NotifierProvider<TimerService, FocusTimerState>(TimerService.new);
