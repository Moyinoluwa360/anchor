import '../data/database.dart';
import '../models/enums.dart';

/// Orders today's open tasks for the Now deck. The first card is always "the
/// one thing to do right now":
/// 1. the task attached to the time block happening now,
/// 2. today's top 3 in rank order,
/// 3. tasks attached to later blocks, by block start,
/// 4. everything else by priority, then by when it was added — or, after a
///    check-in, easy wins first on a low day (energy 1–2) and the heaviest,
///    most important thing first on a high day (4–5),
/// and snoozed tasks wait at the back until their snooze ends.
List<Task> orderDeck(List<Task> tasks, List<TimeBlock> blocks, DateTime now, {int? energy}) {
  final blockById = {for (final b in blocks) b.id: b};
  TimeBlock? blockOf(Task t) => t.timeBlockId == null ? null : blockById[t.timeBlockId];
  bool isNow(TimeBlock b) => !now.isBefore(b.startAt) && now.isBefore(b.endAt);
  bool sleeping(Task t) =>
      t.status == TaskStatus.snoozed && t.snoozedUntil != null && t.snoozedUntil!.isAfter(now);

  int rank(Task t) {
    if (sleeping(t)) return 5;
    final b = blockOf(t);
    if (b != null && isNow(b)) return 0;
    if (t.topRank != null) return 1;
    // On a low-energy day easy wins beat whatever was planned for later.
    if (b != null && b.startAt.isAfter(now) && !(energy != null && energy <= 2)) return 2;
    return 3;
  }

  final list = [...tasks];
  list.sort((a, b) {
    final r = rank(a).compareTo(rank(b));
    if (r != 0) return r;
    switch (rank(a)) {
      case 1:
        return a.topRank!.compareTo(b.topRank!);
      case 2:
        return blockOf(a)!.startAt.compareTo(blockOf(b)!.startAt);
      case 5:
        return a.snoozedUntil!.compareTo(b.snoozedUntil!);
    }
    if (energy != null && energy <= 2) {
      final e = a.effort.index.compareTo(b.effort.index);
      if (e != 0) return e;
      final m = a.estimatedMinutes.compareTo(b.estimatedMinutes);
      if (m != 0) return m;
    }
    final p = a.priority.compareTo(b.priority);
    if (p != 0) return p;
    if (energy != null && energy >= 4) {
      final e = b.effort.index.compareTo(a.effort.index);
      if (e != 0) return e;
    }
    final s = a.sortOrder.compareTo(b.sortOrder);
    return s != 0 ? s : a.id.compareTo(b.id);
  });
  return list;
}

/// When a swipe-down snooze should wake the task again: one hour later, or
/// tomorrow morning if that would run past 21:00.
DateTime snoozeUntil(DateTime now) {
  final later = now.add(const Duration(hours: 1));
  if (later.hour >= 21 || later.day != now.day) {
    return DateTime(now.year, now.month, now.day + 1, 9);
  }
  return later;
}

/// Easiest open tasks first: light effort, then short estimates.
List<Task> easierThan(Task current, List<Task> open) {
  int score(Task t) => t.effort.index * 100 + t.estimatedMinutes;
  final others = open.where((t) => t.id != current.id).toList()..sort((a, b) => score(a).compareTo(score(b)));
  return others.where((t) => score(t) <= score(current)).take(3).toList();
}
