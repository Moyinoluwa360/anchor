import 'package:drift/drift.dart';

import '../../models/dates.dart';
import '../../models/enums.dart';
import '../database.dart';

class TaskRepository {
  TaskRepository(this.db);
  final AppDatabase db;

  $TasksTable get _t => db.tasks;

  /// Open tasks for [day]: scheduled for it or earlier (unfinished work rolls
  /// forward quietly; nothing is ever "overdue"), not snoozed past now.
  Stream<List<Task>> watchOpenFor(DateTime day, {DateTime? now}) {
    final end = addDays(dayOf(day), 1);
    final q = db.select(_t)
      ..where(
        (t) =>
            t.status.isIn([TaskStatus.todo.name, TaskStatus.inProgress.name, TaskStatus.snoozed.name]) &
            t.scheduledDate.isSmallerThanValue(end),
      )
      ..orderBy([
        (t) => OrderingTerm(expression: t.topRank, nulls: NullsOrder.last),
        (t) => OrderingTerm(expression: t.priority),
        (t) => OrderingTerm(expression: t.sortOrder),
        (t) => OrderingTerm(expression: t.id),
      ]);
    return q.watch();
  }

  /// Tasks with no day yet (the "someday" pile).
  Stream<List<Task>> watchInbox() {
    final q = db.select(_t)
      ..where((t) => t.scheduledDate.isNull() & t.status.equals(TaskStatus.todo.name))
      ..orderBy([(t) => OrderingTerm(expression: t.priority), (t) => OrderingTerm(expression: t.id)]);
    return q.watch();
  }

  Stream<List<Task>> watchAllOpen() {
    final q = db.select(_t)..where((t) => t.status.isNotIn([TaskStatus.done.name]));
    return q.watch();
  }

  Stream<List<Task>> watchDoneBetween(DateTime from, DateTime to) {
    final q = db.select(_t)
      ..where(
        (t) =>
            t.status.equals(TaskStatus.done.name) &
            t.completedAt.isBiggerOrEqualValue(from) &
            t.completedAt.isSmallerThanValue(to),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]);
    return q.watch();
  }

  Stream<List<Task>> watchAllDone() {
    final q = db.select(_t)
      ..where((t) => t.status.equals(TaskStatus.done.name))
      ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]);
    return q.watch();
  }

  Stream<List<Task>> watchAll() => db.select(_t).watch();

  Stream<List<Task>> watchForGoal(int goalId) =>
      (db.select(_t)..where((t) => t.goalId.equals(goalId))).watch();

  Future<Task?> byId(int id) => (db.select(_t)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> add(TasksCompanion c) => db.into(_t).insert(c);

  Future<void> patch(int id, TasksCompanion c) => (db.update(_t)..where((t) => t.id.equals(id))).write(c);

  Future<void> complete(int id, {DateTime? at}) => patch(
    id,
    TasksCompanion(
      status: const Value(TaskStatus.done),
      completedAt: Value(at ?? DateTime.now()),
      snoozedUntil: const Value(null),
    ),
  );

  Future<void> reopen(int id) =>
      patch(id, const TasksCompanion(status: Value(TaskStatus.todo), completedAt: Value(null)));

  /// Snooze pushes the card to the back of today's deck until [until]; if that
  /// is tomorrow or later it simply moves to that day.
  Future<void> snooze(int id, DateTime until) => patch(
    id,
    TasksCompanion(
      status: const Value(TaskStatus.snoozed),
      snoozedUntil: Value(until),
      scheduledDate: Value(dayOf(until)),
      sortOrder: Value(DateTime.now().millisecondsSinceEpoch ~/ 1000),
    ),
  );

  Future<void> delete(int id) => (db.delete(_t)..where((t) => t.id.equals(id))).go();

  /// Sets today's top 3 (ids in rank order). Clears any previous picks for that day.
  Future<void> setTopThree(DateTime day, List<int> ids) => db.transaction(() async {
    final d = dayOf(day);
    await (db.update(_t)..where((t) => t.topDate.equals(d))).write(
      const TasksCompanion(topDate: Value(null), topRank: Value(null)),
    );
    for (var i = 0; i < ids.length && i < 3; i++) {
      await patch(ids[i], TasksCompanion(topDate: Value(d), topRank: Value(i + 1), scheduledDate: Value(d)));
    }
  });
}
