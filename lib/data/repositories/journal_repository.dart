import 'package:drift/drift.dart';

import '../../models/dates.dart';
import '../database.dart';

/// Everything that records what happened: focus sessions, energy check-ins,
/// reminders, brain dumps and highlights.
class JournalRepository {
  JournalRepository(this.db);
  final AppDatabase db;

  // Focus sessions -----------------------------------------------------------
  Future<int> startSession(FocusSessionsCompanion c) => db.into(db.focusSessions).insert(c);
  Future<void> patchSession(int id, FocusSessionsCompanion c) =>
      (db.update(db.focusSessions)..where((s) => s.id.equals(id))).write(c);
  Stream<List<FocusSession>> watchSessionsSince(DateTime from) =>
      (db.select(db.focusSessions)
            ..where((s) => s.startAt.isBiggerOrEqualValue(from))
            ..orderBy([(s) => OrderingTerm(expression: s.startAt)]))
          .watch();

  // Energy check-ins ---------------------------------------------------------
  Stream<List<EnergyCheckIn>> watchCheckIns() =>
      (db.select(db.energyCheckIns)..orderBy([(e) => OrderingTerm(expression: e.date)])).watch();

  Future<void> saveCheckIn(DateTime day, int energy, int mood, String? note) => db
      .into(db.energyCheckIns)
      .insert(
        EnergyCheckInsCompanion.insert(date: dayOf(day), energy: energy, mood: mood, note: Value(note)),
        // One check-in per day: a second one replaces the first.
        onConflict: DoUpdate(
          (_) => EnergyCheckInsCompanion(energy: Value(energy), mood: Value(mood), note: Value(note)),
          target: [db.energyCheckIns.date],
        ),
        mode: InsertMode.insert,
      );

  // Reminders ----------------------------------------------------------------
  Stream<List<Reminder>> watchReminders() =>
      (db.select(db.reminders)..orderBy([(r) => OrderingTerm(expression: r.at)])).watch();
  Future<List<Reminder>> reminders() => db.select(db.reminders).get();
  Future<int> addReminder(RemindersCompanion c) => db.into(db.reminders).insert(c);
  Future<void> patchReminder(int id, RemindersCompanion c) =>
      (db.update(db.reminders)..where((r) => r.id.equals(id))).write(c);
  Future<void> deleteReminder(int id) => (db.delete(db.reminders)..where((r) => r.id.equals(id))).go();

  // Brain dump ---------------------------------------------------------------
  Stream<List<BrainDump>> watchBrainDumps() =>
      (db.select(db.brainDumps)
            ..where((b) => b.sorted.equals(false))
            ..orderBy([(b) => OrderingTerm.desc(b.createdAt)]))
          .watch();
  Future<int> addBrainDump(String body) =>
      db.into(db.brainDumps).insert(BrainDumpsCompanion.insert(body: body));
  Future<void> markSorted(int id) => (db.update(
    db.brainDumps,
  )..where((b) => b.id.equals(id))).write(const BrainDumpsCompanion(sorted: Value(true)));
  Future<void> deleteBrainDump(int id) => (db.delete(db.brainDumps)..where((b) => b.id.equals(id))).go();

  // Highlights ---------------------------------------------------------------
  Stream<List<Highlight>> watchHighlights() =>
      (db.select(db.highlights)..orderBy([(h) => OrderingTerm.desc(h.date)])).watch();
  Future<int> addHighlight(HighlightsCompanion c) => db.into(db.highlights).insert(c);
  Future<void> deleteHighlight(int id) => (db.delete(db.highlights)..where((h) => h.id.equals(id))).go();
}
