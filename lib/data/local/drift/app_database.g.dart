// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppSettingsEntriesTable extends AppSettingsEntries
    with TableInfo<$AppSettingsEntriesTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSettingRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppSettingsEntriesTable createAlias(String alias) {
    return $AppSettingsEntriesTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String key;
  final String value;
  const AppSettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsEntriesCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsEntriesCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppSettingRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingRow copyWith({String? key, String? value}) => AppSettingRow(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppSettingRow copyWithCompanion(AppSettingsEntriesCompanion data) {
    return AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsEntriesCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsEntriesCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppSettingsEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduleBlocksTable extends ScheduleBlocks
    with TableInfo<$ScheduleBlocksTable, ScheduleBlockRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleBlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, false,
      check: () => ComparableExpr(endTime).isBiggerThan(startTime),
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<ScheduleBlockSource, int> source =
      GeneratedColumn<int>('source', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(0))
          .withConverter<ScheduleBlockSource>(
              $ScheduleBlocksTable.$convertersource);
  static const VerificationMeta _isLockedMeta =
      const VerificationMeta('isLocked');
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
      'is_locked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_locked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _recurrenceMeta =
      const VerificationMeta('recurrence');
  @override
  late final GeneratedColumn<String> recurrence = GeneratedColumn<String>(
      'recurrence', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recurrenceUntilMeta =
      const VerificationMeta('recurrenceUntil');
  @override
  late final GeneratedColumn<DateTime> recurrenceUntil =
      GeneratedColumn<DateTime>('recurrence_until', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _seriesIdMeta =
      const VerificationMeta('seriesId');
  @override
  late final GeneratedColumn<int> seriesId = GeneratedColumn<int>(
      'series_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES schedule_blocks (id) ON DELETE CASCADE'));
  static const VerificationMeta _occurrenceDateMeta =
      const VerificationMeta('occurrenceDate');
  @override
  late final GeneratedColumn<DateTime> occurrenceDate =
      GeneratedColumn<DateTime>('occurrence_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        startTime,
        endTime,
        source,
        isLocked,
        recurrence,
        recurrenceUntil,
        seriesId,
        occurrenceDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_blocks';
  @override
  VerificationContext validateIntegrity(Insertable<ScheduleBlockRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('is_locked')) {
      context.handle(_isLockedMeta,
          isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta));
    }
    if (data.containsKey('recurrence')) {
      context.handle(
          _recurrenceMeta,
          recurrence.isAcceptableOrUnknown(
              data['recurrence']!, _recurrenceMeta));
    }
    if (data.containsKey('recurrence_until')) {
      context.handle(
          _recurrenceUntilMeta,
          recurrenceUntil.isAcceptableOrUnknown(
              data['recurrence_until']!, _recurrenceUntilMeta));
    }
    if (data.containsKey('series_id')) {
      context.handle(_seriesIdMeta,
          seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta));
    }
    if (data.containsKey('occurrence_date')) {
      context.handle(
          _occurrenceDateMeta,
          occurrenceDate.isAcceptableOrUnknown(
              data['occurrence_date']!, _occurrenceDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleBlockRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleBlockRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time'])!,
      source: $ScheduleBlocksTable.$convertersource.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source'])!),
      isLocked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_locked'])!,
      recurrence: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recurrence']),
      recurrenceUntil: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}recurrence_until']),
      seriesId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}series_id']),
      occurrenceDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}occurrence_date']),
    );
  }

  @override
  $ScheduleBlocksTable createAlias(String alias) {
    return $ScheduleBlocksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ScheduleBlockSource, int, int> $convertersource =
      const EnumIndexConverter<ScheduleBlockSource>(ScheduleBlockSource.values);
}

class ScheduleBlockRow extends DataClass
    implements Insertable<ScheduleBlockRow> {
  final int id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final ScheduleBlockSource source;
  final bool isLocked;
  final String? recurrence;

  /// Last day (local midnight) a series occurs on; null = no end.
  final DateTime? recurrenceUntil;
  final int? seriesId;

  /// The day (local midnight) this stored occurrence replaces in its
  /// series, even if it was moved to another time.
  final DateTime? occurrenceDate;
  const ScheduleBlockRow(
      {required this.id,
      required this.title,
      required this.startTime,
      required this.endTime,
      required this.source,
      required this.isLocked,
      this.recurrence,
      this.recurrenceUntil,
      this.seriesId,
      this.occurrenceDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['start_time'] = Variable<DateTime>(startTime);
    map['end_time'] = Variable<DateTime>(endTime);
    {
      map['source'] =
          Variable<int>($ScheduleBlocksTable.$convertersource.toSql(source));
    }
    map['is_locked'] = Variable<bool>(isLocked);
    if (!nullToAbsent || recurrence != null) {
      map['recurrence'] = Variable<String>(recurrence);
    }
    if (!nullToAbsent || recurrenceUntil != null) {
      map['recurrence_until'] = Variable<DateTime>(recurrenceUntil);
    }
    if (!nullToAbsent || seriesId != null) {
      map['series_id'] = Variable<int>(seriesId);
    }
    if (!nullToAbsent || occurrenceDate != null) {
      map['occurrence_date'] = Variable<DateTime>(occurrenceDate);
    }
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
      recurrence: recurrence == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrence),
      recurrenceUntil: recurrenceUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceUntil),
      seriesId: seriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesId),
      occurrenceDate: occurrenceDate == null && nullToAbsent
          ? const Value.absent()
          : Value(occurrenceDate),
    );
  }

  factory ScheduleBlockRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleBlockRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime>(json['endTime']),
      source: $ScheduleBlocksTable.$convertersource
          .fromJson(serializer.fromJson<int>(json['source'])),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
      recurrence: serializer.fromJson<String?>(json['recurrence']),
      recurrenceUntil: serializer.fromJson<DateTime?>(json['recurrenceUntil']),
      seriesId: serializer.fromJson<int?>(json['seriesId']),
      occurrenceDate: serializer.fromJson<DateTime?>(json['occurrenceDate']),
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
      'source': serializer
          .toJson<int>($ScheduleBlocksTable.$convertersource.toJson(source)),
      'isLocked': serializer.toJson<bool>(isLocked),
      'recurrence': serializer.toJson<String?>(recurrence),
      'recurrenceUntil': serializer.toJson<DateTime?>(recurrenceUntil),
      'seriesId': serializer.toJson<int?>(seriesId),
      'occurrenceDate': serializer.toJson<DateTime?>(occurrenceDate),
    };
  }

  ScheduleBlockRow copyWith(
          {int? id,
          String? title,
          DateTime? startTime,
          DateTime? endTime,
          ScheduleBlockSource? source,
          bool? isLocked,
          Value<String?> recurrence = const Value.absent(),
          Value<DateTime?> recurrenceUntil = const Value.absent(),
          Value<int?> seriesId = const Value.absent(),
          Value<DateTime?> occurrenceDate = const Value.absent()}) =>
      ScheduleBlockRow(
        id: id ?? this.id,
        title: title ?? this.title,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        source: source ?? this.source,
        isLocked: isLocked ?? this.isLocked,
        recurrence: recurrence.present ? recurrence.value : this.recurrence,
        recurrenceUntil: recurrenceUntil.present
            ? recurrenceUntil.value
            : this.recurrenceUntil,
        seriesId: seriesId.present ? seriesId.value : this.seriesId,
        occurrenceDate:
            occurrenceDate.present ? occurrenceDate.value : this.occurrenceDate,
      );
  ScheduleBlockRow copyWithCompanion(ScheduleBlocksCompanion data) {
    return ScheduleBlockRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      source: data.source.present ? data.source.value : this.source,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
      recurrence:
          data.recurrence.present ? data.recurrence.value : this.recurrence,
      recurrenceUntil: data.recurrenceUntil.present
          ? data.recurrenceUntil.value
          : this.recurrenceUntil,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      occurrenceDate: data.occurrenceDate.present
          ? data.occurrenceDate.value
          : this.occurrenceDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleBlockRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('source: $source, ')
          ..write('isLocked: $isLocked, ')
          ..write('recurrence: $recurrence, ')
          ..write('recurrenceUntil: $recurrenceUntil, ')
          ..write('seriesId: $seriesId, ')
          ..write('occurrenceDate: $occurrenceDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, startTime, endTime, source,
      isLocked, recurrence, recurrenceUntil, seriesId, occurrenceDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleBlockRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.source == this.source &&
          other.isLocked == this.isLocked &&
          other.recurrence == this.recurrence &&
          other.recurrenceUntil == this.recurrenceUntil &&
          other.seriesId == this.seriesId &&
          other.occurrenceDate == this.occurrenceDate);
}

