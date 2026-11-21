import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/database.dart';
import '../providers/settings.dart';

class BackupException implements Exception {
  BackupException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// What an import brought back.
class ImportResult {
  const ImportResult(this.rows, this.settings);
  final Map<String, int> rows;
  final Settings? settings;
  int get total => rows.values.fold(0, (a, b) => a + b);
}

/// Whole-app backup as one JSON file: every table plus settings. Import
/// replaces everything, inside one transaction (all or nothing).
abstract final class BackupService {
  static const format = 'exe-backup';
  static const version = 1;

  static Map<String, Insertable Function(Map<String, dynamic>)> _readers(AppDatabase db) => {
    db.goals.actualTableName: Goal.fromJson,
    db.milestones.actualTableName: Milestone.fromJson,
    db.weeklyTargets.actualTableName: WeeklyTarget.fromJson,
    db.tasks.actualTableName: Task.fromJson,
    db.timeBlocks.actualTableName: TimeBlock.fromJson,
    db.focusSessions.actualTableName: FocusSession.fromJson,
    db.energyCheckIns.actualTableName: EnergyCheckIn.fromJson,
    db.reminders.actualTableName: Reminder.fromJson,
    db.brainDumps.actualTableName: BrainDump.fromJson,
    db.highlights.actualTableName: Highlight.fromJson,
  };

  static Future<Map<String, Object?>> export(AppDatabase db, Settings settings, {DateTime? now}) async {
    final tables = <String, Object?>{};
    for (final t in db.orderedTables) {
      final rows = await db.select(t).get();
      tables[t.actualTableName] = [for (final r in rows) (r as dynamic).toJson() as Map<String, dynamic>];
    }
    return {
      'format': format,
      'version': version,
      'exportedAt': (now ?? DateTime.now()).toIso8601String(),
      'settings': settings.toJson(),
      'tables': tables,
    };
  }

  static String encode(Map<String, Object?> data) => const JsonEncoder.withIndent('  ').convert(data);

  /// Validates first, then wipes and restores in one transaction.
  static Future<ImportResult> import(AppDatabase db, String text) async {
    final Object? raw;
    try {
      raw = jsonDecode(text);
    } catch (_) {
      throw BackupException('That file is not valid JSON.');
    }
    if (raw is! Map || raw['format'] != format) {
      throw BackupException('That file is not an exe backup.');
    }
    final v = raw['version'];
    if (v is! int || v > version) {
      throw BackupException('This backup is from a newer version of exe. Update the app first.');
    }
    final tables = raw['tables'];
    if (tables is! Map) throw BackupException('The backup has no data in it.');

    final readers = _readers(db);
    // Parse everything before touching the database.
    final parsed = <TableInfo<Table, dynamic>, List<Insertable>>{};
    for (final t in db.orderedTables) {
      final list = tables[t.actualTableName];
      if (list == null) {
        parsed[t] = const [];
        continue;
      }
      if (list is! List) throw BackupException('The ${t.actualTableName} section is damaged.');
      try {
        parsed[t] = [for (final r in list) readers[t.actualTableName]!((r as Map).cast<String, dynamic>())];
      } catch (_) {
        throw BackupException('Some ${t.actualTableName} entries could not be read.');
      }
    }

    await db.transaction(() async {
      for (final t in db.orderedTables.reversed) {
        await db.delete(t).go();
      }
      for (final t in db.orderedTables) {
        final rows = parsed[t]!;
        if (rows.isEmpty) continue;
        await db.batch((b) => b.insertAll(t, rows));
      }
    });

    final s = raw['settings'];
    return ImportResult({
      for (final e in parsed.entries) e.key.actualTableName: e.value.length,
    }, s is Map ? Settings.fromJson(s.cast<String, Object?>()) : null);
  }
}
