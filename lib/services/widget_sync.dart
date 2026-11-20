import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:live_activities/live_activities.dart';

import '../app_config.dart';
import '../data/database.dart';
import '../models/dates.dart';
import '../providers/data_providers.dart';
import '../providers/week_providers.dart';
import '../screens/now/now_screen.dart';
import 'progress_service.dart';
import 'timer_logic.dart';
import 'timer_service.dart';

/// Home screen widgets and the Live Activity only exist when the build was
/// made with `--dart-define=WIDGETS=true` (Codemagic sets it from
/// ENABLE_WIDGETS). Without it, none of this code runs.
const widgetsEnabled = bool.fromEnvironment('WIDGETS');

/// Widget kinds; must match the Swift `kind` strings in ios/AnchorWidgets.
abstract final class WidgetKinds {
  static const now = 'AnchorNow';
  static const top3 = 'AnchorTop3';
  static const targets = 'AnchorTargets';
  static const all = [now, top3, targets];
}

/// The data the widgets show, as plain strings in the shared App Group.
@immutable
class WidgetSnapshot {
  const WidgetSnapshot({
    required this.nowTitle,
    required this.nowStep,
    required this.nowMeta,
    required this.top3,
    required this.targets,
  });
  final String nowTitle;
  final String nowStep;
  final String nowMeta;
  final List<String> top3;
  final List<({String title, int percent})> targets;

  Map<String, String> toStore() => {
    'now_title': nowTitle,
    'now_step': nowStep,
    'now_meta': nowMeta,
    'top3': jsonEncode(top3),
    'targets': jsonEncode([
      for (final t in targets) {'t': t.title, 'p': t.percent},
    ]),
  };

  /// Built from the same data the app shows (pure, tested).
  static WidgetSnapshot build({
    required List<Task> deck,
    required List<WeeklyTarget> targets,
    required List<Task> allTasks,
  }) {
    final first = deck.isEmpty ? null : deck.first;
    final tops = deck.where((t) => t.topRank != null).toList()
      ..sort((a, b) => a.topRank!.compareTo(b.topRank!));
    final top3 = (tops.isNotEmpty ? tops : deck).take(3).map((t) => t.title).toList();
    return WidgetSnapshot(
      nowTitle: first?.title ?? 'Clear deck',
      nowStep: first?.firstStep ?? (first == null ? 'Nothing left for today.' : 'Just start for 5 minutes.'),
      nowMeta: first == null
          ? ''
          : '${first.area.short.toUpperCase()} · ${minutesLabel(first.estimatedMinutes)}',
      top3: top3,
      targets: [
        for (final t in targets.take(4))
          (title: t.title, percent: (ProgressService.target(t, allTasks) * 100).round()),
      ],
    );
  }
}

/// Pushes fresh data to the home screen widgets whenever it changes.
class WidgetSync extends Notifier<int> {
  Timer? _debounce;

  @override
  int build() {
    ref.onDispose(() => _debounce?.cancel());
    if (!widgetsEnabled) return 0;
    ref.listen(nowDeckProvider, (_, _) => _schedule());
    ref.listen(weekTargetsProvider, (_, _) => _schedule());
    ref.listen(allTasksProvider, (_, _) => _schedule());
    HomeWidget.setAppGroupId(AppConfig.appGroup).ignore();
    _schedule();
    return 0;
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), _push);
  }

  Future<void> _push() async {
    try {
      final snap = WidgetSnapshot.build(
        deck: ref.read(nowDeckProvider),
        targets: ref.read(weekTargetsProvider).value ?? const [],
        allTasks: ref.read(allTasksProvider).value ?? const [],
      );
      for (final e in snap.toStore().entries) {
        await HomeWidget.saveWidgetData<String>(e.key, e.value);
      }
      for (final k in WidgetKinds.all) {
        await HomeWidget.updateWidget(iOSName: k);
      }
      state++;
    } catch (e) {
      debugPrint('Widget update skipped: $e');
    }
  }
}

final widgetSyncProvider = NotifierProvider<WidgetSync, int>(WidgetSync.new);

/// Lock-screen timer (Live Activity). Designed for the lock screen and the
/// banner; the Dynamic Island layout is minimal because the phone has none.
class LiveActivityTimer implements TimerSideEffect {
  final _la = LiveActivities();
  bool _ready = false;
  static const _activityId = 'anchor-focus-timer';

  Future<void> _init() async {
    if (_ready) return;
    await _la.init(appGroupId: AppConfig.appGroup);
    _ready = true;
  }

  /// Data the Swift view reads (see ios/AnchorWidgets/TimerLiveActivity.swift).
  static Map<String, dynamic> payload(FocusTimerState s, String? taskTitle, DateTime now) {
    final isBreak = s.phase == TimerPhase.breakTime;
    final end = s.isPaused ? now.add(s.remaining(now)) : s.endsAt!;
    final start = end.subtract(s.total);
    return {
      'title': isBreak ? 'Break' : (taskTitle ?? 'Focus'),
      'phase': isBreak ? 'BREAK' : 'FOCUS',
      'minutes': s.total.inMinutes,
      'startEpoch': start.millisecondsSinceEpoch / 1000,
      'endEpoch': end.millisecondsSinceEpoch / 1000,
      'paused': s.isPaused,
      'remaining': s.remaining(now).inSeconds,
    };
  }

  @override
  Future<void> onPhaseScheduled(FocusTimerState s, {String? taskTitle}) async {
    if (!widgetsEnabled) return;
    try {
      await _init();
      if (!await _la.areActivitiesEnabled()) return;
      await _la.createOrUpdateActivity(
        _activityId,
        payload(s, taskTitle, DateTime.now()),
        iOSEnableRemoteUpdates: false,
        removeWhenAppIsKilled: false,
      );
    } catch (e) {
      debugPrint('Live Activity skipped: $e');
    }
  }

  @override
  Future<void> onCleared() async {
    if (!widgetsEnabled || !_ready) return;
    try {
      await _la.endAllActivities();
    } catch (_) {}
  }
}

final liveActivityProvider = Provider<LiveActivityTimer>((ref) => LiveActivityTimer());
