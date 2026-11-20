import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Set in main() before runApp (overridden in ProviderScope).
final prefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('prefs'));

/// All user preferences. Small, flat, and stored in SharedPreferences. Times
/// of day are minutes after midnight.
@immutable
class Settings {
  const Settings({
    this.themeMode = ThemeMode.dark,
    this.streakBubbleY = 0.0, // clamped to just under the status bar
    this.quietHoursOn = true,
    this.quietStart = 22 * 60 + 30,
    this.quietEnd = 7 * 60,
    this.blockAlerts = true,
    this.morningNudge = true,
    this.morningTime = 8 * 60,
    this.eveningWrap = true,
    this.eveningTime = 21 * 60,
    this.sundayReview = true,
    this.sundayTime = 18 * 60,
    this.healthyHours = 8,
    this.focusMinutes = 25,
    this.breakMinutes = 5,
    this.restDayOn = true,
    this.timerSound = true,
    this.notificationsAsked = false,
    this.distractionPrompt = true,
  });

  final ThemeMode themeMode;

  /// Streak bubble vertical position as a fraction of screen height.
  final double streakBubbleY;
  final bool quietHoursOn;
  final int quietStart;
  final int quietEnd;
  final bool blockAlerts;
  final bool morningNudge;
  final int morningTime;
  final bool eveningWrap;
  final int eveningTime;
  final bool sundayReview;
  final int sundayTime;

  /// Planned hours that still feel healthy; the capacity ring warns past it.
  final int healthyHours;
  final int focusMinutes;
  final int breakMinutes;
  final bool restDayOn;
  final bool timerSound;
  final bool notificationsAsked;
  final bool distractionPrompt;

  Settings copyWith({
    ThemeMode? themeMode,
    double? streakBubbleY,
    bool? quietHoursOn,
    int? quietStart,
    int? quietEnd,
    bool? blockAlerts,
    bool? morningNudge,
    int? morningTime,
    bool? eveningWrap,
    int? eveningTime,
    bool? sundayReview,
    int? sundayTime,
    int? healthyHours,
    int? focusMinutes,
    int? breakMinutes,
    bool? restDayOn,
    bool? timerSound,
    bool? notificationsAsked,
    bool? distractionPrompt,
  }) => Settings(
    themeMode: themeMode ?? this.themeMode,
    streakBubbleY: streakBubbleY ?? this.streakBubbleY,
    quietHoursOn: quietHoursOn ?? this.quietHoursOn,
    quietStart: quietStart ?? this.quietStart,
    quietEnd: quietEnd ?? this.quietEnd,
    blockAlerts: blockAlerts ?? this.blockAlerts,
    morningNudge: morningNudge ?? this.morningNudge,
    morningTime: morningTime ?? this.morningTime,
    eveningWrap: eveningWrap ?? this.eveningWrap,
    eveningTime: eveningTime ?? this.eveningTime,
    sundayReview: sundayReview ?? this.sundayReview,
    sundayTime: sundayTime ?? this.sundayTime,
    healthyHours: healthyHours ?? this.healthyHours,
    focusMinutes: focusMinutes ?? this.focusMinutes,
    breakMinutes: breakMinutes ?? this.breakMinutes,
    restDayOn: restDayOn ?? this.restDayOn,
    timerSound: timerSound ?? this.timerSound,
    notificationsAsked: notificationsAsked ?? this.notificationsAsked,
    distractionPrompt: distractionPrompt ?? this.distractionPrompt,
  );

  Map<String, Object> toJson() => {
    'themeMode': themeMode.name,
    'streakBubbleY': streakBubbleY,
    'quietHoursOn': quietHoursOn,
    'quietStart': quietStart,
    'quietEnd': quietEnd,
    'blockAlerts': blockAlerts,
    'morningNudge': morningNudge,
    'morningTime': morningTime,
    'eveningWrap': eveningWrap,
    'eveningTime': eveningTime,
    'sundayReview': sundayReview,
    'sundayTime': sundayTime,
    'healthyHours': healthyHours,
    'focusMinutes': focusMinutes,
    'breakMinutes': breakMinutes,
    'restDayOn': restDayOn,
    'timerSound': timerSound,
    'notificationsAsked': notificationsAsked,
    'distractionPrompt': distractionPrompt,
  };

  static Settings fromJson(Map<String, Object?> j) {
    const d = Settings();
    T v<T>(String k, T fallback) {
      final x = j[k];
      if (x is T) return x;
      if (fallback is double && x is num) return x.toDouble() as T;
      return fallback;
    }

    return Settings(
      themeMode: ThemeMode.values.asNameMap()[j['themeMode']] ?? d.themeMode,
      streakBubbleY: v('streakBubbleY', d.streakBubbleY),
      quietHoursOn: v('quietHoursOn', d.quietHoursOn),
      quietStart: v('quietStart', d.quietStart),
      quietEnd: v('quietEnd', d.quietEnd),
      blockAlerts: v('blockAlerts', d.blockAlerts),
      morningNudge: v('morningNudge', d.morningNudge),
      morningTime: v('morningTime', d.morningTime),
      eveningWrap: v('eveningWrap', d.eveningWrap),
      eveningTime: v('eveningTime', d.eveningTime),
      sundayReview: v('sundayReview', d.sundayReview),
      sundayTime: v('sundayTime', d.sundayTime),
      healthyHours: v('healthyHours', d.healthyHours),
      focusMinutes: v('focusMinutes', d.focusMinutes),
      breakMinutes: v('breakMinutes', d.breakMinutes),
      restDayOn: v('restDayOn', d.restDayOn),
      timerSound: v('timerSound', d.timerSound),
      notificationsAsked: v('notificationsAsked', d.notificationsAsked),
      distractionPrompt: v('distractionPrompt', d.distractionPrompt),
    );
  }
}

class SettingsController extends Notifier<Settings> {
  static const _prefix = 'setting.';

  @override
  Settings build() {
    final p = ref.watch(prefsProvider);
    final map = <String, Object?>{
      for (final k in p.getKeys().where((k) => k.startsWith(_prefix))) k.substring(_prefix.length): p.get(k),
    };
    return Settings.fromJson(map);
  }

  Future<void> update(Settings Function(Settings s) change) async {
    final next = change(state);
    state = next;
    await _persist(next);
  }

  Future<void> replace(Settings s) async {
    state = s;
    await _persist(s);
  }

  Future<void> _persist(Settings s) async {
    final p = ref.read(prefsProvider);
    for (final e in s.toJson().entries) {
      final k = '$_prefix${e.key}';
      final v = e.value;
      if (v is bool) {
        await p.setBool(k, v);
      } else if (v is int) {
        await p.setInt(k, v);
      } else if (v is double) {
        await p.setDouble(k, v);
      } else if (v is String) {
        await p.setString(k, v);
      }
    }
  }
}

final settingsProvider = NotifierProvider<SettingsController, Settings>(SettingsController.new);
