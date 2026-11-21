import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/dates.dart';
import '../providers/data_providers.dart';
import '../providers/settings.dart';
import 'notification_planner.dart';
import 'timer_logic.dart';
import 'timer_service.dart';

/// Thin wrapper over flutter_local_notifications. All local; nothing leaves
/// the phone. Every call is guarded so a plugin hiccup never breaks the app
/// (and tests, which have no plugin, just get no-ops).
class NotificationService implements TimerSideEffect {
  NotificationService();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  void Function(String payload)? onTap;

  /// The custom chime bundled in the Runner target (ios/Runner/chime.caf).
  static const _sound = 'chime.caf';

  Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('Timezone setup failed, using UTC offsets: $e');
    }
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          iOS: DarwinInitializationSettings(
            // Asked later, from the friendly explanation screen.
            requestAlertPermission: false,
            requestSoundPermission: false,
            requestBadgePermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (r) {
          final p = r.payload;
          if (p != null) onTap?.call(p);
        },
      );
      _ready = true;
      final launch = await _plugin.getNotificationAppLaunchDetails();
      final p = launch?.notificationResponse?.payload;
      if ((launch?.didNotificationLaunchApp ?? false) && p != null) {
        Future<void>.delayed(const Duration(milliseconds: 600), () => onTap?.call(p));
      }
    } catch (e) {
      debugPrint('Notifications unavailable: $e');
    }
  }

  IOSFlutterLocalNotificationsPlugin? get _ios =>
      _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

  /// Shows the iOS permission prompt. Returns whether notifications are allowed.
  Future<bool> requestPermission() async {
    if (!_ready) return false;
    try {
      return await _ios?.requestPermissions(alert: true, sound: true, badge: false) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isAllowed() async {
    if (!_ready) return false;
    try {
      final o = await _ios?.checkPermissions();
      return o?.isEnabled ?? false;
    } catch (_) {
      return false;
    }
  }

  NotificationDetails _details({bool timeSensitive = false, bool chime = false}) => NotificationDetails(
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentList: true,
      presentSound: true,
      sound: chime ? _sound : null,
      interruptionLevel: timeSensitive ? InterruptionLevel.timeSensitive : InterruptionLevel.active,
      threadIdentifier: timeSensitive ? 'timer' : 'exe',
    ),
  );

  tz.TZDateTime _tz(DateTime local) => tz.TZDateTime.from(local, tz.local);

  /// Replaces every non-timer notification with [plan].
  Future<void> apply(List<PlannedNotification> plan, DateTime now) async {
    if (!_ready) return;
    try {
      final pending = await _plugin.pendingNotificationRequests();
      final keep = plan.map((p) => p.id).toSet();
      for (final p in pending) {
        if (!NotificationIds.isTimer(p.id) && !keep.contains(p.id)) {
          await _plugin.cancel(id: p.id);
        }
      }
      for (final n in plan) {
        var at = n.at;
        // Repeating schedules need their next occurrence in the future.
        while (!at.isAfter(now) && n.repeat != Repeat.once) {
          at = addDays(at, n.repeat == Repeat.daily ? 1 : 7);
        }
        if (!at.isAfter(now)) continue;
        await _plugin.zonedSchedule(
          id: n.id,
          scheduledDate: _tz(at),
          notificationDetails: _details(),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: n.title,
          body: n.body,
          payload: n.payload,
          matchDateTimeComponents: switch (n.repeat) {
            Repeat.once => null,
            Repeat.daily => DateTimeComponents.time,
            Repeat.weekly => DateTimeComponents.dayOfWeekAndTime,
          },
        );
      }
    } catch (e) {
      debugPrint('Scheduling failed: $e');
    }
  }

  // Timer alerts (TimerSideEffect) --------------------------------------------

  @override
  Future<void> onPhaseScheduled(FocusTimerState s, {String? taskTitle}) async {
    if (!_ready) return;
    await _cancelTimer();
    if (!s.isRunning || s.endsAt == null) return; // paused: nothing to ring
    try {
      final focusEnd = s.phase == TimerPhase.focus ? s.endsAt! : null;
      final breakEnd = s.phase == TimerPhase.breakTime
          ? s.endsAt!
          : (s.breakMinutes > 0 ? s.endsAt!.add(Duration(minutes: s.breakMinutes)) : null);
      if (focusEnd != null) {
        await _plugin.zonedSchedule(
          id: NotificationIds.timerFocusEnd,
          scheduledDate: _tz(focusEnd),
          notificationDetails: _details(timeSensitive: true, chime: true),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          title: s.breakMinutes > 0 ? "Time's up. Break time." : "Time's up. Nice start.",
          body: s.breakMinutes > 0
              ? '${taskTitle ?? 'Focus'} · stand up for ${s.breakMinutes} minutes.'
              : 'Keep going or call it there. Both count.',
          payload: 'timer',
        );
      }
      if (breakEnd != null) {
        await _plugin.zonedSchedule(
          id: NotificationIds.timerBreakEnd,
          scheduledDate: _tz(breakEnd),
          notificationDetails: _details(timeSensitive: true, chime: true),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          title: "Break's over",
          body: 'Back when you are ready. One thing at a time.',
          payload: 'timer',
        );
      }
    } catch (e) {
      debugPrint('Timer alert failed: $e');
    }
  }

  @override
  Future<void> onCleared() => _cancelTimer();

  Future<void> _cancelTimer() async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: NotificationIds.timerFocusEnd);
      await _plugin.cancel(id: NotificationIds.timerBreakEnd);
    } catch (_) {}
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

/// Keeps the scheduled notifications in step with blocks, reminders and
/// settings. Re-plans (debounced) whenever any of them change.
class NotificationSync extends Notifier<int> {
  Timer? _debounce;

  @override
  int build() {
    ref.onDispose(() => _debounce?.cancel());
    ref.listen(settingsProvider, (_, _) => schedule());
    ref.listen(upcomingBlocksProvider, (_, _) => schedule());
    ref.listen(remindersProvider, (_, _) => schedule());
    ref.listen(allTasksProvider, (_, _) => schedule());
    ref.listen(todayProvider, (_, _) => schedule());
    schedule();
    return 0;
  }

  void schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _run);
  }

  Future<void> _run() async {
    final now = DateTime.now();
    final tasks = ref.read(allTasksProvider).value ?? const [];
    final plan = const NotificationPlanner().plan(
      settings: ref.read(settingsProvider),
      blocks: ref.read(upcomingBlocksProvider).value ?? const [],
      reminders: ref.read(remindersProvider).value ?? const [],
      taskTitles: {for (final t in tasks) t.id: t.title},
      now: now,
    );
    await ref.read(notificationServiceProvider).apply(plan, now);
    state++;
  }
}

final notificationSyncProvider = NotifierProvider<NotificationSync, int>(NotificationSync.new);
