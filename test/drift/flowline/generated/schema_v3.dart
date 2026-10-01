// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class Tasks extends Table with TableInfo<Tasks, TasksData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Tasks(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<int> scheduleBlockId = GeneratedColumn<int>(
      'schedule_block_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('\'\''));
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
      'due_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, scheduleBlockId, title, notes, priority, status, dueAt, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TasksData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TasksData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      scheduleBlockId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}schedule_block_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      dueAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  Tasks createAlias(String alias) {
    return Tasks(attachedDatabase, alias);
  }
}

class TasksData extends DataClass implements Insertable<TasksData> {
  final int id;
  final int? scheduleBlockId;
  final String title;
  final String notes;
  final int priority;
  final int status;
  final DateTime? dueAt;
  final DateTime createdAt;
  const TasksData(
      {required this.id,
      this.scheduleBlockId,
      required this.title,
      required this.notes,
      required this.priority,
      required this.status,
      this.dueAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || scheduleBlockId != null) {
      map['schedule_block_id'] = Variable<int>(scheduleBlockId);
    }
    map['title'] = Variable<String>(title);
    map['notes'] = Variable<String>(notes);
    map['priority'] = Variable<int>(priority);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      scheduleBlockId: scheduleBlockId == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduleBlockId),
      title: Value(title),
      notes: Value(notes),
      priority: Value(priority),
      status: Value(status),
      dueAt:
          dueAt == null && nullToAbsent ? const Value.absent() : Value(dueAt),
      createdAt: Value(createdAt),
    );
  }

  factory TasksData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TasksData(
      id: serializer.fromJson<int>(json['id']),
      scheduleBlockId: serializer.fromJson<int?>(json['scheduleBlockId']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String>(json['notes']),
      priority: serializer.fromJson<int>(json['priority']),
      status: serializer.fromJson<int>(json['status']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scheduleBlockId': serializer.toJson<int?>(scheduleBlockId),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String>(notes),
      'priority': serializer.toJson<int>(priority),
      'status': serializer.toJson<int>(status),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TasksData copyWith(
          {int? id,
          Value<int?> scheduleBlockId = const Value.absent(),
          String? title,
          String? notes,
          int? priority,
          int? status,
          Value<DateTime?> dueAt = const Value.absent(),
          DateTime? createdAt}) =>
      TasksData(
        id: id ?? this.id,
        scheduleBlockId: scheduleBlockId.present
            ? scheduleBlockId.value
            : this.scheduleBlockId,
        title: title ?? this.title,
        notes: notes ?? this.notes,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        dueAt: dueAt.present ? dueAt.value : this.dueAt,
        createdAt: createdAt ?? this.createdAt,
      );
  TasksData copyWithCompanion(TasksCompanion data) {
    return TasksData(
      id: data.id.present ? data.id.value : this.id,
      scheduleBlockId: data.scheduleBlockId.present
          ? data.scheduleBlockId.value
          : this.scheduleBlockId,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TasksData(')
          ..write('id: $id, ')
          ..write('scheduleBlockId: $scheduleBlockId, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, scheduleBlockId, title, notes, priority, status, dueAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TasksData &&
          other.id == this.id &&
          other.scheduleBlockId == this.scheduleBlockId &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.dueAt == this.dueAt &&
          other.createdAt == this.createdAt);
}

class TasksCompanion extends UpdateCompanion<TasksData> {
  final Value<int> id;
  final Value<int?> scheduleBlockId;
  final Value<String> title;
  final Value<String> notes;
  final Value<int> priority;
  final Value<int> status;
  final Value<DateTime?> dueAt;
  final Value<DateTime> createdAt;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.scheduleBlockId = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    this.scheduleBlockId = const Value.absent(),
    required String title,
    this.notes = const Value.absent(),
    required int priority,
    required int status,
    this.dueAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : title = Value(title),
        priority = Value(priority),
        status = Value(status);
  static Insertable<TasksData> custom({
    Expression<int>? id,
    Expression<int>? scheduleBlockId,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<int>? priority,
    Expression<int>? status,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scheduleBlockId != null) 'schedule_block_id': scheduleBlockId,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (dueAt != null) 'due_at': dueAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TasksCompanion copyWith(
      {Value<int>? id,
      Value<int?>? scheduleBlockId,
      Value<String>? title,
      Value<String>? notes,
      Value<int>? priority,
      Value<int>? status,
      Value<DateTime?>? dueAt,
      Value<DateTime>? createdAt}) {
    return TasksCompanion(
      id: id ?? this.id,
      scheduleBlockId: scheduleBlockId ?? this.scheduleBlockId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueAt: dueAt ?? this.dueAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scheduleBlockId.present) {
      map['schedule_block_id'] = Variable<int>(scheduleBlockId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
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
          ..write('scheduleBlockId: $scheduleBlockId, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('dueAt: $dueAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class Subtasks extends Table with TableInfo<Subtasks, SubtasksData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Subtasks(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
      'task_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tasks (id) ON DELETE CASCADE'));
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<int> plannedSprints = GeneratedColumn<int>(
      'planned_sprints', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('1'));
  late final GeneratedColumn<int> completedSprints = GeneratedColumn<int>(
      'completed_sprints', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('0'));
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('0'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, taskId, title, status, plannedSprints, completedSprints, orderIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subtasks';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubtasksData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubtasksData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}task_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      plannedSprints: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}planned_sprints'])!,
      completedSprints: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}completed_sprints'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
    );
  }

  @override
  Subtasks createAlias(String alias) {
    return Subtasks(attachedDatabase, alias);
  }
}

class SubtasksData extends DataClass implements Insertable<SubtasksData> {
  final int id;
  final int taskId;
  final String title;
  final int status;
  final int plannedSprints;
  final int completedSprints;
  final int orderIndex;
  const SubtasksData(
      {required this.id,
      required this.taskId,
      required this.title,
      required this.status,
      required this.plannedSprints,
      required this.completedSprints,
      required this.orderIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task_id'] = Variable<int>(taskId);
    map['title'] = Variable<String>(title);
    map['status'] = Variable<int>(status);
    map['planned_sprints'] = Variable<int>(plannedSprints);
    map['completed_sprints'] = Variable<int>(completedSprints);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  SubtasksCompanion toCompanion(bool nullToAbsent) {
    return SubtasksCompanion(
      id: Value(id),
      taskId: Value(taskId),
      title: Value(title),
      status: Value(status),
      plannedSprints: Value(plannedSprints),
      completedSprints: Value(completedSprints),
      orderIndex: Value(orderIndex),
    );
  }

  factory SubtasksData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubtasksData(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int>(json['taskId']),
      title: serializer.fromJson<String>(json['title']),
      status: serializer.fromJson<int>(json['status']),
      plannedSprints: serializer.fromJson<int>(json['plannedSprints']),
      completedSprints: serializer.fromJson<int>(json['completedSprints']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<int>(taskId),
      'title': serializer.toJson<String>(title),
      'status': serializer.toJson<int>(status),
      'plannedSprints': serializer.toJson<int>(plannedSprints),
      'completedSprints': serializer.toJson<int>(completedSprints),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  SubtasksData copyWith(
          {int? id,
          int? taskId,
          String? title,
          int? status,
          int? plannedSprints,
          int? completedSprints,
          int? orderIndex}) =>
      SubtasksData(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        title: title ?? this.title,
        status: status ?? this.status,
        plannedSprints: plannedSprints ?? this.plannedSprints,
        completedSprints: completedSprints ?? this.completedSprints,
        orderIndex: orderIndex ?? this.orderIndex,
      );
  SubtasksData copyWithCompanion(SubtasksCompanion data) {
    return SubtasksData(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      plannedSprints: data.plannedSprints.present
          ? data.plannedSprints.value
          : this.plannedSprints,
      completedSprints: data.completedSprints.present
          ? data.completedSprints.value
          : this.completedSprints,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubtasksData(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('plannedSprints: $plannedSprints, ')
          ..write('completedSprints: $completedSprints, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, taskId, title, status, plannedSprints, completedSprints, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubtasksData &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.title == this.title &&
          other.status == this.status &&
          other.plannedSprints == this.plannedSprints &&
          other.completedSprints == this.completedSprints &&
          other.orderIndex == this.orderIndex);
}

class SubtasksCompanion extends UpdateCompanion<SubtasksData> {
  final Value<int> id;
  final Value<int> taskId;
  final Value<String> title;
  final Value<int> status;
  final Value<int> plannedSprints;
  final Value<int> completedSprints;
  final Value<int> orderIndex;
  const SubtasksCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.plannedSprints = const Value.absent(),
    this.completedSprints = const Value.absent(),
    this.orderIndex = const Value.absent(),
  });
  SubtasksCompanion.insert({
    this.id = const Value.absent(),
    required int taskId,
    required String title,
    required int status,
    this.plannedSprints = const Value.absent(),
    this.completedSprints = const Value.absent(),
    this.orderIndex = const Value.absent(),
  })  : taskId = Value(taskId),
        title = Value(title),
        status = Value(status);
  static Insertable<SubtasksData> custom({
    Expression<int>? id,
    Expression<int>? taskId,
    Expression<String>? title,
    Expression<int>? status,
    Expression<int>? plannedSprints,
    Expression<int>? completedSprints,
    Expression<int>? orderIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (plannedSprints != null) 'planned_sprints': plannedSprints,
      if (completedSprints != null) 'completed_sprints': completedSprints,
      if (orderIndex != null) 'order_index': orderIndex,
    });
  }

  SubtasksCompanion copyWith(
      {Value<int>? id,
      Value<int>? taskId,
      Value<String>? title,
      Value<int>? status,
      Value<int>? plannedSprints,
      Value<int>? completedSprints,
      Value<int>? orderIndex}) {
    return SubtasksCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      status: status ?? this.status,
      plannedSprints: plannedSprints ?? this.plannedSprints,
      completedSprints: completedSprints ?? this.completedSprints,
      orderIndex: orderIndex ?? this.orderIndex,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (plannedSprints.present) {
      map['planned_sprints'] = Variable<int>(plannedSprints.value);
    }
    if (completedSprints.present) {
      map['completed_sprints'] = Variable<int>(completedSprints.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubtasksCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('plannedSprints: $plannedSprints, ')
          ..write('completedSprints: $completedSprints, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }
}

class ScheduleBlocks extends Table
    with TableInfo<ScheduleBlocks, ScheduleBlocksData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ScheduleBlocks(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  late final GeneratedColumn<int> source = GeneratedColumn<int>(
      'source', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression('0'));
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
      'is_locked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_locked" IN (0, 1))'),
      defaultValue: const CustomExpression('0'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, startTime, endTime, source, isLocked];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_blocks';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleBlocksData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleBlocksData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source'])!,
      isLocked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_locked'])!,
    );
  }

  @override
  ScheduleBlocks createAlias(String alias) {
    return ScheduleBlocks(attachedDatabase, alias);
  }
}

class ScheduleBlocksData extends DataClass
    implements Insertable<ScheduleBlocksData> {
  final int id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final int source;
  final bool isLocked;
  const ScheduleBlocksData(
      {required this.id,
      required this.title,
      required this.startTime,
      required this.endTime,
      required this.source,
      required this.isLocked});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['start_time'] = Variable<DateTime>(startTime);
    map['end_time'] = Variable<DateTime>(endTime);
    map['source'] = Variable<int>(source);
    map['is_locked'] = Variable<bool>(isLocked);
    return map;
  }

  ScheduleBlocksCompanion toCompanion(bool nullToAbsent) {
    return ScheduleBlocksCompanion(
      id: Value(id),
      title: Value(title),
      startTime: Value(startTime),
      endTime: Value(endTime),
      source: Value(source),
      isLocked: Value(isLocked),
    );
  }

  factory ScheduleBlocksData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleBlocksData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime>(json['endTime']),
      source: serializer.fromJson<int>(json['source']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime>(endTime),
      'source': serializer.toJson<int>(source),
      'isLocked': serializer.toJson<bool>(isLocked),
    };
  }

  ScheduleBlocksData copyWith(
          {int? id,
          String? title,
          DateTime? startTime,
          DateTime? endTime,
          int? source,
          bool? isLocked}) =>
      ScheduleBlocksData(
        id: id ?? this.id,
        title: title ?? this.title,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        source: source ?? this.source,
        isLocked: isLocked ?? this.isLocked,
      );
  ScheduleBlocksData copyWithCompanion(ScheduleBlocksCompanion data) {
    return ScheduleBlocksData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      source: data.source.present ? data.source.value : this.source,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleBlocksData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('source: $source, ')
          ..write('isLocked: $isLocked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, startTime, endTime, source, isLocked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleBlocksData &&
          other.id == this.id &&
          other.title == this.title &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.source == this.source &&
          other.isLocked == this.isLocked);
}

class ScheduleBlocksCompanion extends UpdateCompanion<ScheduleBlocksData> {
  final Value<int> id;
  final Value<String> title;
  final Value<DateTime> startTime;
  final Value<DateTime> endTime;
  final Value<int> source;
  final Value<bool> isLocked;
  const ScheduleBlocksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.source = const Value.absent(),
    this.isLocked = const Value.absent(),
  });
  ScheduleBlocksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    this.source = const Value.absent(),
    this.isLocked = const Value.absent(),
  })  : title = Value(title),
        startTime = Value(startTime),
        endTime = Value(endTime);
  static Insertable<ScheduleBlocksData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? source,
    Expression<bool>? isLocked,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (source != null) 'source': source,
      if (isLocked != null) 'is_locked': isLocked,
    });
  }

  ScheduleBlocksCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<DateTime>? startTime,
      Value<DateTime>? endTime,
      Value<int>? source,
      Value<bool>? isLocked}) {
    return ScheduleBlocksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      source: source ?? this.source,
      isLocked: isLocked ?? this.isLocked,
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
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (source.present) {
      map['source'] = Variable<int>(source.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleBlocksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('source: $source, ')
          ..write('isLocked: $isLocked')
          ..write(')'))
        .toString();
  }
}

