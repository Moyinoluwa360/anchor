import 'package:collection/collection.dart';

import '../data/database.dart';
import '../models/dates.dart';
import '../models/enums.dart';

/// Progress for goals and weekly targets, and the week's numbers. Pure.
abstract final class ProgressService {
  /// 0–1. Milestones carry 60 % of the weight and linked tasks 40 %; with only
  /// one kind present it carries everything. An achieved goal is 100 %.
  static double goal(Goal g, List<Milestone> milestones, List<Task> tasks) {
    if (g.status == GoalStatus.achieved) return 1;
    final ms = milestones.where((m) => m.goalId == g.id).toList();
    final ts = tasks.where((t) => t.goalId == g.id).toList();
    final mRatio = ms.isEmpty ? null : ms.where((m) => m.done).length / ms.length;
    final tRatio = ts.isEmpty ? null : ts.where((t) => t.status == TaskStatus.done).length / ts.length;
    if (mRatio == null && tRatio == null) return 0;
    if (mRatio == null) return tRatio!;
    if (tRatio == null) return mRatio;
    return mRatio * 0.6 + tRatio * 0.4;
  }

  /// 0–1. Done flag wins; otherwise the share of linked tasks completed.
  static double target(WeeklyTarget w, List<Task> tasks) {
    if (w.done) return 1;
    final ts = tasks.where((t) => t.weeklyTargetId == w.id).toList();
    if (ts.isEmpty) return 0;
    return ts.where((t) => t.status == TaskStatus.done).length / ts.length;
  }

  /// Planned working minutes for each day of the week starting [weekStart]
  /// (Mon..Sun): focus, admin and fixed blocks.
  static List<int> weekLoad(List<TimeBlock> blocks, DateTime weekStart) {
    final out = List<int>.filled(7, 0);
    final ws = dayOf(weekStart);
    for (final b in blocks) {
      if (b.type == BlockType.breakTime || b.type == BlockType.rest) continue;
      final i = dayOf(b.startAt).difference(ws).inDays;
      if (i >= 0 && i < 7) out[i] += b.endAt.difference(b.startAt).inMinutes;
    }
    return out;
  }

  /// Tasks completed per day of the week (Mon..Sun).
  static List<int> doneByDay(List<Task> done, DateTime weekStart) {
    final out = List<int>.filled(7, 0);
    final ws = dayOf(weekStart);
    for (final t in done) {
      if (t.completedAt == null) continue;
      final i = dayOf(t.completedAt!).difference(ws).inDays;
      if (i >= 0 && i < 7) out[i]++;
    }
    return out;
  }

  /// Focus hours from sessions that started in [from, to).
  static double focusHours(List<FocusSession> sessions, DateTime from, DateTime to) {
    var s = 0;
    for (final f in sessions) {
      if (!f.startAt.isBefore(from) && f.startAt.isBefore(to)) s += f.actualSeconds;
    }
    return s / 3600;
  }

  /// The soonest milestone that is not done yet (today or later first, then
  /// anything undated).
  static Milestone? nextMilestone(List<Milestone> ms, DateTime now) {
    final open = ms.where((m) => !m.done).toList();
    final dated = open.where((m) => m.dueDate != null && !dayOf(m.dueDate!).isBefore(today(now))).toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    return dated.firstOrNull ?? open.firstWhereOrNull((m) => m.dueDate == null);
  }

  /// Unfinished tasks to carry out of the week ending at [weekStart] + 7.
  static List<Task> carryOver(List<Task> all, DateTime weekStart) {
    final end = addDays(dayOf(weekStart), 7);
    return all
        .where(
          (t) => t.status != TaskStatus.done && t.scheduledDate != null && t.scheduledDate!.isBefore(end),
        )
        .toList();
  }

  /// One suggested target per active goal for next week: its next milestone.
  static List<(Goal, String)> suggestTargets(List<Goal> goals, List<Milestone> ms, DateTime now) {
    final out = <(Goal, String)>[];
    for (final g in goals.where((g) => g.status == GoalStatus.active)) {
      final next = nextMilestone(ms.where((m) => m.goalId == g.id).toList(), now);
      out.add((g, next != null ? 'Move “${next.title}” forward' : 'One step on ${g.title}'));
    }
    return out;
  }
}
