// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LifeArea, String> area = GeneratedColumn<String>(
    'area',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<LifeArea>($GoalsTable.$converterarea);
  static const VerificationMeta _whyMeta = const VerificationMeta('why');
  @override
  late final GeneratedColumn<String> why = GeneratedColumn<String>(
    'why',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta('targetDate');
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<GoalStatus, String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(GoalStatus.active.name),
  ).withConverter<GoalStatus>($GoalsTable.$converterstatus);
  static const VerificationMeta _posXMeta = const VerificationMeta('posX');
  @override
  late final GeneratedColumn<double> posX = GeneratedColumn<double>(
    'pos_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _posYMeta = const VerificationMeta('posY');
  @override
  late final GeneratedColumn<double> posY = GeneratedColumn<double>(
    'pos_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, area, why, targetDate, status, posX, posY, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(Insertable<Goal> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('why')) {
      context.handle(_whyMeta, why.isAcceptableOrUnknown(data['why']!, _whyMeta));
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    }
    if (data.containsKey('pos_x')) {
      context.handle(_posXMeta, posX.isAcceptableOrUnknown(data['pos_x']!, _posXMeta));
    }
    if (data.containsKey('pos_y')) {
      context.handle(_posYMeta, posY.isAcceptableOrUnknown(data['pos_y']!, _posYMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      area: $GoalsTable.$converterarea.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}area'])!,
      ),
      why: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}why'])!,
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_date'],
      ),
      status: $GoalsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      ),
      posX: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}pos_x']),
      posY: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}pos_y']),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LifeArea, String, String> $converterarea = const EnumNameConverter<LifeArea>(
    LifeArea.values,
  );
  static JsonTypeConverter2<GoalStatus, String, String> $converterstatus =
      const EnumNameConverter<GoalStatus>(GoalStatus.values);
}

class Goal extends DataClass implements Insertable<Goal> {
  final int id;
  final String title;
  final LifeArea area;
  final String why;
  final DateTime? targetDate;
  final GoalStatus status;

  /// Position on the constellation canvas, remembered after a drag.
  final double? posX;
  final double? posY;
  final DateTime createdAt;
  const Goal({
    required this.id,
    required this.title,
    required this.area,
    required this.why,
    this.targetDate,
    required this.status,
    this.posX,
    this.posY,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    {
      map['area'] = Variable<String>($GoalsTable.$converterarea.toSql(area));
    }
    map['why'] = Variable<String>(why);
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<DateTime>(targetDate);
    }
    {
      map['status'] = Variable<String>($GoalsTable.$converterstatus.toSql(status));
    }
    if (!nullToAbsent || posX != null) {
      map['pos_x'] = Variable<double>(posX);
    }
    if (!nullToAbsent || posY != null) {
      map['pos_y'] = Variable<double>(posY);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      title: Value(title),
      area: Value(area),
      why: Value(why),
      targetDate: targetDate == null && nullToAbsent ? const Value.absent() : Value(targetDate),
      status: Value(status),
      posX: posX == null && nullToAbsent ? const Value.absent() : Value(posX),
      posY: posY == null && nullToAbsent ? const Value.absent() : Value(posY),
      createdAt: Value(createdAt),
    );
  }

