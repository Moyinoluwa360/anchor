import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../data/database.dart';
import '../models/dates.dart';
import '../models/enums.dart';
import 'streak_service.dart';

enum Period { day, week, month }

@immutable
class AreaStat {
  const AreaStat({required this.area, required this.streak, required this.last30, required this.attention});
  final LifeArea area;
  final StreakResult streak;

  /// Days in the last 30 with at least one task done in this area.
  final int last30;

  /// For each of the last 30 days (oldest first): had attention?
  final List<bool> attention;
}

@immutable
class DoneGroup {
  const DoneGroup({
    required this.start,
    required this.end,
    required this.tasks,
    required this.focusHours,
    required this.goalsAdvanced,
  });
  final DateTime start;
  final DateTime end;
  final List<Task> tasks;
  final double focusHours;
  final int goalsAdvanced;
}

@immutable
class SundaySummary {
  const SundaySummary({required this.consistent, required this.neglected, required this.suggestion});
  final LifeArea consistent;
  final LifeArea neglected;
  final String suggestion;
}

/// Everything the Done screen shows. Pure; celebrates, never scolds.
abstract final class InsightsService {
  /// Tasks done per day.
  static Map<DateTime, int> dailyCounts(Iterable<Task> done) {
    final out = <DateTime, int>{};
    for (final t in done) {
      if (t.completedAt == null) continue;
      final d = dayOf(t.completedAt!);
      out[d] = (out[d] ?? 0) + 1;
    }
    return out;
  }

  /// 0 (nothing) … 4 (big day). Brighter lemon the more got done.
  static int heatLevel(int count) {
    if (count <= 0) return 0;
    if (count <= 2) return 1;
    if (count <= 4) return 2;
    if (count <= 6) return 3;
    return 4;
  }

  /// Per-area gentle streaks and 30-day attention.
  static List<AreaStat> areaStats(List<Task> done, DateTime now, {bool restDay = true}) {
    final t = today(now);
    final from = addDays(t, -29);
    return [
      for (final a in LifeArea.values)
        () {
          final days = done
              .where((x) => x.area == a && x.completedAt != null)
              .map((x) => dayOf(x.completedAt!))
              .toSet();
          final attention = [for (var i = 0; i < 30; i++) days.contains(addDays(from, i))];
          return AreaStat(
            area: a,
            streak: StreakService(restDayPerWeek: restDay).compute(days, now: now),
            last30: attention.where((x) => x).length,
            attention: attention,
          );
        }(),
    ];
  }

  /// The area to celebrate: longest current streak, then most days in 30.
  static AreaStat? strongest(List<AreaStat> stats) {
    final active = stats.where((s) => s.last30 > 0).toList();
    if (active.isEmpty) return null;
    return active.reduce((a, b) {
      final c = a.streak.current.compareTo(b.streak.current);
      if (c != 0) return c > 0 ? a : b;
      return a.last30 >= b.last30 ? a : b;
    });
  }

  /// The area to flag gently: fewest days of attention in 30 (never the
  /// strongest one, and only if it really is behind).
  static AreaStat? neglected(List<AreaStat> stats) {
    final s = strongest(stats);
    final rest = stats.where((x) => x.area != s?.area).toList();
    if (rest.isEmpty) return null;
    final low = rest.reduce((a, b) => a.last30 <= b.last30 ? a : b);
    final best = stats.map((x) => x.last30).fold(0, math.max);
    return low.last30 < best / 2 ? low : null;
  }

  /// Completed tasks grouped by day, week or month, newest first, with totals.
  static List<DoneGroup> groups(
    List<Task> done,
    List<FocusSession> sessions,
    Period p,
    DateTime now, {
    int limit = 12,
  }) {
    DateTime startOf(DateTime d) => switch (p) {
      Period.day => dayOf(d),
      Period.week => weekStartOf(d),
      Period.month => DateTime(d.year, d.month),
    };
    DateTime next(DateTime s) => switch (p) {
      Period.day => addDays(s, 1),
      Period.week => addDays(s, 7),
      Period.month => DateTime(s.year, s.month + 1),
    };
    final byStart = groupBy(done.where((t) => t.completedAt != null), (Task t) => startOf(t.completedAt!));
    final starts = byStart.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final s in starts.take(limit))
        () {
          final e = next(s);
          final ts = byStart[s]!..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
          final secs = sessions
              .where((f) => !f.startAt.isBefore(s) && f.startAt.isBefore(e))
              .fold<int>(0, (a, f) => a + f.actualSeconds);
          return DoneGroup(
            start: s,
            end: e,
            tasks: ts,
            focusHours: secs / 3600,
            goalsAdvanced: ts.map((t) => t.goalId).whereType<int>().toSet().length,
          );
        }(),
    ];
  }

  /// Sunday card: most consistent and most neglected area this week, plus one idea.
  static SundaySummary? sunday(List<Task> done, DateTime now) {
    final ws = weekStartOf(now);
    final week = done.where((t) => t.completedAt != null && !t.completedAt!.isBefore(ws)).toList();
    final days = {
      for (final a in LifeArea.values)
        a: week.where((t) => t.area == a).map((t) => dayOf(t.completedAt!)).toSet().length,
    };
    if (days.values.every((v) => v == 0)) return null;
    final consistent = days.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    final neglected = days.entries
        .where((e) => e.key != consistent)
        .reduce((a, b) => a.value <= b.value ? a : b)
        .key;
    return SundaySummary(
      consistent: consistent,
      neglected: neglected,
      suggestion: 'Next week, try one 20-minute ${neglected.label.toLowerCase()} block on Monday morning.',
    );
  }

  /// Focus hours per week for the last [weeks] weeks (oldest first).
  static List<double> weeklyFocus(List<FocusSession> sessions, DateTime now, {int weeks = 12}) {
    final ws = weekStartOf(now);
    return [
      for (var i = weeks - 1; i >= 0; i--)
        () {
          final s = addDays(ws, -7 * i), e = addDays(s, 7);
          return sessions
                  .where((f) => !f.startAt.isBefore(s) && f.startAt.isBefore(e))
                  .fold<int>(0, (a, f) => a + f.actualSeconds) /
              3600;
        }(),
    ];
  }

  /// Energy for each of the last [days] days (oldest first); null when no check-in.
  static List<int?> energySeries(List<EnergyCheckIn> checkIns, DateTime now, {int days = 30}) {
    final byDay = {for (final c in checkIns) dayOf(c.date): c.energy};
    final t = today(now);
    return [for (var i = days - 1; i >= 0; i--) byDay[addDays(t, -i)]];
  }

  /// Rolling average over [window] days, ignoring gaps, so trends stay gentle.
  static List<double?> smooth(List<int?> values, {int window = 3}) {
    return [
      for (var i = 0; i < values.length; i++)
        () {
          if (values[i] == null) return null;
          final w = values.sublist(math.max(0, i - window + 1), i + 1).whereType<int>().toList();
          return w.reduce((a, b) => a + b) / w.length;
        }(),
    ];
  }
}
