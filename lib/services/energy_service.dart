import 'package:flutter/foundation.dart';

import '../data/database.dart';
import '../models/dates.dart';
import 'timer_logic.dart';

/// How the day adapts to the morning check-in.
@immutable
class EnergyAdvice {
  const EnergyAdvice({
    required this.level,
    required this.deckLimit,
    required this.preset,
    required this.headline,
    required this.hint,
  });

  /// low / steady / high / unknown
  final String level;

  /// How many task cards the Now deck shows (null = all).
  final int? deckLimit;

  /// Suggested focus rhythm for today.
  final TimerPreset preset;
  final String headline;
  final String hint;

  bool get isLow => level == 'low';
  bool get isHigh => level == 'high';

  static EnergyAdvice of(int? energy) {
    if (energy == null) {
      return const EnergyAdvice(
        level: 'unknown',
        deckLimit: null,
        preset: TimerPreset(25, 5),
        headline: '',
        hint: '',
      );
    }
    if (energy <= 2) {
      return const EnergyAdvice(
        level: 'low',
        deckLimit: 3,
        preset: TimerPreset(25, 5),
        headline: 'Low-battery day',
        hint: 'Three easy wins, short blocks. That is a full day today.',
      );
    }
    if (energy >= 4) {
      return const EnergyAdvice(
        level: 'high',
        deckLimit: null,
        preset: TimerPreset(50, 10),
        headline: 'Good energy',
        hint: 'Hardest, most important thing first while it lasts.',
      );
    }
    return const EnergyAdvice(
      level: 'steady',
      deckLimit: null,
      preset: TimerPreset(25, 5),
      headline: 'Steady day',
      hint: 'One thing at a time, with real breaks.',
    );
  }
}

abstract final class EnergyService {
  /// True when energy or mood has been 1–2 on each of the last [days]
  /// check-ins, on consecutive days, ending today or yesterday. Used to show a
  /// kind, non-alarming support message.
  static bool lowStretch(List<EnergyCheckIn> checkIns, DateTime now, {int days = 3, int threshold = 2}) {
    if (checkIns.length < days) return false;
    final byDay = {for (final c in checkIns) dayOf(c.date): c};
    final t = today(now);
    // Start from today if checked in, otherwise yesterday.
    var d = byDay.containsKey(t) ? t : addDays(t, -1);
    for (var i = 0; i < days; i++) {
      final c = byDay[d];
      if (c == null) return false;
      if (c.energy > threshold && c.mood > threshold) return false;
      d = addDays(d, -1);
    }
    return true;
  }
}
