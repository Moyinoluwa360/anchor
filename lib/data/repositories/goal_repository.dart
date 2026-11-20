import 'package:drift/drift.dart';

import '../../models/dates.dart';
import '../database.dart';

/// Goals, milestones and weekly targets.
class GoalRepository {
  GoalRepository(this.db);
  final AppDatabase db;

  Stream<List<Goal>> watchGoals() =>
      (db.select(db.goals)..orderBy([(g) => OrderingTerm(expression: g.id)])).watch();

  Stream<List<Milestone>> watchMilestones() =>
      (db.select(db.milestones)..orderBy([(m) => OrderingTerm(expression: m.dueDate)])).watch();

  Stream<List<WeeklyTarget>> watchTargets(DateTime weekStart) {
    final ws = weekStartOf(weekStart);
    return (db.select(db.weeklyTargets)
          ..where((w) => w.weekStart.equals(ws))
          ..orderBy([(w) => OrderingTerm(expression: w.sortOrder), (w) => OrderingTerm(expression: w.id)]))
        .watch();
  }

  Stream<List<WeeklyTarget>> watchAllTargets() => db.select(db.weeklyTargets).watch();

  Future<int> addGoal(GoalsCompanion c) => db.into(db.goals).insert(c);
  Future<void> patchGoal(int id, GoalsCompanion c) =>
      (db.update(db.goals)..where((g) => g.id.equals(id))).write(c);
  Future<void> deleteGoal(int id) => (db.delete(db.goals)..where((g) => g.id.equals(id))).go();

  Future<void> moveGoal(int id, double x, double y) =>
      patchGoal(id, GoalsCompanion(posX: Value(x), posY: Value(y)));

  Future<int> addMilestone(MilestonesCompanion c) => db.into(db.milestones).insert(c);
  Future<void> patchMilestone(int id, MilestonesCompanion c) =>
      (db.update(db.milestones)..where((m) => m.id.equals(id))).write(c);
  Future<void> setMilestoneDone(int id, bool done) => patchMilestone(
      id, MilestonesCompanion(done: Value(done), doneAt: Value(done ? DateTime.now() : null)));
  Future<void> deleteMilestone(int id) =>
      (db.delete(db.milestones)..where((m) => m.id.equals(id))).go();

  Future<int> addTarget(WeeklyTargetsCompanion c) => db.into(db.weeklyTargets).insert(c);
  Future<void> patchTarget(int id, WeeklyTargetsCompanion c) =>
      (db.update(db.weeklyTargets)..where((w) => w.id.equals(id))).write(c);
  Future<void> deleteTarget(int id) =>
      (db.delete(db.weeklyTargets)..where((w) => w.id.equals(id))).go();

  Future<void> reorderTargets(List<int> idsInOrder) => db.transaction(() async {
        for (var i = 0; i < idsInOrder.length; i++) {
          await patchTarget(idsInOrder[i], WeeklyTargetsCompanion(sortOrder: Value(i)));
        }
      });
}