class FocusSessions extends Table
    with TableInfo<FocusSessions, FocusSessionsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  FocusSessions(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
      'task_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tasks (id) ON DELETE SET NULL'));
  late final GeneratedColumn<int> subtaskId = GeneratedColumn<int>(
      'subtask_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES subtasks (id) ON DELETE SET NULL'));
  late final GeneratedColumn<int> sessionType = GeneratedColumn<int>(
      'session_type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<int> plannedDurationSec = GeneratedColumn<int>(
      'planned_duration_sec', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  late final GeneratedColumn<DateTime> segmentStartedAt =
      GeneratedColumn<DateTime>('segment_started_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  late final GeneratedColumn<int> remainingSecAtSegmentStart =
      GeneratedColumn<int>('remaining_sec_at_segment_start', aliasedName, false,
          type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<bool> isPaused = GeneratedColumn<bool>(
      'is_paused', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_paused" IN (0, 1))'),
      defaultValue: const CustomExpression('0'));
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  late final GeneratedColumn<int> actualDurationSec = GeneratedColumn<int>(
      'actual_duration_sec', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  late final GeneratedColumn<bool> endedEarly = GeneratedColumn<bool>(
      'ended_early', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("ended_early" IN (0, 1))'),
      defaultValue: const CustomExpression('0'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        taskId,
        subtaskId,
        sessionType,
        plannedDurationSec,
        startedAt,
        segmentStartedAt,
        remainingSecAtSegmentStart,
        isPaused,
        completedAt,
        actualDurationSec,
        endedEarly
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_sessions';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FocusSessionsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusSessionsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}task_id']),
      subtaskId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subtask_id']),
      sessionType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_type'])!,
      plannedDurationSec: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}planned_duration_sec'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      segmentStartedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}segment_started_at']),
      remainingSecAtSegmentStart: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}remaining_sec_at_segment_start'])!,
      isPaused: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_paused'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      actualDurationSec: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}actual_duration_sec']),
      endedEarly: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}ended_early'])!,
    );
  }

  @override
  FocusSessions createAlias(String alias) {
    return FocusSessions(attachedDatabase, alias);
  }
}

