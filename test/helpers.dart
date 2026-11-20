import 'package:anchor/data/database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// Fresh in-memory database for each test.
AppDatabase memoryDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}
