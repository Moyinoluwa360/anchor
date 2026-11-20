import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/repositories/goal_repository.dart';
import '../data/repositories/journal_repository.dart';
import '../data/repositories/planner_repository.dart';
import '../data/repositories/task_repository.dart';
import '../models/dates.dart';

/// Set in main() (and in tests) via ProviderScope overrides.
final dbProvider = Provider<AppDatabase>((ref) => throw UnimplementedError('db'));

final taskRepoProvider = Provider((ref) => TaskRepository(ref.watch(dbProvider)));
final plannerRepoProvider = Provider((ref) => PlannerRepository(ref.watch(dbProvider)));
final goalRepoProvider = Provider((ref) => GoalRepository(ref.watch(dbProvider)));
final journalRepoProvider = Provider((ref) => JournalRepository(ref.watch(dbProvider)));

/// Ticks every minute so "today" and "now" stay correct past midnight.
final minuteTickProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 30), (_) => DateTime.now());
});

/// Today's date (midnight). Only changes when the day changes.
final todayProvider = Provider<DateTime>((ref) {
  final now = ref.watch(minuteTickProvider).value ?? DateTime.now();
  return today(now);
});

final openTodayProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepoProvider).watchOpenFor(ref.watch(todayProvider));
});

final inboxProvider = StreamProvider<List<Task>>((ref) => ref.watch(taskRepoProvider).watchInbox());

final allTasksProvider = StreamProvider<List<Task>>((ref) => ref.watch(taskRepoProvider).watchAll());

final doneTasksProvider =
    StreamProvider<List<Task>>((ref) => ref.watch(taskRepoProvider).watchAllDone());

final todayBlocksProvider = StreamProvider<List<TimeBlock>>((ref) {
  return ref.watch(plannerRepoProvider).watchDay(ref.watch(todayProvider));
});

final goalsProvider = StreamProvider<List<Goal>>((ref) => ref.watch(goalRepoProvider).watchGoals());
final milestonesProvider =
    StreamProvider<List<Milestone>>((ref) => ref.watch(goalRepoProvider).watchMilestones());
final allTargetsProvider =
    StreamProvider<List<WeeklyTarget>>((ref) => ref.watch(goalRepoProvider).watchAllTargets());

final checkInsProvider =
    StreamProvider<List<EnergyCheckIn>>((ref) => ref.watch(journalRepoProvider).watchCheckIns());

final todayCheckInProvider = Provider<EnergyCheckIn?>((ref) {
  final d = ref.watch(todayProvider);
  final list = ref.watch(checkInsProvider).value ?? const [];
  for (final c in list.reversed) {
    if (sameDay(c.date, d)) return c;
  }
  return null;
});
