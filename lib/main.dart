import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/database.dart';
import 'data/seed.dart';
import 'providers/data_providers.dart';
import 'providers/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fonts are bundled in assets/google_fonts: never fetch from the network.
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    final ofl = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], ofl);
  });

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final prefs = await SharedPreferences.getInstance();
  final db = AppDatabase();

  // Sample data on first launch only.
  final seeder = Seeder(db);
  if (!(prefs.getBool('seeded') ?? false) && await seeder.isEmpty()) {
    await seeder.seed();
  }
  await prefs.setBool('seeded', true);

  runApp(ProviderScope(
    overrides: [
      prefsProvider.overrideWithValue(prefs),
      dbProvider.overrideWithValue(db),
    ],
    child: const AnchorApp(),
  ));
}
