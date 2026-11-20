import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../data/database.dart';
import '../models/dates.dart';
import '../models/enums.dart';

/// Which slice of the day the dial shows: all 24 hours, or a 6-hour window
/// for fine editing. 0° is straight up.
@immutable
class DialWindow {
  const DialWindow(this.startHour, this.spanHours);
  final double startHour;
  final double spanHours;

  static const fullDay = DialWindow(0, 24);

  /// A 6-hour window starting on the hour before [now].
  factory DialWindow.focused(DateTime now) {
    final start = (now.hour - 1).clamp(0, 18).toDouble();
    return DialWindow(start, 6);
  }

  bool get isFull => spanHours >= 24;

  @override
  bool operator ==(Object other) =>
      other is DialWindow && other.startHour == startHour && other.spanHours == spanHours;
  @override
  int get hashCode => Object.hash(startHour, spanHours);
}

/// How full the day is compared with a healthy limit.
enum CapacityLevel { calm, full, over }

@immutable
class Capacity {
  const Capacity(this.plannedMinutes, this.limitMinutes);
  final int plannedMinutes;
  final int limitMinutes;
  double get ratio => limitMinutes == 0 ? 0 : plannedMinutes / limitMinutes;
  CapacityLevel get level =>
      ratio > 1.0 ? CapacityLevel.over : (ratio >= 0.75 ? CapacityLevel.full : CapacityLevel.calm);
}

/// A proposed block (not yet saved).
@immutable
class BlockDraft {
  const BlockDraft({
    required this.start,
    required this.end,
    required this.type,
    this.label = '',
    this.taskId,
  });
  final DateTime start;
  final DateTime end;
  final BlockType type;
  final String label;
  final int? taskId;
  int get minutes => end.difference(start).inMinutes;

  @override
  String toString() => 'Draft(${hhmm(start)}-${hhmm(end)} ${type.name} $label)';
}

/// How the plan adapts to the morning check-in.
@immutable
class EnergyProfile {
  const EnergyProfile({required this.chunkCap, required this.focusCap, required this.name});
  final int chunkCap; // longest single focus block, minutes
  final int focusCap; // total focus minutes for the day
  final String name;

  static EnergyProfile of(int? energy) {
    final e = energy ?? 3;
    if (e <= 2) return const EnergyProfile(chunkCap: 25, focusCap: 180, name: 'low');
    if (e >= 4) return const EnergyProfile(chunkCap: 90, focusCap: 390, name: 'high');
    return const EnergyProfile(chunkCap: 50, focusCap: 300, name: 'steady');
  }

  bool get isLow => name == 'low';
  bool get isHigh => name == 'high';
}

/// Day-dial geometry, capacity and the auto-suggested plan. Pure and tested.
abstract final class PlannerService {
  static const snapMinutes = 15;

  // Geometry -----------------------------------------------------------------

  /// Angle (radians, 0 = up, clockwise) of time [t] on [day] in window [w].
  static double angleOf(DateTime t, DateTime day, DialWindow w) {
    final hours = t.difference(dayOf(day)).inMinutes / 60;
    return (hours - w.startHour) / w.spanHours * 2 * math.pi;
  }

  /// Minutes after midnight at [angle] (0 = up, clockwise), unsnapped.
  static double minutesAt(double angle, DialWindow w) {
    final a = angle % (2 * math.pi);
    return (w.startHour + a / (2 * math.pi) * w.spanHours) * 60;
  }

  static int snap(double minutes, [int step = snapMinutes]) => (minutes / step).round() * step;

  /// Time on [day] at [angle], snapped to 15 minutes.
  static DateTime timeAt(double angle, DateTime day, DialWindow w) =>
      dayOf(day).add(Duration(minutes: snap(minutesAt(angle, w)).clamp(0, 24 * 60)));

  /// Angle of a point relative to the dial centre (0 = up, clockwise).
  static double angleFromOffset(double dx, double dy) {
    final a = math.atan2(dx, -dy);
    return a < 0 ? a + 2 * math.pi : a;
  }

  // Capacity -----------------------------------------------------------------

  /// Planned working time: focus, admin and fixed commitments. Breaks and rest
  /// never count against you.
  static Capacity capacity(List<TimeBlock> blocks, int healthyHours) {
    var m = 0;
    for (final b in blocks) {
      if (b.type == BlockType.focus || b.type == BlockType.admin || b.type == BlockType.fixed) {
        m += b.endAt.difference(b.startAt).inMinutes;
      }
    }
    return Capacity(m, healthyHours * 60);
  }

