import 'package:flutter/foundation.dart';

import '../data/database.dart';
import '../models/dates.dart';
import '../models/enums.dart';
import '../providers/settings.dart';

/// How a planned notification repeats on iOS.
enum Repeat { once, daily, weekly }

/// One notification to hand to iOS. Times are local wall-clock times.
@immutable
class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
    required this.payload,
    this.repeat = Repeat.once,
  });

  final int id;
  final DateTime at;
  final String title;
  final String body;
  final String payload;
  final Repeat repeat;

  @override
  String toString() => 'PN($id ${repeat.name} $at "$title")';
}

/// Notification ID ranges, so each kind can be replaced without touching the
/// others. The timer (1, 2) is managed by the timer itself.
abstract final class NotificationIds {
  static const timerFocusEnd = 1;
  static const timerBreakEnd = 2;
  static const morning = 10;
  static const evening = 11;
  static const sunday = 12;
  static const blockBase = 1000; // + block id
  static const reminderBase = 100000; // + reminder id * 10 + slot
  static bool isTimer(int id) => id == timerFocusEnd || id == timerBreakEnd;
}

/// Quiet hours: a window of minutes-after-midnight that may wrap past midnight.
@immutable
class QuietHours {
  const QuietHours(this.start, this.end, {this.on = true});
  final int start;
  final int end;
  final bool on;

  bool containsMinute(int m) {
    if (!on || start == end) return false;
    return start < end ? (m >= start && m < end) : (m >= start || m < end);
  }

  bool contains(DateTime t) => containsMinute(t.hour * 60 + t.minute);

  /// Moves [t] to the end of the quiet window it falls in (same or next day).
  DateTime shift(DateTime t) {
    if (!contains(t)) return t;
    final d = dayOf(t);
    var out = d.add(Duration(minutes: end));
    if (!out.isAfter(t)) out = addDays(d, 1).add(Duration(minutes: end));
    return out;
  }

  /// Same idea for a daily time of day.
  int shiftMinute(int m) => containsMinute(m) ? end : m;
}

/// Decides every notification the app should have scheduled right now.
/// Pure: no plugin calls, fully testable.
class NotificationPlanner {
  const NotificationPlanner({this.maxPending = 60});

  /// iOS keeps at most 64 pending local notifications per app; leave room
  /// for the two timer alerts.
  final int maxPending;

  List<PlannedNotification> plan({
    required Settings settings,
    required List<TimeBlock> blocks,
    required List<Reminder> reminders,
    required Map<int, String> taskTitles,
    required DateTime now,
  }) {
    final q = QuietHours(settings.quietStart, settings.quietEnd, on: settings.quietHoursOn);
    final out = <PlannedNotification>[];
    DateTime atMinute(int m) => today(now).add(Duration(minutes: m));

    // Daily nudges.
    if (settings.morningNudge) {
      out.add(
        PlannedNotification(
          id: NotificationIds.morning,
          at: atMinute(q.shiftMinute(settings.morningTime)),
          title: 'Morning. How are you arriving?',
          body: 'Ten seconds: energy and mood, and your day adjusts.',
          payload: 'checkin',
          repeat: Repeat.daily,
        ),
      );
    }
    if (settings.eveningWrap) {
      out.add(
        PlannedNotification(
          id: NotificationIds.evening,
          at: atMinute(q.shiftMinute(settings.eveningTime)),
          title: 'Wrap up the day',
          body: 'See what you got done. Leftovers can wait for tomorrow.',
          payload: 'done',
          repeat: Repeat.daily,
        ),
      );
    }
    if (settings.sundayReview) {
      final ws = weekStartOf(now);
      final sunday = addDays(ws, 6).add(Duration(minutes: q.shiftMinute(settings.sundayTime)));
      out.add(
        PlannedNotification(
          id: NotificationIds.sunday,
          at: sunday,
          title: 'Sunday review',
          body: 'Three quick cards: what got done, what carries over, next week.',
          payload: 'review',
          repeat: Repeat.weekly,
        ),
      );
    }

    // Upcoming blocks: 5 minutes before, within the next 36 hours, not in quiet hours.
    if (settings.blockAlerts) {
      final horizon = now.add(const Duration(hours: 36));
      for (final b in blocks) {
        if (!b.remind || b.type == BlockType.rest) continue;
        final at = b.startAt.subtract(const Duration(minutes: 5));
        if (!at.isAfter(now) || at.isAfter(horizon) || q.contains(at)) continue;
        final what = b.taskId != null && taskTitles[b.taskId] != null
            ? taskTitles[b.taskId]!
            : (b.label.isEmpty ? b.type.label : b.label);
        out.add(
          PlannedNotification(
            id: NotificationIds.blockBase + b.id,
            at: at,
            title: '${b.type.label} in 5 min · ${hhmm(b.startAt)}',
            body: what,
            payload: 'block:${b.id}',
          ),
        );
      }
    }

    // Reminders with repeat rules. Quiet hours push them to the morning.
    for (final r in reminders) {
      if (!r.enabled) continue;
      final base = NotificationIds.reminderBase + r.id * 10;
      final body = r.taskId != null && taskTitles[r.taskId] != null ? taskTitles[r.taskId]! : 'Reminder';
      switch (r.repeat) {
        case RepeatRule.none:
          final at = q.shift(r.at);
          if (at.isAfter(now)) {
            out.add(
              PlannedNotification(id: base, at: at, title: r.title, body: body, payload: 'reminder:${r.id}'),
            );
          }
        case RepeatRule.daily:
          out.add(
            PlannedNotification(
              id: base,
              at: atMinute(q.shiftMinute(r.at.hour * 60 + r.at.minute)),
              title: r.title,
              body: body,
              payload: 'reminder:${r.id}',
              repeat: Repeat.daily,
            ),
          );
        case RepeatRule.weekdays:
          final m = q.shiftMinute(r.at.hour * 60 + r.at.minute);
          final ws = weekStartOf(now);
          for (var i = 0; i < 5; i++) {
            out.add(
              PlannedNotification(
                id: base + i,
                at: addDays(ws, i).add(Duration(minutes: m)),
                title: r.title,
                body: body,
                payload: 'reminder:${r.id}',
                repeat: Repeat.weekly,
              ),
            );
          }
        case RepeatRule.weekly:
          final m = q.shiftMinute(r.at.hour * 60 + r.at.minute);
          final ws = weekStartOf(now);
          out.add(
            PlannedNotification(
              id: base,
              at: addDays(ws, r.at.weekday - 1).add(Duration(minutes: m)),
              title: r.title,
              body: body,
              payload: 'reminder:${r.id}',
              repeat: Repeat.weekly,
            ),
          );
      }
    }

    // Repeating ones first (they matter every day), then the soonest one-offs.
    out.sort((a, b) {
      final ra = a.repeat == Repeat.once ? 1 : 0, rb = b.repeat == Repeat.once ? 1 : 0;
      return ra != rb ? ra.compareTo(rb) : a.at.compareTo(b.at);
    });
    return out.take(maxPending).toList();
  }
}
