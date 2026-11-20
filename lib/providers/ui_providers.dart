import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/streak_service.dart';
import 'data_providers.dart';
import 'settings.dart';

/// Whether floating chrome (bottom bar, streak bubble) is fully shown.
/// Scrolling down tucks it away; scrolling up brings it back.
class ChromeVisible extends Notifier<bool> {
  @override
  bool build() => true;
  void set(bool v) {
    if (state != v) state = v;
  }
}

final chromeVisibleProvider = NotifierProvider<ChromeVisible, bool>(ChromeVisible.new);

/// Overall gentle streak from completed tasks.
final streakProvider = Provider<StreakResult>((ref) {
  final done = ref.watch(doneTasksProvider).value ?? const [];
  final s = ref.watch(settingsProvider);
  final now = ref.watch(minuteTickProvider).value ?? DateTime.now();
  return StreakService(restDayPerWeek: s.restDayOn)
      .compute(done.map((t) => t.completedAt).whereType<DateTime>(), now: now);
});