  // Auto-suggest -------------------------------------------------------------

  /// Order tasks for the energy of the day.
  static List<Task> orderForEnergy(List<Task> tasks, EnergyProfile p) {
    final list = [...tasks];
    int top(Task t) => t.topRank ?? 9;
    if (p.isLow) {
      // Easy wins first: light, short, then importance.
      list.sort((a, b) {
        final e = a.effort.index.compareTo(b.effort.index);
        if (e != 0) return e;
        final m = a.estimatedMinutes.compareTo(b.estimatedMinutes);
        return m != 0 ? m : a.priority.compareTo(b.priority);
      });
    } else if (p.isHigh) {
      // Hardest, most important thing first.
      list.sort((a, b) {
        final t = top(a).compareTo(top(b));
        if (t != 0) return t;
        final pr = a.priority.compareTo(b.priority);
        if (pr != 0) return pr;
        return b.effort.index.compareTo(a.effort.index);
      });
    } else {
      list.sort((a, b) {
        final t = top(a).compareTo(top(b));
        if (t != 0) return t;
        final pr = a.priority.compareTo(b.priority);
        return pr != 0 ? pr : a.id.compareTo(b.id);
      });
    }
    return list;
  }

  static int breakAfter(int focusMinutes) => focusMinutes >= 75 ? 15 : (focusMinutes >= 40 ? 10 : 5);

  /// Proposes focus blocks with breaks for [tasks] from now until [dayEndHour],
  /// around blocks that stay (fixed commitments, rest, anything already
  /// started). Returns the new drafts only; locked blocks are untouched.
  static List<BlockDraft> suggest({
    required List<Task> tasks,
    required List<TimeBlock> existing,
    required DateTime now,
    int? energy,
    int healthyHours = 8,
    int dayStartHour = 8,
    int dayEndHour = 21,
  }) {
    final p = EnergyProfile.of(energy);
    final day = dayOf(now);
    var cursor = dayOf(now).add(Duration(minutes: ((now.hour * 60 + now.minute) / 15).ceil() * 15));
    final dayStart = day.add(Duration(hours: dayStartHour));
    if (cursor.isBefore(dayStart)) cursor = dayStart;
    final dayEnd = day.add(Duration(hours: dayEndHour));

    final locked = existing.where((b) => isLocked(b, now)).toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));

    // Fixed commitments already eat into the healthy limit.
    final fixedMinutes = locked
        .where((b) => b.type == BlockType.fixed && b.endAt.isAfter(now))
        .fold<int>(0, (s, b) => s + b.endAt.difference(b.startAt).inMinutes);
    var budget = math.min(p.focusCap, healthyHours * 60 - fixedMinutes);

    DateTime nextFree(DateTime t, int minutes) {
      var at = t;
      var moved = true;
      while (moved) {
        moved = false;
        for (final b in locked) {
          final end = at.add(Duration(minutes: minutes));
          if (at.isBefore(b.endAt) && end.isAfter(b.startAt)) {
            at = b.endAt;
            moved = true;
          }
        }
      }
      return at;
    }

    final out = <BlockDraft>[];
    final alreadyPlanned = {
      for (final b in locked)
        if (b.taskId != null) b.taskId!,
    };
    for (final t in orderForEnergy(tasks, p)) {
      if (alreadyPlanned.contains(t.id)) continue;
      if (budget < 15) break;
      final mins = math.max(15, math.min(t.estimatedMinutes, math.min(p.chunkCap, budget)));
      final start = nextFree(cursor, mins);
      final end = start.add(Duration(minutes: mins));
      if (end.isAfter(dayEnd)) break;
      out.add(BlockDraft(start: start, end: end, type: BlockType.focus, label: t.title, taskId: t.id));
      budget -= mins;
      final brk = breakAfter(mins);
      final bStart = end;
      final bEnd = bStart.add(Duration(minutes: brk));
      final clash = locked.any((b) => bStart.isBefore(b.endAt) && bEnd.isAfter(b.startAt));
      if (!clash && !bEnd.isAfter(dayEnd)) {
        out.add(BlockDraft(start: bStart, end: bEnd, type: BlockType.breakTime, label: 'Break'));
      }
      cursor = bEnd;
    }
    // A plan never ends on a break.
    if (out.isNotEmpty && out.last.type == BlockType.breakTime) out.removeLast();
    return out;
  }

  /// Blocks the suggester never moves.
  static bool isLocked(TimeBlock b, DateTime now) =>
      b.type == BlockType.fixed || b.type == BlockType.rest || b.startAt.isBefore(now);
}