class ScheduleBlocksCompanion extends UpdateCompanion<ScheduleBlockRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<DateTime> startTime;
  final Value<DateTime> endTime;
  final Value<ScheduleBlockSource> source;
  final Value<bool> isLocked;
  final Value<String?> recurrence;
  final Value<DateTime?> recurrenceUntil;
  final Value<int?> seriesId;
  final Value<DateTime?> occurrenceDate;
  const ScheduleBlocksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.source = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.recurrenceUntil = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.occurrenceDate = const Value.absent(),
  });
  ScheduleBlocksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    this.source = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.recurrenceUntil = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.occurrenceDate = const Value.absent(),
  })  : title = Value(title),
        startTime = Value(startTime),
        endTime = Value(endTime);
  static Insertable<ScheduleBlockRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? source,
    Expression<bool>? isLocked,
    Expression<String>? recurrence,
    Expression<DateTime>? recurrenceUntil,
    Expression<int>? seriesId,
    Expression<DateTime>? occurrenceDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (source != null) 'source': source,
      if (isLocked != null) 'is_locked': isLocked,
      if (recurrence != null) 'recurrence': recurrence,
      if (recurrenceUntil != null) 'recurrence_until': recurrenceUntil,
      if (seriesId != null) 'series_id': seriesId,
      if (occurrenceDate != null) 'occurrence_date': occurrenceDate,
    });
  }

  ScheduleBlocksCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<DateTime>? startTime,
      Value<DateTime>? endTime,
      Value<ScheduleBlockSource>? source,
      Value<bool>? isLocked,
      Value<String?>? recurrence,
      Value<DateTime?>? recurrenceUntil,
      Value<int?>? seriesId,
      Value<DateTime?>? occurrenceDate}) {
    return ScheduleBlocksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      source: source ?? this.source,
      isLocked: isLocked ?? this.isLocked,
      recurrence: recurrence ?? this.recurrence,
      recurrenceUntil: recurrenceUntil ?? this.recurrenceUntil,
      seriesId: seriesId ?? this.seriesId,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
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
      map['source'] = Variable<int>(
          $ScheduleBlocksTable.$convertersource.toSql(source.value));
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(recurrence.value);
    }
    if (recurrenceUntil.present) {
      map['recurrence_until'] = Variable<DateTime>(recurrenceUntil.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<int>(seriesId.value);
    }
    if (occurrenceDate.present) {
      map['occurrence_date'] = Variable<DateTime>(occurrenceDate.value);
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
          ..write('isLocked: $isLocked, ')
          ..write('recurrence: $recurrence, ')
          ..write('recurrenceUntil: $recurrenceUntil, ')
          ..write('seriesId: $seriesId, ')
          ..write('occurrenceDate: $occurrenceDate')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _scheduleBlockIdMeta =
      const VerificationMeta('scheduleBlockId');
  @override
  late final GeneratedColumn<int> scheduleBlockId = GeneratedColumn<int>(
      'schedule_block_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES schedule_blocks (id) ON DELETE SET NULL'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  late final GeneratedColumnWithTypeConverter<TaskPriority, int> priority =
      GeneratedColumn<int>('priority', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<TaskPriority>($TasksTable.$converterpriority);
  @override
  late final GeneratedColumnWithTypeConverter<TaskStatus, int> status =
      GeneratedColumn<int>('status', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<TaskStatus>($TasksTable.$converterstatus);
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
      'due_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, scheduleBlockId, title, notes, priority, status, dueAt, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<TaskRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('schedule_block_id')) {
      context.handle(
          _scheduleBlockIdMeta,
          scheduleBlockId.isAcceptableOrUnknown(
              data['schedule_block_id']!, _scheduleBlockIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('due_at')) {
      context.handle(
          _dueAtMeta, dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      scheduleBlockId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}schedule_block_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      priority: $TasksTable.$converterpriority.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!),
      status: $TasksTable.$converterstatus.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!),
      dueAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TaskPriority, int, int> $converterpriority =
      const EnumIndexConverter<TaskPriority>(TaskPriority.values);
  static JsonTypeConverter2<TaskStatus, int, int> $converterstatus =
      const EnumIndexConverter<TaskStatus>(TaskStatus.values);
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  final int id;
  final int? scheduleBlockId;
  final String title;
  final String notes;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueAt;
  final DateTime createdAt;
  const TaskRow(
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
    {
      map['priority'] =
          Variable<int>($TasksTable.$converterpriority.toSql(priority));
    }
    {
      map['status'] = Variable<int>($TasksTable.$converterstatus.toSql(status));
    }
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

  factory TaskRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      id: serializer.fromJson<int>(json['id']),
      scheduleBlockId: serializer.fromJson<int?>(json['scheduleBlockId']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String>(json['notes']),
      priority: $TasksTable.$converterpriority
          .fromJson(serializer.fromJson<int>(json['priority'])),
      status: $TasksTable.$converterstatus
          .fromJson(serializer.fromJson<int>(json['status'])),
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
      'priority': serializer
          .toJson<int>($TasksTable.$converterpriority.toJson(priority)),
      'status':
          serializer.toJson<int>($TasksTable.$converterstatus.toJson(status)),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TaskRow copyWith(
          {int? id,
          Value<int?> scheduleBlockId = const Value.absent(),
          String? title,
          String? notes,
          TaskPriority? priority,
          TaskStatus? status,
          Value<DateTime?> dueAt = const Value.absent(),
          DateTime? createdAt}) =>
      TaskRow(
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
  TaskRow copyWithCompanion(TasksCompanion data) {
    return TaskRow(
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
    return (StringBuffer('TaskRow(')
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
      (other is TaskRow &&
          other.id == this.id &&
          other.scheduleBlockId == this.scheduleBlockId &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.dueAt == this.dueAt &&
          other.createdAt == this.createdAt);
}

class TasksCompanion extends UpdateCompanion<TaskRow> {
  final Value<int> id;
  final Value<int?> scheduleBlockId;
  final Value<String> title;
  final Value<String> notes;
  final Value<TaskPriority> priority;
  final Value<TaskStatus> status;
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
    required TaskPriority priority,
    required TaskStatus status,
    this.dueAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : title = Value(title),
        priority = Value(priority),
        status = Value(status);
  static Insertable<TaskRow> custom({
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
      Value<TaskPriority>? priority,
      Value<TaskStatus>? status,
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
      map['priority'] =
          Variable<int>($TasksTable.$converterpriority.toSql(priority.value));
    }
    if (status.present) {
      map['status'] =
          Variable<int>($TasksTable.$converterstatus.toSql(status.value));
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

class $SubtasksTable extends Subtasks
    with TableInfo<$SubtasksTable, SubtaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubtasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
      'task_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tasks (id) ON DELETE CASCADE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<SubtaskStatus, int> status =
      GeneratedColumn<int>('status', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<SubtaskStatus>($SubtasksTable.$converterstatus);
  static const VerificationMeta _plannedSprintsMeta =
      const VerificationMeta('plannedSprints');
  @override
  late final GeneratedColumn<int> plannedSprints = GeneratedColumn<int>(
      'planned_sprints', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _completedSprintsMeta =
      const VerificationMeta('completedSprints');
  @override
  late final GeneratedColumn<int> completedSprints = GeneratedColumn<int>(
      'completed_sprints', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, taskId, title, status, plannedSprints, completedSprints, orderIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subtasks';
  @override
  VerificationContext validateIntegrity(Insertable<SubtaskRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('planned_sprints')) {
      context.handle(
          _plannedSprintsMeta,
          plannedSprints.isAcceptableOrUnknown(
              data['planned_sprints']!, _plannedSprintsMeta));
    }
    if (data.containsKey('completed_sprints')) {
      context.handle(
          _completedSprintsMeta,
          completedSprints.isAcceptableOrUnknown(
              data['completed_sprints']!, _completedSprintsMeta));
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubtaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubtaskRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}task_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      status: $SubtasksTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!),
      plannedSprints: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}planned_sprints'])!,
      completedSprints: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}completed_sprints'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
    );
  }

  @override
  $SubtasksTable createAlias(String alias) {
    return $SubtasksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SubtaskStatus, int, int> $converterstatus =
      const EnumIndexConverter<SubtaskStatus>(SubtaskStatus.values);
}

class SubtaskRow extends DataClass implements Insertable<SubtaskRow> {
  final int id;
  final int taskId;
  final String title;
  final SubtaskStatus status;
  final int plannedSprints;
  final int completedSprints;
  final int orderIndex;
  const SubtaskRow(
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
    {
      map['status'] =
          Variable<int>($SubtasksTable.$converterstatus.toSql(status));
    }
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

  factory SubtaskRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubtaskRow(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int>(json['taskId']),
      title: serializer.fromJson<String>(json['title']),
      status: $SubtasksTable.$converterstatus
          .fromJson(serializer.fromJson<int>(json['status'])),
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
      'status': serializer
          .toJson<int>($SubtasksTable.$converterstatus.toJson(status)),
      'plannedSprints': serializer.toJson<int>(plannedSprints),
      'completedSprints': serializer.toJson<int>(completedSprints),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  SubtaskRow copyWith(
          {int? id,
          int? taskId,
          String? title,
          SubtaskStatus? status,
          int? plannedSprints,
          int? completedSprints,
          int? orderIndex}) =>
      SubtaskRow(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        title: title ?? this.title,
        status: status ?? this.status,
        plannedSprints: plannedSprints ?? this.plannedSprints,
        completedSprints: completedSprints ?? this.completedSprints,
        orderIndex: orderIndex ?? this.orderIndex,
      );
  SubtaskRow copyWithCompanion(SubtasksCompanion data) {
    return SubtaskRow(
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
    return (StringBuffer('SubtaskRow(')
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
      (other is SubtaskRow &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.title == this.title &&
          other.status == this.status &&
          other.plannedSprints == this.plannedSprints &&
          other.completedSprints == this.completedSprints &&
          other.orderIndex == this.orderIndex);
}

class SubtasksCompanion extends UpdateCompanion<SubtaskRow> {
  final Value<int> id;
  final Value<int> taskId;
  final Value<String> title;
  final Value<SubtaskStatus> status;
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
    required SubtaskStatus status,
    this.plannedSprints = const Value.absent(),
    this.completedSprints = const Value.absent(),
    this.orderIndex = const Value.absent(),
  })  : taskId = Value(taskId),
        title = Value(title),
        status = Value(status);
  static Insertable<SubtaskRow> custom({
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
      Value<SubtaskStatus>? status,
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
      map['status'] =
          Variable<int>($SubtasksTable.$converterstatus.toSql(status.value));
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

class $ScheduleBlockExceptionsTable extends ScheduleBlockExceptions
    with TableInfo<$ScheduleBlockExceptionsTable, ScheduleBlockExceptionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleBlockExceptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seriesIdMeta =
      const VerificationMeta('seriesId');
  @override
  late final GeneratedColumn<int> seriesId = GeneratedColumn<int>(
      'series_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES schedule_blocks (id) ON DELETE CASCADE'));
  static const VerificationMeta _occurrenceDateMeta =
      const VerificationMeta('occurrenceDate');
  @override
  late final GeneratedColumn<DateTime> occurrenceDate =
      GeneratedColumn<DateTime>('occurrence_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [seriesId, occurrenceDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_block_exceptions';
  @override
  VerificationContext validateIntegrity(
      Insertable<ScheduleBlockExceptionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('series_id')) {
      context.handle(_seriesIdMeta,
          seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta));
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    if (data.containsKey('occurrence_date')) {
      context.handle(
          _occurrenceDateMeta,
          occurrenceDate.isAcceptableOrUnknown(
              data['occurrence_date']!, _occurrenceDateMeta));
    } else if (isInserting) {
      context.missing(_occurrenceDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seriesId, occurrenceDate};
  @override
  ScheduleBlockExceptionRow map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleBlockExceptionRow(
      seriesId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}series_id'])!,
      occurrenceDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}occurrence_date'])!,
    );
  }

  @override
  $ScheduleBlockExceptionsTable createAlias(String alias) {
    return $ScheduleBlockExceptionsTable(attachedDatabase, alias);
  }
}

class ScheduleBlockExceptionRow extends DataClass
    implements Insertable<ScheduleBlockExceptionRow> {
  final int seriesId;
  final DateTime occurrenceDate;
  const ScheduleBlockExceptionRow(
      {required this.seriesId, required this.occurrenceDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['series_id'] = Variable<int>(seriesId);
    map['occurrence_date'] = Variable<DateTime>(occurrenceDate);
    return map;
  }

  ScheduleBlockExceptionsCompanion toCompanion(bool nullToAbsent) {
    return ScheduleBlockExceptionsCompanion(
      seriesId: Value(seriesId),
      occurrenceDate: Value(occurrenceDate),
    );
  }

  factory ScheduleBlockExceptionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleBlockExceptionRow(
      seriesId: serializer.fromJson<int>(json['seriesId']),
      occurrenceDate: serializer.fromJson<DateTime>(json['occurrenceDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seriesId': serializer.toJson<int>(seriesId),
      'occurrenceDate': serializer.toJson<DateTime>(occurrenceDate),
    };
  }

  ScheduleBlockExceptionRow copyWith(
          {int? seriesId, DateTime? occurrenceDate}) =>
      ScheduleBlockExceptionRow(
        seriesId: seriesId ?? this.seriesId,
        occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      );
  ScheduleBlockExceptionRow copyWithCompanion(
      ScheduleBlockExceptionsCompanion data) {
    return ScheduleBlockExceptionRow(
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      occurrenceDate: data.occurrenceDate.present
          ? data.occurrenceDate.value
          : this.occurrenceDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleBlockExceptionRow(')
          ..write('seriesId: $seriesId, ')
          ..write('occurrenceDate: $occurrenceDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(seriesId, occurrenceDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleBlockExceptionRow &&
          other.seriesId == this.seriesId &&
          other.occurrenceDate == this.occurrenceDate);
}

class ScheduleBlockExceptionsCompanion
    extends UpdateCompanion<ScheduleBlockExceptionRow> {
  final Value<int> seriesId;
  final Value<DateTime> occurrenceDate;
  final Value<int> rowid;
  const ScheduleBlockExceptionsCompanion({
    this.seriesId = const Value.absent(),
    this.occurrenceDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduleBlockExceptionsCompanion.insert({
    required int seriesId,
    required DateTime occurrenceDate,
    this.rowid = const Value.absent(),
  })  : seriesId = Value(seriesId),
        occurrenceDate = Value(occurrenceDate);
  static Insertable<ScheduleBlockExceptionRow> custom({
    Expression<int>? seriesId,
    Expression<DateTime>? occurrenceDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (seriesId != null) 'series_id': seriesId,
      if (occurrenceDate != null) 'occurrence_date': occurrenceDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduleBlockExceptionsCompanion copyWith(
      {Value<int>? seriesId,
      Value<DateTime>? occurrenceDate,
      Value<int>? rowid}) {
    return ScheduleBlockExceptionsCompanion(
      seriesId: seriesId ?? this.seriesId,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seriesId.present) {
      map['series_id'] = Variable<int>(seriesId.value);
    }
    if (occurrenceDate.present) {
      map['occurrence_date'] = Variable<DateTime>(occurrenceDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleBlockExceptionsCompanion(')
          ..write('seriesId: $seriesId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FocusSessionsTable extends FocusSessions
    with TableInfo<$FocusSessionsTable, FocusSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
      'task_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tasks (id) ON DELETE SET NULL'));
  static const VerificationMeta _subtaskIdMeta =
      const VerificationMeta('subtaskId');
  @override
  late final GeneratedColumn<int> subtaskId = GeneratedColumn<int>(
      'subtask_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES subtasks (id) ON DELETE SET NULL'));
  @override
  late final GeneratedColumnWithTypeConverter<FocusSessionType, int>
      sessionType = GeneratedColumn<int>('session_type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<FocusSessionType>(
              $FocusSessionsTable.$convertersessionType);
  static const VerificationMeta _plannedDurationSecMeta =
      const VerificationMeta('plannedDurationSec');
  @override
  late final GeneratedColumn<int> plannedDurationSec = GeneratedColumn<int>(
      'planned_duration_sec', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _segmentStartedAtMeta =
      const VerificationMeta('segmentStartedAt');
  @override
  late final GeneratedColumn<DateTime> segmentStartedAt =
      GeneratedColumn<DateTime>('segment_started_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _remainingSecAtSegmentStartMeta =
      const VerificationMeta('remainingSecAtSegmentStart');
  @override
  late final GeneratedColumn<int> remainingSecAtSegmentStart =
      GeneratedColumn<int>('remaining_sec_at_segment_start', aliasedName, false,
          type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isPausedMeta =
      const VerificationMeta('isPaused');
  @override
  late final GeneratedColumn<bool> isPaused = GeneratedColumn<bool>(
      'is_paused', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_paused" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _actualDurationSecMeta =
      const VerificationMeta('actualDurationSec');
  @override
  late final GeneratedColumn<int> actualDurationSec = GeneratedColumn<int>(
      'actual_duration_sec', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _endedEarlyMeta =
      const VerificationMeta('endedEarly');
  @override
  late final GeneratedColumn<bool> endedEarly = GeneratedColumn<bool>(
      'ended_early', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("ended_early" IN (0, 1))'),
      defaultValue: const Constant(false));
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
  VerificationContext validateIntegrity(Insertable<FocusSessionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    }
    if (data.containsKey('subtask_id')) {
      context.handle(_subtaskIdMeta,
          subtaskId.isAcceptableOrUnknown(data['subtask_id']!, _subtaskIdMeta));
    }
    if (data.containsKey('planned_duration_sec')) {
      context.handle(
          _plannedDurationSecMeta,
          plannedDurationSec.isAcceptableOrUnknown(
              data['planned_duration_sec']!, _plannedDurationSecMeta));
    } else if (isInserting) {
      context.missing(_plannedDurationSecMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('segment_started_at')) {
      context.handle(
          _segmentStartedAtMeta,
          segmentStartedAt.isAcceptableOrUnknown(
              data['segment_started_at']!, _segmentStartedAtMeta));
    }
    if (data.containsKey('remaining_sec_at_segment_start')) {
      context.handle(
          _remainingSecAtSegmentStartMeta,
          remainingSecAtSegmentStart.isAcceptableOrUnknown(
              data['remaining_sec_at_segment_start']!,
              _remainingSecAtSegmentStartMeta));
    } else if (isInserting) {
      context.missing(_remainingSecAtSegmentStartMeta);
    }
    if (data.containsKey('is_paused')) {
      context.handle(_isPausedMeta,
          isPaused.isAcceptableOrUnknown(data['is_paused']!, _isPausedMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('actual_duration_sec')) {
      context.handle(
          _actualDurationSecMeta,
          actualDurationSec.isAcceptableOrUnknown(
              data['actual_duration_sec']!, _actualDurationSecMeta));
    }
    if (data.containsKey('ended_early')) {
      context.handle(
          _endedEarlyMeta,
          endedEarly.isAcceptableOrUnknown(
              data['ended_early']!, _endedEarlyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FocusSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusSessionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}task_id']),
      subtaskId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subtask_id']),
      sessionType: $FocusSessionsTable.$convertersessionType.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}session_type'])!),
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
  $FocusSessionsTable createAlias(String alias) {
    return $FocusSessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FocusSessionType, int, int> $convertersessionType =
      const EnumIndexConverter<FocusSessionType>(FocusSessionType.values);
}

class FocusSessionRow extends DataClass implements Insertable<FocusSessionRow> {
  final int id;
  final int? taskId;
  final int? subtaskId;
  final FocusSessionType sessionType;
  final int plannedDurationSec;
  final DateTime startedAt;
  final DateTime? segmentStartedAt;
  final int remainingSecAtSegmentStart;
  final bool isPaused;
  final DateTime? completedAt;
  final int? actualDurationSec;
  final bool endedEarly;
  const FocusSessionRow(
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
    {
      map['session_type'] = Variable<int>(
          $FocusSessionsTable.$convertersessionType.toSql(sessionType));
    }
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

  factory FocusSessionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusSessionRow(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int?>(json['taskId']),
      subtaskId: serializer.fromJson<int?>(json['subtaskId']),
      sessionType: $FocusSessionsTable.$convertersessionType
          .fromJson(serializer.fromJson<int>(json['sessionType'])),
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
      'sessionType': serializer.toJson<int>(
          $FocusSessionsTable.$convertersessionType.toJson(sessionType)),
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

  FocusSessionRow copyWith(
          {int? id,
          Value<int?> taskId = const Value.absent(),
          Value<int?> subtaskId = const Value.absent(),
          FocusSessionType? sessionType,
          int? plannedDurationSec,
          DateTime? startedAt,
          Value<DateTime?> segmentStartedAt = const Value.absent(),
          int? remainingSecAtSegmentStart,
          bool? isPaused,
          Value<DateTime?> completedAt = const Value.absent(),
          Value<int?> actualDurationSec = const Value.absent(),
          bool? endedEarly}) =>
      FocusSessionRow(
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
  FocusSessionRow copyWithCompanion(FocusSessionsCompanion data) {
    return FocusSessionRow(
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
    return (StringBuffer('FocusSessionRow(')
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
      (other is FocusSessionRow &&
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

class FocusSessionsCompanion extends UpdateCompanion<FocusSessionRow> {
  final Value<int> id;
  final Value<int?> taskId;
  final Value<int?> subtaskId;
  final Value<FocusSessionType> sessionType;
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
    required FocusSessionType sessionType,
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
  static Insertable<FocusSessionRow> custom({
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
      Value<FocusSessionType>? sessionType,
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
      map['session_type'] = Variable<int>(
          $FocusSessionsTable.$convertersessionType.toSql(sessionType.value));
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

class $AiProviderConfigsTable extends AiProviderConfigs
    with TableInfo<$AiProviderConfigsTable, AiProviderConfigRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiProviderConfigsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<AIProviderId, int> providerId =
      GeneratedColumn<int>('provider_id', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<AIProviderId>(
              $AiProviderConfigsTable.$converterproviderId);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _defaultModelMeta =
      const VerificationMeta('defaultModel');
  @override
  late final GeneratedColumn<String> defaultModel = GeneratedColumn<String>(
      'default_model', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _baseUrlMeta =
      const VerificationMeta('baseUrl');
  @override
  late final GeneratedColumn<String> baseUrl = GeneratedColumn<String>(
      'base_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [providerId, displayName, defaultModel, baseUrl, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_provider_configs';
  @override
  VerificationContext validateIntegrity(
      Insertable<AiProviderConfigRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('default_model')) {
      context.handle(
          _defaultModelMeta,
          defaultModel.isAcceptableOrUnknown(
              data['default_model']!, _defaultModelMeta));
    } else if (isInserting) {
      context.missing(_defaultModelMeta);
    }
    if (data.containsKey('base_url')) {
      context.handle(_baseUrlMeta,
          baseUrl.isAcceptableOrUnknown(data['base_url']!, _baseUrlMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {providerId};
  @override
  AiProviderConfigRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiProviderConfigRow(
      providerId: $AiProviderConfigsTable.$converterproviderId.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}provider_id'])!),
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
  $AiProviderConfigsTable createAlias(String alias) {
    return $AiProviderConfigsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AIProviderId, int, int> $converterproviderId =
      const EnumIndexConverter<AIProviderId>(AIProviderId.values);
}

class AiProviderConfigRow extends DataClass
    implements Insertable<AiProviderConfigRow> {
  final AIProviderId providerId;
  final String displayName;
  final String defaultModel;
  final String? baseUrl;
  final bool isActive;
  const AiProviderConfigRow(
      {required this.providerId,
      required this.displayName,
      required this.defaultModel,
      this.baseUrl,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['provider_id'] = Variable<int>(
          $AiProviderConfigsTable.$converterproviderId.toSql(providerId));
    }
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

  factory AiProviderConfigRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiProviderConfigRow(
      providerId: $AiProviderConfigsTable.$converterproviderId
          .fromJson(serializer.fromJson<int>(json['providerId'])),
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
      'providerId': serializer.toJson<int>(
          $AiProviderConfigsTable.$converterproviderId.toJson(providerId)),
      'displayName': serializer.toJson<String>(displayName),
      'defaultModel': serializer.toJson<String>(defaultModel),
      'baseUrl': serializer.toJson<String?>(baseUrl),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  AiProviderConfigRow copyWith(
          {AIProviderId? providerId,
          String? displayName,
          String? defaultModel,
          Value<String?> baseUrl = const Value.absent(),
          bool? isActive}) =>
      AiProviderConfigRow(
        providerId: providerId ?? this.providerId,
        displayName: displayName ?? this.displayName,
        defaultModel: defaultModel ?? this.defaultModel,
        baseUrl: baseUrl.present ? baseUrl.value : this.baseUrl,
        isActive: isActive ?? this.isActive,
      );
  AiProviderConfigRow copyWithCompanion(AiProviderConfigsCompanion data) {
    return AiProviderConfigRow(
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
    return (StringBuffer('AiProviderConfigRow(')
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
      (other is AiProviderConfigRow &&
          other.providerId == this.providerId &&
          other.displayName == this.displayName &&
          other.defaultModel == this.defaultModel &&
          other.baseUrl == this.baseUrl &&
          other.isActive == this.isActive);
}

class AiProviderConfigsCompanion extends UpdateCompanion<AiProviderConfigRow> {
  final Value<AIProviderId> providerId;
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
  static Insertable<AiProviderConfigRow> custom({
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
      {Value<AIProviderId>? providerId,
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
      map['provider_id'] = Variable<int>(
          $AiProviderConfigsTable.$converterproviderId.toSql(providerId.value));
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

class $AiConversationsTable extends AiConversations
    with TableInfo<$AiConversationsTable, AiConversationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  @override
  late final GeneratedColumnWithTypeConverter<AIProviderId, int> providerId =
      GeneratedColumn<int>('provider_id', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<AIProviderId>(
              $AiConversationsTable.$converterproviderId);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, providerId, title, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_conversations';
  @override
  VerificationContext validateIntegrity(Insertable<AiConversationRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiConversationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiConversationRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      providerId: $AiConversationsTable.$converterproviderId.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}provider_id'])!),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AiConversationsTable createAlias(String alias) {
    return $AiConversationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AIProviderId, int, int> $converterproviderId =
      const EnumIndexConverter<AIProviderId>(AIProviderId.values);
}

class AiConversationRow extends DataClass
    implements Insertable<AiConversationRow> {
  final int id;
  final AIProviderId providerId;
  final String title;
  final DateTime createdAt;
  const AiConversationRow(
      {required this.id,
      required this.providerId,
      required this.title,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['provider_id'] = Variable<int>(
          $AiConversationsTable.$converterproviderId.toSql(providerId));
    }
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

  factory AiConversationRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiConversationRow(
      id: serializer.fromJson<int>(json['id']),
      providerId: $AiConversationsTable.$converterproviderId
          .fromJson(serializer.fromJson<int>(json['providerId'])),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'providerId': serializer.toJson<int>(
          $AiConversationsTable.$converterproviderId.toJson(providerId)),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AiConversationRow copyWith(
          {int? id,
          AIProviderId? providerId,
          String? title,
          DateTime? createdAt}) =>
      AiConversationRow(
        id: id ?? this.id,
        providerId: providerId ?? this.providerId,
        title: title ?? this.title,
        createdAt: createdAt ?? this.createdAt,
      );
  AiConversationRow copyWithCompanion(AiConversationsCompanion data) {
    return AiConversationRow(
      id: data.id.present ? data.id.value : this.id,
      providerId:
          data.providerId.present ? data.providerId.value : this.providerId,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiConversationRow(')
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
      (other is AiConversationRow &&
          other.id == this.id &&
          other.providerId == this.providerId &&
          other.title == this.title &&
          other.createdAt == this.createdAt);
}

class AiConversationsCompanion extends UpdateCompanion<AiConversationRow> {
  final Value<int> id;
  final Value<AIProviderId> providerId;
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
    required AIProviderId providerId,
    required String title,
    this.createdAt = const Value.absent(),
  })  : providerId = Value(providerId),
        title = Value(title);
  static Insertable<AiConversationRow> custom({
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
      Value<AIProviderId>? providerId,
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
      map['provider_id'] = Variable<int>(
          $AiConversationsTable.$converterproviderId.toSql(providerId.value));
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

class $AiMessagesTable extends AiMessages
    with TableInfo<$AiMessagesTable, AiMessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES ai_conversations (id) ON DELETE CASCADE'));
  @override
  late final GeneratedColumnWithTypeConverter<AIMessageRole, int> role =
      GeneratedColumn<int>('role', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<AIMessageRole>($AiMessagesTable.$converterrole);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isErrorMeta =
      const VerificationMeta('isError');
  @override
  late final GeneratedColumn<bool> isError = GeneratedColumn<bool>(
      'is_error', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_error" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isPendingMeta =
      const VerificationMeta('isPending');
  @override
  late final GeneratedColumn<bool> isPending = GeneratedColumn<bool>(
      'is_pending', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_pending" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
      'sent_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  late final GeneratedColumnWithTypeConverter<AIFailureKind?, int> errorKind =
      GeneratedColumn<int>('error_kind', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<AIFailureKind?>($AiMessagesTable.$convertererrorKindn);
  static const VerificationMeta _errorStatusMeta =
      const VerificationMeta('errorStatus');
  @override
  late final GeneratedColumn<int> errorStatus = GeneratedColumn<int>(
      'error_status', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<AIStopReason?, int> stopReason =
      GeneratedColumn<int>('stop_reason', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<AIStopReason?>($AiMessagesTable.$converterstopReasonn);
  static const VerificationMeta _turnGroupIdMeta =
      const VerificationMeta('turnGroupId');
  @override
  late final GeneratedColumn<String> turnGroupId = GeneratedColumn<String>(
      'turn_group_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        conversationId,
        role,
        content,
        isError,
        isPending,
        sentAt,
        errorKind,
        errorStatus,
        stopReason,
        turnGroupId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_messages';
  @override
  VerificationContext validateIntegrity(Insertable<AiMessageRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('is_error')) {
      context.handle(_isErrorMeta,
          isError.isAcceptableOrUnknown(data['is_error']!, _isErrorMeta));
    }
    if (data.containsKey('is_pending')) {
      context.handle(_isPendingMeta,
          isPending.isAcceptableOrUnknown(data['is_pending']!, _isPendingMeta));
    }
    if (data.containsKey('sent_at')) {
      context.handle(_sentAtMeta,
          sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta));
    }
    if (data.containsKey('error_status')) {
      context.handle(
          _errorStatusMeta,
          errorStatus.isAcceptableOrUnknown(
              data['error_status']!, _errorStatusMeta));
    }
    if (data.containsKey('turn_group_id')) {
      context.handle(
          _turnGroupIdMeta,
          turnGroupId.isAcceptableOrUnknown(
              data['turn_group_id']!, _turnGroupIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiMessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiMessageRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      conversationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}conversation_id'])!,
      role: $AiMessagesTable.$converterrole.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}role'])!),
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      isError: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_error'])!,
      isPending: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_pending'])!,
      sentAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sent_at'])!,
      errorKind: $AiMessagesTable.$convertererrorKindn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}error_kind'])),
      errorStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}error_status']),
      stopReason: $AiMessagesTable.$converterstopReasonn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}stop_reason'])),
      turnGroupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}turn_group_id']),
    );
  }

  @override
  $AiMessagesTable createAlias(String alias) {
    return $AiMessagesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AIMessageRole, int, int> $converterrole =
      const EnumIndexConverter<AIMessageRole>(AIMessageRole.values);
  static JsonTypeConverter2<AIFailureKind, int, int> $convertererrorKind =
      const EnumIndexConverter<AIFailureKind>(AIFailureKind.values);
  static JsonTypeConverter2<AIFailureKind?, int?, int?> $convertererrorKindn =
      JsonTypeConverter2.asNullable($convertererrorKind);
  static JsonTypeConverter2<AIStopReason, int, int> $converterstopReason =
      const EnumIndexConverter<AIStopReason>(AIStopReason.values);
  static JsonTypeConverter2<AIStopReason?, int?, int?> $converterstopReasonn =
      JsonTypeConverter2.asNullable($converterstopReason);
}

class AiMessageRow extends DataClass implements Insertable<AiMessageRow> {
  final int id;
  final int conversationId;
  final AIMessageRole role;
  final String content;
  final bool isError;
  final bool isPending;
  final DateTime sentAt;
  final AIFailureKind? errorKind;
  final int? errorStatus;
  final AIStopReason? stopReason;
  final String? turnGroupId;
  const AiMessageRow(
      {required this.id,
      required this.conversationId,
      required this.role,
      required this.content,
      required this.isError,
      required this.isPending,
      required this.sentAt,
      this.errorKind,
      this.errorStatus,
      this.stopReason,
      this.turnGroupId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conversation_id'] = Variable<int>(conversationId);
    {
      map['role'] = Variable<int>($AiMessagesTable.$converterrole.toSql(role));
    }
    map['content'] = Variable<String>(content);
    map['is_error'] = Variable<bool>(isError);
    map['is_pending'] = Variable<bool>(isPending);
    map['sent_at'] = Variable<DateTime>(sentAt);
    if (!nullToAbsent || errorKind != null) {
      map['error_kind'] =
          Variable<int>($AiMessagesTable.$convertererrorKindn.toSql(errorKind));
    }
    if (!nullToAbsent || errorStatus != null) {
      map['error_status'] = Variable<int>(errorStatus);
    }
    if (!nullToAbsent || stopReason != null) {
      map['stop_reason'] = Variable<int>(
          $AiMessagesTable.$converterstopReasonn.toSql(stopReason));
    }
    if (!nullToAbsent || turnGroupId != null) {
      map['turn_group_id'] = Variable<String>(turnGroupId);
    }
    return map;
  }

  AiMessagesCompanion toCompanion(bool nullToAbsent) {
    return AiMessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      role: Value(role),
      content: Value(content),
      isError: Value(isError),
      isPending: Value(isPending),
      sentAt: Value(sentAt),
      errorKind: errorKind == null && nullToAbsent
          ? const Value.absent()
          : Value(errorKind),
      errorStatus: errorStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(errorStatus),
      stopReason: stopReason == null && nullToAbsent
          ? const Value.absent()
          : Value(stopReason),
      turnGroupId: turnGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(turnGroupId),
    );
  }

  factory AiMessageRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiMessageRow(
      id: serializer.fromJson<int>(json['id']),
      conversationId: serializer.fromJson<int>(json['conversationId']),
      role: $AiMessagesTable.$converterrole
          .fromJson(serializer.fromJson<int>(json['role'])),
      content: serializer.fromJson<String>(json['content']),
      isError: serializer.fromJson<bool>(json['isError']),
      isPending: serializer.fromJson<bool>(json['isPending']),
      sentAt: serializer.fromJson<DateTime>(json['sentAt']),
      errorKind: $AiMessagesTable.$convertererrorKindn
          .fromJson(serializer.fromJson<int?>(json['errorKind'])),
      errorStatus: serializer.fromJson<int?>(json['errorStatus']),
      stopReason: $AiMessagesTable.$converterstopReasonn
          .fromJson(serializer.fromJson<int?>(json['stopReason'])),
      turnGroupId: serializer.fromJson<String?>(json['turnGroupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conversationId': serializer.toJson<int>(conversationId),
      'role':
          serializer.toJson<int>($AiMessagesTable.$converterrole.toJson(role)),
      'content': serializer.toJson<String>(content),
      'isError': serializer.toJson<bool>(isError),
      'isPending': serializer.toJson<bool>(isPending),
      'sentAt': serializer.toJson<DateTime>(sentAt),
      'errorKind': serializer.toJson<int?>(
          $AiMessagesTable.$convertererrorKindn.toJson(errorKind)),
      'errorStatus': serializer.toJson<int?>(errorStatus),
      'stopReason': serializer.toJson<int?>(
          $AiMessagesTable.$converterstopReasonn.toJson(stopReason)),
      'turnGroupId': serializer.toJson<String?>(turnGroupId),
    };
  }

  AiMessageRow copyWith(
          {int? id,
          int? conversationId,
          AIMessageRole? role,
          String? content,
          bool? isError,
          bool? isPending,
          DateTime? sentAt,
          Value<AIFailureKind?> errorKind = const Value.absent(),
          Value<int?> errorStatus = const Value.absent(),
          Value<AIStopReason?> stopReason = const Value.absent(),
          Value<String?> turnGroupId = const Value.absent()}) =>
      AiMessageRow(
        id: id ?? this.id,
        conversationId: conversationId ?? this.conversationId,
        role: role ?? this.role,
        content: content ?? this.content,
        isError: isError ?? this.isError,
        isPending: isPending ?? this.isPending,
        sentAt: sentAt ?? this.sentAt,
        errorKind: errorKind.present ? errorKind.value : this.errorKind,
        errorStatus: errorStatus.present ? errorStatus.value : this.errorStatus,
        stopReason: stopReason.present ? stopReason.value : this.stopReason,
        turnGroupId: turnGroupId.present ? turnGroupId.value : this.turnGroupId,
      );
  AiMessageRow copyWithCompanion(AiMessagesCompanion data) {
    return AiMessageRow(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      isError: data.isError.present ? data.isError.value : this.isError,
      isPending: data.isPending.present ? data.isPending.value : this.isPending,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
      errorKind: data.errorKind.present ? data.errorKind.value : this.errorKind,
      errorStatus:
          data.errorStatus.present ? data.errorStatus.value : this.errorStatus,
      stopReason:
          data.stopReason.present ? data.stopReason.value : this.stopReason,
      turnGroupId:
          data.turnGroupId.present ? data.turnGroupId.value : this.turnGroupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiMessageRow(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('isError: $isError, ')
          ..write('isPending: $isPending, ')
          ..write('sentAt: $sentAt, ')
          ..write('errorKind: $errorKind, ')
          ..write('errorStatus: $errorStatus, ')
          ..write('stopReason: $stopReason, ')
          ..write('turnGroupId: $turnGroupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, conversationId, role, content, isError,
      isPending, sentAt, errorKind, errorStatus, stopReason, turnGroupId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiMessageRow &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.content == this.content &&
          other.isError == this.isError &&
          other.isPending == this.isPending &&
          other.sentAt == this.sentAt &&
          other.errorKind == this.errorKind &&
          other.errorStatus == this.errorStatus &&
          other.stopReason == this.stopReason &&
          other.turnGroupId == this.turnGroupId);
}

class AiMessagesCompanion extends UpdateCompanion<AiMessageRow> {
  final Value<int> id;
  final Value<int> conversationId;
  final Value<AIMessageRole> role;
  final Value<String> content;
  final Value<bool> isError;
  final Value<bool> isPending;
  final Value<DateTime> sentAt;
  final Value<AIFailureKind?> errorKind;
  final Value<int?> errorStatus;
  final Value<AIStopReason?> stopReason;
  final Value<String?> turnGroupId;
  const AiMessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.isError = const Value.absent(),
    this.isPending = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.errorKind = const Value.absent(),
    this.errorStatus = const Value.absent(),
    this.stopReason = const Value.absent(),
    this.turnGroupId = const Value.absent(),
  });
  AiMessagesCompanion.insert({
    this.id = const Value.absent(),
    required int conversationId,
    required AIMessageRole role,
    required String content,
    this.isError = const Value.absent(),
    this.isPending = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.errorKind = const Value.absent(),
    this.errorStatus = const Value.absent(),
    this.stopReason = const Value.absent(),
    this.turnGroupId = const Value.absent(),
  })  : conversationId = Value(conversationId),
        role = Value(role),
        content = Value(content);
  static Insertable<AiMessageRow> custom({
    Expression<int>? id,
    Expression<int>? conversationId,
    Expression<int>? role,
    Expression<String>? content,
    Expression<bool>? isError,
    Expression<bool>? isPending,
    Expression<DateTime>? sentAt,
    Expression<int>? errorKind,
    Expression<int>? errorStatus,
    Expression<int>? stopReason,
    Expression<String>? turnGroupId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (isError != null) 'is_error': isError,
      if (isPending != null) 'is_pending': isPending,
      if (sentAt != null) 'sent_at': sentAt,
      if (errorKind != null) 'error_kind': errorKind,
      if (errorStatus != null) 'error_status': errorStatus,
      if (stopReason != null) 'stop_reason': stopReason,
      if (turnGroupId != null) 'turn_group_id': turnGroupId,
    });
  }

  AiMessagesCompanion copyWith(
      {Value<int>? id,
      Value<int>? conversationId,
      Value<AIMessageRole>? role,
      Value<String>? content,
      Value<bool>? isError,
      Value<bool>? isPending,
      Value<DateTime>? sentAt,
      Value<AIFailureKind?>? errorKind,
      Value<int?>? errorStatus,
      Value<AIStopReason?>? stopReason,
      Value<String?>? turnGroupId}) {
    return AiMessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      isError: isError ?? this.isError,
      isPending: isPending ?? this.isPending,
      sentAt: sentAt ?? this.sentAt,
      errorKind: errorKind ?? this.errorKind,
      errorStatus: errorStatus ?? this.errorStatus,
      stopReason: stopReason ?? this.stopReason,
      turnGroupId: turnGroupId ?? this.turnGroupId,
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
      map['role'] =
          Variable<int>($AiMessagesTable.$converterrole.toSql(role.value));
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (isError.present) {
      map['is_error'] = Variable<bool>(isError.value);
    }
    if (isPending.present) {
      map['is_pending'] = Variable<bool>(isPending.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    if (errorKind.present) {
      map['error_kind'] = Variable<int>(
          $AiMessagesTable.$convertererrorKindn.toSql(errorKind.value));
    }
    if (errorStatus.present) {
      map['error_status'] = Variable<int>(errorStatus.value);
    }
    if (stopReason.present) {
      map['stop_reason'] = Variable<int>(
          $AiMessagesTable.$converterstopReasonn.toSql(stopReason.value));
    }
    if (turnGroupId.present) {
      map['turn_group_id'] = Variable<String>(turnGroupId.value);
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
          ..write('isPending: $isPending, ')
          ..write('sentAt: $sentAt, ')
          ..write('errorKind: $errorKind, ')
          ..write('errorStatus: $errorStatus, ')
          ..write('stopReason: $stopReason, ')
          ..write('turnGroupId: $turnGroupId')
          ..write(')'))
        .toString();
  }
}

class $UtterancesTable extends Utterances
    with TableInfo<$UtterancesTable, UtteranceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UtterancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
      'at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      check: () => ComparableExpr(body.length).isBiggerThanValue(0),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<UtteranceSource, int> source =
      GeneratedColumn<int>('source', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<UtteranceSource>($UtterancesTable.$convertersource);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, true,
      check: () => ComparableExpr(confidence).isBetweenValues(0, 1),
      type: DriftSqlType.double,
      requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, at, body, source, language, confidence];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'utterances';
  @override
  VerificationContext validateIntegrity(Insertable<UtteranceRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UtteranceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UtteranceRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      at: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}at'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      source: $UtterancesTable.$convertersource.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source'])!),
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language']),
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence']),
    );
  }

  @override
  $UtterancesTable createAlias(String alias) {
    return $UtterancesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<UtteranceSource, int, int> $convertersource =
      const EnumIndexConverter<UtteranceSource>(UtteranceSource.values);
}

class UtteranceRow extends DataClass implements Insertable<UtteranceRow> {
  final int id;
  final DateTime at;
  final String body;
  final UtteranceSource source;
  final String? language;
  final double? confidence;
  const UtteranceRow(
      {required this.id,
      required this.at,
      required this.body,
      required this.source,
      this.language,
      this.confidence});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['at'] = Variable<DateTime>(at);
    map['body'] = Variable<String>(body);
    {
      map['source'] =
          Variable<int>($UtterancesTable.$convertersource.toSql(source));
    }
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    return map;
  }

  UtterancesCompanion toCompanion(bool nullToAbsent) {
    return UtterancesCompanion(
      id: Value(id),
      at: Value(at),
      body: Value(body),
      source: Value(source),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
    );
  }

  factory UtteranceRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UtteranceRow(
      id: serializer.fromJson<int>(json['id']),
      at: serializer.fromJson<DateTime>(json['at']),
      body: serializer.fromJson<String>(json['body']),
      source: $UtterancesTable.$convertersource
          .fromJson(serializer.fromJson<int>(json['source'])),
      language: serializer.fromJson<String?>(json['language']),
      confidence: serializer.fromJson<double?>(json['confidence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'at': serializer.toJson<DateTime>(at),
      'body': serializer.toJson<String>(body),
      'source': serializer
          .toJson<int>($UtterancesTable.$convertersource.toJson(source)),
      'language': serializer.toJson<String?>(language),
      'confidence': serializer.toJson<double?>(confidence),
    };
  }

  UtteranceRow copyWith(
          {int? id,
          DateTime? at,
          String? body,
          UtteranceSource? source,
          Value<String?> language = const Value.absent(),
          Value<double?> confidence = const Value.absent()}) =>
      UtteranceRow(
        id: id ?? this.id,
        at: at ?? this.at,
        body: body ?? this.body,
        source: source ?? this.source,
        language: language.present ? language.value : this.language,
        confidence: confidence.present ? confidence.value : this.confidence,
      );
  UtteranceRow copyWithCompanion(UtterancesCompanion data) {
    return UtteranceRow(
      id: data.id.present ? data.id.value : this.id,
      at: data.at.present ? data.at.value : this.at,
      body: data.body.present ? data.body.value : this.body,
      source: data.source.present ? data.source.value : this.source,
      language: data.language.present ? data.language.value : this.language,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UtteranceRow(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('body: $body, ')
          ..write('source: $source, ')
          ..write('language: $language, ')
          ..write('confidence: $confidence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, at, body, source, language, confidence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UtteranceRow &&
          other.id == this.id &&
          other.at == this.at &&
          other.body == this.body &&
          other.source == this.source &&
          other.language == this.language &&
          other.confidence == this.confidence);
}

class UtterancesCompanion extends UpdateCompanion<UtteranceRow> {
  final Value<int> id;
  final Value<DateTime> at;
  final Value<String> body;
  final Value<UtteranceSource> source;
  final Value<String?> language;
  final Value<double?> confidence;
  const UtterancesCompanion({
    this.id = const Value.absent(),
    this.at = const Value.absent(),
    this.body = const Value.absent(),
    this.source = const Value.absent(),
    this.language = const Value.absent(),
    this.confidence = const Value.absent(),
  });
  UtterancesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime at,
    required String body,
    required UtteranceSource source,
    this.language = const Value.absent(),
    this.confidence = const Value.absent(),
  })  : at = Value(at),
        body = Value(body),
        source = Value(source);
  static Insertable<UtteranceRow> custom({
    Expression<int>? id,
    Expression<DateTime>? at,
    Expression<String>? body,
    Expression<int>? source,
    Expression<String>? language,
    Expression<double>? confidence,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (at != null) 'at': at,
      if (body != null) 'body': body,
      if (source != null) 'source': source,
      if (language != null) 'language': language,
      if (confidence != null) 'confidence': confidence,
    });
  }

  UtterancesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? at,
      Value<String>? body,
      Value<UtteranceSource>? source,
      Value<String?>? language,
      Value<double?>? confidence}) {
    return UtterancesCompanion(
      id: id ?? this.id,
      at: at ?? this.at,
      body: body ?? this.body,
      source: source ?? this.source,
      language: language ?? this.language,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (source.present) {
      map['source'] =
          Variable<int>($UtterancesTable.$convertersource.toSql(source.value));
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UtterancesCompanion(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('body: $body, ')
          ..write('source: $source, ')
          ..write('language: $language, ')
          ..write('confidence: $confidence')
          ..write(')'))
        .toString();
  }
}

class $AssistantActionsTable extends AssistantActions
    with TableInfo<$AssistantActionsTable, AssistantActionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssistantActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
      'at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      check: () => ComparableExpr(groupId.length).isBiggerThanValue(0),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _toolNameMeta =
      const VerificationMeta('toolName');
  @override
  late final GeneratedColumn<String> toolName = GeneratedColumn<String>(
      'tool_name', aliasedName, false,
      check: () => ComparableExpr(toolName.length).isBiggerThanValue(0),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _argsJsonMeta =
      const VerificationMeta('argsJson');
  @override
  late final GeneratedColumn<String> argsJson = GeneratedColumn<String>(
      'args_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<ActionOrigin, int> origin =
      GeneratedColumn<int>('origin', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ActionOrigin>($AssistantActionsTable.$converterorigin);
  @override
  late final GeneratedColumnWithTypeConverter<Decision, int> decision =
      GeneratedColumn<int>('decision', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<Decision>($AssistantActionsTable.$converterdecision);
  @override
  late final GeneratedColumnWithTypeConverter<LedgerStatus, int> status =
      GeneratedColumn<int>('status', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<LedgerStatus>($AssistantActionsTable.$converterstatus);
  static const VerificationMeta _undoJsonMeta =
      const VerificationMeta('undoJson');
  @override
  late final GeneratedColumn<String> undoJson = GeneratedColumn<String>(
      'undo_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _previewJsonMeta =
      const VerificationMeta('previewJson');
  @override
  late final GeneratedColumn<String> previewJson = GeneratedColumn<String>(
      'preview_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _utteranceIdMeta =
      const VerificationMeta('utteranceId');
  @override
  late final GeneratedColumn<int> utteranceId = GeneratedColumn<int>(
      'utterance_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES utterances (id) ON DELETE SET NULL'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        at,
        groupId,
        toolName,
        argsJson,
        origin,
        decision,
        status,
        undoJson,
        previewJson,
        utteranceId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assistant_actions';
  @override
  VerificationContext validateIntegrity(Insertable<AssistantActionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('tool_name')) {
      context.handle(_toolNameMeta,
          toolName.isAcceptableOrUnknown(data['tool_name']!, _toolNameMeta));
    } else if (isInserting) {
      context.missing(_toolNameMeta);
    }
    if (data.containsKey('args_json')) {
      context.handle(_argsJsonMeta,
          argsJson.isAcceptableOrUnknown(data['args_json']!, _argsJsonMeta));
    } else if (isInserting) {
      context.missing(_argsJsonMeta);
    }
    if (data.containsKey('undo_json')) {
      context.handle(_undoJsonMeta,
          undoJson.isAcceptableOrUnknown(data['undo_json']!, _undoJsonMeta));
    }
    if (data.containsKey('preview_json')) {
      context.handle(
          _previewJsonMeta,
          previewJson.isAcceptableOrUnknown(
              data['preview_json']!, _previewJsonMeta));
    }
    if (data.containsKey('utterance_id')) {
      context.handle(
          _utteranceIdMeta,
          utteranceId.isAcceptableOrUnknown(
              data['utterance_id']!, _utteranceIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssistantActionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssistantActionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      at: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}at'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      toolName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tool_name'])!,
      argsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}args_json'])!,
      origin: $AssistantActionsTable.$converterorigin.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}origin'])!),
      decision: $AssistantActionsTable.$converterdecision.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}decision'])!),
      status: $AssistantActionsTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!),
      undoJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}undo_json']),
      previewJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}preview_json']),
      utteranceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}utterance_id']),
    );
  }

  @override
  $AssistantActionsTable createAlias(String alias) {
    return $AssistantActionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActionOrigin, int, int> $converterorigin =
      const EnumIndexConverter<ActionOrigin>(ActionOrigin.values);
  static JsonTypeConverter2<Decision, int, int> $converterdecision =
      const EnumIndexConverter<Decision>(Decision.values);
  static JsonTypeConverter2<LedgerStatus, int, int> $converterstatus =
      const EnumIndexConverter<LedgerStatus>(LedgerStatus.values);
}

class AssistantActionRow extends DataClass
    implements Insertable<AssistantActionRow> {
  final int id;
  final DateTime at;
  final String groupId;
  final String toolName;
  final String argsJson;
  final ActionOrigin origin;
  final Decision decision;
  final LedgerStatus status;

  /// `encodeUndoRecipe` output; null when the action has no undo.
  final String? undoJson;

  /// Since schema v10: `previewToJson` of what the action did, so the
  /// chat and Activity can word it later (the target may be gone).
  final String? previewJson;
  final int? utteranceId;
  const AssistantActionRow(
      {required this.id,
      required this.at,
      required this.groupId,
      required this.toolName,
      required this.argsJson,
      required this.origin,
      required this.decision,
      required this.status,
      this.undoJson,
      this.previewJson,
      this.utteranceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['at'] = Variable<DateTime>(at);
    map['group_id'] = Variable<String>(groupId);
    map['tool_name'] = Variable<String>(toolName);
    map['args_json'] = Variable<String>(argsJson);
    {
      map['origin'] =
          Variable<int>($AssistantActionsTable.$converterorigin.toSql(origin));
    }
    {
      map['decision'] = Variable<int>(
          $AssistantActionsTable.$converterdecision.toSql(decision));
    }
    {
      map['status'] =
          Variable<int>($AssistantActionsTable.$converterstatus.toSql(status));
    }
    if (!nullToAbsent || undoJson != null) {
      map['undo_json'] = Variable<String>(undoJson);
    }
    if (!nullToAbsent || previewJson != null) {
      map['preview_json'] = Variable<String>(previewJson);
    }
    if (!nullToAbsent || utteranceId != null) {
      map['utterance_id'] = Variable<int>(utteranceId);
    }
    return map;
  }

  AssistantActionsCompanion toCompanion(bool nullToAbsent) {
    return AssistantActionsCompanion(
      id: Value(id),
      at: Value(at),
      groupId: Value(groupId),
      toolName: Value(toolName),
      argsJson: Value(argsJson),
      origin: Value(origin),
      decision: Value(decision),
      status: Value(status),
      undoJson: undoJson == null && nullToAbsent
          ? const Value.absent()
          : Value(undoJson),
      previewJson: previewJson == null && nullToAbsent
          ? const Value.absent()
          : Value(previewJson),
      utteranceId: utteranceId == null && nullToAbsent
          ? const Value.absent()
          : Value(utteranceId),
    );
  }

  factory AssistantActionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssistantActionRow(
      id: serializer.fromJson<int>(json['id']),
      at: serializer.fromJson<DateTime>(json['at']),
      groupId: serializer.fromJson<String>(json['groupId']),
      toolName: serializer.fromJson<String>(json['toolName']),
      argsJson: serializer.fromJson<String>(json['argsJson']),
      origin: $AssistantActionsTable.$converterorigin
          .fromJson(serializer.fromJson<int>(json['origin'])),
      decision: $AssistantActionsTable.$converterdecision
          .fromJson(serializer.fromJson<int>(json['decision'])),
      status: $AssistantActionsTable.$converterstatus
          .fromJson(serializer.fromJson<int>(json['status'])),
      undoJson: serializer.fromJson<String?>(json['undoJson']),
      previewJson: serializer.fromJson<String?>(json['previewJson']),
      utteranceId: serializer.fromJson<int?>(json['utteranceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'at': serializer.toJson<DateTime>(at),
      'groupId': serializer.toJson<String>(groupId),
      'toolName': serializer.toJson<String>(toolName),
      'argsJson': serializer.toJson<String>(argsJson),
      'origin': serializer
          .toJson<int>($AssistantActionsTable.$converterorigin.toJson(origin)),
      'decision': serializer.toJson<int>(
          $AssistantActionsTable.$converterdecision.toJson(decision)),
      'status': serializer
          .toJson<int>($AssistantActionsTable.$converterstatus.toJson(status)),
      'undoJson': serializer.toJson<String?>(undoJson),
      'previewJson': serializer.toJson<String?>(previewJson),
      'utteranceId': serializer.toJson<int?>(utteranceId),
    };
  }

  AssistantActionRow copyWith(
          {int? id,
          DateTime? at,
          String? groupId,
          String? toolName,
          String? argsJson,
          ActionOrigin? origin,
          Decision? decision,
          LedgerStatus? status,
          Value<String?> undoJson = const Value.absent(),
          Value<String?> previewJson = const Value.absent(),
          Value<int?> utteranceId = const Value.absent()}) =>
      AssistantActionRow(
        id: id ?? this.id,
        at: at ?? this.at,
        groupId: groupId ?? this.groupId,
        toolName: toolName ?? this.toolName,
        argsJson: argsJson ?? this.argsJson,
        origin: origin ?? this.origin,
        decision: decision ?? this.decision,
        status: status ?? this.status,
        undoJson: undoJson.present ? undoJson.value : this.undoJson,
        previewJson: previewJson.present ? previewJson.value : this.previewJson,
        utteranceId: utteranceId.present ? utteranceId.value : this.utteranceId,
      );
  AssistantActionRow copyWithCompanion(AssistantActionsCompanion data) {
    return AssistantActionRow(
      id: data.id.present ? data.id.value : this.id,
      at: data.at.present ? data.at.value : this.at,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      toolName: data.toolName.present ? data.toolName.value : this.toolName,
      argsJson: data.argsJson.present ? data.argsJson.value : this.argsJson,
      origin: data.origin.present ? data.origin.value : this.origin,
      decision: data.decision.present ? data.decision.value : this.decision,
      status: data.status.present ? data.status.value : this.status,
      undoJson: data.undoJson.present ? data.undoJson.value : this.undoJson,
      previewJson:
          data.previewJson.present ? data.previewJson.value : this.previewJson,
      utteranceId:
          data.utteranceId.present ? data.utteranceId.value : this.utteranceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssistantActionRow(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('groupId: $groupId, ')
          ..write('toolName: $toolName, ')
          ..write('argsJson: $argsJson, ')
          ..write('origin: $origin, ')
          ..write('decision: $decision, ')
          ..write('status: $status, ')
          ..write('undoJson: $undoJson, ')
          ..write('previewJson: $previewJson, ')
          ..write('utteranceId: $utteranceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, at, groupId, toolName, argsJson, origin,
      decision, status, undoJson, previewJson, utteranceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssistantActionRow &&
          other.id == this.id &&
          other.at == this.at &&
          other.groupId == this.groupId &&
          other.toolName == this.toolName &&
          other.argsJson == this.argsJson &&
          other.origin == this.origin &&
          other.decision == this.decision &&
          other.status == this.status &&
          other.undoJson == this.undoJson &&
          other.previewJson == this.previewJson &&
          other.utteranceId == this.utteranceId);
}

class AssistantActionsCompanion extends UpdateCompanion<AssistantActionRow> {
  final Value<int> id;
  final Value<DateTime> at;
  final Value<String> groupId;
  final Value<String> toolName;
  final Value<String> argsJson;
  final Value<ActionOrigin> origin;
  final Value<Decision> decision;
  final Value<LedgerStatus> status;
  final Value<String?> undoJson;
  final Value<String?> previewJson;
  final Value<int?> utteranceId;
  const AssistantActionsCompanion({
    this.id = const Value.absent(),
    this.at = const Value.absent(),
    this.groupId = const Value.absent(),
    this.toolName = const Value.absent(),
    this.argsJson = const Value.absent(),
    this.origin = const Value.absent(),
    this.decision = const Value.absent(),
    this.status = const Value.absent(),
    this.undoJson = const Value.absent(),
    this.previewJson = const Value.absent(),
    this.utteranceId = const Value.absent(),
  });
  AssistantActionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime at,
    required String groupId,
    required String toolName,
    required String argsJson,
    required ActionOrigin origin,
    required Decision decision,
    required LedgerStatus status,
    this.undoJson = const Value.absent(),
    this.previewJson = const Value.absent(),
    this.utteranceId = const Value.absent(),
  })  : at = Value(at),
        groupId = Value(groupId),
        toolName = Value(toolName),
        argsJson = Value(argsJson),
        origin = Value(origin),
        decision = Value(decision),
        status = Value(status);
  static Insertable<AssistantActionRow> custom({
    Expression<int>? id,
    Expression<DateTime>? at,
    Expression<String>? groupId,
    Expression<String>? toolName,
    Expression<String>? argsJson,
    Expression<int>? origin,
    Expression<int>? decision,
    Expression<int>? status,
    Expression<String>? undoJson,
    Expression<String>? previewJson,
    Expression<int>? utteranceId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (at != null) 'at': at,
      if (groupId != null) 'group_id': groupId,
      if (toolName != null) 'tool_name': toolName,
      if (argsJson != null) 'args_json': argsJson,
      if (origin != null) 'origin': origin,
      if (decision != null) 'decision': decision,
      if (status != null) 'status': status,
      if (undoJson != null) 'undo_json': undoJson,
      if (previewJson != null) 'preview_json': previewJson,
      if (utteranceId != null) 'utterance_id': utteranceId,
    });
  }

  AssistantActionsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? at,
      Value<String>? groupId,
      Value<String>? toolName,
      Value<String>? argsJson,
      Value<ActionOrigin>? origin,
      Value<Decision>? decision,
      Value<LedgerStatus>? status,
      Value<String?>? undoJson,
      Value<String?>? previewJson,
      Value<int?>? utteranceId}) {
    return AssistantActionsCompanion(
      id: id ?? this.id,
      at: at ?? this.at,
      groupId: groupId ?? this.groupId,
      toolName: toolName ?? this.toolName,
      argsJson: argsJson ?? this.argsJson,
      origin: origin ?? this.origin,
      decision: decision ?? this.decision,
      status: status ?? this.status,
      undoJson: undoJson ?? this.undoJson,
      previewJson: previewJson ?? this.previewJson,
      utteranceId: utteranceId ?? this.utteranceId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (toolName.present) {
      map['tool_name'] = Variable<String>(toolName.value);
    }
    if (argsJson.present) {
      map['args_json'] = Variable<String>(argsJson.value);
    }
    if (origin.present) {
      map['origin'] = Variable<int>(
          $AssistantActionsTable.$converterorigin.toSql(origin.value));
    }
    if (decision.present) {
      map['decision'] = Variable<int>(
          $AssistantActionsTable.$converterdecision.toSql(decision.value));
    }
    if (status.present) {
      map['status'] = Variable<int>(
          $AssistantActionsTable.$converterstatus.toSql(status.value));
    }
    if (undoJson.present) {
      map['undo_json'] = Variable<String>(undoJson.value);
    }
    if (previewJson.present) {
      map['preview_json'] = Variable<String>(previewJson.value);
    }
    if (utteranceId.present) {
      map['utterance_id'] = Variable<int>(utteranceId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssistantActionsCompanion(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('groupId: $groupId, ')
          ..write('toolName: $toolName, ')
          ..write('argsJson: $argsJson, ')
          ..write('origin: $origin, ')
          ..write('decision: $decision, ')
          ..write('status: $status, ')
          ..write('undoJson: $undoJson, ')
          ..write('previewJson: $previewJson, ')
          ..write('utteranceId: $utteranceId')
          ..write(')'))
        .toString();
  }
}

class $ProposalsTable extends Proposals
    with TableInfo<$ProposalsTable, ProposalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProposalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
      'expires_at', aliasedName, true,
      check: () => ComparableExpr(expiresAt).isBiggerThan(createdAt),
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false);
  static const VerificationMeta _toolNameMeta =
      const VerificationMeta('toolName');
  @override
  late final GeneratedColumn<String> toolName = GeneratedColumn<String>(
      'tool_name', aliasedName, false,
      check: () => ComparableExpr(toolName.length).isBiggerThanValue(0),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _argsJsonMeta =
      const VerificationMeta('argsJson');
  @override
  late final GeneratedColumn<String> argsJson = GeneratedColumn<String>(
      'args_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<ActionOrigin, int> origin =
      GeneratedColumn<int>('origin', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ActionOrigin>($ProposalsTable.$converterorigin);
  @override
  late final GeneratedColumnWithTypeConverter<ProposalReason, int> reason =
      GeneratedColumn<int>('reason', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ProposalReason>($ProposalsTable.$converterreason);
  static const VerificationMeta _reasonJsonMeta =
      const VerificationMeta('reasonJson');
  @override
  late final GeneratedColumn<String> reasonJson = GeneratedColumn<String>(
      'reason_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _sourceTextMeta =
      const VerificationMeta('sourceText');
  @override
  late final GeneratedColumn<String> sourceText = GeneratedColumn<String>(
      'source_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dedupeKeyMeta =
      const VerificationMeta('dedupeKey');
  @override
  late final GeneratedColumn<String> dedupeKey = GeneratedColumn<String>(
      'dedupe_key', aliasedName, false,
      check: () => ComparableExpr(dedupeKey.length).isBiggerThanValue(0),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<ProposalStatus, int> status =
      GeneratedColumn<int>('status', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ProposalStatus>($ProposalsTable.$converterstatus);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        expiresAt,
        toolName,
        argsJson,
        origin,
        reason,
        reasonJson,
        sourceText,
        dedupeKey,
        status
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'proposals';
  @override
  VerificationContext validateIntegrity(Insertable<ProposalRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    }
    if (data.containsKey('tool_name')) {
      context.handle(_toolNameMeta,
          toolName.isAcceptableOrUnknown(data['tool_name']!, _toolNameMeta));
    } else if (isInserting) {
      context.missing(_toolNameMeta);
    }
    if (data.containsKey('args_json')) {
      context.handle(_argsJsonMeta,
          argsJson.isAcceptableOrUnknown(data['args_json']!, _argsJsonMeta));
    } else if (isInserting) {
      context.missing(_argsJsonMeta);
    }
    if (data.containsKey('reason_json')) {
      context.handle(
          _reasonJsonMeta,
          reasonJson.isAcceptableOrUnknown(
              data['reason_json']!, _reasonJsonMeta));
    }
    if (data.containsKey('source_text')) {
      context.handle(
          _sourceTextMeta,
          sourceText.isAcceptableOrUnknown(
              data['source_text']!, _sourceTextMeta));
    }
    if (data.containsKey('dedupe_key')) {
      context.handle(_dedupeKeyMeta,
          dedupeKey.isAcceptableOrUnknown(data['dedupe_key']!, _dedupeKeyMeta));
    } else if (isInserting) {
      context.missing(_dedupeKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProposalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProposalRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires_at']),
      toolName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tool_name'])!,
      argsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}args_json'])!,
      origin: $ProposalsTable.$converterorigin.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}origin'])!),
      reason: $ProposalsTable.$converterreason.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reason'])!),
      reasonJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason_json'])!,
      sourceText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_text']),
      dedupeKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dedupe_key'])!,
      status: $ProposalsTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!),
    );
  }

  @override
  $ProposalsTable createAlias(String alias) {
    return $ProposalsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActionOrigin, int, int> $converterorigin =
      const EnumIndexConverter<ActionOrigin>(ActionOrigin.values);
  static JsonTypeConverter2<ProposalReason, int, int> $converterreason =
      const EnumIndexConverter<ProposalReason>(ProposalReason.values);
  static JsonTypeConverter2<ProposalStatus, int, int> $converterstatus =
      const EnumIndexConverter<ProposalStatus>(ProposalStatus.values);
}

class ProposalRow extends DataClass implements Insertable<ProposalRow> {
  final int id;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String toolName;
  final String argsJson;
  final ActionOrigin origin;
  final ProposalReason reason;
  final String reasonJson;
  final String? sourceText;
  final String dedupeKey;
  final ProposalStatus status;
  const ProposalRow(
      {required this.id,
      required this.createdAt,
      this.expiresAt,
      required this.toolName,
      required this.argsJson,
      required this.origin,
      required this.reason,
      required this.reasonJson,
      this.sourceText,
      required this.dedupeKey,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    map['tool_name'] = Variable<String>(toolName);
    map['args_json'] = Variable<String>(argsJson);
    {
      map['origin'] =
          Variable<int>($ProposalsTable.$converterorigin.toSql(origin));
    }
    {
      map['reason'] =
          Variable<int>($ProposalsTable.$converterreason.toSql(reason));
    }
    map['reason_json'] = Variable<String>(reasonJson);
    if (!nullToAbsent || sourceText != null) {
      map['source_text'] = Variable<String>(sourceText);
    }
    map['dedupe_key'] = Variable<String>(dedupeKey);
    {
      map['status'] =
          Variable<int>($ProposalsTable.$converterstatus.toSql(status));
    }
    return map;
  }

  ProposalsCompanion toCompanion(bool nullToAbsent) {
    return ProposalsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      toolName: Value(toolName),
      argsJson: Value(argsJson),
      origin: Value(origin),
      reason: Value(reason),
      reasonJson: Value(reasonJson),
      sourceText: sourceText == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceText),
      dedupeKey: Value(dedupeKey),
      status: Value(status),
    );
  }

  factory ProposalRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProposalRow(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      toolName: serializer.fromJson<String>(json['toolName']),
      argsJson: serializer.fromJson<String>(json['argsJson']),
      origin: $ProposalsTable.$converterorigin
          .fromJson(serializer.fromJson<int>(json['origin'])),
      reason: $ProposalsTable.$converterreason
          .fromJson(serializer.fromJson<int>(json['reason'])),
      reasonJson: serializer.fromJson<String>(json['reasonJson']),
      sourceText: serializer.fromJson<String?>(json['sourceText']),
      dedupeKey: serializer.fromJson<String>(json['dedupeKey']),
      status: $ProposalsTable.$converterstatus
          .fromJson(serializer.fromJson<int>(json['status'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'toolName': serializer.toJson<String>(toolName),
      'argsJson': serializer.toJson<String>(argsJson),
      'origin': serializer
          .toJson<int>($ProposalsTable.$converterorigin.toJson(origin)),
      'reason': serializer
          .toJson<int>($ProposalsTable.$converterreason.toJson(reason)),
      'reasonJson': serializer.toJson<String>(reasonJson),
      'sourceText': serializer.toJson<String?>(sourceText),
      'dedupeKey': serializer.toJson<String>(dedupeKey),
      'status': serializer
          .toJson<int>($ProposalsTable.$converterstatus.toJson(status)),
    };
  }

  ProposalRow copyWith(
          {int? id,
          DateTime? createdAt,
          Value<DateTime?> expiresAt = const Value.absent(),
          String? toolName,
          String? argsJson,
          ActionOrigin? origin,
          ProposalReason? reason,
          String? reasonJson,
          Value<String?> sourceText = const Value.absent(),
          String? dedupeKey,
          ProposalStatus? status}) =>
      ProposalRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
        toolName: toolName ?? this.toolName,
        argsJson: argsJson ?? this.argsJson,
        origin: origin ?? this.origin,
        reason: reason ?? this.reason,
        reasonJson: reasonJson ?? this.reasonJson,
        sourceText: sourceText.present ? sourceText.value : this.sourceText,
        dedupeKey: dedupeKey ?? this.dedupeKey,
        status: status ?? this.status,
      );
  ProposalRow copyWithCompanion(ProposalsCompanion data) {
    return ProposalRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      toolName: data.toolName.present ? data.toolName.value : this.toolName,
      argsJson: data.argsJson.present ? data.argsJson.value : this.argsJson,
      origin: data.origin.present ? data.origin.value : this.origin,
      reason: data.reason.present ? data.reason.value : this.reason,
      reasonJson:
          data.reasonJson.present ? data.reasonJson.value : this.reasonJson,
      sourceText:
          data.sourceText.present ? data.sourceText.value : this.sourceText,
      dedupeKey: data.dedupeKey.present ? data.dedupeKey.value : this.dedupeKey,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProposalRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('toolName: $toolName, ')
          ..write('argsJson: $argsJson, ')
          ..write('origin: $origin, ')
          ..write('reason: $reason, ')
          ..write('reasonJson: $reasonJson, ')
          ..write('sourceText: $sourceText, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, expiresAt, toolName, argsJson,
      origin, reason, reasonJson, sourceText, dedupeKey, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProposalRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt &&
          other.toolName == this.toolName &&
          other.argsJson == this.argsJson &&
          other.origin == this.origin &&
          other.reason == this.reason &&
          other.reasonJson == this.reasonJson &&
          other.sourceText == this.sourceText &&
          other.dedupeKey == this.dedupeKey &&
          other.status == this.status);
}

class ProposalsCompanion extends UpdateCompanion<ProposalRow> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime?> expiresAt;
  final Value<String> toolName;
  final Value<String> argsJson;
  final Value<ActionOrigin> origin;
  final Value<ProposalReason> reason;
  final Value<String> reasonJson;
  final Value<String?> sourceText;
  final Value<String> dedupeKey;
  final Value<ProposalStatus> status;
  const ProposalsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.toolName = const Value.absent(),
    this.argsJson = const Value.absent(),
    this.origin = const Value.absent(),
    this.reason = const Value.absent(),
    this.reasonJson = const Value.absent(),
    this.sourceText = const Value.absent(),
    this.dedupeKey = const Value.absent(),
    this.status = const Value.absent(),
  });
  ProposalsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    this.expiresAt = const Value.absent(),
    required String toolName,
    required String argsJson,
    required ActionOrigin origin,
    required ProposalReason reason,
    this.reasonJson = const Value.absent(),
    this.sourceText = const Value.absent(),
    required String dedupeKey,
    required ProposalStatus status,
  })  : createdAt = Value(createdAt),
        toolName = Value(toolName),
        argsJson = Value(argsJson),
        origin = Value(origin),
        reason = Value(reason),
        dedupeKey = Value(dedupeKey),
        status = Value(status);
  static Insertable<ProposalRow> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? expiresAt,
    Expression<String>? toolName,
    Expression<String>? argsJson,
    Expression<int>? origin,
    Expression<int>? reason,
    Expression<String>? reasonJson,
    Expression<String>? sourceText,
    Expression<String>? dedupeKey,
    Expression<int>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (toolName != null) 'tool_name': toolName,
      if (argsJson != null) 'args_json': argsJson,
      if (origin != null) 'origin': origin,
      if (reason != null) 'reason': reason,
      if (reasonJson != null) 'reason_json': reasonJson,
      if (sourceText != null) 'source_text': sourceText,
      if (dedupeKey != null) 'dedupe_key': dedupeKey,
      if (status != null) 'status': status,
    });
  }

  ProposalsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? createdAt,
      Value<DateTime?>? expiresAt,
      Value<String>? toolName,
      Value<String>? argsJson,
      Value<ActionOrigin>? origin,
      Value<ProposalReason>? reason,
      Value<String>? reasonJson,
      Value<String?>? sourceText,
      Value<String>? dedupeKey,
      Value<ProposalStatus>? status}) {
    return ProposalsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      toolName: toolName ?? this.toolName,
      argsJson: argsJson ?? this.argsJson,
      origin: origin ?? this.origin,
      reason: reason ?? this.reason,
      reasonJson: reasonJson ?? this.reasonJson,
      sourceText: sourceText ?? this.sourceText,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (toolName.present) {
      map['tool_name'] = Variable<String>(toolName.value);
    }
    if (argsJson.present) {
      map['args_json'] = Variable<String>(argsJson.value);
    }
    if (origin.present) {
      map['origin'] =
          Variable<int>($ProposalsTable.$converterorigin.toSql(origin.value));
    }
    if (reason.present) {
      map['reason'] =
          Variable<int>($ProposalsTable.$converterreason.toSql(reason.value));
    }
    if (reasonJson.present) {
      map['reason_json'] = Variable<String>(reasonJson.value);
    }
    if (sourceText.present) {
      map['source_text'] = Variable<String>(sourceText.value);
    }
    if (dedupeKey.present) {
      map['dedupe_key'] = Variable<String>(dedupeKey.value);
    }
    if (status.present) {
      map['status'] =
          Variable<int>($ProposalsTable.$converterstatus.toSql(status.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProposalsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('toolName: $toolName, ')
          ..write('argsJson: $argsJson, ')
          ..write('origin: $origin, ')
          ..write('reason: $reason, ')
          ..write('reasonJson: $reasonJson, ')
          ..write('sourceText: $sourceText, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, ReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      check: () => ComparableExpr(title.length).isBetweenValues(1, 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _fireAtMeta = const VerificationMeta('fireAt');
  @override
  late final GeneratedColumn<DateTime> fireAt = GeneratedColumn<DateTime>(
      'fire_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<ReminderKind, int> kind =
      GeneratedColumn<int>('kind', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ReminderKind>($RemindersTable.$converterkind);
  @override
  late final GeneratedColumnWithTypeConverter<ReminderStatus, int> status =
      GeneratedColumn<int>('status', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ReminderStatus>($RemindersTable.$converterstatus);
  static const VerificationMeta _snoozeCountMeta =
      const VerificationMeta('snoozeCount');
  @override
  late final GeneratedColumn<int> snoozeCount = GeneratedColumn<int>(
      'snooze_count', aliasedName, false,
      check: () => ComparableExpr(snoozeCount).isBiggerOrEqualValue(0),
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
      'task_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tasks (id) ON DELETE SET NULL'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, fireAt, kind, status, snoozeCount, taskId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(Insertable<ReminderRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('fire_at')) {
      context.handle(_fireAtMeta,
          fireAt.isAcceptableOrUnknown(data['fire_at']!, _fireAtMeta));
    } else if (isInserting) {
      context.missing(_fireAtMeta);
    }
    if (data.containsKey('snooze_count')) {
      context.handle(
          _snoozeCountMeta,
          snoozeCount.isAcceptableOrUnknown(
              data['snooze_count']!, _snoozeCountMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      fireAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fire_at'])!,
      kind: $RemindersTable.$converterkind.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kind'])!),
      status: $RemindersTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!),
      snoozeCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}snooze_count'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}task_id']),
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReminderKind, int, int> $converterkind =
      const EnumIndexConverter<ReminderKind>(ReminderKind.values);
  static JsonTypeConverter2<ReminderStatus, int, int> $converterstatus =
      const EnumIndexConverter<ReminderStatus>(ReminderStatus.values);
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final int id;
  final String title;
  final DateTime fireAt;
  final ReminderKind kind;
  final ReminderStatus status;
  final int snoozeCount;
  final int? taskId;
  const ReminderRow(
      {required this.id,
      required this.title,
      required this.fireAt,
      required this.kind,
      required this.status,
      required this.snoozeCount,
      this.taskId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['fire_at'] = Variable<DateTime>(fireAt);
    {
      map['kind'] = Variable<int>($RemindersTable.$converterkind.toSql(kind));
    }
    {
      map['status'] =
          Variable<int>($RemindersTable.$converterstatus.toSql(status));
    }
    map['snooze_count'] = Variable<int>(snoozeCount);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<int>(taskId);
    }
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      title: Value(title),
      fireAt: Value(fireAt),
      kind: Value(kind),
      status: Value(status),
      snoozeCount: Value(snoozeCount),
      taskId:
          taskId == null && nullToAbsent ? const Value.absent() : Value(taskId),
    );
  }

  factory ReminderRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      fireAt: serializer.fromJson<DateTime>(json['fireAt']),
      kind: $RemindersTable.$converterkind
          .fromJson(serializer.fromJson<int>(json['kind'])),
      status: $RemindersTable.$converterstatus
          .fromJson(serializer.fromJson<int>(json['status'])),
      snoozeCount: serializer.fromJson<int>(json['snoozeCount']),
      taskId: serializer.fromJson<int?>(json['taskId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'fireAt': serializer.toJson<DateTime>(fireAt),
      'kind':
          serializer.toJson<int>($RemindersTable.$converterkind.toJson(kind)),
      'status': serializer
          .toJson<int>($RemindersTable.$converterstatus.toJson(status)),
      'snoozeCount': serializer.toJson<int>(snoozeCount),
      'taskId': serializer.toJson<int?>(taskId),
    };
  }

  ReminderRow copyWith(
          {int? id,
          String? title,
          DateTime? fireAt,
          ReminderKind? kind,
          ReminderStatus? status,
          int? snoozeCount,
          Value<int?> taskId = const Value.absent()}) =>
      ReminderRow(
        id: id ?? this.id,
        title: title ?? this.title,
        fireAt: fireAt ?? this.fireAt,
        kind: kind ?? this.kind,
        status: status ?? this.status,
        snoozeCount: snoozeCount ?? this.snoozeCount,
        taskId: taskId.present ? taskId.value : this.taskId,
      );
  ReminderRow copyWithCompanion(RemindersCompanion data) {
    return ReminderRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      fireAt: data.fireAt.present ? data.fireAt.value : this.fireAt,
      kind: data.kind.present ? data.kind.value : this.kind,
      status: data.status.present ? data.status.value : this.status,
      snoozeCount:
          data.snoozeCount.present ? data.snoozeCount.value : this.snoozeCount,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('fireAt: $fireAt, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('taskId: $taskId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, fireAt, kind, status, snoozeCount, taskId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.fireAt == this.fireAt &&
          other.kind == this.kind &&
          other.status == this.status &&
          other.snoozeCount == this.snoozeCount &&
          other.taskId == this.taskId);
}

class RemindersCompanion extends UpdateCompanion<ReminderRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<DateTime> fireAt;
  final Value<ReminderKind> kind;
  final Value<ReminderStatus> status;
  final Value<int> snoozeCount;
  final Value<int?> taskId;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.fireAt = const Value.absent(),
    this.kind = const Value.absent(),
    this.status = const Value.absent(),
    this.snoozeCount = const Value.absent(),
    this.taskId = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required DateTime fireAt,
    required ReminderKind kind,
    required ReminderStatus status,
    this.snoozeCount = const Value.absent(),
    this.taskId = const Value.absent(),
  })  : title = Value(title),
        fireAt = Value(fireAt),
        kind = Value(kind),
        status = Value(status);
  static Insertable<ReminderRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<DateTime>? fireAt,
    Expression<int>? kind,
    Expression<int>? status,
    Expression<int>? snoozeCount,
    Expression<int>? taskId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (fireAt != null) 'fire_at': fireAt,
      if (kind != null) 'kind': kind,
      if (status != null) 'status': status,
      if (snoozeCount != null) 'snooze_count': snoozeCount,
      if (taskId != null) 'task_id': taskId,
    });
  }

  RemindersCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<DateTime>? fireAt,
      Value<ReminderKind>? kind,
      Value<ReminderStatus>? status,
      Value<int>? snoozeCount,
      Value<int?>? taskId}) {
    return RemindersCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      fireAt: fireAt ?? this.fireAt,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      taskId: taskId ?? this.taskId,
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
    if (fireAt.present) {
      map['fire_at'] = Variable<DateTime>(fireAt.value);
    }
    if (kind.present) {
      map['kind'] =
          Variable<int>($RemindersTable.$converterkind.toSql(kind.value));
    }
    if (status.present) {
      map['status'] =
          Variable<int>($RemindersTable.$converterstatus.toSql(status.value));
    }
    if (snoozeCount.present) {
      map['snooze_count'] = Variable<int>(snoozeCount.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('fireAt: $fireAt, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('taskId: $taskId')
          ..write(')'))
        .toString();
  }
}

class $ListsTable extends Lists with TableInfo<$ListsTable, ListRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      check: () => ComparableExpr(name.length).isBetweenValues(1, 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<ListKind, int> kind =
      GeneratedColumn<int>('kind', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ListKind>($ListsTable.$converterkind);
  static const VerificationMeta _archivedMeta =
      const VerificationMeta('archived');
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
      'archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [id, name, kind, archived];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lists';
  @override
  VerificationContext validateIntegrity(Insertable<ListRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(_archivedMeta,
          archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      kind: $ListsTable.$converterkind.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kind'])!),
      archived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}archived'])!,
    );
  }

  @override
  $ListsTable createAlias(String alias) {
    return $ListsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ListKind, int, int> $converterkind =
      const EnumIndexConverter<ListKind>(ListKind.values);
}

class ListRow extends DataClass implements Insertable<ListRow> {
  final int id;
  final String name;
  final ListKind kind;
  final bool archived;
  const ListRow(
      {required this.id,
      required this.name,
      required this.kind,
      required this.archived});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['kind'] = Variable<int>($ListsTable.$converterkind.toSql(kind));
    }
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  ListsCompanion toCompanion(bool nullToAbsent) {
    return ListsCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      archived: Value(archived),
    );
  }

  factory ListRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: $ListsTable.$converterkind
          .fromJson(serializer.fromJson<int>(json['kind'])),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<int>($ListsTable.$converterkind.toJson(kind)),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  ListRow copyWith({int? id, String? name, ListKind? kind, bool? archived}) =>
      ListRow(
        id: id ?? this.id,
        name: name ?? this.name,
        kind: kind ?? this.kind,
        archived: archived ?? this.archived,
      );
  ListRow copyWithCompanion(ListsCompanion data) {
    return ListRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, kind, archived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.archived == this.archived);
}

class ListsCompanion extends UpdateCompanion<ListRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<ListKind> kind;
  final Value<bool> archived;
  const ListsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.archived = const Value.absent(),
  });
  ListsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required ListKind kind,
    this.archived = const Value.absent(),
  })  : name = Value(name),
        kind = Value(kind);
  static Insertable<ListRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? kind,
    Expression<bool>? archived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (archived != null) 'archived': archived,
    });
  }

  ListsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<ListKind>? kind,
      Value<bool>? archived}) {
    return ListsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      archived: archived ?? this.archived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>($ListsTable.$converterkind.toSql(kind.value));
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }
}

class $ListItemsTable extends ListItems
    with TableInfo<$ListItemsTable, ListItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
      'list_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES lists (id) ON DELETE CASCADE'));
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      check: () => ComparableExpr(body.length).isBetweenValues(1, 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _checkedMeta =
      const VerificationMeta('checked');
  @override
  late final GeneratedColumn<bool> checked = GeneratedColumn<bool>(
      'checked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("checked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
      'added_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _checkedAtMeta =
      const VerificationMeta('checkedAt');
  @override
  late final GeneratedColumn<DateTime> checkedAt = GeneratedColumn<DateTime>(
      'checked_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, listId, body, checked, position, addedAt, checkedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'list_items';
  @override
  VerificationContext validateIntegrity(Insertable<ListItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('list_id')) {
      context.handle(_listIdMeta,
          listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta));
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('checked')) {
      context.handle(_checkedMeta,
          checked.isAcceptableOrUnknown(data['checked']!, _checkedMeta));
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('checked_at')) {
      context.handle(_checkedAtMeta,
          checkedAt.isAcceptableOrUnknown(data['checked_at']!, _checkedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListItemRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      listId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}list_id'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      checked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}checked'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!,
      checkedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}checked_at']),
    );
  }

  @override
  $ListItemsTable createAlias(String alias) {
    return $ListItemsTable(attachedDatabase, alias);
  }
}

class ListItemRow extends DataClass implements Insertable<ListItemRow> {
  final int id;
  final int listId;
  final String body;
  final bool checked;
  final int position;
  final DateTime addedAt;
  final DateTime? checkedAt;
  const ListItemRow(
      {required this.id,
      required this.listId,
      required this.body,
      required this.checked,
      required this.position,
      required this.addedAt,
      this.checkedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['list_id'] = Variable<int>(listId);
    map['body'] = Variable<String>(body);
    map['checked'] = Variable<bool>(checked);
    map['position'] = Variable<int>(position);
    map['added_at'] = Variable<DateTime>(addedAt);
    if (!nullToAbsent || checkedAt != null) {
      map['checked_at'] = Variable<DateTime>(checkedAt);
    }
    return map;
  }

  ListItemsCompanion toCompanion(bool nullToAbsent) {
    return ListItemsCompanion(
      id: Value(id),
      listId: Value(listId),
      body: Value(body),
      checked: Value(checked),
      position: Value(position),
      addedAt: Value(addedAt),
      checkedAt: checkedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(checkedAt),
    );
  }

  factory ListItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListItemRow(
      id: serializer.fromJson<int>(json['id']),
      listId: serializer.fromJson<int>(json['listId']),
      body: serializer.fromJson<String>(json['body']),
      checked: serializer.fromJson<bool>(json['checked']),
      position: serializer.fromJson<int>(json['position']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      checkedAt: serializer.fromJson<DateTime?>(json['checkedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'listId': serializer.toJson<int>(listId),
      'body': serializer.toJson<String>(body),
      'checked': serializer.toJson<bool>(checked),
      'position': serializer.toJson<int>(position),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'checkedAt': serializer.toJson<DateTime?>(checkedAt),
    };
  }

  ListItemRow copyWith(
          {int? id,
          int? listId,
          String? body,
          bool? checked,
          int? position,
          DateTime? addedAt,
          Value<DateTime?> checkedAt = const Value.absent()}) =>
      ListItemRow(
        id: id ?? this.id,
        listId: listId ?? this.listId,
        body: body ?? this.body,
        checked: checked ?? this.checked,
        position: position ?? this.position,
        addedAt: addedAt ?? this.addedAt,
        checkedAt: checkedAt.present ? checkedAt.value : this.checkedAt,
      );
  ListItemRow copyWithCompanion(ListItemsCompanion data) {
    return ListItemRow(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      body: data.body.present ? data.body.value : this.body,
      checked: data.checked.present ? data.checked.value : this.checked,
      position: data.position.present ? data.position.value : this.position,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      checkedAt: data.checkedAt.present ? data.checkedAt.value : this.checkedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListItemRow(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('body: $body, ')
          ..write('checked: $checked, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt, ')
          ..write('checkedAt: $checkedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, listId, body, checked, position, addedAt, checkedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListItemRow &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.body == this.body &&
          other.checked == this.checked &&
          other.position == this.position &&
          other.addedAt == this.addedAt &&
          other.checkedAt == this.checkedAt);
}

class ListItemsCompanion extends UpdateCompanion<ListItemRow> {
  final Value<int> id;
  final Value<int> listId;
  final Value<String> body;
  final Value<bool> checked;
  final Value<int> position;
  final Value<DateTime> addedAt;
  final Value<DateTime?> checkedAt;
  const ListItemsCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.body = const Value.absent(),
    this.checked = const Value.absent(),
    this.position = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.checkedAt = const Value.absent(),
  });
  ListItemsCompanion.insert({
    this.id = const Value.absent(),
    required int listId,
    required String body,
    this.checked = const Value.absent(),
    required int position,
    required DateTime addedAt,
    this.checkedAt = const Value.absent(),
  })  : listId = Value(listId),
        body = Value(body),
        position = Value(position),
        addedAt = Value(addedAt);
  static Insertable<ListItemRow> custom({
    Expression<int>? id,
    Expression<int>? listId,
    Expression<String>? body,
    Expression<bool>? checked,
    Expression<int>? position,
    Expression<DateTime>? addedAt,
    Expression<DateTime>? checkedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (body != null) 'body': body,
      if (checked != null) 'checked': checked,
      if (position != null) 'position': position,
      if (addedAt != null) 'added_at': addedAt,
      if (checkedAt != null) 'checked_at': checkedAt,
    });
  }

  ListItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? listId,
      Value<String>? body,
      Value<bool>? checked,
      Value<int>? position,
      Value<DateTime>? addedAt,
      Value<DateTime?>? checkedAt}) {
    return ListItemsCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      body: body ?? this.body,
      checked: checked ?? this.checked,
      position: position ?? this.position,
      addedAt: addedAt ?? this.addedAt,
      checkedAt: checkedAt ?? this.checkedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (checked.present) {
      map['checked'] = Variable<bool>(checked.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (checkedAt.present) {
      map['checked_at'] = Variable<DateTime>(checkedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListItemsCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('body: $body, ')
          ..write('checked: $checked, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt, ')
          ..write('checkedAt: $checkedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppSettingsEntriesTable appSettingsEntries =
      $AppSettingsEntriesTable(this);
  late final $ScheduleBlocksTable scheduleBlocks = $ScheduleBlocksTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $SubtasksTable subtasks = $SubtasksTable(this);
  late final $ScheduleBlockExceptionsTable scheduleBlockExceptions =
      $ScheduleBlockExceptionsTable(this);
  late final $FocusSessionsTable focusSessions = $FocusSessionsTable(this);
  late final $AiProviderConfigsTable aiProviderConfigs =
      $AiProviderConfigsTable(this);
  late final $AiConversationsTable aiConversations =
      $AiConversationsTable(this);
  late final $AiMessagesTable aiMessages = $AiMessagesTable(this);
  late final $UtterancesTable utterances = $UtterancesTable(this);
  late final $AssistantActionsTable assistantActions =
      $AssistantActionsTable(this);
  late final $ProposalsTable proposals = $ProposalsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $ListsTable lists = $ListsTable(this);
  late final $ListItemsTable listItems = $ListItemsTable(this);
  late final Index tasksScheduleBlockId = Index('tasks_schedule_block_id',
      'CREATE INDEX tasks_schedule_block_id ON tasks (schedule_block_id)');
  late final Index subtasksTaskOrder = Index('subtasks_task_order',
      'CREATE INDEX subtasks_task_order ON subtasks (task_id, order_index)');
  late final Index scheduleBlocksStartTime = Index('schedule_blocks_start_time',
      'CREATE INDEX schedule_blocks_start_time ON schedule_blocks (start_time)');
  late final Index scheduleBlocksSeriesOccurrence = Index(
      'schedule_blocks_series_occurrence',
      'CREATE UNIQUE INDEX schedule_blocks_series_occurrence ON schedule_blocks (series_id, occurrence_date)');
  late final Index focusSessionsOneActive = Index('focus_sessions_one_active',
      'CREATE UNIQUE INDEX focus_sessions_one_active ON focus_sessions (completed_at IS NULL) WHERE completed_at IS NULL');
  late final Index focusSessionsCompletedAt = Index(
      'focus_sessions_completed_at',
      'CREATE INDEX focus_sessions_completed_at ON focus_sessions (completed_at)');
  late final Index aiMessagesConversationOrder = Index(
      'ai_messages_conversation_order',
      'CREATE INDEX ai_messages_conversation_order ON ai_messages (conversation_id, sent_at, id)');
  late final Index utterancesAt =
      Index('utterances_at', 'CREATE INDEX utterances_at ON utterances (at)');
  late final Index assistantActionsAt = Index('assistant_actions_at',
      'CREATE INDEX assistant_actions_at ON assistant_actions (at)');
  late final Index assistantActionsGroup = Index('assistant_actions_group',
      'CREATE INDEX assistant_actions_group ON assistant_actions (group_id)');
  late final Index proposalsOpenKey = Index('proposals_open_key',
      'CREATE UNIQUE INDEX proposals_open_key ON proposals (dedupe_key) WHERE status = 0');
  late final Index proposalsStatus = Index('proposals_status',
      'CREATE INDEX proposals_status ON proposals (status)');
  late final Index remindersStatusFireAt = Index('reminders_status_fire_at',
      'CREATE INDEX reminders_status_fire_at ON reminders (status, fire_at)');
  late final Index listsNameNocase = Index('lists_name_nocase',
      'CREATE UNIQUE INDEX lists_name_nocase ON lists (name COLLATE NOCASE)');
  late final Index listItemsListPosition = Index('list_items_list_position',
      'CREATE INDEX list_items_list_position ON list_items (list_id, position)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        appSettingsEntries,
        scheduleBlocks,
        tasks,
        subtasks,
        scheduleBlockExceptions,
        focusSessions,
        aiProviderConfigs,
        aiConversations,
        aiMessages,
        utterances,
        assistantActions,
        proposals,
        reminders,
        lists,
        listItems,
        tasksScheduleBlockId,
        subtasksTaskOrder,
        scheduleBlocksStartTime,
        scheduleBlocksSeriesOccurrence,
        focusSessionsOneActive,
        focusSessionsCompletedAt,
        aiMessagesConversationOrder,
        utterancesAt,
        assistantActionsAt,
        assistantActionsGroup,
        proposalsOpenKey,
        proposalsStatus,
        remindersStatusFireAt,
        listsNameNocase,
        listItemsListPosition
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('schedule_blocks',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('schedule_blocks', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('schedule_blocks',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('tasks', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tasks',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('subtasks', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('schedule_blocks',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('schedule_block_exceptions', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tasks',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('focus_sessions', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('subtasks',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('focus_sessions', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('ai_conversations',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('ai_messages', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('utterances',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('assistant_actions', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tasks',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('reminders', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('lists',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('list_items', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$AppSettingsEntriesTableCreateCompanionBuilder
    = AppSettingsEntriesCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppSettingsEntriesTableUpdateCompanionBuilder
    = AppSettingsEntriesCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppSettingsEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsEntriesTable> {
  $$AppSettingsEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsEntriesTable> {
  $$AppSettingsEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsEntriesTable> {
  $$AppSettingsEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsEntriesTable,
    AppSettingRow,
    $$AppSettingsEntriesTableFilterComposer,
    $$AppSettingsEntriesTableOrderingComposer,
    $$AppSettingsEntriesTableAnnotationComposer,
    $$AppSettingsEntriesTableCreateCompanionBuilder,
    $$AppSettingsEntriesTableUpdateCompanionBuilder,
    (
      AppSettingRow,
      BaseReferences<_$AppDatabase, $AppSettingsEntriesTable, AppSettingRow>
    ),
    AppSettingRow,
    PrefetchHooks Function()> {
  $$AppSettingsEntriesTableTableManager(
      _$AppDatabase db, $AppSettingsEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsEntriesCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsEntriesCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AppSettingsEntriesTable, AppSettingRow>(table),
                    BaseReferences<_$AppDatabase, $AppSettingsEntriesTable,
                        AppSettingRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsEntriesTable,
    AppSettingRow,
    $$AppSettingsEntriesTableFilterComposer,
    $$AppSettingsEntriesTableOrderingComposer,
    $$AppSettingsEntriesTableAnnotationComposer,
    $$AppSettingsEntriesTableCreateCompanionBuilder,
    $$AppSettingsEntriesTableUpdateCompanionBuilder,
    (
      AppSettingRow,
      BaseReferences<_$AppDatabase, $AppSettingsEntriesTable, AppSettingRow>
    ),
    AppSettingRow,
    PrefetchHooks Function()>;
typedef $$ScheduleBlocksTableCreateCompanionBuilder = ScheduleBlocksCompanion
    Function({
  Value<int> id,
  required String title,
  required DateTime startTime,
  required DateTime endTime,
  Value<ScheduleBlockSource> source,
  Value<bool> isLocked,
  Value<String?> recurrence,
  Value<DateTime?> recurrenceUntil,
  Value<int?> seriesId,
  Value<DateTime?> occurrenceDate,
});
typedef $$ScheduleBlocksTableUpdateCompanionBuilder = ScheduleBlocksCompanion
    Function({
  Value<int> id,
  Value<String> title,
  Value<DateTime> startTime,
  Value<DateTime> endTime,
  Value<ScheduleBlockSource> source,
  Value<bool> isLocked,
  Value<String?> recurrence,
  Value<DateTime?> recurrenceUntil,
  Value<int?> seriesId,
  Value<DateTime?> occurrenceDate,
});

final class $$ScheduleBlocksTableReferences extends BaseReferences<
    _$AppDatabase, $ScheduleBlocksTable, ScheduleBlockRow> {
  $$ScheduleBlocksTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ScheduleBlocksTable _seriesIdTable(_$AppDatabase db) =>
      db.scheduleBlocks
          .createAlias('schedule_blocks__series_id__schedule_blocks__id');

  $$ScheduleBlocksTableProcessedTableManager? get seriesId {
    final $_column = $_itemColumn<int>('series_id');
    if ($_column == null) return null;
    final manager = $$ScheduleBlocksTableTableManager($_db, $_db.scheduleBlocks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seriesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TasksTable, List<TaskRow>> _tasksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tasks,
          aliasName: 'schedule_blocks__id__tasks__schedule_block_id');

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager($_db, $_db.tasks).filter(
        (f) => f.scheduleBlockId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ScheduleBlockExceptionsTable,
      List<ScheduleBlockExceptionRow>> _scheduleBlockExceptionsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.scheduleBlockExceptions,
          aliasName:
              'schedule_blocks__id__schedule_block_exceptions__series_id');

  $$ScheduleBlockExceptionsTableProcessedTableManager
      get scheduleBlockExceptionsRefs {
    final manager = $$ScheduleBlockExceptionsTableTableManager(
            $_db, $_db.scheduleBlockExceptions)
        .filter((f) => f.seriesId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_scheduleBlockExceptionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ScheduleBlocksTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduleBlocksTable> {
  $$ScheduleBlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ScheduleBlockSource, ScheduleBlockSource, int>
      get source => $composableBuilder(
          column: $table.source,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isLocked => $composableBuilder(
      column: $table.isLocked, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrence => $composableBuilder(
      column: $table.recurrence, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recurrenceUntil => $composableBuilder(
      column: $table.recurrenceUntil,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurrenceDate => $composableBuilder(
      column: $table.occurrenceDate,
      builder: (column) => ColumnFilters(column));

  $$ScheduleBlocksTableFilterComposer get seriesId {
    final $$ScheduleBlocksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seriesId,
        referencedTable: $db.scheduleBlocks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduleBlocksTableFilterComposer(
              $db: $db,
              $table: $db.scheduleBlocks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> tasksRefs(
      Expression<bool> Function($$TasksTableFilterComposer f) f) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.scheduleBlockId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> scheduleBlockExceptionsRefs(
      Expression<bool> Function($$ScheduleBlockExceptionsTableFilterComposer f)
          f) {
    final $$ScheduleBlockExceptionsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.scheduleBlockExceptions,
            getReferencedColumn: (t) => t.seriesId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ScheduleBlockExceptionsTableFilterComposer(
                  $db: $db,
                  $table: $db.scheduleBlockExceptions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ScheduleBlocksTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduleBlocksTable> {
  $$ScheduleBlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isLocked => $composableBuilder(
      column: $table.isLocked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrence => $composableBuilder(
      column: $table.recurrence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recurrenceUntil => $composableBuilder(
      column: $table.recurrenceUntil,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurrenceDate => $composableBuilder(
      column: $table.occurrenceDate,
      builder: (column) => ColumnOrderings(column));

  $$ScheduleBlocksTableOrderingComposer get seriesId {
    final $$ScheduleBlocksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seriesId,
        referencedTable: $db.scheduleBlocks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduleBlocksTableOrderingComposer(
              $db: $db,
              $table: $db.scheduleBlocks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScheduleBlocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduleBlocksTable> {
  $$ScheduleBlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ScheduleBlockSource, int> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  GeneratedColumn<String> get recurrence => $composableBuilder(
      column: $table.recurrence, builder: (column) => column);

  GeneratedColumn<DateTime> get recurrenceUntil => $composableBuilder(
      column: $table.recurrenceUntil, builder: (column) => column);

  GeneratedColumn<DateTime> get occurrenceDate => $composableBuilder(
      column: $table.occurrenceDate, builder: (column) => column);

  $$ScheduleBlocksTableAnnotationComposer get seriesId {
    final $$ScheduleBlocksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seriesId,
        referencedTable: $db.scheduleBlocks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduleBlocksTableAnnotationComposer(
              $db: $db,
              $table: $db.scheduleBlocks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> tasksRefs<T extends Object>(
      Expression<T> Function($$TasksTableAnnotationComposer a) f) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.scheduleBlockId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> scheduleBlockExceptionsRefs<T extends Object>(
      Expression<T> Function($$ScheduleBlockExceptionsTableAnnotationComposer a)
          f) {
    final $$ScheduleBlockExceptionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.scheduleBlockExceptions,
            getReferencedColumn: (t) => t.seriesId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ScheduleBlockExceptionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.scheduleBlockExceptions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ScheduleBlocksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScheduleBlocksTable,
    ScheduleBlockRow,
    $$ScheduleBlocksTableFilterComposer,
    $$ScheduleBlocksTableOrderingComposer,
    $$ScheduleBlocksTableAnnotationComposer,
    $$ScheduleBlocksTableCreateCompanionBuilder,
    $$ScheduleBlocksTableUpdateCompanionBuilder,
    (ScheduleBlockRow, $$ScheduleBlocksTableReferences),
    ScheduleBlockRow,
    PrefetchHooks Function(
        {bool seriesId, bool tasksRefs, bool scheduleBlockExceptionsRefs})> {
  $$ScheduleBlocksTableTableManager(
      _$AppDatabase db, $ScheduleBlocksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleBlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleBlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleBlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<DateTime> endTime = const Value.absent(),
            Value<ScheduleBlockSource> source = const Value.absent(),
            Value<bool> isLocked = const Value.absent(),
            Value<String?> recurrence = const Value.absent(),
            Value<DateTime?> recurrenceUntil = const Value.absent(),
            Value<int?> seriesId = const Value.absent(),
            Value<DateTime?> occurrenceDate = const Value.absent(),
          }) =>
              ScheduleBlocksCompanion(
            id: id,
            title: title,
            startTime: startTime,
            endTime: endTime,
            source: source,
            isLocked: isLocked,
            recurrence: recurrence,
            recurrenceUntil: recurrenceUntil,
            seriesId: seriesId,
            occurrenceDate: occurrenceDate,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required DateTime startTime,
            required DateTime endTime,
            Value<ScheduleBlockSource> source = const Value.absent(),
            Value<bool> isLocked = const Value.absent(),
            Value<String?> recurrence = const Value.absent(),
            Value<DateTime?> recurrenceUntil = const Value.absent(),
            Value<int?> seriesId = const Value.absent(),
            Value<DateTime?> occurrenceDate = const Value.absent(),
          }) =>
              ScheduleBlocksCompanion.insert(
            id: id,
            title: title,
            startTime: startTime,
            endTime: endTime,
            source: source,
            isLocked: isLocked,
            recurrence: recurrence,
            recurrenceUntil: recurrenceUntil,
            seriesId: seriesId,
            occurrenceDate: occurrenceDate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ScheduleBlocksTable, ScheduleBlockRow>(table),
                    $$ScheduleBlocksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {seriesId = false,
              tasksRefs = false,
              scheduleBlockExceptionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tasksRefs) db.tasks,
                if (scheduleBlockExceptionsRefs) db.scheduleBlockExceptions
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (seriesId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.seriesId,
                    referencedTable:
                        $$ScheduleBlocksTableReferences._seriesIdTable(db),
                    referencedColumn:
                        $$ScheduleBlocksTableReferences._seriesIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tasksRefs)
                    await $_getPrefetchedData<ScheduleBlockRow,
                            $ScheduleBlocksTable, TaskRow>(
                        currentTable: table,
                        referencedTable:
                            $$ScheduleBlocksTableReferences._tasksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ScheduleBlocksTableReferences(db, table, p0)
                                .tasksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.scheduleBlockId == item.id),
                        typedResults: items),
                  if (scheduleBlockExceptionsRefs)
                    await $_getPrefetchedData<ScheduleBlockRow,
                            $ScheduleBlocksTable, ScheduleBlockExceptionRow>(
                        currentTable: table,
                        referencedTable: $$ScheduleBlocksTableReferences
                            ._scheduleBlockExceptionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ScheduleBlocksTableReferences(db, table, p0)
                                .scheduleBlockExceptionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.seriesId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ScheduleBlocksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScheduleBlocksTable,
    ScheduleBlockRow,
    $$ScheduleBlocksTableFilterComposer,
    $$ScheduleBlocksTableOrderingComposer,
    $$ScheduleBlocksTableAnnotationComposer,
    $$ScheduleBlocksTableCreateCompanionBuilder,
    $$ScheduleBlocksTableUpdateCompanionBuilder,
    (ScheduleBlockRow, $$ScheduleBlocksTableReferences),
    ScheduleBlockRow,
    PrefetchHooks Function(
        {bool seriesId, bool tasksRefs, bool scheduleBlockExceptionsRefs})>;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  Value<int?> scheduleBlockId,
  required String title,
  Value<String> notes,
  required TaskPriority priority,
  required TaskStatus status,
  Value<DateTime?> dueAt,
  Value<DateTime> createdAt,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  Value<int?> scheduleBlockId,
  Value<String> title,
  Value<String> notes,
  Value<TaskPriority> priority,
  Value<TaskStatus> status,
  Value<DateTime?> dueAt,
  Value<DateTime> createdAt,
});

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, TaskRow> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScheduleBlocksTable _scheduleBlockIdTable(_$AppDatabase db) =>
      db.scheduleBlocks
          .createAlias('tasks__schedule_block_id__schedule_blocks__id');

  $$ScheduleBlocksTableProcessedTableManager? get scheduleBlockId {
    final $_column = $_itemColumn<int>('schedule_block_id');
    if ($_column == null) return null;
    final manager = $$ScheduleBlocksTableTableManager($_db, $_db.scheduleBlocks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scheduleBlockIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SubtasksTable, List<SubtaskRow>>
      _subtasksRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.subtasks,
              aliasName: 'tasks__id__subtasks__task_id');

  $$SubtasksTableProcessedTableManager get subtasksRefs {
    final manager = $$SubtasksTableTableManager($_db, $_db.subtasks)
        .filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_subtasksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$FocusSessionsTable, List<FocusSessionRow>>
      _focusSessionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.focusSessions,
              aliasName: 'tasks__id__focus_sessions__task_id');

  $$FocusSessionsTableProcessedTableManager get focusSessionsRefs {
    final manager = $$FocusSessionsTableTableManager($_db, $_db.focusSessions)
        .filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_focusSessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RemindersTable, List<ReminderRow>>
      _remindersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.reminders,
              aliasName: 'tasks__id__reminders__task_id');

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager($_db, $_db.reminders)
        .filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
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
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TaskPriority, TaskPriority, int>
      get priority => $composableBuilder(
          column: $table.priority,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<TaskStatus, TaskStatus, int> get status =>
      $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
      column: $table.dueAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ScheduleBlocksTableFilterComposer get scheduleBlockId {
    final $$ScheduleBlocksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scheduleBlockId,
        referencedTable: $db.scheduleBlocks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduleBlocksTableFilterComposer(
              $db: $db,
              $table: $db.scheduleBlocks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> subtasksRefs(
      Expression<bool> Function($$SubtasksTableFilterComposer f) f) {
    final $$SubtasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subtasks,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubtasksTableFilterComposer(
              $db: $db,
              $table: $db.subtasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> focusSessionsRefs(
      Expression<bool> Function($$FocusSessionsTableFilterComposer f) f) {
    final $$FocusSessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.focusSessions,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FocusSessionsTableFilterComposer(
              $db: $db,
              $table: $db.focusSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> remindersRefs(
      Expression<bool> Function($$RemindersTableFilterComposer f) f) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reminders,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RemindersTableFilterComposer(
              $db: $db,
              $table: $db.reminders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
      column: $table.dueAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ScheduleBlocksTableOrderingComposer get scheduleBlockId {
    final $$ScheduleBlocksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scheduleBlockId,
        referencedTable: $db.scheduleBlocks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduleBlocksTableOrderingComposer(
              $db: $db,
              $table: $db.scheduleBlocks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskPriority, int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ScheduleBlocksTableAnnotationComposer get scheduleBlockId {
    final $$ScheduleBlocksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scheduleBlockId,
        referencedTable: $db.scheduleBlocks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduleBlocksTableAnnotationComposer(
              $db: $db,
              $table: $db.scheduleBlocks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> subtasksRefs<T extends Object>(
      Expression<T> Function($$SubtasksTableAnnotationComposer a) f) {
    final $$SubtasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subtasks,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubtasksTableAnnotationComposer(
              $db: $db,
              $table: $db.subtasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> focusSessionsRefs<T extends Object>(
      Expression<T> Function($$FocusSessionsTableAnnotationComposer a) f) {
    final $$FocusSessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.focusSessions,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FocusSessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.focusSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
      Expression<T> Function($$RemindersTableAnnotationComposer a) f) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reminders,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RemindersTableAnnotationComposer(
              $db: $db,
              $table: $db.reminders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    TaskRow,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (TaskRow, $$TasksTableReferences),
    TaskRow,
    PrefetchHooks Function(
        {bool scheduleBlockId,
        bool subtasksRefs,
        bool focusSessionsRefs,
        bool remindersRefs})> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> scheduleBlockId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<TaskPriority> priority = const Value.absent(),
            Value<TaskStatus> status = const Value.absent(),
            Value<DateTime?> dueAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            scheduleBlockId: scheduleBlockId,
            title: title,
            notes: notes,
            priority: priority,
            status: status,
            dueAt: dueAt,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> scheduleBlockId = const Value.absent(),
            required String title,
            Value<String> notes = const Value.absent(),
            required TaskPriority priority,
            required TaskStatus status,
            Value<DateTime?> dueAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            scheduleBlockId: scheduleBlockId,
            title: title,
            notes: notes,
            priority: priority,
            status: status,
            dueAt: dueAt,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$TasksTable, TaskRow>(table),
                    $$TasksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {scheduleBlockId = false,
              subtasksRefs = false,
              focusSessionsRefs = false,
              remindersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (subtasksRefs) db.subtasks,
                if (focusSessionsRefs) db.focusSessions,
                if (remindersRefs) db.reminders
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (scheduleBlockId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.scheduleBlockId,
                    referencedTable:
                        $$TasksTableReferences._scheduleBlockIdTable(db),
                    referencedColumn:
                        $$TasksTableReferences._scheduleBlockIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (subtasksRefs)
                    await $_getPrefetchedData<TaskRow, $TasksTable, SubtaskRow>(
                        currentTable: table,
                        referencedTable:
                            $$TasksTableReferences._subtasksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0).subtasksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.taskId == item.id),
                        typedResults: items),
                  if (focusSessionsRefs)
                    await $_getPrefetchedData<TaskRow, $TasksTable,
                            FocusSessionRow>(
                        currentTable: table,
                        referencedTable:
                            $$TasksTableReferences._focusSessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0)
                                .focusSessionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.taskId == item.id),
                        typedResults: items),
                  if (remindersRefs)
                    await $_getPrefetchedData<TaskRow, $TasksTable,
                            ReminderRow>(
                        currentTable: table,
                        referencedTable:
                            $$TasksTableReferences._remindersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0).remindersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.taskId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    TaskRow,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (TaskRow, $$TasksTableReferences),
    TaskRow,
    PrefetchHooks Function(
        {bool scheduleBlockId,
        bool subtasksRefs,
        bool focusSessionsRefs,
        bool remindersRefs})>;
typedef $$SubtasksTableCreateCompanionBuilder = SubtasksCompanion Function({
  Value<int> id,
  required int taskId,
  required String title,
  required SubtaskStatus status,
  Value<int> plannedSprints,
  Value<int> completedSprints,
  Value<int> orderIndex,
});
typedef $$SubtasksTableUpdateCompanionBuilder = SubtasksCompanion Function({
  Value<int> id,
  Value<int> taskId,
  Value<String> title,
  Value<SubtaskStatus> status,
  Value<int> plannedSprints,
  Value<int> completedSprints,
  Value<int> orderIndex,
});

final class $$SubtasksTableReferences
    extends BaseReferences<_$AppDatabase, $SubtasksTable, SubtaskRow> {
  $$SubtasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('subtasks__task_id__tasks__id');

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<int>('task_id')!;

    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$FocusSessionsTable, List<FocusSessionRow>>
      _focusSessionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.focusSessions,
              aliasName: 'subtasks__id__focus_sessions__subtask_id');

  $$FocusSessionsTableProcessedTableManager get focusSessionsRefs {
    final manager = $$FocusSessionsTableTableManager($_db, $_db.focusSessions)
        .filter((f) => f.subtaskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_focusSessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SubtasksTableFilterComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SubtaskStatus, SubtaskStatus, int>
      get status => $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get plannedSprints => $composableBuilder(
      column: $table.plannedSprints,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedSprints => $composableBuilder(
      column: $table.completedSprints,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> focusSessionsRefs(
      Expression<bool> Function($$FocusSessionsTableFilterComposer f) f) {
    final $$FocusSessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.focusSessions,
        getReferencedColumn: (t) => t.subtaskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FocusSessionsTableFilterComposer(
              $db: $db,
              $table: $db.focusSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SubtasksTableOrderingComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get plannedSprints => $composableBuilder(
      column: $table.plannedSprints,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedSprints => $composableBuilder(
      column: $table.completedSprints,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SubtasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SubtaskStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get plannedSprints => $composableBuilder(
      column: $table.plannedSprints, builder: (column) => column);

  GeneratedColumn<int> get completedSprints => $composableBuilder(
      column: $table.completedSprints, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> focusSessionsRefs<T extends Object>(
      Expression<T> Function($$FocusSessionsTableAnnotationComposer a) f) {
    final $$FocusSessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.focusSessions,
        getReferencedColumn: (t) => t.subtaskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FocusSessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.focusSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SubtasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubtasksTable,
    SubtaskRow,
    $$SubtasksTableFilterComposer,
    $$SubtasksTableOrderingComposer,
    $$SubtasksTableAnnotationComposer,
    $$SubtasksTableCreateCompanionBuilder,
    $$SubtasksTableUpdateCompanionBuilder,
    (SubtaskRow, $$SubtasksTableReferences),
    SubtaskRow,
    PrefetchHooks Function({bool taskId, bool focusSessionsRefs})> {
  $$SubtasksTableTableManager(_$AppDatabase db, $SubtasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubtasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubtasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubtasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> taskId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<SubtaskStatus> status = const Value.absent(),
            Value<int> plannedSprints = const Value.absent(),
            Value<int> completedSprints = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
          }) =>
              SubtasksCompanion(
            id: id,
            taskId: taskId,
            title: title,
            status: status,
            plannedSprints: plannedSprints,
            completedSprints: completedSprints,
            orderIndex: orderIndex,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int taskId,
            required String title,
            required SubtaskStatus status,
            Value<int> plannedSprints = const Value.absent(),
            Value<int> completedSprints = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
          }) =>
              SubtasksCompanion.insert(
            id: id,
            taskId: taskId,
            title: title,
            status: status,
            plannedSprints: plannedSprints,
            completedSprints: completedSprints,
            orderIndex: orderIndex,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SubtasksTable, SubtaskRow>(table),
                    $$SubtasksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({taskId = false, focusSessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (focusSessionsRefs) db.focusSessions
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable: $$SubtasksTableReferences._taskIdTable(db),
                    referencedColumn:
                        $$SubtasksTableReferences._taskIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (focusSessionsRefs)
                    await $_getPrefetchedData<SubtaskRow, $SubtasksTable,
                            FocusSessionRow>(
                        currentTable: table,
                        referencedTable: $$SubtasksTableReferences
                            ._focusSessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SubtasksTableReferences(db, table, p0)
                                .focusSessionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.subtaskId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SubtasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubtasksTable,
    SubtaskRow,
    $$SubtasksTableFilterComposer,
    $$SubtasksTableOrderingComposer,
    $$SubtasksTableAnnotationComposer,
    $$SubtasksTableCreateCompanionBuilder,
    $$SubtasksTableUpdateCompanionBuilder,
    (SubtaskRow, $$SubtasksTableReferences),
    SubtaskRow,
    PrefetchHooks Function({bool taskId, bool focusSessionsRefs})>;
typedef $$ScheduleBlockExceptionsTableCreateCompanionBuilder
    = ScheduleBlockExceptionsCompanion Function({
  required int seriesId,
  required DateTime occurrenceDate,
  Value<int> rowid,
});
typedef $$ScheduleBlockExceptionsTableUpdateCompanionBuilder
    = ScheduleBlockExceptionsCompanion Function({
  Value<int> seriesId,
  Value<DateTime> occurrenceDate,
  Value<int> rowid,
});

final class $$ScheduleBlockExceptionsTableReferences extends BaseReferences<
    _$AppDatabase, $ScheduleBlockExceptionsTable, ScheduleBlockExceptionRow> {
  $$ScheduleBlockExceptionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ScheduleBlocksTable _seriesIdTable(_$AppDatabase db) => db
      .scheduleBlocks
      .createAlias('schedule_block_exceptions__series_id__schedule_blocks__id');

  $$ScheduleBlocksTableProcessedTableManager get seriesId {
    final $_column = $_itemColumn<int>('series_id')!;

    final manager = $$ScheduleBlocksTableTableManager($_db, $_db.scheduleBlocks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seriesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ScheduleBlockExceptionsTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduleBlockExceptionsTable> {
  $$ScheduleBlockExceptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get occurrenceDate => $composableBuilder(
      column: $table.occurrenceDate,
      builder: (column) => ColumnFilters(column));

  $$ScheduleBlocksTableFilterComposer get seriesId {
    final $$ScheduleBlocksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seriesId,
        referencedTable: $db.scheduleBlocks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduleBlocksTableFilterComposer(
              $db: $db,
              $table: $db.scheduleBlocks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScheduleBlockExceptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduleBlockExceptionsTable> {
  $$ScheduleBlockExceptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get occurrenceDate => $composableBuilder(
      column: $table.occurrenceDate,
      builder: (column) => ColumnOrderings(column));

  $$ScheduleBlocksTableOrderingComposer get seriesId {
    final $$ScheduleBlocksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seriesId,
        referencedTable: $db.scheduleBlocks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduleBlocksTableOrderingComposer(
              $db: $db,
              $table: $db.scheduleBlocks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScheduleBlockExceptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduleBlockExceptionsTable> {
  $$ScheduleBlockExceptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get occurrenceDate => $composableBuilder(
      column: $table.occurrenceDate, builder: (column) => column);

  $$ScheduleBlocksTableAnnotationComposer get seriesId {
    final $$ScheduleBlocksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seriesId,
        referencedTable: $db.scheduleBlocks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScheduleBlocksTableAnnotationComposer(
              $db: $db,
              $table: $db.scheduleBlocks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScheduleBlockExceptionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScheduleBlockExceptionsTable,
    ScheduleBlockExceptionRow,
    $$ScheduleBlockExceptionsTableFilterComposer,
    $$ScheduleBlockExceptionsTableOrderingComposer,
    $$ScheduleBlockExceptionsTableAnnotationComposer,
    $$ScheduleBlockExceptionsTableCreateCompanionBuilder,
    $$ScheduleBlockExceptionsTableUpdateCompanionBuilder,
    (ScheduleBlockExceptionRow, $$ScheduleBlockExceptionsTableReferences),
    ScheduleBlockExceptionRow,
    PrefetchHooks Function({bool seriesId})> {
  $$ScheduleBlockExceptionsTableTableManager(
      _$AppDatabase db, $ScheduleBlockExceptionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleBlockExceptionsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleBlockExceptionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleBlockExceptionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> seriesId = const Value.absent(),
            Value<DateTime> occurrenceDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ScheduleBlockExceptionsCompanion(
            seriesId: seriesId,
            occurrenceDate: occurrenceDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int seriesId,
            required DateTime occurrenceDate,
            Value<int> rowid = const Value.absent(),
          }) =>
              ScheduleBlockExceptionsCompanion.insert(
            seriesId: seriesId,
            occurrenceDate: occurrenceDate,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ScheduleBlockExceptionsTable,
                        ScheduleBlockExceptionRow>(table),
                    $$ScheduleBlockExceptionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({seriesId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (seriesId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.seriesId,
                    referencedTable: $$ScheduleBlockExceptionsTableReferences
                        ._seriesIdTable(db),
                    referencedColumn: $$ScheduleBlockExceptionsTableReferences
                        ._seriesIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ScheduleBlockExceptionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ScheduleBlockExceptionsTable,
        ScheduleBlockExceptionRow,
        $$ScheduleBlockExceptionsTableFilterComposer,
        $$ScheduleBlockExceptionsTableOrderingComposer,
        $$ScheduleBlockExceptionsTableAnnotationComposer,
        $$ScheduleBlockExceptionsTableCreateCompanionBuilder,
        $$ScheduleBlockExceptionsTableUpdateCompanionBuilder,
        (ScheduleBlockExceptionRow, $$ScheduleBlockExceptionsTableReferences),
        ScheduleBlockExceptionRow,
        PrefetchHooks Function({bool seriesId})>;
typedef $$FocusSessionsTableCreateCompanionBuilder = FocusSessionsCompanion
    Function({
  Value<int> id,
  Value<int?> taskId,
  Value<int?> subtaskId,
  required FocusSessionType sessionType,
  required int plannedDurationSec,
  required DateTime startedAt,
  Value<DateTime?> segmentStartedAt,
  required int remainingSecAtSegmentStart,
  Value<bool> isPaused,
  Value<DateTime?> completedAt,
  Value<int?> actualDurationSec,
  Value<bool> endedEarly,
});
typedef $$FocusSessionsTableUpdateCompanionBuilder = FocusSessionsCompanion
    Function({
  Value<int> id,
  Value<int?> taskId,
  Value<int?> subtaskId,
  Value<FocusSessionType> sessionType,
  Value<int> plannedDurationSec,
  Value<DateTime> startedAt,
  Value<DateTime?> segmentStartedAt,
  Value<int> remainingSecAtSegmentStart,
  Value<bool> isPaused,
  Value<DateTime?> completedAt,
  Value<int?> actualDurationSec,
  Value<bool> endedEarly,
});

final class $$FocusSessionsTableReferences extends BaseReferences<_$AppDatabase,
    $FocusSessionsTable, FocusSessionRow> {
  $$FocusSessionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('focus_sessions__task_id__tasks__id');

  $$TasksTableProcessedTableManager? get taskId {
    final $_column = $_itemColumn<int>('task_id');
    if ($_column == null) return null;
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SubtasksTable _subtaskIdTable(_$AppDatabase db) =>
      db.subtasks.createAlias('focus_sessions__subtask_id__subtasks__id');

  $$SubtasksTableProcessedTableManager? get subtaskId {
    final $_column = $_itemColumn<int>('subtask_id');
    if ($_column == null) return null;
    final manager = $$SubtasksTableTableManager($_db, $_db.subtasks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subtaskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FocusSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<FocusSessionType, FocusSessionType, int>
      get sessionType => $composableBuilder(
          column: $table.sessionType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get plannedDurationSec => $composableBuilder(
      column: $table.plannedDurationSec,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get segmentStartedAt => $composableBuilder(
      column: $table.segmentStartedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get remainingSecAtSegmentStart => $composableBuilder(
      column: $table.remainingSecAtSegmentStart,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPaused => $composableBuilder(
      column: $table.isPaused, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get actualDurationSec => $composableBuilder(
      column: $table.actualDurationSec,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get endedEarly => $composableBuilder(
      column: $table.endedEarly, builder: (column) => ColumnFilters(column));

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubtasksTableFilterComposer get subtaskId {
    final $$SubtasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subtaskId,
        referencedTable: $db.subtasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubtasksTableFilterComposer(
              $db: $db,
              $table: $db.subtasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FocusSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sessionType => $composableBuilder(
      column: $table.sessionType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get plannedDurationSec => $composableBuilder(
      column: $table.plannedDurationSec,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get segmentStartedAt => $composableBuilder(
      column: $table.segmentStartedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get remainingSecAtSegmentStart => $composableBuilder(
      column: $table.remainingSecAtSegmentStart,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPaused => $composableBuilder(
      column: $table.isPaused, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get actualDurationSec => $composableBuilder(
      column: $table.actualDurationSec,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get endedEarly => $composableBuilder(
      column: $table.endedEarly, builder: (column) => ColumnOrderings(column));

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubtasksTableOrderingComposer get subtaskId {
    final $$SubtasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subtaskId,
        referencedTable: $db.subtasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubtasksTableOrderingComposer(
              $db: $db,
              $table: $db.subtasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FocusSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FocusSessionType, int> get sessionType =>
      $composableBuilder(
          column: $table.sessionType, builder: (column) => column);

  GeneratedColumn<int> get plannedDurationSec => $composableBuilder(
      column: $table.plannedDurationSec, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get segmentStartedAt => $composableBuilder(
      column: $table.segmentStartedAt, builder: (column) => column);

  GeneratedColumn<int> get remainingSecAtSegmentStart => $composableBuilder(
      column: $table.remainingSecAtSegmentStart, builder: (column) => column);

  GeneratedColumn<bool> get isPaused =>
      $composableBuilder(column: $table.isPaused, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<int> get actualDurationSec => $composableBuilder(
      column: $table.actualDurationSec, builder: (column) => column);

  GeneratedColumn<bool> get endedEarly => $composableBuilder(
      column: $table.endedEarly, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SubtasksTableAnnotationComposer get subtaskId {
    final $$SubtasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subtaskId,
        referencedTable: $db.subtasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubtasksTableAnnotationComposer(
              $db: $db,
              $table: $db.subtasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FocusSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FocusSessionsTable,
    FocusSessionRow,
    $$FocusSessionsTableFilterComposer,
    $$FocusSessionsTableOrderingComposer,
    $$FocusSessionsTableAnnotationComposer,
    $$FocusSessionsTableCreateCompanionBuilder,
    $$FocusSessionsTableUpdateCompanionBuilder,
    (FocusSessionRow, $$FocusSessionsTableReferences),
    FocusSessionRow,
    PrefetchHooks Function({bool taskId, bool subtaskId})> {
  $$FocusSessionsTableTableManager(_$AppDatabase db, $FocusSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FocusSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FocusSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FocusSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> taskId = const Value.absent(),
            Value<int?> subtaskId = const Value.absent(),
            Value<FocusSessionType> sessionType = const Value.absent(),
            Value<int> plannedDurationSec = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> segmentStartedAt = const Value.absent(),
            Value<int> remainingSecAtSegmentStart = const Value.absent(),
            Value<bool> isPaused = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int?> actualDurationSec = const Value.absent(),
            Value<bool> endedEarly = const Value.absent(),
          }) =>
              FocusSessionsCompanion(
            id: id,
            taskId: taskId,
            subtaskId: subtaskId,
            sessionType: sessionType,
            plannedDurationSec: plannedDurationSec,
            startedAt: startedAt,
            segmentStartedAt: segmentStartedAt,
            remainingSecAtSegmentStart: remainingSecAtSegmentStart,
            isPaused: isPaused,
            completedAt: completedAt,
            actualDurationSec: actualDurationSec,
            endedEarly: endedEarly,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> taskId = const Value.absent(),
            Value<int?> subtaskId = const Value.absent(),
            required FocusSessionType sessionType,
            required int plannedDurationSec,
            required DateTime startedAt,
            Value<DateTime?> segmentStartedAt = const Value.absent(),
            required int remainingSecAtSegmentStart,
            Value<bool> isPaused = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int?> actualDurationSec = const Value.absent(),
            Value<bool> endedEarly = const Value.absent(),
          }) =>
              FocusSessionsCompanion.insert(
            id: id,
            taskId: taskId,
            subtaskId: subtaskId,
            sessionType: sessionType,
            plannedDurationSec: plannedDurationSec,
            startedAt: startedAt,
            segmentStartedAt: segmentStartedAt,
            remainingSecAtSegmentStart: remainingSecAtSegmentStart,
            isPaused: isPaused,
            completedAt: completedAt,
            actualDurationSec: actualDurationSec,
            endedEarly: endedEarly,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$FocusSessionsTable, FocusSessionRow>(table),
                    $$FocusSessionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({taskId = false, subtaskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable:
                        $$FocusSessionsTableReferences._taskIdTable(db),
                    referencedColumn:
                        $$FocusSessionsTableReferences._taskIdTable(db).id,
                  ) as T;
                }
                if (subtaskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.subtaskId,
                    referencedTable:
                        $$FocusSessionsTableReferences._subtaskIdTable(db),
                    referencedColumn:
                        $$FocusSessionsTableReferences._subtaskIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$FocusSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FocusSessionsTable,
    FocusSessionRow,
    $$FocusSessionsTableFilterComposer,
    $$FocusSessionsTableOrderingComposer,
    $$FocusSessionsTableAnnotationComposer,
    $$FocusSessionsTableCreateCompanionBuilder,
    $$FocusSessionsTableUpdateCompanionBuilder,
    (FocusSessionRow, $$FocusSessionsTableReferences),
    FocusSessionRow,
    PrefetchHooks Function({bool taskId, bool subtaskId})>;
typedef $$AiProviderConfigsTableCreateCompanionBuilder
    = AiProviderConfigsCompanion Function({
  Value<AIProviderId> providerId,
  required String displayName,
  required String defaultModel,
  Value<String?> baseUrl,
  Value<bool> isActive,
});
typedef $$AiProviderConfigsTableUpdateCompanionBuilder
    = AiProviderConfigsCompanion Function({
  Value<AIProviderId> providerId,
  Value<String> displayName,
  Value<String> defaultModel,
  Value<String?> baseUrl,
  Value<bool> isActive,
});

class $$AiProviderConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $AiProviderConfigsTable> {
  $$AiProviderConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<AIProviderId, AIProviderId, int>
      get providerId => $composableBuilder(
          column: $table.providerId,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultModel => $composableBuilder(
      column: $table.defaultModel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get baseUrl => $composableBuilder(
      column: $table.baseUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));
}

class $$AiProviderConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiProviderConfigsTable> {
  $$AiProviderConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get providerId => $composableBuilder(
      column: $table.providerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultModel => $composableBuilder(
      column: $table.defaultModel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get baseUrl => $composableBuilder(
      column: $table.baseUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$AiProviderConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiProviderConfigsTable> {
  $$AiProviderConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<AIProviderId, int> get providerId =>
      $composableBuilder(
          column: $table.providerId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get defaultModel => $composableBuilder(
      column: $table.defaultModel, builder: (column) => column);

  GeneratedColumn<String> get baseUrl =>
      $composableBuilder(column: $table.baseUrl, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$AiProviderConfigsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AiProviderConfigsTable,
    AiProviderConfigRow,
    $$AiProviderConfigsTableFilterComposer,
    $$AiProviderConfigsTableOrderingComposer,
    $$AiProviderConfigsTableAnnotationComposer,
    $$AiProviderConfigsTableCreateCompanionBuilder,
    $$AiProviderConfigsTableUpdateCompanionBuilder,
    (
      AiProviderConfigRow,
      BaseReferences<_$AppDatabase, $AiProviderConfigsTable,
          AiProviderConfigRow>
    ),
    AiProviderConfigRow,
    PrefetchHooks Function()> {
  $$AiProviderConfigsTableTableManager(
      _$AppDatabase db, $AiProviderConfigsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiProviderConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiProviderConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiProviderConfigsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<AIProviderId> providerId = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String> defaultModel = const Value.absent(),
            Value<String?> baseUrl = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              AiProviderConfigsCompanion(
            providerId: providerId,
            displayName: displayName,
            defaultModel: defaultModel,
            baseUrl: baseUrl,
            isActive: isActive,
          ),
          createCompanionCallback: ({
            Value<AIProviderId> providerId = const Value.absent(),
            required String displayName,
            required String defaultModel,
            Value<String?> baseUrl = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              AiProviderConfigsCompanion.insert(
            providerId: providerId,
            displayName: displayName,
            defaultModel: defaultModel,
            baseUrl: baseUrl,
            isActive: isActive,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AiProviderConfigsTable, AiProviderConfigRow>(
                        table),
                    BaseReferences<_$AppDatabase, $AiProviderConfigsTable,
                        AiProviderConfigRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AiProviderConfigsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AiProviderConfigsTable,
    AiProviderConfigRow,
    $$AiProviderConfigsTableFilterComposer,
    $$AiProviderConfigsTableOrderingComposer,
    $$AiProviderConfigsTableAnnotationComposer,
    $$AiProviderConfigsTableCreateCompanionBuilder,
    $$AiProviderConfigsTableUpdateCompanionBuilder,
    (
      AiProviderConfigRow,
      BaseReferences<_$AppDatabase, $AiProviderConfigsTable,
          AiProviderConfigRow>
    ),
    AiProviderConfigRow,
    PrefetchHooks Function()>;
typedef $$AiConversationsTableCreateCompanionBuilder = AiConversationsCompanion
    Function({
  Value<int> id,
  required AIProviderId providerId,
  required String title,
  Value<DateTime> createdAt,
});
typedef $$AiConversationsTableUpdateCompanionBuilder = AiConversationsCompanion
    Function({
  Value<int> id,
  Value<AIProviderId> providerId,
  Value<String> title,
  Value<DateTime> createdAt,
});

final class $$AiConversationsTableReferences extends BaseReferences<
    _$AppDatabase, $AiConversationsTable, AiConversationRow> {
  $$AiConversationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AiMessagesTable, List<AiMessageRow>>
      _aiMessagesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.aiMessages,
              aliasName: 'ai_conversations__id__ai_messages__conversation_id');

  $$AiMessagesTableProcessedTableManager get aiMessagesRefs {
    final manager = $$AiMessagesTableTableManager($_db, $_db.aiMessages)
        .filter((f) => f.conversationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_aiMessagesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AiConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $AiConversationsTable> {
  $$AiConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<AIProviderId, AIProviderId, int>
      get providerId => $composableBuilder(
          column: $table.providerId,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> aiMessagesRefs(
      Expression<bool> Function($$AiMessagesTableFilterComposer f) f) {
    final $$AiMessagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.aiMessages,
        getReferencedColumn: (t) => t.conversationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AiMessagesTableFilterComposer(
              $db: $db,
              $table: $db.aiMessages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AiConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiConversationsTable> {
  $$AiConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get providerId => $composableBuilder(
      column: $table.providerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$AiConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiConversationsTable> {
  $$AiConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AIProviderId, int> get providerId =>
      $composableBuilder(
          column: $table.providerId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> aiMessagesRefs<T extends Object>(
      Expression<T> Function($$AiMessagesTableAnnotationComposer a) f) {
    final $$AiMessagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.aiMessages,
        getReferencedColumn: (t) => t.conversationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AiMessagesTableAnnotationComposer(
              $db: $db,
              $table: $db.aiMessages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AiConversationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AiConversationsTable,
    AiConversationRow,
    $$AiConversationsTableFilterComposer,
    $$AiConversationsTableOrderingComposer,
    $$AiConversationsTableAnnotationComposer,
    $$AiConversationsTableCreateCompanionBuilder,
    $$AiConversationsTableUpdateCompanionBuilder,
    (AiConversationRow, $$AiConversationsTableReferences),
    AiConversationRow,
    PrefetchHooks Function({bool aiMessagesRefs})> {
  $$AiConversationsTableTableManager(
      _$AppDatabase db, $AiConversationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<AIProviderId> providerId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              AiConversationsCompanion(
            id: id,
            providerId: providerId,
            title: title,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required AIProviderId providerId,
            required String title,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              AiConversationsCompanion.insert(
            id: id,
            providerId: providerId,
            title: title,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AiConversationsTable, AiConversationRow>(
                        table),
                    $$AiConversationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({aiMessagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (aiMessagesRefs) db.aiMessages],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (aiMessagesRefs)
                    await $_getPrefetchedData<AiConversationRow,
                            $AiConversationsTable, AiMessageRow>(
                        currentTable: table,
                        referencedTable: $$AiConversationsTableReferences
                            ._aiMessagesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AiConversationsTableReferences(db, table, p0)
                                .aiMessagesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.conversationId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AiConversationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AiConversationsTable,
    AiConversationRow,
    $$AiConversationsTableFilterComposer,
    $$AiConversationsTableOrderingComposer,
    $$AiConversationsTableAnnotationComposer,
    $$AiConversationsTableCreateCompanionBuilder,
    $$AiConversationsTableUpdateCompanionBuilder,
    (AiConversationRow, $$AiConversationsTableReferences),
    AiConversationRow,
    PrefetchHooks Function({bool aiMessagesRefs})>;
typedef $$AiMessagesTableCreateCompanionBuilder = AiMessagesCompanion Function({
  Value<int> id,
  required int conversationId,
  required AIMessageRole role,
  required String content,
  Value<bool> isError,
  Value<bool> isPending,
  Value<DateTime> sentAt,
  Value<AIFailureKind?> errorKind,
  Value<int?> errorStatus,
  Value<AIStopReason?> stopReason,
  Value<String?> turnGroupId,
});
typedef $$AiMessagesTableUpdateCompanionBuilder = AiMessagesCompanion Function({
  Value<int> id,
  Value<int> conversationId,
  Value<AIMessageRole> role,
  Value<String> content,
  Value<bool> isError,
  Value<bool> isPending,
  Value<DateTime> sentAt,
  Value<AIFailureKind?> errorKind,
  Value<int?> errorStatus,
  Value<AIStopReason?> stopReason,
  Value<String?> turnGroupId,
});

final class $$AiMessagesTableReferences
    extends BaseReferences<_$AppDatabase, $AiMessagesTable, AiMessageRow> {
  $$AiMessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AiConversationsTable _conversationIdTable(_$AppDatabase db) =>
      db.aiConversations
          .createAlias('ai_messages__conversation_id__ai_conversations__id');

  $$AiConversationsTableProcessedTableManager get conversationId {
    final $_column = $_itemColumn<int>('conversation_id')!;

    final manager =
        $$AiConversationsTableTableManager($_db, $_db.aiConversations)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_conversationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AiMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $AiMessagesTable> {
  $$AiMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<AIMessageRole, AIMessageRole, int> get role =>
      $composableBuilder(
          column: $table.role,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isError => $composableBuilder(
      column: $table.isError, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPending => $composableBuilder(
      column: $table.isPending, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
      column: $table.sentAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<AIFailureKind?, AIFailureKind, int>
      get errorKind => $composableBuilder(
          column: $table.errorKind,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get errorStatus => $composableBuilder(
      column: $table.errorStatus, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<AIStopReason?, AIStopReason, int>
      get stopReason => $composableBuilder(
          column: $table.stopReason,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get turnGroupId => $composableBuilder(
      column: $table.turnGroupId, builder: (column) => ColumnFilters(column));

  $$AiConversationsTableFilterComposer get conversationId {
    final $$AiConversationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.conversationId,
        referencedTable: $db.aiConversations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AiConversationsTableFilterComposer(
              $db: $db,
              $table: $db.aiConversations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AiMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $AiMessagesTable> {
  $$AiMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isError => $composableBuilder(
      column: $table.isError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPending => $composableBuilder(
      column: $table.isPending, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
      column: $table.sentAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get errorKind => $composableBuilder(
      column: $table.errorKind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get errorStatus => $composableBuilder(
      column: $table.errorStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stopReason => $composableBuilder(
      column: $table.stopReason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get turnGroupId => $composableBuilder(
      column: $table.turnGroupId, builder: (column) => ColumnOrderings(column));

  $$AiConversationsTableOrderingComposer get conversationId {
    final $$AiConversationsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.conversationId,
        referencedTable: $db.aiConversations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AiConversationsTableOrderingComposer(
              $db: $db,
              $table: $db.aiConversations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AiMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiMessagesTable> {
  $$AiMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AIMessageRole, int> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get isError =>
      $composableBuilder(column: $table.isError, builder: (column) => column);

  GeneratedColumn<bool> get isPending =>
      $composableBuilder(column: $table.isPending, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AIFailureKind?, int> get errorKind =>
      $composableBuilder(column: $table.errorKind, builder: (column) => column);

  GeneratedColumn<int> get errorStatus => $composableBuilder(
      column: $table.errorStatus, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AIStopReason?, int> get stopReason =>
      $composableBuilder(
          column: $table.stopReason, builder: (column) => column);

  GeneratedColumn<String> get turnGroupId => $composableBuilder(
      column: $table.turnGroupId, builder: (column) => column);

  $$AiConversationsTableAnnotationComposer get conversationId {
    final $$AiConversationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.conversationId,
        referencedTable: $db.aiConversations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AiConversationsTableAnnotationComposer(
              $db: $db,
              $table: $db.aiConversations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AiMessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AiMessagesTable,
    AiMessageRow,
    $$AiMessagesTableFilterComposer,
    $$AiMessagesTableOrderingComposer,
    $$AiMessagesTableAnnotationComposer,
    $$AiMessagesTableCreateCompanionBuilder,
    $$AiMessagesTableUpdateCompanionBuilder,
    (AiMessageRow, $$AiMessagesTableReferences),
    AiMessageRow,
    PrefetchHooks Function({bool conversationId})> {
  $$AiMessagesTableTableManager(_$AppDatabase db, $AiMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> conversationId = const Value.absent(),
            Value<AIMessageRole> role = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<bool> isError = const Value.absent(),
            Value<bool> isPending = const Value.absent(),
            Value<DateTime> sentAt = const Value.absent(),
            Value<AIFailureKind?> errorKind = const Value.absent(),
            Value<int?> errorStatus = const Value.absent(),
            Value<AIStopReason?> stopReason = const Value.absent(),
            Value<String?> turnGroupId = const Value.absent(),
          }) =>
              AiMessagesCompanion(
            id: id,
            conversationId: conversationId,
            role: role,
            content: content,
            isError: isError,
            isPending: isPending,
            sentAt: sentAt,
            errorKind: errorKind,
            errorStatus: errorStatus,
            stopReason: stopReason,
            turnGroupId: turnGroupId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int conversationId,
            required AIMessageRole role,
            required String content,
            Value<bool> isError = const Value.absent(),
            Value<bool> isPending = const Value.absent(),
            Value<DateTime> sentAt = const Value.absent(),
            Value<AIFailureKind?> errorKind = const Value.absent(),
            Value<int?> errorStatus = const Value.absent(),
            Value<AIStopReason?> stopReason = const Value.absent(),
            Value<String?> turnGroupId = const Value.absent(),
          }) =>
              AiMessagesCompanion.insert(
            id: id,
            conversationId: conversationId,
            role: role,
            content: content,
            isError: isError,
            isPending: isPending,
            sentAt: sentAt,
            errorKind: errorKind,
            errorStatus: errorStatus,
            stopReason: stopReason,
            turnGroupId: turnGroupId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AiMessagesTable, AiMessageRow>(table),
                    $$AiMessagesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({conversationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (conversationId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.conversationId,
                    referencedTable:
                        $$AiMessagesTableReferences._conversationIdTable(db),
                    referencedColumn:
                        $$AiMessagesTableReferences._conversationIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AiMessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AiMessagesTable,
    AiMessageRow,
    $$AiMessagesTableFilterComposer,
    $$AiMessagesTableOrderingComposer,
    $$AiMessagesTableAnnotationComposer,
    $$AiMessagesTableCreateCompanionBuilder,
    $$AiMessagesTableUpdateCompanionBuilder,
    (AiMessageRow, $$AiMessagesTableReferences),
    AiMessageRow,
    PrefetchHooks Function({bool conversationId})>;
typedef $$UtterancesTableCreateCompanionBuilder = UtterancesCompanion Function({
  Value<int> id,
  required DateTime at,
  required String body,
  required UtteranceSource source,
  Value<String?> language,
  Value<double?> confidence,
});
typedef $$UtterancesTableUpdateCompanionBuilder = UtterancesCompanion Function({
  Value<int> id,
  Value<DateTime> at,
  Value<String> body,
  Value<UtteranceSource> source,
  Value<String?> language,
  Value<double?> confidence,
});

final class $$UtterancesTableReferences
    extends BaseReferences<_$AppDatabase, $UtterancesTable, UtteranceRow> {
  $$UtterancesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AssistantActionsTable, List<AssistantActionRow>>
      _assistantActionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.assistantActions,
              aliasName: 'utterances__id__assistant_actions__utterance_id');

  $$AssistantActionsTableProcessedTableManager get assistantActionsRefs {
    final manager = $$AssistantActionsTableTableManager(
            $_db, $_db.assistantActions)
        .filter((f) => f.utteranceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_assistantActionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UtterancesTableFilterComposer
    extends Composer<_$AppDatabase, $UtterancesTable> {
  $$UtterancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get at => $composableBuilder(
      column: $table.at, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<UtteranceSource, UtteranceSource, int>
      get source => $composableBuilder(
          column: $table.source,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  Expression<bool> assistantActionsRefs(
      Expression<bool> Function($$AssistantActionsTableFilterComposer f) f) {
    final $$AssistantActionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.assistantActions,
        getReferencedColumn: (t) => t.utteranceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssistantActionsTableFilterComposer(
              $db: $db,
              $table: $db.assistantActions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UtterancesTableOrderingComposer
    extends Composer<_$AppDatabase, $UtterancesTable> {
  $$UtterancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get at => $composableBuilder(
      column: $table.at, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));
}

class $$UtterancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UtterancesTable> {
  $$UtterancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumnWithTypeConverter<UtteranceSource, int> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  Expression<T> assistantActionsRefs<T extends Object>(
      Expression<T> Function($$AssistantActionsTableAnnotationComposer a) f) {
    final $$AssistantActionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.assistantActions,
        getReferencedColumn: (t) => t.utteranceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AssistantActionsTableAnnotationComposer(
              $db: $db,
              $table: $db.assistantActions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UtterancesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UtterancesTable,
    UtteranceRow,
    $$UtterancesTableFilterComposer,
    $$UtterancesTableOrderingComposer,
    $$UtterancesTableAnnotationComposer,
    $$UtterancesTableCreateCompanionBuilder,
    $$UtterancesTableUpdateCompanionBuilder,
    (UtteranceRow, $$UtterancesTableReferences),
    UtteranceRow,
    PrefetchHooks Function({bool assistantActionsRefs})> {
  $$UtterancesTableTableManager(_$AppDatabase db, $UtterancesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UtterancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UtterancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UtterancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> at = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<UtteranceSource> source = const Value.absent(),
            Value<String?> language = const Value.absent(),
            Value<double?> confidence = const Value.absent(),
          }) =>
              UtterancesCompanion(
            id: id,
            at: at,
            body: body,
            source: source,
            language: language,
            confidence: confidence,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime at,
            required String body,
            required UtteranceSource source,
            Value<String?> language = const Value.absent(),
            Value<double?> confidence = const Value.absent(),
          }) =>
              UtterancesCompanion.insert(
            id: id,
            at: at,
            body: body,
            source: source,
            language: language,
            confidence: confidence,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$UtterancesTable, UtteranceRow>(table),
                    $$UtterancesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({assistantActionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (assistantActionsRefs) db.assistantActions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (assistantActionsRefs)
                    await $_getPrefetchedData<UtteranceRow, $UtterancesTable,
                            AssistantActionRow>(
                        currentTable: table,
                        referencedTable: $$UtterancesTableReferences
                            ._assistantActionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UtterancesTableReferences(db, table, p0)
                                .assistantActionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.utteranceId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UtterancesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UtterancesTable,
    UtteranceRow,
    $$UtterancesTableFilterComposer,
    $$UtterancesTableOrderingComposer,
    $$UtterancesTableAnnotationComposer,
    $$UtterancesTableCreateCompanionBuilder,
    $$UtterancesTableUpdateCompanionBuilder,
    (UtteranceRow, $$UtterancesTableReferences),
    UtteranceRow,
    PrefetchHooks Function({bool assistantActionsRefs})>;
typedef $$AssistantActionsTableCreateCompanionBuilder
    = AssistantActionsCompanion Function({
  Value<int> id,
  required DateTime at,
  required String groupId,
  required String toolName,
  required String argsJson,
  required ActionOrigin origin,
  required Decision decision,
  required LedgerStatus status,
  Value<String?> undoJson,
  Value<String?> previewJson,
  Value<int?> utteranceId,
});
typedef $$AssistantActionsTableUpdateCompanionBuilder
    = AssistantActionsCompanion Function({
  Value<int> id,
  Value<DateTime> at,
  Value<String> groupId,
  Value<String> toolName,
  Value<String> argsJson,
  Value<ActionOrigin> origin,
  Value<Decision> decision,
  Value<LedgerStatus> status,
  Value<String?> undoJson,
  Value<String?> previewJson,
  Value<int?> utteranceId,
});

final class $$AssistantActionsTableReferences extends BaseReferences<
    _$AppDatabase, $AssistantActionsTable, AssistantActionRow> {
  $$AssistantActionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $UtterancesTable _utteranceIdTable(_$AppDatabase db) => db.utterances
      .createAlias('assistant_actions__utterance_id__utterances__id');

  $$UtterancesTableProcessedTableManager? get utteranceId {
    final $_column = $_itemColumn<int>('utterance_id');
    if ($_column == null) return null;
    final manager = $$UtterancesTableTableManager($_db, $_db.utterances)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_utteranceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AssistantActionsTableFilterComposer
    extends Composer<_$AppDatabase, $AssistantActionsTable> {
  $$AssistantActionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get at => $composableBuilder(
      column: $table.at, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toolName => $composableBuilder(
      column: $table.toolName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get argsJson => $composableBuilder(
      column: $table.argsJson, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ActionOrigin, ActionOrigin, int> get origin =>
      $composableBuilder(
          column: $table.origin,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Decision, Decision, int> get decision =>
      $composableBuilder(
          column: $table.decision,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<LedgerStatus, LedgerStatus, int> get status =>
      $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get undoJson => $composableBuilder(
      column: $table.undoJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get previewJson => $composableBuilder(
      column: $table.previewJson, builder: (column) => ColumnFilters(column));

  $$UtterancesTableFilterComposer get utteranceId {
    final $$UtterancesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.utteranceId,
        referencedTable: $db.utterances,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UtterancesTableFilterComposer(
              $db: $db,
              $table: $db.utterances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AssistantActionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssistantActionsTable> {
  $$AssistantActionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get at => $composableBuilder(
      column: $table.at, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toolName => $composableBuilder(
      column: $table.toolName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get argsJson => $composableBuilder(
      column: $table.argsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get origin => $composableBuilder(
      column: $table.origin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get decision => $composableBuilder(
      column: $table.decision, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get undoJson => $composableBuilder(
      column: $table.undoJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get previewJson => $composableBuilder(
      column: $table.previewJson, builder: (column) => ColumnOrderings(column));

  $$UtterancesTableOrderingComposer get utteranceId {
    final $$UtterancesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.utteranceId,
        referencedTable: $db.utterances,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UtterancesTableOrderingComposer(
              $db: $db,
              $table: $db.utterances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AssistantActionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssistantActionsTable> {
  $$AssistantActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get toolName =>
      $composableBuilder(column: $table.toolName, builder: (column) => column);

  GeneratedColumn<String> get argsJson =>
      $composableBuilder(column: $table.argsJson, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActionOrigin, int> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decision, int> get decision =>
      $composableBuilder(column: $table.decision, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LedgerStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get undoJson =>
      $composableBuilder(column: $table.undoJson, builder: (column) => column);

  GeneratedColumn<String> get previewJson => $composableBuilder(
      column: $table.previewJson, builder: (column) => column);

  $$UtterancesTableAnnotationComposer get utteranceId {
    final $$UtterancesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.utteranceId,
        referencedTable: $db.utterances,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UtterancesTableAnnotationComposer(
              $db: $db,
              $table: $db.utterances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AssistantActionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AssistantActionsTable,
    AssistantActionRow,
    $$AssistantActionsTableFilterComposer,
    $$AssistantActionsTableOrderingComposer,
    $$AssistantActionsTableAnnotationComposer,
    $$AssistantActionsTableCreateCompanionBuilder,
    $$AssistantActionsTableUpdateCompanionBuilder,
    (AssistantActionRow, $$AssistantActionsTableReferences),
    AssistantActionRow,
    PrefetchHooks Function({bool utteranceId})> {
  $$AssistantActionsTableTableManager(
      _$AppDatabase db, $AssistantActionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssistantActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssistantActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssistantActionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> at = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String> toolName = const Value.absent(),
            Value<String> argsJson = const Value.absent(),
            Value<ActionOrigin> origin = const Value.absent(),
            Value<Decision> decision = const Value.absent(),
            Value<LedgerStatus> status = const Value.absent(),
            Value<String?> undoJson = const Value.absent(),
            Value<String?> previewJson = const Value.absent(),
            Value<int?> utteranceId = const Value.absent(),
          }) =>
              AssistantActionsCompanion(
            id: id,
            at: at,
            groupId: groupId,
            toolName: toolName,
            argsJson: argsJson,
            origin: origin,
            decision: decision,
            status: status,
            undoJson: undoJson,
            previewJson: previewJson,
            utteranceId: utteranceId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime at,
            required String groupId,
            required String toolName,
            required String argsJson,
            required ActionOrigin origin,
            required Decision decision,
            required LedgerStatus status,
            Value<String?> undoJson = const Value.absent(),
            Value<String?> previewJson = const Value.absent(),
            Value<int?> utteranceId = const Value.absent(),
          }) =>
              AssistantActionsCompanion.insert(
            id: id,
            at: at,
            groupId: groupId,
            toolName: toolName,
            argsJson: argsJson,
            origin: origin,
            decision: decision,
            status: status,
            undoJson: undoJson,
            previewJson: previewJson,
            utteranceId: utteranceId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AssistantActionsTable, AssistantActionRow>(
                        table),
                    $$AssistantActionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({utteranceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (utteranceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.utteranceId,
                    referencedTable:
                        $$AssistantActionsTableReferences._utteranceIdTable(db),
                    referencedColumn: $$AssistantActionsTableReferences
                        ._utteranceIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AssistantActionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AssistantActionsTable,
    AssistantActionRow,
    $$AssistantActionsTableFilterComposer,
    $$AssistantActionsTableOrderingComposer,
    $$AssistantActionsTableAnnotationComposer,
    $$AssistantActionsTableCreateCompanionBuilder,
    $$AssistantActionsTableUpdateCompanionBuilder,
    (AssistantActionRow, $$AssistantActionsTableReferences),
    AssistantActionRow,
    PrefetchHooks Function({bool utteranceId})>;
typedef $$ProposalsTableCreateCompanionBuilder = ProposalsCompanion Function({
  Value<int> id,
  required DateTime createdAt,
  Value<DateTime?> expiresAt,
  required String toolName,
  required String argsJson,
  required ActionOrigin origin,
  required ProposalReason reason,
  Value<String> reasonJson,
  Value<String?> sourceText,
  required String dedupeKey,
  required ProposalStatus status,
});
typedef $$ProposalsTableUpdateCompanionBuilder = ProposalsCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<DateTime?> expiresAt,
  Value<String> toolName,
  Value<String> argsJson,
  Value<ActionOrigin> origin,
  Value<ProposalReason> reason,
  Value<String> reasonJson,
  Value<String?> sourceText,
  Value<String> dedupeKey,
  Value<ProposalStatus> status,
});

class $$ProposalsTableFilterComposer
    extends Composer<_$AppDatabase, $ProposalsTable> {
  $$ProposalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toolName => $composableBuilder(
      column: $table.toolName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get argsJson => $composableBuilder(
      column: $table.argsJson, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ActionOrigin, ActionOrigin, int> get origin =>
      $composableBuilder(
          column: $table.origin,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<ProposalReason, ProposalReason, int>
      get reason => $composableBuilder(
          column: $table.reason,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get reasonJson => $composableBuilder(
      column: $table.reasonJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceText => $composableBuilder(
      column: $table.sourceText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dedupeKey => $composableBuilder(
      column: $table.dedupeKey, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ProposalStatus, ProposalStatus, int>
      get status => $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$ProposalsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProposalsTable> {
  $$ProposalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toolName => $composableBuilder(
      column: $table.toolName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get argsJson => $composableBuilder(
      column: $table.argsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get origin => $composableBuilder(
      column: $table.origin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reasonJson => $composableBuilder(
      column: $table.reasonJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceText => $composableBuilder(
      column: $table.sourceText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dedupeKey => $composableBuilder(
      column: $table.dedupeKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$ProposalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProposalsTable> {
  $$ProposalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get toolName =>
      $composableBuilder(column: $table.toolName, builder: (column) => column);

  GeneratedColumn<String> get argsJson =>
      $composableBuilder(column: $table.argsJson, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActionOrigin, int> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ProposalReason, int> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get reasonJson => $composableBuilder(
      column: $table.reasonJson, builder: (column) => column);

  GeneratedColumn<String> get sourceText => $composableBuilder(
      column: $table.sourceText, builder: (column) => column);

  GeneratedColumn<String> get dedupeKey =>
      $composableBuilder(column: $table.dedupeKey, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ProposalStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$ProposalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProposalsTable,
    ProposalRow,
    $$ProposalsTableFilterComposer,
    $$ProposalsTableOrderingComposer,
    $$ProposalsTableAnnotationComposer,
    $$ProposalsTableCreateCompanionBuilder,
    $$ProposalsTableUpdateCompanionBuilder,
    (ProposalRow, BaseReferences<_$AppDatabase, $ProposalsTable, ProposalRow>),
    ProposalRow,
    PrefetchHooks Function()> {
  $$ProposalsTableTableManager(_$AppDatabase db, $ProposalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProposalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProposalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProposalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> expiresAt = const Value.absent(),
            Value<String> toolName = const Value.absent(),
            Value<String> argsJson = const Value.absent(),
            Value<ActionOrigin> origin = const Value.absent(),
            Value<ProposalReason> reason = const Value.absent(),
            Value<String> reasonJson = const Value.absent(),
            Value<String?> sourceText = const Value.absent(),
            Value<String> dedupeKey = const Value.absent(),
            Value<ProposalStatus> status = const Value.absent(),
          }) =>
              ProposalsCompanion(
            id: id,
            createdAt: createdAt,
            expiresAt: expiresAt,
            toolName: toolName,
            argsJson: argsJson,
            origin: origin,
            reason: reason,
            reasonJson: reasonJson,
            sourceText: sourceText,
            dedupeKey: dedupeKey,
            status: status,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> expiresAt = const Value.absent(),
            required String toolName,
            required String argsJson,
            required ActionOrigin origin,
            required ProposalReason reason,
            Value<String> reasonJson = const Value.absent(),
            Value<String?> sourceText = const Value.absent(),
            required String dedupeKey,
            required ProposalStatus status,
          }) =>
              ProposalsCompanion.insert(
            id: id,
            createdAt: createdAt,
            expiresAt: expiresAt,
            toolName: toolName,
            argsJson: argsJson,
            origin: origin,
            reason: reason,
            reasonJson: reasonJson,
            sourceText: sourceText,
            dedupeKey: dedupeKey,
            status: status,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ProposalsTable, ProposalRow>(table),
                    BaseReferences<_$AppDatabase, $ProposalsTable, ProposalRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProposalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProposalsTable,
    ProposalRow,
    $$ProposalsTableFilterComposer,
    $$ProposalsTableOrderingComposer,
    $$ProposalsTableAnnotationComposer,
    $$ProposalsTableCreateCompanionBuilder,
    $$ProposalsTableUpdateCompanionBuilder,
    (ProposalRow, BaseReferences<_$AppDatabase, $ProposalsTable, ProposalRow>),
    ProposalRow,
    PrefetchHooks Function()>;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  required String title,
  required DateTime fireAt,
  required ReminderKind kind,
  required ReminderStatus status,
  Value<int> snoozeCount,
  Value<int?> taskId,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<DateTime> fireAt,
  Value<ReminderKind> kind,
  Value<ReminderStatus> status,
  Value<int> snoozeCount,
  Value<int?> taskId,
});

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, ReminderRow> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('reminders__task_id__tasks__id');

  $$TasksTableProcessedTableManager? get taskId {
    final $_column = $_itemColumn<int>('task_id');
    if ($_column == null) return null;
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fireAt => $composableBuilder(
      column: $table.fireAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ReminderKind, ReminderKind, int> get kind =>
      $composableBuilder(
          column: $table.kind,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<ReminderStatus, ReminderStatus, int>
      get status => $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get snoozeCount => $composableBuilder(
      column: $table.snoozeCount, builder: (column) => ColumnFilters(column));

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fireAt => $composableBuilder(
      column: $table.fireAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get snoozeCount => $composableBuilder(
      column: $table.snoozeCount, builder: (column) => ColumnOrderings(column));

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get fireAt =>
      $composableBuilder(column: $table.fireAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReminderKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReminderStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get snoozeCount => $composableBuilder(
      column: $table.snoozeCount, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RemindersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RemindersTable,
    ReminderRow,
    $$RemindersTableFilterComposer,
    $$RemindersTableOrderingComposer,
    $$RemindersTableAnnotationComposer,
    $$RemindersTableCreateCompanionBuilder,
    $$RemindersTableUpdateCompanionBuilder,
    (ReminderRow, $$RemindersTableReferences),
    ReminderRow,
    PrefetchHooks Function({bool taskId})> {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<DateTime> fireAt = const Value.absent(),
            Value<ReminderKind> kind = const Value.absent(),
            Value<ReminderStatus> status = const Value.absent(),
            Value<int> snoozeCount = const Value.absent(),
            Value<int?> taskId = const Value.absent(),
          }) =>
              RemindersCompanion(
            id: id,
            title: title,
            fireAt: fireAt,
            kind: kind,
            status: status,
            snoozeCount: snoozeCount,
            taskId: taskId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required DateTime fireAt,
            required ReminderKind kind,
            required ReminderStatus status,
            Value<int> snoozeCount = const Value.absent(),
            Value<int?> taskId = const Value.absent(),
          }) =>
              RemindersCompanion.insert(
            id: id,
            title: title,
            fireAt: fireAt,
            kind: kind,
            status: status,
            snoozeCount: snoozeCount,
            taskId: taskId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$RemindersTable, ReminderRow>(table),
                    $$RemindersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable:
                        $$RemindersTableReferences._taskIdTable(db),
                    referencedColumn:
                        $$RemindersTableReferences._taskIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RemindersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RemindersTable,
    ReminderRow,
    $$RemindersTableFilterComposer,
    $$RemindersTableOrderingComposer,
    $$RemindersTableAnnotationComposer,
    $$RemindersTableCreateCompanionBuilder,
    $$RemindersTableUpdateCompanionBuilder,
    (ReminderRow, $$RemindersTableReferences),
    ReminderRow,
    PrefetchHooks Function({bool taskId})>;
typedef $$ListsTableCreateCompanionBuilder = ListsCompanion Function({
  Value<int> id,
  required String name,
  required ListKind kind,
  Value<bool> archived,
});
typedef $$ListsTableUpdateCompanionBuilder = ListsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<ListKind> kind,
  Value<bool> archived,
});

final class $$ListsTableReferences
    extends BaseReferences<_$AppDatabase, $ListsTable, ListRow> {
  $$ListsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ListItemsTable, List<ListItemRow>>
      _listItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.listItems,
              aliasName: 'lists__id__list_items__list_id');

  $$ListItemsTableProcessedTableManager get listItemsRefs {
    final manager = $$ListItemsTableTableManager($_db, $_db.listItems)
        .filter((f) => f.listId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_listItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ListsTableFilterComposer extends Composer<_$AppDatabase, $ListsTable> {
  $$ListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ListKind, ListKind, int> get kind =>
      $composableBuilder(
          column: $table.kind,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get archived => $composableBuilder(
      column: $table.archived, builder: (column) => ColumnFilters(column));

  Expression<bool> listItemsRefs(
      Expression<bool> Function($$ListItemsTableFilterComposer f) f) {
    final $$ListItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.listItems,
        getReferencedColumn: (t) => t.listId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ListItemsTableFilterComposer(
              $db: $db,
              $table: $db.listItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ListsTableOrderingComposer
    extends Composer<_$AppDatabase, $ListsTable> {
  $$ListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get archived => $composableBuilder(
      column: $table.archived, builder: (column) => ColumnOrderings(column));
}

class $$ListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListsTable> {
  $$ListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ListKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  Expression<T> listItemsRefs<T extends Object>(
      Expression<T> Function($$ListItemsTableAnnotationComposer a) f) {
    final $$ListItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.listItems,
        getReferencedColumn: (t) => t.listId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ListItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.listItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ListsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ListsTable,
    ListRow,
    $$ListsTableFilterComposer,
    $$ListsTableOrderingComposer,
    $$ListsTableAnnotationComposer,
    $$ListsTableCreateCompanionBuilder,
    $$ListsTableUpdateCompanionBuilder,
    (ListRow, $$ListsTableReferences),
    ListRow,
    PrefetchHooks Function({bool listItemsRefs})> {
  $$ListsTableTableManager(_$AppDatabase db, $ListsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<ListKind> kind = const Value.absent(),
            Value<bool> archived = const Value.absent(),
          }) =>
              ListsCompanion(
            id: id,
            name: name,
            kind: kind,
            archived: archived,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required ListKind kind,
            Value<bool> archived = const Value.absent(),
          }) =>
              ListsCompanion.insert(
            id: id,
            name: name,
            kind: kind,
            archived: archived,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ListsTable, ListRow>(table),
                    $$ListsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({listItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (listItemsRefs) db.listItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (listItemsRefs)
                    await $_getPrefetchedData<ListRow, $ListsTable,
                            ListItemRow>(
                        currentTable: table,
                        referencedTable:
                            $$ListsTableReferences._listItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ListsTableReferences(db, table, p0).listItemsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.listId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ListsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ListsTable,
    ListRow,
    $$ListsTableFilterComposer,
    $$ListsTableOrderingComposer,
    $$ListsTableAnnotationComposer,
    $$ListsTableCreateCompanionBuilder,
    $$ListsTableUpdateCompanionBuilder,
    (ListRow, $$ListsTableReferences),
    ListRow,
    PrefetchHooks Function({bool listItemsRefs})>;
typedef $$ListItemsTableCreateCompanionBuilder = ListItemsCompanion Function({
  Value<int> id,
  required int listId,
  required String body,
  Value<bool> checked,
  required int position,
  required DateTime addedAt,
  Value<DateTime?> checkedAt,
});
typedef $$ListItemsTableUpdateCompanionBuilder = ListItemsCompanion Function({
  Value<int> id,
  Value<int> listId,
  Value<String> body,
  Value<bool> checked,
  Value<int> position,
  Value<DateTime> addedAt,
  Value<DateTime?> checkedAt,
});

final class $$ListItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ListItemsTable, ListItemRow> {
  $$ListItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ListsTable _listIdTable(_$AppDatabase db) =>
      db.lists.createAlias('list_items__list_id__lists__id');

  $$ListsTableProcessedTableManager get listId {
    final $_column = $_itemColumn<int>('list_id')!;

    final manager = $$ListsTableTableManager($_db, $_db.lists)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_listIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ListItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ListItemsTable> {
  $$ListItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get checked => $composableBuilder(
      column: $table.checked, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get checkedAt => $composableBuilder(
      column: $table.checkedAt, builder: (column) => ColumnFilters(column));

  $$ListsTableFilterComposer get listId {
    final $$ListsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.listId,
        referencedTable: $db.lists,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ListsTableFilterComposer(
              $db: $db,
              $table: $db.lists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ListItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ListItemsTable> {
  $$ListItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get checked => $composableBuilder(
      column: $table.checked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get checkedAt => $composableBuilder(
      column: $table.checkedAt, builder: (column) => ColumnOrderings(column));

  $$ListsTableOrderingComposer get listId {
    final $$ListsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.listId,
        referencedTable: $db.lists,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ListsTableOrderingComposer(
              $db: $db,
              $table: $db.lists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ListItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListItemsTable> {
  $$ListItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<bool> get checked =>
      $composableBuilder(column: $table.checked, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get checkedAt =>
      $composableBuilder(column: $table.checkedAt, builder: (column) => column);

  $$ListsTableAnnotationComposer get listId {
    final $$ListsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.listId,
        referencedTable: $db.lists,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ListsTableAnnotationComposer(
              $db: $db,
              $table: $db.lists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ListItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ListItemsTable,
    ListItemRow,
    $$ListItemsTableFilterComposer,
    $$ListItemsTableOrderingComposer,
    $$ListItemsTableAnnotationComposer,
    $$ListItemsTableCreateCompanionBuilder,
    $$ListItemsTableUpdateCompanionBuilder,
    (ListItemRow, $$ListItemsTableReferences),
    ListItemRow,
    PrefetchHooks Function({bool listId})> {
  $$ListItemsTableTableManager(_$AppDatabase db, $ListItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> listId = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<bool> checked = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
            Value<DateTime?> checkedAt = const Value.absent(),
          }) =>
              ListItemsCompanion(
            id: id,
            listId: listId,
            body: body,
            checked: checked,
            position: position,
            addedAt: addedAt,
            checkedAt: checkedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int listId,
            required String body,
            Value<bool> checked = const Value.absent(),
            required int position,
            required DateTime addedAt,
            Value<DateTime?> checkedAt = const Value.absent(),
          }) =>
              ListItemsCompanion.insert(
            id: id,
            listId: listId,
            body: body,
            checked: checked,
            position: position,
            addedAt: addedAt,
            checkedAt: checkedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ListItemsTable, ListItemRow>(table),
                    $$ListItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({listId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (listId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.listId,
                    referencedTable:
                        $$ListItemsTableReferences._listIdTable(db),
                    referencedColumn:
                        $$ListItemsTableReferences._listIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ListItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ListItemsTable,
    ListItemRow,
    $$ListItemsTableFilterComposer,
    $$ListItemsTableOrderingComposer,
    $$ListItemsTableAnnotationComposer,
    $$ListItemsTableCreateCompanionBuilder,
    $$ListItemsTableUpdateCompanionBuilder,
    (ListItemRow, $$ListItemsTableReferences),
    ListItemRow,
    PrefetchHooks Function({bool listId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppSettingsEntriesTableTableManager get appSettingsEntries =>
      $$AppSettingsEntriesTableTableManager(_db, _db.appSettingsEntries);
  $$ScheduleBlocksTableTableManager get scheduleBlocks =>
      $$ScheduleBlocksTableTableManager(_db, _db.scheduleBlocks);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$SubtasksTableTableManager get subtasks =>
      $$SubtasksTableTableManager(_db, _db.subtasks);
  $$ScheduleBlockExceptionsTableTableManager get scheduleBlockExceptions =>
      $$ScheduleBlockExceptionsTableTableManager(
          _db, _db.scheduleBlockExceptions);
  $$FocusSessionsTableTableManager get focusSessions =>
      $$FocusSessionsTableTableManager(_db, _db.focusSessions);
  $$AiProviderConfigsTableTableManager get aiProviderConfigs =>
      $$AiProviderConfigsTableTableManager(_db, _db.aiProviderConfigs);
  $$AiConversationsTableTableManager get aiConversations =>
      $$AiConversationsTableTableManager(_db, _db.aiConversations);
  $$AiMessagesTableTableManager get aiMessages =>
      $$AiMessagesTableTableManager(_db, _db.aiMessages);
  $$UtterancesTableTableManager get utterances =>
      $$UtterancesTableTableManager(_db, _db.utterances);
  $$AssistantActionsTableTableManager get assistantActions =>
      $$AssistantActionsTableTableManager(_db, _db.assistantActions);
  $$ProposalsTableTableManager get proposals =>
      $$ProposalsTableTableManager(_db, _db.proposals);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$ListsTableTableManager get lists =>
      $$ListsTableTableManager(_db, _db.lists);
  $$ListItemsTableTableManager get listItems =>
      $$ListItemsTableTableManager(_db, _db.listItems);
}
