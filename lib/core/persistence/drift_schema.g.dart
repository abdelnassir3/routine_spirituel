// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_schema.dart';

// ignore_for_file: type=lint
class $ThemesTable extends Themes with TableInfo<$ThemesTable, ThemeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThemesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameFrMeta = const VerificationMeta('nameFr');
  @override
  late final GeneratedColumn<String> nameFr = GeneratedColumn<String>(
      'name_fr', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameArMeta = const VerificationMeta('nameAr');
  @override
  late final GeneratedColumn<String> nameAr = GeneratedColumn<String>(
      'name_ar', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
      'frequency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, nameFr, nameAr, frequency, createdAt, metadata];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'themes';
  @override
  VerificationContext validateIntegrity(Insertable<ThemeRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name_fr')) {
      context.handle(_nameFrMeta,
          nameFr.isAcceptableOrUnknown(data['name_fr']!, _nameFrMeta));
    } else if (isInserting) {
      context.missing(_nameFrMeta);
    }
    if (data.containsKey('name_ar')) {
      context.handle(_nameArMeta,
          nameAr.isAcceptableOrUnknown(data['name_ar']!, _nameArMeta));
    } else if (isInserting) {
      context.missing(_nameArMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(_frequencyMeta,
          frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta));
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ThemeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThemeRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      nameFr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_fr'])!,
      nameAr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_ar'])!,
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}frequency'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata'])!,
    );
  }

  @override
  $ThemesTable createAlias(String alias) {
    return $ThemesTable(attachedDatabase, alias);
  }
}

