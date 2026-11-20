import '../models/dates.dart';

/// Result of the gentle streak calculation.
class StreakResult {
  const StreakResult({
    required this.current,
    required this.best,
    required this.paused,
    required this.restDaysUsed,
  });

  /// Active days in the current run. Never drops to zero with a message:
  /// a missed day only pauses it.
  final int current;
  final int best;

  /// True when yesterday (or more) had no activity and was not a rest day.
  final bool paused;

  /// Rest days used in the current week.
  final int restDaysUsed;

  static const empty = StreakResult(current: 0, best: 0, paused: false, restDaysUsed: 0);
}

/// Gentle streak rules (see docs/BUILD_PLAN.md → Decisions):
/// * A streak counts days with at least one task done.
/// * One missed day per Monday–Sunday week is a free rest day: it never
///   breaks or pauses anything.
/// * Other missed days pause the streak (it stops growing but keeps its
///   number). After more than [maxPauseDays] paused days in a row the next
///   active day quietly starts a fresh run; the best streak is kept.
/// * Today never counts as missed: the day is still in progress.
class StreakService {
  const StreakService({this.restDayPerWeek = true, this.maxPauseDays = 3});

  final bool restDayPerWeek;
  final int maxPauseDays;

  StreakResult compute(Iterable<DateTime> activity, {required DateTime now}) {
    final days = activity.map(dayOf).toSet();
    if (days.isEmpty) return StreakResult.empty;
    final t = today(now);
    final first = days.reduce((a, b) => a.isBefore(b) ? a : b);

    var run = 0, best = 0, gap = 0;
    final restUsed = <DateTime>{};
    for (var d = first; !d.isAfter(t); d = addDays(d, 1)) {
      if (days.contains(d)) {
        if (gap > maxPauseDays) run = 0;
        run += 1;
        gap = 0;
        if (run > best) best = run;
      } else if (sameDay(d, t)) {
        // In progress.
      } else {
        final wk = weekStartOf(d);
        if (restDayPerWeek && !restUsed.contains(wk)) {
          restUsed.add(wk);
        } else {
          gap += 1;
        }
      }
    }
    return StreakResult(
      current: run,
      best: best,
      paused: gap > 0,
      restDaysUsed: restUsed.contains(weekStartOf(t)) ? 1 : 0,
    );
  }
}
