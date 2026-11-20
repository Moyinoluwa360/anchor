import 'package:drift/drift.dart';

import '../../models/dates.dart';
import '../database.dart';

/// Time blocks on the day dial.
class PlannerRepository {
  PlannerRepository(this.db);
  final AppDatabase db;

  $TimeBlocksTable get _b => db.timeBlocks;

  Stream<List<TimeBlock>> watchDay(DateTime day) {
    final from = dayOf(day), to = addDays(from, 1);
    final q = db.select(_b)
      ..where((b) => b.startAt.isBiggerOrEqualValue(from) & b.startAt.isSmallerThanValue(to))
      ..orderBy([(b) => OrderingTerm(expression: b.startAt)]);
    return q.watch();
  }

  Stream<List<TimeBlock>> watchRange(DateTime from, DateTime to) {
    final q = db.select(_b)
      ..where((b) => b.startAt.isBiggerOrEqualValue(from) & b.startAt.isSmallerThanValue(to))
      ..orderBy([(b) => OrderingTerm(expression: b.startAt)]);
    return q.watch();
  }

  Future<List<TimeBlock>> upcoming(DateTime from, DateTime to) =>
      (db.select(_b)
            ..where((b) => b.startAt.isBiggerOrEqualValue(from) & b.startAt.isSmallerThanValue(to))
            ..orderBy([(b) => OrderingTerm(expression: b.startAt)]))
          .get();

  Future<int> add(TimeBlocksCompanion c) async {
    final id = await db.into(_b).insert(c);
    if (c.taskId.present && c.taskId.value != null) {
      await (db.update(db.tasks)..where((t) => t.id.equals(c.taskId.value!)))
          .write(TasksCompanion(timeBlockId: Value(id), scheduledDate: Value(dayOf(c.startAt.value))));
    }
    return id;
  }

  Future<void> patch(int id, TimeBlocksCompanion c) => db.transaction(() async {
        await (db.update(_b)..where((b) => b.id.equals(id))).write(c);
        if (c.taskId.present) {
          // Detach whichever task pointed at this block, then attach the new one.
          await (db.update(db.tasks)..where((t) => t.timeBlockId.equals(id)))
              .write(const TasksCompanion(timeBlockId: Value(null)));
          final tid = c.taskId.value;
          if (tid != null) {
            final b = await (db.select(_b)..where((b) => b.id.equals(id))).getSingle();
            await (db.update(db.tasks)..where((t) => t.id.equals(tid)))
                .write(TasksCompanion(timeBlockId: Value(id), scheduledDate: Value(dayOf(b.startAt))));
          }
        }
      });

  Future<void> delete(int id) => db.transaction(() async {
        await (db.update(db.tasks)..where((t) => t.timeBlockId.equals(id)))
            .write(const TasksCompanion(timeBlockId: Value(null)));
        await (db.delete(_b)..where((b) => b.id.equals(id))).go();
      });

  /// Replaces every block of [day] with [blocks] (used by "accept suggested plan").
  Future<void> replaceDay(DateTime day, List<TimeBlocksCompanion> blocks) => db.transaction(() async {
        final from = dayOf(day), to = addDays(from, 1);
        final old = await (db.select(_b)
              ..where((b) => b.startAt.isBiggerOrEqualValue(from) & b.startAt.isSmallerThanValue(to)))
            .get();
        for (final b in old) {
          await delete(b.id);
        }
        for (final b in blocks) {
          await add(b);
        }
      });
}