class FocusSessionsData extends DataClass
    implements Insertable<FocusSessionsData> {
  final int id;
  final int? taskId;
  final int? subtaskId;
  final int sessionType;
  final int plannedDurationSec;
  final DateTime startedAt;
  final DateTime? segmentStartedAt;
  final int remainingSecAtSegmentStart;
  final bool isPaused;
  final DateTime? completedAt;
  final int? actualDurationSec;
  final bool endedEarly;
  const FocusSessionsData(
      {required this.id,
      this.taskId,
      this.subtaskId,
      required this.sessionType,
      required this.plannedDurationSec,
      required this.startedAt,
      this.segmentStartedAt,
      required this.remainingSecAtSegmentStart,
      required this.isPaused,
      this.completedAt,
      this.actualDurationSec,
      required this.endedEarly});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<int>(taskId);
    }
    if (!nullToAbsent || subtaskId != null) {
      map['subtask_id'] = Variable<int>(subtaskId);
    }
    map['session_type'] = Variable<int>(sessionType);
    map['planned_duration_sec'] = Variable<int>(plannedDurationSec);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || segmentStartedAt != null) {
      map['segment_started_at'] = Variable<DateTime>(segmentStartedAt);
    }
    map['remaining_sec_at_segment_start'] =
        Variable<int>(remainingSecAtSegmentStart);
    map['is_paused'] = Variable<bool>(isPaused);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || actualDurationSec != null) {
      map['actual_duration_sec'] = Variable<int>(actualDurationSec);
    }
    map['ended_early'] = Variable<bool>(endedEarly);
    return map;
  }

  FocusSessionsCompanion toCompanion(bool nullToAbsent) {
    return FocusSessionsCompanion(
      id: Value(id),
      taskId:
          taskId == null && nullToAbsent ? const Value.absent() : Value(taskId),
      subtaskId: subtaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(subtaskId),
      sessionType: Value(sessionType),
      plannedDurationSec: Value(plannedDurationSec),
      startedAt: Value(startedAt),
      segmentStartedAt: segmentStartedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(segmentStartedAt),
      remainingSecAtSegmentStart: Value(remainingSecAtSegmentStart),
      isPaused: Value(isPaused),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      actualDurationSec: actualDurationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDurationSec),
      endedEarly: Value(endedEarly),
    );
  }

  factory FocusSessionsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusSessionsData(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int?>(json['taskId']),
      subtaskId: serializer.fromJson<int?>(json['subtaskId']),
      sessionType: serializer.fromJson<int>(json['sessionType']),
      plannedDurationSec: serializer.fromJson<int>(json['plannedDurationSec']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      segmentStartedAt:
          serializer.fromJson<DateTime?>(json['segmentStartedAt']),
      remainingSecAtSegmentStart:
          serializer.fromJson<int>(json['remainingSecAtSegmentStart']),
      isPaused: serializer.fromJson<bool>(json['isPaused']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      actualDurationSec: serializer.fromJson<int?>(json['actualDurationSec']),
      endedEarly: serializer.fromJson<bool>(json['endedEarly']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<int?>(taskId),
      'subtaskId': serializer.toJson<int?>(subtaskId),
      'sessionType': serializer.toJson<int>(sessionType),
      'plannedDurationSec': serializer.toJson<int>(plannedDurationSec),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'segmentStartedAt': serializer.toJson<DateTime?>(segmentStartedAt),
      'remainingSecAtSegmentStart':
          serializer.toJson<int>(remainingSecAtSegmentStart),
      'isPaused': serializer.toJson<bool>(isPaused),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'actualDurationSec': serializer.toJson<int?>(actualDurationSec),
      'endedEarly': serializer.toJson<bool>(endedEarly),
    };
  }

  FocusSessionsData copyWith(
          {int? id,
          Value<int?> taskId = const Value.absent(),
          Value<int?> subtaskId = const Value.absent(),
          int? sessionType,
          int? plannedDurationSec,
          DateTime? startedAt,
          Value<DateTime?> segmentStartedAt = const Value.absent(),
          int? remainingSecAtSegmentStart,
          bool? isPaused,
          Value<DateTime?> completedAt = const Value.absent(),
          Value<int?> actualDurationSec = const Value.absent(),
          bool? endedEarly}) =>
      FocusSessionsData(
        id: id ?? this.id,
        taskId: taskId.present ? taskId.value : this.taskId,
        subtaskId: subtaskId.present ? subtaskId.value : this.subtaskId,
        sessionType: sessionType ?? this.sessionType,
        plannedDurationSec: plannedDurationSec ?? this.plannedDurationSec,
        startedAt: startedAt ?? this.startedAt,
        segmentStartedAt: segmentStartedAt.present
            ? segmentStartedAt.value
            : this.segmentStartedAt,
        remainingSecAtSegmentStart:
            remainingSecAtSegmentStart ?? this.remainingSecAtSegmentStart,
        isPaused: isPaused ?? this.isPaused,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        actualDurationSec: actualDurationSec.present
            ? actualDurationSec.value
            : this.actualDurationSec,
        endedEarly: endedEarly ?? this.endedEarly,
      );
  FocusSessionsData copyWithCompanion(FocusSessionsCompanion data) {
    return FocusSessionsData(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      subtaskId: data.subtaskId.present ? data.subtaskId.value : this.subtaskId,
      sessionType:
          data.sessionType.present ? data.sessionType.value : this.sessionType,
      plannedDurationSec: data.plannedDurationSec.present
          ? data.plannedDurationSec.value
          : this.plannedDurationSec,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      segmentStartedAt: data.segmentStartedAt.present
          ? data.segmentStartedAt.value
          : this.segmentStartedAt,
      remainingSecAtSegmentStart: data.remainingSecAtSegmentStart.present
          ? data.remainingSecAtSegmentStart.value
          : this.remainingSecAtSegmentStart,
      isPaused: data.isPaused.present ? data.isPaused.value : this.isPaused,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      actualDurationSec: data.actualDurationSec.present
          ? data.actualDurationSec.value
          : this.actualDurationSec,
      endedEarly:
          data.endedEarly.present ? data.endedEarly.value : this.endedEarly,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionsData(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('subtaskId: $subtaskId, ')
          ..write('sessionType: $sessionType, ')
          ..write('plannedDurationSec: $plannedDurationSec, ')
          ..write('startedAt: $startedAt, ')
          ..write('segmentStartedAt: $segmentStartedAt, ')
          ..write('remainingSecAtSegmentStart: $remainingSecAtSegmentStart, ')
          ..write('isPaused: $isPaused, ')
          ..write('completedAt: $completedAt, ')
          ..write('actualDurationSec: $actualDurationSec, ')
          ..write('endedEarly: $endedEarly')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      taskId,
      subtaskId,
      sessionType,
      plannedDurationSec,
      startedAt,
      segmentStartedAt,
      remainingSecAtSegmentStart,
      isPaused,
      completedAt,
      actualDurationSec,
      endedEarly);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusSessionsData &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.subtaskId == this.subtaskId &&
          other.sessionType == this.sessionType &&
          other.plannedDurationSec == this.plannedDurationSec &&
          other.startedAt == this.startedAt &&
          other.segmentStartedAt == this.segmentStartedAt &&
          other.remainingSecAtSegmentStart == this.remainingSecAtSegmentStart &&
          other.isPaused == this.isPaused &&
          other.completedAt == this.completedAt &&
          other.actualDurationSec == this.actualDurationSec &&
          other.endedEarly == this.endedEarly);
}

class FocusSessionsCompanion extends UpdateCompanion<FocusSessionsData> {
  final Value<int> id;
  final Value<int?> taskId;
  final Value<int?> subtaskId;
  final Value<int> sessionType;
  final Value<int> plannedDurationSec;
  final Value<DateTime> startedAt;
  final Value<DateTime?> segmentStartedAt;
  final Value<int> remainingSecAtSegmentStart;
  final Value<bool> isPaused;
  final Value<DateTime?> completedAt;
  final Value<int?> actualDurationSec;
  final Value<bool> endedEarly;
  const FocusSessionsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.subtaskId = const Value.absent(),
    this.sessionType = const Value.absent(),
    this.plannedDurationSec = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.segmentStartedAt = const Value.absent(),
    this.remainingSecAtSegmentStart = const Value.absent(),
    this.isPaused = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.actualDurationSec = const Value.absent(),
    this.endedEarly = const Value.absent(),
  });
  FocusSessionsCompanion.insert({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.subtaskId = const Value.absent(),
    required int sessionType,
    required int plannedDurationSec,
    required DateTime startedAt,
    this.segmentStartedAt = const Value.absent(),
    required int remainingSecAtSegmentStart,
    this.isPaused = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.actualDurationSec = const Value.absent(),
    this.endedEarly = const Value.absent(),
  })  : sessionType = Value(sessionType),
        plannedDurationSec = Value(plannedDurationSec),
        startedAt = Value(startedAt),
        remainingSecAtSegmentStart = Value(remainingSecAtSegmentStart);
  static Insertable<FocusSessionsData> custom({
    Expression<int>? id,
    Expression<int>? taskId,
    Expression<int>? subtaskId,
    Expression<int>? sessionType,
    Expression<int>? plannedDurationSec,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? segmentStartedAt,
    Expression<int>? remainingSecAtSegmentStart,
    Expression<bool>? isPaused,
    Expression<DateTime>? completedAt,
    Expression<int>? actualDurationSec,
    Expression<bool>? endedEarly,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (subtaskId != null) 'subtask_id': subtaskId,
      if (sessionType != null) 'session_type': sessionType,
      if (plannedDurationSec != null)
        'planned_duration_sec': plannedDurationSec,
      if (startedAt != null) 'started_at': startedAt,
      if (segmentStartedAt != null) 'segment_started_at': segmentStartedAt,
      if (remainingSecAtSegmentStart != null)
        'remaining_sec_at_segment_start': remainingSecAtSegmentStart,
      if (isPaused != null) 'is_paused': isPaused,
      if (completedAt != null) 'completed_at': completedAt,
      if (actualDurationSec != null) 'actual_duration_sec': actualDurationSec,
      if (endedEarly != null) 'ended_early': endedEarly,
    });
  }

  FocusSessionsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? taskId,
      Value<int?>? subtaskId,
      Value<int>? sessionType,
      Value<int>? plannedDurationSec,
      Value<DateTime>? startedAt,
      Value<DateTime?>? segmentStartedAt,
      Value<int>? remainingSecAtSegmentStart,
      Value<bool>? isPaused,
      Value<DateTime?>? completedAt,
      Value<int?>? actualDurationSec,
      Value<bool>? endedEarly}) {
    return FocusSessionsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      subtaskId: subtaskId ?? this.subtaskId,
      sessionType: sessionType ?? this.sessionType,
      plannedDurationSec: plannedDurationSec ?? this.plannedDurationSec,
      startedAt: startedAt ?? this.startedAt,
      segmentStartedAt: segmentStartedAt ?? this.segmentStartedAt,
      remainingSecAtSegmentStart:
          remainingSecAtSegmentStart ?? this.remainingSecAtSegmentStart,
      isPaused: isPaused ?? this.isPaused,
      completedAt: completedAt ?? this.completedAt,
      actualDurationSec: actualDurationSec ?? this.actualDurationSec,
      endedEarly: endedEarly ?? this.endedEarly,
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
    if (subtaskId.present) {
      map['subtask_id'] = Variable<int>(subtaskId.value);
    }
    if (sessionType.present) {
      map['session_type'] = Variable<int>(sessionType.value);
    }
    if (plannedDurationSec.present) {
      map['planned_duration_sec'] = Variable<int>(plannedDurationSec.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (segmentStartedAt.present) {
      map['segment_started_at'] = Variable<DateTime>(segmentStartedAt.value);
    }
    if (remainingSecAtSegmentStart.present) {
      map['remaining_sec_at_segment_start'] =
          Variable<int>(remainingSecAtSegmentStart.value);
    }
    if (isPaused.present) {
      map['is_paused'] = Variable<bool>(isPaused.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (actualDurationSec.present) {
      map['actual_duration_sec'] = Variable<int>(actualDurationSec.value);
    }
    if (endedEarly.present) {
      map['ended_early'] = Variable<bool>(endedEarly.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('subtaskId: $subtaskId, ')
          ..write('sessionType: $sessionType, ')
          ..write('plannedDurationSec: $plannedDurationSec, ')
          ..write('startedAt: $startedAt, ')
          ..write('segmentStartedAt: $segmentStartedAt, ')
          ..write('remainingSecAtSegmentStart: $remainingSecAtSegmentStart, ')
          ..write('isPaused: $isPaused, ')
          ..write('completedAt: $completedAt, ')
          ..write('actualDurationSec: $actualDurationSec, ')
          ..write('endedEarly: $endedEarly')
          ..write(')'))
        .toString();
  }
}

class AiProviderConfigs extends Table
    with TableInfo<AiProviderConfigs, AiProviderConfigsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AiProviderConfigs(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> providerId = GeneratedColumn<int>(
      'provider_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> defaultModel = GeneratedColumn<String>(
      'default_model', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> baseUrl = GeneratedColumn<String>(
      'base_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const CustomExpression('0'));
  @override
  List<GeneratedColumn> get $columns =>
      [providerId, displayName, defaultModel, baseUrl, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_provider_configs';
  @override
  Set<GeneratedColumn> get $primaryKey => {providerId};
  @override
  AiProviderConfigsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiProviderConfigsData(
      providerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}provider_id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      defaultModel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}default_model'])!,
      baseUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}base_url']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  AiProviderConfigs createAlias(String alias) {
    return AiProviderConfigs(attachedDatabase, alias);
  }
}

class AiProviderConfigsData extends DataClass
    implements Insertable<AiProviderConfigsData> {
  final int providerId;
  final String displayName;
  final String defaultModel;
  final String? baseUrl;
  final bool isActive;
  const AiProviderConfigsData(
      {required this.providerId,
      required this.displayName,
      required this.defaultModel,
      this.baseUrl,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['provider_id'] = Variable<int>(providerId);
    map['display_name'] = Variable<String>(displayName);
    map['default_model'] = Variable<String>(defaultModel);
    if (!nullToAbsent || baseUrl != null) {
      map['base_url'] = Variable<String>(baseUrl);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  AiProviderConfigsCompanion toCompanion(bool nullToAbsent) {
    return AiProviderConfigsCompanion(
      providerId: Value(providerId),
      displayName: Value(displayName),
      defaultModel: Value(defaultModel),
      baseUrl: baseUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(baseUrl),
      isActive: Value(isActive),
    );
  }

  factory AiProviderConfigsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiProviderConfigsData(
      providerId: serializer.fromJson<int>(json['providerId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      defaultModel: serializer.fromJson<String>(json['defaultModel']),
      baseUrl: serializer.fromJson<String?>(json['baseUrl']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'providerId': serializer.toJson<int>(providerId),
      'displayName': serializer.toJson<String>(displayName),
      'defaultModel': serializer.toJson<String>(defaultModel),
      'baseUrl': serializer.toJson<String?>(baseUrl),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  AiProviderConfigsData copyWith(
          {int? providerId,
          String? displayName,
          String? defaultModel,
          Value<String?> baseUrl = const Value.absent(),
          bool? isActive}) =>
      AiProviderConfigsData(
        providerId: providerId ?? this.providerId,
        displayName: displayName ?? this.displayName,
        defaultModel: defaultModel ?? this.defaultModel,
        baseUrl: baseUrl.present ? baseUrl.value : this.baseUrl,
        isActive: isActive ?? this.isActive,
      );
  AiProviderConfigsData copyWithCompanion(AiProviderConfigsCompanion data) {
    return AiProviderConfigsData(
      providerId:
          data.providerId.present ? data.providerId.value : this.providerId,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      defaultModel: data.defaultModel.present
          ? data.defaultModel.value
          : this.defaultModel,
      baseUrl: data.baseUrl.present ? data.baseUrl.value : this.baseUrl,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiProviderConfigsData(')
          ..write('providerId: $providerId, ')
          ..write('displayName: $displayName, ')
          ..write('defaultModel: $defaultModel, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(providerId, displayName, defaultModel, baseUrl, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiProviderConfigsData &&
          other.providerId == this.providerId &&
          other.displayName == this.displayName &&
          other.defaultModel == this.defaultModel &&
          other.baseUrl == this.baseUrl &&
          other.isActive == this.isActive);
}

class AiProviderConfigsCompanion
    extends UpdateCompanion<AiProviderConfigsData> {
  final Value<int> providerId;
  final Value<String> displayName;
  final Value<String> defaultModel;
  final Value<String?> baseUrl;
  final Value<bool> isActive;
  const AiProviderConfigsCompanion({
    this.providerId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.defaultModel = const Value.absent(),
    this.baseUrl = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  AiProviderConfigsCompanion.insert({
    this.providerId = const Value.absent(),
    required String displayName,
    required String defaultModel,
    this.baseUrl = const Value.absent(),
    this.isActive = const Value.absent(),
  })  : displayName = Value(displayName),
        defaultModel = Value(defaultModel);
  static Insertable<AiProviderConfigsData> custom({
    Expression<int>? providerId,
    Expression<String>? displayName,
    Expression<String>? defaultModel,
    Expression<String>? baseUrl,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (providerId != null) 'provider_id': providerId,
      if (displayName != null) 'display_name': displayName,
      if (defaultModel != null) 'default_model': defaultModel,
      if (baseUrl != null) 'base_url': baseUrl,
      if (isActive != null) 'is_active': isActive,
    });
  }

  AiProviderConfigsCompanion copyWith(
      {Value<int>? providerId,
      Value<String>? displayName,
      Value<String>? defaultModel,
      Value<String?>? baseUrl,
      Value<bool>? isActive}) {
    return AiProviderConfigsCompanion(
      providerId: providerId ?? this.providerId,
      displayName: displayName ?? this.displayName,
      defaultModel: defaultModel ?? this.defaultModel,
      baseUrl: baseUrl ?? this.baseUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (providerId.present) {
      map['provider_id'] = Variable<int>(providerId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (defaultModel.present) {
      map['default_model'] = Variable<String>(defaultModel.value);
    }
    if (baseUrl.present) {
      map['base_url'] = Variable<String>(baseUrl.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiProviderConfigsCompanion(')
          ..write('providerId: $providerId, ')
          ..write('displayName: $displayName, ')
          ..write('defaultModel: $defaultModel, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class AiConversations extends Table
    with TableInfo<AiConversations, AiConversationsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AiConversations(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<int> providerId = GeneratedColumn<int>(
      'provider_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  @override
  List<GeneratedColumn> get $columns => [id, providerId, title, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_conversations';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiConversationsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiConversationsData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      providerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}provider_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  AiConversations createAlias(String alias) {
    return AiConversations(attachedDatabase, alias);
  }
}

class AiConversationsData extends DataClass
    implements Insertable<AiConversationsData> {
  final int id;
  final int providerId;
  final String title;
  final DateTime createdAt;
  const AiConversationsData(
      {required this.id,
      required this.providerId,
      required this.title,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['provider_id'] = Variable<int>(providerId);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AiConversationsCompanion toCompanion(bool nullToAbsent) {
    return AiConversationsCompanion(
      id: Value(id),
      providerId: Value(providerId),
      title: Value(title),
      createdAt: Value(createdAt),
    );
  }

  factory AiConversationsData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiConversationsData(
      id: serializer.fromJson<int>(json['id']),
      providerId: serializer.fromJson<int>(json['providerId']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'providerId': serializer.toJson<int>(providerId),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AiConversationsData copyWith(
          {int? id, int? providerId, String? title, DateTime? createdAt}) =>
      AiConversationsData(
        id: id ?? this.id,
        providerId: providerId ?? this.providerId,
        title: title ?? this.title,
        createdAt: createdAt ?? this.createdAt,
      );
  AiConversationsData copyWithCompanion(AiConversationsCompanion data) {
    return AiConversationsData(
      id: data.id.present ? data.id.value : this.id,
      providerId:
          data.providerId.present ? data.providerId.value : this.providerId,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiConversationsData(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, providerId, title, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiConversationsData &&
          other.id == this.id &&
          other.providerId == this.providerId &&
          other.title == this.title &&
          other.createdAt == this.createdAt);
}

class AiConversationsCompanion extends UpdateCompanion<AiConversationsData> {
  final Value<int> id;
  final Value<int> providerId;
  final Value<String> title;
  final Value<DateTime> createdAt;
  const AiConversationsCompanion({
    this.id = const Value.absent(),
    this.providerId = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AiConversationsCompanion.insert({
    this.id = const Value.absent(),
    required int providerId,
    required String title,
    this.createdAt = const Value.absent(),
  })  : providerId = Value(providerId),
        title = Value(title);
  static Insertable<AiConversationsData> custom({
    Expression<int>? id,
    Expression<int>? providerId,
    Expression<String>? title,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerId != null) 'provider_id': providerId,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AiConversationsCompanion copyWith(
      {Value<int>? id,
      Value<int>? providerId,
      Value<String>? title,
      Value<DateTime>? createdAt}) {
    return AiConversationsCompanion(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<int>(providerId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiConversationsCompanion(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class AiMessages extends Table with TableInfo<AiMessages, AiMessagesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AiMessages(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES ai_conversations (id) ON DELETE CASCADE'));
  late final GeneratedColumn<int> role = GeneratedColumn<int>(
      'role', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<bool> isError = GeneratedColumn<bool>(
      'is_error', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_error" IN (0, 1))'),
      defaultValue: const CustomExpression('0'));
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
      'sent_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, conversationId, role, content, isError, sentAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_messages';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiMessagesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiMessagesData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      conversationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}conversation_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}role'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      isError: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_error'])!,
      sentAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sent_at'])!,
    );
  }

  @override
  AiMessages createAlias(String alias) {
    return AiMessages(attachedDatabase, alias);
  }
}

class AiMessagesData extends DataClass implements Insertable<AiMessagesData> {
  final int id;
  final int conversationId;
  final int role;
  final String content;
  final bool isError;
  final DateTime sentAt;
  const AiMessagesData(
      {required this.id,
      required this.conversationId,
      required this.role,
      required this.content,
      required this.isError,
      required this.sentAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conversation_id'] = Variable<int>(conversationId);
    map['role'] = Variable<int>(role);
    map['content'] = Variable<String>(content);
    map['is_error'] = Variable<bool>(isError);
    map['sent_at'] = Variable<DateTime>(sentAt);
    return map;
  }

  AiMessagesCompanion toCompanion(bool nullToAbsent) {
    return AiMessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      role: Value(role),
      content: Value(content),
      isError: Value(isError),
      sentAt: Value(sentAt),
    );
  }

  factory AiMessagesData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiMessagesData(
      id: serializer.fromJson<int>(json['id']),
      conversationId: serializer.fromJson<int>(json['conversationId']),
      role: serializer.fromJson<int>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      isError: serializer.fromJson<bool>(json['isError']),
      sentAt: serializer.fromJson<DateTime>(json['sentAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conversationId': serializer.toJson<int>(conversationId),
      'role': serializer.toJson<int>(role),
      'content': serializer.toJson<String>(content),
      'isError': serializer.toJson<bool>(isError),
      'sentAt': serializer.toJson<DateTime>(sentAt),
    };
  }

  AiMessagesData copyWith(
          {int? id,
          int? conversationId,
          int? role,
          String? content,
          bool? isError,
          DateTime? sentAt}) =>
      AiMessagesData(
        id: id ?? this.id,
        conversationId: conversationId ?? this.conversationId,
        role: role ?? this.role,
        content: content ?? this.content,
        isError: isError ?? this.isError,
        sentAt: sentAt ?? this.sentAt,
      );
  AiMessagesData copyWithCompanion(AiMessagesCompanion data) {
    return AiMessagesData(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      isError: data.isError.present ? data.isError.value : this.isError,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiMessagesData(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('isError: $isError, ')
          ..write('sentAt: $sentAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, conversationId, role, content, isError, sentAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiMessagesData &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.content == this.content &&
          other.isError == this.isError &&
          other.sentAt == this.sentAt);
}

class AiMessagesCompanion extends UpdateCompanion<AiMessagesData> {
  final Value<int> id;
  final Value<int> conversationId;
  final Value<int> role;
  final Value<String> content;
  final Value<bool> isError;
  final Value<DateTime> sentAt;
  const AiMessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.isError = const Value.absent(),
    this.sentAt = const Value.absent(),
  });
  AiMessagesCompanion.insert({
    this.id = const Value.absent(),
    required int conversationId,
    required int role,
    required String content,
    this.isError = const Value.absent(),
    this.sentAt = const Value.absent(),
  })  : conversationId = Value(conversationId),
        role = Value(role),
        content = Value(content);
  static Insertable<AiMessagesData> custom({
    Expression<int>? id,
    Expression<int>? conversationId,
    Expression<int>? role,
    Expression<String>? content,
    Expression<bool>? isError,
    Expression<DateTime>? sentAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (isError != null) 'is_error': isError,
      if (sentAt != null) 'sent_at': sentAt,
    });
  }

  AiMessagesCompanion copyWith(
      {Value<int>? id,
      Value<int>? conversationId,
      Value<int>? role,
      Value<String>? content,
      Value<bool>? isError,
      Value<DateTime>? sentAt}) {
    return AiMessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      isError: isError ?? this.isError,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (role.present) {
      map['role'] = Variable<int>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (isError.present) {
      map['is_error'] = Variable<bool>(isError.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiMessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('isError: $isError, ')
          ..write('sentAt: $sentAt')
          ..write(')'))
        .toString();
  }
}

class DatabaseAtV3 extends GeneratedDatabase {
  DatabaseAtV3(QueryExecutor e) : super(e);
  late final Tasks tasks = Tasks(this);
  late final Subtasks subtasks = Subtasks(this);
  late final ScheduleBlocks scheduleBlocks = ScheduleBlocks(this);
  late final FocusSessions focusSessions = FocusSessions(this);
  late final AiProviderConfigs aiProviderConfigs = AiProviderConfigs(this);
  late final AiConversations aiConversations = AiConversations(this);
  late final AiMessages aiMessages = AiMessages(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        tasks,
        subtasks,
        scheduleBlocks,
        focusSessions,
        aiProviderConfigs,
        aiConversations,
        aiMessages
      ];
  @override
  int get schemaVersion => 3;
}
