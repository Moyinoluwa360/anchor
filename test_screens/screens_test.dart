// ignore_for_file: invalid_use_of_visible_for_testing_member
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

Future<void> _shoot(WidgetTester tester, String theme, {bool intro = false}) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  tester.view.padding = const FakeViewPadding(top: 141, bottom: 102);
  tester.view.viewPadding = const FakeViewPadding(top: 141, bottom: 102);
  SharedPreferences.setMockInitialValues({'setting.themeMode': theme, 'setting.notificationsAsked': !intro});
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
  await tester.pumpWidget(
    ProviderScope(
      overrides: [prefsProvider.overrideWithValue(prefs), dbProvider.overrideWithValue(db)],
      child: const AnchorApp(),
    ),
  );
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 100));
  }
  Future<void> settle([int n = 8]) async {
    for (var k = 0; k < n; k++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> shot(String name) =>
      expectLater(find.byType(AnchorApp), matchesGoldenFile('out/${theme}_$name.png'));

  if (intro) {
    await settle();
    await shot('welcome_notifications');
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    return;
  }

  // Now: check-in card, then the first task card, then the running timer.
  await shot('0a_now_checkin');
  await tester.tap(find.bySemanticsLabel('Skip for now').last);
  await settle();
  await shot('0b_now_deck');
  await tester.tap(find.bySemanticsLabel(RegExp('^Start')).last);
  await settle(12);
  await shot('0c_now_timer');
  await tester.tap(find.bySemanticsLabel('Stop timer').last);
  await settle();

  const tabs = ['Today', 'Week', 'Goals', 'Done'];
  for (var i = 0; i < tabs.length; i++) {
    await tester.tap(find.bySemanticsLabel(tabs[i]).last);
    await settle();
    await shot('${i + 1}_${tabs[i].toLowerCase()}');
    if (tabs[i] == 'Today') {
      final dial = find.bySemanticsLabel(RegExp('^Day dial'));
      await tester.tap(dial.last);
      await tester.pump(const Duration(milliseconds: 60));
      await tester.tap(dial.last);
      await settle();
      await shot('1b_today_zoomed');
      await tester.tap(dial.last);
      await tester.pump(const Duration(milliseconds: 60));
      await tester.tap(dial.last);
      await settle();
      await tester.tap(find.bySemanticsLabel('Suggest a plan').last);
      await settle();
      await shot('1c_today_suggest');
      await tester.tap(find.bySemanticsLabel('Not now').last);
      await settle();
      await tester.tap(find.bySemanticsLabel('Show timeline').last);
      await settle();
      await shot('1d_today_timeline');
      await tester.tap(find.bySemanticsLabel('Show dial').last);
      await settle();
    }
  }
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('dark', (t) => _shoot(t, 'dark'));
  testWidgets('light', (t) => _shoot(t, 'light'));
  testWidgets('intro', (t) => _shoot(t, 'dark', intro: true));
}
