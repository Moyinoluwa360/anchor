import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../models/dates.dart';
import 'data_providers.dart';

/// Monday of the current week.
final weekStartProvider = Provider<DateTime>((ref) => weekStartOf(ref.watch(todayProvider)));

final weekBlocksProvider = StreamProvider<List<TimeBlock>>((ref) {
  final ws = ref.watch(weekStartProvider);
  return ref.watch(plannerRepoProvider).watchRange(ws, addDays(ws, 7));
});

final weekSessionsProvider = StreamProvider<List<FocusSession>>((ref) {
  final ws = ref.watch(weekStartProvider);
  return ref.watch(journalRepoProvider).watchSessionsSince(ws);
});

final weekTargetsProvider = StreamProvider<List<WeeklyTarget>>((ref) {
  return ref.watch(goalRepoProvider).watchTargets(ref.watch(weekStartProvider));
});

final nextWeekTargetsProvider = StreamProvider<List<WeeklyTarget>>((ref) {
  return ref.watch(goalRepoProvider).watchTargets(addDays(ref.watch(weekStartProvider), 7));
});