  factory Goal.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      area: $GoalsTable.$converterarea.fromJson(serializer.fromJson<String>(json['area'])),
      why: serializer.fromJson<String>(json['why']),
      targetDate: serializer.fromJson<DateTime?>(json['targetDate']),
      status: $GoalsTable.$converterstatus.fromJson(serializer.fromJson<String>(json['status'])),
      posX: serializer.fromJson<double?>(json['posX']),
      posY: serializer.fromJson<double?>(json['posY']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'area': serializer.toJson<String>($GoalsTable.$converterarea.toJson(area)),
      'why': serializer.toJson<String>(why),
      'targetDate': serializer.toJson<DateTime?>(targetDate),
      'status': serializer.toJson<String>($GoalsTable.$converterstatus.toJson(status)),
      'posX': serializer.toJson<double?>(posX),
      'posY': serializer.toJson<double?>(posY),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Goal copyWith({
    int? id,
    String? title,
    LifeArea? area,
    String? why,
    Value<DateTime?> targetDate = const Value.absent(),
    GoalStatus? status,
    Value<double?> posX = const Value.absent(),
    Value<double?> posY = const Value.absent(),
    DateTime? createdAt,
  }) => Goal(
    id: id ?? this.id,
    title: title ?? this.title,
    area: area ?? this.area,
    why: why ?? this.why,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    status: status ?? this.status,
    posX: posX.present ? posX.value : this.posX,
    posY: posY.present ? posY.value : this.posY,
    createdAt: createdAt ?? this.createdAt,
  );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      area: data.area.present ? data.area.value : this.area,
      why: data.why.present ? data.why.value : this.why,
      targetDate: data.targetDate.present ? data.targetDate.value : this.targetDate,
      status: data.status.present ? data.status.value : this.status,
      posX: data.posX.present ? data.posX.value : this.posX,
      posY: data.posY.present ? data.posY.value : this.posY,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('area: $area, ')
          ..write('why: $why, ')
          ..write('targetDate: $targetDate, ')
          ..write('status: $status, ')
          ..write('posX: $posX, ')
          ..write('posY: $posY, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, area, why, targetDate, status, posX, posY, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.title == this.title &&
          other.area == this.area &&
          other.why == this.why &&
          other.targetDate == this.targetDate &&
          other.status == this.status &&
          other.posX == this.posX &&
          other.posY == this.posY &&
          other.createdAt == this.createdAt);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<int> id;
  final Value<String> title;
  final Value<LifeArea> area;
  final Value<String> why;
  final Value<DateTime?> targetDate;
  final Value<GoalStatus> status;
  final Value<double?> posX;
  final Value<double?> posY;
  final Value<DateTime> createdAt;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.area = const Value.absent(),
    this.why = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.status = const Value.absent(),
    this.posX = const Value.absent(),
    this.posY = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required LifeArea area,
    this.why = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.status = const Value.absent(),
    this.posX = const Value.absent(),
    this.posY = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       area = Value(area);
  static Insertable<Goal> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? area,
    Expression<String>? why,
    Expression<DateTime>? targetDate,
    Expression<String>? status,
    Expression<double>? posX,
    Expression<double>? posY,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (area != null) 'area': area,
      if (why != null) 'why': why,
      if (targetDate != null) 'target_date': targetDate,
      if (status != null) 'status': status,
      if (posX != null) 'pos_x': posX,
      if (posY != null) 'pos_y': posY,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GoalsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<LifeArea>? area,
    Value<String>? why,
    Value<DateTime?>? targetDate,
    Value<GoalStatus>? status,
    Value<double?>? posX,
    Value<double?>? posY,
    Value<DateTime>? createdAt,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      area: area ?? this.area,
      why: why ?? this.why,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (area.present) {
      map['area'] = Variable<String>($GoalsTable.$converterarea.toSql(area.value));
    }
    if (why.present) {
      map['why'] = Variable<String>(why.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>($GoalsTable.$converterstatus.toSql(status.value));
    }
    if (posX.present) {
      map['pos_x'] = Variable<double>(posX.value);
    }
    if (posY.present) {
      map['pos_y'] = Variable<double>(posY.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('area: $area, ')
          ..write('why: $why, ')
          ..write('targetDate: $targetDate, ')
          ..write('status: $status, ')
          ..write('posX: $posX, ')
          ..write('posY: $posY, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MilestonesTable extends Milestones with TableInfo<$MilestonesTable, Milestone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MilestonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<int> goalId = GeneratedColumn<int>(
    'goal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES goals (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("done" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _doneAtMeta = const VerificationMeta('doneAt');
  @override
  late final GeneratedColumn<DateTime> doneAt = GeneratedColumn<DateTime>(
    'done_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, goalId, title, dueDate, done, doneAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'milestones';
  @override
  VerificationContext validateIntegrity(Insertable<Milestone> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('goal_id')) {
      context.handle(_goalIdMeta, goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta));
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta, dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('done')) {
      context.handle(_doneMeta, done.isAcceptableOrUnknown(data['done']!, _doneMeta));
    }
    if (data.containsKey('done_at')) {
      context.handle(_doneAtMeta, doneAt.isAcceptableOrUnknown(data['done_at']!, _doneAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Milestone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Milestone(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      goalId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}goal_id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      dueDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      done: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}done'])!,
      doneAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}done_at']),
    );
  }

  @override
  $MilestonesTable createAlias(String alias) {
    return $MilestonesTable(attachedDatabase, alias);
  }
}

class Milestone extends DataClass implements Insertable<Milestone> {
  final int id;
  final int goalId;
  final String title;
  final DateTime? dueDate;
  final bool done;
  final DateTime? doneAt;
  const Milestone({
    required this.id,
    required this.goalId,
    required this.title,
    this.dueDate,
    required this.done,
    this.doneAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['goal_id'] = Variable<int>(goalId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['done'] = Variable<bool>(done);
    if (!nullToAbsent || doneAt != null) {
      map['done_at'] = Variable<DateTime>(doneAt);
    }
    return map;
  }

  MilestonesCompanion toCompanion(bool nullToAbsent) {
    return MilestonesCompanion(
      id: Value(id),
      goalId: Value(goalId),
      title: Value(title),
      dueDate: dueDate == null && nullToAbsent ? const Value.absent() : Value(dueDate),
      done: Value(done),
      doneAt: doneAt == null && nullToAbsent ? const Value.absent() : Value(doneAt),
    );
  }

  factory Milestone.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Milestone(
      id: serializer.fromJson<int>(json['id']),
      goalId: serializer.fromJson<int>(json['goalId']),
      title: serializer.fromJson<String>(json['title']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      done: serializer.fromJson<bool>(json['done']),
      doneAt: serializer.fromJson<DateTime?>(json['doneAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'goalId': serializer.toJson<int>(goalId),
      'title': serializer.toJson<String>(title),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'done': serializer.toJson<bool>(done),
      'doneAt': serializer.toJson<DateTime?>(doneAt),
    };
  }

  Milestone copyWith({
    int? id,
    int? goalId,
    String? title,
    Value<DateTime?> dueDate = const Value.absent(),
    bool? done,
    Value<DateTime?> doneAt = const Value.absent(),
  }) => Milestone(
    id: id ?? this.id,
    goalId: goalId ?? this.goalId,
    title: title ?? this.title,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    done: done ?? this.done,
    doneAt: doneAt.present ? doneAt.value : this.doneAt,
  );
  Milestone copyWithCompanion(MilestonesCompanion data) {
    return Milestone(
      id: data.id.present ? data.id.value : this.id,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      title: data.title.present ? data.title.value : this.title,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      done: data.done.present ? data.done.value : this.done,
      doneAt: data.doneAt.present ? data.doneAt.value : this.doneAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Milestone(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('title: $title, ')
          ..write('dueDate: $dueDate, ')
          ..write('done: $done, ')
          ..write('doneAt: $doneAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, goalId, title, dueDate, done, doneAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Milestone &&
          other.id == this.id &&
          other.goalId == this.goalId &&
          other.title == this.title &&
          other.dueDate == this.dueDate &&
          other.done == this.done &&
          other.doneAt == this.doneAt);
}

class MilestonesCompanion extends UpdateCompanion<Milestone> {
  final Value<int> id;
  final Value<int> goalId;
  final Value<String> title;
  final Value<DateTime?> dueDate;
  final Value<bool> done;
  final Value<DateTime?> doneAt;
  const MilestonesCompanion({
    this.id = const Value.absent(),
    this.goalId = const Value.absent(),
    this.title = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.done = const Value.absent(),
    this.doneAt = const Value.absent(),
  });
  MilestonesCompanion.insert({
    this.id = const Value.absent(),
    required int goalId,
    required String title,
    this.dueDate = const Value.absent(),
    this.done = const Value.absent(),
    this.doneAt = const Value.absent(),
  }) : goalId = Value(goalId),
       title = Value(title);
  static Insertable<Milestone> custom({
    Expression<int>? id,
    Expression<int>? goalId,
    Expression<String>? title,
    Expression<DateTime>? dueDate,
    Expression<bool>? done,
    Expression<DateTime>? doneAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goalId != null) 'goal_id': goalId,
      if (title != null) 'title': title,
      if (dueDate != null) 'due_date': dueDate,
      if (done != null) 'done': done,
      if (doneAt != null) 'done_at': doneAt,
    });
  }

  MilestonesCompanion copyWith({
    Value<int>? id,
    Value<int>? goalId,
    Value<String>? title,
    Value<DateTime?>? dueDate,
    Value<bool>? done,
    Value<DateTime?>? doneAt,
  }) {
    return MilestonesCompanion(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      done: done ?? this.done,
      doneAt: doneAt ?? this.doneAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<int>(goalId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (doneAt.present) {
      map['done_at'] = Variable<DateTime>(doneAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MilestonesCompanion(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('title: $title, ')
          ..write('dueDate: $dueDate, ')
          ..write('done: $done, ')
          ..write('doneAt: $doneAt')
          ..write(')'))
        .toString();
  }
}

class $WeeklyTargetsTable extends WeeklyTargets with TableInfo<$WeeklyTargetsTable, WeeklyTarget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeeklyTargetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<int> goalId = GeneratedColumn<int>(
    'goal_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES goals (id) ON DELETE SET NULL'),
  );
  static const VerificationMeta _weekStartMeta = const VerificationMeta('weekStart');
  @override
  late final GeneratedColumn<DateTime> weekStart = GeneratedColumn<DateTime>(
    'week_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("done" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, goalId, weekStart, title, done, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weekly_targets';
  @override
  VerificationContext validateIntegrity(Insertable<WeeklyTarget> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('goal_id')) {
      context.handle(_goalIdMeta, goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta));
    }
    if (data.containsKey('week_start')) {
      context.handle(_weekStartMeta, weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta));
    } else if (isInserting) {
      context.missing(_weekStartMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('done')) {
      context.handle(_doneMeta, done.isAcceptableOrUnknown(data['done']!, _doneMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta, sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeeklyTarget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeeklyTarget(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      goalId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}goal_id']),
      weekStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}week_start'],
      )!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      done: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}done'])!,
      sortOrder: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $WeeklyTargetsTable createAlias(String alias) {
    return $WeeklyTargetsTable(attachedDatabase, alias);
  }
}

class WeeklyTarget extends DataClass implements Insertable<WeeklyTarget> {
  final int id;
  final int? goalId;

  /// Monday 00:00 of the week this target belongs to.
  final DateTime weekStart;
  final String title;
  final bool done;
  final int sortOrder;
  const WeeklyTarget({
    required this.id,
    this.goalId,
    required this.weekStart,
    required this.title,
    required this.done,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || goalId != null) {
      map['goal_id'] = Variable<int>(goalId);
    }
    map['week_start'] = Variable<DateTime>(weekStart);
    map['title'] = Variable<String>(title);
    map['done'] = Variable<bool>(done);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  WeeklyTargetsCompanion toCompanion(bool nullToAbsent) {
    return WeeklyTargetsCompanion(
      id: Value(id),
      goalId: goalId == null && nullToAbsent ? const Value.absent() : Value(goalId),
      weekStart: Value(weekStart),
      title: Value(title),
      done: Value(done),
      sortOrder: Value(sortOrder),
    );
  }

  factory WeeklyTarget.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeeklyTarget(
      id: serializer.fromJson<int>(json['id']),
      goalId: serializer.fromJson<int?>(json['goalId']),
      weekStart: serializer.fromJson<DateTime>(json['weekStart']),
      title: serializer.fromJson<String>(json['title']),
      done: serializer.fromJson<bool>(json['done']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'goalId': serializer.toJson<int?>(goalId),
      'weekStart': serializer.toJson<DateTime>(weekStart),
      'title': serializer.toJson<String>(title),
      'done': serializer.toJson<bool>(done),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  WeeklyTarget copyWith({
    int? id,
    Value<int?> goalId = const Value.absent(),
    DateTime? weekStart,
    String? title,
    bool? done,
    int? sortOrder,
  }) => WeeklyTarget(
    id: id ?? this.id,
    goalId: goalId.present ? goalId.value : this.goalId,
    weekStart: weekStart ?? this.weekStart,
    title: title ?? this.title,
    done: done ?? this.done,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  WeeklyTarget copyWithCompanion(WeeklyTargetsCompanion data) {
    return WeeklyTarget(
      id: data.id.present ? data.id.value : this.id,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      title: data.title.present ? data.title.value : this.title,
      done: data.done.present ? data.done.value : this.done,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyTarget(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('weekStart: $weekStart, ')
          ..write('title: $title, ')
          ..write('done: $done, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, goalId, weekStart, title, done, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeeklyTarget &&
          other.id == this.id &&
          other.goalId == this.goalId &&
          other.weekStart == this.weekStart &&
          other.title == this.title &&
          other.done == this.done &&
          other.sortOrder == this.sortOrder);
}

class WeeklyTargetsCompanion extends UpdateCompanion<WeeklyTarget> {
  final Value<int> id;
  final Value<int?> goalId;
  final Value<DateTime> weekStart;
  final Value<String> title;
  final Value<bool> done;
  final Value<int> sortOrder;
  const WeeklyTargetsCompanion({
    this.id = const Value.absent(),
    this.goalId = const Value.absent(),
    this.weekStart = const Value.absent(),
    this.title = const Value.absent(),
    this.done = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  WeeklyTargetsCompanion.insert({
    this.id = const Value.absent(),
    this.goalId = const Value.absent(),
    required DateTime weekStart,
    required String title,
    this.done = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : weekStart = Value(weekStart),
       title = Value(title);
  static Insertable<WeeklyTarget> custom({
    Expression<int>? id,
    Expression<int>? goalId,
    Expression<DateTime>? weekStart,
    Expression<String>? title,
    Expression<bool>? done,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goalId != null) 'goal_id': goalId,
      if (weekStart != null) 'week_start': weekStart,
      if (title != null) 'title': title,
      if (done != null) 'done': done,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  WeeklyTargetsCompanion copyWith({
    Value<int>? id,
    Value<int?>? goalId,
    Value<DateTime>? weekStart,
    Value<String>? title,
    Value<bool>? done,
    Value<int>? sortOrder,
  }) {
    return WeeklyTargetsCompanion(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      weekStart: weekStart ?? this.weekStart,
      title: title ?? this.title,
      done: done ?? this.done,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<int>(goalId.value);
    }
    if (weekStart.present) {
      map['week_start'] = Variable<DateTime>(weekStart.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyTargetsCompanion(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('weekStart: $weekStart, ')
          ..write('title: $title, ')
          ..write('done: $done, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LifeArea, String> area = GeneratedColumn<String>(
    'area',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<LifeArea>($TasksTable.$converterarea);
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<int> goalId = GeneratedColumn<int>(
    'goal_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES goals (id) ON DELETE SET NULL'),
  );
  static const VerificationMeta _weeklyTargetIdMeta = const VerificationMeta('weeklyTargetId');
  @override
  late final GeneratedColumn<int> weeklyTargetId = GeneratedColumn<int>(
    'weekly_target_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES weekly_targets (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _estimatedMinutesMeta = const VerificationMeta('estimatedMinutes');
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
    'estimated_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(25),
  );
  static const VerificationMeta _firstStepMeta = const VerificationMeta('firstStep');
  @override
  late final GeneratedColumn<String> firstStep = GeneratedColumn<String>(
    'first_step',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduledDateMeta = const VerificationMeta('scheduledDate');
  @override
  late final GeneratedColumn<DateTime> scheduledDate = GeneratedColumn<DateTime>(
    'scheduled_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeBlockIdMeta = const VerificationMeta('timeBlockId');
  @override
  late final GeneratedColumn<int> timeBlockId = GeneratedColumn<int>(
    'time_block_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TaskStatus, String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(TaskStatus.todo.name),
  ).withConverter<TaskStatus>($TasksTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<Effort, String> effort = GeneratedColumn<String>(
    'effort',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(Effort.medium.name),
  ).withConverter<Effort>($TasksTable.$convertereffort);
  static const VerificationMeta _priorityMeta = const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snoozedUntilMeta = const VerificationMeta('snoozedUntil');
  @override
  late final GeneratedColumn<DateTime> snoozedUntil = GeneratedColumn<DateTime>(
    'snoozed_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _topDateMeta = const VerificationMeta('topDate');
  @override
  late final GeneratedColumn<DateTime> topDate = GeneratedColumn<DateTime>(
    'top_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _topRankMeta = const VerificationMeta('topRank');
  @override
  late final GeneratedColumn<int> topRank = GeneratedColumn<int>(
    'top_rank',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    area,
    goalId,
    weeklyTargetId,
    estimatedMinutes,
    firstStep,
    scheduledDate,
    timeBlockId,
    status,
    effort,
    priority,
    completedAt,
    snoozedUntil,
    topDate,
    topRank,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('goal_id')) {
      context.handle(_goalIdMeta, goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta));
    }
    if (data.containsKey('weekly_target_id')) {
      context.handle(
        _weeklyTargetIdMeta,
        weeklyTargetId.isAcceptableOrUnknown(data['weekly_target_id']!, _weeklyTargetIdMeta),
      );
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
        _estimatedMinutesMeta,
        estimatedMinutes.isAcceptableOrUnknown(data['estimated_minutes']!, _estimatedMinutesMeta),
      );
    }
    if (data.containsKey('first_step')) {
      context.handle(_firstStepMeta, firstStep.isAcceptableOrUnknown(data['first_step']!, _firstStepMeta));
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
        _scheduledDateMeta,
        scheduledDate.isAcceptableOrUnknown(data['scheduled_date']!, _scheduledDateMeta),
      );
    }
    if (data.containsKey('time_block_id')) {
      context.handle(
        _timeBlockIdMeta,
        timeBlockId.isAcceptableOrUnknown(data['time_block_id']!, _timeBlockIdMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta, priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(data['completed_at']!, _completedAtMeta),
      );
    }
    if (data.containsKey('snoozed_until')) {
      context.handle(
        _snoozedUntilMeta,
        snoozedUntil.isAcceptableOrUnknown(data['snoozed_until']!, _snoozedUntilMeta),
      );
    }
    if (data.containsKey('top_date')) {
      context.handle(_topDateMeta, topDate.isAcceptableOrUnknown(data['top_date']!, _topDateMeta));
    }
    if (data.containsKey('top_rank')) {
      context.handle(_topRankMeta, topRank.isAcceptableOrUnknown(data['top_rank']!, _topRankMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta, sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      area: $TasksTable.$converterarea.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}area'])!,
      ),
      goalId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}goal_id']),
      weeklyTargetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekly_target_id'],
      ),
      estimatedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_minutes'],
      )!,
      firstStep: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}first_step']),
      scheduledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_date'],
      ),
      timeBlockId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_block_id'],
      ),
      status: $TasksTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      ),
      effort: $TasksTable.$convertereffort.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}effort'])!,
      ),
      priority: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      snoozedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}snoozed_until'],
      ),
      topDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}top_date']),
      topRank: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}top_rank']),
      sortOrder: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LifeArea, String, String> $converterarea = const EnumNameConverter<LifeArea>(
    LifeArea.values,
  );
  static JsonTypeConverter2<TaskStatus, String, String> $converterstatus =
      const EnumNameConverter<TaskStatus>(TaskStatus.values);
  static JsonTypeConverter2<Effort, String, String> $convertereffort = const EnumNameConverter<Effort>(
    Effort.values,
  );
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final String title;
  final LifeArea area;
  final int? goalId;
  final int? weeklyTargetId;
  final int estimatedMinutes;

  /// The tiny 5-minute starter that beats the fog.
  final String? firstStep;

  /// Day (00:00) the task is planned for. Null = inbox / someday.
  final DateTime? scheduledDate;
  final int? timeBlockId;
  final TaskStatus status;
  final Effort effort;

  /// 1 = most important, 3 = nice to have.
  final int priority;
  final DateTime? completedAt;
  final DateTime? snoozedUntil;

  /// Daily top 3: the day it was picked for, and its rank 1–3.
  final DateTime? topDate;
  final int? topRank;
  final int sortOrder;
  final DateTime createdAt;
  const Task({
    required this.id,
    required this.title,
    required this.area,
    this.goalId,
    this.weeklyTargetId,
    required this.estimatedMinutes,
    this.firstStep,
    this.scheduledDate,
    this.timeBlockId,
    required this.status,
    required this.effort,
    required this.priority,
    this.completedAt,
    this.snoozedUntil,
    this.topDate,
    this.topRank,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    {
      map['area'] = Variable<String>($TasksTable.$converterarea.toSql(area));
    }
    if (!nullToAbsent || goalId != null) {
      map['goal_id'] = Variable<int>(goalId);
    }
    if (!nullToAbsent || weeklyTargetId != null) {
      map['weekly_target_id'] = Variable<int>(weeklyTargetId);
    }
    map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    if (!nullToAbsent || firstStep != null) {
      map['first_step'] = Variable<String>(firstStep);
    }
    if (!nullToAbsent || scheduledDate != null) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate);
    }
    if (!nullToAbsent || timeBlockId != null) {
      map['time_block_id'] = Variable<int>(timeBlockId);
    }
    {
      map['status'] = Variable<String>($TasksTable.$converterstatus.toSql(status));
    }
    {
      map['effort'] = Variable<String>($TasksTable.$convertereffort.toSql(effort));
    }
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || snoozedUntil != null) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil);
    }
    if (!nullToAbsent || topDate != null) {
      map['top_date'] = Variable<DateTime>(topDate);
    }
    if (!nullToAbsent || topRank != null) {
      map['top_rank'] = Variable<int>(topRank);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      area: Value(area),
      goalId: goalId == null && nullToAbsent ? const Value.absent() : Value(goalId),
      weeklyTargetId: weeklyTargetId == null && nullToAbsent ? const Value.absent() : Value(weeklyTargetId),
      estimatedMinutes: Value(estimatedMinutes),
      firstStep: firstStep == null && nullToAbsent ? const Value.absent() : Value(firstStep),
      scheduledDate: scheduledDate == null && nullToAbsent ? const Value.absent() : Value(scheduledDate),
      timeBlockId: timeBlockId == null && nullToAbsent ? const Value.absent() : Value(timeBlockId),
      status: Value(status),
      effort: Value(effort),
      priority: Value(priority),
      completedAt: completedAt == null && nullToAbsent ? const Value.absent() : Value(completedAt),
      snoozedUntil: snoozedUntil == null && nullToAbsent ? const Value.absent() : Value(snoozedUntil),
      topDate: topDate == null && nullToAbsent ? const Value.absent() : Value(topDate),
      topRank: topRank == null && nullToAbsent ? const Value.absent() : Value(topRank),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      area: $TasksTable.$converterarea.fromJson(serializer.fromJson<String>(json['area'])),
      goalId: serializer.fromJson<int?>(json['goalId']),
      weeklyTargetId: serializer.fromJson<int?>(json['weeklyTargetId']),
      estimatedMinutes: serializer.fromJson<int>(json['estimatedMinutes']),
      firstStep: serializer.fromJson<String?>(json['firstStep']),
      scheduledDate: serializer.fromJson<DateTime?>(json['scheduledDate']),
      timeBlockId: serializer.fromJson<int?>(json['timeBlockId']),
      status: $TasksTable.$converterstatus.fromJson(serializer.fromJson<String>(json['status'])),
      effort: $TasksTable.$convertereffort.fromJson(serializer.fromJson<String>(json['effort'])),
      priority: serializer.fromJson<int>(json['priority']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      snoozedUntil: serializer.fromJson<DateTime?>(json['snoozedUntil']),
      topDate: serializer.fromJson<DateTime?>(json['topDate']),
      topRank: serializer.fromJson<int?>(json['topRank']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'area': serializer.toJson<String>($TasksTable.$converterarea.toJson(area)),
      'goalId': serializer.toJson<int?>(goalId),
      'weeklyTargetId': serializer.toJson<int?>(weeklyTargetId),
      'estimatedMinutes': serializer.toJson<int>(estimatedMinutes),
      'firstStep': serializer.toJson<String?>(firstStep),
      'scheduledDate': serializer.toJson<DateTime?>(scheduledDate),
      'timeBlockId': serializer.toJson<int?>(timeBlockId),
      'status': serializer.toJson<String>($TasksTable.$converterstatus.toJson(status)),
      'effort': serializer.toJson<String>($TasksTable.$convertereffort.toJson(effort)),
      'priority': serializer.toJson<int>(priority),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'snoozedUntil': serializer.toJson<DateTime?>(snoozedUntil),
      'topDate': serializer.toJson<DateTime?>(topDate),
      'topRank': serializer.toJson<int?>(topRank),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Task copyWith({
    int? id,
    String? title,
    LifeArea? area,
    Value<int?> goalId = const Value.absent(),
    Value<int?> weeklyTargetId = const Value.absent(),
    int? estimatedMinutes,
    Value<String?> firstStep = const Value.absent(),
    Value<DateTime?> scheduledDate = const Value.absent(),
    Value<int?> timeBlockId = const Value.absent(),
    TaskStatus? status,
    Effort? effort,
    int? priority,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<DateTime?> snoozedUntil = const Value.absent(),
    Value<DateTime?> topDate = const Value.absent(),
    Value<int?> topRank = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    area: area ?? this.area,
    goalId: goalId.present ? goalId.value : this.goalId,
    weeklyTargetId: weeklyTargetId.present ? weeklyTargetId.value : this.weeklyTargetId,
    estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    firstStep: firstStep.present ? firstStep.value : this.firstStep,
    scheduledDate: scheduledDate.present ? scheduledDate.value : this.scheduledDate,
    timeBlockId: timeBlockId.present ? timeBlockId.value : this.timeBlockId,
    status: status ?? this.status,
    effort: effort ?? this.effort,
    priority: priority ?? this.priority,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    snoozedUntil: snoozedUntil.present ? snoozedUntil.value : this.snoozedUntil,
    topDate: topDate.present ? topDate.value : this.topDate,
    topRank: topRank.present ? topRank.value : this.topRank,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      area: data.area.present ? data.area.value : this.area,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      weeklyTargetId: data.weeklyTargetId.present ? data.weeklyTargetId.value : this.weeklyTargetId,
      estimatedMinutes: data.estimatedMinutes.present ? data.estimatedMinutes.value : this.estimatedMinutes,
      firstStep: data.firstStep.present ? data.firstStep.value : this.firstStep,
      scheduledDate: data.scheduledDate.present ? data.scheduledDate.value : this.scheduledDate,
      timeBlockId: data.timeBlockId.present ? data.timeBlockId.value : this.timeBlockId,
      status: data.status.present ? data.status.value : this.status,
      effort: data.effort.present ? data.effort.value : this.effort,
      priority: data.priority.present ? data.priority.value : this.priority,
      completedAt: data.completedAt.present ? data.completedAt.value : this.completedAt,
      snoozedUntil: data.snoozedUntil.present ? data.snoozedUntil.value : this.snoozedUntil,
      topDate: data.topDate.present ? data.topDate.value : this.topDate,
      topRank: data.topRank.present ? data.topRank.value : this.topRank,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('area: $area, ')
          ..write('goalId: $goalId, ')
          ..write('weeklyTargetId: $weeklyTargetId, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('firstStep: $firstStep, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('timeBlockId: $timeBlockId, ')
          ..write('status: $status, ')
          ..write('effort: $effort, ')
          ..write('priority: $priority, ')
          ..write('completedAt: $completedAt, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('topDate: $topDate, ')
          ..write('topRank: $topRank, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    area,
    goalId,
    weeklyTargetId,
    estimatedMinutes,
    firstStep,
    scheduledDate,
    timeBlockId,
    status,
    effort,
    priority,
    completedAt,
    snoozedUntil,
    topDate,
    topRank,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.area == this.area &&
          other.goalId == this.goalId &&
          other.weeklyTargetId == this.weeklyTargetId &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.firstStep == this.firstStep &&
          other.scheduledDate == this.scheduledDate &&
          other.timeBlockId == this.timeBlockId &&
          other.status == this.status &&
          other.effort == this.effort &&
          other.priority == this.priority &&
          other.completedAt == this.completedAt &&
          other.snoozedUntil == this.snoozedUntil &&
          other.topDate == this.topDate &&
          other.topRank == this.topRank &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<String> title;
  final Value<LifeArea> area;
  final Value<int?> goalId;
  final Value<int?> weeklyTargetId;
  final Value<int> estimatedMinutes;
  final Value<String?> firstStep;
  final Value<DateTime?> scheduledDate;
  final Value<int?> timeBlockId;
  final Value<TaskStatus> status;
  final Value<Effort> effort;
  final Value<int> priority;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> snoozedUntil;
  final Value<DateTime?> topDate;
  final Value<int?> topRank;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.area = const Value.absent(),
    this.goalId = const Value.absent(),
    this.weeklyTargetId = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.firstStep = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.timeBlockId = const Value.absent(),
    this.status = const Value.absent(),
    this.effort = const Value.absent(),
    this.priority = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.topDate = const Value.absent(),
    this.topRank = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required LifeArea area,
    this.goalId = const Value.absent(),
    this.weeklyTargetId = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.firstStep = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.timeBlockId = const Value.absent(),
    this.status = const Value.absent(),
    this.effort = const Value.absent(),
    this.priority = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.topDate = const Value.absent(),
    this.topRank = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       area = Value(area);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? area,
    Expression<int>? goalId,
    Expression<int>? weeklyTargetId,
    Expression<int>? estimatedMinutes,
    Expression<String>? firstStep,
    Expression<DateTime>? scheduledDate,
    Expression<int>? timeBlockId,
    Expression<String>? status,
    Expression<String>? effort,
    Expression<int>? priority,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? snoozedUntil,
    Expression<DateTime>? topDate,
    Expression<int>? topRank,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (area != null) 'area': area,
      if (goalId != null) 'goal_id': goalId,
      if (weeklyTargetId != null) 'weekly_target_id': weeklyTargetId,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (firstStep != null) 'first_step': firstStep,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (timeBlockId != null) 'time_block_id': timeBlockId,
      if (status != null) 'status': status,
      if (effort != null) 'effort': effort,
      if (priority != null) 'priority': priority,
      if (completedAt != null) 'completed_at': completedAt,
      if (snoozedUntil != null) 'snoozed_until': snoozedUntil,
      if (topDate != null) 'top_date': topDate,
      if (topRank != null) 'top_rank': topRank,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<LifeArea>? area,
    Value<int?>? goalId,
    Value<int?>? weeklyTargetId,
    Value<int>? estimatedMinutes,
    Value<String?>? firstStep,
    Value<DateTime?>? scheduledDate,
    Value<int?>? timeBlockId,
    Value<TaskStatus>? status,
    Value<Effort>? effort,
    Value<int>? priority,
    Value<DateTime?>? completedAt,
    Value<DateTime?>? snoozedUntil,
    Value<DateTime?>? topDate,
    Value<int?>? topRank,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      area: area ?? this.area,
      goalId: goalId ?? this.goalId,
      weeklyTargetId: weeklyTargetId ?? this.weeklyTargetId,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      firstStep: firstStep ?? this.firstStep,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeBlockId: timeBlockId ?? this.timeBlockId,
      status: status ?? this.status,
      effort: effort ?? this.effort,
      priority: priority ?? this.priority,
      completedAt: completedAt ?? this.completedAt,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      topDate: topDate ?? this.topDate,
      topRank: topRank ?? this.topRank,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (area.present) {
      map['area'] = Variable<String>($TasksTable.$converterarea.toSql(area.value));
    }
    if (goalId.present) {
      map['goal_id'] = Variable<int>(goalId.value);
    }
    if (weeklyTargetId.present) {
      map['weekly_target_id'] = Variable<int>(weeklyTargetId.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (firstStep.present) {
      map['first_step'] = Variable<String>(firstStep.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate.value);
    }
    if (timeBlockId.present) {
      map['time_block_id'] = Variable<int>(timeBlockId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>($TasksTable.$converterstatus.toSql(status.value));
    }
    if (effort.present) {
      map['effort'] = Variable<String>($TasksTable.$convertereffort.toSql(effort.value));
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (snoozedUntil.present) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil.value);
    }
    if (topDate.present) {
      map['top_date'] = Variable<DateTime>(topDate.value);
    }
    if (topRank.present) {
      map['top_rank'] = Variable<int>(topRank.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('area: $area, ')
          ..write('goalId: $goalId, ')
          ..write('weeklyTargetId: $weeklyTargetId, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('firstStep: $firstStep, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('timeBlockId: $timeBlockId, ')
          ..write('status: $status, ')
          ..write('effort: $effort, ')
          ..write('priority: $priority, ')
          ..write('completedAt: $completedAt, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('topDate: $topDate, ')
          ..write('topRank: $topRank, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TimeBlocksTable extends TimeBlocks with TableInfo<$TimeBlocksTable, TimeBlock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimeBlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta('startAt');
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
    'end_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES tasks (id) ON DELETE SET NULL'),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<BlockType, String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<BlockType>($TimeBlocksTable.$convertertype);
  static const VerificationMeta _remindMeta = const VerificationMeta('remind');
  @override
  late final GeneratedColumn<bool> remind = GeneratedColumn<bool>(
    'remind',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("remind" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, startAt, endAt, taskId, label, type, remind];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'time_blocks';
  @override
  VerificationContext validateIntegrity(Insertable<TimeBlock> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('start_at')) {
      context.handle(_startAtMeta, startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta));
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(_endAtMeta, endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta));
    } else if (isInserting) {
      context.missing(_endAtMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta, taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    }
    if (data.containsKey('label')) {
      context.handle(_labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('remind')) {
      context.handle(_remindMeta, remind.isAcceptableOrUnknown(data['remind']!, _remindMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimeBlock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimeBlock(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      startAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}start_at'])!,
      endAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}end_at'])!,
      taskId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}task_id']),
      label: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      type: $TimeBlocksTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      ),
      remind: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}remind'])!,
    );
  }

  @override
  $TimeBlocksTable createAlias(String alias) {
    return $TimeBlocksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BlockType, String, String> $convertertype = const EnumNameConverter<BlockType>(
    BlockType.values,
  );
}

class TimeBlock extends DataClass implements Insertable<TimeBlock> {
  final int id;
  final DateTime startAt;
  final DateTime endAt;
  final int? taskId;
  final String label;
  final BlockType type;

  /// Send the "starts in 5 minutes" alert for this block.
  final bool remind;
  const TimeBlock({
    required this.id,
    required this.startAt,
    required this.endAt,
    this.taskId,
    required this.label,
    required this.type,
    required this.remind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['start_at'] = Variable<DateTime>(startAt);
    map['end_at'] = Variable<DateTime>(endAt);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<int>(taskId);
    }
    map['label'] = Variable<String>(label);
    {
      map['type'] = Variable<String>($TimeBlocksTable.$convertertype.toSql(type));
    }
    map['remind'] = Variable<bool>(remind);
    return map;
  }

  TimeBlocksCompanion toCompanion(bool nullToAbsent) {
    return TimeBlocksCompanion(
      id: Value(id),
      startAt: Value(startAt),
      endAt: Value(endAt),
      taskId: taskId == null && nullToAbsent ? const Value.absent() : Value(taskId),
      label: Value(label),
      type: Value(type),
      remind: Value(remind),
    );
  }

  factory TimeBlock.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimeBlock(
      id: serializer.fromJson<int>(json['id']),
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      endAt: serializer.fromJson<DateTime>(json['endAt']),
      taskId: serializer.fromJson<int?>(json['taskId']),
      label: serializer.fromJson<String>(json['label']),
      type: $TimeBlocksTable.$convertertype.fromJson(serializer.fromJson<String>(json['type'])),
      remind: serializer.fromJson<bool>(json['remind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startAt': serializer.toJson<DateTime>(startAt),
      'endAt': serializer.toJson<DateTime>(endAt),
      'taskId': serializer.toJson<int?>(taskId),
      'label': serializer.toJson<String>(label),
      'type': serializer.toJson<String>($TimeBlocksTable.$convertertype.toJson(type)),
      'remind': serializer.toJson<bool>(remind),
    };
  }

  TimeBlock copyWith({
    int? id,
    DateTime? startAt,
    DateTime? endAt,
    Value<int?> taskId = const Value.absent(),
    String? label,
    BlockType? type,
    bool? remind,
  }) => TimeBlock(
    id: id ?? this.id,
    startAt: startAt ?? this.startAt,
    endAt: endAt ?? this.endAt,
    taskId: taskId.present ? taskId.value : this.taskId,
    label: label ?? this.label,
    type: type ?? this.type,
    remind: remind ?? this.remind,
  );
  TimeBlock copyWithCompanion(TimeBlocksCompanion data) {
    return TimeBlock(
      id: data.id.present ? data.id.value : this.id,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      label: data.label.present ? data.label.value : this.label,
      type: data.type.present ? data.type.value : this.type,
      remind: data.remind.present ? data.remind.value : this.remind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimeBlock(')
          ..write('id: $id, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('taskId: $taskId, ')
          ..write('label: $label, ')
          ..write('type: $type, ')
          ..write('remind: $remind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, startAt, endAt, taskId, label, type, remind);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimeBlock &&
          other.id == this.id &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.taskId == this.taskId &&
          other.label == this.label &&
          other.type == this.type &&
          other.remind == this.remind);
}

class TimeBlocksCompanion extends UpdateCompanion<TimeBlock> {
  final Value<int> id;
  final Value<DateTime> startAt;
  final Value<DateTime> endAt;
  final Value<int?> taskId;
  final Value<String> label;
  final Value<BlockType> type;
  final Value<bool> remind;
  const TimeBlocksCompanion({
    this.id = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.taskId = const Value.absent(),
    this.label = const Value.absent(),
    this.type = const Value.absent(),
    this.remind = const Value.absent(),
  });
  TimeBlocksCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startAt,
    required DateTime endAt,
    this.taskId = const Value.absent(),
    this.label = const Value.absent(),
    required BlockType type,
    this.remind = const Value.absent(),
  }) : startAt = Value(startAt),
       endAt = Value(endAt),
       type = Value(type);
  static Insertable<TimeBlock> custom({
    Expression<int>? id,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<int>? taskId,
    Expression<String>? label,
    Expression<String>? type,
    Expression<bool>? remind,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (taskId != null) 'task_id': taskId,
      if (label != null) 'label': label,
      if (type != null) 'type': type,
      if (remind != null) 'remind': remind,
    });
  }

  TimeBlocksCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startAt,
    Value<DateTime>? endAt,
    Value<int?>? taskId,
    Value<String>? label,
    Value<BlockType>? type,
    Value<bool>? remind,
  }) {
    return TimeBlocksCompanion(
      id: id ?? this.id,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      taskId: taskId ?? this.taskId,
      label: label ?? this.label,
      type: type ?? this.type,
      remind: remind ?? this.remind,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (type.present) {
      map['type'] = Variable<String>($TimeBlocksTable.$convertertype.toSql(type.value));
    }
    if (remind.present) {
      map['remind'] = Variable<bool>(remind.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimeBlocksCompanion(')
          ..write('id: $id, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('taskId: $taskId, ')
          ..write('label: $label, ')
          ..write('type: $type, ')
          ..write('remind: $remind')
          ..write(')'))
        .toString();
  }
}

class $FocusSessionsTable extends FocusSessions with TableInfo<$FocusSessionsTable, FocusSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES tasks (id) ON DELETE SET NULL'),
  );
  static const VerificationMeta _plannedMinutesMeta = const VerificationMeta('plannedMinutes');
  @override
  late final GeneratedColumn<int> plannedMinutes = GeneratedColumn<int>(
    'planned_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _breakMinutesMeta = const VerificationMeta('breakMinutes');
  @override
  late final GeneratedColumn<int> breakMinutes = GeneratedColumn<int>(
    'break_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _actualSecondsMeta = const VerificationMeta('actualSeconds');
  @override
  late final GeneratedColumn<int> actualSeconds = GeneratedColumn<int>(
    'actual_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta('startAt');
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
    'end_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta('completed');
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("completed" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _distractionsMeta = const VerificationMeta('distractions');
  @override
  late final GeneratedColumn<String> distractions = GeneratedColumn<String>(
    'distractions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    plannedMinutes,
    breakMinutes,
    actualSeconds,
    startAt,
    endAt,
    completed,
    distractions,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<FocusSession> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta, taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    }
    if (data.containsKey('planned_minutes')) {
      context.handle(
        _plannedMinutesMeta,
        plannedMinutes.isAcceptableOrUnknown(data['planned_minutes']!, _plannedMinutesMeta),
      );
    } else if (isInserting) {
      context.missing(_plannedMinutesMeta);
    }
    if (data.containsKey('break_minutes')) {
      context.handle(
        _breakMinutesMeta,
        breakMinutes.isAcceptableOrUnknown(data['break_minutes']!, _breakMinutesMeta),
      );
    }
    if (data.containsKey('actual_seconds')) {
      context.handle(
        _actualSecondsMeta,
        actualSeconds.isAcceptableOrUnknown(data['actual_seconds']!, _actualSecondsMeta),
      );
    }
    if (data.containsKey('start_at')) {
      context.handle(_startAtMeta, startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta));
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(_endAtMeta, endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta));
    }
    if (data.containsKey('completed')) {
      context.handle(_completedMeta, completed.isAcceptableOrUnknown(data['completed']!, _completedMeta));
    }
    if (data.containsKey('distractions')) {
      context.handle(
        _distractionsMeta,
        distractions.isAcceptableOrUnknown(data['distractions']!, _distractionsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FocusSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusSession(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}task_id']),
      plannedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_minutes'],
      )!,
      breakMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}break_minutes'],
      )!,
      actualSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_seconds'],
      )!,
      startAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}start_at'])!,
      endAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}end_at']),
      completed: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}completed'])!,
      distractions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}distractions'],
      ),
    );
  }

  @override
  $FocusSessionsTable createAlias(String alias) {
    return $FocusSessionsTable(attachedDatabase, alias);
  }
}

class FocusSession extends DataClass implements Insertable<FocusSession> {
  final int id;
  final int? taskId;
  final int plannedMinutes;
  final int breakMinutes;
  final int actualSeconds;
  final DateTime startAt;
  final DateTime? endAt;
  final bool completed;

  /// Focus guard: optional note of what pulled attention away.
  final String? distractions;
  const FocusSession({
    required this.id,
    this.taskId,
    required this.plannedMinutes,
    required this.breakMinutes,
    required this.actualSeconds,
    required this.startAt,
    this.endAt,
    required this.completed,
    this.distractions,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<int>(taskId);
    }
    map['planned_minutes'] = Variable<int>(plannedMinutes);
    map['break_minutes'] = Variable<int>(breakMinutes);
    map['actual_seconds'] = Variable<int>(actualSeconds);
    map['start_at'] = Variable<DateTime>(startAt);
    if (!nullToAbsent || endAt != null) {
      map['end_at'] = Variable<DateTime>(endAt);
    }
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || distractions != null) {
      map['distractions'] = Variable<String>(distractions);
    }
    return map;
  }

  FocusSessionsCompanion toCompanion(bool nullToAbsent) {
    return FocusSessionsCompanion(
      id: Value(id),
      taskId: taskId == null && nullToAbsent ? const Value.absent() : Value(taskId),
      plannedMinutes: Value(plannedMinutes),
      breakMinutes: Value(breakMinutes),
      actualSeconds: Value(actualSeconds),
      startAt: Value(startAt),
      endAt: endAt == null && nullToAbsent ? const Value.absent() : Value(endAt),
      completed: Value(completed),
      distractions: distractions == null && nullToAbsent ? const Value.absent() : Value(distractions),
    );
  }

  factory FocusSession.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusSession(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int?>(json['taskId']),
      plannedMinutes: serializer.fromJson<int>(json['plannedMinutes']),
      breakMinutes: serializer.fromJson<int>(json['breakMinutes']),
      actualSeconds: serializer.fromJson<int>(json['actualSeconds']),
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      endAt: serializer.fromJson<DateTime?>(json['endAt']),
      completed: serializer.fromJson<bool>(json['completed']),
      distractions: serializer.fromJson<String?>(json['distractions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<int?>(taskId),
      'plannedMinutes': serializer.toJson<int>(plannedMinutes),
      'breakMinutes': serializer.toJson<int>(breakMinutes),
      'actualSeconds': serializer.toJson<int>(actualSeconds),
      'startAt': serializer.toJson<DateTime>(startAt),
      'endAt': serializer.toJson<DateTime?>(endAt),
      'completed': serializer.toJson<bool>(completed),
      'distractions': serializer.toJson<String?>(distractions),
    };
  }

  FocusSession copyWith({
    int? id,
    Value<int?> taskId = const Value.absent(),
    int? plannedMinutes,
    int? breakMinutes,
    int? actualSeconds,
    DateTime? startAt,
    Value<DateTime?> endAt = const Value.absent(),
    bool? completed,
    Value<String?> distractions = const Value.absent(),
  }) => FocusSession(
    id: id ?? this.id,
    taskId: taskId.present ? taskId.value : this.taskId,
    plannedMinutes: plannedMinutes ?? this.plannedMinutes,
    breakMinutes: breakMinutes ?? this.breakMinutes,
    actualSeconds: actualSeconds ?? this.actualSeconds,
    startAt: startAt ?? this.startAt,
    endAt: endAt.present ? endAt.value : this.endAt,
    completed: completed ?? this.completed,
    distractions: distractions.present ? distractions.value : this.distractions,
  );
  FocusSession copyWithCompanion(FocusSessionsCompanion data) {
    return FocusSession(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      plannedMinutes: data.plannedMinutes.present ? data.plannedMinutes.value : this.plannedMinutes,
      breakMinutes: data.breakMinutes.present ? data.breakMinutes.value : this.breakMinutes,
      actualSeconds: data.actualSeconds.present ? data.actualSeconds.value : this.actualSeconds,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      completed: data.completed.present ? data.completed.value : this.completed,
      distractions: data.distractions.present ? data.distractions.value : this.distractions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusSession(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('plannedMinutes: $plannedMinutes, ')
          ..write('breakMinutes: $breakMinutes, ')
          ..write('actualSeconds: $actualSeconds, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('completed: $completed, ')
          ..write('distractions: $distractions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    plannedMinutes,
    breakMinutes,
    actualSeconds,
    startAt,
    endAt,
    completed,
    distractions,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusSession &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.plannedMinutes == this.plannedMinutes &&
          other.breakMinutes == this.breakMinutes &&
          other.actualSeconds == this.actualSeconds &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.completed == this.completed &&
          other.distractions == this.distractions);
}

class FocusSessionsCompanion extends UpdateCompanion<FocusSession> {
  final Value<int> id;
  final Value<int?> taskId;
  final Value<int> plannedMinutes;
  final Value<int> breakMinutes;
  final Value<int> actualSeconds;
  final Value<DateTime> startAt;
  final Value<DateTime?> endAt;
  final Value<bool> completed;
  final Value<String?> distractions;
  const FocusSessionsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.plannedMinutes = const Value.absent(),
    this.breakMinutes = const Value.absent(),
    this.actualSeconds = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.completed = const Value.absent(),
    this.distractions = const Value.absent(),
  });
  FocusSessionsCompanion.insert({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    required int plannedMinutes,
    this.breakMinutes = const Value.absent(),
    this.actualSeconds = const Value.absent(),
    required DateTime startAt,
    this.endAt = const Value.absent(),
    this.completed = const Value.absent(),
    this.distractions = const Value.absent(),
  }) : plannedMinutes = Value(plannedMinutes),
       startAt = Value(startAt);
  static Insertable<FocusSession> custom({
    Expression<int>? id,
    Expression<int>? taskId,
    Expression<int>? plannedMinutes,
    Expression<int>? breakMinutes,
    Expression<int>? actualSeconds,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<bool>? completed,
    Expression<String>? distractions,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (plannedMinutes != null) 'planned_minutes': plannedMinutes,
      if (breakMinutes != null) 'break_minutes': breakMinutes,
      if (actualSeconds != null) 'actual_seconds': actualSeconds,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (completed != null) 'completed': completed,
      if (distractions != null) 'distractions': distractions,
    });
  }

  FocusSessionsCompanion copyWith({
    Value<int>? id,
    Value<int?>? taskId,
    Value<int>? plannedMinutes,
    Value<int>? breakMinutes,
    Value<int>? actualSeconds,
    Value<DateTime>? startAt,
    Value<DateTime?>? endAt,
    Value<bool>? completed,
    Value<String?>? distractions,
  }) {
    return FocusSessionsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      plannedMinutes: plannedMinutes ?? this.plannedMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      actualSeconds: actualSeconds ?? this.actualSeconds,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      completed: completed ?? this.completed,
      distractions: distractions ?? this.distractions,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (plannedMinutes.present) {
      map['planned_minutes'] = Variable<int>(plannedMinutes.value);
    }
    if (breakMinutes.present) {
      map['break_minutes'] = Variable<int>(breakMinutes.value);
    }
    if (actualSeconds.present) {
      map['actual_seconds'] = Variable<int>(actualSeconds.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (distractions.present) {
      map['distractions'] = Variable<String>(distractions.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('plannedMinutes: $plannedMinutes, ')
          ..write('breakMinutes: $breakMinutes, ')
          ..write('actualSeconds: $actualSeconds, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('completed: $completed, ')
          ..write('distractions: $distractions')
          ..write(')'))
        .toString();
  }
}

class $EnergyCheckInsTable extends EnergyCheckIns with TableInfo<$EnergyCheckInsTable, EnergyCheckIn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnergyCheckInsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _energyMeta = const VerificationMeta('energy');
  @override
  late final GeneratedColumn<int> energy = GeneratedColumn<int>(
    'energy',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<int> mood = GeneratedColumn<int>(
    'mood',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, energy, mood, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'energy_check_ins';
  @override
  VerificationContext validateIntegrity(Insertable<EnergyCheckIn> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(_dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('energy')) {
      context.handle(_energyMeta, energy.isAcceptableOrUnknown(data['energy']!, _energyMeta));
    } else if (isInserting) {
      context.missing(_energyMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(_moodMeta, mood.isAcceptableOrUnknown(data['mood']!, _moodMeta));
    } else if (isInserting) {
      context.missing(_moodMeta);
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnergyCheckIn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnergyCheckIn(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      energy: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}energy'])!,
      mood: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}mood'])!,
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $EnergyCheckInsTable createAlias(String alias) {
    return $EnergyCheckInsTable(attachedDatabase, alias);
  }
}

class EnergyCheckIn extends DataClass implements Insertable<EnergyCheckIn> {
  final int id;
  final DateTime date;
  final int energy;
  final int mood;
  final String? note;
  const EnergyCheckIn({
    required this.id,
    required this.date,
    required this.energy,
    required this.mood,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['energy'] = Variable<int>(energy);
    map['mood'] = Variable<int>(mood);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  EnergyCheckInsCompanion toCompanion(bool nullToAbsent) {
    return EnergyCheckInsCompanion(
      id: Value(id),
      date: Value(date),
      energy: Value(energy),
      mood: Value(mood),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory EnergyCheckIn.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnergyCheckIn(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      energy: serializer.fromJson<int>(json['energy']),
      mood: serializer.fromJson<int>(json['mood']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'energy': serializer.toJson<int>(energy),
      'mood': serializer.toJson<int>(mood),
      'note': serializer.toJson<String?>(note),
    };
  }

  EnergyCheckIn copyWith({
    int? id,
    DateTime? date,
    int? energy,
    int? mood,
    Value<String?> note = const Value.absent(),
  }) => EnergyCheckIn(
    id: id ?? this.id,
    date: date ?? this.date,
    energy: energy ?? this.energy,
    mood: mood ?? this.mood,
    note: note.present ? note.value : this.note,
  );
  EnergyCheckIn copyWithCompanion(EnergyCheckInsCompanion data) {
    return EnergyCheckIn(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      energy: data.energy.present ? data.energy.value : this.energy,
      mood: data.mood.present ? data.mood.value : this.mood,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnergyCheckIn(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('energy: $energy, ')
          ..write('mood: $mood, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, energy, mood, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnergyCheckIn &&
          other.id == this.id &&
          other.date == this.date &&
          other.energy == this.energy &&
          other.mood == this.mood &&
          other.note == this.note);
}

class EnergyCheckInsCompanion extends UpdateCompanion<EnergyCheckIn> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> energy;
  final Value<int> mood;
  final Value<String?> note;
  const EnergyCheckInsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.energy = const Value.absent(),
    this.mood = const Value.absent(),
    this.note = const Value.absent(),
  });
  EnergyCheckInsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int energy,
    required int mood,
    this.note = const Value.absent(),
  }) : date = Value(date),
       energy = Value(energy),
       mood = Value(mood);
  static Insertable<EnergyCheckIn> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? energy,
    Expression<int>? mood,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (energy != null) 'energy': energy,
      if (mood != null) 'mood': mood,
      if (note != null) 'note': note,
    });
  }

  EnergyCheckInsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int>? energy,
    Value<int>? mood,
    Value<String?>? note,
  }) {
    return EnergyCheckInsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      energy: energy ?? this.energy,
      mood: mood ?? this.mood,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (energy.present) {
      map['energy'] = Variable<int>(energy.value);
    }
    if (mood.present) {
      map['mood'] = Variable<int>(mood.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnergyCheckInsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('energy: $energy, ')
          ..write('mood: $mood, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RepeatRule, String> repeat = GeneratedColumn<String>(
    'repeat',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(RepeatRule.none.name),
  ).withConverter<RepeatRule>($RemindersTable.$converterrepeat);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES tasks (id) ON DELETE SET NULL'),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, at, repeat, taskId, enabled];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(Insertable<Reminder> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta, taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta, enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      at: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}at'])!,
      repeat: $RemindersTable.$converterrepeat.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}repeat'])!,
      ),
      taskId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}task_id']),
      enabled: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RepeatRule, String, String> $converterrepeat =
      const EnumNameConverter<RepeatRule>(RepeatRule.values);
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final int id;
  final String title;
  final DateTime at;
  final RepeatRule repeat;
  final int? taskId;
  final bool enabled;
  const Reminder({
    required this.id,
    required this.title,
    required this.at,
    required this.repeat,
    this.taskId,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['at'] = Variable<DateTime>(at);
    {
      map['repeat'] = Variable<String>($RemindersTable.$converterrepeat.toSql(repeat));
    }
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<int>(taskId);
    }
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      title: Value(title),
      at: Value(at),
      repeat: Value(repeat),
      taskId: taskId == null && nullToAbsent ? const Value.absent() : Value(taskId),
      enabled: Value(enabled),
    );
  }

  factory Reminder.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      at: serializer.fromJson<DateTime>(json['at']),
      repeat: $RemindersTable.$converterrepeat.fromJson(serializer.fromJson<String>(json['repeat'])),
      taskId: serializer.fromJson<int?>(json['taskId']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'at': serializer.toJson<DateTime>(at),
      'repeat': serializer.toJson<String>($RemindersTable.$converterrepeat.toJson(repeat)),
      'taskId': serializer.toJson<int?>(taskId),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  Reminder copyWith({
    int? id,
    String? title,
    DateTime? at,
    RepeatRule? repeat,
    Value<int?> taskId = const Value.absent(),
    bool? enabled,
  }) => Reminder(
    id: id ?? this.id,
    title: title ?? this.title,
    at: at ?? this.at,
    repeat: repeat ?? this.repeat,
    taskId: taskId.present ? taskId.value : this.taskId,
    enabled: enabled ?? this.enabled,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      at: data.at.present ? data.at.value : this.at,
      repeat: data.repeat.present ? data.repeat.value : this.repeat,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('at: $at, ')
          ..write('repeat: $repeat, ')
          ..write('taskId: $taskId, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, at, repeat, taskId, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.title == this.title &&
          other.at == this.at &&
          other.repeat == this.repeat &&
          other.taskId == this.taskId &&
          other.enabled == this.enabled);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<int> id;
  final Value<String> title;
  final Value<DateTime> at;
  final Value<RepeatRule> repeat;
  final Value<int?> taskId;
  final Value<bool> enabled;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.at = const Value.absent(),
    this.repeat = const Value.absent(),
    this.taskId = const Value.absent(),
    this.enabled = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required DateTime at,
    this.repeat = const Value.absent(),
    this.taskId = const Value.absent(),
    this.enabled = const Value.absent(),
  }) : title = Value(title),
       at = Value(at);
  static Insertable<Reminder> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<DateTime>? at,
    Expression<String>? repeat,
    Expression<int>? taskId,
    Expression<bool>? enabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (at != null) 'at': at,
      if (repeat != null) 'repeat': repeat,
      if (taskId != null) 'task_id': taskId,
      if (enabled != null) 'enabled': enabled,
    });
  }

  RemindersCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<DateTime>? at,
    Value<RepeatRule>? repeat,
    Value<int?>? taskId,
    Value<bool>? enabled,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      at: at ?? this.at,
      repeat: repeat ?? this.repeat,
      taskId: taskId ?? this.taskId,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (repeat.present) {
      map['repeat'] = Variable<String>($RemindersTable.$converterrepeat.toSql(repeat.value));
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('at: $at, ')
          ..write('repeat: $repeat, ')
          ..write('taskId: $taskId, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }
}

class $BrainDumpsTable extends BrainDumps with TableInfo<$BrainDumpsTable, BrainDump> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BrainDumpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _sortedMeta = const VerificationMeta('sorted');
  @override
  late final GeneratedColumn<bool> sorted = GeneratedColumn<bool>(
    'sorted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("sorted" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, body, createdAt, sorted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'brain_dumps';
  @override
  VerificationContext validateIntegrity(Insertable<BrainDump> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('body')) {
      context.handle(_bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('sorted')) {
      context.handle(_sortedMeta, sorted.isAcceptableOrUnknown(data['sorted']!, _sortedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BrainDump map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BrainDump(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      body: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      sorted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}sorted'])!,
    );
  }

  @override
  $BrainDumpsTable createAlias(String alias) {
    return $BrainDumpsTable(attachedDatabase, alias);
  }
}

class BrainDump extends DataClass implements Insertable<BrainDump> {
  final int id;
  final String body;
  final DateTime createdAt;
  final bool sorted;
  const BrainDump({required this.id, required this.body, required this.createdAt, required this.sorted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sorted'] = Variable<bool>(sorted);
    return map;
  }

  BrainDumpsCompanion toCompanion(bool nullToAbsent) {
    return BrainDumpsCompanion(
      id: Value(id),
      body: Value(body),
      createdAt: Value(createdAt),
      sorted: Value(sorted),
    );
  }

  factory BrainDump.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BrainDump(
      id: serializer.fromJson<int>(json['id']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      sorted: serializer.fromJson<bool>(json['sorted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'sorted': serializer.toJson<bool>(sorted),
    };
  }

  BrainDump copyWith({int? id, String? body, DateTime? createdAt, bool? sorted}) => BrainDump(
    id: id ?? this.id,
    body: body ?? this.body,
    createdAt: createdAt ?? this.createdAt,
    sorted: sorted ?? this.sorted,
  );
  BrainDump copyWithCompanion(BrainDumpsCompanion data) {
    return BrainDump(
      id: data.id.present ? data.id.value : this.id,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sorted: data.sorted.present ? data.sorted.value : this.sorted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BrainDump(')
          ..write('id: $id, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('sorted: $sorted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, body, createdAt, sorted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BrainDump &&
          other.id == this.id &&
          other.body == this.body &&
          other.createdAt == this.createdAt &&
          other.sorted == this.sorted);
}

class BrainDumpsCompanion extends UpdateCompanion<BrainDump> {
  final Value<int> id;
  final Value<String> body;
  final Value<DateTime> createdAt;
  final Value<bool> sorted;
  const BrainDumpsCompanion({
    this.id = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sorted = const Value.absent(),
  });
  BrainDumpsCompanion.insert({
    this.id = const Value.absent(),
    required String body,
    this.createdAt = const Value.absent(),
    this.sorted = const Value.absent(),
  }) : body = Value(body);
  static Insertable<BrainDump> custom({
    Expression<int>? id,
    Expression<String>? body,
    Expression<DateTime>? createdAt,
    Expression<bool>? sorted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (sorted != null) 'sorted': sorted,
    });
  }

  BrainDumpsCompanion copyWith({
    Value<int>? id,
    Value<String>? body,
    Value<DateTime>? createdAt,
    Value<bool>? sorted,
  }) {
    return BrainDumpsCompanion(
      id: id ?? this.id,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      sorted: sorted ?? this.sorted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (sorted.present) {
      map['sorted'] = Variable<bool>(sorted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BrainDumpsCompanion(')
          ..write('id: $id, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('sorted: $sorted')
          ..write(')'))
        .toString();
  }
}

class $HighlightsTable extends Highlights with TableInfo<$HighlightsTable, Highlight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HighlightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES tasks (id) ON DELETE SET NULL'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, date, taskId, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'highlights';
  @override
  VerificationContext validateIntegrity(Insertable<Highlight> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(_dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta, taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Highlight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Highlight(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      date: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      taskId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}task_id']),
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $HighlightsTable createAlias(String alias) {
    return $HighlightsTable(attachedDatabase, alias);
  }
}

class Highlight extends DataClass implements Insertable<Highlight> {
  final int id;
  final String title;
  final DateTime date;
  final int? taskId;
  final String? note;
  const Highlight({required this.id, required this.title, required this.date, this.taskId, this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<int>(taskId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  HighlightsCompanion toCompanion(bool nullToAbsent) {
    return HighlightsCompanion(
      id: Value(id),
      title: Value(title),
      date: Value(date),
      taskId: taskId == null && nullToAbsent ? const Value.absent() : Value(taskId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Highlight.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Highlight(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<DateTime>(json['date']),
      taskId: serializer.fromJson<int?>(json['taskId']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<DateTime>(date),
      'taskId': serializer.toJson<int?>(taskId),
      'note': serializer.toJson<String?>(note),
    };
  }

  Highlight copyWith({
    int? id,
    String? title,
    DateTime? date,
    Value<int?> taskId = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => Highlight(
    id: id ?? this.id,
    title: title ?? this.title,
    date: date ?? this.date,
    taskId: taskId.present ? taskId.value : this.taskId,
    note: note.present ? note.value : this.note,
  );
  Highlight copyWithCompanion(HighlightsCompanion data) {
    return Highlight(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Highlight(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('taskId: $taskId, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, date, taskId, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Highlight &&
          other.id == this.id &&
          other.title == this.title &&
          other.date == this.date &&
          other.taskId == this.taskId &&
          other.note == this.note);
}

class HighlightsCompanion extends UpdateCompanion<Highlight> {
  final Value<int> id;
  final Value<String> title;
  final Value<DateTime> date;
  final Value<int?> taskId;
  final Value<String?> note;
  const HighlightsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.taskId = const Value.absent(),
    this.note = const Value.absent(),
  });
  HighlightsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required DateTime date,
    this.taskId = const Value.absent(),
    this.note = const Value.absent(),
  }) : title = Value(title),
       date = Value(date);
  static Insertable<Highlight> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<DateTime>? date,
    Expression<int>? taskId,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (taskId != null) 'task_id': taskId,
      if (note != null) 'note': note,
    });
  }

  HighlightsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<DateTime>? date,
    Value<int?>? taskId,
    Value<String?>? note,
  }) {
    return HighlightsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      taskId: taskId ?? this.taskId,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HighlightsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('taskId: $taskId, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $MilestonesTable milestones = $MilestonesTable(this);
  late final $WeeklyTargetsTable weeklyTargets = $WeeklyTargetsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $TimeBlocksTable timeBlocks = $TimeBlocksTable(this);
  late final $FocusSessionsTable focusSessions = $FocusSessionsTable(this);
  late final $EnergyCheckInsTable energyCheckIns = $EnergyCheckInsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $BrainDumpsTable brainDumps = $BrainDumpsTable(this);
  late final $HighlightsTable highlights = $HighlightsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
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
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName('goals', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('milestones', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('goals', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('weekly_targets', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('goals', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('tasks', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('weekly_targets', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('tasks', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('tasks', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('time_blocks', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('tasks', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('focus_sessions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('tasks', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('reminders', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('tasks', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('highlights', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$GoalsTableCreateCompanionBuilder = GoalsCompanion Function({
  Value<int> id,
  required String title,
  required LifeArea area,
  Value<String> why,
  Value<DateTime?> targetDate,
  Value<GoalStatus> status,
  Value<double?> posX,
  Value<double?> posY,
  Value<DateTime> createdAt,
});
typedef $$GoalsTableUpdateCompanionBuilder = GoalsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<LifeArea> area,
  Value<String> why,
  Value<DateTime?> targetDate,
  Value<GoalStatus> status,
  Value<double?> posX,
  Value<double?> posY,
  Value<DateTime> createdAt,
});

final class $$GoalsTableReferences extends BaseReferences<_$AppDatabase, $GoalsTable, Goal> {
  $$GoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MilestonesTable, List<Milestone>> _milestonesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.milestones, aliasName: 'goals__id__milestones__goal_id');

  $$MilestonesTableProcessedTableManager get milestonesRefs {
    final manager = $$MilestonesTableTableManager(
      $_db,
      $_db.milestones,
    ).filter((f) => f.goalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_milestonesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$WeeklyTargetsTable, List<WeeklyTarget>> _weeklyTargetsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(db.weeklyTargets, aliasName: 'goals__id__weekly_targets__goal_id');

  $$WeeklyTargetsTableProcessedTableManager get weeklyTargetsRefs {
    final manager = $$WeeklyTargetsTableTableManager(
      $_db,
      $_db.weeklyTargets,
    ).filter((f) => f.goalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_weeklyTargetsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tasks, aliasName: 'goals__id__tasks__goal_id');

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.goalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<LifeArea, LifeArea, String> get area =>
      $composableBuilder(column: $table.area, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get why =>
      $composableBuilder(column: $table.why, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get targetDate =>
      $composableBuilder(column: $table.targetDate, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<GoalStatus, GoalStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get posX =>
      $composableBuilder(column: $table.posX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get posY =>
      $composableBuilder(column: $table.posY, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> milestonesRefs(Expression<bool> Function($$MilestonesTableFilterComposer f) f) {
    final $$MilestonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.goalId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MilestonesTableFilterComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> weeklyTargetsRefs(Expression<bool> Function($$WeeklyTargetsTableFilterComposer f) f) {
    final $$WeeklyTargetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weeklyTargets,
      getReferencedColumn: (t) => t.goalId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$WeeklyTargetsTableFilterComposer(
            $db: $db,
            $table: $db.weeklyTargets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tasksRefs(Expression<bool> Function($$TasksTableFilterComposer f) f) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.goalId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalsTableOrderingComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get area =>
      $composableBuilder(column: $table.area, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get why =>
      $composableBuilder(column: $table.why, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get targetDate =>
      $composableBuilder(column: $table.targetDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get posX =>
      $composableBuilder(column: $table.posX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get posY =>
      $composableBuilder(column: $table.posY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$GoalsTableAnnotationComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LifeArea, String> get area =>
      $composableBuilder(column: $table.area, builder: (column) => column);

  GeneratedColumn<String> get why => $composableBuilder(column: $table.why, builder: (column) => column);

  GeneratedColumn<DateTime> get targetDate =>
      $composableBuilder(column: $table.targetDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GoalStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get posX => $composableBuilder(column: $table.posX, builder: (column) => column);

  GeneratedColumn<double> get posY => $composableBuilder(column: $table.posY, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> milestonesRefs<T extends Object>(
    Expression<T> Function($$MilestonesTableAnnotationComposer a) f,
  ) {
    final $$MilestonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.goalId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MilestonesTableAnnotationComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> weeklyTargetsRefs<T extends Object>(
    Expression<T> Function($$WeeklyTargetsTableAnnotationComposer a) f,
  ) {
    final $$WeeklyTargetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.weeklyTargets,
      getReferencedColumn: (t) => t.goalId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$WeeklyTargetsTableAnnotationComposer(
            $db: $db,
            $table: $db.weeklyTargets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tasksRefs<T extends Object>(Expression<T> Function($$TasksTableAnnotationComposer a) f) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.goalId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          Goal,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (Goal, $$GoalsTableReferences),
          Goal,
          PrefetchHooks Function({bool milestonesRefs, bool weeklyTargetsRefs, bool tasksRefs})
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<LifeArea> area = const Value.absent(),
                Value<String> why = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<GoalStatus> status = const Value.absent(),
                Value<double?> posX = const Value.absent(),
                Value<double?> posY = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                title: title,
                area: area,
                why: why,
                targetDate: targetDate,
                status: status,
                posX: posX,
                posY: posY,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required LifeArea area,
                Value<String> why = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<GoalStatus> status = const Value.absent(),
                Value<double?> posX = const Value.absent(),
                Value<double?> posY = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                title: title,
                area: area,
                why: why,
                targetDate: targetDate,
                status: status,
                posX: posX,
                posY: posY,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable<$GoalsTable, Goal>(table), $$GoalsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({milestonesRefs = false, weeklyTargetsRefs = false, tasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (milestonesRefs) db.milestones,
                if (weeklyTargetsRefs) db.weeklyTargets,
                if (tasksRefs) db.tasks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (milestonesRefs)
                    await $_getPrefetchedDataByColumns<Goal, $GoalsTable, Milestone, $MilestonesTable>(
                      currentTable: table,
                      referencedTable: $$GoalsTableReferences._milestonesRefsTable(db),
                      managerFromTypedResult: (p0) => $$GoalsTableReferences(db, table, p0).milestonesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'goal_id',
                      typedResults: items,
                    ),
                  if (weeklyTargetsRefs)
                    await $_getPrefetchedDataByColumns<Goal, $GoalsTable, WeeklyTarget, $WeeklyTargetsTable>(
                      currentTable: table,
                      referencedTable: $$GoalsTableReferences._weeklyTargetsRefsTable(db),
                      managerFromTypedResult: (p0) => $$GoalsTableReferences(db, table, p0).weeklyTargetsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'goal_id',
                      typedResults: items,
                    ),
                  if (tasksRefs)
                    await $_getPrefetchedDataByColumns<Goal, $GoalsTable, Task, $TasksTable>(
                      currentTable: table,
                      referencedTable: $$GoalsTableReferences._tasksRefsTable(db),
                      managerFromTypedResult: (p0) => $$GoalsTableReferences(db, table, p0).tasksRefs,
                      currentColumn: 'id',
                      referencedColumn: 'goal_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      Goal,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (Goal, $$GoalsTableReferences),
      Goal,
      PrefetchHooks Function({bool milestonesRefs, bool weeklyTargetsRefs, bool tasksRefs})
    >;
typedef $$MilestonesTableCreateCompanionBuilder = MilestonesCompanion Function({
  Value<int> id,
  required int goalId,
  required String title,
  Value<DateTime?> dueDate,
  Value<bool> done,
  Value<DateTime?> doneAt,
});
typedef $$MilestonesTableUpdateCompanionBuilder = MilestonesCompanion Function({
  Value<int> id,
  Value<int> goalId,
  Value<String> title,
  Value<DateTime?> dueDate,
  Value<bool> done,
  Value<DateTime?> doneAt,
});

final class $$MilestonesTableReferences extends BaseReferences<_$AppDatabase, $MilestonesTable, Milestone> {
  $$MilestonesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GoalsTable _goalIdTable(_$AppDatabase db) => db.goals.createAlias('milestones__goal_id__goals__id');

  $$GoalsTableProcessedTableManager get goalId {
    final $_column = $_itemColumn<int>('goal_id')!;

    final manager = $$GoalsTableTableManager($_db, $_db.goals).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MilestonesTableFilterComposer extends Composer<_$AppDatabase, $MilestonesTable> {
  $$MilestonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => ColumnFilters(column));

  $$GoalsTableFilterComposer get goalId {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$GoalsTableFilterComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MilestonesTableOrderingComposer extends Composer<_$AppDatabase, $MilestonesTable> {
  $$MilestonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => ColumnOrderings(column));

  $$GoalsTableOrderingComposer get goalId {
    final $$GoalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$GoalsTableOrderingComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MilestonesTableAnnotationComposer extends Composer<_$AppDatabase, $MilestonesTable> {
  $$MilestonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<bool> get done => $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<DateTime> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => column);

  $$GoalsTableAnnotationComposer get goalId {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$GoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MilestonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MilestonesTable,
          Milestone,
          $$MilestonesTableFilterComposer,
          $$MilestonesTableOrderingComposer,
          $$MilestonesTableAnnotationComposer,
          $$MilestonesTableCreateCompanionBuilder,
          $$MilestonesTableUpdateCompanionBuilder,
          (Milestone, $$MilestonesTableReferences),
          Milestone,
          PrefetchHooks Function({bool goalId})
        > {
  $$MilestonesTableTableManager(_$AppDatabase db, $MilestonesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MilestonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MilestonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$MilestonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> goalId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<DateTime?> doneAt = const Value.absent(),
              }) => MilestonesCompanion(
                id: id,
                goalId: goalId,
                title: title,
                dueDate: dueDate,
                done: done,
                doneAt: doneAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int goalId,
                required String title,
                Value<DateTime?> dueDate = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<DateTime?> doneAt = const Value.absent(),
              }) => MilestonesCompanion.insert(
                id: id,
                goalId: goalId,
                title: title,
                dueDate: dueDate,
                done: done,
                doneAt: doneAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MilestonesTable, Milestone>(table),
                  $$MilestonesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({goalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (goalId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.goalId,
                        referencedTable: $$MilestonesTableReferences._goalIdTable(db),
                        referencedColumn: $$MilestonesTableReferences._goalIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MilestonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MilestonesTable,
      Milestone,
      $$MilestonesTableFilterComposer,
      $$MilestonesTableOrderingComposer,
      $$MilestonesTableAnnotationComposer,
      $$MilestonesTableCreateCompanionBuilder,
      $$MilestonesTableUpdateCompanionBuilder,
      (Milestone, $$MilestonesTableReferences),
      Milestone,
      PrefetchHooks Function({bool goalId})
    >;
typedef $$WeeklyTargetsTableCreateCompanionBuilder = WeeklyTargetsCompanion Function({
  Value<int> id,
  Value<int?> goalId,
  required DateTime weekStart,
  required String title,
  Value<bool> done,
  Value<int> sortOrder,
});
typedef $$WeeklyTargetsTableUpdateCompanionBuilder = WeeklyTargetsCompanion Function({
  Value<int> id,
  Value<int?> goalId,
  Value<DateTime> weekStart,
  Value<String> title,
  Value<bool> done,
  Value<int> sortOrder,
});

final class $$WeeklyTargetsTableReferences
    extends BaseReferences<_$AppDatabase, $WeeklyTargetsTable, WeeklyTarget> {
  $$WeeklyTargetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GoalsTable _goalIdTable(_$AppDatabase db) =>
      db.goals.createAlias('weekly_targets__goal_id__goals__id');

  $$GoalsTableProcessedTableManager? get goalId {
    final $_column = $_itemColumn<int>('goal_id');
    if ($_column == null) return null;
    final manager = $$GoalsTableTableManager($_db, $_db.goals).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tasks, aliasName: 'weekly_targets__id__tasks__weekly_target_id');

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.weeklyTargetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WeeklyTargetsTableFilterComposer extends Composer<_$AppDatabase, $WeeklyTargetsTable> {
  $$WeeklyTargetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  $$GoalsTableFilterComposer get goalId {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$GoalsTableFilterComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> tasksRefs(Expression<bool> Function($$TasksTableFilterComposer f) f) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.weeklyTargetId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WeeklyTargetsTableOrderingComposer extends Composer<_$AppDatabase, $WeeklyTargetsTable> {
  $$WeeklyTargetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  $$GoalsTableOrderingComposer get goalId {
    final $$GoalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$GoalsTableOrderingComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WeeklyTargetsTableAnnotationComposer extends Composer<_$AppDatabase, $WeeklyTargetsTable> {
  $$WeeklyTargetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get done => $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$GoalsTableAnnotationComposer get goalId {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$GoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> tasksRefs<T extends Object>(Expression<T> Function($$TasksTableAnnotationComposer a) f) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.weeklyTargetId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WeeklyTargetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeeklyTargetsTable,
          WeeklyTarget,
          $$WeeklyTargetsTableFilterComposer,
          $$WeeklyTargetsTableOrderingComposer,
          $$WeeklyTargetsTableAnnotationComposer,
          $$WeeklyTargetsTableCreateCompanionBuilder,
          $$WeeklyTargetsTableUpdateCompanionBuilder,
          (WeeklyTarget, $$WeeklyTargetsTableReferences),
          WeeklyTarget,
          PrefetchHooks Function({bool goalId, bool tasksRefs})
        > {
  $$WeeklyTargetsTableTableManager(_$AppDatabase db, $WeeklyTargetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$WeeklyTargetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$WeeklyTargetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$WeeklyTargetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> goalId = const Value.absent(),
                Value<DateTime> weekStart = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => WeeklyTargetsCompanion(
                id: id,
                goalId: goalId,
                weekStart: weekStart,
                title: title,
                done: done,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> goalId = const Value.absent(),
                required DateTime weekStart,
                required String title,
                Value<bool> done = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => WeeklyTargetsCompanion.insert(
                id: id,
                goalId: goalId,
                weekStart: weekStart,
                title: title,
                done: done,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WeeklyTargetsTable, WeeklyTarget>(table),
                  $$WeeklyTargetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({goalId = false, tasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tasksRefs) db.tasks],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (goalId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.goalId,
                        referencedTable: $$WeeklyTargetsTableReferences._goalIdTable(db),
                        referencedColumn: $$WeeklyTargetsTableReferences._goalIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tasksRefs)
                    await $_getPrefetchedDataByColumns<WeeklyTarget, $WeeklyTargetsTable, Task, $TasksTable>(
                      currentTable: table,
                      referencedTable: $$WeeklyTargetsTableReferences._tasksRefsTable(db),
                      managerFromTypedResult: (p0) => $$WeeklyTargetsTableReferences(db, table, p0).tasksRefs,
                      currentColumn: 'id',
                      referencedColumn: 'weekly_target_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WeeklyTargetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeeklyTargetsTable,
      WeeklyTarget,
      $$WeeklyTargetsTableFilterComposer,
      $$WeeklyTargetsTableOrderingComposer,
      $$WeeklyTargetsTableAnnotationComposer,
      $$WeeklyTargetsTableCreateCompanionBuilder,
      $$WeeklyTargetsTableUpdateCompanionBuilder,
      (WeeklyTarget, $$WeeklyTargetsTableReferences),
      WeeklyTarget,
      PrefetchHooks Function({bool goalId, bool tasksRefs})
    >;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  required String title,
  required LifeArea area,
  Value<int?> goalId,
  Value<int?> weeklyTargetId,
  Value<int> estimatedMinutes,
  Value<String?> firstStep,
  Value<DateTime?> scheduledDate,
  Value<int?> timeBlockId,
  Value<TaskStatus> status,
  Value<Effort> effort,
  Value<int> priority,
  Value<DateTime?> completedAt,
  Value<DateTime?> snoozedUntil,
  Value<DateTime?> topDate,
  Value<int?> topRank,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<LifeArea> area,
  Value<int?> goalId,
  Value<int?> weeklyTargetId,
  Value<int> estimatedMinutes,
  Value<String?> firstStep,
  Value<DateTime?> scheduledDate,
  Value<int?> timeBlockId,
  Value<TaskStatus> status,
  Value<Effort> effort,
  Value<int> priority,
  Value<DateTime?> completedAt,
  Value<DateTime?> snoozedUntil,
  Value<DateTime?> topDate,
  Value<int?> topRank,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
});

final class $$TasksTableReferences extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GoalsTable _goalIdTable(_$AppDatabase db) => db.goals.createAlias('tasks__goal_id__goals__id');

  $$GoalsTableProcessedTableManager? get goalId {
    final $_column = $_itemColumn<int>('goal_id');
    if ($_column == null) return null;
    final manager = $$GoalsTableTableManager($_db, $_db.goals).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $WeeklyTargetsTable _weeklyTargetIdTable(_$AppDatabase db) =>
      db.weeklyTargets.createAlias('tasks__weekly_target_id__weekly_targets__id');

  $$WeeklyTargetsTableProcessedTableManager? get weeklyTargetId {
    final $_column = $_itemColumn<int>('weekly_target_id');
    if ($_column == null) return null;
    final manager = $$WeeklyTargetsTableTableManager(
      $_db,
      $_db.weeklyTargets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_weeklyTargetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TimeBlocksTable, List<TimeBlock>> _timeBlocksRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.timeBlocks, aliasName: 'tasks__id__time_blocks__task_id');

  $$TimeBlocksTableProcessedTableManager get timeBlocksRefs {
    final manager = $$TimeBlocksTableTableManager(
      $_db,
      $_db.timeBlocks,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_timeBlocksRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$FocusSessionsTable, List<FocusSession>> _focusSessionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(db.focusSessions, aliasName: 'tasks__id__focus_sessions__task_id');

  $$FocusSessionsTableProcessedTableManager get focusSessionsRefs {
    final manager = $$FocusSessionsTableTableManager(
      $_db,
      $_db.focusSessions,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_focusSessionsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RemindersTable, List<Reminder>> _remindersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.reminders, aliasName: 'tasks__id__reminders__task_id');

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$HighlightsTable, List<Highlight>> _highlightsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.highlights, aliasName: 'tasks__id__highlights__task_id');

  $$HighlightsTableProcessedTableManager get highlightsRefs {
    final manager = $$HighlightsTableTableManager(
      $_db,
      $_db.highlights,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_highlightsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<LifeArea, LifeArea, String> get area =>
      $composableBuilder(column: $table.area, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get estimatedMinutes =>
      $composableBuilder(column: $table.estimatedMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstStep =>
      $composableBuilder(column: $table.firstStep, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledDate =>
      $composableBuilder(column: $table.scheduledDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timeBlockId =>
      $composableBuilder(column: $table.timeBlockId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TaskStatus, TaskStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Effort, Effort, String> get effort =>
      $composableBuilder(column: $table.effort, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get snoozedUntil =>
      $composableBuilder(column: $table.snoozedUntil, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get topDate =>
      $composableBuilder(column: $table.topDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get topRank =>
      $composableBuilder(column: $table.topRank, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$GoalsTableFilterComposer get goalId {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$GoalsTableFilterComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WeeklyTargetsTableFilterComposer get weeklyTargetId {
    final $$WeeklyTargetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.weeklyTargetId,
      referencedTable: $db.weeklyTargets,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$WeeklyTargetsTableFilterComposer(
            $db: $db,
            $table: $db.weeklyTargets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> timeBlocksRefs(Expression<bool> Function($$TimeBlocksTableFilterComposer f) f) {
    final $$TimeBlocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timeBlocks,
      getReferencedColumn: (t) => t.taskId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TimeBlocksTableFilterComposer(
            $db: $db,
            $table: $db.timeBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> focusSessionsRefs(Expression<bool> Function($$FocusSessionsTableFilterComposer f) f) {
    final $$FocusSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.taskId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$FocusSessionsTableFilterComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> remindersRefs(Expression<bool> Function($$RemindersTableFilterComposer f) f) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.taskId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> highlightsRefs(Expression<bool> Function($$HighlightsTableFilterComposer f) f) {
    final $$HighlightsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.highlights,
      getReferencedColumn: (t) => t.taskId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$HighlightsTableFilterComposer(
            $db: $db,
            $table: $db.highlights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableOrderingComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get area =>
      $composableBuilder(column: $table.area, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedMinutes =>
      $composableBuilder(column: $table.estimatedMinutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstStep =>
      $composableBuilder(column: $table.firstStep, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledDate =>
      $composableBuilder(column: $table.scheduledDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timeBlockId =>
      $composableBuilder(column: $table.timeBlockId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get effort =>
      $composableBuilder(column: $table.effort, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get snoozedUntil =>
      $composableBuilder(column: $table.snoozedUntil, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get topDate =>
      $composableBuilder(column: $table.topDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get topRank =>
      $composableBuilder(column: $table.topRank, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$GoalsTableOrderingComposer get goalId {
    final $$GoalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$GoalsTableOrderingComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WeeklyTargetsTableOrderingComposer get weeklyTargetId {
    final $$WeeklyTargetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.weeklyTargetId,
      referencedTable: $db.weeklyTargets,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$WeeklyTargetsTableOrderingComposer(
            $db: $db,
            $table: $db.weeklyTargets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableAnnotationComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LifeArea, String> get area =>
      $composableBuilder(column: $table.area, builder: (column) => column);

  GeneratedColumn<int> get estimatedMinutes =>
      $composableBuilder(column: $table.estimatedMinutes, builder: (column) => column);

  GeneratedColumn<String> get firstStep =>
      $composableBuilder(column: $table.firstStep, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledDate =>
      $composableBuilder(column: $table.scheduledDate, builder: (column) => column);

  GeneratedColumn<int> get timeBlockId =>
      $composableBuilder(column: $table.timeBlockId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Effort, String> get effort =>
      $composableBuilder(column: $table.effort, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get snoozedUntil =>
      $composableBuilder(column: $table.snoozedUntil, builder: (column) => column);

  GeneratedColumn<DateTime> get topDate =>
      $composableBuilder(column: $table.topDate, builder: (column) => column);

  GeneratedColumn<int> get topRank => $composableBuilder(column: $table.topRank, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GoalsTableAnnotationComposer get goalId {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$GoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WeeklyTargetsTableAnnotationComposer get weeklyTargetId {
    final $$WeeklyTargetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.weeklyTargetId,
      referencedTable: $db.weeklyTargets,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$WeeklyTargetsTableAnnotationComposer(
            $db: $db,
            $table: $db.weeklyTargets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> timeBlocksRefs<T extends Object>(
    Expression<T> Function($$TimeBlocksTableAnnotationComposer a) f,
  ) {
    final $$TimeBlocksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timeBlocks,
      getReferencedColumn: (t) => t.taskId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TimeBlocksTableAnnotationComposer(
            $db: $db,
            $table: $db.timeBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> focusSessionsRefs<T extends Object>(
    Expression<T> Function($$FocusSessionsTableAnnotationComposer a) f,
  ) {
    final $$FocusSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.taskId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$FocusSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.taskId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> highlightsRefs<T extends Object>(
    Expression<T> Function($$HighlightsTableAnnotationComposer a) f,
  ) {
    final $$HighlightsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.highlights,
      getReferencedColumn: (t) => t.taskId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$HighlightsTableAnnotationComposer(
            $db: $db,
            $table: $db.highlights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({
            bool goalId,
            bool weeklyTargetId,
            bool timeBlocksRefs,
            bool focusSessionsRefs,
            bool remindersRefs,
            bool highlightsRefs,
          })
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<LifeArea> area = const Value.absent(),
                Value<int?> goalId = const Value.absent(),
                Value<int?> weeklyTargetId = const Value.absent(),
                Value<int> estimatedMinutes = const Value.absent(),
                Value<String?> firstStep = const Value.absent(),
                Value<DateTime?> scheduledDate = const Value.absent(),
                Value<int?> timeBlockId = const Value.absent(),
                Value<TaskStatus> status = const Value.absent(),
                Value<Effort> effort = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> snoozedUntil = const Value.absent(),
                Value<DateTime?> topDate = const Value.absent(),
                Value<int?> topRank = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                area: area,
                goalId: goalId,
                weeklyTargetId: weeklyTargetId,
                estimatedMinutes: estimatedMinutes,
                firstStep: firstStep,
                scheduledDate: scheduledDate,
                timeBlockId: timeBlockId,
                status: status,
                effort: effort,
                priority: priority,
                completedAt: completedAt,
                snoozedUntil: snoozedUntil,
                topDate: topDate,
                topRank: topRank,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required LifeArea area,
                Value<int?> goalId = const Value.absent(),
                Value<int?> weeklyTargetId = const Value.absent(),
                Value<int> estimatedMinutes = const Value.absent(),
                Value<String?> firstStep = const Value.absent(),
                Value<DateTime?> scheduledDate = const Value.absent(),
                Value<int?> timeBlockId = const Value.absent(),
                Value<TaskStatus> status = const Value.absent(),
                Value<Effort> effort = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> snoozedUntil = const Value.absent(),
                Value<DateTime?> topDate = const Value.absent(),
                Value<int?> topRank = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                area: area,
                goalId: goalId,
                weeklyTargetId: weeklyTargetId,
                estimatedMinutes: estimatedMinutes,
                firstStep: firstStep,
                scheduledDate: scheduledDate,
                timeBlockId: timeBlockId,
                status: status,
                effort: effort,
                priority: priority,
                completedAt: completedAt,
                snoozedUntil: snoozedUntil,
                topDate: topDate,
                topRank: topRank,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable<$TasksTable, Task>(table), $$TasksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback:
              ({
                goalId = false,
                weeklyTargetId = false,
                timeBlocksRefs = false,
                focusSessionsRefs = false,
                remindersRefs = false,
                highlightsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (timeBlocksRefs) db.timeBlocks,
                    if (focusSessionsRefs) db.focusSessions,
                    if (remindersRefs) db.reminders,
                    if (highlightsRefs) db.highlights,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (goalId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.goalId,
                            referencedTable: $$TasksTableReferences._goalIdTable(db),
                            referencedColumn: $$TasksTableReferences._goalIdTable(db).id,
                          ) as T;
                        }
                        if (weeklyTargetId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.weeklyTargetId,
                            referencedTable: $$TasksTableReferences._weeklyTargetIdTable(db),
                            referencedColumn: $$TasksTableReferences._weeklyTargetIdTable(db).id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (timeBlocksRefs)
                        await $_getPrefetchedDataByColumns<Task, $TasksTable, TimeBlock, $TimeBlocksTable>(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences._timeBlocksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(db, table, p0).timeBlocksRefs,
                          currentColumn: 'id',
                          referencedColumn: 'task_id',
                          typedResults: items,
                        ),
                      if (focusSessionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Task,
                          $TasksTable,
                          FocusSession,
                          $FocusSessionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences._focusSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(db, table, p0).focusSessionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'task_id',
                          typedResults: items,
                        ),
                      if (remindersRefs)
                        await $_getPrefetchedDataByColumns<Task, $TasksTable, Reminder, $RemindersTable>(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences._remindersRefsTable(db),
                          managerFromTypedResult: (p0) => $$TasksTableReferences(db, table, p0).remindersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'task_id',
                          typedResults: items,
                        ),
                      if (highlightsRefs)
                        await $_getPrefetchedDataByColumns<Task, $TasksTable, Highlight, $HighlightsTable>(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences._highlightsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(db, table, p0).highlightsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'task_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({
        bool goalId,
        bool weeklyTargetId,
        bool timeBlocksRefs,
        bool focusSessionsRefs,
        bool remindersRefs,
        bool highlightsRefs,
      })
    >;
typedef $$TimeBlocksTableCreateCompanionBuilder = TimeBlocksCompanion Function({
  Value<int> id,
  required DateTime startAt,
  required DateTime endAt,
  Value<int?> taskId,
  Value<String> label,
  required BlockType type,
  Value<bool> remind,
});
typedef $$TimeBlocksTableUpdateCompanionBuilder = TimeBlocksCompanion Function({
  Value<int> id,
  Value<DateTime> startAt,
  Value<DateTime> endAt,
  Value<int?> taskId,
  Value<String> label,
  Value<BlockType> type,
  Value<bool> remind,
});

final class $$TimeBlocksTableReferences extends BaseReferences<_$AppDatabase, $TimeBlocksTable, TimeBlock> {
  $$TimeBlocksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('time_blocks__task_id__tasks__id');

  $$TasksTableProcessedTableManager? get taskId {
    final $_column = $_itemColumn<int>('task_id');
    if ($_column == null) return null;
    final manager = $$TasksTableTableManager($_db, $_db.tasks).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TimeBlocksTableFilterComposer extends Composer<_$AppDatabase, $TimeBlocksTable> {
  $$TimeBlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<BlockType, BlockType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get remind =>
      $composableBuilder(column: $table.remind, builder: (column) => ColumnFilters(column));

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimeBlocksTableOrderingComposer extends Composer<_$AppDatabase, $TimeBlocksTable> {
  $$TimeBlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get remind =>
      $composableBuilder(column: $table.remind, builder: (column) => ColumnOrderings(column));

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimeBlocksTableAnnotationComposer extends Composer<_$AppDatabase, $TimeBlocksTable> {
  $$TimeBlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<String> get label => $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BlockType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get remind => $composableBuilder(column: $table.remind, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimeBlocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimeBlocksTable,
          TimeBlock,
          $$TimeBlocksTableFilterComposer,
          $$TimeBlocksTableOrderingComposer,
          $$TimeBlocksTableAnnotationComposer,
          $$TimeBlocksTableCreateCompanionBuilder,
          $$TimeBlocksTableUpdateCompanionBuilder,
          (TimeBlock, $$TimeBlocksTableReferences),
          TimeBlock,
          PrefetchHooks Function({bool taskId})
        > {
  $$TimeBlocksTableTableManager(_$AppDatabase db, $TimeBlocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TimeBlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TimeBlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TimeBlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startAt = const Value.absent(),
                Value<DateTime> endAt = const Value.absent(),
                Value<int?> taskId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<BlockType> type = const Value.absent(),
                Value<bool> remind = const Value.absent(),
              }) => TimeBlocksCompanion(
                id: id,
                startAt: startAt,
                endAt: endAt,
                taskId: taskId,
                label: label,
                type: type,
                remind: remind,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startAt,
                required DateTime endAt,
                Value<int?> taskId = const Value.absent(),
                Value<String> label = const Value.absent(),
                required BlockType type,
                Value<bool> remind = const Value.absent(),
              }) => TimeBlocksCompanion.insert(
                id: id,
                startAt: startAt,
                endAt: endAt,
                taskId: taskId,
                label: label,
                type: type,
                remind: remind,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TimeBlocksTable, TimeBlock>(table),
                  $$TimeBlocksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.taskId,
                        referencedTable: $$TimeBlocksTableReferences._taskIdTable(db),
                        referencedColumn: $$TimeBlocksTableReferences._taskIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TimeBlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimeBlocksTable,
      TimeBlock,
      $$TimeBlocksTableFilterComposer,
      $$TimeBlocksTableOrderingComposer,
      $$TimeBlocksTableAnnotationComposer,
      $$TimeBlocksTableCreateCompanionBuilder,
      $$TimeBlocksTableUpdateCompanionBuilder,
      (TimeBlock, $$TimeBlocksTableReferences),
      TimeBlock,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$FocusSessionsTableCreateCompanionBuilder = FocusSessionsCompanion Function({
  Value<int> id,
  Value<int?> taskId,
  required int plannedMinutes,
  Value<int> breakMinutes,
  Value<int> actualSeconds,
  required DateTime startAt,
  Value<DateTime?> endAt,
  Value<bool> completed,
  Value<String?> distractions,
});
typedef $$FocusSessionsTableUpdateCompanionBuilder = FocusSessionsCompanion Function({
  Value<int> id,
  Value<int?> taskId,
  Value<int> plannedMinutes,
  Value<int> breakMinutes,
  Value<int> actualSeconds,
  Value<DateTime> startAt,
  Value<DateTime?> endAt,
  Value<bool> completed,
  Value<String?> distractions,
});

final class $$FocusSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $FocusSessionsTable, FocusSession> {
  $$FocusSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('focus_sessions__task_id__tasks__id');

  $$TasksTableProcessedTableManager? get taskId {
    final $_column = $_itemColumn<int>('task_id');
    if ($_column == null) return null;
    final manager = $$TasksTableTableManager($_db, $_db.tasks).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FocusSessionsTableFilterComposer extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get plannedMinutes =>
      $composableBuilder(column: $table.plannedMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get breakMinutes =>
      $composableBuilder(column: $table.breakMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get actualSeconds =>
      $composableBuilder(column: $table.actualSeconds, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get distractions =>
      $composableBuilder(column: $table.distractions, builder: (column) => ColumnFilters(column));

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionsTableOrderingComposer extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get plannedMinutes =>
      $composableBuilder(column: $table.plannedMinutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get breakMinutes =>
      $composableBuilder(column: $table.breakMinutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get actualSeconds =>
      $composableBuilder(column: $table.actualSeconds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get distractions =>
      $composableBuilder(column: $table.distractions, builder: (column) => ColumnOrderings(column));

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionsTableAnnotationComposer extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get plannedMinutes =>
      $composableBuilder(column: $table.plannedMinutes, builder: (column) => column);

  GeneratedColumn<int> get breakMinutes =>
      $composableBuilder(column: $table.breakMinutes, builder: (column) => column);

  GeneratedColumn<int> get actualSeconds =>
      $composableBuilder(column: $table.actualSeconds, builder: (column) => column);

  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<String> get distractions =>
      $composableBuilder(column: $table.distractions, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FocusSessionsTable,
          FocusSession,
          $$FocusSessionsTableFilterComposer,
          $$FocusSessionsTableOrderingComposer,
          $$FocusSessionsTableAnnotationComposer,
          $$FocusSessionsTableCreateCompanionBuilder,
          $$FocusSessionsTableUpdateCompanionBuilder,
          (FocusSession, $$FocusSessionsTableReferences),
          FocusSession,
          PrefetchHooks Function({bool taskId})
        > {
  $$FocusSessionsTableTableManager(_$AppDatabase db, $FocusSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$FocusSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$FocusSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$FocusSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> taskId = const Value.absent(),
                Value<int> plannedMinutes = const Value.absent(),
                Value<int> breakMinutes = const Value.absent(),
                Value<int> actualSeconds = const Value.absent(),
                Value<DateTime> startAt = const Value.absent(),
                Value<DateTime?> endAt = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<String?> distractions = const Value.absent(),
              }) => FocusSessionsCompanion(
                id: id,
                taskId: taskId,
                plannedMinutes: plannedMinutes,
                breakMinutes: breakMinutes,
                actualSeconds: actualSeconds,
                startAt: startAt,
                endAt: endAt,
                completed: completed,
                distractions: distractions,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> taskId = const Value.absent(),
                required int plannedMinutes,
                Value<int> breakMinutes = const Value.absent(),
                Value<int> actualSeconds = const Value.absent(),
                required DateTime startAt,
                Value<DateTime?> endAt = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<String?> distractions = const Value.absent(),
              }) => FocusSessionsCompanion.insert(
                id: id,
                taskId: taskId,
                plannedMinutes: plannedMinutes,
                breakMinutes: breakMinutes,
                actualSeconds: actualSeconds,
                startAt: startAt,
                endAt: endAt,
                completed: completed,
                distractions: distractions,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FocusSessionsTable, FocusSession>(table),
                  $$FocusSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.taskId,
                        referencedTable: $$FocusSessionsTableReferences._taskIdTable(db),
                        referencedColumn: $$FocusSessionsTableReferences._taskIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FocusSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FocusSessionsTable,
      FocusSession,
      $$FocusSessionsTableFilterComposer,
      $$FocusSessionsTableOrderingComposer,
      $$FocusSessionsTableAnnotationComposer,
      $$FocusSessionsTableCreateCompanionBuilder,
      $$FocusSessionsTableUpdateCompanionBuilder,
      (FocusSession, $$FocusSessionsTableReferences),
      FocusSession,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$EnergyCheckInsTableCreateCompanionBuilder = EnergyCheckInsCompanion Function({
  Value<int> id,
  required DateTime date,
  required int energy,
  required int mood,
  Value<String?> note,
});
typedef $$EnergyCheckInsTableUpdateCompanionBuilder = EnergyCheckInsCompanion Function({
  Value<int> id,
  Value<DateTime> date,
  Value<int> energy,
  Value<int> mood,
  Value<String?> note,
});

class $$EnergyCheckInsTableFilterComposer extends Composer<_$AppDatabase, $EnergyCheckInsTable> {
  $$EnergyCheckInsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$EnergyCheckInsTableOrderingComposer extends Composer<_$AppDatabase, $EnergyCheckInsTable> {
  $$EnergyCheckInsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$EnergyCheckInsTableAnnotationComposer extends Composer<_$AppDatabase, $EnergyCheckInsTable> {
  $$EnergyCheckInsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date => $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get energy => $composableBuilder(column: $table.energy, builder: (column) => column);

  GeneratedColumn<int> get mood => $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get note => $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$EnergyCheckInsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnergyCheckInsTable,
          EnergyCheckIn,
          $$EnergyCheckInsTableFilterComposer,
          $$EnergyCheckInsTableOrderingComposer,
          $$EnergyCheckInsTableAnnotationComposer,
          $$EnergyCheckInsTableCreateCompanionBuilder,
          $$EnergyCheckInsTableUpdateCompanionBuilder,
          (EnergyCheckIn, BaseReferences<_$AppDatabase, $EnergyCheckInsTable, EnergyCheckIn>),
          EnergyCheckIn,
          PrefetchHooks Function()
        > {
  $$EnergyCheckInsTableTableManager(_$AppDatabase db, $EnergyCheckInsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$EnergyCheckInsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$EnergyCheckInsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$EnergyCheckInsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<int> energy = const Value.absent(),
            Value<int> mood = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) => EnergyCheckInsCompanion(id: id, date: date, energy: energy, mood: mood, note: note),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime date,
            required int energy,
            required int mood,
            Value<String?> note = const Value.absent(),
          }) => EnergyCheckInsCompanion.insert(id: id, date: date, energy: energy, mood: mood, note: note),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EnergyCheckInsTable, EnergyCheckIn>(table),
                  BaseReferences<_$AppDatabase, $EnergyCheckInsTable, EnergyCheckIn>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EnergyCheckInsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnergyCheckInsTable,
      EnergyCheckIn,
      $$EnergyCheckInsTableFilterComposer,
      $$EnergyCheckInsTableOrderingComposer,
      $$EnergyCheckInsTableAnnotationComposer,
      $$EnergyCheckInsTableCreateCompanionBuilder,
      $$EnergyCheckInsTableUpdateCompanionBuilder,
      (EnergyCheckIn, BaseReferences<_$AppDatabase, $EnergyCheckInsTable, EnergyCheckIn>),
      EnergyCheckIn,
      PrefetchHooks Function()
    >;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  required String title,
  required DateTime at,
  Value<RepeatRule> repeat,
  Value<int?> taskId,
  Value<bool> enabled,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<DateTime> at,
  Value<RepeatRule> repeat,
  Value<int?> taskId,
  Value<bool> enabled,
});

final class $$RemindersTableReferences extends BaseReferences<_$AppDatabase, $RemindersTable, Reminder> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks.createAlias('reminders__task_id__tasks__id');

  $$TasksTableProcessedTableManager? get taskId {
    final $_column = $_itemColumn<int>('task_id');
    if ($_column == null) return null;
    final manager = $$TasksTableTableManager($_db, $_db.tasks).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RemindersTableFilterComposer extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<RepeatRule, RepeatRule, String> get repeat =>
      $composableBuilder(column: $table.repeat, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => ColumnFilters(column));

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableOrderingComposer extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get repeat =>
      $composableBuilder(column: $table.repeat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => ColumnOrderings(column));

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableAnnotationComposer extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get at => $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RepeatRule, String> get repeat =>
      $composableBuilder(column: $table.repeat, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          Reminder,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (Reminder, $$RemindersTableReferences),
          Reminder,
          PrefetchHooks Function({bool taskId})
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<RepeatRule> repeat = const Value.absent(),
                Value<int?> taskId = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                title: title,
                at: at,
                repeat: repeat,
                taskId: taskId,
                enabled: enabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required DateTime at,
                Value<RepeatRule> repeat = const Value.absent(),
                Value<int?> taskId = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                title: title,
                at: at,
                repeat: repeat,
                taskId: taskId,
                enabled: enabled,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable<$RemindersTable, Reminder>(table), $$RemindersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.taskId,
                        referencedTable: $$RemindersTableReferences._taskIdTable(db),
                        referencedColumn: $$RemindersTableReferences._taskIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      Reminder,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (Reminder, $$RemindersTableReferences),
      Reminder,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$BrainDumpsTableCreateCompanionBuilder = BrainDumpsCompanion Function({
  Value<int> id,
  required String body,
  Value<DateTime> createdAt,
  Value<bool> sorted,
});
typedef $$BrainDumpsTableUpdateCompanionBuilder = BrainDumpsCompanion Function({
  Value<int> id,
  Value<String> body,
  Value<DateTime> createdAt,
  Value<bool> sorted,
});

class $$BrainDumpsTableFilterComposer extends Composer<_$AppDatabase, $BrainDumpsTable> {
  $$BrainDumpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get sorted =>
      $composableBuilder(column: $table.sorted, builder: (column) => ColumnFilters(column));
}

class $$BrainDumpsTableOrderingComposer extends Composer<_$AppDatabase, $BrainDumpsTable> {
  $$BrainDumpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get sorted =>
      $composableBuilder(column: $table.sorted, builder: (column) => ColumnOrderings(column));
}

class $$BrainDumpsTableAnnotationComposer extends Composer<_$AppDatabase, $BrainDumpsTable> {
  $$BrainDumpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get body => $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get sorted => $composableBuilder(column: $table.sorted, builder: (column) => column);
}

class $$BrainDumpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BrainDumpsTable,
          BrainDump,
          $$BrainDumpsTableFilterComposer,
          $$BrainDumpsTableOrderingComposer,
          $$BrainDumpsTableAnnotationComposer,
          $$BrainDumpsTableCreateCompanionBuilder,
          $$BrainDumpsTableUpdateCompanionBuilder,
          (BrainDump, BaseReferences<_$AppDatabase, $BrainDumpsTable, BrainDump>),
          BrainDump,
          PrefetchHooks Function()
        > {
  $$BrainDumpsTableTableManager(_$AppDatabase db, $BrainDumpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$BrainDumpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$BrainDumpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$BrainDumpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> sorted = const Value.absent(),
          }) => BrainDumpsCompanion(id: id, body: body, createdAt: createdAt, sorted: sorted),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String body,
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> sorted = const Value.absent(),
          }) => BrainDumpsCompanion.insert(id: id, body: body, createdAt: createdAt, sorted: sorted),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BrainDumpsTable, BrainDump>(table),
                  BaseReferences<_$AppDatabase, $BrainDumpsTable, BrainDump>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BrainDumpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BrainDumpsTable,
      BrainDump,
      $$BrainDumpsTableFilterComposer,
      $$BrainDumpsTableOrderingComposer,
      $$BrainDumpsTableAnnotationComposer,
      $$BrainDumpsTableCreateCompanionBuilder,
      $$BrainDumpsTableUpdateCompanionBuilder,
      (BrainDump, BaseReferences<_$AppDatabase, $BrainDumpsTable, BrainDump>),
      BrainDump,
      PrefetchHooks Function()
    >;
typedef $$HighlightsTableCreateCompanionBuilder = HighlightsCompanion Function({
  Value<int> id,
  required String title,
  required DateTime date,
  Value<int?> taskId,
  Value<String?> note,
});
typedef $$HighlightsTableUpdateCompanionBuilder = HighlightsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<DateTime> date,
  Value<int?> taskId,
  Value<String?> note,
});

final class $$HighlightsTableReferences extends BaseReferences<_$AppDatabase, $HighlightsTable, Highlight> {
  $$HighlightsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks.createAlias('highlights__task_id__tasks__id');

  $$TasksTableProcessedTableManager? get taskId {
    final $_column = $_itemColumn<int>('task_id');
    if ($_column == null) return null;
    final manager = $$TasksTableTableManager($_db, $_db.tasks).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$HighlightsTableFilterComposer extends Composer<_$AppDatabase, $HighlightsTable> {
  $$HighlightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HighlightsTableOrderingComposer extends Composer<_$AppDatabase, $HighlightsTable> {
  $$HighlightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HighlightsTableAnnotationComposer extends Composer<_$AppDatabase, $HighlightsTable> {
  $$HighlightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get date => $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note => $composableBuilder(column: $table.note, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HighlightsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HighlightsTable,
          Highlight,
          $$HighlightsTableFilterComposer,
          $$HighlightsTableOrderingComposer,
          $$HighlightsTableAnnotationComposer,
          $$HighlightsTableCreateCompanionBuilder,
          $$HighlightsTableUpdateCompanionBuilder,
          (Highlight, $$HighlightsTableReferences),
          Highlight,
          PrefetchHooks Function({bool taskId})
        > {
  $$HighlightsTableTableManager(_$AppDatabase db, $HighlightsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$HighlightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$HighlightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$HighlightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<int?> taskId = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) => HighlightsCompanion(id: id, title: title, date: date, taskId: taskId, note: note),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required DateTime date,
            Value<int?> taskId = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) => HighlightsCompanion.insert(id: id, title: title, date: date, taskId: taskId, note: note),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HighlightsTable, Highlight>(table),
                  $$HighlightsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.taskId,
                        referencedTable: $$HighlightsTableReferences._taskIdTable(db),
                        referencedColumn: $$HighlightsTableReferences._taskIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HighlightsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HighlightsTable,
      Highlight,
      $$HighlightsTableFilterComposer,
      $$HighlightsTableOrderingComposer,
      $$HighlightsTableAnnotationComposer,
      $$HighlightsTableCreateCompanionBuilder,
      $$HighlightsTableUpdateCompanionBuilder,
      (Highlight, $$HighlightsTableReferences),
      Highlight,
      PrefetchHooks Function({bool taskId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GoalsTableTableManager get goals => $$GoalsTableTableManager(_db, _db.goals);
  $$MilestonesTableTableManager get milestones => $$MilestonesTableTableManager(_db, _db.milestones);
  $$WeeklyTargetsTableTableManager get weeklyTargets =>
      $$WeeklyTargetsTableTableManager(_db, _db.weeklyTargets);
  $$TasksTableTableManager get tasks => $$TasksTableTableManager(_db, _db.tasks);
  $$TimeBlocksTableTableManager get timeBlocks => $$TimeBlocksTableTableManager(_db, _db.timeBlocks);
  $$FocusSessionsTableTableManager get focusSessions =>
      $$FocusSessionsTableTableManager(_db, _db.focusSessions);
  $$EnergyCheckInsTableTableManager get energyCheckIns =>
      $$EnergyCheckInsTableTableManager(_db, _db.energyCheckIns);
  $$RemindersTableTableManager get reminders => $$RemindersTableTableManager(_db, _db.reminders);
  $$BrainDumpsTableTableManager get brainDumps => $$BrainDumpsTableTableManager(_db, _db.brainDumps);
  $$HighlightsTableTableManager get highlights => $$HighlightsTableTableManager(_db, _db.highlights);
}