class ThemeRow extends DataClass implements Insertable<ThemeRow> {
  final String id;
  final String nameFr;
  final String nameAr;
  final String frequency;
  final DateTime createdAt;
  final String metadata;
  const ThemeRow(
      {required this.id,
      required this.nameFr,
      required this.nameAr,
      required this.frequency,
      required this.createdAt,
      required this.metadata});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name_fr'] = Variable<String>(nameFr);
    map['name_ar'] = Variable<String>(nameAr);
    map['frequency'] = Variable<String>(frequency);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['metadata'] = Variable<String>(metadata);
    return map;
  }

  ThemesCompanion toCompanion(bool nullToAbsent) {
    return ThemesCompanion(
      id: Value(id),
      nameFr: Value(nameFr),
      nameAr: Value(nameAr),
      frequency: Value(frequency),
      createdAt: Value(createdAt),
      metadata: Value(metadata),
    );
  }

  factory ThemeRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThemeRow(
      id: serializer.fromJson<String>(json['id']),
      nameFr: serializer.fromJson<String>(json['nameFr']),
      nameAr: serializer.fromJson<String>(json['nameAr']),
      frequency: serializer.fromJson<String>(json['frequency']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      metadata: serializer.fromJson<String>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nameFr': serializer.toJson<String>(nameFr),
      'nameAr': serializer.toJson<String>(nameAr),
      'frequency': serializer.toJson<String>(frequency),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'metadata': serializer.toJson<String>(metadata),
    };
  }

  ThemeRow copyWith(
          {String? id,
          String? nameFr,
          String? nameAr,
          String? frequency,
          DateTime? createdAt,
          String? metadata}) =>
      ThemeRow(
        id: id ?? this.id,
        nameFr: nameFr ?? this.nameFr,
        nameAr: nameAr ?? this.nameAr,
        frequency: frequency ?? this.frequency,
        createdAt: createdAt ?? this.createdAt,
        metadata: metadata ?? this.metadata,
      );
  ThemeRow copyWithCompanion(ThemesCompanion data) {
    return ThemeRow(
      id: data.id.present ? data.id.value : this.id,
      nameFr: data.nameFr.present ? data.nameFr.value : this.nameFr,
      nameAr: data.nameAr.present ? data.nameAr.value : this.nameAr,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThemeRow(')
          ..write('id: $id, ')
          ..write('nameFr: $nameFr, ')
          ..write('nameAr: $nameAr, ')
          ..write('frequency: $frequency, ')
          ..write('createdAt: $createdAt, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nameFr, nameAr, frequency, createdAt, metadata);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThemeRow &&
          other.id == this.id &&
          other.nameFr == this.nameFr &&
          other.nameAr == this.nameAr &&
          other.frequency == this.frequency &&
          other.createdAt == this.createdAt &&
          other.metadata == this.metadata);
}

class ThemesCompanion extends UpdateCompanion<ThemeRow> {
  final Value<String> id;
  final Value<String> nameFr;
  final Value<String> nameAr;
  final Value<String> frequency;
  final Value<DateTime> createdAt;
  final Value<String> metadata;
  final Value<int> rowid;
  const ThemesCompanion({
    this.id = const Value.absent(),
    this.nameFr = const Value.absent(),
    this.nameAr = const Value.absent(),
    this.frequency = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ThemesCompanion.insert({
    required String id,
    required String nameFr,
    required String nameAr,
    required String frequency,
    this.createdAt = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        nameFr = Value(nameFr),
        nameAr = Value(nameAr),
        frequency = Value(frequency);
  static Insertable<ThemeRow> custom({
    Expression<String>? id,
    Expression<String>? nameFr,
    Expression<String>? nameAr,
    Expression<String>? frequency,
    Expression<DateTime>? createdAt,
    Expression<String>? metadata,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameFr != null) 'name_fr': nameFr,
      if (nameAr != null) 'name_ar': nameAr,
      if (frequency != null) 'frequency': frequency,
      if (createdAt != null) 'created_at': createdAt,
      if (metadata != null) 'metadata': metadata,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ThemesCompanion copyWith(
      {Value<String>? id,
      Value<String>? nameFr,
      Value<String>? nameAr,
      Value<String>? frequency,
      Value<DateTime>? createdAt,
      Value<String>? metadata,
      Value<int>? rowid}) {
    return ThemesCompanion(
      id: id ?? this.id,
      nameFr: nameFr ?? this.nameFr,
      nameAr: nameAr ?? this.nameAr,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nameFr.present) {
      map['name_fr'] = Variable<String>(nameFr.value);
    }
    if (nameAr.present) {
      map['name_ar'] = Variable<String>(nameAr.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThemesCompanion(')
          ..write('id: $id, ')
          ..write('nameFr: $nameFr, ')
          ..write('nameAr: $nameAr, ')
          ..write('frequency: $frequency, ')
          ..write('createdAt: $createdAt, ')
          ..write('metadata: $metadata, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutinesTable extends Routines
    with TableInfo<$RoutinesTable, RoutineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _themeIdMeta =
      const VerificationMeta('themeId');
  @override
  late final GeneratedColumn<String> themeId = GeneratedColumn<String>(
      'theme_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES themes (id)'));
  static const VerificationMeta _nameFrMeta = const VerificationMeta('nameFr');
  @override
  late final GeneratedColumn<String> nameFr = GeneratedColumn<String>(
      'name_fr', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameArMeta = const VerificationMeta('nameAr');
  @override
  late final GeneratedColumn<String> nameAr = GeneratedColumn<String>(
      'name_ar', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [id, themeId, nameFr, nameAr, orderIndex, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routines';
  @override
  VerificationContext validateIntegrity(Insertable<RoutineRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('theme_id')) {
      context.handle(_themeIdMeta,
          themeId.isAcceptableOrUnknown(data['theme_id']!, _themeIdMeta));
    } else if (isInserting) {
      context.missing(_themeIdMeta);
    }
    if (data.containsKey('name_fr')) {
      context.handle(_nameFrMeta,
          nameFr.isAcceptableOrUnknown(data['name_fr']!, _nameFrMeta));
    } else if (isInserting) {
      context.missing(_nameFrMeta);
    }
    if (data.containsKey('name_ar')) {
      context.handle(_nameArMeta,
          nameAr.isAcceptableOrUnknown(data['name_ar']!, _nameArMeta));
    } else if (isInserting) {
      context.missing(_nameArMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      themeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme_id'])!,
      nameFr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_fr'])!,
      nameAr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_ar'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $RoutinesTable createAlias(String alias) {
    return $RoutinesTable(attachedDatabase, alias);
  }
}

class RoutineRow extends DataClass implements Insertable<RoutineRow> {
  final String id;
  final String themeId;
  final String nameFr;
  final String nameAr;
  final int orderIndex;
  final bool isActive;
  const RoutineRow(
      {required this.id,
      required this.themeId,
      required this.nameFr,
      required this.nameAr,
      required this.orderIndex,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['theme_id'] = Variable<String>(themeId);
    map['name_fr'] = Variable<String>(nameFr);
    map['name_ar'] = Variable<String>(nameAr);
    map['order_index'] = Variable<int>(orderIndex);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  RoutinesCompanion toCompanion(bool nullToAbsent) {
    return RoutinesCompanion(
      id: Value(id),
      themeId: Value(themeId),
      nameFr: Value(nameFr),
      nameAr: Value(nameAr),
      orderIndex: Value(orderIndex),
      isActive: Value(isActive),
    );
  }

  factory RoutineRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineRow(
      id: serializer.fromJson<String>(json['id']),
      themeId: serializer.fromJson<String>(json['themeId']),
      nameFr: serializer.fromJson<String>(json['nameFr']),
      nameAr: serializer.fromJson<String>(json['nameAr']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'themeId': serializer.toJson<String>(themeId),
      'nameFr': serializer.toJson<String>(nameFr),
      'nameAr': serializer.toJson<String>(nameAr),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  RoutineRow copyWith(
          {String? id,
          String? themeId,
          String? nameFr,
          String? nameAr,
          int? orderIndex,
          bool? isActive}) =>
      RoutineRow(
        id: id ?? this.id,
        themeId: themeId ?? this.themeId,
        nameFr: nameFr ?? this.nameFr,
        nameAr: nameAr ?? this.nameAr,
        orderIndex: orderIndex ?? this.orderIndex,
        isActive: isActive ?? this.isActive,
      );
  RoutineRow copyWithCompanion(RoutinesCompanion data) {
    return RoutineRow(
      id: data.id.present ? data.id.value : this.id,
      themeId: data.themeId.present ? data.themeId.value : this.themeId,
      nameFr: data.nameFr.present ? data.nameFr.value : this.nameFr,
      nameAr: data.nameAr.present ? data.nameAr.value : this.nameAr,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineRow(')
          ..write('id: $id, ')
          ..write('themeId: $themeId, ')
          ..write('nameFr: $nameFr, ')
          ..write('nameAr: $nameAr, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, themeId, nameFr, nameAr, orderIndex, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineRow &&
          other.id == this.id &&
          other.themeId == this.themeId &&
          other.nameFr == this.nameFr &&
          other.nameAr == this.nameAr &&
          other.orderIndex == this.orderIndex &&
          other.isActive == this.isActive);
}

class RoutinesCompanion extends UpdateCompanion<RoutineRow> {
  final Value<String> id;
  final Value<String> themeId;
  final Value<String> nameFr;
  final Value<String> nameAr;
  final Value<int> orderIndex;
  final Value<bool> isActive;
  final Value<int> rowid;
  const RoutinesCompanion({
    this.id = const Value.absent(),
    this.themeId = const Value.absent(),
    this.nameFr = const Value.absent(),
    this.nameAr = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutinesCompanion.insert({
    required String id,
    required String themeId,
    required String nameFr,
    required String nameAr,
    this.orderIndex = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        themeId = Value(themeId),
        nameFr = Value(nameFr),
        nameAr = Value(nameAr);
  static Insertable<RoutineRow> custom({
    Expression<String>? id,
    Expression<String>? themeId,
    Expression<String>? nameFr,
    Expression<String>? nameAr,
    Expression<int>? orderIndex,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeId != null) 'theme_id': themeId,
      if (nameFr != null) 'name_fr': nameFr,
      if (nameAr != null) 'name_ar': nameAr,
      if (orderIndex != null) 'order_index': orderIndex,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutinesCompanion copyWith(
      {Value<String>? id,
      Value<String>? themeId,
      Value<String>? nameFr,
      Value<String>? nameAr,
      Value<int>? orderIndex,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return RoutinesCompanion(
      id: id ?? this.id,
      themeId: themeId ?? this.themeId,
      nameFr: nameFr ?? this.nameFr,
      nameAr: nameAr ?? this.nameAr,
      orderIndex: orderIndex ?? this.orderIndex,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (themeId.present) {
      map['theme_id'] = Variable<String>(themeId.value);
    }
    if (nameFr.present) {
      map['name_fr'] = Variable<String>(nameFr.value);
    }
    if (nameAr.present) {
      map['name_ar'] = Variable<String>(nameAr.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutinesCompanion(')
          ..write('id: $id, ')
          ..write('themeId: $themeId, ')
          ..write('nameFr: $nameFr, ')
          ..write('nameAr: $nameAr, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
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
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _routineIdMeta =
      const VerificationMeta('routineId');
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
      'routine_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES routines (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _defaultRepsMeta =
      const VerificationMeta('defaultReps');
  @override
  late final GeneratedColumn<int> defaultReps = GeneratedColumn<int>(
      'default_reps', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _audioSettingsMeta =
      const VerificationMeta('audioSettings');
  @override
  late final GeneratedColumn<String> audioSettings = GeneratedColumn<String>(
      'audio_settings', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _displaySettingsMeta =
      const VerificationMeta('displaySettings');
  @override
  late final GeneratedColumn<String> displaySettings = GeneratedColumn<String>(
      'display_settings', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _contentIdMeta =
      const VerificationMeta('contentId');
  @override
  late final GeneratedColumn<String> contentId = GeneratedColumn<String>(
      'content_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesFrMeta =
      const VerificationMeta('notesFr');
  @override
  late final GeneratedColumn<String> notesFr = GeneratedColumn<String>(
      'notes_fr', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesArMeta =
      const VerificationMeta('notesAr');
  @override
  late final GeneratedColumn<String> notesAr = GeneratedColumn<String>(
      'notes_ar', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        routineId,
        type,
        category,
        defaultReps,
        audioSettings,
        displaySettings,
        contentId,
        notesFr,
        notesAr,
        orderIndex
      ];
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
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('routine_id')) {
      context.handle(_routineIdMeta,
          routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta));
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('default_reps')) {
      context.handle(
          _defaultRepsMeta,
          defaultReps.isAcceptableOrUnknown(
              data['default_reps']!, _defaultRepsMeta));
    }
    if (data.containsKey('audio_settings')) {
      context.handle(
          _audioSettingsMeta,
          audioSettings.isAcceptableOrUnknown(
              data['audio_settings']!, _audioSettingsMeta));
    }
    if (data.containsKey('display_settings')) {
      context.handle(
          _displaySettingsMeta,
          displaySettings.isAcceptableOrUnknown(
              data['display_settings']!, _displaySettingsMeta));
    }
    if (data.containsKey('content_id')) {
      context.handle(_contentIdMeta,
          contentId.isAcceptableOrUnknown(data['content_id']!, _contentIdMeta));
    }
    if (data.containsKey('notes_fr')) {
      context.handle(_notesFrMeta,
          notesFr.isAcceptableOrUnknown(data['notes_fr']!, _notesFrMeta));
    }
    if (data.containsKey('notes_ar')) {
      context.handle(_notesArMeta,
          notesAr.isAcceptableOrUnknown(data['notes_ar']!, _notesArMeta));
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
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      routineId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}routine_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      defaultReps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}default_reps'])!,
      audioSettings: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audio_settings'])!,
      displaySettings: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}display_settings'])!,
      contentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content_id']),
      notesFr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes_fr']),
      notesAr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes_ar']),
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  final String id;
  final String routineId;
  final String type;
  final String category;
  final int defaultReps;
  final String audioSettings;
  final String displaySettings;
  final String? contentId;
  final String? notesFr;
  final String? notesAr;
  final int orderIndex;
  const TaskRow(
      {required this.id,
      required this.routineId,
      required this.type,
      required this.category,
      required this.defaultReps,
      required this.audioSettings,
      required this.displaySettings,
      this.contentId,
      this.notesFr,
      this.notesAr,
      required this.orderIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['routine_id'] = Variable<String>(routineId);
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    map['default_reps'] = Variable<int>(defaultReps);
    map['audio_settings'] = Variable<String>(audioSettings);
    map['display_settings'] = Variable<String>(displaySettings);
    if (!nullToAbsent || contentId != null) {
      map['content_id'] = Variable<String>(contentId);
    }
    if (!nullToAbsent || notesFr != null) {
      map['notes_fr'] = Variable<String>(notesFr);
    }
    if (!nullToAbsent || notesAr != null) {
      map['notes_ar'] = Variable<String>(notesAr);
    }
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      routineId: Value(routineId),
      type: Value(type),
      category: Value(category),
      defaultReps: Value(defaultReps),
      audioSettings: Value(audioSettings),
      displaySettings: Value(displaySettings),
      contentId: contentId == null && nullToAbsent
          ? const Value.absent()
          : Value(contentId),
      notesFr: notesFr == null && nullToAbsent
          ? const Value.absent()
          : Value(notesFr),
      notesAr: notesAr == null && nullToAbsent
          ? const Value.absent()
          : Value(notesAr),
      orderIndex: Value(orderIndex),
    );
  }

  factory TaskRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      id: serializer.fromJson<String>(json['id']),
      routineId: serializer.fromJson<String>(json['routineId']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      defaultReps: serializer.fromJson<int>(json['defaultReps']),
      audioSettings: serializer.fromJson<String>(json['audioSettings']),
      displaySettings: serializer.fromJson<String>(json['displaySettings']),
      contentId: serializer.fromJson<String?>(json['contentId']),
      notesFr: serializer.fromJson<String?>(json['notesFr']),
      notesAr: serializer.fromJson<String?>(json['notesAr']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'routineId': serializer.toJson<String>(routineId),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'defaultReps': serializer.toJson<int>(defaultReps),
      'audioSettings': serializer.toJson<String>(audioSettings),
      'displaySettings': serializer.toJson<String>(displaySettings),
      'contentId': serializer.toJson<String?>(contentId),
      'notesFr': serializer.toJson<String?>(notesFr),
      'notesAr': serializer.toJson<String?>(notesAr),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  TaskRow copyWith(
          {String? id,
          String? routineId,
          String? type,
          String? category,
          int? defaultReps,
          String? audioSettings,
          String? displaySettings,
          Value<String?> contentId = const Value.absent(),
          Value<String?> notesFr = const Value.absent(),
          Value<String?> notesAr = const Value.absent(),
          int? orderIndex}) =>
      TaskRow(
        id: id ?? this.id,
        routineId: routineId ?? this.routineId,
        type: type ?? this.type,
        category: category ?? this.category,
        defaultReps: defaultReps ?? this.defaultReps,
        audioSettings: audioSettings ?? this.audioSettings,
        displaySettings: displaySettings ?? this.displaySettings,
        contentId: contentId.present ? contentId.value : this.contentId,
        notesFr: notesFr.present ? notesFr.value : this.notesFr,
        notesAr: notesAr.present ? notesAr.value : this.notesAr,
        orderIndex: orderIndex ?? this.orderIndex,
      );
  TaskRow copyWithCompanion(TasksCompanion data) {
    return TaskRow(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      defaultReps:
          data.defaultReps.present ? data.defaultReps.value : this.defaultReps,
      audioSettings: data.audioSettings.present
          ? data.audioSettings.value
          : this.audioSettings,
      displaySettings: data.displaySettings.present
          ? data.displaySettings.value
          : this.displaySettings,
      contentId: data.contentId.present ? data.contentId.value : this.contentId,
      notesFr: data.notesFr.present ? data.notesFr.value : this.notesFr,
      notesAr: data.notesAr.present ? data.notesAr.value : this.notesAr,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('defaultReps: $defaultReps, ')
          ..write('audioSettings: $audioSettings, ')
          ..write('displaySettings: $displaySettings, ')
          ..write('contentId: $contentId, ')
          ..write('notesFr: $notesFr, ')
          ..write('notesAr: $notesAr, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, routineId, type, category, defaultReps,
      audioSettings, displaySettings, contentId, notesFr, notesAr, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.type == this.type &&
          other.category == this.category &&
          other.defaultReps == this.defaultReps &&
          other.audioSettings == this.audioSettings &&
          other.displaySettings == this.displaySettings &&
          other.contentId == this.contentId &&
          other.notesFr == this.notesFr &&
          other.notesAr == this.notesAr &&
          other.orderIndex == this.orderIndex);
}

class TasksCompanion extends UpdateCompanion<TaskRow> {
  final Value<String> id;
  final Value<String> routineId;
  final Value<String> type;
  final Value<String> category;
  final Value<int> defaultReps;
  final Value<String> audioSettings;
  final Value<String> displaySettings;
  final Value<String?> contentId;
  final Value<String?> notesFr;
  final Value<String?> notesAr;
  final Value<int> orderIndex;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.defaultReps = const Value.absent(),
    this.audioSettings = const Value.absent(),
    this.displaySettings = const Value.absent(),
    this.contentId = const Value.absent(),
    this.notesFr = const Value.absent(),
    this.notesAr = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String routineId,
    required String type,
    required String category,
    this.defaultReps = const Value.absent(),
    this.audioSettings = const Value.absent(),
    this.displaySettings = const Value.absent(),
    this.contentId = const Value.absent(),
    this.notesFr = const Value.absent(),
    this.notesAr = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        routineId = Value(routineId),
        type = Value(type),
        category = Value(category);
  static Insertable<TaskRow> custom({
    Expression<String>? id,
    Expression<String>? routineId,
    Expression<String>? type,
    Expression<String>? category,
    Expression<int>? defaultReps,
    Expression<String>? audioSettings,
    Expression<String>? displaySettings,
    Expression<String>? contentId,
    Expression<String>? notesFr,
    Expression<String>? notesAr,
    Expression<int>? orderIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (defaultReps != null) 'default_reps': defaultReps,
      if (audioSettings != null) 'audio_settings': audioSettings,
      if (displaySettings != null) 'display_settings': displaySettings,
      if (contentId != null) 'content_id': contentId,
      if (notesFr != null) 'notes_fr': notesFr,
      if (notesAr != null) 'notes_ar': notesAr,
      if (orderIndex != null) 'order_index': orderIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? routineId,
      Value<String>? type,
      Value<String>? category,
      Value<int>? defaultReps,
      Value<String>? audioSettings,
      Value<String>? displaySettings,
      Value<String?>? contentId,
      Value<String?>? notesFr,
      Value<String?>? notesAr,
      Value<int>? orderIndex,
      Value<int>? rowid}) {
    return TasksCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      type: type ?? this.type,
      category: category ?? this.category,
      defaultReps: defaultReps ?? this.defaultReps,
      audioSettings: audioSettings ?? this.audioSettings,
      displaySettings: displaySettings ?? this.displaySettings,
      contentId: contentId ?? this.contentId,
      notesFr: notesFr ?? this.notesFr,
      notesAr: notesAr ?? this.notesAr,
      orderIndex: orderIndex ?? this.orderIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (defaultReps.present) {
      map['default_reps'] = Variable<int>(defaultReps.value);
    }
    if (audioSettings.present) {
      map['audio_settings'] = Variable<String>(audioSettings.value);
    }
    if (displaySettings.present) {
      map['display_settings'] = Variable<String>(displaySettings.value);
    }
    if (contentId.present) {
      map['content_id'] = Variable<String>(contentId.value);
    }
    if (notesFr.present) {
      map['notes_fr'] = Variable<String>(notesFr.value);
    }
    if (notesAr.present) {
      map['notes_ar'] = Variable<String>(notesAr.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('defaultReps: $defaultReps, ')
          ..write('audioSettings: $audioSettings, ')
          ..write('displaySettings: $displaySettings, ')
          ..write('contentId: $contentId, ')
          ..write('notesFr: $notesFr, ')
          ..write('notesAr: $notesAr, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _routineIdMeta =
      const VerificationMeta('routineId');
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
      'routine_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES routines (id)'));
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _snapshotRefMeta =
      const VerificationMeta('snapshotRef');
  @override
  late final GeneratedColumn<String> snapshotRef = GeneratedColumn<String>(
      'snapshot_ref', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, routineId, startedAt, endedAt, state, snapshotRef];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(Insertable<SessionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('routine_id')) {
      context.handle(_routineIdMeta,
          routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta));
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    }
    if (data.containsKey('snapshot_ref')) {
      context.handle(
          _snapshotRefMeta,
          snapshotRef.isAcceptableOrUnknown(
              data['snapshot_ref']!, _snapshotRefMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      routineId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}routine_id'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ended_at']),
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!,
      snapshotRef: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}snapshot_ref']),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final String id;
  final String routineId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String state;
  final String? snapshotRef;
  const SessionRow(
      {required this.id,
      required this.routineId,
      required this.startedAt,
      this.endedAt,
      required this.state,
      this.snapshotRef});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['routine_id'] = Variable<String>(routineId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || snapshotRef != null) {
      map['snapshot_ref'] = Variable<String>(snapshotRef);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      routineId: Value(routineId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      state: Value(state),
      snapshotRef: snapshotRef == null && nullToAbsent
          ? const Value.absent()
          : Value(snapshotRef),
    );
  }

  factory SessionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<String>(json['id']),
      routineId: serializer.fromJson<String>(json['routineId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      state: serializer.fromJson<String>(json['state']),
      snapshotRef: serializer.fromJson<String?>(json['snapshotRef']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'routineId': serializer.toJson<String>(routineId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'state': serializer.toJson<String>(state),
      'snapshotRef': serializer.toJson<String?>(snapshotRef),
    };
  }

  SessionRow copyWith(
          {String? id,
          String? routineId,
          DateTime? startedAt,
          Value<DateTime?> endedAt = const Value.absent(),
          String? state,
          Value<String?> snapshotRef = const Value.absent()}) =>
      SessionRow(
        id: id ?? this.id,
        routineId: routineId ?? this.routineId,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
        state: state ?? this.state,
        snapshotRef: snapshotRef.present ? snapshotRef.value : this.snapshotRef,
      );
  SessionRow copyWithCompanion(SessionsCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      state: data.state.present ? data.state.value : this.state,
      snapshotRef:
          data.snapshotRef.present ? data.snapshotRef.value : this.snapshotRef,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('state: $state, ')
          ..write('snapshotRef: $snapshotRef')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, routineId, startedAt, endedAt, state, snapshotRef);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.state == this.state &&
          other.snapshotRef == this.snapshotRef);
}

class SessionsCompanion extends UpdateCompanion<SessionRow> {
  final Value<String> id;
  final Value<String> routineId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String> state;
  final Value<String?> snapshotRef;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.state = const Value.absent(),
    this.snapshotRef = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required String routineId,
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.state = const Value.absent(),
    this.snapshotRef = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        routineId = Value(routineId);
  static Insertable<SessionRow> custom({
    Expression<String>? id,
    Expression<String>? routineId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? state,
    Expression<String>? snapshotRef,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (state != null) 'state': state,
      if (snapshotRef != null) 'snapshot_ref': snapshotRef,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? routineId,
      Value<DateTime>? startedAt,
      Value<DateTime?>? endedAt,
      Value<String>? state,
      Value<String?>? snapshotRef,
      Value<int>? rowid}) {
    return SessionsCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      state: state ?? this.state,
      snapshotRef: snapshotRef ?? this.snapshotRef,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (snapshotRef.present) {
      map['snapshot_ref'] = Variable<String>(snapshotRef.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('state: $state, ')
          ..write('snapshotRef: $snapshotRef, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskProgressTable extends TaskProgress
    with TableInfo<$TaskProgressTable, TaskProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES sessions (id)'));
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tasks (id)'));
  static const VerificationMeta _remainingRepsMeta =
      const VerificationMeta('remainingReps');
  @override
  late final GeneratedColumn<int> remainingReps = GeneratedColumn<int>(
      'remaining_reps', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _elapsedMsMeta =
      const VerificationMeta('elapsedMs');
  @override
  late final GeneratedColumn<int> elapsedMs = GeneratedColumn<int>(
      'elapsed_ms', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _wordIndexMeta =
      const VerificationMeta('wordIndex');
  @override
  late final GeneratedColumn<int> wordIndex = GeneratedColumn<int>(
      'word_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _verseIndexMeta =
      const VerificationMeta('verseIndex');
  @override
  late final GeneratedColumn<int> verseIndex = GeneratedColumn<int>(
      'verse_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastUpdateMeta =
      const VerificationMeta('lastUpdate');
  @override
  late final GeneratedColumn<DateTime> lastUpdate = GeneratedColumn<DateTime>(
      'last_update', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        taskId,
        remainingReps,
        elapsedMs,
        wordIndex,
        verseIndex,
        lastUpdate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_progress';
  @override
  VerificationContext validateIntegrity(Insertable<TaskProgressRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('remaining_reps')) {
      context.handle(
          _remainingRepsMeta,
          remainingReps.isAcceptableOrUnknown(
              data['remaining_reps']!, _remainingRepsMeta));
    } else if (isInserting) {
      context.missing(_remainingRepsMeta);
    }
    if (data.containsKey('elapsed_ms')) {
      context.handle(_elapsedMsMeta,
          elapsedMs.isAcceptableOrUnknown(data['elapsed_ms']!, _elapsedMsMeta));
    }
    if (data.containsKey('word_index')) {
      context.handle(_wordIndexMeta,
          wordIndex.isAcceptableOrUnknown(data['word_index']!, _wordIndexMeta));
    }
    if (data.containsKey('verse_index')) {
      context.handle(
          _verseIndexMeta,
          verseIndex.isAcceptableOrUnknown(
              data['verse_index']!, _verseIndexMeta));
    }
    if (data.containsKey('last_update')) {
      context.handle(
          _lastUpdateMeta,
          lastUpdate.isAcceptableOrUnknown(
              data['last_update']!, _lastUpdateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskProgressRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id'])!,
      remainingReps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}remaining_reps'])!,
      elapsedMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}elapsed_ms'])!,
      wordIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}word_index'])!,
      verseIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}verse_index'])!,
      lastUpdate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_update'])!,
    );
  }

  @override
  $TaskProgressTable createAlias(String alias) {
    return $TaskProgressTable(attachedDatabase, alias);
  }
}

class TaskProgressRow extends DataClass implements Insertable<TaskProgressRow> {
  final String id;
  final String sessionId;
  final String taskId;
  final int remainingReps;
  final int elapsedMs;
  final int wordIndex;
  final int verseIndex;
  final DateTime lastUpdate;
  const TaskProgressRow(
      {required this.id,
      required this.sessionId,
      required this.taskId,
      required this.remainingReps,
      required this.elapsedMs,
      required this.wordIndex,
      required this.verseIndex,
      required this.lastUpdate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['task_id'] = Variable<String>(taskId);
    map['remaining_reps'] = Variable<int>(remainingReps);
    map['elapsed_ms'] = Variable<int>(elapsedMs);
    map['word_index'] = Variable<int>(wordIndex);
    map['verse_index'] = Variable<int>(verseIndex);
    map['last_update'] = Variable<DateTime>(lastUpdate);
    return map;
  }

  TaskProgressCompanion toCompanion(bool nullToAbsent) {
    return TaskProgressCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      taskId: Value(taskId),
      remainingReps: Value(remainingReps),
      elapsedMs: Value(elapsedMs),
      wordIndex: Value(wordIndex),
      verseIndex: Value(verseIndex),
      lastUpdate: Value(lastUpdate),
    );
  }

  factory TaskProgressRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskProgressRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      taskId: serializer.fromJson<String>(json['taskId']),
      remainingReps: serializer.fromJson<int>(json['remainingReps']),
      elapsedMs: serializer.fromJson<int>(json['elapsedMs']),
      wordIndex: serializer.fromJson<int>(json['wordIndex']),
      verseIndex: serializer.fromJson<int>(json['verseIndex']),
      lastUpdate: serializer.fromJson<DateTime>(json['lastUpdate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'taskId': serializer.toJson<String>(taskId),
      'remainingReps': serializer.toJson<int>(remainingReps),
      'elapsedMs': serializer.toJson<int>(elapsedMs),
      'wordIndex': serializer.toJson<int>(wordIndex),
      'verseIndex': serializer.toJson<int>(verseIndex),
      'lastUpdate': serializer.toJson<DateTime>(lastUpdate),
    };
  }

  TaskProgressRow copyWith(
          {String? id,
          String? sessionId,
          String? taskId,
          int? remainingReps,
          int? elapsedMs,
          int? wordIndex,
          int? verseIndex,
          DateTime? lastUpdate}) =>
      TaskProgressRow(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        taskId: taskId ?? this.taskId,
        remainingReps: remainingReps ?? this.remainingReps,
        elapsedMs: elapsedMs ?? this.elapsedMs,
        wordIndex: wordIndex ?? this.wordIndex,
        verseIndex: verseIndex ?? this.verseIndex,
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );
  TaskProgressRow copyWithCompanion(TaskProgressCompanion data) {
    return TaskProgressRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      remainingReps: data.remainingReps.present
          ? data.remainingReps.value
          : this.remainingReps,
      elapsedMs: data.elapsedMs.present ? data.elapsedMs.value : this.elapsedMs,
      wordIndex: data.wordIndex.present ? data.wordIndex.value : this.wordIndex,
      verseIndex:
          data.verseIndex.present ? data.verseIndex.value : this.verseIndex,
      lastUpdate:
          data.lastUpdate.present ? data.lastUpdate.value : this.lastUpdate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskProgressRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('taskId: $taskId, ')
          ..write('remainingReps: $remainingReps, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('wordIndex: $wordIndex, ')
          ..write('verseIndex: $verseIndex, ')
          ..write('lastUpdate: $lastUpdate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, taskId, remainingReps,
      elapsedMs, wordIndex, verseIndex, lastUpdate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskProgressRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.taskId == this.taskId &&
          other.remainingReps == this.remainingReps &&
          other.elapsedMs == this.elapsedMs &&
          other.wordIndex == this.wordIndex &&
          other.verseIndex == this.verseIndex &&
          other.lastUpdate == this.lastUpdate);
}

class TaskProgressCompanion extends UpdateCompanion<TaskProgressRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> taskId;
  final Value<int> remainingReps;
  final Value<int> elapsedMs;
  final Value<int> wordIndex;
  final Value<int> verseIndex;
  final Value<DateTime> lastUpdate;
  final Value<int> rowid;
  const TaskProgressCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.remainingReps = const Value.absent(),
    this.elapsedMs = const Value.absent(),
    this.wordIndex = const Value.absent(),
    this.verseIndex = const Value.absent(),
    this.lastUpdate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskProgressCompanion.insert({
    required String id,
    required String sessionId,
    required String taskId,
    required int remainingReps,
    this.elapsedMs = const Value.absent(),
    this.wordIndex = const Value.absent(),
    this.verseIndex = const Value.absent(),
    this.lastUpdate = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sessionId = Value(sessionId),
        taskId = Value(taskId),
        remainingReps = Value(remainingReps);
  static Insertable<TaskProgressRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? taskId,
    Expression<int>? remainingReps,
    Expression<int>? elapsedMs,
    Expression<int>? wordIndex,
    Expression<int>? verseIndex,
    Expression<DateTime>? lastUpdate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (taskId != null) 'task_id': taskId,
      if (remainingReps != null) 'remaining_reps': remainingReps,
      if (elapsedMs != null) 'elapsed_ms': elapsedMs,
      if (wordIndex != null) 'word_index': wordIndex,
      if (verseIndex != null) 'verse_index': verseIndex,
      if (lastUpdate != null) 'last_update': lastUpdate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskProgressCompanion copyWith(
      {Value<String>? id,
      Value<String>? sessionId,
      Value<String>? taskId,
      Value<int>? remainingReps,
      Value<int>? elapsedMs,
      Value<int>? wordIndex,
      Value<int>? verseIndex,
      Value<DateTime>? lastUpdate,
      Value<int>? rowid}) {
    return TaskProgressCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      taskId: taskId ?? this.taskId,
      remainingReps: remainingReps ?? this.remainingReps,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      wordIndex: wordIndex ?? this.wordIndex,
      verseIndex: verseIndex ?? this.verseIndex,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (remainingReps.present) {
      map['remaining_reps'] = Variable<int>(remainingReps.value);
    }
    if (elapsedMs.present) {
      map['elapsed_ms'] = Variable<int>(elapsedMs.value);
    }
    if (wordIndex.present) {
      map['word_index'] = Variable<int>(wordIndex.value);
    }
    if (verseIndex.present) {
      map['verse_index'] = Variable<int>(verseIndex.value);
    }
    if (lastUpdate.present) {
      map['last_update'] = Variable<DateTime>(lastUpdate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskProgressCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('taskId: $taskId, ')
          ..write('remainingReps: $remainingReps, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('wordIndex: $wordIndex, ')
          ..write('verseIndex: $verseIndex, ')
          ..write('lastUpdate: $lastUpdate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SnapshotsTable extends Snapshots
    with TableInfo<$SnapshotsTable, SnapshotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES sessions (id)'));
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
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
  List<GeneratedColumn> get $columns => [id, sessionId, payload, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'snapshots';
  @override
  VerificationContext validateIntegrity(Insertable<SnapshotRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
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
  SnapshotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnapshotRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SnapshotsTable createAlias(String alias) {
    return $SnapshotsTable(attachedDatabase, alias);
  }
}

class SnapshotRow extends DataClass implements Insertable<SnapshotRow> {
  final String id;
  final String sessionId;
  final String payload;
  final DateTime createdAt;
  const SnapshotRow(
      {required this.id,
      required this.sessionId,
      required this.payload,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SnapshotsCompanion toCompanion(bool nullToAbsent) {
    return SnapshotsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      payload: Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory SnapshotRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnapshotRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SnapshotRow copyWith(
          {String? id,
          String? sessionId,
          String? payload,
          DateTime? createdAt}) =>
      SnapshotRow(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        payload: payload ?? this.payload,
        createdAt: createdAt ?? this.createdAt,
      );
  SnapshotRow copyWithCompanion(SnapshotsCompanion data) {
    return SnapshotRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnapshotRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, payload, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnapshotRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class SnapshotsCompanion extends UpdateCompanion<SnapshotRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SnapshotsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SnapshotsCompanion.insert({
    required String id,
    required String sessionId,
    required String payload,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sessionId = Value(sessionId),
        payload = Value(payload);
  static Insertable<SnapshotRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SnapshotsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sessionId,
      Value<String>? payload,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SnapshotsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('fr'));
  static const VerificationMeta _rtlPrefMeta =
      const VerificationMeta('rtlPref');
  @override
  late final GeneratedColumn<bool> rtlPref = GeneratedColumn<bool>(
      'rtl_pref', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("rtl_pref" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _fontPrefsMeta =
      const VerificationMeta('fontPrefs');
  @override
  late final GeneratedColumn<String> fontPrefs = GeneratedColumn<String>(
      'font_prefs', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _ttsVoiceMeta =
      const VerificationMeta('ttsVoice');
  @override
  late final GeneratedColumn<String> ttsVoice = GeneratedColumn<String>(
      'tts_voice', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
      'speed', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _hapticsMeta =
      const VerificationMeta('haptics');
  @override
  late final GeneratedColumn<bool> haptics = GeneratedColumn<bool>(
      'haptics', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("haptics" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _notificationsMeta =
      const VerificationMeta('notifications');
  @override
  late final GeneratedColumn<bool> notifications = GeneratedColumn<bool>(
      'notifications', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notifications" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        language,
        rtlPref,
        fontPrefs,
        ttsVoice,
        speed,
        haptics,
        notifications
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(Insertable<UserSettingsRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    }
    if (data.containsKey('rtl_pref')) {
      context.handle(_rtlPrefMeta,
          rtlPref.isAcceptableOrUnknown(data['rtl_pref']!, _rtlPrefMeta));
    }
    if (data.containsKey('font_prefs')) {
      context.handle(_fontPrefsMeta,
          fontPrefs.isAcceptableOrUnknown(data['font_prefs']!, _fontPrefsMeta));
    }
    if (data.containsKey('tts_voice')) {
      context.handle(_ttsVoiceMeta,
          ttsVoice.isAcceptableOrUnknown(data['tts_voice']!, _ttsVoiceMeta));
    }
    if (data.containsKey('speed')) {
      context.handle(
          _speedMeta, speed.isAcceptableOrUnknown(data['speed']!, _speedMeta));
    }
    if (data.containsKey('haptics')) {
      context.handle(_hapticsMeta,
          haptics.isAcceptableOrUnknown(data['haptics']!, _hapticsMeta));
    }
    if (data.containsKey('notifications')) {
      context.handle(
          _notificationsMeta,
          notifications.isAcceptableOrUnknown(
              data['notifications']!, _notificationsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSettingsRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      rtlPref: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}rtl_pref'])!,
      fontPrefs: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}font_prefs'])!,
      ttsVoice: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tts_voice']),
      speed: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}speed'])!,
      haptics: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}haptics'])!,
      notifications: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}notifications'])!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSettingsRow extends DataClass implements Insertable<UserSettingsRow> {
  final String id;
  final String? userId;
  final String language;
  final bool rtlPref;
  final String fontPrefs;
  final String? ttsVoice;
  final double speed;
  final bool haptics;
  final bool notifications;
  const UserSettingsRow(
      {required this.id,
      this.userId,
      required this.language,
      required this.rtlPref,
      required this.fontPrefs,
      this.ttsVoice,
      required this.speed,
      required this.haptics,
      required this.notifications});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['language'] = Variable<String>(language);
    map['rtl_pref'] = Variable<bool>(rtlPref);
    map['font_prefs'] = Variable<String>(fontPrefs);
    if (!nullToAbsent || ttsVoice != null) {
      map['tts_voice'] = Variable<String>(ttsVoice);
    }
    map['speed'] = Variable<double>(speed);
    map['haptics'] = Variable<bool>(haptics);
    map['notifications'] = Variable<bool>(notifications);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      id: Value(id),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      language: Value(language),
      rtlPref: Value(rtlPref),
      fontPrefs: Value(fontPrefs),
      ttsVoice: ttsVoice == null && nullToAbsent
          ? const Value.absent()
          : Value(ttsVoice),
      speed: Value(speed),
      haptics: Value(haptics),
      notifications: Value(notifications),
    );
  }

  factory UserSettingsRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSettingsRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      language: serializer.fromJson<String>(json['language']),
      rtlPref: serializer.fromJson<bool>(json['rtlPref']),
      fontPrefs: serializer.fromJson<String>(json['fontPrefs']),
      ttsVoice: serializer.fromJson<String?>(json['ttsVoice']),
      speed: serializer.fromJson<double>(json['speed']),
      haptics: serializer.fromJson<bool>(json['haptics']),
      notifications: serializer.fromJson<bool>(json['notifications']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'language': serializer.toJson<String>(language),
      'rtlPref': serializer.toJson<bool>(rtlPref),
      'fontPrefs': serializer.toJson<String>(fontPrefs),
      'ttsVoice': serializer.toJson<String?>(ttsVoice),
      'speed': serializer.toJson<double>(speed),
      'haptics': serializer.toJson<bool>(haptics),
      'notifications': serializer.toJson<bool>(notifications),
    };
  }

  UserSettingsRow copyWith(
          {String? id,
          Value<String?> userId = const Value.absent(),
          String? language,
          bool? rtlPref,
          String? fontPrefs,
          Value<String?> ttsVoice = const Value.absent(),
          double? speed,
          bool? haptics,
          bool? notifications}) =>
      UserSettingsRow(
        id: id ?? this.id,
        userId: userId.present ? userId.value : this.userId,
        language: language ?? this.language,
        rtlPref: rtlPref ?? this.rtlPref,
        fontPrefs: fontPrefs ?? this.fontPrefs,
        ttsVoice: ttsVoice.present ? ttsVoice.value : this.ttsVoice,
        speed: speed ?? this.speed,
        haptics: haptics ?? this.haptics,
        notifications: notifications ?? this.notifications,
      );
  UserSettingsRow copyWithCompanion(UserSettingsCompanion data) {
    return UserSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      language: data.language.present ? data.language.value : this.language,
      rtlPref: data.rtlPref.present ? data.rtlPref.value : this.rtlPref,
      fontPrefs: data.fontPrefs.present ? data.fontPrefs.value : this.fontPrefs,
      ttsVoice: data.ttsVoice.present ? data.ttsVoice.value : this.ttsVoice,
      speed: data.speed.present ? data.speed.value : this.speed,
      haptics: data.haptics.present ? data.haptics.value : this.haptics,
      notifications: data.notifications.present
          ? data.notifications.value
          : this.notifications,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('language: $language, ')
          ..write('rtlPref: $rtlPref, ')
          ..write('fontPrefs: $fontPrefs, ')
          ..write('ttsVoice: $ttsVoice, ')
          ..write('speed: $speed, ')
          ..write('haptics: $haptics, ')
          ..write('notifications: $notifications')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, language, rtlPref, fontPrefs,
      ttsVoice, speed, haptics, notifications);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingsRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.language == this.language &&
          other.rtlPref == this.rtlPref &&
          other.fontPrefs == this.fontPrefs &&
          other.ttsVoice == this.ttsVoice &&
          other.speed == this.speed &&
          other.haptics == this.haptics &&
          other.notifications == this.notifications);
}

class UserSettingsCompanion extends UpdateCompanion<UserSettingsRow> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String> language;
  final Value<bool> rtlPref;
  final Value<String> fontPrefs;
  final Value<String?> ttsVoice;
  final Value<double> speed;
  final Value<bool> haptics;
  final Value<bool> notifications;
  final Value<int> rowid;
  const UserSettingsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.language = const Value.absent(),
    this.rtlPref = const Value.absent(),
    this.fontPrefs = const Value.absent(),
    this.ttsVoice = const Value.absent(),
    this.speed = const Value.absent(),
    this.haptics = const Value.absent(),
    this.notifications = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    this.language = const Value.absent(),
    this.rtlPref = const Value.absent(),
    this.fontPrefs = const Value.absent(),
    this.ttsVoice = const Value.absent(),
    this.speed = const Value.absent(),
    this.haptics = const Value.absent(),
    this.notifications = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<UserSettingsRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? language,
    Expression<bool>? rtlPref,
    Expression<String>? fontPrefs,
    Expression<String>? ttsVoice,
    Expression<double>? speed,
    Expression<bool>? haptics,
    Expression<bool>? notifications,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (language != null) 'language': language,
      if (rtlPref != null) 'rtl_pref': rtlPref,
      if (fontPrefs != null) 'font_prefs': fontPrefs,
      if (ttsVoice != null) 'tts_voice': ttsVoice,
      if (speed != null) 'speed': speed,
      if (haptics != null) 'haptics': haptics,
      if (notifications != null) 'notifications': notifications,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? userId,
      Value<String>? language,
      Value<bool>? rtlPref,
      Value<String>? fontPrefs,
      Value<String?>? ttsVoice,
      Value<double>? speed,
      Value<bool>? haptics,
      Value<bool>? notifications,
      Value<int>? rowid}) {
    return UserSettingsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      language: language ?? this.language,
      rtlPref: rtlPref ?? this.rtlPref,
      fontPrefs: fontPrefs ?? this.fontPrefs,
      ttsVoice: ttsVoice ?? this.ttsVoice,
      speed: speed ?? this.speed,
      haptics: haptics ?? this.haptics,
      notifications: notifications ?? this.notifications,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (rtlPref.present) {
      map['rtl_pref'] = Variable<bool>(rtlPref.value);
    }
    if (fontPrefs.present) {
      map['font_prefs'] = Variable<String>(fontPrefs.value);
    }
    if (ttsVoice.present) {
      map['tts_voice'] = Variable<String>(ttsVoice.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (haptics.present) {
      map['haptics'] = Variable<bool>(haptics.value);
    }
    if (notifications.present) {
      map['notifications'] = Variable<bool>(notifications.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('language: $language, ')
          ..write('rtlPref: $rtlPref, ')
          ..write('fontPrefs: $fontPrefs, ')
          ..write('ttsVoice: $ttsVoice, ')
          ..write('speed: $speed, ')
          ..write('haptics: $haptics, ')
          ..write('notifications: $notifications, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ThemesTable themes = $ThemesTable(this);
  late final $RoutinesTable routines = $RoutinesTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $TaskProgressTable taskProgress = $TaskProgressTable(this);
  late final $SnapshotsTable snapshots = $SnapshotsTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final ThemeDao themeDao = ThemeDao(this as AppDatabase);
  late final RoutineDao routineDao = RoutineDao(this as AppDatabase);
  late final TaskDao taskDao = TaskDao(this as AppDatabase);
  late final SessionDao sessionDao = SessionDao(this as AppDatabase);
  late final ProgressDao progressDao = ProgressDao(this as AppDatabase);
  late final SnapshotDao snapshotDao = SnapshotDao(this as AppDatabase);
  late final UserSettingsDao userSettingsDao =
      UserSettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        themes,
        routines,
        tasks,
        sessions,
        taskProgress,
        snapshots,
        userSettings
      ];
}

typedef $$ThemesTableCreateCompanionBuilder = ThemesCompanion Function({
  required String id,
  required String nameFr,
  required String nameAr,
  required String frequency,
  Value<DateTime> createdAt,
  Value<String> metadata,
  Value<int> rowid,
});
typedef $$ThemesTableUpdateCompanionBuilder = ThemesCompanion Function({
  Value<String> id,
  Value<String> nameFr,
  Value<String> nameAr,
  Value<String> frequency,
  Value<DateTime> createdAt,
  Value<String> metadata,
  Value<int> rowid,
});

final class $$ThemesTableReferences
    extends BaseReferences<_$AppDatabase, $ThemesTable, ThemeRow> {
  $$ThemesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoutinesTable, List<RoutineRow>>
      _routinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.routines,
          aliasName: $_aliasNameGenerator(db.themes.id, db.routines.themeId));

  $$RoutinesTableProcessedTableManager get routinesRefs {
    final manager = $$RoutinesTableTableManager($_db, $_db.routines)
        .filter((f) => f.themeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_routinesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ThemesTableFilterComposer
    extends Composer<_$AppDatabase, $ThemesTable> {
  $$ThemesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameFr => $composableBuilder(
      column: $table.nameFr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameAr => $composableBuilder(
      column: $table.nameAr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));

  Expression<bool> routinesRefs(
      Expression<bool> Function($$RoutinesTableFilterComposer f) f) {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.routines,
        getReferencedColumn: (t) => t.themeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoutinesTableFilterComposer(
              $db: $db,
              $table: $db.routines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ThemesTableOrderingComposer
    extends Composer<_$AppDatabase, $ThemesTable> {
  $$ThemesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameFr => $composableBuilder(
      column: $table.nameFr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameAr => $composableBuilder(
      column: $table.nameAr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));
}

class $$ThemesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ThemesTable> {
  $$ThemesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameFr =>
      $composableBuilder(column: $table.nameFr, builder: (column) => column);

  GeneratedColumn<String> get nameAr =>
      $composableBuilder(column: $table.nameAr, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  Expression<T> routinesRefs<T extends Object>(
      Expression<T> Function($$RoutinesTableAnnotationComposer a) f) {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.routines,
        getReferencedColumn: (t) => t.themeId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoutinesTableAnnotationComposer(
              $db: $db,
              $table: $db.routines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ThemesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ThemesTable,
    ThemeRow,
    $$ThemesTableFilterComposer,
    $$ThemesTableOrderingComposer,
    $$ThemesTableAnnotationComposer,
    $$ThemesTableCreateCompanionBuilder,
    $$ThemesTableUpdateCompanionBuilder,
    (ThemeRow, $$ThemesTableReferences),
    ThemeRow,
    PrefetchHooks Function({bool routinesRefs})> {
  $$ThemesTableTableManager(_$AppDatabase db, $ThemesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThemesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThemesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThemesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> nameFr = const Value.absent(),
            Value<String> nameAr = const Value.absent(),
            Value<String> frequency = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ThemesCompanion(
            id: id,
            nameFr: nameFr,
            nameAr: nameAr,
            frequency: frequency,
            createdAt: createdAt,
            metadata: metadata,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String nameFr,
            required String nameAr,
            required String frequency,
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ThemesCompanion.insert(
            id: id,
            nameFr: nameFr,
            nameAr: nameAr,
            frequency: frequency,
            createdAt: createdAt,
            metadata: metadata,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ThemesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({routinesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (routinesRefs) db.routines],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routinesRefs)
                    await $_getPrefetchedData<ThemeRow, $ThemesTable,
                            RoutineRow>(
                        currentTable: table,
                        referencedTable:
                            $$ThemesTableReferences._routinesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ThemesTableReferences(db, table, p0).routinesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.themeId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ThemesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ThemesTable,
    ThemeRow,
    $$ThemesTableFilterComposer,
    $$ThemesTableOrderingComposer,
    $$ThemesTableAnnotationComposer,
    $$ThemesTableCreateCompanionBuilder,
    $$ThemesTableUpdateCompanionBuilder,
    (ThemeRow, $$ThemesTableReferences),
    ThemeRow,
    PrefetchHooks Function({bool routinesRefs})>;
typedef $$RoutinesTableCreateCompanionBuilder = RoutinesCompanion Function({
  required String id,
  required String themeId,
  required String nameFr,
  required String nameAr,
  Value<int> orderIndex,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$RoutinesTableUpdateCompanionBuilder = RoutinesCompanion Function({
  Value<String> id,
  Value<String> themeId,
  Value<String> nameFr,
  Value<String> nameAr,
  Value<int> orderIndex,
  Value<bool> isActive,
  Value<int> rowid,
});

final class $$RoutinesTableReferences
    extends BaseReferences<_$AppDatabase, $RoutinesTable, RoutineRow> {
  $$RoutinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ThemesTable _themeIdTable(_$AppDatabase db) => db.themes
      .createAlias($_aliasNameGenerator(db.routines.themeId, db.themes.id));

  $$ThemesTableProcessedTableManager get themeId {
    final $_column = $_itemColumn<String>('theme_id')!;

    final manager = $$ThemesTableTableManager($_db, $_db.themes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_themeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TasksTable, List<TaskRow>> _tasksRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.tasks,
          aliasName: $_aliasNameGenerator(db.routines.id, db.tasks.routineId));

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.routineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SessionsTable, List<SessionRow>>
      _sessionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.sessions,
              aliasName:
                  $_aliasNameGenerator(db.routines.id, db.sessions.routineId));

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager($_db, $_db.sessions)
        .filter((f) => f.routineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RoutinesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameFr => $composableBuilder(
      column: $table.nameFr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameAr => $composableBuilder(
      column: $table.nameAr, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  $$ThemesTableFilterComposer get themeId {
    final $$ThemesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.themeId,
        referencedTable: $db.themes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ThemesTableFilterComposer(
              $db: $db,
              $table: $db.themes,
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
        getReferencedColumn: (t) => t.routineId,
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

  Expression<bool> sessionsRefs(
      Expression<bool> Function($$SessionsTableFilterComposer f) f) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.routineId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableFilterComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RoutinesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameFr => $composableBuilder(
      column: $table.nameFr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameAr => $composableBuilder(
      column: $table.nameAr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  $$ThemesTableOrderingComposer get themeId {
    final $$ThemesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.themeId,
        referencedTable: $db.themes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ThemesTableOrderingComposer(
              $db: $db,
              $table: $db.themes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoutinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameFr =>
      $composableBuilder(column: $table.nameFr, builder: (column) => column);

  GeneratedColumn<String> get nameAr =>
      $composableBuilder(column: $table.nameAr, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  $$ThemesTableAnnotationComposer get themeId {
    final $$ThemesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.themeId,
        referencedTable: $db.themes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ThemesTableAnnotationComposer(
              $db: $db,
              $table: $db.themes,
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
        getReferencedColumn: (t) => t.routineId,
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

  Expression<T> sessionsRefs<T extends Object>(
      Expression<T> Function($$SessionsTableAnnotationComposer a) f) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.routineId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RoutinesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoutinesTable,
    RoutineRow,
    $$RoutinesTableFilterComposer,
    $$RoutinesTableOrderingComposer,
    $$RoutinesTableAnnotationComposer,
    $$RoutinesTableCreateCompanionBuilder,
    $$RoutinesTableUpdateCompanionBuilder,
    (RoutineRow, $$RoutinesTableReferences),
    RoutineRow,
    PrefetchHooks Function({bool themeId, bool tasksRefs, bool sessionsRefs})> {
  $$RoutinesTableTableManager(_$AppDatabase db, $RoutinesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> themeId = const Value.absent(),
            Value<String> nameFr = const Value.absent(),
            Value<String> nameAr = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoutinesCompanion(
            id: id,
            themeId: themeId,
            nameFr: nameFr,
            nameAr: nameAr,
            orderIndex: orderIndex,
            isActive: isActive,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String themeId,
            required String nameFr,
            required String nameAr,
            Value<int> orderIndex = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoutinesCompanion.insert(
            id: id,
            themeId: themeId,
            nameFr: nameFr,
            nameAr: nameAr,
            orderIndex: orderIndex,
            isActive: isActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$RoutinesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {themeId = false, tasksRefs = false, sessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tasksRefs) db.tasks,
                if (sessionsRefs) db.sessions
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
                if (themeId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.themeId,
                    referencedTable:
                        $$RoutinesTableReferences._themeIdTable(db),
                    referencedColumn:
                        $$RoutinesTableReferences._themeIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tasksRefs)
                    await $_getPrefetchedData<RoutineRow, $RoutinesTable,
                            TaskRow>(
                        currentTable: table,
                        referencedTable:
                            $$RoutinesTableReferences._tasksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RoutinesTableReferences(db, table, p0).tasksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.routineId == item.id),
                        typedResults: items),
                  if (sessionsRefs)
                    await $_getPrefetchedData<RoutineRow, $RoutinesTable,
                            SessionRow>(
                        currentTable: table,
                        referencedTable:
                            $$RoutinesTableReferences._sessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RoutinesTableReferences(db, table, p0)
                                .sessionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.routineId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RoutinesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RoutinesTable,
    RoutineRow,
    $$RoutinesTableFilterComposer,
    $$RoutinesTableOrderingComposer,
    $$RoutinesTableAnnotationComposer,
    $$RoutinesTableCreateCompanionBuilder,
    $$RoutinesTableUpdateCompanionBuilder,
    (RoutineRow, $$RoutinesTableReferences),
    RoutineRow,
    PrefetchHooks Function({bool themeId, bool tasksRefs, bool sessionsRefs})>;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String routineId,
  required String type,
  required String category,
  Value<int> defaultReps,
  Value<String> audioSettings,
  Value<String> displaySettings,
  Value<String?> contentId,
  Value<String?> notesFr,
  Value<String?> notesAr,
  Value<int> orderIndex,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> routineId,
  Value<String> type,
  Value<String> category,
  Value<int> defaultReps,
  Value<String> audioSettings,
  Value<String> displaySettings,
  Value<String?> contentId,
  Value<String?> notesFr,
  Value<String?> notesAr,
  Value<int> orderIndex,
  Value<int> rowid,
});

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, TaskRow> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutinesTable _routineIdTable(_$AppDatabase db) => db.routines
      .createAlias($_aliasNameGenerator(db.tasks.routineId, db.routines.id));

  $$RoutinesTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<String>('routine_id')!;

    final manager = $$RoutinesTableTableManager($_db, $_db.routines)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TaskProgressTable, List<TaskProgressRow>>
      _taskProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.taskProgress,
          aliasName: $_aliasNameGenerator(db.tasks.id, db.taskProgress.taskId));

  $$TaskProgressTableProcessedTableManager get taskProgressRefs {
    final manager = $$TaskProgressTableTableManager($_db, $_db.taskProgress)
        .filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskProgressRefsTable($_db));
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
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get defaultReps => $composableBuilder(
      column: $table.defaultReps, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioSettings => $composableBuilder(
      column: $table.audioSettings, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displaySettings => $composableBuilder(
      column: $table.displaySettings,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contentId => $composableBuilder(
      column: $table.contentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notesFr => $composableBuilder(
      column: $table.notesFr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notesAr => $composableBuilder(
      column: $table.notesAr, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.routineId,
        referencedTable: $db.routines,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoutinesTableFilterComposer(
              $db: $db,
              $table: $db.routines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> taskProgressRefs(
      Expression<bool> Function($$TaskProgressTableFilterComposer f) f) {
    final $$TaskProgressTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskProgress,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskProgressTableFilterComposer(
              $db: $db,
              $table: $db.taskProgress,
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
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get defaultReps => $composableBuilder(
      column: $table.defaultReps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioSettings => $composableBuilder(
      column: $table.audioSettings,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displaySettings => $composableBuilder(
      column: $table.displaySettings,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contentId => $composableBuilder(
      column: $table.contentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notesFr => $composableBuilder(
      column: $table.notesFr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notesAr => $composableBuilder(
      column: $table.notesAr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.routineId,
        referencedTable: $db.routines,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoutinesTableOrderingComposer(
              $db: $db,
              $table: $db.routines,
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get defaultReps => $composableBuilder(
      column: $table.defaultReps, builder: (column) => column);

  GeneratedColumn<String> get audioSettings => $composableBuilder(
      column: $table.audioSettings, builder: (column) => column);

  GeneratedColumn<String> get displaySettings => $composableBuilder(
      column: $table.displaySettings, builder: (column) => column);

  GeneratedColumn<String> get contentId =>
      $composableBuilder(column: $table.contentId, builder: (column) => column);

  GeneratedColumn<String> get notesFr =>
      $composableBuilder(column: $table.notesFr, builder: (column) => column);

  GeneratedColumn<String> get notesAr =>
      $composableBuilder(column: $table.notesAr, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  $$RoutinesTableAnnotationComposer get routineId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.routineId,
        referencedTable: $db.routines,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoutinesTableAnnotationComposer(
              $db: $db,
              $table: $db.routines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> taskProgressRefs<T extends Object>(
      Expression<T> Function($$TaskProgressTableAnnotationComposer a) f) {
    final $$TaskProgressTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskProgress,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskProgressTableAnnotationComposer(
              $db: $db,
              $table: $db.taskProgress,
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
    PrefetchHooks Function({bool routineId, bool taskProgressRefs})> {
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
            Value<String> id = const Value.absent(),
            Value<String> routineId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<int> defaultReps = const Value.absent(),
            Value<String> audioSettings = const Value.absent(),
            Value<String> displaySettings = const Value.absent(),
            Value<String?> contentId = const Value.absent(),
            Value<String?> notesFr = const Value.absent(),
            Value<String?> notesAr = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            routineId: routineId,
            type: type,
            category: category,
            defaultReps: defaultReps,
            audioSettings: audioSettings,
            displaySettings: displaySettings,
            contentId: contentId,
            notesFr: notesFr,
            notesAr: notesAr,
            orderIndex: orderIndex,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String routineId,
            required String type,
            required String category,
            Value<int> defaultReps = const Value.absent(),
            Value<String> audioSettings = const Value.absent(),
            Value<String> displaySettings = const Value.absent(),
            Value<String?> contentId = const Value.absent(),
            Value<String?> notesFr = const Value.absent(),
            Value<String?> notesAr = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            routineId: routineId,
            type: type,
            category: category,
            defaultReps: defaultReps,
            audioSettings: audioSettings,
            displaySettings: displaySettings,
            contentId: contentId,
            notesFr: notesFr,
            notesAr: notesAr,
            orderIndex: orderIndex,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TasksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {routineId = false, taskProgressRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (taskProgressRefs) db.taskProgress],
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
                if (routineId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.routineId,
                    referencedTable: $$TasksTableReferences._routineIdTable(db),
                    referencedColumn:
                        $$TasksTableReferences._routineIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (taskProgressRefs)
                    await $_getPrefetchedData<TaskRow, $TasksTable,
                            TaskProgressRow>(
                        currentTable: table,
                        referencedTable:
                            $$TasksTableReferences._taskProgressRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0)
                                .taskProgressRefs,
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
    PrefetchHooks Function({bool routineId, bool taskProgressRefs})>;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  required String id,
  required String routineId,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<String> state,
  Value<String?> snapshotRef,
  Value<int> rowid,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<String> id,
  Value<String> routineId,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<String> state,
  Value<String?> snapshotRef,
  Value<int> rowid,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, SessionRow> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutinesTable _routineIdTable(_$AppDatabase db) => db.routines
      .createAlias($_aliasNameGenerator(db.sessions.routineId, db.routines.id));

  $$RoutinesTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<String>('routine_id')!;

    final manager = $$RoutinesTableTableManager($_db, $_db.routines)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TaskProgressTable, List<TaskProgressRow>>
      _taskProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.taskProgress,
          aliasName:
              $_aliasNameGenerator(db.sessions.id, db.taskProgress.sessionId));

  $$TaskProgressTableProcessedTableManager get taskProgressRefs {
    final manager = $$TaskProgressTableTableManager($_db, $_db.taskProgress)
        .filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskProgressRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SnapshotsTable, List<SnapshotRow>>
      _snapshotsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.snapshots,
              aliasName:
                  $_aliasNameGenerator(db.sessions.id, db.snapshots.sessionId));

  $$SnapshotsTableProcessedTableManager get snapshotsRefs {
    final manager = $$SnapshotsTableTableManager($_db, $_db.snapshots)
        .filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_snapshotsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get snapshotRef => $composableBuilder(
      column: $table.snapshotRef, builder: (column) => ColumnFilters(column));

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.routineId,
        referencedTable: $db.routines,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoutinesTableFilterComposer(
              $db: $db,
              $table: $db.routines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> taskProgressRefs(
      Expression<bool> Function($$TaskProgressTableFilterComposer f) f) {
    final $$TaskProgressTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskProgress,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskProgressTableFilterComposer(
              $db: $db,
              $table: $db.taskProgress,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> snapshotsRefs(
      Expression<bool> Function($$SnapshotsTableFilterComposer f) f) {
    final $$SnapshotsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.snapshots,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SnapshotsTableFilterComposer(
              $db: $db,
              $table: $db.snapshots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get snapshotRef => $composableBuilder(
      column: $table.snapshotRef, builder: (column) => ColumnOrderings(column));

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.routineId,
        referencedTable: $db.routines,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoutinesTableOrderingComposer(
              $db: $db,
              $table: $db.routines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get snapshotRef => $composableBuilder(
      column: $table.snapshotRef, builder: (column) => column);

  $$RoutinesTableAnnotationComposer get routineId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.routineId,
        referencedTable: $db.routines,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoutinesTableAnnotationComposer(
              $db: $db,
              $table: $db.routines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> taskProgressRefs<T extends Object>(
      Expression<T> Function($$TaskProgressTableAnnotationComposer a) f) {
    final $$TaskProgressTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskProgress,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TaskProgressTableAnnotationComposer(
              $db: $db,
              $table: $db.taskProgress,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> snapshotsRefs<T extends Object>(
      Expression<T> Function($$SnapshotsTableAnnotationComposer a) f) {
    final $$SnapshotsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.snapshots,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SnapshotsTableAnnotationComposer(
              $db: $db,
              $table: $db.snapshots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SessionsTable,
    SessionRow,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (SessionRow, $$SessionsTableReferences),
    SessionRow,
    PrefetchHooks Function(
        {bool routineId, bool taskProgressRefs, bool snapshotsRefs})> {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> routineId = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<String> state = const Value.absent(),
            Value<String?> snapshotRef = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SessionsCompanion(
            id: id,
            routineId: routineId,
            startedAt: startedAt,
            endedAt: endedAt,
            state: state,
            snapshotRef: snapshotRef,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String routineId,
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<String> state = const Value.absent(),
            Value<String?> snapshotRef = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SessionsCompanion.insert(
            id: id,
            routineId: routineId,
            startedAt: startedAt,
            endedAt: endedAt,
            state: state,
            snapshotRef: snapshotRef,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SessionsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {routineId = false,
              taskProgressRefs = false,
              snapshotsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (taskProgressRefs) db.taskProgress,
                if (snapshotsRefs) db.snapshots
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
                if (routineId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.routineId,
                    referencedTable:
                        $$SessionsTableReferences._routineIdTable(db),
                    referencedColumn:
                        $$SessionsTableReferences._routineIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (taskProgressRefs)
                    await $_getPrefetchedData<SessionRow, $SessionsTable,
                            TaskProgressRow>(
                        currentTable: table,
                        referencedTable: $$SessionsTableReferences
                            ._taskProgressRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SessionsTableReferences(db, table, p0)
                                .taskProgressRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sessionId == item.id),
                        typedResults: items),
                  if (snapshotsRefs)
                    await $_getPrefetchedData<SessionRow, $SessionsTable,
                            SnapshotRow>(
                        currentTable: table,
                        referencedTable:
                            $$SessionsTableReferences._snapshotsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SessionsTableReferences(db, table, p0)
                                .snapshotsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sessionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SessionsTable,
    SessionRow,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (SessionRow, $$SessionsTableReferences),
    SessionRow,
    PrefetchHooks Function(
        {bool routineId, bool taskProgressRefs, bool snapshotsRefs})>;
typedef $$TaskProgressTableCreateCompanionBuilder = TaskProgressCompanion
    Function({
  required String id,
  required String sessionId,
  required String taskId,
  required int remainingReps,
  Value<int> elapsedMs,
  Value<int> wordIndex,
  Value<int> verseIndex,
  Value<DateTime> lastUpdate,
  Value<int> rowid,
});
typedef $$TaskProgressTableUpdateCompanionBuilder = TaskProgressCompanion
    Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String> taskId,
  Value<int> remainingReps,
  Value<int> elapsedMs,
  Value<int> wordIndex,
  Value<int> verseIndex,
  Value<DateTime> lastUpdate,
  Value<int> rowid,
});

final class $$TaskProgressTableReferences
    extends BaseReferences<_$AppDatabase, $TaskProgressTable, TaskProgressRow> {
  $$TaskProgressTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias(
          $_aliasNameGenerator(db.taskProgress.sessionId, db.sessions.id));

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager($_db, $_db.sessions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks
      .createAlias($_aliasNameGenerator(db.taskProgress.taskId, db.tasks.id));

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TaskProgressTableFilterComposer
    extends Composer<_$AppDatabase, $TaskProgressTable> {
  $$TaskProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get remainingReps => $composableBuilder(
      column: $table.remainingReps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get elapsedMs => $composableBuilder(
      column: $table.elapsedMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wordIndex => $composableBuilder(
      column: $table.wordIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get verseIndex => $composableBuilder(
      column: $table.verseIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnFilters(column));

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableFilterComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

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

class $$TaskProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskProgressTable> {
  $$TaskProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get remainingReps => $composableBuilder(
      column: $table.remainingReps,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get elapsedMs => $composableBuilder(
      column: $table.elapsedMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wordIndex => $composableBuilder(
      column: $table.wordIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get verseIndex => $composableBuilder(
      column: $table.verseIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => ColumnOrderings(column));

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableOrderingComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

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

class $$TaskProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskProgressTable> {
  $$TaskProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get remainingReps => $composableBuilder(
      column: $table.remainingReps, builder: (column) => column);

  GeneratedColumn<int> get elapsedMs =>
      $composableBuilder(column: $table.elapsedMs, builder: (column) => column);

  GeneratedColumn<int> get wordIndex =>
      $composableBuilder(column: $table.wordIndex, builder: (column) => column);

  GeneratedColumn<int> get verseIndex => $composableBuilder(
      column: $table.verseIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdate => $composableBuilder(
      column: $table.lastUpdate, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

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

class $$TaskProgressTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TaskProgressTable,
    TaskProgressRow,
    $$TaskProgressTableFilterComposer,
    $$TaskProgressTableOrderingComposer,
    $$TaskProgressTableAnnotationComposer,
    $$TaskProgressTableCreateCompanionBuilder,
    $$TaskProgressTableUpdateCompanionBuilder,
    (TaskProgressRow, $$TaskProgressTableReferences),
    TaskProgressRow,
    PrefetchHooks Function({bool sessionId, bool taskId})> {
  $$TaskProgressTableTableManager(_$AppDatabase db, $TaskProgressTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<String> taskId = const Value.absent(),
            Value<int> remainingReps = const Value.absent(),
            Value<int> elapsedMs = const Value.absent(),
            Value<int> wordIndex = const Value.absent(),
            Value<int> verseIndex = const Value.absent(),
            Value<DateTime> lastUpdate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskProgressCompanion(
            id: id,
            sessionId: sessionId,
            taskId: taskId,
            remainingReps: remainingReps,
            elapsedMs: elapsedMs,
            wordIndex: wordIndex,
            verseIndex: verseIndex,
            lastUpdate: lastUpdate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sessionId,
            required String taskId,
            required int remainingReps,
            Value<int> elapsedMs = const Value.absent(),
            Value<int> wordIndex = const Value.absent(),
            Value<int> verseIndex = const Value.absent(),
            Value<DateTime> lastUpdate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TaskProgressCompanion.insert(
            id: id,
            sessionId: sessionId,
            taskId: taskId,
            remainingReps: remainingReps,
            elapsedMs: elapsedMs,
            wordIndex: wordIndex,
            verseIndex: verseIndex,
            lastUpdate: lastUpdate,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TaskProgressTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sessionId = false, taskId = false}) {
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
                if (sessionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionId,
                    referencedTable:
                        $$TaskProgressTableReferences._sessionIdTable(db),
                    referencedColumn:
                        $$TaskProgressTableReferences._sessionIdTable(db).id,
                  ) as T;
                }
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable:
                        $$TaskProgressTableReferences._taskIdTable(db),
                    referencedColumn:
                        $$TaskProgressTableReferences._taskIdTable(db).id,
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

typedef $$TaskProgressTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TaskProgressTable,
    TaskProgressRow,
    $$TaskProgressTableFilterComposer,
    $$TaskProgressTableOrderingComposer,
    $$TaskProgressTableAnnotationComposer,
    $$TaskProgressTableCreateCompanionBuilder,
    $$TaskProgressTableUpdateCompanionBuilder,
    (TaskProgressRow, $$TaskProgressTableReferences),
    TaskProgressRow,
    PrefetchHooks Function({bool sessionId, bool taskId})>;
typedef $$SnapshotsTableCreateCompanionBuilder = SnapshotsCompanion Function({
  required String id,
  required String sessionId,
  required String payload,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$SnapshotsTableUpdateCompanionBuilder = SnapshotsCompanion Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$SnapshotsTableReferences
    extends BaseReferences<_$AppDatabase, $SnapshotsTable, SnapshotRow> {
  $$SnapshotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias(
          $_aliasNameGenerator(db.snapshots.sessionId, db.sessions.id));

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager($_db, $_db.sessions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $SnapshotsTable> {
  $$SnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableFilterComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $SnapshotsTable> {
  $$SnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableOrderingComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SnapshotsTable> {
  $$SnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SnapshotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SnapshotsTable,
    SnapshotRow,
    $$SnapshotsTableFilterComposer,
    $$SnapshotsTableOrderingComposer,
    $$SnapshotsTableAnnotationComposer,
    $$SnapshotsTableCreateCompanionBuilder,
    $$SnapshotsTableUpdateCompanionBuilder,
    (SnapshotRow, $$SnapshotsTableReferences),
    SnapshotRow,
    PrefetchHooks Function({bool sessionId})> {
  $$SnapshotsTableTableManager(_$AppDatabase db, $SnapshotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SnapshotsCompanion(
            id: id,
            sessionId: sessionId,
            payload: payload,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sessionId,
            required String payload,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SnapshotsCompanion.insert(
            id: id,
            sessionId: sessionId,
            payload: payload,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SnapshotsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                if (sessionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionId,
                    referencedTable:
                        $$SnapshotsTableReferences._sessionIdTable(db),
                    referencedColumn:
                        $$SnapshotsTableReferences._sessionIdTable(db).id,
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

typedef $$SnapshotsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SnapshotsTable,
    SnapshotRow,
    $$SnapshotsTableFilterComposer,
    $$SnapshotsTableOrderingComposer,
    $$SnapshotsTableAnnotationComposer,
    $$SnapshotsTableCreateCompanionBuilder,
    $$SnapshotsTableUpdateCompanionBuilder,
    (SnapshotRow, $$SnapshotsTableReferences),
    SnapshotRow,
    PrefetchHooks Function({bool sessionId})>;
typedef $$UserSettingsTableCreateCompanionBuilder = UserSettingsCompanion
    Function({
  required String id,
  Value<String?> userId,
  Value<String> language,
  Value<bool> rtlPref,
  Value<String> fontPrefs,
  Value<String?> ttsVoice,
  Value<double> speed,
  Value<bool> haptics,
  Value<bool> notifications,
  Value<int> rowid,
});
typedef $$UserSettingsTableUpdateCompanionBuilder = UserSettingsCompanion
    Function({
  Value<String> id,
  Value<String?> userId,
  Value<String> language,
  Value<bool> rtlPref,
  Value<String> fontPrefs,
  Value<String?> ttsVoice,
  Value<double> speed,
  Value<bool> haptics,
  Value<bool> notifications,
  Value<int> rowid,
});

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get rtlPref => $composableBuilder(
      column: $table.rtlPref, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fontPrefs => $composableBuilder(
      column: $table.fontPrefs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ttsVoice => $composableBuilder(
      column: $table.ttsVoice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get speed => $composableBuilder(
      column: $table.speed, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get haptics => $composableBuilder(
      column: $table.haptics, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get notifications => $composableBuilder(
      column: $table.notifications, builder: (column) => ColumnFilters(column));
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get rtlPref => $composableBuilder(
      column: $table.rtlPref, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fontPrefs => $composableBuilder(
      column: $table.fontPrefs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ttsVoice => $composableBuilder(
      column: $table.ttsVoice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get speed => $composableBuilder(
      column: $table.speed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get haptics => $composableBuilder(
      column: $table.haptics, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get notifications => $composableBuilder(
      column: $table.notifications,
      builder: (column) => ColumnOrderings(column));
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<bool> get rtlPref =>
      $composableBuilder(column: $table.rtlPref, builder: (column) => column);

  GeneratedColumn<String> get fontPrefs =>
      $composableBuilder(column: $table.fontPrefs, builder: (column) => column);

  GeneratedColumn<String> get ttsVoice =>
      $composableBuilder(column: $table.ttsVoice, builder: (column) => column);

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<bool> get haptics =>
      $composableBuilder(column: $table.haptics, builder: (column) => column);

  GeneratedColumn<bool> get notifications => $composableBuilder(
      column: $table.notifications, builder: (column) => column);
}

class $$UserSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserSettingsTable,
    UserSettingsRow,
    $$UserSettingsTableFilterComposer,
    $$UserSettingsTableOrderingComposer,
    $$UserSettingsTableAnnotationComposer,
    $$UserSettingsTableCreateCompanionBuilder,
    $$UserSettingsTableUpdateCompanionBuilder,
    (
      UserSettingsRow,
      BaseReferences<_$AppDatabase, $UserSettingsTable, UserSettingsRow>
    ),
    UserSettingsRow,
    PrefetchHooks Function()> {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<bool> rtlPref = const Value.absent(),
            Value<String> fontPrefs = const Value.absent(),
            Value<String?> ttsVoice = const Value.absent(),
            Value<double> speed = const Value.absent(),
            Value<bool> haptics = const Value.absent(),
            Value<bool> notifications = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSettingsCompanion(
            id: id,
            userId: userId,
            language: language,
            rtlPref: rtlPref,
            fontPrefs: fontPrefs,
            ttsVoice: ttsVoice,
            speed: speed,
            haptics: haptics,
            notifications: notifications,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> userId = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<bool> rtlPref = const Value.absent(),
            Value<String> fontPrefs = const Value.absent(),
            Value<String?> ttsVoice = const Value.absent(),
            Value<double> speed = const Value.absent(),
            Value<bool> haptics = const Value.absent(),
            Value<bool> notifications = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserSettingsCompanion.insert(
            id: id,
            userId: userId,
            language: language,
            rtlPref: rtlPref,
            fontPrefs: fontPrefs,
            ttsVoice: ttsVoice,
            speed: speed,
            haptics: haptics,
            notifications: notifications,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserSettingsTable,
    UserSettingsRow,
    $$UserSettingsTableFilterComposer,
    $$UserSettingsTableOrderingComposer,
    $$UserSettingsTableAnnotationComposer,
    $$UserSettingsTableCreateCompanionBuilder,
    $$UserSettingsTableUpdateCompanionBuilder,
    (
      UserSettingsRow,
      BaseReferences<_$AppDatabase, $UserSettingsTable, UserSettingsRow>
    ),
    UserSettingsRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ThemesTableTableManager get themes =>
      $$ThemesTableTableManager(_db, _db.themes);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db, _db.routines);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$TaskProgressTableTableManager get taskProgress =>
      $$TaskProgressTableTableManager(_db, _db.taskProgress);
  $$SnapshotsTableTableManager get snapshots =>
      $$SnapshotsTableTableManager(_db, _db.snapshots);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
}

mixin _$ThemeDaoMixin on DatabaseAccessor<AppDatabase> {
  $ThemesTable get themes => attachedDatabase.themes;
}
mixin _$RoutineDaoMixin on DatabaseAccessor<AppDatabase> {
  $ThemesTable get themes => attachedDatabase.themes;
  $RoutinesTable get routines => attachedDatabase.routines;
}
mixin _$TaskDaoMixin on DatabaseAccessor<AppDatabase> {
  $ThemesTable get themes => attachedDatabase.themes;
  $RoutinesTable get routines => attachedDatabase.routines;
  $TasksTable get tasks => attachedDatabase.tasks;
}
mixin _$SessionDaoMixin on DatabaseAccessor<AppDatabase> {
  $ThemesTable get themes => attachedDatabase.themes;
  $RoutinesTable get routines => attachedDatabase.routines;
  $SessionsTable get sessions => attachedDatabase.sessions;
}
mixin _$ProgressDaoMixin on DatabaseAccessor<AppDatabase> {
  $ThemesTable get themes => attachedDatabase.themes;
  $RoutinesTable get routines => attachedDatabase.routines;
  $SessionsTable get sessions => attachedDatabase.sessions;
  $TasksTable get tasks => attachedDatabase.tasks;
  $TaskProgressTable get taskProgress => attachedDatabase.taskProgress;
}
mixin _$SnapshotDaoMixin on DatabaseAccessor<AppDatabase> {
  $ThemesTable get themes => attachedDatabase.themes;
  $RoutinesTable get routines => attachedDatabase.routines;
  $SessionsTable get sessions => attachedDatabase.sessions;
  $SnapshotsTable get snapshots => attachedDatabase.snapshots;
}
mixin _$UserSettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserSettingsTable get userSettings => attachedDatabase.userSettings;
}
