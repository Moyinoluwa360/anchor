// Renders each main screen at iPhone size (390x844 @3x) to PNG for a visual
// check on Windows. Not part of `flutter test` (lives outside test/).
// Run:  flutter test test_screens --update-goldens   → PNGs in test_screens/out/
import 'package:anchor/app.dart';
import 'package:anchor/data/database.dart';
import 'package:anchor/data/seed.dart';
import 'package:anchor/providers/data_providers.dart';
import 'package:anchor/providers/settings.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _shoot(WidgetTester tester, String theme) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  tester.view.padding = const FakeViewPadding(top: 141, bottom: 102);
  tester.view.viewPadding = const FakeViewPadding(top: 141, bottom: 102);
  SharedPreferences.setMockInitialValues({'setting.themeMode': theme});
  final prefs = await SharedPreferences.getInstance();
  final db = AppDatabase(NativeDatabase.memory());
  await tester.runAsync(() => Seeder(db).seed());
  await tester.runAsync(() async {
    final icons = FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    // Load bundled fonts for real glyphs.
    await GoogleFonts.pendingFonts([
      GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
      GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
      GoogleFonts.inter(),
      GoogleFonts.inter(fontWeight: FontWeight.w500),
      GoogleFonts.inter(fontWeight: FontWeight.w600),
      GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w500),
      GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700),
    ]);
  });
  await tester.pumpWidget(ProviderScope(
    overrides: [prefsProvider.overrideWithValue(prefs), dbProvider.overrideWithValue(db)],
    child: const AnchorApp(),
  ));
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 100));
  }
  const tabs = ['Now', 'Today', 'Week', 'Goals', 'Done'];
  for (var i = 0; i < tabs.length; i++) {
    if (i > 0) {
      await tester.tap(find.bySemanticsLabel(tabs[i]).last);
      for (var k = 0; k < 8; k++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }
    await expectLater(find.byType(AnchorApp), matchesGoldenFile('out/${theme}_${i}_${tabs[i].toLowerCase()}.png'));
  }
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('dark', (t) => _shoot(t, 'dark'));
  testWidgets('light', (t) => _shoot(t, 'light'));
}
