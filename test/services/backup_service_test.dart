import 'dart:convert';

import 'package:exe/data/database.dart';
import 'package:exe/data/seed.dart';
import 'package:exe/providers/settings.dart';
import 'package:exe/services/backup_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  final now = DateTime(2026, 11, 20, 10);

  Future<Map<String, int>> counts(AppDatabase db) async => {
    for (final t in db.orderedTables) t.actualTableName: (await db.select(t).get()).length,
  };

  test('export → import into an empty database restores everything exactly', () async {
    final a = memoryDb();
    await Seeder(a, now: now).seed();
    const settings = Settings(themeMode: ThemeMode.light, healthyHours: 7, quietStart: 23 * 60);
    final json = BackupService.encode(await BackupService.export(a, settings, now: now));

    final b = memoryDb();
    final result = await BackupService.import(b, json);
    expect(await counts(b), await counts(a));
    expect(result.total, greaterThan(500));
    expect(result.settings!.themeMode, ThemeMode.light);
    expect(result.settings!.healthyHours, 7);

    // Same content, including enums, dates and nullable links.
    final ga = await a.select(a.goals).get(), gb = await b.select(b.goals).get();
    expect(gb.map((g) => g.toJson()), ga.map((g) => g.toJson()));
    final ta = await a.select(a.tasks).get(), tb = await b.select(b.tasks).get();
    expect(tb.map((t) => t.toJson()), ta.map((t) => t.toJson()));
    await a.close();
    await b.close();
  });

  test('import replaces existing data (no duplicates)', () async {
    final a = memoryDb();
    await Seeder(a, now: now).seed();
    final json = BackupService.encode(await BackupService.export(a, const Settings()));
    await BackupService.import(a, json);
    final before = await counts(a);
    await BackupService.import(a, json);
    expect(await counts(a), before);
    await a.close();
  });

  test('rejects files that are not exe backups, leaving data untouched', () async {
    final a = memoryDb();
    await Seeder(a, now: now).seed();
    final before = await counts(a);
    await expectLater(BackupService.import(a, 'not json'), throwsA(isA<BackupException>()));
    await expectLater(BackupService.import(a, jsonEncode({'hello': 1})), throwsA(isA<BackupException>()));
    await expectLater(
      BackupService.import(a, jsonEncode({'format': 'exe-backup', 'version': 99, 'tables': {}})),
      throwsA(isA<BackupException>()),
    );
    await expectLater(
      BackupService.import(
        a,
        jsonEncode({
          'format': 'exe-backup',
          'version': 1,
          'tables': {
            'goals': [
              {'nonsense': true},
            ],
          },
        }),
      ),
      throwsA(isA<BackupException>()),
    );
    expect(await counts(a), before);
    await a.close();
  });
}
