import 'package:exe/app.dart';
import 'package:exe/data/seed.dart';
import 'package:exe/providers/data_providers.dart';
import 'package:exe/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers.dart';

void main() {
  for (final theme in ['dark', 'light']) {
    testWidgets('every tab lays out at iPhone SE size with large text and reduced motion ($theme)', (
      tester,
    ) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      tester.view.physicalSize = const Size(750, 1334);
      tester.view.devicePixelRatio = 2;
      tester.platformDispatcher.textScaleFactorTestValue = 1.6; // clamped to 1.3 by the app
      tester.platformDispatcher.accessibilityFeaturesTestValue = FakeAccessibilityFeatures.allOn;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      SharedPreferences.setMockInitialValues({
        'setting.notificationsAsked': true,
        'setting.themeMode': theme,
      });
      final prefs = await SharedPreferences.getInstance();
      final db = memoryDb();
      await tester.runAsync(() => Seeder(db).seed());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [prefsProvider.overrideWithValue(prefs), dbProvider.overrideWithValue(db)],
          child: const ExeApp(),
        ),
      );
      Future<void> settle() async {
        for (var i = 0; i < 6; i++) {
          await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      await settle();
      for (final tab in ['Today', 'Week', 'Goals', 'Done', 'Now']) {
        await tester.tap(find.bySemanticsLabel(tab).last);
        await settle();
        expect(tester.takeException(), isNull, reason: '$tab overflowed or threw');
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  }
}
