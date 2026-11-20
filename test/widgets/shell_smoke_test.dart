import 'package:anchor/app.dart';
import 'package:anchor/data/seed.dart';
import 'package:anchor/providers/data_providers.dart';
import 'package:anchor/providers/settings.dart';
import 'package:anchor/widgets/glass_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers.dart';

void main() {
  testWidgets('shell shows five tabs and switches between them', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    // Smallest supported iPhone (SE, 375x667 pt).
    tester.view.physicalSize = const Size(750, 1334);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'setting.notificationsAsked': true});
    final prefs = await SharedPreferences.getInstance();
    final db = memoryDb();
    await tester.runAsync(() => Seeder(db).seed());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [prefsProvider.overrideWithValue(prefs), dbProvider.overrideWithValue(db)],
        child: const AnchorApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(GlassBottomBar), findsOneWidget);
    for (final label in ['Now', 'Today', 'Week', 'Goals', 'Done']) {
      expect(find.bySemanticsLabel(label), findsWidgets);
    }
    await tester.tap(find.bySemanticsLabel('Week').last);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Week'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
    // In-memory DB is dropped with the test; closing it inside the fake-async
    // zone would wait forever on drift's stream cleanup timers.
    await tester.pump(const Duration(seconds: 1));
  }, timeout: const Timeout(Duration(seconds: 90)));
}
