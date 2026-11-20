import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/enums.dart';

part 'database.g.dart';

/// Long-term goals (3–12 months). Progress is computed, never stored.
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get area => textEnum<LifeArea>()();
  TextColumn get why => text().withDefault(const Constant(''))();
  DateTimeColumn get targetDate => dateTime().nullable()();
  TextColumn get status => textEnum<GoalStatus>().withDefault(Constant(GoalStatus.active.name))();

  /// Position on the constellation canvas, remembered after a drag.
  RealColumn get posX => real().nullable()();
  RealColumn get posY => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Milestones extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get goalId => integer().references(Goals, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  DateTimeColumn get doneAt => dateTime().nullable()();
}

class WeeklyTargets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get goalId => integer().nullable().references(Goals, #id, onDelete: KeyAction.setNull)();

  /// Monday 00:00 of the week this target belongs to.
  DateTimeColumn get weekStart => dateTime()();
  TextColumn get title => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get area => textEnum<LifeArea>()();
  IntColumn get goalId => integer().nullable().references(Goals, #id, onDelete: KeyAction.setNull)();
  IntColumn get weeklyTargetId =>
      integer().nullable().references(WeeklyTargets, #id, onDelete: KeyAction.setNull)();
  IntColumn get estimatedMinutes => integer().withDefault(const Constant(25))();

  /// The tiny 5-minute starter that beats the fog.
  TextColumn get firstStep => text().nullable()();

  /// Day (00:00) the task is planned for. Null = inbox / someday.
  DateTimeColumn get scheduledDate => dateTime().nullable()();
  IntColumn get timeBlockId => integer().nullable()();
  TextColumn get status => textEnum<TaskStatus>().withDefault(Constant(TaskStatus.todo.name))();
  TextColumn get effort => textEnum<Effort>().withDefault(Constant(Effort.medium.name))();

  /// 1 = most important, 3 = nice to have.
  IntColumn get priority => integer().withDefault(const Constant(2))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get snoozedUntil => dateTime().nullable()();

  /// Daily top 3: the day it was picked for, and its rank 1–3.
  DateTimeColumn get topDate => dateTime().nullable()();
  IntColumn get topRank => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class TimeBlocks extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get endAt => dateTime()();
  IntColumn get taskId => integer().nullable().references(Tasks, #id, onDelete: KeyAction.setNull)();
  TextColumn get label => text().withDefault(const Constant(''))();
  TextColumn get type => textEnum<BlockType>()();

  /// Send the "starts in 5 minutes" alert for this block.
  BoolColumn get remind => boolean().withDefault(const Constant(true))();
}

class FocusSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().nullable().references(Tasks, #id, onDelete: KeyAction.setNull)();
  IntColumn get plannedMinutes => integer()();
  IntColumn get breakMinutes => integer().withDefault(const Constant(5))();
  IntColumn get actualSeconds => integer().withDefault(const Constant(0))();
  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get endAt => dateTime().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  /// Focus guard: optional note of what pulled attention away.
  TextColumn get distractions => text().nullable()();
}

class EnergyCheckIns extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime().unique()();
  IntColumn get energy => integer()();
  IntColumn get mood => integer()();
  TextColumn get note => text().nullable()();
}

class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get at => dateTime()();
  TextColumn get repeat => textEnum<RepeatRule>().withDefault(Constant(RepeatRule.none.name))();
  IntColumn get taskId => integer().nullable().references(Tasks, #id, onDelete: KeyAction.setNull)();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
}

class BrainDumps extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get body => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get sorted => boolean().withDefault(const Constant(false))();
}

/// Big wins ("Shipped an app to the App Store").
class Highlights extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get taskId => integer().nullable().references(Tasks, #id, onDelete: KeyAction.setNull)();
  TextColumn get note => text().nullable()();
}

@DriftDatabase(
  tables: [
    Goals,
    Milestones,
    WeeklyTargets,
    Tasks,
    TimeBlocks,
    FocusSessions,
    EnergyCheckIns,
    Reminders,
    BrainDumps,
    Highlights,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'anchor'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Every table, child tables last — used by export/import and reset.
  List<TableInfo<Table, dynamic>> get orderedTables => [
    goals,
    milestones,
    weeklyTargets,
    tasks,
    timeBlocks,
    focusSessions,
    energyCheckIns,
    reminders,
    brainDumps,
    highlights,
  ];
}
