// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitSystemMeta = const VerificationMeta(
    'unitSystem',
  );
  @override
  late final GeneratedColumn<String> unitSystem = GeneratedColumn<String>(
    'unit_system',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weeklyActivityGoalMeta =
      const VerificationMeta('weeklyActivityGoal');
  @override
  late final GeneratedColumn<int> weeklyActivityGoal = GeneratedColumn<int>(
    'weekly_activity_goal',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<String> dateOfBirth = GeneratedColumn<String>(
    'date_of_birth',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fitnessGoalMeta = const VerificationMeta(
    'fitnessGoal',
  );
  @override
  late final GeneratedColumn<String> fitnessGoal = GeneratedColumn<String>(
    'fitness_goal',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _runningExperienceMeta = const VerificationMeta(
    'runningExperience',
  );
  @override
  late final GeneratedColumn<String> runningExperience =
      GeneratedColumn<String>(
        'running_experience',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _strengthExperienceMeta =
      const VerificationMeta('strengthExperience');
  @override
  late final GeneratedColumn<String> strengthExperience =
      GeneratedColumn<String>(
        'strength_experience',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _trainingDaysMeta = const VerificationMeta(
    'trainingDays',
  );
  @override
  late final GeneratedColumn<String> trainingDays = GeneratedColumn<String>(
    'training_days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    unitSystem,
    weeklyActivityGoal,
    dateOfBirth,
    heightCm,
    weightKg,
    fitnessGoal,
    runningExperience,
    strengthExperience,
    trainingDays,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('unit_system')) {
      context.handle(
        _unitSystemMeta,
        unitSystem.isAcceptableOrUnknown(data['unit_system']!, _unitSystemMeta),
      );
    } else if (isInserting) {
      context.missing(_unitSystemMeta);
    }
    if (data.containsKey('weekly_activity_goal')) {
      context.handle(
        _weeklyActivityGoalMeta,
        weeklyActivityGoal.isAcceptableOrUnknown(
          data['weekly_activity_goal']!,
          _weeklyActivityGoalMeta,
        ),
      );
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('fitness_goal')) {
      context.handle(
        _fitnessGoalMeta,
        fitnessGoal.isAcceptableOrUnknown(
          data['fitness_goal']!,
          _fitnessGoalMeta,
        ),
      );
    }
    if (data.containsKey('running_experience')) {
      context.handle(
        _runningExperienceMeta,
        runningExperience.isAcceptableOrUnknown(
          data['running_experience']!,
          _runningExperienceMeta,
        ),
      );
    }
    if (data.containsKey('strength_experience')) {
      context.handle(
        _strengthExperienceMeta,
        strengthExperience.isAcceptableOrUnknown(
          data['strength_experience']!,
          _strengthExperienceMeta,
        ),
      );
    }
    if (data.containsKey('training_days')) {
      context.handle(
        _trainingDaysMeta,
        trainingDays.isAcceptableOrUnknown(
          data['training_days']!,
          _trainingDaysMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      unitSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_system'],
      )!,
      weeklyActivityGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekly_activity_goal'],
      ),
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_of_birth'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      fitnessGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fitness_goal'],
      ),
      runningExperience: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}running_experience'],
      ),
      strengthExperience: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strength_experience'],
      ),
      trainingDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}training_days'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  /// Client-generated UUIDv7 (see `core/domain/entity_id.dart`).
  final String id;
  final String displayName;

  /// Persisted as `'metric'` or `'imperial'` (see `core/domain/units.dart`).
  final String unitSystem;

  /// Target sessions per week. Nullable: no goal set yet.
  final int? weeklyActivityGoal;

  /// ISO-8601 date string (`YYYY-MM-DD`) — see `core/domain/local_date.dart`.
  /// Nullable: never forced (spec §5.1). S2-tier
  /// (`knowledge/engineering/security_and_privacy.md`) — never logged.
  final String? dateOfBirth;

  /// Canonical metric (centimetres). Nullable: never forced. S2-tier — never
  /// logged. Presentation converts to ft+in for imperial users (see
  /// `core/domain/units.dart#cmToFeetInches`).
  final double? heightCm;

  /// Canonical metric (kilograms). Nullable: never forced. S2-tier — never
  /// logged. Presentation converts to lb for imperial users.
  final double? weightKg;

  /// Persisted as one of `FitnessGoal`'s storage keys (see
  /// `features/profile/domain/user_profile.dart`). Nullable: never forced.
  final String? fitnessGoal;

  /// Persisted as one of `ExperienceLevel`'s storage keys. Nullable: never
  /// forced.
  final String? runningExperience;

  /// Persisted as one of `ExperienceLevel`'s storage keys. Nullable: never
  /// forced.
  final String? strengthExperience;

  /// Comma-separated `Weekday.toStorage()` keys (see
  /// `core/domain/weekday.dart`). Empty string when none chosen — same CSV
  /// convention as `daily_checkins.symptoms`/`flare_events.symptoms`, and
  /// `NOT NULL DEFAULT ''` (rather than nullable) for the same reason: "no
  /// training days chosen" and "not yet asked" both read the same way here,
  /// which is fine since this field is purely a preference with no
  /// tri-state meaning to preserve.
  final String trainingDays;

  /// UTC milliseconds since epoch.
  final int createdAt;

  /// UTC milliseconds since epoch.
  final int updatedAt;

  /// UTC milliseconds since epoch; null while the row is live. Soft-delete
  /// marker per ADR 004 — rows are never hard-deleted locally so deletions
  /// can propagate through sync.
  final int? deletedAt;

  /// One of `'local'`, `'pending'`, `'synced'` (outbox/sync status; see
  /// ADR 004). Defaults to `'local'` for rows created before any backend
  /// exists.
  final String syncStatus;
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.unitSystem,
    this.weeklyActivityGoal,
    this.dateOfBirth,
    this.heightCm,
    this.weightKg,
    this.fitnessGoal,
    this.runningExperience,
    this.strengthExperience,
    required this.trainingDays,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['unit_system'] = Variable<String>(unitSystem);
    if (!nullToAbsent || weeklyActivityGoal != null) {
      map['weekly_activity_goal'] = Variable<int>(weeklyActivityGoal);
    }
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<String>(dateOfBirth);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || fitnessGoal != null) {
      map['fitness_goal'] = Variable<String>(fitnessGoal);
    }
    if (!nullToAbsent || runningExperience != null) {
      map['running_experience'] = Variable<String>(runningExperience);
    }
    if (!nullToAbsent || strengthExperience != null) {
      map['strength_experience'] = Variable<String>(strengthExperience);
    }
    map['training_days'] = Variable<String>(trainingDays);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      displayName: Value(displayName),
      unitSystem: Value(unitSystem),
      weeklyActivityGoal: weeklyActivityGoal == null && nullToAbsent
          ? const Value.absent()
          : Value(weeklyActivityGoal),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      fitnessGoal: fitnessGoal == null && nullToAbsent
          ? const Value.absent()
          : Value(fitnessGoal),
      runningExperience: runningExperience == null && nullToAbsent
          ? const Value.absent()
          : Value(runningExperience),
      strengthExperience: strengthExperience == null && nullToAbsent
          ? const Value.absent()
          : Value(strengthExperience),
      trainingDays: Value(trainingDays),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      unitSystem: serializer.fromJson<String>(json['unitSystem']),
      weeklyActivityGoal: serializer.fromJson<int?>(json['weeklyActivityGoal']),
      dateOfBirth: serializer.fromJson<String?>(json['dateOfBirth']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      fitnessGoal: serializer.fromJson<String?>(json['fitnessGoal']),
      runningExperience: serializer.fromJson<String?>(
        json['runningExperience'],
      ),
      strengthExperience: serializer.fromJson<String?>(
        json['strengthExperience'],
      ),
      trainingDays: serializer.fromJson<String>(json['trainingDays']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'unitSystem': serializer.toJson<String>(unitSystem),
      'weeklyActivityGoal': serializer.toJson<int?>(weeklyActivityGoal),
      'dateOfBirth': serializer.toJson<String?>(dateOfBirth),
      'heightCm': serializer.toJson<double?>(heightCm),
      'weightKg': serializer.toJson<double?>(weightKg),
      'fitnessGoal': serializer.toJson<String?>(fitnessGoal),
      'runningExperience': serializer.toJson<String?>(runningExperience),
      'strengthExperience': serializer.toJson<String?>(strengthExperience),
      'trainingDays': serializer.toJson<String>(trainingDays),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? unitSystem,
    Value<int?> weeklyActivityGoal = const Value.absent(),
    Value<String?> dateOfBirth = const Value.absent(),
    Value<double?> heightCm = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
    Value<String?> fitnessGoal = const Value.absent(),
    Value<String?> runningExperience = const Value.absent(),
    Value<String?> strengthExperience = const Value.absent(),
    String? trainingDays,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? syncStatus,
  }) => UserProfile(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    unitSystem: unitSystem ?? this.unitSystem,
    weeklyActivityGoal: weeklyActivityGoal.present
        ? weeklyActivityGoal.value
        : this.weeklyActivityGoal,
    dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    fitnessGoal: fitnessGoal.present ? fitnessGoal.value : this.fitnessGoal,
    runningExperience: runningExperience.present
        ? runningExperience.value
        : this.runningExperience,
    strengthExperience: strengthExperience.present
        ? strengthExperience.value
        : this.strengthExperience,
    trainingDays: trainingDays ?? this.trainingDays,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      unitSystem: data.unitSystem.present
          ? data.unitSystem.value
          : this.unitSystem,
      weeklyActivityGoal: data.weeklyActivityGoal.present
          ? data.weeklyActivityGoal.value
          : this.weeklyActivityGoal,
      dateOfBirth: data.dateOfBirth.present
          ? data.dateOfBirth.value
          : this.dateOfBirth,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      fitnessGoal: data.fitnessGoal.present
          ? data.fitnessGoal.value
          : this.fitnessGoal,
      runningExperience: data.runningExperience.present
          ? data.runningExperience.value
          : this.runningExperience,
      strengthExperience: data.strengthExperience.present
          ? data.strengthExperience.value
          : this.strengthExperience,
      trainingDays: data.trainingDays.present
          ? data.trainingDays.value
          : this.trainingDays,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('unitSystem: $unitSystem, ')
          ..write('weeklyActivityGoal: $weeklyActivityGoal, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('fitnessGoal: $fitnessGoal, ')
          ..write('runningExperience: $runningExperience, ')
          ..write('strengthExperience: $strengthExperience, ')
          ..write('trainingDays: $trainingDays, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    unitSystem,
    weeklyActivityGoal,
    dateOfBirth,
    heightCm,
    weightKg,
    fitnessGoal,
    runningExperience,
    strengthExperience,
    trainingDays,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.unitSystem == this.unitSystem &&
          other.weeklyActivityGoal == this.weeklyActivityGoal &&
          other.dateOfBirth == this.dateOfBirth &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.fitnessGoal == this.fitnessGoal &&
          other.runningExperience == this.runningExperience &&
          other.strengthExperience == this.strengthExperience &&
          other.trainingDays == this.trainingDays &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String> unitSystem;
  final Value<int?> weeklyActivityGoal;
  final Value<String?> dateOfBirth;
  final Value<double?> heightCm;
  final Value<double?> weightKg;
  final Value<String?> fitnessGoal;
  final Value<String?> runningExperience;
  final Value<String?> strengthExperience;
  final Value<String> trainingDays;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.unitSystem = const Value.absent(),
    this.weeklyActivityGoal = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.fitnessGoal = const Value.absent(),
    this.runningExperience = const Value.absent(),
    this.strengthExperience = const Value.absent(),
    this.trainingDays = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    required String displayName,
    required String unitSystem,
    this.weeklyActivityGoal = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.fitnessGoal = const Value.absent(),
    this.runningExperience = const Value.absent(),
    this.strengthExperience = const Value.absent(),
    this.trainingDays = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       unitSystem = Value(unitSystem),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserProfile> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? unitSystem,
    Expression<int>? weeklyActivityGoal,
    Expression<String>? dateOfBirth,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<String>? fitnessGoal,
    Expression<String>? runningExperience,
    Expression<String>? strengthExperience,
    Expression<String>? trainingDays,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (unitSystem != null) 'unit_system': unitSystem,
      if (weeklyActivityGoal != null)
        'weekly_activity_goal': weeklyActivityGoal,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (fitnessGoal != null) 'fitness_goal': fitnessGoal,
      if (runningExperience != null) 'running_experience': runningExperience,
      if (strengthExperience != null) 'strength_experience': strengthExperience,
      if (trainingDays != null) 'training_days': trainingDays,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<String>? unitSystem,
    Value<int?>? weeklyActivityGoal,
    Value<String?>? dateOfBirth,
    Value<double?>? heightCm,
    Value<double?>? weightKg,
    Value<String?>? fitnessGoal,
    Value<String?>? runningExperience,
    Value<String?>? strengthExperience,
    Value<String>? trainingDays,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      unitSystem: unitSystem ?? this.unitSystem,
      weeklyActivityGoal: weeklyActivityGoal ?? this.weeklyActivityGoal,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      runningExperience: runningExperience ?? this.runningExperience,
      strengthExperience: strengthExperience ?? this.strengthExperience,
      trainingDays: trainingDays ?? this.trainingDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (unitSystem.present) {
      map['unit_system'] = Variable<String>(unitSystem.value);
    }
    if (weeklyActivityGoal.present) {
      map['weekly_activity_goal'] = Variable<int>(weeklyActivityGoal.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<String>(dateOfBirth.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (fitnessGoal.present) {
      map['fitness_goal'] = Variable<String>(fitnessGoal.value);
    }
    if (runningExperience.present) {
      map['running_experience'] = Variable<String>(runningExperience.value);
    }
    if (strengthExperience.present) {
      map['strength_experience'] = Variable<String>(strengthExperience.value);
    }
    if (trainingDays.present) {
      map['training_days'] = Variable<String>(trainingDays.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('unitSystem: $unitSystem, ')
          ..write('weeklyActivityGoal: $weeklyActivityGoal, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('fitnessGoal: $fitnessGoal, ')
          ..write('runningExperience: $runningExperience, ')
          ..write('strengthExperience: $strengthExperience, ')
          ..write('trainingDays: $trainingDays, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, Activity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityTypeMeta = const VerificationMeta(
    'activityType',
  );
  @override
  late final GeneratedColumn<String> activityType = GeneratedColumn<String>(
    'activity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _movingTimeMsMeta = const VerificationMeta(
    'movingTimeMs',
  );
  @override
  late final GeneratedColumn<int> movingTimeMs = GeneratedColumn<int>(
    'moving_time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elapsedTimeMsMeta = const VerificationMeta(
    'elapsedTimeMs',
  );
  @override
  late final GeneratedColumn<int> elapsedTimeMs = GeneratedColumn<int>(
    'elapsed_time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elevationGainMetersMeta =
      const VerificationMeta('elevationGainMeters');
  @override
  late final GeneratedColumn<double> elevationGainMeters =
      GeneratedColumn<double>(
        'elevation_gain_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _avgHeartRateMeta = const VerificationMeta(
    'avgHeartRate',
  );
  @override
  late final GeneratedColumn<int> avgHeartRate = GeneratedColumn<int>(
    'avg_heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routeIdMeta = const VerificationMeta(
    'routeId',
  );
  @override
  late final GeneratedColumn<String> routeId = GeneratedColumn<String>(
    'route_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    activityType,
    title,
    notes,
    startedAt,
    movingTimeMs,
    elapsedTimeMs,
    distanceMeters,
    elevationGainMeters,
    avgHeartRate,
    source,
    routeId,
    metadataJson,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Activity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('activity_type')) {
      context.handle(
        _activityTypeMeta,
        activityType.isAcceptableOrUnknown(
          data['activity_type']!,
          _activityTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activityTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('moving_time_ms')) {
      context.handle(
        _movingTimeMsMeta,
        movingTimeMs.isAcceptableOrUnknown(
          data['moving_time_ms']!,
          _movingTimeMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_movingTimeMsMeta);
    }
    if (data.containsKey('elapsed_time_ms')) {
      context.handle(
        _elapsedTimeMsMeta,
        elapsedTimeMs.isAcceptableOrUnknown(
          data['elapsed_time_ms']!,
          _elapsedTimeMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_elapsedTimeMsMeta);
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distanceMetersMeta);
    }
    if (data.containsKey('elevation_gain_meters')) {
      context.handle(
        _elevationGainMetersMeta,
        elevationGainMeters.isAcceptableOrUnknown(
          data['elevation_gain_meters']!,
          _elevationGainMetersMeta,
        ),
      );
    }
    if (data.containsKey('avg_heart_rate')) {
      context.handle(
        _avgHeartRateMeta,
        avgHeartRate.isAcceptableOrUnknown(
          data['avg_heart_rate']!,
          _avgHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('route_id')) {
      context.handle(
        _routeIdMeta,
        routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Activity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Activity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      activityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      movingTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}moving_time_ms'],
      )!,
      elapsedTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_time_ms'],
      )!,
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      )!,
      elevationGainMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_gain_meters'],
      ),
      avgHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_heart_rate'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      routeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_id'],
      ),
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }
}

class Activity extends DataClass implements Insertable<Activity> {
  /// Client-generated UUIDv7.
  final String id;

  /// Persisted as `'run'`, `'walk'`, `'hike'`, or `'ride'` (see
  /// `features/activity/domain/activity.dart`'s `ActivityType`).
  final String activityType;
  final String title;
  final String? notes;

  /// UTC milliseconds since epoch.
  final int startedAt;

  /// Time actually moving, in milliseconds. Equal to [elapsedTimeMs] for
  /// manually-logged activities, which don't distinguish paused time.
  final int movingTimeMs;

  /// Total elapsed time (including any stopped time), in milliseconds.
  final int elapsedTimeMs;
  final double distanceMeters;
  final double? elevationGainMeters;
  final int? avgHeartRate;

  /// Persisted as `'manual'` or `'recorded'` (see
  /// `features/activity/domain/activity.dart`'s `ActivitySource`).
  final String source;

  /// The saved route (`routes.id`) this activity was started from, if any
  /// (v8; see `core/db/tables/routes.dart`). Plain nullable TEXT, no FK
  /// constraint — the route may be soft- or hard-deleted independently of
  /// the activity, and the activity must survive that.
  final String? routeId;

  /// Structured JSON metadata for type-specific workouts (v15; e.g. Strength
  /// sets/reps/rest, HIIT intervals, Yoga/Pilates mindfulness, Swim laps).
  final String? metadataJson;

  /// UTC milliseconds since epoch.
  final int createdAt;

  /// UTC milliseconds since epoch.
  final int updatedAt;

  /// UTC milliseconds since epoch; null while the row is live. Soft-delete
  /// marker per ADR 004.
  final int? deletedAt;

  /// One of `'local'`, `'pending'`, `'synced'` (outbox/sync status; see
  /// ADR 004). Defaults to `'local'` for rows created before any backend
  /// exists.
  final String syncStatus;
  const Activity({
    required this.id,
    required this.activityType,
    required this.title,
    this.notes,
    required this.startedAt,
    required this.movingTimeMs,
    required this.elapsedTimeMs,
    required this.distanceMeters,
    this.elevationGainMeters,
    this.avgHeartRate,
    required this.source,
    this.routeId,
    this.metadataJson,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['activity_type'] = Variable<String>(activityType);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['started_at'] = Variable<int>(startedAt);
    map['moving_time_ms'] = Variable<int>(movingTimeMs);
    map['elapsed_time_ms'] = Variable<int>(elapsedTimeMs);
    map['distance_meters'] = Variable<double>(distanceMeters);
    if (!nullToAbsent || elevationGainMeters != null) {
      map['elevation_gain_meters'] = Variable<double>(elevationGainMeters);
    }
    if (!nullToAbsent || avgHeartRate != null) {
      map['avg_heart_rate'] = Variable<int>(avgHeartRate);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || routeId != null) {
      map['route_id'] = Variable<String>(routeId);
    }
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      activityType: Value(activityType),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      startedAt: Value(startedAt),
      movingTimeMs: Value(movingTimeMs),
      elapsedTimeMs: Value(elapsedTimeMs),
      distanceMeters: Value(distanceMeters),
      elevationGainMeters: elevationGainMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(elevationGainMeters),
      avgHeartRate: avgHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(avgHeartRate),
      source: Value(source),
      routeId: routeId == null && nullToAbsent
          ? const Value.absent()
          : Value(routeId),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Activity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Activity(
      id: serializer.fromJson<String>(json['id']),
      activityType: serializer.fromJson<String>(json['activityType']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      movingTimeMs: serializer.fromJson<int>(json['movingTimeMs']),
      elapsedTimeMs: serializer.fromJson<int>(json['elapsedTimeMs']),
      distanceMeters: serializer.fromJson<double>(json['distanceMeters']),
      elevationGainMeters: serializer.fromJson<double?>(
        json['elevationGainMeters'],
      ),
      avgHeartRate: serializer.fromJson<int?>(json['avgHeartRate']),
      source: serializer.fromJson<String>(json['source']),
      routeId: serializer.fromJson<String?>(json['routeId']),
      metadataJson: serializer.fromJson<String?>(json['metadataJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'activityType': serializer.toJson<String>(activityType),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'startedAt': serializer.toJson<int>(startedAt),
      'movingTimeMs': serializer.toJson<int>(movingTimeMs),
      'elapsedTimeMs': serializer.toJson<int>(elapsedTimeMs),
      'distanceMeters': serializer.toJson<double>(distanceMeters),
      'elevationGainMeters': serializer.toJson<double?>(elevationGainMeters),
      'avgHeartRate': serializer.toJson<int?>(avgHeartRate),
      'source': serializer.toJson<String>(source),
      'routeId': serializer.toJson<String?>(routeId),
      'metadataJson': serializer.toJson<String?>(metadataJson),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Activity copyWith({
    String? id,
    String? activityType,
    String? title,
    Value<String?> notes = const Value.absent(),
    int? startedAt,
    int? movingTimeMs,
    int? elapsedTimeMs,
    double? distanceMeters,
    Value<double?> elevationGainMeters = const Value.absent(),
    Value<int?> avgHeartRate = const Value.absent(),
    String? source,
    Value<String?> routeId = const Value.absent(),
    Value<String?> metadataJson = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? syncStatus,
  }) => Activity(
    id: id ?? this.id,
    activityType: activityType ?? this.activityType,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    startedAt: startedAt ?? this.startedAt,
    movingTimeMs: movingTimeMs ?? this.movingTimeMs,
    elapsedTimeMs: elapsedTimeMs ?? this.elapsedTimeMs,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    elevationGainMeters: elevationGainMeters.present
        ? elevationGainMeters.value
        : this.elevationGainMeters,
    avgHeartRate: avgHeartRate.present ? avgHeartRate.value : this.avgHeartRate,
    source: source ?? this.source,
    routeId: routeId.present ? routeId.value : this.routeId,
    metadataJson: metadataJson.present ? metadataJson.value : this.metadataJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Activity copyWithCompanion(ActivitiesCompanion data) {
    return Activity(
      id: data.id.present ? data.id.value : this.id,
      activityType: data.activityType.present
          ? data.activityType.value
          : this.activityType,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      movingTimeMs: data.movingTimeMs.present
          ? data.movingTimeMs.value
          : this.movingTimeMs,
      elapsedTimeMs: data.elapsedTimeMs.present
          ? data.elapsedTimeMs.value
          : this.elapsedTimeMs,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      elevationGainMeters: data.elevationGainMeters.present
          ? data.elevationGainMeters.value
          : this.elevationGainMeters,
      avgHeartRate: data.avgHeartRate.present
          ? data.avgHeartRate.value
          : this.avgHeartRate,
      source: data.source.present ? data.source.value : this.source,
      routeId: data.routeId.present ? data.routeId.value : this.routeId,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Activity(')
          ..write('id: $id, ')
          ..write('activityType: $activityType, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('startedAt: $startedAt, ')
          ..write('movingTimeMs: $movingTimeMs, ')
          ..write('elapsedTimeMs: $elapsedTimeMs, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('elevationGainMeters: $elevationGainMeters, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('source: $source, ')
          ..write('routeId: $routeId, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    activityType,
    title,
    notes,
    startedAt,
    movingTimeMs,
    elapsedTimeMs,
    distanceMeters,
    elevationGainMeters,
    avgHeartRate,
    source,
    routeId,
    metadataJson,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Activity &&
          other.id == this.id &&
          other.activityType == this.activityType &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.startedAt == this.startedAt &&
          other.movingTimeMs == this.movingTimeMs &&
          other.elapsedTimeMs == this.elapsedTimeMs &&
          other.distanceMeters == this.distanceMeters &&
          other.elevationGainMeters == this.elevationGainMeters &&
          other.avgHeartRate == this.avgHeartRate &&
          other.source == this.source &&
          other.routeId == this.routeId &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus);
}

class ActivitiesCompanion extends UpdateCompanion<Activity> {
  final Value<String> id;
  final Value<String> activityType;
  final Value<String> title;
  final Value<String?> notes;
  final Value<int> startedAt;
  final Value<int> movingTimeMs;
  final Value<int> elapsedTimeMs;
  final Value<double> distanceMeters;
  final Value<double?> elevationGainMeters;
  final Value<int?> avgHeartRate;
  final Value<String> source;
  final Value<String?> routeId;
  final Value<String?> metadataJson;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.activityType = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.movingTimeMs = const Value.absent(),
    this.elapsedTimeMs = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.elevationGainMeters = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    this.source = const Value.absent(),
    this.routeId = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    required String id,
    required String activityType,
    required String title,
    this.notes = const Value.absent(),
    required int startedAt,
    required int movingTimeMs,
    required int elapsedTimeMs,
    required double distanceMeters,
    this.elevationGainMeters = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    required String source,
    this.routeId = const Value.absent(),
    this.metadataJson = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       activityType = Value(activityType),
       title = Value(title),
       startedAt = Value(startedAt),
       movingTimeMs = Value(movingTimeMs),
       elapsedTimeMs = Value(elapsedTimeMs),
       distanceMeters = Value(distanceMeters),
       source = Value(source),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Activity> custom({
    Expression<String>? id,
    Expression<String>? activityType,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<int>? startedAt,
    Expression<int>? movingTimeMs,
    Expression<int>? elapsedTimeMs,
    Expression<double>? distanceMeters,
    Expression<double>? elevationGainMeters,
    Expression<int>? avgHeartRate,
    Expression<String>? source,
    Expression<String>? routeId,
    Expression<String>? metadataJson,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityType != null) 'activity_type': activityType,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (startedAt != null) 'started_at': startedAt,
      if (movingTimeMs != null) 'moving_time_ms': movingTimeMs,
      if (elapsedTimeMs != null) 'elapsed_time_ms': elapsedTimeMs,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (elevationGainMeters != null)
        'elevation_gain_meters': elevationGainMeters,
      if (avgHeartRate != null) 'avg_heart_rate': avgHeartRate,
      if (source != null) 'source': source,
      if (routeId != null) 'route_id': routeId,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? activityType,
    Value<String>? title,
    Value<String?>? notes,
    Value<int>? startedAt,
    Value<int>? movingTimeMs,
    Value<int>? elapsedTimeMs,
    Value<double>? distanceMeters,
    Value<double?>? elevationGainMeters,
    Value<int?>? avgHeartRate,
    Value<String>? source,
    Value<String?>? routeId,
    Value<String?>? metadataJson,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      activityType: activityType ?? this.activityType,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      startedAt: startedAt ?? this.startedAt,
      movingTimeMs: movingTimeMs ?? this.movingTimeMs,
      elapsedTimeMs: elapsedTimeMs ?? this.elapsedTimeMs,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      source: source ?? this.source,
      routeId: routeId ?? this.routeId,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (activityType.present) {
      map['activity_type'] = Variable<String>(activityType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (movingTimeMs.present) {
      map['moving_time_ms'] = Variable<int>(movingTimeMs.value);
    }
    if (elapsedTimeMs.present) {
      map['elapsed_time_ms'] = Variable<int>(elapsedTimeMs.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (elevationGainMeters.present) {
      map['elevation_gain_meters'] = Variable<double>(
        elevationGainMeters.value,
      );
    }
    if (avgHeartRate.present) {
      map['avg_heart_rate'] = Variable<int>(avgHeartRate.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (routeId.present) {
      map['route_id'] = Variable<String>(routeId.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('activityType: $activityType, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('startedAt: $startedAt, ')
          ..write('movingTimeMs: $movingTimeMs, ')
          ..write('elapsedTimeMs: $elapsedTimeMs, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('elevationGainMeters: $elevationGainMeters, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('source: $source, ')
          ..write('routeId: $routeId, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivitySamplesTable extends ActivitySamples
    with TableInfo<$ActivitySamplesTable, ActivitySample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitySamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityIdMeta = const VerificationMeta(
    'activityId',
  );
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
    'activity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES activities (id)',
    ),
  );
  static const VerificationMeta _timestampMsMeta = const VerificationMeta(
    'timestampMs',
  );
  @override
  late final GeneratedColumn<int> timestampMs = GeneratedColumn<int>(
    'timestamp_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elevationMetersMeta = const VerificationMeta(
    'elevationMeters',
  );
  @override
  late final GeneratedColumn<double> elevationMeters = GeneratedColumn<double>(
    'elevation_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _horizontalAccuracyMetersMeta =
      const VerificationMeta('horizontalAccuracyMeters');
  @override
  late final GeneratedColumn<double> horizontalAccuracyMeters =
      GeneratedColumn<double>(
        'horizontal_accuracy_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _heartRateMeta = const VerificationMeta(
    'heartRate',
  );
  @override
  late final GeneratedColumn<int> heartRate = GeneratedColumn<int>(
    'heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPausedMeta = const VerificationMeta(
    'isPaused',
  );
  @override
  late final GeneratedColumn<bool> isPaused = GeneratedColumn<bool>(
    'is_paused',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_paused" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    activityId,
    timestampMs,
    latitude,
    longitude,
    elevationMeters,
    horizontalAccuracyMeters,
    heartRate,
    isPaused,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_samples';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivitySample> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('timestamp_ms')) {
      context.handle(
        _timestampMsMeta,
        timestampMs.isAcceptableOrUnknown(
          data['timestamp_ms']!,
          _timestampMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampMsMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('elevation_meters')) {
      context.handle(
        _elevationMetersMeta,
        elevationMeters.isAcceptableOrUnknown(
          data['elevation_meters']!,
          _elevationMetersMeta,
        ),
      );
    }
    if (data.containsKey('horizontal_accuracy_meters')) {
      context.handle(
        _horizontalAccuracyMetersMeta,
        horizontalAccuracyMeters.isAcceptableOrUnknown(
          data['horizontal_accuracy_meters']!,
          _horizontalAccuracyMetersMeta,
        ),
      );
    }
    if (data.containsKey('heart_rate')) {
      context.handle(
        _heartRateMeta,
        heartRate.isAcceptableOrUnknown(data['heart_rate']!, _heartRateMeta),
      );
    }
    if (data.containsKey('is_paused')) {
      context.handle(
        _isPausedMeta,
        isPaused.isAcceptableOrUnknown(data['is_paused']!, _isPausedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivitySample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivitySample(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      activityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_id'],
      )!,
      timestampMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp_ms'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      elevationMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_meters'],
      ),
      horizontalAccuracyMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}horizontal_accuracy_meters'],
      ),
      heartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}heart_rate'],
      ),
      isPaused: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_paused'],
      )!,
    );
  }

  @override
  $ActivitySamplesTable createAlias(String alias) {
    return $ActivitySamplesTable(attachedDatabase, alias);
  }
}

class ActivitySample extends DataClass implements Insertable<ActivitySample> {
  /// Client-generated UUIDv7.
  final String id;
  final String activityId;

  /// UTC milliseconds since epoch.
  final int timestampMs;
  final double latitude;
  final double longitude;
  final double? elevationMeters;
  final double? horizontalAccuracyMeters;
  final int? heartRate;

  /// Whether this sample was accepted while the recording was paused
  /// (manually or automatically) — see
  /// `features/activity/domain/recording_session.dart`'s `RecordedFix`.
  /// Added in schema v4; every sample persisted before that migration has
  /// this default (`false`), which is the correct value for pre-v4 data —
  /// wave C3/D recordings predate pause-aware sample tagging entirely, so
  /// there is nothing to backfill (see `domain/track_analysis.dart`'s "old
  /// data" doc note).
  final bool isPaused;
  const ActivitySample({
    required this.id,
    required this.activityId,
    required this.timestampMs,
    required this.latitude,
    required this.longitude,
    this.elevationMeters,
    this.horizontalAccuracyMeters,
    this.heartRate,
    required this.isPaused,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['activity_id'] = Variable<String>(activityId);
    map['timestamp_ms'] = Variable<int>(timestampMs);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || elevationMeters != null) {
      map['elevation_meters'] = Variable<double>(elevationMeters);
    }
    if (!nullToAbsent || horizontalAccuracyMeters != null) {
      map['horizontal_accuracy_meters'] = Variable<double>(
        horizontalAccuracyMeters,
      );
    }
    if (!nullToAbsent || heartRate != null) {
      map['heart_rate'] = Variable<int>(heartRate);
    }
    map['is_paused'] = Variable<bool>(isPaused);
    return map;
  }

  ActivitySamplesCompanion toCompanion(bool nullToAbsent) {
    return ActivitySamplesCompanion(
      id: Value(id),
      activityId: Value(activityId),
      timestampMs: Value(timestampMs),
      latitude: Value(latitude),
      longitude: Value(longitude),
      elevationMeters: elevationMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(elevationMeters),
      horizontalAccuracyMeters: horizontalAccuracyMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(horizontalAccuracyMeters),
      heartRate: heartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(heartRate),
      isPaused: Value(isPaused),
    );
  }

  factory ActivitySample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivitySample(
      id: serializer.fromJson<String>(json['id']),
      activityId: serializer.fromJson<String>(json['activityId']),
      timestampMs: serializer.fromJson<int>(json['timestampMs']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      elevationMeters: serializer.fromJson<double?>(json['elevationMeters']),
      horizontalAccuracyMeters: serializer.fromJson<double?>(
        json['horizontalAccuracyMeters'],
      ),
      heartRate: serializer.fromJson<int?>(json['heartRate']),
      isPaused: serializer.fromJson<bool>(json['isPaused']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'activityId': serializer.toJson<String>(activityId),
      'timestampMs': serializer.toJson<int>(timestampMs),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'elevationMeters': serializer.toJson<double?>(elevationMeters),
      'horizontalAccuracyMeters': serializer.toJson<double?>(
        horizontalAccuracyMeters,
      ),
      'heartRate': serializer.toJson<int?>(heartRate),
      'isPaused': serializer.toJson<bool>(isPaused),
    };
  }

  ActivitySample copyWith({
    String? id,
    String? activityId,
    int? timestampMs,
    double? latitude,
    double? longitude,
    Value<double?> elevationMeters = const Value.absent(),
    Value<double?> horizontalAccuracyMeters = const Value.absent(),
    Value<int?> heartRate = const Value.absent(),
    bool? isPaused,
  }) => ActivitySample(
    id: id ?? this.id,
    activityId: activityId ?? this.activityId,
    timestampMs: timestampMs ?? this.timestampMs,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    elevationMeters: elevationMeters.present
        ? elevationMeters.value
        : this.elevationMeters,
    horizontalAccuracyMeters: horizontalAccuracyMeters.present
        ? horizontalAccuracyMeters.value
        : this.horizontalAccuracyMeters,
    heartRate: heartRate.present ? heartRate.value : this.heartRate,
    isPaused: isPaused ?? this.isPaused,
  );
  ActivitySample copyWithCompanion(ActivitySamplesCompanion data) {
    return ActivitySample(
      id: data.id.present ? data.id.value : this.id,
      activityId: data.activityId.present
          ? data.activityId.value
          : this.activityId,
      timestampMs: data.timestampMs.present
          ? data.timestampMs.value
          : this.timestampMs,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      elevationMeters: data.elevationMeters.present
          ? data.elevationMeters.value
          : this.elevationMeters,
      horizontalAccuracyMeters: data.horizontalAccuracyMeters.present
          ? data.horizontalAccuracyMeters.value
          : this.horizontalAccuracyMeters,
      heartRate: data.heartRate.present ? data.heartRate.value : this.heartRate,
      isPaused: data.isPaused.present ? data.isPaused.value : this.isPaused,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivitySample(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('timestampMs: $timestampMs, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('elevationMeters: $elevationMeters, ')
          ..write('horizontalAccuracyMeters: $horizontalAccuracyMeters, ')
          ..write('heartRate: $heartRate, ')
          ..write('isPaused: $isPaused')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    activityId,
    timestampMs,
    latitude,
    longitude,
    elevationMeters,
    horizontalAccuracyMeters,
    heartRate,
    isPaused,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivitySample &&
          other.id == this.id &&
          other.activityId == this.activityId &&
          other.timestampMs == this.timestampMs &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.elevationMeters == this.elevationMeters &&
          other.horizontalAccuracyMeters == this.horizontalAccuracyMeters &&
          other.heartRate == this.heartRate &&
          other.isPaused == this.isPaused);
}

class ActivitySamplesCompanion extends UpdateCompanion<ActivitySample> {
  final Value<String> id;
  final Value<String> activityId;
  final Value<int> timestampMs;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double?> elevationMeters;
  final Value<double?> horizontalAccuracyMeters;
  final Value<int?> heartRate;
  final Value<bool> isPaused;
  final Value<int> rowid;
  const ActivitySamplesCompanion({
    this.id = const Value.absent(),
    this.activityId = const Value.absent(),
    this.timestampMs = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.elevationMeters = const Value.absent(),
    this.horizontalAccuracyMeters = const Value.absent(),
    this.heartRate = const Value.absent(),
    this.isPaused = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivitySamplesCompanion.insert({
    required String id,
    required String activityId,
    required int timestampMs,
    required double latitude,
    required double longitude,
    this.elevationMeters = const Value.absent(),
    this.horizontalAccuracyMeters = const Value.absent(),
    this.heartRate = const Value.absent(),
    this.isPaused = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       activityId = Value(activityId),
       timestampMs = Value(timestampMs),
       latitude = Value(latitude),
       longitude = Value(longitude);
  static Insertable<ActivitySample> custom({
    Expression<String>? id,
    Expression<String>? activityId,
    Expression<int>? timestampMs,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? elevationMeters,
    Expression<double>? horizontalAccuracyMeters,
    Expression<int>? heartRate,
    Expression<bool>? isPaused,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityId != null) 'activity_id': activityId,
      if (timestampMs != null) 'timestamp_ms': timestampMs,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (elevationMeters != null) 'elevation_meters': elevationMeters,
      if (horizontalAccuracyMeters != null)
        'horizontal_accuracy_meters': horizontalAccuracyMeters,
      if (heartRate != null) 'heart_rate': heartRate,
      if (isPaused != null) 'is_paused': isPaused,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivitySamplesCompanion copyWith({
    Value<String>? id,
    Value<String>? activityId,
    Value<int>? timestampMs,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double?>? elevationMeters,
    Value<double?>? horizontalAccuracyMeters,
    Value<int?>? heartRate,
    Value<bool>? isPaused,
    Value<int>? rowid,
  }) {
    return ActivitySamplesCompanion(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      timestampMs: timestampMs ?? this.timestampMs,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      elevationMeters: elevationMeters ?? this.elevationMeters,
      horizontalAccuracyMeters:
          horizontalAccuracyMeters ?? this.horizontalAccuracyMeters,
      heartRate: heartRate ?? this.heartRate,
      isPaused: isPaused ?? this.isPaused,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (timestampMs.present) {
      map['timestamp_ms'] = Variable<int>(timestampMs.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (elevationMeters.present) {
      map['elevation_meters'] = Variable<double>(elevationMeters.value);
    }
    if (horizontalAccuracyMeters.present) {
      map['horizontal_accuracy_meters'] = Variable<double>(
        horizontalAccuracyMeters.value,
      );
    }
    if (heartRate.present) {
      map['heart_rate'] = Variable<int>(heartRate.value);
    }
    if (isPaused.present) {
      map['is_paused'] = Variable<bool>(isPaused.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitySamplesCompanion(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('timestampMs: $timestampMs, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('elevationMeters: $elevationMeters, ')
          ..write('horizontalAccuracyMeters: $horizontalAccuracyMeters, ')
          ..write('heartRate: $heartRate, ')
          ..write('isPaused: $isPaused, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyCheckinsTable extends DailyCheckins
    with TableInfo<$DailyCheckinsTable, DailyCheckin> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyCheckinsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _energyMeta = const VerificationMeta('energy');
  @override
  late final GeneratedColumn<int> energy = GeneratedColumn<int>(
    'energy',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sleepMeta = const VerificationMeta('sleep');
  @override
  late final GeneratedColumn<int> sleep = GeneratedColumn<int>(
    'sleep',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sorenessMeta = const VerificationMeta(
    'soreness',
  );
  @override
  late final GeneratedColumn<int> soreness = GeneratedColumn<int>(
    'soreness',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stressMeta = const VerificationMeta('stress');
  @override
  late final GeneratedColumn<int> stress = GeneratedColumn<int>(
    'stress',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _painMeta = const VerificationMeta('pain');
  @override
  late final GeneratedColumn<int> pain = GeneratedColumn<int>(
    'pain',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _symptomsMeta = const VerificationMeta(
    'symptoms',
  );
  @override
  late final GeneratedColumn<String> symptoms = GeneratedColumn<String>(
    'symptoms',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    energy,
    sleep,
    soreness,
    stress,
    pain,
    symptoms,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_checkins';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyCheckin> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('energy')) {
      context.handle(
        _energyMeta,
        energy.isAcceptableOrUnknown(data['energy']!, _energyMeta),
      );
    }
    if (data.containsKey('sleep')) {
      context.handle(
        _sleepMeta,
        sleep.isAcceptableOrUnknown(data['sleep']!, _sleepMeta),
      );
    }
    if (data.containsKey('soreness')) {
      context.handle(
        _sorenessMeta,
        soreness.isAcceptableOrUnknown(data['soreness']!, _sorenessMeta),
      );
    }
    if (data.containsKey('stress')) {
      context.handle(
        _stressMeta,
        stress.isAcceptableOrUnknown(data['stress']!, _stressMeta),
      );
    }
    if (data.containsKey('pain')) {
      context.handle(
        _painMeta,
        pain.isAcceptableOrUnknown(data['pain']!, _painMeta),
      );
    }
    if (data.containsKey('symptoms')) {
      context.handle(
        _symptomsMeta,
        symptoms.isAcceptableOrUnknown(data['symptoms']!, _symptomsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyCheckin map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyCheckin(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      energy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energy'],
      ),
      sleep: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sleep'],
      ),
      soreness: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}soreness'],
      ),
      stress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stress'],
      ),
      pain: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pain'],
      ),
      symptoms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symptoms'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $DailyCheckinsTable createAlias(String alias) {
    return $DailyCheckinsTable(attachedDatabase, alias);
  }
}

class DailyCheckin extends DataClass implements Insertable<DailyCheckin> {
  /// Client-generated UUIDv7.
  final String id;

  /// ISO-8601 date string (`YYYY-MM-DD`), user-local calendar day. Unique —
  /// at most one check-in per day.
  final String day;

  /// 1-5, higher is better. `null` when not answered.
  final int? energy;

  /// 1-5, higher is better. `null` when not answered.
  final int? sleep;

  /// 1-5, higher is worse (more soreness). `null` when not answered.
  final int? soreness;

  /// 1-5, higher is worse (more stress). `null` when not answered.
  final int? stress;

  /// 1-5, higher is worse (more pain). `null` when not answered.
  final int? pain;

  /// Comma-separated `SymptomType.toStorage()` keys. Empty string when no
  /// symptoms were logged.
  final String symptoms;

  /// UTC milliseconds since epoch.
  final int createdAt;

  /// UTC milliseconds since epoch.
  final int updatedAt;

  /// UTC milliseconds since epoch; null while the row is live. Kept for
  /// column-shape consistency with other tables, but
  /// `DriftWellbeingRepository.deleteCheckin` hard-deletes instead (S3: a
  /// "deleted" health row that is still forensically recoverable on-device
  /// is not deleted) — should always read `null`.
  final int? deletedAt;

  /// One of `'local'`, `'pending'`, `'synced'` (outbox/sync status; see ADR
  /// 004). Defaults to `'local'`.
  final String syncStatus;
  const DailyCheckin({
    required this.id,
    required this.day,
    this.energy,
    this.sleep,
    this.soreness,
    this.stress,
    this.pain,
    required this.symptoms,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day'] = Variable<String>(day);
    if (!nullToAbsent || energy != null) {
      map['energy'] = Variable<int>(energy);
    }
    if (!nullToAbsent || sleep != null) {
      map['sleep'] = Variable<int>(sleep);
    }
    if (!nullToAbsent || soreness != null) {
      map['soreness'] = Variable<int>(soreness);
    }
    if (!nullToAbsent || stress != null) {
      map['stress'] = Variable<int>(stress);
    }
    if (!nullToAbsent || pain != null) {
      map['pain'] = Variable<int>(pain);
    }
    map['symptoms'] = Variable<String>(symptoms);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  DailyCheckinsCompanion toCompanion(bool nullToAbsent) {
    return DailyCheckinsCompanion(
      id: Value(id),
      day: Value(day),
      energy: energy == null && nullToAbsent
          ? const Value.absent()
          : Value(energy),
      sleep: sleep == null && nullToAbsent
          ? const Value.absent()
          : Value(sleep),
      soreness: soreness == null && nullToAbsent
          ? const Value.absent()
          : Value(soreness),
      stress: stress == null && nullToAbsent
          ? const Value.absent()
          : Value(stress),
      pain: pain == null && nullToAbsent ? const Value.absent() : Value(pain),
      symptoms: Value(symptoms),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory DailyCheckin.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyCheckin(
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      energy: serializer.fromJson<int?>(json['energy']),
      sleep: serializer.fromJson<int?>(json['sleep']),
      soreness: serializer.fromJson<int?>(json['soreness']),
      stress: serializer.fromJson<int?>(json['stress']),
      pain: serializer.fromJson<int?>(json['pain']),
      symptoms: serializer.fromJson<String>(json['symptoms']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<String>(day),
      'energy': serializer.toJson<int?>(energy),
      'sleep': serializer.toJson<int?>(sleep),
      'soreness': serializer.toJson<int?>(soreness),
      'stress': serializer.toJson<int?>(stress),
      'pain': serializer.toJson<int?>(pain),
      'symptoms': serializer.toJson<String>(symptoms),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  DailyCheckin copyWith({
    String? id,
    String? day,
    Value<int?> energy = const Value.absent(),
    Value<int?> sleep = const Value.absent(),
    Value<int?> soreness = const Value.absent(),
    Value<int?> stress = const Value.absent(),
    Value<int?> pain = const Value.absent(),
    String? symptoms,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? syncStatus,
  }) => DailyCheckin(
    id: id ?? this.id,
    day: day ?? this.day,
    energy: energy.present ? energy.value : this.energy,
    sleep: sleep.present ? sleep.value : this.sleep,
    soreness: soreness.present ? soreness.value : this.soreness,
    stress: stress.present ? stress.value : this.stress,
    pain: pain.present ? pain.value : this.pain,
    symptoms: symptoms ?? this.symptoms,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  DailyCheckin copyWithCompanion(DailyCheckinsCompanion data) {
    return DailyCheckin(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      energy: data.energy.present ? data.energy.value : this.energy,
      sleep: data.sleep.present ? data.sleep.value : this.sleep,
      soreness: data.soreness.present ? data.soreness.value : this.soreness,
      stress: data.stress.present ? data.stress.value : this.stress,
      pain: data.pain.present ? data.pain.value : this.pain,
      symptoms: data.symptoms.present ? data.symptoms.value : this.symptoms,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyCheckin(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('energy: $energy, ')
          ..write('sleep: $sleep, ')
          ..write('soreness: $soreness, ')
          ..write('stress: $stress, ')
          ..write('pain: $pain, ')
          ..write('symptoms: $symptoms, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    day,
    energy,
    sleep,
    soreness,
    stress,
    pain,
    symptoms,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyCheckin &&
          other.id == this.id &&
          other.day == this.day &&
          other.energy == this.energy &&
          other.sleep == this.sleep &&
          other.soreness == this.soreness &&
          other.stress == this.stress &&
          other.pain == this.pain &&
          other.symptoms == this.symptoms &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus);
}

class DailyCheckinsCompanion extends UpdateCompanion<DailyCheckin> {
  final Value<String> id;
  final Value<String> day;
  final Value<int?> energy;
  final Value<int?> sleep;
  final Value<int?> soreness;
  final Value<int?> stress;
  final Value<int?> pain;
  final Value<String> symptoms;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const DailyCheckinsCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.energy = const Value.absent(),
    this.sleep = const Value.absent(),
    this.soreness = const Value.absent(),
    this.stress = const Value.absent(),
    this.pain = const Value.absent(),
    this.symptoms = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyCheckinsCompanion.insert({
    required String id,
    required String day,
    this.energy = const Value.absent(),
    this.sleep = const Value.absent(),
    this.soreness = const Value.absent(),
    this.stress = const Value.absent(),
    this.pain = const Value.absent(),
    this.symptoms = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       day = Value(day),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DailyCheckin> custom({
    Expression<String>? id,
    Expression<String>? day,
    Expression<int>? energy,
    Expression<int>? sleep,
    Expression<int>? soreness,
    Expression<int>? stress,
    Expression<int>? pain,
    Expression<String>? symptoms,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (energy != null) 'energy': energy,
      if (sleep != null) 'sleep': sleep,
      if (soreness != null) 'soreness': soreness,
      if (stress != null) 'stress': stress,
      if (pain != null) 'pain': pain,
      if (symptoms != null) 'symptoms': symptoms,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyCheckinsCompanion copyWith({
    Value<String>? id,
    Value<String>? day,
    Value<int?>? energy,
    Value<int?>? sleep,
    Value<int?>? soreness,
    Value<int?>? stress,
    Value<int?>? pain,
    Value<String>? symptoms,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return DailyCheckinsCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      energy: energy ?? this.energy,
      sleep: sleep ?? this.sleep,
      soreness: soreness ?? this.soreness,
      stress: stress ?? this.stress,
      pain: pain ?? this.pain,
      symptoms: symptoms ?? this.symptoms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (energy.present) {
      map['energy'] = Variable<int>(energy.value);
    }
    if (sleep.present) {
      map['sleep'] = Variable<int>(sleep.value);
    }
    if (soreness.present) {
      map['soreness'] = Variable<int>(soreness.value);
    }
    if (stress.present) {
      map['stress'] = Variable<int>(stress.value);
    }
    if (pain.present) {
      map['pain'] = Variable<int>(pain.value);
    }
    if (symptoms.present) {
      map['symptoms'] = Variable<String>(symptoms.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyCheckinsCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('energy: $energy, ')
          ..write('sleep: $sleep, ')
          ..write('soreness: $soreness, ')
          ..write('stress: $stress, ')
          ..write('pain: $pain, ')
          ..write('symptoms: $symptoms, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FlareEventsTable extends FlareEvents
    with TableInfo<$FlareEventsTable, FlareEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlareEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDayMeta = const VerificationMeta('endDay');
  @override
  late final GeneratedColumn<String> endDay = GeneratedColumn<String>(
    'end_day',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _symptomsMeta = const VerificationMeta(
    'symptoms',
  );
  @override
  late final GeneratedColumn<String> symptoms = GeneratedColumn<String>(
    'symptoms',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _impactMeta = const VerificationMeta('impact');
  @override
  late final GeneratedColumn<String> impact = GeneratedColumn<String>(
    'impact',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    endDay,
    severity,
    symptoms,
    impact,
    category,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flare_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<FlareEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('end_day')) {
      context.handle(
        _endDayMeta,
        endDay.isAcceptableOrUnknown(data['end_day']!, _endDayMeta),
      );
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('symptoms')) {
      context.handle(
        _symptomsMeta,
        symptoms.isAcceptableOrUnknown(data['symptoms']!, _symptomsMeta),
      );
    }
    if (data.containsKey('impact')) {
      context.handle(
        _impactMeta,
        impact.isAcceptableOrUnknown(data['impact']!, _impactMeta),
      );
    } else if (isInserting) {
      context.missing(_impactMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FlareEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FlareEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      endDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_day'],
      ),
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      symptoms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symptoms'],
      )!,
      impact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}impact'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $FlareEventsTable createAlias(String alias) {
    return $FlareEventsTable(attachedDatabase, alias);
  }
}

class FlareEvent extends DataClass implements Insertable<FlareEvent> {
  /// Client-generated UUIDv7.
  final String id;

  /// ISO-8601 date string (`YYYY-MM-DD`), user-local calendar day. The
  /// **first** day of the flare when [endDay] is set.
  final String day;

  /// ISO-8601 date string (`YYYY-MM-DD`), user-local calendar day; the
  /// **inclusive** last day of a multi-day flare (schema v9).
  ///
  /// `null` means a single-day flare covering only [day] — the shape every
  /// pre-v9 row backfills to, and still the common case. Range queries
  /// therefore read the effective last day as `COALESCE(end_day, day)`
  /// rather than requiring the column to be populated (see
  /// `features/wellbeing/data/drift_wellbeing_repository.dart`).
  final String? endDay;

  /// Persisted as `'mild'`, `'moderate'`, or `'severe'` (see
  /// `features/wellbeing/domain/flare_event.dart`'s `FlareSeverity`).
  final String severity;

  /// Comma-separated `SymptomType.toStorage()` keys. Empty string when no
  /// symptoms were logged.
  final String symptoms;

  /// Persisted as `'none'`, `'reducedTraining'`, or `'unableToTrain'` (see
  /// `FlareImpact`).
  final String impact;

  /// Persisted as one of `FlareCategory`'s storage keys, or `null` when
  /// left unset ("Prefer not to say") — never required.
  final String? category;
  final String? notes;

  /// UTC milliseconds since epoch.
  final int createdAt;

  /// UTC milliseconds since epoch.
  final int updatedAt;

  /// UTC milliseconds since epoch; null while the row is live. Kept for
  /// column-shape consistency with other tables, but
  /// `DriftWellbeingRepository.deleteFlare` hard-deletes instead (S3, same
  /// reasoning as `daily_checkins.dart#deletedAt`) — should always read
  /// `null`.
  final int? deletedAt;

  /// One of `'local'`, `'pending'`, `'synced'` (outbox/sync status; see ADR
  /// 004). Defaults to `'local'`.
  final String syncStatus;
  const FlareEvent({
    required this.id,
    required this.day,
    this.endDay,
    required this.severity,
    required this.symptoms,
    required this.impact,
    this.category,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day'] = Variable<String>(day);
    if (!nullToAbsent || endDay != null) {
      map['end_day'] = Variable<String>(endDay);
    }
    map['severity'] = Variable<String>(severity);
    map['symptoms'] = Variable<String>(symptoms);
    map['impact'] = Variable<String>(impact);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  FlareEventsCompanion toCompanion(bool nullToAbsent) {
    return FlareEventsCompanion(
      id: Value(id),
      day: Value(day),
      endDay: endDay == null && nullToAbsent
          ? const Value.absent()
          : Value(endDay),
      severity: Value(severity),
      symptoms: Value(symptoms),
      impact: Value(impact),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory FlareEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FlareEvent(
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      endDay: serializer.fromJson<String?>(json['endDay']),
      severity: serializer.fromJson<String>(json['severity']),
      symptoms: serializer.fromJson<String>(json['symptoms']),
      impact: serializer.fromJson<String>(json['impact']),
      category: serializer.fromJson<String?>(json['category']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<String>(day),
      'endDay': serializer.toJson<String?>(endDay),
      'severity': serializer.toJson<String>(severity),
      'symptoms': serializer.toJson<String>(symptoms),
      'impact': serializer.toJson<String>(impact),
      'category': serializer.toJson<String?>(category),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  FlareEvent copyWith({
    String? id,
    String? day,
    Value<String?> endDay = const Value.absent(),
    String? severity,
    String? symptoms,
    String? impact,
    Value<String?> category = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? syncStatus,
  }) => FlareEvent(
    id: id ?? this.id,
    day: day ?? this.day,
    endDay: endDay.present ? endDay.value : this.endDay,
    severity: severity ?? this.severity,
    symptoms: symptoms ?? this.symptoms,
    impact: impact ?? this.impact,
    category: category.present ? category.value : this.category,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  FlareEvent copyWithCompanion(FlareEventsCompanion data) {
    return FlareEvent(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      endDay: data.endDay.present ? data.endDay.value : this.endDay,
      severity: data.severity.present ? data.severity.value : this.severity,
      symptoms: data.symptoms.present ? data.symptoms.value : this.symptoms,
      impact: data.impact.present ? data.impact.value : this.impact,
      category: data.category.present ? data.category.value : this.category,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FlareEvent(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('endDay: $endDay, ')
          ..write('severity: $severity, ')
          ..write('symptoms: $symptoms, ')
          ..write('impact: $impact, ')
          ..write('category: $category, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    day,
    endDay,
    severity,
    symptoms,
    impact,
    category,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlareEvent &&
          other.id == this.id &&
          other.day == this.day &&
          other.endDay == this.endDay &&
          other.severity == this.severity &&
          other.symptoms == this.symptoms &&
          other.impact == this.impact &&
          other.category == this.category &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus);
}

class FlareEventsCompanion extends UpdateCompanion<FlareEvent> {
  final Value<String> id;
  final Value<String> day;
  final Value<String?> endDay;
  final Value<String> severity;
  final Value<String> symptoms;
  final Value<String> impact;
  final Value<String?> category;
  final Value<String?> notes;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const FlareEventsCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.endDay = const Value.absent(),
    this.severity = const Value.absent(),
    this.symptoms = const Value.absent(),
    this.impact = const Value.absent(),
    this.category = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlareEventsCompanion.insert({
    required String id,
    required String day,
    this.endDay = const Value.absent(),
    required String severity,
    this.symptoms = const Value.absent(),
    required String impact,
    this.category = const Value.absent(),
    this.notes = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       day = Value(day),
       severity = Value(severity),
       impact = Value(impact),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FlareEvent> custom({
    Expression<String>? id,
    Expression<String>? day,
    Expression<String>? endDay,
    Expression<String>? severity,
    Expression<String>? symptoms,
    Expression<String>? impact,
    Expression<String>? category,
    Expression<String>? notes,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (endDay != null) 'end_day': endDay,
      if (severity != null) 'severity': severity,
      if (symptoms != null) 'symptoms': symptoms,
      if (impact != null) 'impact': impact,
      if (category != null) 'category': category,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlareEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? day,
    Value<String?>? endDay,
    Value<String>? severity,
    Value<String>? symptoms,
    Value<String>? impact,
    Value<String?>? category,
    Value<String?>? notes,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return FlareEventsCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      endDay: endDay ?? this.endDay,
      severity: severity ?? this.severity,
      symptoms: symptoms ?? this.symptoms,
      impact: impact ?? this.impact,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (endDay.present) {
      map['end_day'] = Variable<String>(endDay.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (symptoms.present) {
      map['symptoms'] = Variable<String>(symptoms.value);
    }
    if (impact.present) {
      map['impact'] = Variable<String>(impact.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlareEventsCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('endDay: $endDay, ')
          ..write('severity: $severity, ')
          ..write('symptoms: $symptoms, ')
          ..write('impact: $impact, ')
          ..write('category: $category, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecoveryDaysTable extends RecoveryDays
    with TableInfo<$RecoveryDaysTable, RecoveryDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecoveryDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    note,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recovery_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecoveryDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecoveryDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecoveryDay(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $RecoveryDaysTable createAlias(String alias) {
    return $RecoveryDaysTable(attachedDatabase, alias);
  }
}

class RecoveryDay extends DataClass implements Insertable<RecoveryDay> {
  /// Client-generated UUIDv7.
  final String id;

  /// ISO-8601 date string (`YYYY-MM-DD`), user-local calendar day. Unique —
  /// at most one recovery record per day.
  final String day;

  /// Optional free-text note the user attached when marking the day —
  /// never required (`knowledge/product/terminology.md`'s "Protected
  /// Recovery": "requires no proof").
  final String? note;

  /// UTC milliseconds since epoch.
  final int createdAt;

  /// UTC milliseconds since epoch.
  final int updatedAt;

  /// UTC milliseconds since epoch; null while the row is live. Kept for
  /// column-shape consistency with other tables, but
  /// `DriftRecoveryRepository.unmarkRecoveryDay` hard-deletes instead (same
  /// reasoning as `daily_checkins.dart#deletedAt`) — should always read
  /// `null`.
  final int? deletedAt;

  /// One of `'local'`, `'pending'`, `'synced'` (outbox/sync status; see ADR
  /// 004). Defaults to `'local'`.
  final String syncStatus;
  const RecoveryDay({
    required this.id,
    required this.day,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day'] = Variable<String>(day);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  RecoveryDaysCompanion toCompanion(bool nullToAbsent) {
    return RecoveryDaysCompanion(
      id: Value(id),
      day: Value(day),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory RecoveryDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecoveryDay(
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<String>(day),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  RecoveryDay copyWith({
    String? id,
    String? day,
    Value<String?> note = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? syncStatus,
  }) => RecoveryDay(
    id: id ?? this.id,
    day: day ?? this.day,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  RecoveryDay copyWithCompanion(RecoveryDaysCompanion data) {
    return RecoveryDay(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecoveryDay(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, day, note, createdAt, updatedAt, deletedAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecoveryDay &&
          other.id == this.id &&
          other.day == this.day &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus);
}

class RecoveryDaysCompanion extends UpdateCompanion<RecoveryDay> {
  final Value<String> id;
  final Value<String> day;
  final Value<String?> note;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const RecoveryDaysCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecoveryDaysCompanion.insert({
    required String id,
    required String day,
    this.note = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       day = Value(day),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RecoveryDay> custom({
    Expression<String>? id,
    Expression<String>? day,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecoveryDaysCompanion copyWith({
    Value<String>? id,
    Value<String>? day,
    Value<String?>? note,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return RecoveryDaysCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecoveryDaysCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutesTable extends Routes with TableInfo<$RoutesTable, Route> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedDurationSecondsMeta =
      const VerificationMeta('estimatedDurationSeconds');
  @override
  late final GeneratedColumn<int> estimatedDurationSeconds =
      GeneratedColumn<int>(
        'estimated_duration_seconds',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ascentMetersMeta = const VerificationMeta(
    'ascentMeters',
  );
  @override
  late final GeneratedColumn<double> ascentMeters = GeneratedColumn<double>(
    'ascent_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descentMetersMeta = const VerificationMeta(
    'descentMeters',
  );
  @override
  late final GeneratedColumn<double> descentMeters = GeneratedColumn<double>(
    'descent_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _geometryMeta = const VerificationMeta(
    'geometry',
  );
  @override
  late final GeneratedColumn<String> geometry = GeneratedColumn<String>(
    'geometry',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityTypeMeta = const VerificationMeta(
    'activityType',
  );
  @override
  late final GeneratedColumn<String> activityType = GeneratedColumn<String>(
    'activity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('suggested'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    distanceMeters,
    estimatedDurationSeconds,
    ascentMeters,
    descentMeters,
    geometry,
    activityType,
    source,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Route> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distanceMetersMeta);
    }
    if (data.containsKey('estimated_duration_seconds')) {
      context.handle(
        _estimatedDurationSecondsMeta,
        estimatedDurationSeconds.isAcceptableOrUnknown(
          data['estimated_duration_seconds']!,
          _estimatedDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('ascent_meters')) {
      context.handle(
        _ascentMetersMeta,
        ascentMeters.isAcceptableOrUnknown(
          data['ascent_meters']!,
          _ascentMetersMeta,
        ),
      );
    }
    if (data.containsKey('descent_meters')) {
      context.handle(
        _descentMetersMeta,
        descentMeters.isAcceptableOrUnknown(
          data['descent_meters']!,
          _descentMetersMeta,
        ),
      );
    }
    if (data.containsKey('geometry')) {
      context.handle(
        _geometryMeta,
        geometry.isAcceptableOrUnknown(data['geometry']!, _geometryMeta),
      );
    } else if (isInserting) {
      context.missing(_geometryMeta);
    }
    if (data.containsKey('activity_type')) {
      context.handle(
        _activityTypeMeta,
        activityType.isAcceptableOrUnknown(
          data['activity_type']!,
          _activityTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activityTypeMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Route map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Route(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      )!,
      estimatedDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_duration_seconds'],
      ),
      ascentMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ascent_meters'],
      ),
      descentMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}descent_meters'],
      ),
      geometry: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}geometry'],
      )!,
      activityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_type'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $RoutesTable createAlias(String alias) {
    return $RoutesTable(attachedDatabase, alias);
  }
}

class Route extends DataClass implements Insertable<Route> {
  /// Client-generated UUIDv7.
  final String id;
  final String name;
  final double distanceMeters;
  final int? estimatedDurationSeconds;
  final double? ascentMeters;

  /// Total descent in metres; null when the source had no elevation data.
  final double? descentMeters;

  /// The route's geometry as a Google polyline-5 encoded string (see
  /// `core/utils/polyline_codec.dart`) — read back whole for drawing, never
  /// queried per point, so a compact TEXT blob beats a relational point
  /// table here (unlike `activity_samples`, which analytics query per
  /// point).
  final String geometry;

  /// Persisted as `'run'`, `'walk'`, `'hike'`, or `'ride'` (see
  /// `features/activity/domain/activity.dart`'s `ActivityType`).
  final String activityType;

  /// Where the route came from. `'suggested'` for routes produced by the
  /// route-suggestion service; future values (e.g. `'extracted'`) arrive
  /// with their features.
  final String source;

  /// UTC milliseconds since epoch.
  final int createdAt;

  /// UTC milliseconds since epoch.
  final int updatedAt;

  /// UTC milliseconds since epoch; null while the row is live. Soft-delete
  /// marker per ADR 004.
  final int? deletedAt;

  /// One of `'local'`, `'pending'`, `'synced'` (outbox/sync status; see
  /// ADR 004).
  final String syncStatus;
  const Route({
    required this.id,
    required this.name,
    required this.distanceMeters,
    this.estimatedDurationSeconds,
    this.ascentMeters,
    this.descentMeters,
    required this.geometry,
    required this.activityType,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['distance_meters'] = Variable<double>(distanceMeters);
    if (!nullToAbsent || estimatedDurationSeconds != null) {
      map['estimated_duration_seconds'] = Variable<int>(
        estimatedDurationSeconds,
      );
    }
    if (!nullToAbsent || ascentMeters != null) {
      map['ascent_meters'] = Variable<double>(ascentMeters);
    }
    if (!nullToAbsent || descentMeters != null) {
      map['descent_meters'] = Variable<double>(descentMeters);
    }
    map['geometry'] = Variable<String>(geometry);
    map['activity_type'] = Variable<String>(activityType);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  RoutesCompanion toCompanion(bool nullToAbsent) {
    return RoutesCompanion(
      id: Value(id),
      name: Value(name),
      distanceMeters: Value(distanceMeters),
      estimatedDurationSeconds: estimatedDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedDurationSeconds),
      ascentMeters: ascentMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(ascentMeters),
      descentMeters: descentMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(descentMeters),
      geometry: Value(geometry),
      activityType: Value(activityType),
      source: Value(source),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Route.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Route(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      distanceMeters: serializer.fromJson<double>(json['distanceMeters']),
      estimatedDurationSeconds: serializer.fromJson<int?>(
        json['estimatedDurationSeconds'],
      ),
      ascentMeters: serializer.fromJson<double?>(json['ascentMeters']),
      descentMeters: serializer.fromJson<double?>(json['descentMeters']),
      geometry: serializer.fromJson<String>(json['geometry']),
      activityType: serializer.fromJson<String>(json['activityType']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'distanceMeters': serializer.toJson<double>(distanceMeters),
      'estimatedDurationSeconds': serializer.toJson<int?>(
        estimatedDurationSeconds,
      ),
      'ascentMeters': serializer.toJson<double?>(ascentMeters),
      'descentMeters': serializer.toJson<double?>(descentMeters),
      'geometry': serializer.toJson<String>(geometry),
      'activityType': serializer.toJson<String>(activityType),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Route copyWith({
    String? id,
    String? name,
    double? distanceMeters,
    Value<int?> estimatedDurationSeconds = const Value.absent(),
    Value<double?> ascentMeters = const Value.absent(),
    Value<double?> descentMeters = const Value.absent(),
    String? geometry,
    String? activityType,
    String? source,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? syncStatus,
  }) => Route(
    id: id ?? this.id,
    name: name ?? this.name,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    estimatedDurationSeconds: estimatedDurationSeconds.present
        ? estimatedDurationSeconds.value
        : this.estimatedDurationSeconds,
    ascentMeters: ascentMeters.present ? ascentMeters.value : this.ascentMeters,
    descentMeters: descentMeters.present
        ? descentMeters.value
        : this.descentMeters,
    geometry: geometry ?? this.geometry,
    activityType: activityType ?? this.activityType,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Route copyWithCompanion(RoutesCompanion data) {
    return Route(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      estimatedDurationSeconds: data.estimatedDurationSeconds.present
          ? data.estimatedDurationSeconds.value
          : this.estimatedDurationSeconds,
      ascentMeters: data.ascentMeters.present
          ? data.ascentMeters.value
          : this.ascentMeters,
      descentMeters: data.descentMeters.present
          ? data.descentMeters.value
          : this.descentMeters,
      geometry: data.geometry.present ? data.geometry.value : this.geometry,
      activityType: data.activityType.present
          ? data.activityType.value
          : this.activityType,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Route(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('estimatedDurationSeconds: $estimatedDurationSeconds, ')
          ..write('ascentMeters: $ascentMeters, ')
          ..write('descentMeters: $descentMeters, ')
          ..write('geometry: $geometry, ')
          ..write('activityType: $activityType, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    distanceMeters,
    estimatedDurationSeconds,
    ascentMeters,
    descentMeters,
    geometry,
    activityType,
    source,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Route &&
          other.id == this.id &&
          other.name == this.name &&
          other.distanceMeters == this.distanceMeters &&
          other.estimatedDurationSeconds == this.estimatedDurationSeconds &&
          other.ascentMeters == this.ascentMeters &&
          other.descentMeters == this.descentMeters &&
          other.geometry == this.geometry &&
          other.activityType == this.activityType &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus);
}

class RoutesCompanion extends UpdateCompanion<Route> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> distanceMeters;
  final Value<int?> estimatedDurationSeconds;
  final Value<double?> ascentMeters;
  final Value<double?> descentMeters;
  final Value<String> geometry;
  final Value<String> activityType;
  final Value<String> source;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const RoutesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.estimatedDurationSeconds = const Value.absent(),
    this.ascentMeters = const Value.absent(),
    this.descentMeters = const Value.absent(),
    this.geometry = const Value.absent(),
    this.activityType = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutesCompanion.insert({
    required String id,
    required String name,
    required double distanceMeters,
    this.estimatedDurationSeconds = const Value.absent(),
    this.ascentMeters = const Value.absent(),
    this.descentMeters = const Value.absent(),
    required String geometry,
    required String activityType,
    this.source = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       distanceMeters = Value(distanceMeters),
       geometry = Value(geometry),
       activityType = Value(activityType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Route> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? distanceMeters,
    Expression<int>? estimatedDurationSeconds,
    Expression<double>? ascentMeters,
    Expression<double>? descentMeters,
    Expression<String>? geometry,
    Expression<String>? activityType,
    Expression<String>? source,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (estimatedDurationSeconds != null)
        'estimated_duration_seconds': estimatedDurationSeconds,
      if (ascentMeters != null) 'ascent_meters': ascentMeters,
      if (descentMeters != null) 'descent_meters': descentMeters,
      if (geometry != null) 'geometry': geometry,
      if (activityType != null) 'activity_type': activityType,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<double>? distanceMeters,
    Value<int?>? estimatedDurationSeconds,
    Value<double?>? ascentMeters,
    Value<double?>? descentMeters,
    Value<String>? geometry,
    Value<String>? activityType,
    Value<String>? source,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return RoutesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      estimatedDurationSeconds:
          estimatedDurationSeconds ?? this.estimatedDurationSeconds,
      ascentMeters: ascentMeters ?? this.ascentMeters,
      descentMeters: descentMeters ?? this.descentMeters,
      geometry: geometry ?? this.geometry,
      activityType: activityType ?? this.activityType,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (estimatedDurationSeconds.present) {
      map['estimated_duration_seconds'] = Variable<int>(
        estimatedDurationSeconds.value,
      );
    }
    if (ascentMeters.present) {
      map['ascent_meters'] = Variable<double>(ascentMeters.value);
    }
    if (descentMeters.present) {
      map['descent_meters'] = Variable<double>(descentMeters.value);
    }
    if (geometry.present) {
      map['geometry'] = Variable<String>(geometry.value);
    }
    if (activityType.present) {
      map['activity_type'] = Variable<String>(activityType.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('estimatedDurationSeconds: $estimatedDurationSeconds, ')
          ..write('ascentMeters: $ascentMeters, ')
          ..write('descentMeters: $descentMeters, ')
          ..write('geometry: $geometry, ')
          ..write('activityType: $activityType, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoodsTable extends Foods with TableInfo<$FoodsTable, Food> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerFoodIdMeta = const VerificationMeta(
    'providerFoodId',
  );
  @override
  late final GeneratedColumn<String> providerFoodId = GeneratedColumn<String>(
    'provider_food_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _servingDescriptionMeta =
      const VerificationMeta('servingDescription');
  @override
  late final GeneratedColumn<String> servingDescription =
      GeneratedColumn<String>(
        'serving_description',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _servingGramsMeta = const VerificationMeta(
    'servingGrams',
  );
  @override
  late final GeneratedColumn<double> servingGrams = GeneratedColumn<double>(
    'serving_grams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _servingVolumeMlMeta = const VerificationMeta(
    'servingVolumeMl',
  );
  @override
  late final GeneratedColumn<double> servingVolumeMl = GeneratedColumn<double>(
    'serving_volume_ml',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caloriesKcalMeta = const VerificationMeta(
    'caloriesKcal',
  );
  @override
  late final GeneratedColumn<double> caloriesKcal = GeneratedColumn<double>(
    'calories_kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinGramsMeta = const VerificationMeta(
    'proteinGrams',
  );
  @override
  late final GeneratedColumn<double> proteinGrams = GeneratedColumn<double>(
    'protein_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsGramsMeta = const VerificationMeta(
    'carbsGrams',
  );
  @override
  late final GeneratedColumn<double> carbsGrams = GeneratedColumn<double>(
    'carbs_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatGramsMeta = const VerificationMeta(
    'fatGrams',
  );
  @override
  late final GeneratedColumn<double> fatGrams = GeneratedColumn<double>(
    'fat_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ironMgMeta = const VerificationMeta('ironMg');
  @override
  late final GeneratedColumn<double> ironMg = GeneratedColumn<double>(
    'iron_mg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _saturatedFatGramsMeta = const VerificationMeta(
    'saturatedFatGrams',
  );
  @override
  late final GeneratedColumn<double> saturatedFatGrams =
      GeneratedColumn<double>(
        'saturated_fat_grams',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _transFatGramsMeta = const VerificationMeta(
    'transFatGrams',
  );
  @override
  late final GeneratedColumn<double> transFatGrams = GeneratedColumn<double>(
    'trans_fat_grams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monounsaturatedFatGramsMeta =
      const VerificationMeta('monounsaturatedFatGrams');
  @override
  late final GeneratedColumn<double> monounsaturatedFatGrams =
      GeneratedColumn<double>(
        'monounsaturated_fat_grams',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _polyunsaturatedFatGramsMeta =
      const VerificationMeta('polyunsaturatedFatGrams');
  @override
  late final GeneratedColumn<double> polyunsaturatedFatGrams =
      GeneratedColumn<double>(
        'polyunsaturated_fat_grams',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fiberGramsMeta = const VerificationMeta(
    'fiberGrams',
  );
  @override
  late final GeneratedColumn<double> fiberGrams = GeneratedColumn<double>(
    'fiber_grams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sugarsGramsMeta = const VerificationMeta(
    'sugarsGrams',
  );
  @override
  late final GeneratedColumn<double> sugarsGrams = GeneratedColumn<double>(
    'sugars_grams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedSugarsGramsMeta = const VerificationMeta(
    'addedSugarsGrams',
  );
  @override
  late final GeneratedColumn<double> addedSugarsGrams = GeneratedColumn<double>(
    'added_sugars_grams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sodiumMgMeta = const VerificationMeta(
    'sodiumMg',
  );
  @override
  late final GeneratedColumn<double> sodiumMg = GeneratedColumn<double>(
    'sodium_mg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _potassiumMgMeta = const VerificationMeta(
    'potassiumMg',
  );
  @override
  late final GeneratedColumn<double> potassiumMg = GeneratedColumn<double>(
    'potassium_mg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cholesterolMgMeta = const VerificationMeta(
    'cholesterolMg',
  );
  @override
  late final GeneratedColumn<double> cholesterolMg = GeneratedColumn<double>(
    'cholesterol_mg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _calciumMgMeta = const VerificationMeta(
    'calciumMg',
  );
  @override
  late final GeneratedColumn<double> calciumMg = GeneratedColumn<double>(
    'calcium_mg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vitaminDMcgMeta = const VerificationMeta(
    'vitaminDMcg',
  );
  @override
  late final GeneratedColumn<double> vitaminDMcg = GeneratedColumn<double>(
    'vitamin_d_mcg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vitaminCMgMeta = const VerificationMeta(
    'vitaminCMg',
  );
  @override
  late final GeneratedColumn<double> vitaminCMg = GeneratedColumn<double>(
    'vitamin_c_mg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('custom'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerFoodId,
    name,
    brand,
    servingDescription,
    servingGrams,
    servingVolumeMl,
    caloriesKcal,
    proteinGrams,
    carbsGrams,
    fatGrams,
    ironMg,
    saturatedFatGrams,
    transFatGrams,
    monounsaturatedFatGrams,
    polyunsaturatedFatGrams,
    fiberGrams,
    sugarsGrams,
    addedSugarsGrams,
    sodiumMg,
    potassiumMg,
    cholesterolMg,
    calciumMg,
    vitaminDMcg,
    vitaminCMg,
    barcode,
    source,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<Food> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('provider_food_id')) {
      context.handle(
        _providerFoodIdMeta,
        providerFoodId.isAcceptableOrUnknown(
          data['provider_food_id']!,
          _providerFoodIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('serving_description')) {
      context.handle(
        _servingDescriptionMeta,
        servingDescription.isAcceptableOrUnknown(
          data['serving_description']!,
          _servingDescriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_servingDescriptionMeta);
    }
    if (data.containsKey('serving_grams')) {
      context.handle(
        _servingGramsMeta,
        servingGrams.isAcceptableOrUnknown(
          data['serving_grams']!,
          _servingGramsMeta,
        ),
      );
    }
    if (data.containsKey('serving_volume_ml')) {
      context.handle(
        _servingVolumeMlMeta,
        servingVolumeMl.isAcceptableOrUnknown(
          data['serving_volume_ml']!,
          _servingVolumeMlMeta,
        ),
      );
    }
    if (data.containsKey('calories_kcal')) {
      context.handle(
        _caloriesKcalMeta,
        caloriesKcal.isAcceptableOrUnknown(
          data['calories_kcal']!,
          _caloriesKcalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_caloriesKcalMeta);
    }
    if (data.containsKey('protein_grams')) {
      context.handle(
        _proteinGramsMeta,
        proteinGrams.isAcceptableOrUnknown(
          data['protein_grams']!,
          _proteinGramsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinGramsMeta);
    }
    if (data.containsKey('carbs_grams')) {
      context.handle(
        _carbsGramsMeta,
        carbsGrams.isAcceptableOrUnknown(data['carbs_grams']!, _carbsGramsMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsGramsMeta);
    }
    if (data.containsKey('fat_grams')) {
      context.handle(
        _fatGramsMeta,
        fatGrams.isAcceptableOrUnknown(data['fat_grams']!, _fatGramsMeta),
      );
    } else if (isInserting) {
      context.missing(_fatGramsMeta);
    }
    if (data.containsKey('iron_mg')) {
      context.handle(
        _ironMgMeta,
        ironMg.isAcceptableOrUnknown(data['iron_mg']!, _ironMgMeta),
      );
    }
    if (data.containsKey('saturated_fat_grams')) {
      context.handle(
        _saturatedFatGramsMeta,
        saturatedFatGrams.isAcceptableOrUnknown(
          data['saturated_fat_grams']!,
          _saturatedFatGramsMeta,
        ),
      );
    }
    if (data.containsKey('trans_fat_grams')) {
      context.handle(
        _transFatGramsMeta,
        transFatGrams.isAcceptableOrUnknown(
          data['trans_fat_grams']!,
          _transFatGramsMeta,
        ),
      );
    }
    if (data.containsKey('monounsaturated_fat_grams')) {
      context.handle(
        _monounsaturatedFatGramsMeta,
        monounsaturatedFatGrams.isAcceptableOrUnknown(
          data['monounsaturated_fat_grams']!,
          _monounsaturatedFatGramsMeta,
        ),
      );
    }
    if (data.containsKey('polyunsaturated_fat_grams')) {
      context.handle(
        _polyunsaturatedFatGramsMeta,
        polyunsaturatedFatGrams.isAcceptableOrUnknown(
          data['polyunsaturated_fat_grams']!,
          _polyunsaturatedFatGramsMeta,
        ),
      );
    }
    if (data.containsKey('fiber_grams')) {
      context.handle(
        _fiberGramsMeta,
        fiberGrams.isAcceptableOrUnknown(data['fiber_grams']!, _fiberGramsMeta),
      );
    }
    if (data.containsKey('sugars_grams')) {
      context.handle(
        _sugarsGramsMeta,
        sugarsGrams.isAcceptableOrUnknown(
          data['sugars_grams']!,
          _sugarsGramsMeta,
        ),
      );
    }
    if (data.containsKey('added_sugars_grams')) {
      context.handle(
        _addedSugarsGramsMeta,
        addedSugarsGrams.isAcceptableOrUnknown(
          data['added_sugars_grams']!,
          _addedSugarsGramsMeta,
        ),
      );
    }
    if (data.containsKey('sodium_mg')) {
      context.handle(
        _sodiumMgMeta,
        sodiumMg.isAcceptableOrUnknown(data['sodium_mg']!, _sodiumMgMeta),
      );
    }
    if (data.containsKey('potassium_mg')) {
      context.handle(
        _potassiumMgMeta,
        potassiumMg.isAcceptableOrUnknown(
          data['potassium_mg']!,
          _potassiumMgMeta,
        ),
      );
    }
    if (data.containsKey('cholesterol_mg')) {
      context.handle(
        _cholesterolMgMeta,
        cholesterolMg.isAcceptableOrUnknown(
          data['cholesterol_mg']!,
          _cholesterolMgMeta,
        ),
      );
    }
    if (data.containsKey('calcium_mg')) {
      context.handle(
        _calciumMgMeta,
        calciumMg.isAcceptableOrUnknown(data['calcium_mg']!, _calciumMgMeta),
      );
    }
    if (data.containsKey('vitamin_d_mcg')) {
      context.handle(
        _vitaminDMcgMeta,
        vitaminDMcg.isAcceptableOrUnknown(
          data['vitamin_d_mcg']!,
          _vitaminDMcgMeta,
        ),
      );
    }
    if (data.containsKey('vitamin_c_mg')) {
      context.handle(
        _vitaminCMgMeta,
        vitaminCMg.isAcceptableOrUnknown(
          data['vitamin_c_mg']!,
          _vitaminCMgMeta,
        ),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Food map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Food(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      providerFoodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_food_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      servingDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_description'],
      )!,
      servingGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}serving_grams'],
      ),
      servingVolumeMl: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}serving_volume_ml'],
      ),
      caloriesKcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories_kcal'],
      )!,
      proteinGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_grams'],
      )!,
      carbsGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_grams'],
      )!,
      fatGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_grams'],
      )!,
      ironMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}iron_mg'],
      ),
      saturatedFatGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}saturated_fat_grams'],
      ),
      transFatGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}trans_fat_grams'],
      ),
      monounsaturatedFatGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monounsaturated_fat_grams'],
      ),
      polyunsaturatedFatGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}polyunsaturated_fat_grams'],
      ),
      fiberGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber_grams'],
      ),
      sugarsGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sugars_grams'],
      ),
      addedSugarsGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}added_sugars_grams'],
      ),
      sodiumMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sodium_mg'],
      ),
      potassiumMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}potassium_mg'],
      ),
      cholesterolMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cholesterol_mg'],
      ),
      calciumMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calcium_mg'],
      ),
      vitaminDMcg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vitamin_d_mcg'],
      ),
      vitaminCMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vitamin_c_mg'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $FoodsTable createAlias(String alias) {
    return $FoodsTable(attachedDatabase, alias);
  }
}

class Food extends DataClass implements Insertable<Food> {
  /// Client-generated UUIDv7.
  final String id;

  /// Catalogue identity, distinct from a retail barcode.
  final String? providerFoodId;

  /// What the user calls this food, e.g. `'Porridge oats'`.
  final String name;

  /// Brand or maker, when the user gave one. `null` for generic foods.
  final String? brand;

  /// Plain-English description of one serving, e.g. `'1 cup (dry)'`. Always
  /// present — every number below is "per one of these".
  final String servingDescription;

  /// Mass of one serving in grams, when known. `null` for servings with no
  /// meaningful gram weight (a drink measured in ml, an item the user
  /// didn't weigh) — see the class doc.
  final double? servingGrams;

  /// Volume of one serving in millilitres, when known. `null` for solid foods
  /// or servings where fluid volume is not specified.
  final double? servingVolumeMl;

  /// Energy per serving, in kilocalories.
  final double caloriesKcal;

  /// Protein per serving, in grams.
  final double proteinGrams;

  /// Carbohydrate per serving, in grams.
  final double carbsGrams;

  /// Fat per serving, in grams.
  final double fatGrams;

  /// Iron per serving, in milligrams. `null` means **unknown**, never zero
  /// — see the class doc.
  final double? ironMg;

  /// Saturated fat per serving, in grams. `null` means **unknown** — the
  /// same rule [ironMg] follows, and the reason every column below is
  /// nullable (see the class doc).
  final double? saturatedFatGrams;

  /// Trans fat per serving, in grams. `null` means unknown.
  final double? transFatGrams;

  /// Monounsaturated fat per serving, in grams. `null` means unknown.
  final double? monounsaturatedFatGrams;

  /// Polyunsaturated fat per serving, in grams. `null` means unknown.
  final double? polyunsaturatedFatGrams;

  /// Dietary fibre per serving, in grams. `null` means unknown.
  final double? fiberGrams;

  /// Total sugars per serving, in grams. `null` means unknown.
  final double? sugarsGrams;

  /// Added sugars per serving, in grams. `null` means unknown.
  final double? addedSugarsGrams;

  /// Sodium per serving, in milligrams. `null` means unknown.
  final double? sodiumMg;

  /// Potassium per serving, in milligrams. `null` means unknown.
  final double? potassiumMg;

  /// Cholesterol per serving, in milligrams. `null` means unknown.
  final double? cholesterolMg;

  /// Calcium per serving, in milligrams. `null` means unknown.
  final double? calciumMg;

  /// Vitamin D per serving, in micrograms. `null` means unknown.
  final double? vitaminDMcg;

  /// Vitamin C per serving, in milligrams. `null` means unknown.
  final double? vitaminCMg;

  /// EAN/UPC barcode, when this food came from (or was matched to) a
  /// scanned product. `null` for hand-entered foods. Deliberately
  /// **non-unique**: the same product can legitimately exist twice once
  /// provider-sourced rows join user-entered ones (S1-5).
  final String? barcode;

  /// Persisted as one of `FoodSource`'s storage keys (see
  /// `features/nutrition/domain/food.dart`). Defaults to `'custom'` — the
  /// only value anything writes today.
  final String source;

  /// UTC milliseconds since epoch.
  final int createdAt;

  /// UTC milliseconds since epoch.
  final int updatedAt;

  /// UTC milliseconds since epoch; null while the row is live. A genuine
  /// soft-delete marker per ADR 004 (see the class doc for why this table,
  /// unlike `nutrition_entries`, soft-deletes).
  final int? deletedAt;

  /// One of `'local'`, `'pending'`, `'synced'` (outbox/sync status; see ADR
  /// 004). Defaults to `'local'`.
  final String syncStatus;
  const Food({
    required this.id,
    this.providerFoodId,
    required this.name,
    this.brand,
    required this.servingDescription,
    this.servingGrams,
    this.servingVolumeMl,
    required this.caloriesKcal,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.ironMg,
    this.saturatedFatGrams,
    this.transFatGrams,
    this.monounsaturatedFatGrams,
    this.polyunsaturatedFatGrams,
    this.fiberGrams,
    this.sugarsGrams,
    this.addedSugarsGrams,
    this.sodiumMg,
    this.potassiumMg,
    this.cholesterolMg,
    this.calciumMg,
    this.vitaminDMcg,
    this.vitaminCMg,
    this.barcode,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || providerFoodId != null) {
      map['provider_food_id'] = Variable<String>(providerFoodId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    map['serving_description'] = Variable<String>(servingDescription);
    if (!nullToAbsent || servingGrams != null) {
      map['serving_grams'] = Variable<double>(servingGrams);
    }
    if (!nullToAbsent || servingVolumeMl != null) {
      map['serving_volume_ml'] = Variable<double>(servingVolumeMl);
    }
    map['calories_kcal'] = Variable<double>(caloriesKcal);
    map['protein_grams'] = Variable<double>(proteinGrams);
    map['carbs_grams'] = Variable<double>(carbsGrams);
    map['fat_grams'] = Variable<double>(fatGrams);
    if (!nullToAbsent || ironMg != null) {
      map['iron_mg'] = Variable<double>(ironMg);
    }
    if (!nullToAbsent || saturatedFatGrams != null) {
      map['saturated_fat_grams'] = Variable<double>(saturatedFatGrams);
    }
    if (!nullToAbsent || transFatGrams != null) {
      map['trans_fat_grams'] = Variable<double>(transFatGrams);
    }
    if (!nullToAbsent || monounsaturatedFatGrams != null) {
      map['monounsaturated_fat_grams'] = Variable<double>(
        monounsaturatedFatGrams,
      );
    }
    if (!nullToAbsent || polyunsaturatedFatGrams != null) {
      map['polyunsaturated_fat_grams'] = Variable<double>(
        polyunsaturatedFatGrams,
      );
    }
    if (!nullToAbsent || fiberGrams != null) {
      map['fiber_grams'] = Variable<double>(fiberGrams);
    }
    if (!nullToAbsent || sugarsGrams != null) {
      map['sugars_grams'] = Variable<double>(sugarsGrams);
    }
    if (!nullToAbsent || addedSugarsGrams != null) {
      map['added_sugars_grams'] = Variable<double>(addedSugarsGrams);
    }
    if (!nullToAbsent || sodiumMg != null) {
      map['sodium_mg'] = Variable<double>(sodiumMg);
    }
    if (!nullToAbsent || potassiumMg != null) {
      map['potassium_mg'] = Variable<double>(potassiumMg);
    }
    if (!nullToAbsent || cholesterolMg != null) {
      map['cholesterol_mg'] = Variable<double>(cholesterolMg);
    }
    if (!nullToAbsent || calciumMg != null) {
      map['calcium_mg'] = Variable<double>(calciumMg);
    }
    if (!nullToAbsent || vitaminDMcg != null) {
      map['vitamin_d_mcg'] = Variable<double>(vitaminDMcg);
    }
    if (!nullToAbsent || vitaminCMg != null) {
      map['vitamin_c_mg'] = Variable<double>(vitaminCMg);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  FoodsCompanion toCompanion(bool nullToAbsent) {
    return FoodsCompanion(
      id: Value(id),
      providerFoodId: providerFoodId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerFoodId),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      servingDescription: Value(servingDescription),
      servingGrams: servingGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(servingGrams),
      servingVolumeMl: servingVolumeMl == null && nullToAbsent
          ? const Value.absent()
          : Value(servingVolumeMl),
      caloriesKcal: Value(caloriesKcal),
      proteinGrams: Value(proteinGrams),
      carbsGrams: Value(carbsGrams),
      fatGrams: Value(fatGrams),
      ironMg: ironMg == null && nullToAbsent
          ? const Value.absent()
          : Value(ironMg),
      saturatedFatGrams: saturatedFatGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(saturatedFatGrams),
      transFatGrams: transFatGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(transFatGrams),
      monounsaturatedFatGrams: monounsaturatedFatGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(monounsaturatedFatGrams),
      polyunsaturatedFatGrams: polyunsaturatedFatGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(polyunsaturatedFatGrams),
      fiberGrams: fiberGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(fiberGrams),
      sugarsGrams: sugarsGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(sugarsGrams),
      addedSugarsGrams: addedSugarsGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(addedSugarsGrams),
      sodiumMg: sodiumMg == null && nullToAbsent
          ? const Value.absent()
          : Value(sodiumMg),
      potassiumMg: potassiumMg == null && nullToAbsent
          ? const Value.absent()
          : Value(potassiumMg),
      cholesterolMg: cholesterolMg == null && nullToAbsent
          ? const Value.absent()
          : Value(cholesterolMg),
      calciumMg: calciumMg == null && nullToAbsent
          ? const Value.absent()
          : Value(calciumMg),
      vitaminDMcg: vitaminDMcg == null && nullToAbsent
          ? const Value.absent()
          : Value(vitaminDMcg),
      vitaminCMg: vitaminCMg == null && nullToAbsent
          ? const Value.absent()
          : Value(vitaminCMg),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      source: Value(source),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Food.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Food(
      id: serializer.fromJson<String>(json['id']),
      providerFoodId: serializer.fromJson<String?>(json['providerFoodId']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      servingDescription: serializer.fromJson<String>(
        json['servingDescription'],
      ),
      servingGrams: serializer.fromJson<double?>(json['servingGrams']),
      servingVolumeMl: serializer.fromJson<double?>(json['servingVolumeMl']),
      caloriesKcal: serializer.fromJson<double>(json['caloriesKcal']),
      proteinGrams: serializer.fromJson<double>(json['proteinGrams']),
      carbsGrams: serializer.fromJson<double>(json['carbsGrams']),
      fatGrams: serializer.fromJson<double>(json['fatGrams']),
      ironMg: serializer.fromJson<double?>(json['ironMg']),
      saturatedFatGrams: serializer.fromJson<double?>(
        json['saturatedFatGrams'],
      ),
      transFatGrams: serializer.fromJson<double?>(json['transFatGrams']),
      monounsaturatedFatGrams: serializer.fromJson<double?>(
        json['monounsaturatedFatGrams'],
      ),
      polyunsaturatedFatGrams: serializer.fromJson<double?>(
        json['polyunsaturatedFatGrams'],
      ),
      fiberGrams: serializer.fromJson<double?>(json['fiberGrams']),
      sugarsGrams: serializer.fromJson<double?>(json['sugarsGrams']),
      addedSugarsGrams: serializer.fromJson<double?>(json['addedSugarsGrams']),
      sodiumMg: serializer.fromJson<double?>(json['sodiumMg']),
      potassiumMg: serializer.fromJson<double?>(json['potassiumMg']),
      cholesterolMg: serializer.fromJson<double?>(json['cholesterolMg']),
      calciumMg: serializer.fromJson<double?>(json['calciumMg']),
      vitaminDMcg: serializer.fromJson<double?>(json['vitaminDMcg']),
      vitaminCMg: serializer.fromJson<double?>(json['vitaminCMg']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'providerFoodId': serializer.toJson<String?>(providerFoodId),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'servingDescription': serializer.toJson<String>(servingDescription),
      'servingGrams': serializer.toJson<double?>(servingGrams),
      'servingVolumeMl': serializer.toJson<double?>(servingVolumeMl),
      'caloriesKcal': serializer.toJson<double>(caloriesKcal),
      'proteinGrams': serializer.toJson<double>(proteinGrams),
      'carbsGrams': serializer.toJson<double>(carbsGrams),
      'fatGrams': serializer.toJson<double>(fatGrams),
      'ironMg': serializer.toJson<double?>(ironMg),
      'saturatedFatGrams': serializer.toJson<double?>(saturatedFatGrams),
      'transFatGrams': serializer.toJson<double?>(transFatGrams),
      'monounsaturatedFatGrams': serializer.toJson<double?>(
        monounsaturatedFatGrams,
      ),
      'polyunsaturatedFatGrams': serializer.toJson<double?>(
        polyunsaturatedFatGrams,
      ),
      'fiberGrams': serializer.toJson<double?>(fiberGrams),
      'sugarsGrams': serializer.toJson<double?>(sugarsGrams),
      'addedSugarsGrams': serializer.toJson<double?>(addedSugarsGrams),
      'sodiumMg': serializer.toJson<double?>(sodiumMg),
      'potassiumMg': serializer.toJson<double?>(potassiumMg),
      'cholesterolMg': serializer.toJson<double?>(cholesterolMg),
      'calciumMg': serializer.toJson<double?>(calciumMg),
      'vitaminDMcg': serializer.toJson<double?>(vitaminDMcg),
      'vitaminCMg': serializer.toJson<double?>(vitaminCMg),
      'barcode': serializer.toJson<String?>(barcode),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Food copyWith({
    String? id,
    Value<String?> providerFoodId = const Value.absent(),
    String? name,
    Value<String?> brand = const Value.absent(),
    String? servingDescription,
    Value<double?> servingGrams = const Value.absent(),
    Value<double?> servingVolumeMl = const Value.absent(),
    double? caloriesKcal,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    Value<double?> ironMg = const Value.absent(),
    Value<double?> saturatedFatGrams = const Value.absent(),
    Value<double?> transFatGrams = const Value.absent(),
    Value<double?> monounsaturatedFatGrams = const Value.absent(),
    Value<double?> polyunsaturatedFatGrams = const Value.absent(),
    Value<double?> fiberGrams = const Value.absent(),
    Value<double?> sugarsGrams = const Value.absent(),
    Value<double?> addedSugarsGrams = const Value.absent(),
    Value<double?> sodiumMg = const Value.absent(),
    Value<double?> potassiumMg = const Value.absent(),
    Value<double?> cholesterolMg = const Value.absent(),
    Value<double?> calciumMg = const Value.absent(),
    Value<double?> vitaminDMcg = const Value.absent(),
    Value<double?> vitaminCMg = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    String? source,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? syncStatus,
  }) => Food(
    id: id ?? this.id,
    providerFoodId: providerFoodId.present
        ? providerFoodId.value
        : this.providerFoodId,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    servingDescription: servingDescription ?? this.servingDescription,
    servingGrams: servingGrams.present ? servingGrams.value : this.servingGrams,
    servingVolumeMl: servingVolumeMl.present
        ? servingVolumeMl.value
        : this.servingVolumeMl,
    caloriesKcal: caloriesKcal ?? this.caloriesKcal,
    proteinGrams: proteinGrams ?? this.proteinGrams,
    carbsGrams: carbsGrams ?? this.carbsGrams,
    fatGrams: fatGrams ?? this.fatGrams,
    ironMg: ironMg.present ? ironMg.value : this.ironMg,
    saturatedFatGrams: saturatedFatGrams.present
        ? saturatedFatGrams.value
        : this.saturatedFatGrams,
    transFatGrams: transFatGrams.present
        ? transFatGrams.value
        : this.transFatGrams,
    monounsaturatedFatGrams: monounsaturatedFatGrams.present
        ? monounsaturatedFatGrams.value
        : this.monounsaturatedFatGrams,
    polyunsaturatedFatGrams: polyunsaturatedFatGrams.present
        ? polyunsaturatedFatGrams.value
        : this.polyunsaturatedFatGrams,
    fiberGrams: fiberGrams.present ? fiberGrams.value : this.fiberGrams,
    sugarsGrams: sugarsGrams.present ? sugarsGrams.value : this.sugarsGrams,
    addedSugarsGrams: addedSugarsGrams.present
        ? addedSugarsGrams.value
        : this.addedSugarsGrams,
    sodiumMg: sodiumMg.present ? sodiumMg.value : this.sodiumMg,
    potassiumMg: potassiumMg.present ? potassiumMg.value : this.potassiumMg,
    cholesterolMg: cholesterolMg.present
        ? cholesterolMg.value
        : this.cholesterolMg,
    calciumMg: calciumMg.present ? calciumMg.value : this.calciumMg,
    vitaminDMcg: vitaminDMcg.present ? vitaminDMcg.value : this.vitaminDMcg,
    vitaminCMg: vitaminCMg.present ? vitaminCMg.value : this.vitaminCMg,
    barcode: barcode.present ? barcode.value : this.barcode,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Food copyWithCompanion(FoodsCompanion data) {
    return Food(
      id: data.id.present ? data.id.value : this.id,
      providerFoodId: data.providerFoodId.present
          ? data.providerFoodId.value
          : this.providerFoodId,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      servingDescription: data.servingDescription.present
          ? data.servingDescription.value
          : this.servingDescription,
      servingGrams: data.servingGrams.present
          ? data.servingGrams.value
          : this.servingGrams,
      servingVolumeMl: data.servingVolumeMl.present
          ? data.servingVolumeMl.value
          : this.servingVolumeMl,
      caloriesKcal: data.caloriesKcal.present
          ? data.caloriesKcal.value
          : this.caloriesKcal,
      proteinGrams: data.proteinGrams.present
          ? data.proteinGrams.value
          : this.proteinGrams,
      carbsGrams: data.carbsGrams.present
          ? data.carbsGrams.value
          : this.carbsGrams,
      fatGrams: data.fatGrams.present ? data.fatGrams.value : this.fatGrams,
      ironMg: data.ironMg.present ? data.ironMg.value : this.ironMg,
      saturatedFatGrams: data.saturatedFatGrams.present
          ? data.saturatedFatGrams.value
          : this.saturatedFatGrams,
      transFatGrams: data.transFatGrams.present
          ? data.transFatGrams.value
          : this.transFatGrams,
      monounsaturatedFatGrams: data.monounsaturatedFatGrams.present
          ? data.monounsaturatedFatGrams.value
          : this.monounsaturatedFatGrams,
      polyunsaturatedFatGrams: data.polyunsaturatedFatGrams.present
          ? data.polyunsaturatedFatGrams.value
          : this.polyunsaturatedFatGrams,
      fiberGrams: data.fiberGrams.present
          ? data.fiberGrams.value
          : this.fiberGrams,
      sugarsGrams: data.sugarsGrams.present
          ? data.sugarsGrams.value
          : this.sugarsGrams,
      addedSugarsGrams: data.addedSugarsGrams.present
          ? data.addedSugarsGrams.value
          : this.addedSugarsGrams,
      sodiumMg: data.sodiumMg.present ? data.sodiumMg.value : this.sodiumMg,
      potassiumMg: data.potassiumMg.present
          ? data.potassiumMg.value
          : this.potassiumMg,
      cholesterolMg: data.cholesterolMg.present
          ? data.cholesterolMg.value
          : this.cholesterolMg,
      calciumMg: data.calciumMg.present ? data.calciumMg.value : this.calciumMg,
      vitaminDMcg: data.vitaminDMcg.present
          ? data.vitaminDMcg.value
          : this.vitaminDMcg,
      vitaminCMg: data.vitaminCMg.present
          ? data.vitaminCMg.value
          : this.vitaminCMg,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Food(')
          ..write('id: $id, ')
          ..write('providerFoodId: $providerFoodId, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('servingDescription: $servingDescription, ')
          ..write('servingGrams: $servingGrams, ')
          ..write('servingVolumeMl: $servingVolumeMl, ')
          ..write('caloriesKcal: $caloriesKcal, ')
          ..write('proteinGrams: $proteinGrams, ')
          ..write('carbsGrams: $carbsGrams, ')
          ..write('fatGrams: $fatGrams, ')
          ..write('ironMg: $ironMg, ')
          ..write('saturatedFatGrams: $saturatedFatGrams, ')
          ..write('transFatGrams: $transFatGrams, ')
          ..write('monounsaturatedFatGrams: $monounsaturatedFatGrams, ')
          ..write('polyunsaturatedFatGrams: $polyunsaturatedFatGrams, ')
          ..write('fiberGrams: $fiberGrams, ')
          ..write('sugarsGrams: $sugarsGrams, ')
          ..write('addedSugarsGrams: $addedSugarsGrams, ')
          ..write('sodiumMg: $sodiumMg, ')
          ..write('potassiumMg: $potassiumMg, ')
          ..write('cholesterolMg: $cholesterolMg, ')
          ..write('calciumMg: $calciumMg, ')
          ..write('vitaminDMcg: $vitaminDMcg, ')
          ..write('vitaminCMg: $vitaminCMg, ')
          ..write('barcode: $barcode, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    providerFoodId,
    name,
    brand,
    servingDescription,
    servingGrams,
    servingVolumeMl,
    caloriesKcal,
    proteinGrams,
    carbsGrams,
    fatGrams,
    ironMg,
    saturatedFatGrams,
    transFatGrams,
    monounsaturatedFatGrams,
    polyunsaturatedFatGrams,
    fiberGrams,
    sugarsGrams,
    addedSugarsGrams,
    sodiumMg,
    potassiumMg,
    cholesterolMg,
    calciumMg,
    vitaminDMcg,
    vitaminCMg,
    barcode,
    source,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Food &&
          other.id == this.id &&
          other.providerFoodId == this.providerFoodId &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.servingDescription == this.servingDescription &&
          other.servingGrams == this.servingGrams &&
          other.servingVolumeMl == this.servingVolumeMl &&
          other.caloriesKcal == this.caloriesKcal &&
          other.proteinGrams == this.proteinGrams &&
          other.carbsGrams == this.carbsGrams &&
          other.fatGrams == this.fatGrams &&
          other.ironMg == this.ironMg &&
          other.saturatedFatGrams == this.saturatedFatGrams &&
          other.transFatGrams == this.transFatGrams &&
          other.monounsaturatedFatGrams == this.monounsaturatedFatGrams &&
          other.polyunsaturatedFatGrams == this.polyunsaturatedFatGrams &&
          other.fiberGrams == this.fiberGrams &&
          other.sugarsGrams == this.sugarsGrams &&
          other.addedSugarsGrams == this.addedSugarsGrams &&
          other.sodiumMg == this.sodiumMg &&
          other.potassiumMg == this.potassiumMg &&
          other.cholesterolMg == this.cholesterolMg &&
          other.calciumMg == this.calciumMg &&
          other.vitaminDMcg == this.vitaminDMcg &&
          other.vitaminCMg == this.vitaminCMg &&
          other.barcode == this.barcode &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus);
}

class FoodsCompanion extends UpdateCompanion<Food> {
  final Value<String> id;
  final Value<String?> providerFoodId;
  final Value<String> name;
  final Value<String?> brand;
  final Value<String> servingDescription;
  final Value<double?> servingGrams;
  final Value<double?> servingVolumeMl;
  final Value<double> caloriesKcal;
  final Value<double> proteinGrams;
  final Value<double> carbsGrams;
  final Value<double> fatGrams;
  final Value<double?> ironMg;
  final Value<double?> saturatedFatGrams;
  final Value<double?> transFatGrams;
  final Value<double?> monounsaturatedFatGrams;
  final Value<double?> polyunsaturatedFatGrams;
  final Value<double?> fiberGrams;
  final Value<double?> sugarsGrams;
  final Value<double?> addedSugarsGrams;
  final Value<double?> sodiumMg;
  final Value<double?> potassiumMg;
  final Value<double?> cholesterolMg;
  final Value<double?> calciumMg;
  final Value<double?> vitaminDMcg;
  final Value<double?> vitaminCMg;
  final Value<String?> barcode;
  final Value<String> source;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const FoodsCompanion({
    this.id = const Value.absent(),
    this.providerFoodId = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.servingDescription = const Value.absent(),
    this.servingGrams = const Value.absent(),
    this.servingVolumeMl = const Value.absent(),
    this.caloriesKcal = const Value.absent(),
    this.proteinGrams = const Value.absent(),
    this.carbsGrams = const Value.absent(),
    this.fatGrams = const Value.absent(),
    this.ironMg = const Value.absent(),
    this.saturatedFatGrams = const Value.absent(),
    this.transFatGrams = const Value.absent(),
    this.monounsaturatedFatGrams = const Value.absent(),
    this.polyunsaturatedFatGrams = const Value.absent(),
    this.fiberGrams = const Value.absent(),
    this.sugarsGrams = const Value.absent(),
    this.addedSugarsGrams = const Value.absent(),
    this.sodiumMg = const Value.absent(),
    this.potassiumMg = const Value.absent(),
    this.cholesterolMg = const Value.absent(),
    this.calciumMg = const Value.absent(),
    this.vitaminDMcg = const Value.absent(),
    this.vitaminCMg = const Value.absent(),
    this.barcode = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodsCompanion.insert({
    required String id,
    this.providerFoodId = const Value.absent(),
    required String name,
    this.brand = const Value.absent(),
    required String servingDescription,
    this.servingGrams = const Value.absent(),
    this.servingVolumeMl = const Value.absent(),
    required double caloriesKcal,
    required double proteinGrams,
    required double carbsGrams,
    required double fatGrams,
    this.ironMg = const Value.absent(),
    this.saturatedFatGrams = const Value.absent(),
    this.transFatGrams = const Value.absent(),
    this.monounsaturatedFatGrams = const Value.absent(),
    this.polyunsaturatedFatGrams = const Value.absent(),
    this.fiberGrams = const Value.absent(),
    this.sugarsGrams = const Value.absent(),
    this.addedSugarsGrams = const Value.absent(),
    this.sodiumMg = const Value.absent(),
    this.potassiumMg = const Value.absent(),
    this.cholesterolMg = const Value.absent(),
    this.calciumMg = const Value.absent(),
    this.vitaminDMcg = const Value.absent(),
    this.vitaminCMg = const Value.absent(),
    this.barcode = const Value.absent(),
    this.source = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       servingDescription = Value(servingDescription),
       caloriesKcal = Value(caloriesKcal),
       proteinGrams = Value(proteinGrams),
       carbsGrams = Value(carbsGrams),
       fatGrams = Value(fatGrams),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Food> custom({
    Expression<String>? id,
    Expression<String>? providerFoodId,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? servingDescription,
    Expression<double>? servingGrams,
    Expression<double>? servingVolumeMl,
    Expression<double>? caloriesKcal,
    Expression<double>? proteinGrams,
    Expression<double>? carbsGrams,
    Expression<double>? fatGrams,
    Expression<double>? ironMg,
    Expression<double>? saturatedFatGrams,
    Expression<double>? transFatGrams,
    Expression<double>? monounsaturatedFatGrams,
    Expression<double>? polyunsaturatedFatGrams,
    Expression<double>? fiberGrams,
    Expression<double>? sugarsGrams,
    Expression<double>? addedSugarsGrams,
    Expression<double>? sodiumMg,
    Expression<double>? potassiumMg,
    Expression<double>? cholesterolMg,
    Expression<double>? calciumMg,
    Expression<double>? vitaminDMcg,
    Expression<double>? vitaminCMg,
    Expression<String>? barcode,
    Expression<String>? source,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerFoodId != null) 'provider_food_id': providerFoodId,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (servingDescription != null) 'serving_description': servingDescription,
      if (servingGrams != null) 'serving_grams': servingGrams,
      if (servingVolumeMl != null) 'serving_volume_ml': servingVolumeMl,
      if (caloriesKcal != null) 'calories_kcal': caloriesKcal,
      if (proteinGrams != null) 'protein_grams': proteinGrams,
      if (carbsGrams != null) 'carbs_grams': carbsGrams,
      if (fatGrams != null) 'fat_grams': fatGrams,
      if (ironMg != null) 'iron_mg': ironMg,
      if (saturatedFatGrams != null) 'saturated_fat_grams': saturatedFatGrams,
      if (transFatGrams != null) 'trans_fat_grams': transFatGrams,
      if (monounsaturatedFatGrams != null)
        'monounsaturated_fat_grams': monounsaturatedFatGrams,
      if (polyunsaturatedFatGrams != null)
        'polyunsaturated_fat_grams': polyunsaturatedFatGrams,
      if (fiberGrams != null) 'fiber_grams': fiberGrams,
      if (sugarsGrams != null) 'sugars_grams': sugarsGrams,
      if (addedSugarsGrams != null) 'added_sugars_grams': addedSugarsGrams,
      if (sodiumMg != null) 'sodium_mg': sodiumMg,
      if (potassiumMg != null) 'potassium_mg': potassiumMg,
      if (cholesterolMg != null) 'cholesterol_mg': cholesterolMg,
      if (calciumMg != null) 'calcium_mg': calciumMg,
      if (vitaminDMcg != null) 'vitamin_d_mcg': vitaminDMcg,
      if (vitaminCMg != null) 'vitamin_c_mg': vitaminCMg,
      if (barcode != null) 'barcode': barcode,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodsCompanion copyWith({
    Value<String>? id,
    Value<String?>? providerFoodId,
    Value<String>? name,
    Value<String?>? brand,
    Value<String>? servingDescription,
    Value<double?>? servingGrams,
    Value<double?>? servingVolumeMl,
    Value<double>? caloriesKcal,
    Value<double>? proteinGrams,
    Value<double>? carbsGrams,
    Value<double>? fatGrams,
    Value<double?>? ironMg,
    Value<double?>? saturatedFatGrams,
    Value<double?>? transFatGrams,
    Value<double?>? monounsaturatedFatGrams,
    Value<double?>? polyunsaturatedFatGrams,
    Value<double?>? fiberGrams,
    Value<double?>? sugarsGrams,
    Value<double?>? addedSugarsGrams,
    Value<double?>? sodiumMg,
    Value<double?>? potassiumMg,
    Value<double?>? cholesterolMg,
    Value<double?>? calciumMg,
    Value<double?>? vitaminDMcg,
    Value<double?>? vitaminCMg,
    Value<String?>? barcode,
    Value<String>? source,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return FoodsCompanion(
      id: id ?? this.id,
      providerFoodId: providerFoodId ?? this.providerFoodId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      servingDescription: servingDescription ?? this.servingDescription,
      servingGrams: servingGrams ?? this.servingGrams,
      servingVolumeMl: servingVolumeMl ?? this.servingVolumeMl,
      caloriesKcal: caloriesKcal ?? this.caloriesKcal,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      ironMg: ironMg ?? this.ironMg,
      saturatedFatGrams: saturatedFatGrams ?? this.saturatedFatGrams,
      transFatGrams: transFatGrams ?? this.transFatGrams,
      monounsaturatedFatGrams:
          monounsaturatedFatGrams ?? this.monounsaturatedFatGrams,
      polyunsaturatedFatGrams:
          polyunsaturatedFatGrams ?? this.polyunsaturatedFatGrams,
      fiberGrams: fiberGrams ?? this.fiberGrams,
      sugarsGrams: sugarsGrams ?? this.sugarsGrams,
      addedSugarsGrams: addedSugarsGrams ?? this.addedSugarsGrams,
      sodiumMg: sodiumMg ?? this.sodiumMg,
      potassiumMg: potassiumMg ?? this.potassiumMg,
      cholesterolMg: cholesterolMg ?? this.cholesterolMg,
      calciumMg: calciumMg ?? this.calciumMg,
      vitaminDMcg: vitaminDMcg ?? this.vitaminDMcg,
      vitaminCMg: vitaminCMg ?? this.vitaminCMg,
      barcode: barcode ?? this.barcode,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (providerFoodId.present) {
      map['provider_food_id'] = Variable<String>(providerFoodId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (servingDescription.present) {
      map['serving_description'] = Variable<String>(servingDescription.value);
    }
    if (servingGrams.present) {
      map['serving_grams'] = Variable<double>(servingGrams.value);
    }
    if (servingVolumeMl.present) {
      map['serving_volume_ml'] = Variable<double>(servingVolumeMl.value);
    }
    if (caloriesKcal.present) {
      map['calories_kcal'] = Variable<double>(caloriesKcal.value);
    }
    if (proteinGrams.present) {
      map['protein_grams'] = Variable<double>(proteinGrams.value);
    }
    if (carbsGrams.present) {
      map['carbs_grams'] = Variable<double>(carbsGrams.value);
    }
    if (fatGrams.present) {
      map['fat_grams'] = Variable<double>(fatGrams.value);
    }
    if (ironMg.present) {
      map['iron_mg'] = Variable<double>(ironMg.value);
    }
    if (saturatedFatGrams.present) {
      map['saturated_fat_grams'] = Variable<double>(saturatedFatGrams.value);
    }
    if (transFatGrams.present) {
      map['trans_fat_grams'] = Variable<double>(transFatGrams.value);
    }
    if (monounsaturatedFatGrams.present) {
      map['monounsaturated_fat_grams'] = Variable<double>(
        monounsaturatedFatGrams.value,
      );
    }
    if (polyunsaturatedFatGrams.present) {
      map['polyunsaturated_fat_grams'] = Variable<double>(
        polyunsaturatedFatGrams.value,
      );
    }
    if (fiberGrams.present) {
      map['fiber_grams'] = Variable<double>(fiberGrams.value);
    }
    if (sugarsGrams.present) {
      map['sugars_grams'] = Variable<double>(sugarsGrams.value);
    }
    if (addedSugarsGrams.present) {
      map['added_sugars_grams'] = Variable<double>(addedSugarsGrams.value);
    }
    if (sodiumMg.present) {
      map['sodium_mg'] = Variable<double>(sodiumMg.value);
    }
    if (potassiumMg.present) {
      map['potassium_mg'] = Variable<double>(potassiumMg.value);
    }
    if (cholesterolMg.present) {
      map['cholesterol_mg'] = Variable<double>(cholesterolMg.value);
    }
    if (calciumMg.present) {
      map['calcium_mg'] = Variable<double>(calciumMg.value);
    }
    if (vitaminDMcg.present) {
      map['vitamin_d_mcg'] = Variable<double>(vitaminDMcg.value);
    }
    if (vitaminCMg.present) {
      map['vitamin_c_mg'] = Variable<double>(vitaminCMg.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodsCompanion(')
          ..write('id: $id, ')
          ..write('providerFoodId: $providerFoodId, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('servingDescription: $servingDescription, ')
          ..write('servingGrams: $servingGrams, ')
          ..write('servingVolumeMl: $servingVolumeMl, ')
          ..write('caloriesKcal: $caloriesKcal, ')
          ..write('proteinGrams: $proteinGrams, ')
          ..write('carbsGrams: $carbsGrams, ')
          ..write('fatGrams: $fatGrams, ')
          ..write('ironMg: $ironMg, ')
          ..write('saturatedFatGrams: $saturatedFatGrams, ')
          ..write('transFatGrams: $transFatGrams, ')
          ..write('monounsaturatedFatGrams: $monounsaturatedFatGrams, ')
          ..write('polyunsaturatedFatGrams: $polyunsaturatedFatGrams, ')
          ..write('fiberGrams: $fiberGrams, ')
          ..write('sugarsGrams: $sugarsGrams, ')
          ..write('addedSugarsGrams: $addedSugarsGrams, ')
          ..write('sodiumMg: $sodiumMg, ')
          ..write('potassiumMg: $potassiumMg, ')
          ..write('cholesterolMg: $cholesterolMg, ')
          ..write('calciumMg: $calciumMg, ')
          ..write('vitaminDMcg: $vitaminDMcg, ')
          ..write('vitaminCMg: $vitaminCMg, ')
          ..write('barcode: $barcode, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NutritionEntriesTable extends NutritionEntries
    with TableInfo<$NutritionEntriesTable, NutritionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NutritionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealMeta = const VerificationMeta('meal');
  @override
  late final GeneratedColumn<String> meal = GeneratedColumn<String>(
    'meal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<String> foodId = GeneratedColumn<String>(
    'food_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _foodNameMeta = const VerificationMeta(
    'foodName',
  );
  @override
  late final GeneratedColumn<String> foodName = GeneratedColumn<String>(
    'food_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodBrandMeta = const VerificationMeta(
    'foodBrand',
  );
  @override
  late final GeneratedColumn<String> foodBrand = GeneratedColumn<String>(
    'food_brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _servingDescriptionMeta =
      const VerificationMeta('servingDescription');
  @override
  late final GeneratedColumn<String> servingDescription =
      GeneratedColumn<String>(
        'serving_description',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _quantityServingsMeta = const VerificationMeta(
    'quantityServings',
  );
  @override
  late final GeneratedColumn<double> quantityServings = GeneratedColumn<double>(
    'quantity_servings',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityAmountMeta = const VerificationMeta(
    'quantityAmount',
  );
  @override
  late final GeneratedColumn<double> quantityAmount = GeneratedColumn<double>(
    'quantity_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _quantityUnitMeta = const VerificationMeta(
    'quantityUnit',
  );
  @override
  late final GeneratedColumn<String> quantityUnit = GeneratedColumn<String>(
    'quantity_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('serving'),
  );
  static const VerificationMeta _servingGramsMeta = const VerificationMeta(
    'servingGrams',
  );
  @override
  late final GeneratedColumn<double> servingGrams = GeneratedColumn<double>(
    'serving_grams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _servingVolumeMlMeta = const VerificationMeta(
    'servingVolumeMl',
  );
  @override
  late final GeneratedColumn<double> servingVolumeMl = GeneratedColumn<double>(
    'serving_volume_ml',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caloriesKcalMeta = const VerificationMeta(
    'caloriesKcal',
  );
  @override
  late final GeneratedColumn<double> caloriesKcal = GeneratedColumn<double>(
    'calories_kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinGramsMeta = const VerificationMeta(
    'proteinGrams',
  );
  @override
  late final GeneratedColumn<double> proteinGrams = GeneratedColumn<double>(
    'protein_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsGramsMeta = const VerificationMeta(
    'carbsGrams',
  );
  @override
  late final GeneratedColumn<double> carbsGrams = GeneratedColumn<double>(
    'carbs_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatGramsMeta = const VerificationMeta(
    'fatGrams',
  );
  @override
  late final GeneratedColumn<double> fatGrams = GeneratedColumn<double>(
    'fat_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ironMgMeta = const VerificationMeta('ironMg');
  @override
  late final GeneratedColumn<double> ironMg = GeneratedColumn<double>(
    'iron_mg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _saturatedFatGramsMeta = const VerificationMeta(
    'saturatedFatGrams',
  );
  @override
  late final GeneratedColumn<double> saturatedFatGrams =
      GeneratedColumn<double>(
        'saturated_fat_grams',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _transFatGramsMeta = const VerificationMeta(
    'transFatGrams',
  );
  @override
  late final GeneratedColumn<double> transFatGrams = GeneratedColumn<double>(
    'trans_fat_grams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monounsaturatedFatGramsMeta =
      const VerificationMeta('monounsaturatedFatGrams');
  @override
  late final GeneratedColumn<double> monounsaturatedFatGrams =
      GeneratedColumn<double>(
        'monounsaturated_fat_grams',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _polyunsaturatedFatGramsMeta =
      const VerificationMeta('polyunsaturatedFatGrams');
  @override
  late final GeneratedColumn<double> polyunsaturatedFatGrams =
      GeneratedColumn<double>(
        'polyunsaturated_fat_grams',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fiberGramsMeta = const VerificationMeta(
    'fiberGrams',
  );
  @override
  late final GeneratedColumn<double> fiberGrams = GeneratedColumn<double>(
    'fiber_grams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sugarsGramsMeta = const VerificationMeta(
    'sugarsGrams',
  );
  @override
  late final GeneratedColumn<double> sugarsGrams = GeneratedColumn<double>(
    'sugars_grams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedSugarsGramsMeta = const VerificationMeta(
    'addedSugarsGrams',
  );
  @override
  late final GeneratedColumn<double> addedSugarsGrams = GeneratedColumn<double>(
    'added_sugars_grams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sodiumMgMeta = const VerificationMeta(
    'sodiumMg',
  );
  @override
  late final GeneratedColumn<double> sodiumMg = GeneratedColumn<double>(
    'sodium_mg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _potassiumMgMeta = const VerificationMeta(
    'potassiumMg',
  );
  @override
  late final GeneratedColumn<double> potassiumMg = GeneratedColumn<double>(
    'potassium_mg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cholesterolMgMeta = const VerificationMeta(
    'cholesterolMg',
  );
  @override
  late final GeneratedColumn<double> cholesterolMg = GeneratedColumn<double>(
    'cholesterol_mg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _calciumMgMeta = const VerificationMeta(
    'calciumMg',
  );
  @override
  late final GeneratedColumn<double> calciumMg = GeneratedColumn<double>(
    'calcium_mg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vitaminDMcgMeta = const VerificationMeta(
    'vitaminDMcg',
  );
  @override
  late final GeneratedColumn<double> vitaminDMcg = GeneratedColumn<double>(
    'vitamin_d_mcg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vitaminCMgMeta = const VerificationMeta(
    'vitaminCMg',
  );
  @override
  late final GeneratedColumn<double> vitaminCMg = GeneratedColumn<double>(
    'vitamin_c_mg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    meal,
    foodId,
    foodName,
    foodBrand,
    servingDescription,
    quantityServings,
    quantityAmount,
    quantityUnit,
    servingGrams,
    servingVolumeMl,
    caloriesKcal,
    proteinGrams,
    carbsGrams,
    fatGrams,
    ironMg,
    saturatedFatGrams,
    transFatGrams,
    monounsaturatedFatGrams,
    polyunsaturatedFatGrams,
    fiberGrams,
    sugarsGrams,
    addedSugarsGrams,
    sodiumMg,
    potassiumMg,
    cholesterolMg,
    calciumMg,
    vitaminDMcg,
    vitaminCMg,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nutrition_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<NutritionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('meal')) {
      context.handle(
        _mealMeta,
        meal.isAcceptableOrUnknown(data['meal']!, _mealMeta),
      );
    } else if (isInserting) {
      context.missing(_mealMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    }
    if (data.containsKey('food_name')) {
      context.handle(
        _foodNameMeta,
        foodName.isAcceptableOrUnknown(data['food_name']!, _foodNameMeta),
      );
    } else if (isInserting) {
      context.missing(_foodNameMeta);
    }
    if (data.containsKey('food_brand')) {
      context.handle(
        _foodBrandMeta,
        foodBrand.isAcceptableOrUnknown(data['food_brand']!, _foodBrandMeta),
      );
    }
    if (data.containsKey('serving_description')) {
      context.handle(
        _servingDescriptionMeta,
        servingDescription.isAcceptableOrUnknown(
          data['serving_description']!,
          _servingDescriptionMeta,
        ),
      );
    }
    if (data.containsKey('quantity_servings')) {
      context.handle(
        _quantityServingsMeta,
        quantityServings.isAcceptableOrUnknown(
          data['quantity_servings']!,
          _quantityServingsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityServingsMeta);
    }
    if (data.containsKey('quantity_amount')) {
      context.handle(
        _quantityAmountMeta,
        quantityAmount.isAcceptableOrUnknown(
          data['quantity_amount']!,
          _quantityAmountMeta,
        ),
      );
    }
    if (data.containsKey('quantity_unit')) {
      context.handle(
        _quantityUnitMeta,
        quantityUnit.isAcceptableOrUnknown(
          data['quantity_unit']!,
          _quantityUnitMeta,
        ),
      );
    }
    if (data.containsKey('serving_grams')) {
      context.handle(
        _servingGramsMeta,
        servingGrams.isAcceptableOrUnknown(
          data['serving_grams']!,
          _servingGramsMeta,
        ),
      );
    }
    if (data.containsKey('serving_volume_ml')) {
      context.handle(
        _servingVolumeMlMeta,
        servingVolumeMl.isAcceptableOrUnknown(
          data['serving_volume_ml']!,
          _servingVolumeMlMeta,
        ),
      );
    }
    if (data.containsKey('calories_kcal')) {
      context.handle(
        _caloriesKcalMeta,
        caloriesKcal.isAcceptableOrUnknown(
          data['calories_kcal']!,
          _caloriesKcalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_caloriesKcalMeta);
    }
    if (data.containsKey('protein_grams')) {
      context.handle(
        _proteinGramsMeta,
        proteinGrams.isAcceptableOrUnknown(
          data['protein_grams']!,
          _proteinGramsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinGramsMeta);
    }
    if (data.containsKey('carbs_grams')) {
      context.handle(
        _carbsGramsMeta,
        carbsGrams.isAcceptableOrUnknown(data['carbs_grams']!, _carbsGramsMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsGramsMeta);
    }
    if (data.containsKey('fat_grams')) {
      context.handle(
        _fatGramsMeta,
        fatGrams.isAcceptableOrUnknown(data['fat_grams']!, _fatGramsMeta),
      );
    } else if (isInserting) {
      context.missing(_fatGramsMeta);
    }
    if (data.containsKey('iron_mg')) {
      context.handle(
        _ironMgMeta,
        ironMg.isAcceptableOrUnknown(data['iron_mg']!, _ironMgMeta),
      );
    }
    if (data.containsKey('saturated_fat_grams')) {
      context.handle(
        _saturatedFatGramsMeta,
        saturatedFatGrams.isAcceptableOrUnknown(
          data['saturated_fat_grams']!,
          _saturatedFatGramsMeta,
        ),
      );
    }
    if (data.containsKey('trans_fat_grams')) {
      context.handle(
        _transFatGramsMeta,
        transFatGrams.isAcceptableOrUnknown(
          data['trans_fat_grams']!,
          _transFatGramsMeta,
        ),
      );
    }
    if (data.containsKey('monounsaturated_fat_grams')) {
      context.handle(
        _monounsaturatedFatGramsMeta,
        monounsaturatedFatGrams.isAcceptableOrUnknown(
          data['monounsaturated_fat_grams']!,
          _monounsaturatedFatGramsMeta,
        ),
      );
    }
    if (data.containsKey('polyunsaturated_fat_grams')) {
      context.handle(
        _polyunsaturatedFatGramsMeta,
        polyunsaturatedFatGrams.isAcceptableOrUnknown(
          data['polyunsaturated_fat_grams']!,
          _polyunsaturatedFatGramsMeta,
        ),
      );
    }
    if (data.containsKey('fiber_grams')) {
      context.handle(
        _fiberGramsMeta,
        fiberGrams.isAcceptableOrUnknown(data['fiber_grams']!, _fiberGramsMeta),
      );
    }
    if (data.containsKey('sugars_grams')) {
      context.handle(
        _sugarsGramsMeta,
        sugarsGrams.isAcceptableOrUnknown(
          data['sugars_grams']!,
          _sugarsGramsMeta,
        ),
      );
    }
    if (data.containsKey('added_sugars_grams')) {
      context.handle(
        _addedSugarsGramsMeta,
        addedSugarsGrams.isAcceptableOrUnknown(
          data['added_sugars_grams']!,
          _addedSugarsGramsMeta,
        ),
      );
    }
    if (data.containsKey('sodium_mg')) {
      context.handle(
        _sodiumMgMeta,
        sodiumMg.isAcceptableOrUnknown(data['sodium_mg']!, _sodiumMgMeta),
      );
    }
    if (data.containsKey('potassium_mg')) {
      context.handle(
        _potassiumMgMeta,
        potassiumMg.isAcceptableOrUnknown(
          data['potassium_mg']!,
          _potassiumMgMeta,
        ),
      );
    }
    if (data.containsKey('cholesterol_mg')) {
      context.handle(
        _cholesterolMgMeta,
        cholesterolMg.isAcceptableOrUnknown(
          data['cholesterol_mg']!,
          _cholesterolMgMeta,
        ),
      );
    }
    if (data.containsKey('calcium_mg')) {
      context.handle(
        _calciumMgMeta,
        calciumMg.isAcceptableOrUnknown(data['calcium_mg']!, _calciumMgMeta),
      );
    }
    if (data.containsKey('vitamin_d_mcg')) {
      context.handle(
        _vitaminDMcgMeta,
        vitaminDMcg.isAcceptableOrUnknown(
          data['vitamin_d_mcg']!,
          _vitaminDMcgMeta,
        ),
      );
    }
    if (data.containsKey('vitamin_c_mg')) {
      context.handle(
        _vitaminCMgMeta,
        vitaminCMg.isAcceptableOrUnknown(
          data['vitamin_c_mg']!,
          _vitaminCMgMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NutritionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NutritionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      meal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_id'],
      ),
      foodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_name'],
      )!,
      foodBrand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_brand'],
      ),
      servingDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_description'],
      ),
      quantityServings: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_servings'],
      )!,
      quantityAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_amount'],
      )!,
      quantityUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity_unit'],
      )!,
      servingGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}serving_grams'],
      ),
      servingVolumeMl: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}serving_volume_ml'],
      ),
      caloriesKcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories_kcal'],
      )!,
      proteinGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_grams'],
      )!,
      carbsGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_grams'],
      )!,
      fatGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_grams'],
      )!,
      ironMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}iron_mg'],
      ),
      saturatedFatGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}saturated_fat_grams'],
      ),
      transFatGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}trans_fat_grams'],
      ),
      monounsaturatedFatGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monounsaturated_fat_grams'],
      ),
      polyunsaturatedFatGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}polyunsaturated_fat_grams'],
      ),
      fiberGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber_grams'],
      ),
      sugarsGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sugars_grams'],
      ),
      addedSugarsGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}added_sugars_grams'],
      ),
      sodiumMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sodium_mg'],
      ),
      potassiumMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}potassium_mg'],
      ),
      cholesterolMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cholesterol_mg'],
      ),
      calciumMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calcium_mg'],
      ),
      vitaminDMcg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vitamin_d_mcg'],
      ),
      vitaminCMg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vitamin_c_mg'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $NutritionEntriesTable createAlias(String alias) {
    return $NutritionEntriesTable(attachedDatabase, alias);
  }
}

class NutritionEntry extends DataClass implements Insertable<NutritionEntry> {
  /// Client-generated UUIDv7.
  final String id;

  /// ISO-8601 date string (`YYYY-MM-DD`), user-local calendar day.
  /// Non-unique — many entries per day.
  final String day;

  /// Persisted as one of `MealType`'s storage keys (see
  /// `features/nutrition/domain/meal_type.dart`).
  final String meal;

  /// The `foods.id` this entry was logged from, if that food still needs to
  /// be reachable for "log again". Plain nullable TEXT with **no FK
  /// constraint** — same choice, for the same reason, as
  /// `activities.route_id`: the food may be soft- or hard-deleted
  /// independently and this entry must survive that intact (see the class
  /// doc's snapshot section).
  final String? foodId;

  /// The food's name as it stood at log time. Snapshotted for the same
  /// reason as the nutrition numbers: an entry must stay displayable
  /// without a join, and without depending on a row that may be gone.
  final String foodName;

  /// The food's brand as it stood at log time, when it had one.
  final String? foodBrand;

  /// The food's serving description as it stood at log time, e.g.
  /// `'1 cup (dry)'`. `null` for entries whose source food had none.
  final String? servingDescription;

  /// How many servings were eaten — the **canonical multiplier**, and the
  /// only quantity column the nutrition arithmetic reads. Always greater
  /// than zero (enforced by
  /// `features/nutrition/domain/nutrition_validation.dart`); fractional
  /// values are normal.
  ///
  /// [quantityAmount]/[quantityUnit] below record how that number was
  /// *expressed*; they never change what it means.
  final double quantityServings;

  /// The number the user actually typed, in [quantityUnit] — `47` for
  /// "47 g", `1.5` for "1.5 servings".
  ///
  /// Stored alongside [quantityServings] rather than instead of it: the
  /// diary has to be able to show them back what they entered, while every
  /// total keeps multiplying by servings. The two are derived from each
  /// other through `features/nutrition/domain/quantity_unit.dart` and
  /// `NutritionEntry.fromFood` is the only place that derivation happens.
  ///
  /// The default exists for `ALTER TABLE`'s sake — SQLite cannot add a
  /// NOT NULL column without one — and for a fresh insert that omits it.
  /// It is emphatically *not* what pre-v13 rows mean: the v13 migration
  /// step backfills every existing row from `quantity_servings` explicitly
  /// (see `core/db/app_database.dart`), because those rows were all logged
  /// in servings and `1` would silently claim otherwise.
  final double quantityAmount;

  /// One of `QuantityUnit`'s storage keys (see
  /// `features/nutrition/domain/quantity_unit.dart`), defaulting to
  /// `'serving'`.
  ///
  /// The default is the honest reading of every row written before this
  /// column existed — servings were the only thing that could be logged —
  /// and `QuantityUnit.fromStorage` reads an unrecognised key the same way.
  final String quantityUnit;

  /// Snapshot: the food's grams per serving at log time. `null` when the
  /// food had no recorded serving weight.
  ///
  /// Snapshotted for exactly the reason the nutrition numbers are (see the
  /// class doc): "47 g" only means a serving count *against a particular
  /// serving weight*. Correcting a food's serving weight next month must
  /// not retroactively re-interpret what 47 g meant in an entry logged
  /// today — and re-displaying or editing that entry has to use the weight
  /// it was logged against, not today's.
  ///
  /// `null` is also what `quantity_unit.dart` reads as "weight units are
  /// unavailable for this entry", which is the correct state for every
  /// pre-v13 row: nothing was recorded, so nothing may be assumed.
  final double? servingGrams;

  /// Snapshot: the food's volume in millilitres per serving at log time.
  /// `null` when the food had no recorded serving volume.
  final double? servingVolumeMl;

  /// Snapshot: energy per serving at log time, in kilocalories.
  final double caloriesKcal;

  /// Snapshot: protein per serving at log time, in grams.
  final double proteinGrams;

  /// Snapshot: carbohydrate per serving at log time, in grams.
  final double carbsGrams;

  /// Snapshot: fat per serving at log time, in grams.
  final double fatGrams;

  /// Snapshot: iron per serving at log time, in milligrams. `null` means
  /// the food didn't state iron — never zero (see `foods.dart`'s class
  /// doc).
  final double? ironMg;

  /// Snapshot: saturated fat per serving at log time, in grams.
  /// `null` means **unknown** — the same rule [ironMg] follows, and the
  /// reason every column below is nullable (see `foods.dart`'s class
  /// doc).
  final double? saturatedFatGrams;

  /// Snapshot: trans fat per serving at log time, in grams. `null` means
  /// unknown.
  final double? transFatGrams;

  /// Snapshot: monounsaturated fat per serving at log time, in grams.
  /// `null` means unknown.
  final double? monounsaturatedFatGrams;

  /// Snapshot: polyunsaturated fat per serving at log time, in grams.
  /// `null` means unknown.
  final double? polyunsaturatedFatGrams;

  /// Snapshot: dietary fibre per serving at log time, in grams. `null` means
  /// unknown.
  final double? fiberGrams;

  /// Snapshot: total sugars per serving at log time, in grams. `null` means
  /// unknown.
  final double? sugarsGrams;

  /// Snapshot: added sugars per serving at log time, in grams. `null` means
  /// unknown.
  final double? addedSugarsGrams;

  /// Snapshot: sodium per serving at log time, in milligrams. `null` means
  /// unknown.
  final double? sodiumMg;

  /// Snapshot: potassium per serving at log time, in milligrams. `null` means
  /// unknown.
  final double? potassiumMg;

  /// Snapshot: cholesterol per serving at log time, in milligrams. `null` means
  /// unknown.
  final double? cholesterolMg;

  /// Snapshot: calcium per serving at log time, in milligrams. `null` means
  /// unknown.
  final double? calciumMg;

  /// Snapshot: vitamin D per serving at log time, in micrograms. `null` means
  /// unknown.
  final double? vitaminDMcg;

  /// Snapshot: vitamin C per serving at log time, in milligrams. `null` means
  /// unknown.
  final double? vitaminCMg;

  /// UTC milliseconds since epoch.
  final int createdAt;

  /// UTC milliseconds since epoch.
  final int updatedAt;

  /// UTC milliseconds since epoch; null while the row is live. Kept for
  /// column-shape consistency with other tables, but
  /// `DriftNutritionRepository.deleteEntry` hard-deletes instead (see the
  /// class doc) — should always read `null`.
  final int? deletedAt;

  /// One of `'local'`, `'pending'`, `'synced'` (outbox/sync status; see ADR
  /// 004). Defaults to `'local'`.
  final String syncStatus;
  const NutritionEntry({
    required this.id,
    required this.day,
    required this.meal,
    this.foodId,
    required this.foodName,
    this.foodBrand,
    this.servingDescription,
    required this.quantityServings,
    required this.quantityAmount,
    required this.quantityUnit,
    this.servingGrams,
    this.servingVolumeMl,
    required this.caloriesKcal,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.ironMg,
    this.saturatedFatGrams,
    this.transFatGrams,
    this.monounsaturatedFatGrams,
    this.polyunsaturatedFatGrams,
    this.fiberGrams,
    this.sugarsGrams,
    this.addedSugarsGrams,
    this.sodiumMg,
    this.potassiumMg,
    this.cholesterolMg,
    this.calciumMg,
    this.vitaminDMcg,
    this.vitaminCMg,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day'] = Variable<String>(day);
    map['meal'] = Variable<String>(meal);
    if (!nullToAbsent || foodId != null) {
      map['food_id'] = Variable<String>(foodId);
    }
    map['food_name'] = Variable<String>(foodName);
    if (!nullToAbsent || foodBrand != null) {
      map['food_brand'] = Variable<String>(foodBrand);
    }
    if (!nullToAbsent || servingDescription != null) {
      map['serving_description'] = Variable<String>(servingDescription);
    }
    map['quantity_servings'] = Variable<double>(quantityServings);
    map['quantity_amount'] = Variable<double>(quantityAmount);
    map['quantity_unit'] = Variable<String>(quantityUnit);
    if (!nullToAbsent || servingGrams != null) {
      map['serving_grams'] = Variable<double>(servingGrams);
    }
    if (!nullToAbsent || servingVolumeMl != null) {
      map['serving_volume_ml'] = Variable<double>(servingVolumeMl);
    }
    map['calories_kcal'] = Variable<double>(caloriesKcal);
    map['protein_grams'] = Variable<double>(proteinGrams);
    map['carbs_grams'] = Variable<double>(carbsGrams);
    map['fat_grams'] = Variable<double>(fatGrams);
    if (!nullToAbsent || ironMg != null) {
      map['iron_mg'] = Variable<double>(ironMg);
    }
    if (!nullToAbsent || saturatedFatGrams != null) {
      map['saturated_fat_grams'] = Variable<double>(saturatedFatGrams);
    }
    if (!nullToAbsent || transFatGrams != null) {
      map['trans_fat_grams'] = Variable<double>(transFatGrams);
    }
    if (!nullToAbsent || monounsaturatedFatGrams != null) {
      map['monounsaturated_fat_grams'] = Variable<double>(
        monounsaturatedFatGrams,
      );
    }
    if (!nullToAbsent || polyunsaturatedFatGrams != null) {
      map['polyunsaturated_fat_grams'] = Variable<double>(
        polyunsaturatedFatGrams,
      );
    }
    if (!nullToAbsent || fiberGrams != null) {
      map['fiber_grams'] = Variable<double>(fiberGrams);
    }
    if (!nullToAbsent || sugarsGrams != null) {
      map['sugars_grams'] = Variable<double>(sugarsGrams);
    }
    if (!nullToAbsent || addedSugarsGrams != null) {
      map['added_sugars_grams'] = Variable<double>(addedSugarsGrams);
    }
    if (!nullToAbsent || sodiumMg != null) {
      map['sodium_mg'] = Variable<double>(sodiumMg);
    }
    if (!nullToAbsent || potassiumMg != null) {
      map['potassium_mg'] = Variable<double>(potassiumMg);
    }
    if (!nullToAbsent || cholesterolMg != null) {
      map['cholesterol_mg'] = Variable<double>(cholesterolMg);
    }
    if (!nullToAbsent || calciumMg != null) {
      map['calcium_mg'] = Variable<double>(calciumMg);
    }
    if (!nullToAbsent || vitaminDMcg != null) {
      map['vitamin_d_mcg'] = Variable<double>(vitaminDMcg);
    }
    if (!nullToAbsent || vitaminCMg != null) {
      map['vitamin_c_mg'] = Variable<double>(vitaminCMg);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  NutritionEntriesCompanion toCompanion(bool nullToAbsent) {
    return NutritionEntriesCompanion(
      id: Value(id),
      day: Value(day),
      meal: Value(meal),
      foodId: foodId == null && nullToAbsent
          ? const Value.absent()
          : Value(foodId),
      foodName: Value(foodName),
      foodBrand: foodBrand == null && nullToAbsent
          ? const Value.absent()
          : Value(foodBrand),
      servingDescription: servingDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(servingDescription),
      quantityServings: Value(quantityServings),
      quantityAmount: Value(quantityAmount),
      quantityUnit: Value(quantityUnit),
      servingGrams: servingGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(servingGrams),
      servingVolumeMl: servingVolumeMl == null && nullToAbsent
          ? const Value.absent()
          : Value(servingVolumeMl),
      caloriesKcal: Value(caloriesKcal),
      proteinGrams: Value(proteinGrams),
      carbsGrams: Value(carbsGrams),
      fatGrams: Value(fatGrams),
      ironMg: ironMg == null && nullToAbsent
          ? const Value.absent()
          : Value(ironMg),
      saturatedFatGrams: saturatedFatGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(saturatedFatGrams),
      transFatGrams: transFatGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(transFatGrams),
      monounsaturatedFatGrams: monounsaturatedFatGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(monounsaturatedFatGrams),
      polyunsaturatedFatGrams: polyunsaturatedFatGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(polyunsaturatedFatGrams),
      fiberGrams: fiberGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(fiberGrams),
      sugarsGrams: sugarsGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(sugarsGrams),
      addedSugarsGrams: addedSugarsGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(addedSugarsGrams),
      sodiumMg: sodiumMg == null && nullToAbsent
          ? const Value.absent()
          : Value(sodiumMg),
      potassiumMg: potassiumMg == null && nullToAbsent
          ? const Value.absent()
          : Value(potassiumMg),
      cholesterolMg: cholesterolMg == null && nullToAbsent
          ? const Value.absent()
          : Value(cholesterolMg),
      calciumMg: calciumMg == null && nullToAbsent
          ? const Value.absent()
          : Value(calciumMg),
      vitaminDMcg: vitaminDMcg == null && nullToAbsent
          ? const Value.absent()
          : Value(vitaminDMcg),
      vitaminCMg: vitaminCMg == null && nullToAbsent
          ? const Value.absent()
          : Value(vitaminCMg),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory NutritionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NutritionEntry(
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      meal: serializer.fromJson<String>(json['meal']),
      foodId: serializer.fromJson<String?>(json['foodId']),
      foodName: serializer.fromJson<String>(json['foodName']),
      foodBrand: serializer.fromJson<String?>(json['foodBrand']),
      servingDescription: serializer.fromJson<String?>(
        json['servingDescription'],
      ),
      quantityServings: serializer.fromJson<double>(json['quantityServings']),
      quantityAmount: serializer.fromJson<double>(json['quantityAmount']),
      quantityUnit: serializer.fromJson<String>(json['quantityUnit']),
      servingGrams: serializer.fromJson<double?>(json['servingGrams']),
      servingVolumeMl: serializer.fromJson<double?>(json['servingVolumeMl']),
      caloriesKcal: serializer.fromJson<double>(json['caloriesKcal']),
      proteinGrams: serializer.fromJson<double>(json['proteinGrams']),
      carbsGrams: serializer.fromJson<double>(json['carbsGrams']),
      fatGrams: serializer.fromJson<double>(json['fatGrams']),
      ironMg: serializer.fromJson<double?>(json['ironMg']),
      saturatedFatGrams: serializer.fromJson<double?>(
        json['saturatedFatGrams'],
      ),
      transFatGrams: serializer.fromJson<double?>(json['transFatGrams']),
      monounsaturatedFatGrams: serializer.fromJson<double?>(
        json['monounsaturatedFatGrams'],
      ),
      polyunsaturatedFatGrams: serializer.fromJson<double?>(
        json['polyunsaturatedFatGrams'],
      ),
      fiberGrams: serializer.fromJson<double?>(json['fiberGrams']),
      sugarsGrams: serializer.fromJson<double?>(json['sugarsGrams']),
      addedSugarsGrams: serializer.fromJson<double?>(json['addedSugarsGrams']),
      sodiumMg: serializer.fromJson<double?>(json['sodiumMg']),
      potassiumMg: serializer.fromJson<double?>(json['potassiumMg']),
      cholesterolMg: serializer.fromJson<double?>(json['cholesterolMg']),
      calciumMg: serializer.fromJson<double?>(json['calciumMg']),
      vitaminDMcg: serializer.fromJson<double?>(json['vitaminDMcg']),
      vitaminCMg: serializer.fromJson<double?>(json['vitaminCMg']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<String>(day),
      'meal': serializer.toJson<String>(meal),
      'foodId': serializer.toJson<String?>(foodId),
      'foodName': serializer.toJson<String>(foodName),
      'foodBrand': serializer.toJson<String?>(foodBrand),
      'servingDescription': serializer.toJson<String?>(servingDescription),
      'quantityServings': serializer.toJson<double>(quantityServings),
      'quantityAmount': serializer.toJson<double>(quantityAmount),
      'quantityUnit': serializer.toJson<String>(quantityUnit),
      'servingGrams': serializer.toJson<double?>(servingGrams),
      'servingVolumeMl': serializer.toJson<double?>(servingVolumeMl),
      'caloriesKcal': serializer.toJson<double>(caloriesKcal),
      'proteinGrams': serializer.toJson<double>(proteinGrams),
      'carbsGrams': serializer.toJson<double>(carbsGrams),
      'fatGrams': serializer.toJson<double>(fatGrams),
      'ironMg': serializer.toJson<double?>(ironMg),
      'saturatedFatGrams': serializer.toJson<double?>(saturatedFatGrams),
      'transFatGrams': serializer.toJson<double?>(transFatGrams),
      'monounsaturatedFatGrams': serializer.toJson<double?>(
        monounsaturatedFatGrams,
      ),
      'polyunsaturatedFatGrams': serializer.toJson<double?>(
        polyunsaturatedFatGrams,
      ),
      'fiberGrams': serializer.toJson<double?>(fiberGrams),
      'sugarsGrams': serializer.toJson<double?>(sugarsGrams),
      'addedSugarsGrams': serializer.toJson<double?>(addedSugarsGrams),
      'sodiumMg': serializer.toJson<double?>(sodiumMg),
      'potassiumMg': serializer.toJson<double?>(potassiumMg),
      'cholesterolMg': serializer.toJson<double?>(cholesterolMg),
      'calciumMg': serializer.toJson<double?>(calciumMg),
      'vitaminDMcg': serializer.toJson<double?>(vitaminDMcg),
      'vitaminCMg': serializer.toJson<double?>(vitaminCMg),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  NutritionEntry copyWith({
    String? id,
    String? day,
    String? meal,
    Value<String?> foodId = const Value.absent(),
    String? foodName,
    Value<String?> foodBrand = const Value.absent(),
    Value<String?> servingDescription = const Value.absent(),
    double? quantityServings,
    double? quantityAmount,
    String? quantityUnit,
    Value<double?> servingGrams = const Value.absent(),
    Value<double?> servingVolumeMl = const Value.absent(),
    double? caloriesKcal,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    Value<double?> ironMg = const Value.absent(),
    Value<double?> saturatedFatGrams = const Value.absent(),
    Value<double?> transFatGrams = const Value.absent(),
    Value<double?> monounsaturatedFatGrams = const Value.absent(),
    Value<double?> polyunsaturatedFatGrams = const Value.absent(),
    Value<double?> fiberGrams = const Value.absent(),
    Value<double?> sugarsGrams = const Value.absent(),
    Value<double?> addedSugarsGrams = const Value.absent(),
    Value<double?> sodiumMg = const Value.absent(),
    Value<double?> potassiumMg = const Value.absent(),
    Value<double?> cholesterolMg = const Value.absent(),
    Value<double?> calciumMg = const Value.absent(),
    Value<double?> vitaminDMcg = const Value.absent(),
    Value<double?> vitaminCMg = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? syncStatus,
  }) => NutritionEntry(
    id: id ?? this.id,
    day: day ?? this.day,
    meal: meal ?? this.meal,
    foodId: foodId.present ? foodId.value : this.foodId,
    foodName: foodName ?? this.foodName,
    foodBrand: foodBrand.present ? foodBrand.value : this.foodBrand,
    servingDescription: servingDescription.present
        ? servingDescription.value
        : this.servingDescription,
    quantityServings: quantityServings ?? this.quantityServings,
    quantityAmount: quantityAmount ?? this.quantityAmount,
    quantityUnit: quantityUnit ?? this.quantityUnit,
    servingGrams: servingGrams.present ? servingGrams.value : this.servingGrams,
    servingVolumeMl: servingVolumeMl.present
        ? servingVolumeMl.value
        : this.servingVolumeMl,
    caloriesKcal: caloriesKcal ?? this.caloriesKcal,
    proteinGrams: proteinGrams ?? this.proteinGrams,
    carbsGrams: carbsGrams ?? this.carbsGrams,
    fatGrams: fatGrams ?? this.fatGrams,
    ironMg: ironMg.present ? ironMg.value : this.ironMg,
    saturatedFatGrams: saturatedFatGrams.present
        ? saturatedFatGrams.value
        : this.saturatedFatGrams,
    transFatGrams: transFatGrams.present
        ? transFatGrams.value
        : this.transFatGrams,
    monounsaturatedFatGrams: monounsaturatedFatGrams.present
        ? monounsaturatedFatGrams.value
        : this.monounsaturatedFatGrams,
    polyunsaturatedFatGrams: polyunsaturatedFatGrams.present
        ? polyunsaturatedFatGrams.value
        : this.polyunsaturatedFatGrams,
    fiberGrams: fiberGrams.present ? fiberGrams.value : this.fiberGrams,
    sugarsGrams: sugarsGrams.present ? sugarsGrams.value : this.sugarsGrams,
    addedSugarsGrams: addedSugarsGrams.present
        ? addedSugarsGrams.value
        : this.addedSugarsGrams,
    sodiumMg: sodiumMg.present ? sodiumMg.value : this.sodiumMg,
    potassiumMg: potassiumMg.present ? potassiumMg.value : this.potassiumMg,
    cholesterolMg: cholesterolMg.present
        ? cholesterolMg.value
        : this.cholesterolMg,
    calciumMg: calciumMg.present ? calciumMg.value : this.calciumMg,
    vitaminDMcg: vitaminDMcg.present ? vitaminDMcg.value : this.vitaminDMcg,
    vitaminCMg: vitaminCMg.present ? vitaminCMg.value : this.vitaminCMg,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  NutritionEntry copyWithCompanion(NutritionEntriesCompanion data) {
    return NutritionEntry(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      meal: data.meal.present ? data.meal.value : this.meal,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      foodName: data.foodName.present ? data.foodName.value : this.foodName,
      foodBrand: data.foodBrand.present ? data.foodBrand.value : this.foodBrand,
      servingDescription: data.servingDescription.present
          ? data.servingDescription.value
          : this.servingDescription,
      quantityServings: data.quantityServings.present
          ? data.quantityServings.value
          : this.quantityServings,
      quantityAmount: data.quantityAmount.present
          ? data.quantityAmount.value
          : this.quantityAmount,
      quantityUnit: data.quantityUnit.present
          ? data.quantityUnit.value
          : this.quantityUnit,
      servingGrams: data.servingGrams.present
          ? data.servingGrams.value
          : this.servingGrams,
      servingVolumeMl: data.servingVolumeMl.present
          ? data.servingVolumeMl.value
          : this.servingVolumeMl,
      caloriesKcal: data.caloriesKcal.present
          ? data.caloriesKcal.value
          : this.caloriesKcal,
      proteinGrams: data.proteinGrams.present
          ? data.proteinGrams.value
          : this.proteinGrams,
      carbsGrams: data.carbsGrams.present
          ? data.carbsGrams.value
          : this.carbsGrams,
      fatGrams: data.fatGrams.present ? data.fatGrams.value : this.fatGrams,
      ironMg: data.ironMg.present ? data.ironMg.value : this.ironMg,
      saturatedFatGrams: data.saturatedFatGrams.present
          ? data.saturatedFatGrams.value
          : this.saturatedFatGrams,
      transFatGrams: data.transFatGrams.present
          ? data.transFatGrams.value
          : this.transFatGrams,
      monounsaturatedFatGrams: data.monounsaturatedFatGrams.present
          ? data.monounsaturatedFatGrams.value
          : this.monounsaturatedFatGrams,
      polyunsaturatedFatGrams: data.polyunsaturatedFatGrams.present
          ? data.polyunsaturatedFatGrams.value
          : this.polyunsaturatedFatGrams,
      fiberGrams: data.fiberGrams.present
          ? data.fiberGrams.value
          : this.fiberGrams,
      sugarsGrams: data.sugarsGrams.present
          ? data.sugarsGrams.value
          : this.sugarsGrams,
      addedSugarsGrams: data.addedSugarsGrams.present
          ? data.addedSugarsGrams.value
          : this.addedSugarsGrams,
      sodiumMg: data.sodiumMg.present ? data.sodiumMg.value : this.sodiumMg,
      potassiumMg: data.potassiumMg.present
          ? data.potassiumMg.value
          : this.potassiumMg,
      cholesterolMg: data.cholesterolMg.present
          ? data.cholesterolMg.value
          : this.cholesterolMg,
      calciumMg: data.calciumMg.present ? data.calciumMg.value : this.calciumMg,
      vitaminDMcg: data.vitaminDMcg.present
          ? data.vitaminDMcg.value
          : this.vitaminDMcg,
      vitaminCMg: data.vitaminCMg.present
          ? data.vitaminCMg.value
          : this.vitaminCMg,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NutritionEntry(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('meal: $meal, ')
          ..write('foodId: $foodId, ')
          ..write('foodName: $foodName, ')
          ..write('foodBrand: $foodBrand, ')
          ..write('servingDescription: $servingDescription, ')
          ..write('quantityServings: $quantityServings, ')
          ..write('quantityAmount: $quantityAmount, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('servingGrams: $servingGrams, ')
          ..write('servingVolumeMl: $servingVolumeMl, ')
          ..write('caloriesKcal: $caloriesKcal, ')
          ..write('proteinGrams: $proteinGrams, ')
          ..write('carbsGrams: $carbsGrams, ')
          ..write('fatGrams: $fatGrams, ')
          ..write('ironMg: $ironMg, ')
          ..write('saturatedFatGrams: $saturatedFatGrams, ')
          ..write('transFatGrams: $transFatGrams, ')
          ..write('monounsaturatedFatGrams: $monounsaturatedFatGrams, ')
          ..write('polyunsaturatedFatGrams: $polyunsaturatedFatGrams, ')
          ..write('fiberGrams: $fiberGrams, ')
          ..write('sugarsGrams: $sugarsGrams, ')
          ..write('addedSugarsGrams: $addedSugarsGrams, ')
          ..write('sodiumMg: $sodiumMg, ')
          ..write('potassiumMg: $potassiumMg, ')
          ..write('cholesterolMg: $cholesterolMg, ')
          ..write('calciumMg: $calciumMg, ')
          ..write('vitaminDMcg: $vitaminDMcg, ')
          ..write('vitaminCMg: $vitaminCMg, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    day,
    meal,
    foodId,
    foodName,
    foodBrand,
    servingDescription,
    quantityServings,
    quantityAmount,
    quantityUnit,
    servingGrams,
    servingVolumeMl,
    caloriesKcal,
    proteinGrams,
    carbsGrams,
    fatGrams,
    ironMg,
    saturatedFatGrams,
    transFatGrams,
    monounsaturatedFatGrams,
    polyunsaturatedFatGrams,
    fiberGrams,
    sugarsGrams,
    addedSugarsGrams,
    sodiumMg,
    potassiumMg,
    cholesterolMg,
    calciumMg,
    vitaminDMcg,
    vitaminCMg,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NutritionEntry &&
          other.id == this.id &&
          other.day == this.day &&
          other.meal == this.meal &&
          other.foodId == this.foodId &&
          other.foodName == this.foodName &&
          other.foodBrand == this.foodBrand &&
          other.servingDescription == this.servingDescription &&
          other.quantityServings == this.quantityServings &&
          other.quantityAmount == this.quantityAmount &&
          other.quantityUnit == this.quantityUnit &&
          other.servingGrams == this.servingGrams &&
          other.servingVolumeMl == this.servingVolumeMl &&
          other.caloriesKcal == this.caloriesKcal &&
          other.proteinGrams == this.proteinGrams &&
          other.carbsGrams == this.carbsGrams &&
          other.fatGrams == this.fatGrams &&
          other.ironMg == this.ironMg &&
          other.saturatedFatGrams == this.saturatedFatGrams &&
          other.transFatGrams == this.transFatGrams &&
          other.monounsaturatedFatGrams == this.monounsaturatedFatGrams &&
          other.polyunsaturatedFatGrams == this.polyunsaturatedFatGrams &&
          other.fiberGrams == this.fiberGrams &&
          other.sugarsGrams == this.sugarsGrams &&
          other.addedSugarsGrams == this.addedSugarsGrams &&
          other.sodiumMg == this.sodiumMg &&
          other.potassiumMg == this.potassiumMg &&
          other.cholesterolMg == this.cholesterolMg &&
          other.calciumMg == this.calciumMg &&
          other.vitaminDMcg == this.vitaminDMcg &&
          other.vitaminCMg == this.vitaminCMg &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus);
}

class NutritionEntriesCompanion extends UpdateCompanion<NutritionEntry> {
  final Value<String> id;
  final Value<String> day;
  final Value<String> meal;
  final Value<String?> foodId;
  final Value<String> foodName;
  final Value<String?> foodBrand;
  final Value<String?> servingDescription;
  final Value<double> quantityServings;
  final Value<double> quantityAmount;
  final Value<String> quantityUnit;
  final Value<double?> servingGrams;
  final Value<double?> servingVolumeMl;
  final Value<double> caloriesKcal;
  final Value<double> proteinGrams;
  final Value<double> carbsGrams;
  final Value<double> fatGrams;
  final Value<double?> ironMg;
  final Value<double?> saturatedFatGrams;
  final Value<double?> transFatGrams;
  final Value<double?> monounsaturatedFatGrams;
  final Value<double?> polyunsaturatedFatGrams;
  final Value<double?> fiberGrams;
  final Value<double?> sugarsGrams;
  final Value<double?> addedSugarsGrams;
  final Value<double?> sodiumMg;
  final Value<double?> potassiumMg;
  final Value<double?> cholesterolMg;
  final Value<double?> calciumMg;
  final Value<double?> vitaminDMcg;
  final Value<double?> vitaminCMg;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const NutritionEntriesCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.meal = const Value.absent(),
    this.foodId = const Value.absent(),
    this.foodName = const Value.absent(),
    this.foodBrand = const Value.absent(),
    this.servingDescription = const Value.absent(),
    this.quantityServings = const Value.absent(),
    this.quantityAmount = const Value.absent(),
    this.quantityUnit = const Value.absent(),
    this.servingGrams = const Value.absent(),
    this.servingVolumeMl = const Value.absent(),
    this.caloriesKcal = const Value.absent(),
    this.proteinGrams = const Value.absent(),
    this.carbsGrams = const Value.absent(),
    this.fatGrams = const Value.absent(),
    this.ironMg = const Value.absent(),
    this.saturatedFatGrams = const Value.absent(),
    this.transFatGrams = const Value.absent(),
    this.monounsaturatedFatGrams = const Value.absent(),
    this.polyunsaturatedFatGrams = const Value.absent(),
    this.fiberGrams = const Value.absent(),
    this.sugarsGrams = const Value.absent(),
    this.addedSugarsGrams = const Value.absent(),
    this.sodiumMg = const Value.absent(),
    this.potassiumMg = const Value.absent(),
    this.cholesterolMg = const Value.absent(),
    this.calciumMg = const Value.absent(),
    this.vitaminDMcg = const Value.absent(),
    this.vitaminCMg = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NutritionEntriesCompanion.insert({
    required String id,
    required String day,
    required String meal,
    this.foodId = const Value.absent(),
    required String foodName,
    this.foodBrand = const Value.absent(),
    this.servingDescription = const Value.absent(),
    required double quantityServings,
    this.quantityAmount = const Value.absent(),
    this.quantityUnit = const Value.absent(),
    this.servingGrams = const Value.absent(),
    this.servingVolumeMl = const Value.absent(),
    required double caloriesKcal,
    required double proteinGrams,
    required double carbsGrams,
    required double fatGrams,
    this.ironMg = const Value.absent(),
    this.saturatedFatGrams = const Value.absent(),
    this.transFatGrams = const Value.absent(),
    this.monounsaturatedFatGrams = const Value.absent(),
    this.polyunsaturatedFatGrams = const Value.absent(),
    this.fiberGrams = const Value.absent(),
    this.sugarsGrams = const Value.absent(),
    this.addedSugarsGrams = const Value.absent(),
    this.sodiumMg = const Value.absent(),
    this.potassiumMg = const Value.absent(),
    this.cholesterolMg = const Value.absent(),
    this.calciumMg = const Value.absent(),
    this.vitaminDMcg = const Value.absent(),
    this.vitaminCMg = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       day = Value(day),
       meal = Value(meal),
       foodName = Value(foodName),
       quantityServings = Value(quantityServings),
       caloriesKcal = Value(caloriesKcal),
       proteinGrams = Value(proteinGrams),
       carbsGrams = Value(carbsGrams),
       fatGrams = Value(fatGrams),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<NutritionEntry> custom({
    Expression<String>? id,
    Expression<String>? day,
    Expression<String>? meal,
    Expression<String>? foodId,
    Expression<String>? foodName,
    Expression<String>? foodBrand,
    Expression<String>? servingDescription,
    Expression<double>? quantityServings,
    Expression<double>? quantityAmount,
    Expression<String>? quantityUnit,
    Expression<double>? servingGrams,
    Expression<double>? servingVolumeMl,
    Expression<double>? caloriesKcal,
    Expression<double>? proteinGrams,
    Expression<double>? carbsGrams,
    Expression<double>? fatGrams,
    Expression<double>? ironMg,
    Expression<double>? saturatedFatGrams,
    Expression<double>? transFatGrams,
    Expression<double>? monounsaturatedFatGrams,
    Expression<double>? polyunsaturatedFatGrams,
    Expression<double>? fiberGrams,
    Expression<double>? sugarsGrams,
    Expression<double>? addedSugarsGrams,
    Expression<double>? sodiumMg,
    Expression<double>? potassiumMg,
    Expression<double>? cholesterolMg,
    Expression<double>? calciumMg,
    Expression<double>? vitaminDMcg,
    Expression<double>? vitaminCMg,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (meal != null) 'meal': meal,
      if (foodId != null) 'food_id': foodId,
      if (foodName != null) 'food_name': foodName,
      if (foodBrand != null) 'food_brand': foodBrand,
      if (servingDescription != null) 'serving_description': servingDescription,
      if (quantityServings != null) 'quantity_servings': quantityServings,
      if (quantityAmount != null) 'quantity_amount': quantityAmount,
      if (quantityUnit != null) 'quantity_unit': quantityUnit,
      if (servingGrams != null) 'serving_grams': servingGrams,
      if (servingVolumeMl != null) 'serving_volume_ml': servingVolumeMl,
      if (caloriesKcal != null) 'calories_kcal': caloriesKcal,
      if (proteinGrams != null) 'protein_grams': proteinGrams,
      if (carbsGrams != null) 'carbs_grams': carbsGrams,
      if (fatGrams != null) 'fat_grams': fatGrams,
      if (ironMg != null) 'iron_mg': ironMg,
      if (saturatedFatGrams != null) 'saturated_fat_grams': saturatedFatGrams,
      if (transFatGrams != null) 'trans_fat_grams': transFatGrams,
      if (monounsaturatedFatGrams != null)
        'monounsaturated_fat_grams': monounsaturatedFatGrams,
      if (polyunsaturatedFatGrams != null)
        'polyunsaturated_fat_grams': polyunsaturatedFatGrams,
      if (fiberGrams != null) 'fiber_grams': fiberGrams,
      if (sugarsGrams != null) 'sugars_grams': sugarsGrams,
      if (addedSugarsGrams != null) 'added_sugars_grams': addedSugarsGrams,
      if (sodiumMg != null) 'sodium_mg': sodiumMg,
      if (potassiumMg != null) 'potassium_mg': potassiumMg,
      if (cholesterolMg != null) 'cholesterol_mg': cholesterolMg,
      if (calciumMg != null) 'calcium_mg': calciumMg,
      if (vitaminDMcg != null) 'vitamin_d_mcg': vitaminDMcg,
      if (vitaminCMg != null) 'vitamin_c_mg': vitaminCMg,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NutritionEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? day,
    Value<String>? meal,
    Value<String?>? foodId,
    Value<String>? foodName,
    Value<String?>? foodBrand,
    Value<String?>? servingDescription,
    Value<double>? quantityServings,
    Value<double>? quantityAmount,
    Value<String>? quantityUnit,
    Value<double?>? servingGrams,
    Value<double?>? servingVolumeMl,
    Value<double>? caloriesKcal,
    Value<double>? proteinGrams,
    Value<double>? carbsGrams,
    Value<double>? fatGrams,
    Value<double?>? ironMg,
    Value<double?>? saturatedFatGrams,
    Value<double?>? transFatGrams,
    Value<double?>? monounsaturatedFatGrams,
    Value<double?>? polyunsaturatedFatGrams,
    Value<double?>? fiberGrams,
    Value<double?>? sugarsGrams,
    Value<double?>? addedSugarsGrams,
    Value<double?>? sodiumMg,
    Value<double?>? potassiumMg,
    Value<double?>? cholesterolMg,
    Value<double?>? calciumMg,
    Value<double?>? vitaminDMcg,
    Value<double?>? vitaminCMg,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return NutritionEntriesCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      meal: meal ?? this.meal,
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      foodBrand: foodBrand ?? this.foodBrand,
      servingDescription: servingDescription ?? this.servingDescription,
      quantityServings: quantityServings ?? this.quantityServings,
      quantityAmount: quantityAmount ?? this.quantityAmount,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      servingGrams: servingGrams ?? this.servingGrams,
      servingVolumeMl: servingVolumeMl ?? this.servingVolumeMl,
      caloriesKcal: caloriesKcal ?? this.caloriesKcal,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      ironMg: ironMg ?? this.ironMg,
      saturatedFatGrams: saturatedFatGrams ?? this.saturatedFatGrams,
      transFatGrams: transFatGrams ?? this.transFatGrams,
      monounsaturatedFatGrams:
          monounsaturatedFatGrams ?? this.monounsaturatedFatGrams,
      polyunsaturatedFatGrams:
          polyunsaturatedFatGrams ?? this.polyunsaturatedFatGrams,
      fiberGrams: fiberGrams ?? this.fiberGrams,
      sugarsGrams: sugarsGrams ?? this.sugarsGrams,
      addedSugarsGrams: addedSugarsGrams ?? this.addedSugarsGrams,
      sodiumMg: sodiumMg ?? this.sodiumMg,
      potassiumMg: potassiumMg ?? this.potassiumMg,
      cholesterolMg: cholesterolMg ?? this.cholesterolMg,
      calciumMg: calciumMg ?? this.calciumMg,
      vitaminDMcg: vitaminDMcg ?? this.vitaminDMcg,
      vitaminCMg: vitaminCMg ?? this.vitaminCMg,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (meal.present) {
      map['meal'] = Variable<String>(meal.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<String>(foodId.value);
    }
    if (foodName.present) {
      map['food_name'] = Variable<String>(foodName.value);
    }
    if (foodBrand.present) {
      map['food_brand'] = Variable<String>(foodBrand.value);
    }
    if (servingDescription.present) {
      map['serving_description'] = Variable<String>(servingDescription.value);
    }
    if (quantityServings.present) {
      map['quantity_servings'] = Variable<double>(quantityServings.value);
    }
    if (quantityAmount.present) {
      map['quantity_amount'] = Variable<double>(quantityAmount.value);
    }
    if (quantityUnit.present) {
      map['quantity_unit'] = Variable<String>(quantityUnit.value);
    }
    if (servingGrams.present) {
      map['serving_grams'] = Variable<double>(servingGrams.value);
    }
    if (servingVolumeMl.present) {
      map['serving_volume_ml'] = Variable<double>(servingVolumeMl.value);
    }
    if (caloriesKcal.present) {
      map['calories_kcal'] = Variable<double>(caloriesKcal.value);
    }
    if (proteinGrams.present) {
      map['protein_grams'] = Variable<double>(proteinGrams.value);
    }
    if (carbsGrams.present) {
      map['carbs_grams'] = Variable<double>(carbsGrams.value);
    }
    if (fatGrams.present) {
      map['fat_grams'] = Variable<double>(fatGrams.value);
    }
    if (ironMg.present) {
      map['iron_mg'] = Variable<double>(ironMg.value);
    }
    if (saturatedFatGrams.present) {
      map['saturated_fat_grams'] = Variable<double>(saturatedFatGrams.value);
    }
    if (transFatGrams.present) {
      map['trans_fat_grams'] = Variable<double>(transFatGrams.value);
    }
    if (monounsaturatedFatGrams.present) {
      map['monounsaturated_fat_grams'] = Variable<double>(
        monounsaturatedFatGrams.value,
      );
    }
    if (polyunsaturatedFatGrams.present) {
      map['polyunsaturated_fat_grams'] = Variable<double>(
        polyunsaturatedFatGrams.value,
      );
    }
    if (fiberGrams.present) {
      map['fiber_grams'] = Variable<double>(fiberGrams.value);
    }
    if (sugarsGrams.present) {
      map['sugars_grams'] = Variable<double>(sugarsGrams.value);
    }
    if (addedSugarsGrams.present) {
      map['added_sugars_grams'] = Variable<double>(addedSugarsGrams.value);
    }
    if (sodiumMg.present) {
      map['sodium_mg'] = Variable<double>(sodiumMg.value);
    }
    if (potassiumMg.present) {
      map['potassium_mg'] = Variable<double>(potassiumMg.value);
    }
    if (cholesterolMg.present) {
      map['cholesterol_mg'] = Variable<double>(cholesterolMg.value);
    }
    if (calciumMg.present) {
      map['calcium_mg'] = Variable<double>(calciumMg.value);
    }
    if (vitaminDMcg.present) {
      map['vitamin_d_mcg'] = Variable<double>(vitaminDMcg.value);
    }
    if (vitaminCMg.present) {
      map['vitamin_c_mg'] = Variable<double>(vitaminCMg.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NutritionEntriesCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('meal: $meal, ')
          ..write('foodId: $foodId, ')
          ..write('foodName: $foodName, ')
          ..write('foodBrand: $foodBrand, ')
          ..write('servingDescription: $servingDescription, ')
          ..write('quantityServings: $quantityServings, ')
          ..write('quantityAmount: $quantityAmount, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('servingGrams: $servingGrams, ')
          ..write('servingVolumeMl: $servingVolumeMl, ')
          ..write('caloriesKcal: $caloriesKcal, ')
          ..write('proteinGrams: $proteinGrams, ')
          ..write('carbsGrams: $carbsGrams, ')
          ..write('fatGrams: $fatGrams, ')
          ..write('ironMg: $ironMg, ')
          ..write('saturatedFatGrams: $saturatedFatGrams, ')
          ..write('transFatGrams: $transFatGrams, ')
          ..write('monounsaturatedFatGrams: $monounsaturatedFatGrams, ')
          ..write('polyunsaturatedFatGrams: $polyunsaturatedFatGrams, ')
          ..write('fiberGrams: $fiberGrams, ')
          ..write('sugarsGrams: $sugarsGrams, ')
          ..write('addedSugarsGrams: $addedSugarsGrams, ')
          ..write('sodiumMg: $sodiumMg, ')
          ..write('potassiumMg: $potassiumMg, ')
          ..write('cholesterolMg: $cholesterolMg, ')
          ..write('calciumMg: $calciumMg, ')
          ..write('vitaminDMcg: $vitaminDMcg, ')
          ..write('vitaminCMg: $vitaminCMg, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NutritionGoalsTable extends NutritionGoals
    with TableInfo<$NutritionGoalsTable, NutritionGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NutritionGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calorieTargetKcalMeta = const VerificationMeta(
    'calorieTargetKcal',
  );
  @override
  late final GeneratedColumn<int> calorieTargetKcal = GeneratedColumn<int>(
    'calorie_target_kcal',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinTargetGramsMeta =
      const VerificationMeta('proteinTargetGrams');
  @override
  late final GeneratedColumn<double> proteinTargetGrams =
      GeneratedColumn<double>(
        'protein_target_grams',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _carbTargetGramsMeta = const VerificationMeta(
    'carbTargetGrams',
  );
  @override
  late final GeneratedColumn<double> carbTargetGrams = GeneratedColumn<double>(
    'carb_target_grams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatTargetGramsMeta = const VerificationMeta(
    'fatTargetGrams',
  );
  @override
  late final GeneratedColumn<double> fatTargetGrams = GeneratedColumn<double>(
    'fat_target_grams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _macroTargetModeMeta = const VerificationMeta(
    'macroTargetMode',
  );
  @override
  late final GeneratedColumn<String> macroTargetMode = GeneratedColumn<String>(
    'macro_target_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('grams'),
  );
  static const VerificationMeta _proteinTargetPercentMeta =
      const VerificationMeta('proteinTargetPercent');
  @override
  late final GeneratedColumn<double> proteinTargetPercent =
      GeneratedColumn<double>(
        'protein_target_percent',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _carbTargetPercentMeta = const VerificationMeta(
    'carbTargetPercent',
  );
  @override
  late final GeneratedColumn<double> carbTargetPercent =
      GeneratedColumn<double>(
        'carb_target_percent',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fatTargetPercentMeta = const VerificationMeta(
    'fatTargetPercent',
  );
  @override
  late final GeneratedColumn<double> fatTargetPercent = GeneratedColumn<double>(
    'fat_target_percent',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _macroLocksMeta = const VerificationMeta(
    'macroLocks',
  );
  @override
  late final GeneratedColumn<String> macroLocks = GeneratedColumn<String>(
    'macro_locks',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _hideCalorieNumbersMeta =
      const VerificationMeta('hideCalorieNumbers');
  @override
  late final GeneratedColumn<bool> hideCalorieNumbers = GeneratedColumn<bool>(
    'hide_calorie_numbers',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hide_calorie_numbers" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _activityLevelMeta = const VerificationMeta(
    'activityLevel',
  );
  @override
  late final GeneratedColumn<String> activityLevel = GeneratedColumn<String>(
    'activity_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightGoalMeta = const VerificationMeta(
    'weightGoal',
  );
  @override
  late final GeneratedColumn<String> weightGoal = GeneratedColumn<String>(
    'weight_goal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('maintain'),
  );
  static const VerificationMeta _dailyDeficitKcalMeta = const VerificationMeta(
    'dailyDeficitKcal',
  );
  @override
  late final GeneratedColumn<int> dailyDeficitKcal = GeneratedColumn<int>(
    'daily_deficit_kcal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    calorieTargetKcal,
    proteinTargetGrams,
    carbTargetGrams,
    fatTargetGrams,
    macroTargetMode,
    proteinTargetPercent,
    carbTargetPercent,
    fatTargetPercent,
    macroLocks,
    hideCalorieNumbers,
    activityLevel,
    weightGoal,
    dailyDeficitKcal,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nutrition_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<NutritionGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('calorie_target_kcal')) {
      context.handle(
        _calorieTargetKcalMeta,
        calorieTargetKcal.isAcceptableOrUnknown(
          data['calorie_target_kcal']!,
          _calorieTargetKcalMeta,
        ),
      );
    }
    if (data.containsKey('protein_target_grams')) {
      context.handle(
        _proteinTargetGramsMeta,
        proteinTargetGrams.isAcceptableOrUnknown(
          data['protein_target_grams']!,
          _proteinTargetGramsMeta,
        ),
      );
    }
    if (data.containsKey('carb_target_grams')) {
      context.handle(
        _carbTargetGramsMeta,
        carbTargetGrams.isAcceptableOrUnknown(
          data['carb_target_grams']!,
          _carbTargetGramsMeta,
        ),
      );
    }
    if (data.containsKey('fat_target_grams')) {
      context.handle(
        _fatTargetGramsMeta,
        fatTargetGrams.isAcceptableOrUnknown(
          data['fat_target_grams']!,
          _fatTargetGramsMeta,
        ),
      );
    }
    if (data.containsKey('macro_target_mode')) {
      context.handle(
        _macroTargetModeMeta,
        macroTargetMode.isAcceptableOrUnknown(
          data['macro_target_mode']!,
          _macroTargetModeMeta,
        ),
      );
    }
    if (data.containsKey('protein_target_percent')) {
      context.handle(
        _proteinTargetPercentMeta,
        proteinTargetPercent.isAcceptableOrUnknown(
          data['protein_target_percent']!,
          _proteinTargetPercentMeta,
        ),
      );
    }
    if (data.containsKey('carb_target_percent')) {
      context.handle(
        _carbTargetPercentMeta,
        carbTargetPercent.isAcceptableOrUnknown(
          data['carb_target_percent']!,
          _carbTargetPercentMeta,
        ),
      );
    }
    if (data.containsKey('fat_target_percent')) {
      context.handle(
        _fatTargetPercentMeta,
        fatTargetPercent.isAcceptableOrUnknown(
          data['fat_target_percent']!,
          _fatTargetPercentMeta,
        ),
      );
    }
    if (data.containsKey('macro_locks')) {
      context.handle(
        _macroLocksMeta,
        macroLocks.isAcceptableOrUnknown(data['macro_locks']!, _macroLocksMeta),
      );
    }
    if (data.containsKey('hide_calorie_numbers')) {
      context.handle(
        _hideCalorieNumbersMeta,
        hideCalorieNumbers.isAcceptableOrUnknown(
          data['hide_calorie_numbers']!,
          _hideCalorieNumbersMeta,
        ),
      );
    }
    if (data.containsKey('activity_level')) {
      context.handle(
        _activityLevelMeta,
        activityLevel.isAcceptableOrUnknown(
          data['activity_level']!,
          _activityLevelMeta,
        ),
      );
    }
    if (data.containsKey('weight_goal')) {
      context.handle(
        _weightGoalMeta,
        weightGoal.isAcceptableOrUnknown(data['weight_goal']!, _weightGoalMeta),
      );
    }
    if (data.containsKey('daily_deficit_kcal')) {
      context.handle(
        _dailyDeficitKcalMeta,
        dailyDeficitKcal.isAcceptableOrUnknown(
          data['daily_deficit_kcal']!,
          _dailyDeficitKcalMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NutritionGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NutritionGoal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      calorieTargetKcal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calorie_target_kcal'],
      ),
      proteinTargetGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_target_grams'],
      ),
      carbTargetGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carb_target_grams'],
      ),
      fatTargetGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_target_grams'],
      ),
      macroTargetMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}macro_target_mode'],
      )!,
      proteinTargetPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_target_percent'],
      ),
      carbTargetPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carb_target_percent'],
      ),
      fatTargetPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_target_percent'],
      ),
      macroLocks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}macro_locks'],
      )!,
      hideCalorieNumbers: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hide_calorie_numbers'],
      )!,
      activityLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_level'],
      ),
      weightGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weight_goal'],
      )!,
      dailyDeficitKcal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_deficit_kcal'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $NutritionGoalsTable createAlias(String alias) {
    return $NutritionGoalsTable(attachedDatabase, alias);
  }
}

class NutritionGoal extends DataClass implements Insertable<NutritionGoal> {
  /// Client-generated UUIDv7.
  final String id;

  /// Daily energy target in kilocalories. `null` means no target set.
  final int? calorieTargetKcal;

  /// Daily protein target in grams. `null` means no target set. Protein is
  /// one of the two first-class adequacy indicators for this audience
  /// (`knowledge/domain/nutrition.md`).
  final double? proteinTargetGrams;

  /// Daily carbohydrate target in grams. `null` means no target set.
  final double? carbTargetGrams;

  /// Daily fat target in grams. `null` means no target set.
  final double? fatTargetGrams;

  /// Which macro representation is authoritative — one of
  /// `MacroTargetMode`'s storage keys (see
  /// `features/nutrition/domain/macro_targets.dart`). Defaults to
  /// `'grams'`, which is what every row written before this column existed
  /// already means, so the v12 migration changes no existing behaviour.
  ///
  /// The grams and percent columns are stored **side by side and
  /// independently**; neither is written from the other. That is what lets
  /// a user switch representation and back without losing the numbers they
  /// typed, and it keeps derived grams out of the database — they are
  /// recomputed from the current energy target instead of going stale
  /// (`knowledge/architecture/data_architecture.md`'s derived-vs-stored
  /// rule).
  final String macroTargetMode;

  /// Daily protein target as a percentage of the day's energy target,
  /// 0-100. `null` means no target set. Authoritative only while
  /// [macroTargetMode] is `'percent'`.
  final double? proteinTargetPercent;

  /// Daily carbohydrate target as a percentage of the day's energy target,
  /// 0-100. `null` means no target set.
  final double? carbTargetPercent;

  /// Daily fat target as a percentage of the day's energy target, 0-100.
  /// `null` means no target set.
  final double? fatTargetPercent;

  /// Which gram targets the user has pinned, as a comma-separated set of
  /// `MacroNutrient` storage keys — `''` (the default, and what every pre-v14
  /// row means) for none, `'protein,fat'` for two. See
  /// `features/nutrition/domain/macro_locks.dart`.
  ///
  /// **One column rather than three booleans**, because this *is* a set: it
  /// round-trips as one, it is read as one ("how many are locked?"), and a
  /// fourth macro would need no migration to join it. Same comma-separated
  /// convention as `user_profiles.training_days`.
  ///
  /// Stored rather than left in the widget, because a lock is a durable
  /// intent: "keep protein at 200 g" has to survive a reopen, or the
  /// promise that the free macro tracks a changed calorie target quietly
  /// breaks. Only meaningful while [macroTargetMode] is `'grams'` — a
  /// percentage split is already fully determined by its own add-to-100
  /// rule — and, like the two macro sets, it is kept rather than cleared
  /// when the user switches away and back.
  final String macroLocks;

  /// When the user asks the app to hide calorie figures. Purely a display
  /// preference — see the class doc.
  final bool hideCalorieNumbers;

  /// Persisted as one of `ActivityLevel`'s storage keys (see
  /// `features/nutrition/domain/energy_estimate.dart`) — the multiplier the
  /// TDEE estimate applies to the estimated BMR. `null` means the user
  /// hasn't told us, and no TDEE is estimated.
  final String? activityLevel;

  /// Persisted as one of `WeightGoal`'s storage keys (see
  /// `features/nutrition/domain/nutrition_goals.dart`). Defaults to
  /// `'maintain'` — the app never assumes a user wants to lose weight.
  final String weightGoal;

  /// The size of the daily energy gap the user asked for, in kilocalories,
  /// as a **magnitude** — [weightGoal] carries the direction. `0` (the
  /// default) means no gap. This is the user's request, not the resolved
  /// target; see the class doc.
  final int dailyDeficitKcal;

  /// UTC milliseconds since epoch.
  final int createdAt;

  /// UTC milliseconds since epoch.
  final int updatedAt;

  /// UTC milliseconds since epoch; null while the row is live. Kept for
  /// column-shape consistency; "Delete my data" hard-deletes the row.
  final int? deletedAt;

  /// One of `'local'`, `'pending'`, `'synced'` (outbox/sync status; see ADR
  /// 004). Defaults to `'local'`.
  final String syncStatus;
  const NutritionGoal({
    required this.id,
    this.calorieTargetKcal,
    this.proteinTargetGrams,
    this.carbTargetGrams,
    this.fatTargetGrams,
    required this.macroTargetMode,
    this.proteinTargetPercent,
    this.carbTargetPercent,
    this.fatTargetPercent,
    required this.macroLocks,
    required this.hideCalorieNumbers,
    this.activityLevel,
    required this.weightGoal,
    required this.dailyDeficitKcal,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || calorieTargetKcal != null) {
      map['calorie_target_kcal'] = Variable<int>(calorieTargetKcal);
    }
    if (!nullToAbsent || proteinTargetGrams != null) {
      map['protein_target_grams'] = Variable<double>(proteinTargetGrams);
    }
    if (!nullToAbsent || carbTargetGrams != null) {
      map['carb_target_grams'] = Variable<double>(carbTargetGrams);
    }
    if (!nullToAbsent || fatTargetGrams != null) {
      map['fat_target_grams'] = Variable<double>(fatTargetGrams);
    }
    map['macro_target_mode'] = Variable<String>(macroTargetMode);
    if (!nullToAbsent || proteinTargetPercent != null) {
      map['protein_target_percent'] = Variable<double>(proteinTargetPercent);
    }
    if (!nullToAbsent || carbTargetPercent != null) {
      map['carb_target_percent'] = Variable<double>(carbTargetPercent);
    }
    if (!nullToAbsent || fatTargetPercent != null) {
      map['fat_target_percent'] = Variable<double>(fatTargetPercent);
    }
    map['macro_locks'] = Variable<String>(macroLocks);
    map['hide_calorie_numbers'] = Variable<bool>(hideCalorieNumbers);
    if (!nullToAbsent || activityLevel != null) {
      map['activity_level'] = Variable<String>(activityLevel);
    }
    map['weight_goal'] = Variable<String>(weightGoal);
    map['daily_deficit_kcal'] = Variable<int>(dailyDeficitKcal);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  NutritionGoalsCompanion toCompanion(bool nullToAbsent) {
    return NutritionGoalsCompanion(
      id: Value(id),
      calorieTargetKcal: calorieTargetKcal == null && nullToAbsent
          ? const Value.absent()
          : Value(calorieTargetKcal),
      proteinTargetGrams: proteinTargetGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(proteinTargetGrams),
      carbTargetGrams: carbTargetGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(carbTargetGrams),
      fatTargetGrams: fatTargetGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(fatTargetGrams),
      macroTargetMode: Value(macroTargetMode),
      proteinTargetPercent: proteinTargetPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(proteinTargetPercent),
      carbTargetPercent: carbTargetPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(carbTargetPercent),
      fatTargetPercent: fatTargetPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(fatTargetPercent),
      macroLocks: Value(macroLocks),
      hideCalorieNumbers: Value(hideCalorieNumbers),
      activityLevel: activityLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(activityLevel),
      weightGoal: Value(weightGoal),
      dailyDeficitKcal: Value(dailyDeficitKcal),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory NutritionGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NutritionGoal(
      id: serializer.fromJson<String>(json['id']),
      calorieTargetKcal: serializer.fromJson<int?>(json['calorieTargetKcal']),
      proteinTargetGrams: serializer.fromJson<double?>(
        json['proteinTargetGrams'],
      ),
      carbTargetGrams: serializer.fromJson<double?>(json['carbTargetGrams']),
      fatTargetGrams: serializer.fromJson<double?>(json['fatTargetGrams']),
      macroTargetMode: serializer.fromJson<String>(json['macroTargetMode']),
      proteinTargetPercent: serializer.fromJson<double?>(
        json['proteinTargetPercent'],
      ),
      carbTargetPercent: serializer.fromJson<double?>(
        json['carbTargetPercent'],
      ),
      fatTargetPercent: serializer.fromJson<double?>(json['fatTargetPercent']),
      macroLocks: serializer.fromJson<String>(json['macroLocks']),
      hideCalorieNumbers: serializer.fromJson<bool>(json['hideCalorieNumbers']),
      activityLevel: serializer.fromJson<String?>(json['activityLevel']),
      weightGoal: serializer.fromJson<String>(json['weightGoal']),
      dailyDeficitKcal: serializer.fromJson<int>(json['dailyDeficitKcal']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'calorieTargetKcal': serializer.toJson<int?>(calorieTargetKcal),
      'proteinTargetGrams': serializer.toJson<double?>(proteinTargetGrams),
      'carbTargetGrams': serializer.toJson<double?>(carbTargetGrams),
      'fatTargetGrams': serializer.toJson<double?>(fatTargetGrams),
      'macroTargetMode': serializer.toJson<String>(macroTargetMode),
      'proteinTargetPercent': serializer.toJson<double?>(proteinTargetPercent),
      'carbTargetPercent': serializer.toJson<double?>(carbTargetPercent),
      'fatTargetPercent': serializer.toJson<double?>(fatTargetPercent),
      'macroLocks': serializer.toJson<String>(macroLocks),
      'hideCalorieNumbers': serializer.toJson<bool>(hideCalorieNumbers),
      'activityLevel': serializer.toJson<String?>(activityLevel),
      'weightGoal': serializer.toJson<String>(weightGoal),
      'dailyDeficitKcal': serializer.toJson<int>(dailyDeficitKcal),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  NutritionGoal copyWith({
    String? id,
    Value<int?> calorieTargetKcal = const Value.absent(),
    Value<double?> proteinTargetGrams = const Value.absent(),
    Value<double?> carbTargetGrams = const Value.absent(),
    Value<double?> fatTargetGrams = const Value.absent(),
    String? macroTargetMode,
    Value<double?> proteinTargetPercent = const Value.absent(),
    Value<double?> carbTargetPercent = const Value.absent(),
    Value<double?> fatTargetPercent = const Value.absent(),
    String? macroLocks,
    bool? hideCalorieNumbers,
    Value<String?> activityLevel = const Value.absent(),
    String? weightGoal,
    int? dailyDeficitKcal,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    String? syncStatus,
  }) => NutritionGoal(
    id: id ?? this.id,
    calorieTargetKcal: calorieTargetKcal.present
        ? calorieTargetKcal.value
        : this.calorieTargetKcal,
    proteinTargetGrams: proteinTargetGrams.present
        ? proteinTargetGrams.value
        : this.proteinTargetGrams,
    carbTargetGrams: carbTargetGrams.present
        ? carbTargetGrams.value
        : this.carbTargetGrams,
    fatTargetGrams: fatTargetGrams.present
        ? fatTargetGrams.value
        : this.fatTargetGrams,
    macroTargetMode: macroTargetMode ?? this.macroTargetMode,
    proteinTargetPercent: proteinTargetPercent.present
        ? proteinTargetPercent.value
        : this.proteinTargetPercent,
    carbTargetPercent: carbTargetPercent.present
        ? carbTargetPercent.value
        : this.carbTargetPercent,
    fatTargetPercent: fatTargetPercent.present
        ? fatTargetPercent.value
        : this.fatTargetPercent,
    macroLocks: macroLocks ?? this.macroLocks,
    hideCalorieNumbers: hideCalorieNumbers ?? this.hideCalorieNumbers,
    activityLevel: activityLevel.present
        ? activityLevel.value
        : this.activityLevel,
    weightGoal: weightGoal ?? this.weightGoal,
    dailyDeficitKcal: dailyDeficitKcal ?? this.dailyDeficitKcal,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  NutritionGoal copyWithCompanion(NutritionGoalsCompanion data) {
    return NutritionGoal(
      id: data.id.present ? data.id.value : this.id,
      calorieTargetKcal: data.calorieTargetKcal.present
          ? data.calorieTargetKcal.value
          : this.calorieTargetKcal,
      proteinTargetGrams: data.proteinTargetGrams.present
          ? data.proteinTargetGrams.value
          : this.proteinTargetGrams,
      carbTargetGrams: data.carbTargetGrams.present
          ? data.carbTargetGrams.value
          : this.carbTargetGrams,
      fatTargetGrams: data.fatTargetGrams.present
          ? data.fatTargetGrams.value
          : this.fatTargetGrams,
      macroTargetMode: data.macroTargetMode.present
          ? data.macroTargetMode.value
          : this.macroTargetMode,
      proteinTargetPercent: data.proteinTargetPercent.present
          ? data.proteinTargetPercent.value
          : this.proteinTargetPercent,
      carbTargetPercent: data.carbTargetPercent.present
          ? data.carbTargetPercent.value
          : this.carbTargetPercent,
      fatTargetPercent: data.fatTargetPercent.present
          ? data.fatTargetPercent.value
          : this.fatTargetPercent,
      macroLocks: data.macroLocks.present
          ? data.macroLocks.value
          : this.macroLocks,
      hideCalorieNumbers: data.hideCalorieNumbers.present
          ? data.hideCalorieNumbers.value
          : this.hideCalorieNumbers,
      activityLevel: data.activityLevel.present
          ? data.activityLevel.value
          : this.activityLevel,
      weightGoal: data.weightGoal.present
          ? data.weightGoal.value
          : this.weightGoal,
      dailyDeficitKcal: data.dailyDeficitKcal.present
          ? data.dailyDeficitKcal.value
          : this.dailyDeficitKcal,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NutritionGoal(')
          ..write('id: $id, ')
          ..write('calorieTargetKcal: $calorieTargetKcal, ')
          ..write('proteinTargetGrams: $proteinTargetGrams, ')
          ..write('carbTargetGrams: $carbTargetGrams, ')
          ..write('fatTargetGrams: $fatTargetGrams, ')
          ..write('macroTargetMode: $macroTargetMode, ')
          ..write('proteinTargetPercent: $proteinTargetPercent, ')
          ..write('carbTargetPercent: $carbTargetPercent, ')
          ..write('fatTargetPercent: $fatTargetPercent, ')
          ..write('macroLocks: $macroLocks, ')
          ..write('hideCalorieNumbers: $hideCalorieNumbers, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('weightGoal: $weightGoal, ')
          ..write('dailyDeficitKcal: $dailyDeficitKcal, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    calorieTargetKcal,
    proteinTargetGrams,
    carbTargetGrams,
    fatTargetGrams,
    macroTargetMode,
    proteinTargetPercent,
    carbTargetPercent,
    fatTargetPercent,
    macroLocks,
    hideCalorieNumbers,
    activityLevel,
    weightGoal,
    dailyDeficitKcal,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NutritionGoal &&
          other.id == this.id &&
          other.calorieTargetKcal == this.calorieTargetKcal &&
          other.proteinTargetGrams == this.proteinTargetGrams &&
          other.carbTargetGrams == this.carbTargetGrams &&
          other.fatTargetGrams == this.fatTargetGrams &&
          other.macroTargetMode == this.macroTargetMode &&
          other.proteinTargetPercent == this.proteinTargetPercent &&
          other.carbTargetPercent == this.carbTargetPercent &&
          other.fatTargetPercent == this.fatTargetPercent &&
          other.macroLocks == this.macroLocks &&
          other.hideCalorieNumbers == this.hideCalorieNumbers &&
          other.activityLevel == this.activityLevel &&
          other.weightGoal == this.weightGoal &&
          other.dailyDeficitKcal == this.dailyDeficitKcal &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus);
}

class NutritionGoalsCompanion extends UpdateCompanion<NutritionGoal> {
  final Value<String> id;
  final Value<int?> calorieTargetKcal;
  final Value<double?> proteinTargetGrams;
  final Value<double?> carbTargetGrams;
  final Value<double?> fatTargetGrams;
  final Value<String> macroTargetMode;
  final Value<double?> proteinTargetPercent;
  final Value<double?> carbTargetPercent;
  final Value<double?> fatTargetPercent;
  final Value<String> macroLocks;
  final Value<bool> hideCalorieNumbers;
  final Value<String?> activityLevel;
  final Value<String> weightGoal;
  final Value<int> dailyDeficitKcal;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const NutritionGoalsCompanion({
    this.id = const Value.absent(),
    this.calorieTargetKcal = const Value.absent(),
    this.proteinTargetGrams = const Value.absent(),
    this.carbTargetGrams = const Value.absent(),
    this.fatTargetGrams = const Value.absent(),
    this.macroTargetMode = const Value.absent(),
    this.proteinTargetPercent = const Value.absent(),
    this.carbTargetPercent = const Value.absent(),
    this.fatTargetPercent = const Value.absent(),
    this.macroLocks = const Value.absent(),
    this.hideCalorieNumbers = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.weightGoal = const Value.absent(),
    this.dailyDeficitKcal = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NutritionGoalsCompanion.insert({
    required String id,
    this.calorieTargetKcal = const Value.absent(),
    this.proteinTargetGrams = const Value.absent(),
    this.carbTargetGrams = const Value.absent(),
    this.fatTargetGrams = const Value.absent(),
    this.macroTargetMode = const Value.absent(),
    this.proteinTargetPercent = const Value.absent(),
    this.carbTargetPercent = const Value.absent(),
    this.fatTargetPercent = const Value.absent(),
    this.macroLocks = const Value.absent(),
    this.hideCalorieNumbers = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.weightGoal = const Value.absent(),
    this.dailyDeficitKcal = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<NutritionGoal> custom({
    Expression<String>? id,
    Expression<int>? calorieTargetKcal,
    Expression<double>? proteinTargetGrams,
    Expression<double>? carbTargetGrams,
    Expression<double>? fatTargetGrams,
    Expression<String>? macroTargetMode,
    Expression<double>? proteinTargetPercent,
    Expression<double>? carbTargetPercent,
    Expression<double>? fatTargetPercent,
    Expression<String>? macroLocks,
    Expression<bool>? hideCalorieNumbers,
    Expression<String>? activityLevel,
    Expression<String>? weightGoal,
    Expression<int>? dailyDeficitKcal,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (calorieTargetKcal != null) 'calorie_target_kcal': calorieTargetKcal,
      if (proteinTargetGrams != null)
        'protein_target_grams': proteinTargetGrams,
      if (carbTargetGrams != null) 'carb_target_grams': carbTargetGrams,
      if (fatTargetGrams != null) 'fat_target_grams': fatTargetGrams,
      if (macroTargetMode != null) 'macro_target_mode': macroTargetMode,
      if (proteinTargetPercent != null)
        'protein_target_percent': proteinTargetPercent,
      if (carbTargetPercent != null) 'carb_target_percent': carbTargetPercent,
      if (fatTargetPercent != null) 'fat_target_percent': fatTargetPercent,
      if (macroLocks != null) 'macro_locks': macroLocks,
      if (hideCalorieNumbers != null)
        'hide_calorie_numbers': hideCalorieNumbers,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (weightGoal != null) 'weight_goal': weightGoal,
      if (dailyDeficitKcal != null) 'daily_deficit_kcal': dailyDeficitKcal,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NutritionGoalsCompanion copyWith({
    Value<String>? id,
    Value<int?>? calorieTargetKcal,
    Value<double?>? proteinTargetGrams,
    Value<double?>? carbTargetGrams,
    Value<double?>? fatTargetGrams,
    Value<String>? macroTargetMode,
    Value<double?>? proteinTargetPercent,
    Value<double?>? carbTargetPercent,
    Value<double?>? fatTargetPercent,
    Value<String>? macroLocks,
    Value<bool>? hideCalorieNumbers,
    Value<String?>? activityLevel,
    Value<String>? weightGoal,
    Value<int>? dailyDeficitKcal,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return NutritionGoalsCompanion(
      id: id ?? this.id,
      calorieTargetKcal: calorieTargetKcal ?? this.calorieTargetKcal,
      proteinTargetGrams: proteinTargetGrams ?? this.proteinTargetGrams,
      carbTargetGrams: carbTargetGrams ?? this.carbTargetGrams,
      fatTargetGrams: fatTargetGrams ?? this.fatTargetGrams,
      macroTargetMode: macroTargetMode ?? this.macroTargetMode,
      proteinTargetPercent: proteinTargetPercent ?? this.proteinTargetPercent,
      carbTargetPercent: carbTargetPercent ?? this.carbTargetPercent,
      fatTargetPercent: fatTargetPercent ?? this.fatTargetPercent,
      macroLocks: macroLocks ?? this.macroLocks,
      hideCalorieNumbers: hideCalorieNumbers ?? this.hideCalorieNumbers,
      activityLevel: activityLevel ?? this.activityLevel,
      weightGoal: weightGoal ?? this.weightGoal,
      dailyDeficitKcal: dailyDeficitKcal ?? this.dailyDeficitKcal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (calorieTargetKcal.present) {
      map['calorie_target_kcal'] = Variable<int>(calorieTargetKcal.value);
    }
    if (proteinTargetGrams.present) {
      map['protein_target_grams'] = Variable<double>(proteinTargetGrams.value);
    }
    if (carbTargetGrams.present) {
      map['carb_target_grams'] = Variable<double>(carbTargetGrams.value);
    }
    if (fatTargetGrams.present) {
      map['fat_target_grams'] = Variable<double>(fatTargetGrams.value);
    }
    if (macroTargetMode.present) {
      map['macro_target_mode'] = Variable<String>(macroTargetMode.value);
    }
    if (proteinTargetPercent.present) {
      map['protein_target_percent'] = Variable<double>(
        proteinTargetPercent.value,
      );
    }
    if (carbTargetPercent.present) {
      map['carb_target_percent'] = Variable<double>(carbTargetPercent.value);
    }
    if (fatTargetPercent.present) {
      map['fat_target_percent'] = Variable<double>(fatTargetPercent.value);
    }
    if (macroLocks.present) {
      map['macro_locks'] = Variable<String>(macroLocks.value);
    }
    if (hideCalorieNumbers.present) {
      map['hide_calorie_numbers'] = Variable<bool>(hideCalorieNumbers.value);
    }
    if (activityLevel.present) {
      map['activity_level'] = Variable<String>(activityLevel.value);
    }
    if (weightGoal.present) {
      map['weight_goal'] = Variable<String>(weightGoal.value);
    }
    if (dailyDeficitKcal.present) {
      map['daily_deficit_kcal'] = Variable<int>(dailyDeficitKcal.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NutritionGoalsCompanion(')
          ..write('id: $id, ')
          ..write('calorieTargetKcal: $calorieTargetKcal, ')
          ..write('proteinTargetGrams: $proteinTargetGrams, ')
          ..write('carbTargetGrams: $carbTargetGrams, ')
          ..write('fatTargetGrams: $fatTargetGrams, ')
          ..write('macroTargetMode: $macroTargetMode, ')
          ..write('proteinTargetPercent: $proteinTargetPercent, ')
          ..write('carbTargetPercent: $carbTargetPercent, ')
          ..write('fatTargetPercent: $fatTargetPercent, ')
          ..write('macroLocks: $macroLocks, ')
          ..write('hideCalorieNumbers: $hideCalorieNumbers, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('weightGoal: $weightGoal, ')
          ..write('dailyDeficitKcal: $dailyDeficitKcal, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WaterLogsTable extends WaterLogs
    with TableInfo<$WaterLogsTable, WaterLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WaterLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _millilitersMeta = const VerificationMeta(
    'milliliters',
  );
  @override
  late final GeneratedColumn<int> milliliters = GeneratedColumn<int>(
    'milliliters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, day, milliliters, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'water_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WaterLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('milliliters')) {
      context.handle(
        _millilitersMeta,
        milliliters.isAcceptableOrUnknown(
          data['milliliters']!,
          _millilitersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_millilitersMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WaterLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WaterLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      milliliters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}milliliters'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WaterLogsTable createAlias(String alias) {
    return $WaterLogsTable(attachedDatabase, alias);
  }
}

class WaterLog extends DataClass implements Insertable<WaterLog> {
  /// Client-generated UUIDv7.
  final String id;

  /// ISO-8601 date string (`YYYY-MM-DD`), user-local calendar day.
  final String day;

  /// Water volume in milliliters (e.g. 250 for 1 cup / glass).
  final int milliliters;

  /// Timestamp when logged (UTC).
  final DateTime createdAt;
  const WaterLog({
    required this.id,
    required this.day,
    required this.milliliters,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day'] = Variable<String>(day);
    map['milliliters'] = Variable<int>(milliliters);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WaterLogsCompanion toCompanion(bool nullToAbsent) {
    return WaterLogsCompanion(
      id: Value(id),
      day: Value(day),
      milliliters: Value(milliliters),
      createdAt: Value(createdAt),
    );
  }

  factory WaterLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WaterLog(
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      milliliters: serializer.fromJson<int>(json['milliliters']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<String>(day),
      'milliliters': serializer.toJson<int>(milliliters),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WaterLog copyWith({
    String? id,
    String? day,
    int? milliliters,
    DateTime? createdAt,
  }) => WaterLog(
    id: id ?? this.id,
    day: day ?? this.day,
    milliliters: milliliters ?? this.milliliters,
    createdAt: createdAt ?? this.createdAt,
  );
  WaterLog copyWithCompanion(WaterLogsCompanion data) {
    return WaterLog(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      milliliters: data.milliliters.present
          ? data.milliliters.value
          : this.milliliters,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WaterLog(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('milliliters: $milliliters, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, day, milliliters, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WaterLog &&
          other.id == this.id &&
          other.day == this.day &&
          other.milliliters == this.milliliters &&
          other.createdAt == this.createdAt);
}

class WaterLogsCompanion extends UpdateCompanion<WaterLog> {
  final Value<String> id;
  final Value<String> day;
  final Value<int> milliliters;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const WaterLogsCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.milliliters = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WaterLogsCompanion.insert({
    required String id,
    required String day,
    required int milliliters,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       day = Value(day),
       milliliters = Value(milliliters),
       createdAt = Value(createdAt);
  static Insertable<WaterLog> custom({
    Expression<String>? id,
    Expression<String>? day,
    Expression<int>? milliliters,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (milliliters != null) 'milliliters': milliliters,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WaterLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? day,
    Value<int>? milliliters,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return WaterLogsCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      milliliters: milliliters ?? this.milliliters,
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
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (milliliters.present) {
      map['milliliters'] = Variable<int>(milliliters.value);
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
    return (StringBuffer('WaterLogsCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('milliliters: $milliliters, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StrengthRoutinesTable extends StrengthRoutines
    with TableInfo<$StrengthRoutinesTable, StrengthRoutine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StrengthRoutinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _exercisesJsonMeta = const VerificationMeta(
    'exercisesJson',
  );
  @override
  late final GeneratedColumn<String> exercisesJson = GeneratedColumn<String>(
    'exercises_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedDurationMinutesMeta =
      const VerificationMeta('estimatedDurationMinutes');
  @override
  late final GeneratedColumn<int> estimatedDurationMinutes =
      GeneratedColumn<int>(
        'estimated_duration_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(45),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    exercisesJson,
    estimatedDurationMinutes,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'strength_routines';
  @override
  VerificationContext validateIntegrity(
    Insertable<StrengthRoutine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('exercises_json')) {
      context.handle(
        _exercisesJsonMeta,
        exercisesJson.isAcceptableOrUnknown(
          data['exercises_json']!,
          _exercisesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exercisesJsonMeta);
    }
    if (data.containsKey('estimated_duration_minutes')) {
      context.handle(
        _estimatedDurationMinutesMeta,
        estimatedDurationMinutes.isAcceptableOrUnknown(
          data['estimated_duration_minutes']!,
          _estimatedDurationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StrengthRoutine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StrengthRoutine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      exercisesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercises_json'],
      )!,
      estimatedDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_duration_minutes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $StrengthRoutinesTable createAlias(String alias) {
    return $StrengthRoutinesTable(attachedDatabase, alias);
  }
}

class StrengthRoutine extends DataClass implements Insertable<StrengthRoutine> {
  /// Client-generated UUIDv7.
  final String id;
  final String name;
  final String description;

  /// Serialized JSON list of strength exercise templates.
  final String exercisesJson;
  final int estimatedDurationMinutes;

  /// UTC milliseconds since epoch.
  final int createdAt;

  /// UTC milliseconds since epoch.
  final int updatedAt;

  /// UTC milliseconds since epoch; null while the row is live. Soft-delete.
  final int? deletedAt;
  const StrengthRoutine({
    required this.id,
    required this.name,
    required this.description,
    required this.exercisesJson,
    required this.estimatedDurationMinutes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['exercises_json'] = Variable<String>(exercisesJson);
    map['estimated_duration_minutes'] = Variable<int>(estimatedDurationMinutes);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  StrengthRoutinesCompanion toCompanion(bool nullToAbsent) {
    return StrengthRoutinesCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      exercisesJson: Value(exercisesJson),
      estimatedDurationMinutes: Value(estimatedDurationMinutes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory StrengthRoutine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StrengthRoutine(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      exercisesJson: serializer.fromJson<String>(json['exercisesJson']),
      estimatedDurationMinutes: serializer.fromJson<int>(
        json['estimatedDurationMinutes'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'exercisesJson': serializer.toJson<String>(exercisesJson),
      'estimatedDurationMinutes': serializer.toJson<int>(
        estimatedDurationMinutes,
      ),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  StrengthRoutine copyWith({
    String? id,
    String? name,
    String? description,
    String? exercisesJson,
    int? estimatedDurationMinutes,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => StrengthRoutine(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    exercisesJson: exercisesJson ?? this.exercisesJson,
    estimatedDurationMinutes:
        estimatedDurationMinutes ?? this.estimatedDurationMinutes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  StrengthRoutine copyWithCompanion(StrengthRoutinesCompanion data) {
    return StrengthRoutine(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      exercisesJson: data.exercisesJson.present
          ? data.exercisesJson.value
          : this.exercisesJson,
      estimatedDurationMinutes: data.estimatedDurationMinutes.present
          ? data.estimatedDurationMinutes.value
          : this.estimatedDurationMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StrengthRoutine(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('exercisesJson: $exercisesJson, ')
          ..write('estimatedDurationMinutes: $estimatedDurationMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    exercisesJson,
    estimatedDurationMinutes,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StrengthRoutine &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.exercisesJson == this.exercisesJson &&
          other.estimatedDurationMinutes == this.estimatedDurationMinutes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class StrengthRoutinesCompanion extends UpdateCompanion<StrengthRoutine> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String> exercisesJson;
  final Value<int> estimatedDurationMinutes;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const StrengthRoutinesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.exercisesJson = const Value.absent(),
    this.estimatedDurationMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StrengthRoutinesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String exercisesJson,
    this.estimatedDurationMinutes = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       exercisesJson = Value(exercisesJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<StrengthRoutine> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? exercisesJson,
    Expression<int>? estimatedDurationMinutes,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (exercisesJson != null) 'exercises_json': exercisesJson,
      if (estimatedDurationMinutes != null)
        'estimated_duration_minutes': estimatedDurationMinutes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StrengthRoutinesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String>? exercisesJson,
    Value<int>? estimatedDurationMinutes,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return StrengthRoutinesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercisesJson: exercisesJson ?? this.exercisesJson,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (exercisesJson.present) {
      map['exercises_json'] = Variable<String>(exercisesJson.value);
    }
    if (estimatedDurationMinutes.present) {
      map['estimated_duration_minutes'] = Variable<int>(
        estimatedDurationMinutes.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StrengthRoutinesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('exercisesJson: $exercisesJson, ')
          ..write('estimatedDurationMinutes: $estimatedDurationMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StrengthCyclesTable extends StrengthCycles
    with TableInfo<$StrengthCyclesTable, StrengthCycle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StrengthCyclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _routinesJsonMeta = const VerificationMeta(
    'routinesJson',
  );
  @override
  late final GeneratedColumn<String> routinesJson = GeneratedColumn<String>(
    'routines_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentDayIndexMeta = const VerificationMeta(
    'currentDayIndex',
  );
  @override
  late final GeneratedColumn<int> currentDayIndex = GeneratedColumn<int>(
    'current_day_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalSessionsCompletedMeta =
      const VerificationMeta('totalSessionsCompleted');
  @override
  late final GeneratedColumn<int> totalSessionsCompleted = GeneratedColumn<int>(
    'total_sessions_completed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalVolumeLiftedKgMeta =
      const VerificationMeta('totalVolumeLiftedKg');
  @override
  late final GeneratedColumn<double> totalVolumeLiftedKg =
      GeneratedColumn<double>(
        'total_volume_lifted_kg',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastCompletedAtMeta = const VerificationMeta(
    'lastCompletedAt',
  );
  @override
  late final GeneratedColumn<int> lastCompletedAt = GeneratedColumn<int>(
    'last_completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    routinesJson,
    currentDayIndex,
    totalSessionsCompleted,
    totalVolumeLiftedKg,
    isActive,
    startedAt,
    lastCompletedAt,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'strength_cycles';
  @override
  VerificationContext validateIntegrity(
    Insertable<StrengthCycle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('routines_json')) {
      context.handle(
        _routinesJsonMeta,
        routinesJson.isAcceptableOrUnknown(
          data['routines_json']!,
          _routinesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_routinesJsonMeta);
    }
    if (data.containsKey('current_day_index')) {
      context.handle(
        _currentDayIndexMeta,
        currentDayIndex.isAcceptableOrUnknown(
          data['current_day_index']!,
          _currentDayIndexMeta,
        ),
      );
    }
    if (data.containsKey('total_sessions_completed')) {
      context.handle(
        _totalSessionsCompletedMeta,
        totalSessionsCompleted.isAcceptableOrUnknown(
          data['total_sessions_completed']!,
          _totalSessionsCompletedMeta,
        ),
      );
    }
    if (data.containsKey('total_volume_lifted_kg')) {
      context.handle(
        _totalVolumeLiftedKgMeta,
        totalVolumeLiftedKg.isAcceptableOrUnknown(
          data['total_volume_lifted_kg']!,
          _totalVolumeLiftedKgMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('last_completed_at')) {
      context.handle(
        _lastCompletedAtMeta,
        lastCompletedAt.isAcceptableOrUnknown(
          data['last_completed_at']!,
          _lastCompletedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StrengthCycle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StrengthCycle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      routinesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routines_json'],
      )!,
      currentDayIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_day_index'],
      )!,
      totalSessionsCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_sessions_completed'],
      )!,
      totalVolumeLiftedKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_volume_lifted_kg'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      ),
      lastCompletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_completed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $StrengthCyclesTable createAlias(String alias) {
    return $StrengthCyclesTable(attachedDatabase, alias);
  }
}

class StrengthCycle extends DataClass implements Insertable<StrengthCycle> {
  /// Client-generated UUIDv7.
  final String id;
  final String name;
  final String description;

  /// Serialized JSON list of day routines.
  final String routinesJson;

  /// Pointer to the active routine index in the cycle (0 -> 1 -> ...).
  final int currentDayIndex;
  final int totalSessionsCompleted;
  final double totalVolumeLiftedKg;
  final bool isActive;

  /// UTC milliseconds since epoch.
  final int? startedAt;

  /// UTC milliseconds since epoch.
  final int? lastCompletedAt;

  /// UTC milliseconds since epoch.
  final int createdAt;

  /// UTC milliseconds since epoch.
  final int updatedAt;

  /// UTC milliseconds since epoch; null while the row is live. Soft-delete.
  final int? deletedAt;
  const StrengthCycle({
    required this.id,
    required this.name,
    required this.description,
    required this.routinesJson,
    required this.currentDayIndex,
    required this.totalSessionsCompleted,
    required this.totalVolumeLiftedKg,
    required this.isActive,
    this.startedAt,
    this.lastCompletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['routines_json'] = Variable<String>(routinesJson);
    map['current_day_index'] = Variable<int>(currentDayIndex);
    map['total_sessions_completed'] = Variable<int>(totalSessionsCompleted);
    map['total_volume_lifted_kg'] = Variable<double>(totalVolumeLiftedKg);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<int>(startedAt);
    }
    if (!nullToAbsent || lastCompletedAt != null) {
      map['last_completed_at'] = Variable<int>(lastCompletedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  StrengthCyclesCompanion toCompanion(bool nullToAbsent) {
    return StrengthCyclesCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      routinesJson: Value(routinesJson),
      currentDayIndex: Value(currentDayIndex),
      totalSessionsCompleted: Value(totalSessionsCompleted),
      totalVolumeLiftedKg: Value(totalVolumeLiftedKg),
      isActive: Value(isActive),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      lastCompletedAt: lastCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCompletedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory StrengthCycle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StrengthCycle(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      routinesJson: serializer.fromJson<String>(json['routinesJson']),
      currentDayIndex: serializer.fromJson<int>(json['currentDayIndex']),
      totalSessionsCompleted: serializer.fromJson<int>(
        json['totalSessionsCompleted'],
      ),
      totalVolumeLiftedKg: serializer.fromJson<double>(
        json['totalVolumeLiftedKg'],
      ),
      isActive: serializer.fromJson<bool>(json['isActive']),
      startedAt: serializer.fromJson<int?>(json['startedAt']),
      lastCompletedAt: serializer.fromJson<int?>(json['lastCompletedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'routinesJson': serializer.toJson<String>(routinesJson),
      'currentDayIndex': serializer.toJson<int>(currentDayIndex),
      'totalSessionsCompleted': serializer.toJson<int>(totalSessionsCompleted),
      'totalVolumeLiftedKg': serializer.toJson<double>(totalVolumeLiftedKg),
      'isActive': serializer.toJson<bool>(isActive),
      'startedAt': serializer.toJson<int?>(startedAt),
      'lastCompletedAt': serializer.toJson<int?>(lastCompletedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  StrengthCycle copyWith({
    String? id,
    String? name,
    String? description,
    String? routinesJson,
    int? currentDayIndex,
    int? totalSessionsCompleted,
    double? totalVolumeLiftedKg,
    bool? isActive,
    Value<int?> startedAt = const Value.absent(),
    Value<int?> lastCompletedAt = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => StrengthCycle(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    routinesJson: routinesJson ?? this.routinesJson,
    currentDayIndex: currentDayIndex ?? this.currentDayIndex,
    totalSessionsCompleted:
        totalSessionsCompleted ?? this.totalSessionsCompleted,
    totalVolumeLiftedKg: totalVolumeLiftedKg ?? this.totalVolumeLiftedKg,
    isActive: isActive ?? this.isActive,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    lastCompletedAt: lastCompletedAt.present
        ? lastCompletedAt.value
        : this.lastCompletedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  StrengthCycle copyWithCompanion(StrengthCyclesCompanion data) {
    return StrengthCycle(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      routinesJson: data.routinesJson.present
          ? data.routinesJson.value
          : this.routinesJson,
      currentDayIndex: data.currentDayIndex.present
          ? data.currentDayIndex.value
          : this.currentDayIndex,
      totalSessionsCompleted: data.totalSessionsCompleted.present
          ? data.totalSessionsCompleted.value
          : this.totalSessionsCompleted,
      totalVolumeLiftedKg: data.totalVolumeLiftedKg.present
          ? data.totalVolumeLiftedKg.value
          : this.totalVolumeLiftedKg,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      lastCompletedAt: data.lastCompletedAt.present
          ? data.lastCompletedAt.value
          : this.lastCompletedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StrengthCycle(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('routinesJson: $routinesJson, ')
          ..write('currentDayIndex: $currentDayIndex, ')
          ..write('totalSessionsCompleted: $totalSessionsCompleted, ')
          ..write('totalVolumeLiftedKg: $totalVolumeLiftedKg, ')
          ..write('isActive: $isActive, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastCompletedAt: $lastCompletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    routinesJson,
    currentDayIndex,
    totalSessionsCompleted,
    totalVolumeLiftedKg,
    isActive,
    startedAt,
    lastCompletedAt,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StrengthCycle &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.routinesJson == this.routinesJson &&
          other.currentDayIndex == this.currentDayIndex &&
          other.totalSessionsCompleted == this.totalSessionsCompleted &&
          other.totalVolumeLiftedKg == this.totalVolumeLiftedKg &&
          other.isActive == this.isActive &&
          other.startedAt == this.startedAt &&
          other.lastCompletedAt == this.lastCompletedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class StrengthCyclesCompanion extends UpdateCompanion<StrengthCycle> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String> routinesJson;
  final Value<int> currentDayIndex;
  final Value<int> totalSessionsCompleted;
  final Value<double> totalVolumeLiftedKg;
  final Value<bool> isActive;
  final Value<int?> startedAt;
  final Value<int?> lastCompletedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const StrengthCyclesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.routinesJson = const Value.absent(),
    this.currentDayIndex = const Value.absent(),
    this.totalSessionsCompleted = const Value.absent(),
    this.totalVolumeLiftedKg = const Value.absent(),
    this.isActive = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.lastCompletedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StrengthCyclesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String routinesJson,
    this.currentDayIndex = const Value.absent(),
    this.totalSessionsCompleted = const Value.absent(),
    this.totalVolumeLiftedKg = const Value.absent(),
    this.isActive = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.lastCompletedAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       routinesJson = Value(routinesJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<StrengthCycle> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? routinesJson,
    Expression<int>? currentDayIndex,
    Expression<int>? totalSessionsCompleted,
    Expression<double>? totalVolumeLiftedKg,
    Expression<bool>? isActive,
    Expression<int>? startedAt,
    Expression<int>? lastCompletedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (routinesJson != null) 'routines_json': routinesJson,
      if (currentDayIndex != null) 'current_day_index': currentDayIndex,
      if (totalSessionsCompleted != null)
        'total_sessions_completed': totalSessionsCompleted,
      if (totalVolumeLiftedKg != null)
        'total_volume_lifted_kg': totalVolumeLiftedKg,
      if (isActive != null) 'is_active': isActive,
      if (startedAt != null) 'started_at': startedAt,
      if (lastCompletedAt != null) 'last_completed_at': lastCompletedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StrengthCyclesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String>? routinesJson,
    Value<int>? currentDayIndex,
    Value<int>? totalSessionsCompleted,
    Value<double>? totalVolumeLiftedKg,
    Value<bool>? isActive,
    Value<int?>? startedAt,
    Value<int?>? lastCompletedAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return StrengthCyclesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      routinesJson: routinesJson ?? this.routinesJson,
      currentDayIndex: currentDayIndex ?? this.currentDayIndex,
      totalSessionsCompleted:
          totalSessionsCompleted ?? this.totalSessionsCompleted,
      totalVolumeLiftedKg: totalVolumeLiftedKg ?? this.totalVolumeLiftedKg,
      isActive: isActive ?? this.isActive,
      startedAt: startedAt ?? this.startedAt,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (routinesJson.present) {
      map['routines_json'] = Variable<String>(routinesJson.value);
    }
    if (currentDayIndex.present) {
      map['current_day_index'] = Variable<int>(currentDayIndex.value);
    }
    if (totalSessionsCompleted.present) {
      map['total_sessions_completed'] = Variable<int>(
        totalSessionsCompleted.value,
      );
    }
    if (totalVolumeLiftedKg.present) {
      map['total_volume_lifted_kg'] = Variable<double>(
        totalVolumeLiftedKg.value,
      );
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (lastCompletedAt.present) {
      map['last_completed_at'] = Variable<int>(lastCompletedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StrengthCyclesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('routinesJson: $routinesJson, ')
          ..write('currentDayIndex: $currentDayIndex, ')
          ..write('totalSessionsCompleted: $totalSessionsCompleted, ')
          ..write('totalVolumeLiftedKg: $totalVolumeLiftedKg, ')
          ..write('isActive: $isActive, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastCompletedAt: $lastCompletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeightLogsTable extends WeightLogs
    with TableInfo<$WeightLogsTable, WeightLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    weightKg,
    notes,
    source,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeightLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeightLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WeightLogsTable createAlias(String alias) {
    return $WeightLogsTable(attachedDatabase, alias);
  }
}

class WeightLog extends DataClass implements Insertable<WeightLog> {
  /// Client-generated UUIDv7.
  final String id;

  /// ISO-8601 date string (`YYYY-MM-DD`), user-local calendar day. Not
  /// unique — see the class doc.
  final String day;

  /// Canonical metric (kilograms). Presentation converts to lb for
  /// imperial users.
  final double weightKg;

  /// Free-text note the user attached to this weigh-in. Nullable: nothing
  /// is ever required here. S3 — wiped by "Delete my data" with the rest
  /// of the row.
  final String? notes;

  /// One of `WeightLogSource`'s storage keys — `'manual'`,
  /// `'profile-migration'`, or `'health-sync'` (see
  /// `features/weight/domain/weight_log.dart`). Defaults to `'manual'`.
  final String source;

  /// UTC milliseconds since epoch.
  final int createdAt;

  /// UTC milliseconds since epoch.
  final int updatedAt;
  const WeightLog({
    required this.id,
    required this.day,
    required this.weightKg,
    this.notes,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day'] = Variable<String>(day);
    map['weight_kg'] = Variable<double>(weightKg);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  WeightLogsCompanion toCompanion(bool nullToAbsent) {
    return WeightLogsCompanion(
      id: Value(id),
      day: Value(day),
      weightKg: Value(weightKg),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      source: Value(source),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WeightLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeightLog(
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      notes: serializer.fromJson<String?>(json['notes']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<String>(day),
      'weightKg': serializer.toJson<double>(weightKg),
      'notes': serializer.toJson<String?>(notes),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  WeightLog copyWith({
    String? id,
    String? day,
    double? weightKg,
    Value<String?> notes = const Value.absent(),
    String? source,
    int? createdAt,
    int? updatedAt,
  }) => WeightLog(
    id: id ?? this.id,
    day: day ?? this.day,
    weightKg: weightKg ?? this.weightKg,
    notes: notes.present ? notes.value : this.notes,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WeightLog copyWithCompanion(WeightLogsCompanion data) {
    return WeightLog(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      notes: data.notes.present ? data.notes.value : this.notes,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeightLog(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('weightKg: $weightKg, ')
          ..write('notes: $notes, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, day, weightKg, notes, source, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeightLog &&
          other.id == this.id &&
          other.day == this.day &&
          other.weightKg == this.weightKg &&
          other.notes == this.notes &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WeightLogsCompanion extends UpdateCompanion<WeightLog> {
  final Value<String> id;
  final Value<String> day;
  final Value<double> weightKg;
  final Value<String?> notes;
  final Value<String> source;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const WeightLogsCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.notes = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeightLogsCompanion.insert({
    required String id,
    required String day,
    required double weightKg,
    this.notes = const Value.absent(),
    this.source = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       day = Value(day),
       weightKg = Value(weightKg),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WeightLog> custom({
    Expression<String>? id,
    Expression<String>? day,
    Expression<double>? weightKg,
    Expression<String>? notes,
    Expression<String>? source,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (weightKg != null) 'weight_kg': weightKg,
      if (notes != null) 'notes': notes,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeightLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? day,
    Value<double>? weightKg,
    Value<String?>? notes,
    Value<String>? source,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return WeightLogsCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      weightKg: weightKg ?? this.weightKg,
      notes: notes ?? this.notes,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightLogsCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('weightKg: $weightKg, ')
          ..write('notes: $notes, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BadgeAwardsTable extends BadgeAwards
    with TableInfo<$BadgeAwardsTable, BadgeAwardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BadgeAwardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _badgeIdMeta = const VerificationMeta(
    'badgeId',
  );
  @override
  late final GeneratedColumn<String> badgeId = GeneratedColumn<String>(
    'badge_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tierKeyMeta = const VerificationMeta(
    'tierKey',
  );
  @override
  late final GeneratedColumn<String> tierKey = GeneratedColumn<String>(
    'tier_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _awardedAtMeta = const VerificationMeta(
    'awardedAt',
  );
  @override
  late final GeneratedColumn<int> awardedAt = GeneratedColumn<int>(
    'awarded_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, badgeId, tierKey, awardedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'badge_awards';
  @override
  VerificationContext validateIntegrity(
    Insertable<BadgeAwardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('badge_id')) {
      context.handle(
        _badgeIdMeta,
        badgeId.isAcceptableOrUnknown(data['badge_id']!, _badgeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_badgeIdMeta);
    }
    if (data.containsKey('tier_key')) {
      context.handle(
        _tierKeyMeta,
        tierKey.isAcceptableOrUnknown(data['tier_key']!, _tierKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_tierKeyMeta);
    }
    if (data.containsKey('awarded_at')) {
      context.handle(
        _awardedAtMeta,
        awardedAt.isAcceptableOrUnknown(data['awarded_at']!, _awardedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_awardedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {badgeId, tierKey},
  ];
  @override
  BadgeAwardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BadgeAwardRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      badgeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}badge_id'],
      )!,
      tierKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tier_key'],
      )!,
      awardedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}awarded_at'],
      )!,
    );
  }

  @override
  $BadgeAwardsTable createAlias(String alias) {
    return $BadgeAwardsTable(attachedDatabase, alias);
  }
}

class BadgeAwardRow extends DataClass implements Insertable<BadgeAwardRow> {
  /// Client-generated UUIDv7.
  final String id;

  /// The catalogue id of the badge (see
  /// `features/achievements/domain/badge_catalogue.dart`). Stable forever —
  /// a shipped id is never renamed, or every user loses the award.
  final String badgeId;

  /// The storage key of the awarded tier (`'bronze'` … `'diamond-3'`), or
  /// `'once'` for a one-off badge. Never null — see the class doc.
  final String tierKey;

  /// UTC milliseconds since epoch.
  final int awardedAt;
  const BadgeAwardRow({
    required this.id,
    required this.badgeId,
    required this.tierKey,
    required this.awardedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['badge_id'] = Variable<String>(badgeId);
    map['tier_key'] = Variable<String>(tierKey);
    map['awarded_at'] = Variable<int>(awardedAt);
    return map;
  }

  BadgeAwardsCompanion toCompanion(bool nullToAbsent) {
    return BadgeAwardsCompanion(
      id: Value(id),
      badgeId: Value(badgeId),
      tierKey: Value(tierKey),
      awardedAt: Value(awardedAt),
    );
  }

  factory BadgeAwardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BadgeAwardRow(
      id: serializer.fromJson<String>(json['id']),
      badgeId: serializer.fromJson<String>(json['badgeId']),
      tierKey: serializer.fromJson<String>(json['tierKey']),
      awardedAt: serializer.fromJson<int>(json['awardedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'badgeId': serializer.toJson<String>(badgeId),
      'tierKey': serializer.toJson<String>(tierKey),
      'awardedAt': serializer.toJson<int>(awardedAt),
    };
  }

  BadgeAwardRow copyWith({
    String? id,
    String? badgeId,
    String? tierKey,
    int? awardedAt,
  }) => BadgeAwardRow(
    id: id ?? this.id,
    badgeId: badgeId ?? this.badgeId,
    tierKey: tierKey ?? this.tierKey,
    awardedAt: awardedAt ?? this.awardedAt,
  );
  BadgeAwardRow copyWithCompanion(BadgeAwardsCompanion data) {
    return BadgeAwardRow(
      id: data.id.present ? data.id.value : this.id,
      badgeId: data.badgeId.present ? data.badgeId.value : this.badgeId,
      tierKey: data.tierKey.present ? data.tierKey.value : this.tierKey,
      awardedAt: data.awardedAt.present ? data.awardedAt.value : this.awardedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BadgeAwardRow(')
          ..write('id: $id, ')
          ..write('badgeId: $badgeId, ')
          ..write('tierKey: $tierKey, ')
          ..write('awardedAt: $awardedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, badgeId, tierKey, awardedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BadgeAwardRow &&
          other.id == this.id &&
          other.badgeId == this.badgeId &&
          other.tierKey == this.tierKey &&
          other.awardedAt == this.awardedAt);
}

class BadgeAwardsCompanion extends UpdateCompanion<BadgeAwardRow> {
  final Value<String> id;
  final Value<String> badgeId;
  final Value<String> tierKey;
  final Value<int> awardedAt;
  final Value<int> rowid;
  const BadgeAwardsCompanion({
    this.id = const Value.absent(),
    this.badgeId = const Value.absent(),
    this.tierKey = const Value.absent(),
    this.awardedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BadgeAwardsCompanion.insert({
    required String id,
    required String badgeId,
    required String tierKey,
    required int awardedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       badgeId = Value(badgeId),
       tierKey = Value(tierKey),
       awardedAt = Value(awardedAt);
  static Insertable<BadgeAwardRow> custom({
    Expression<String>? id,
    Expression<String>? badgeId,
    Expression<String>? tierKey,
    Expression<int>? awardedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (badgeId != null) 'badge_id': badgeId,
      if (tierKey != null) 'tier_key': tierKey,
      if (awardedAt != null) 'awarded_at': awardedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BadgeAwardsCompanion copyWith({
    Value<String>? id,
    Value<String>? badgeId,
    Value<String>? tierKey,
    Value<int>? awardedAt,
    Value<int>? rowid,
  }) {
    return BadgeAwardsCompanion(
      id: id ?? this.id,
      badgeId: badgeId ?? this.badgeId,
      tierKey: tierKey ?? this.tierKey,
      awardedAt: awardedAt ?? this.awardedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (badgeId.present) {
      map['badge_id'] = Variable<String>(badgeId.value);
    }
    if (tierKey.present) {
      map['tier_key'] = Variable<String>(tierKey.value);
    }
    if (awardedAt.present) {
      map['awarded_at'] = Variable<int>(awardedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BadgeAwardsCompanion(')
          ..write('id: $id, ')
          ..write('badgeId: $badgeId, ')
          ..write('tierKey: $tierKey, ')
          ..write('awardedAt: $awardedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChallengesTable extends Challenges
    with TableInfo<$ChallengesTable, ChallengeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChallengesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityTypesMeta = const VerificationMeta(
    'activityTypes',
  );
  @override
  late final GeneratedColumn<String> activityTypes = GeneratedColumn<String>(
    'activity_types',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetUnitsMeta = const VerificationMeta(
    'targetUnits',
  );
  @override
  late final GeneratedColumn<int> targetUnits = GeneratedColumn<int>(
    'target_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _windowStartMeta = const VerificationMeta(
    'windowStart',
  );
  @override
  late final GeneratedColumn<String> windowStart = GeneratedColumn<String>(
    'window_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _windowEndMeta = const VerificationMeta(
    'windowEnd',
  );
  @override
  late final GeneratedColumn<String> windowEnd = GeneratedColumn<String>(
    'window_end',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<int> salt = GeneratedColumn<int>(
    'salt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _selfDisplayNameMeta = const VerificationMeta(
    'selfDisplayName',
  );
  @override
  late final GeneratedColumn<String> selfDisplayName = GeneratedColumn<String>(
    'self_display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorTagMeta = const VerificationMeta(
    'authorTag',
  );
  @override
  late final GeneratedColumn<int> authorTag = GeneratedColumn<int>(
    'author_tag',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _buddyDisplayNameMeta = const VerificationMeta(
    'buddyDisplayName',
  );
  @override
  late final GeneratedColumn<String> buddyDisplayName = GeneratedColumn<String>(
    'buddy_display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _buddyProgressPercentMeta =
      const VerificationMeta('buddyProgressPercent');
  @override
  late final GeneratedColumn<double> buddyProgressPercent =
      GeneratedColumn<double>(
        'buddy_progress_percent',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _buddyAsOfMeta = const VerificationMeta(
    'buddyAsOf',
  );
  @override
  late final GeneratedColumn<String> buddyAsOf = GeneratedColumn<String>(
    'buddy_as_of',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    activityTypes,
    targetUnits,
    windowStart,
    windowEnd,
    salt,
    selfDisplayName,
    origin,
    authorTag,
    buddyDisplayName,
    buddyProgressPercent,
    buddyAsOf,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'challenges';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChallengeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('activity_types')) {
      context.handle(
        _activityTypesMeta,
        activityTypes.isAcceptableOrUnknown(
          data['activity_types']!,
          _activityTypesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activityTypesMeta);
    }
    if (data.containsKey('target_units')) {
      context.handle(
        _targetUnitsMeta,
        targetUnits.isAcceptableOrUnknown(
          data['target_units']!,
          _targetUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetUnitsMeta);
    }
    if (data.containsKey('window_start')) {
      context.handle(
        _windowStartMeta,
        windowStart.isAcceptableOrUnknown(
          data['window_start']!,
          _windowStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_windowStartMeta);
    }
    if (data.containsKey('window_end')) {
      context.handle(
        _windowEndMeta,
        windowEnd.isAcceptableOrUnknown(data['window_end']!, _windowEndMeta),
      );
    } else if (isInserting) {
      context.missing(_windowEndMeta);
    }
    if (data.containsKey('salt')) {
      context.handle(
        _saltMeta,
        salt.isAcceptableOrUnknown(data['salt']!, _saltMeta),
      );
    } else if (isInserting) {
      context.missing(_saltMeta);
    }
    if (data.containsKey('self_display_name')) {
      context.handle(
        _selfDisplayNameMeta,
        selfDisplayName.isAcceptableOrUnknown(
          data['self_display_name']!,
          _selfDisplayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_selfDisplayNameMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('author_tag')) {
      context.handle(
        _authorTagMeta,
        authorTag.isAcceptableOrUnknown(data['author_tag']!, _authorTagMeta),
      );
    } else if (isInserting) {
      context.missing(_authorTagMeta);
    }
    if (data.containsKey('buddy_display_name')) {
      context.handle(
        _buddyDisplayNameMeta,
        buddyDisplayName.isAcceptableOrUnknown(
          data['buddy_display_name']!,
          _buddyDisplayNameMeta,
        ),
      );
    }
    if (data.containsKey('buddy_progress_percent')) {
      context.handle(
        _buddyProgressPercentMeta,
        buddyProgressPercent.isAcceptableOrUnknown(
          data['buddy_progress_percent']!,
          _buddyProgressPercentMeta,
        ),
      );
    }
    if (data.containsKey('buddy_as_of')) {
      context.handle(
        _buddyAsOfMeta,
        buddyAsOf.isAcceptableOrUnknown(data['buddy_as_of']!, _buddyAsOfMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChallengeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChallengeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      activityTypes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_types'],
      )!,
      targetUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_units'],
      )!,
      windowStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}window_start'],
      )!,
      windowEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}window_end'],
      )!,
      salt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}salt'],
      )!,
      selfDisplayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}self_display_name'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      authorTag: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}author_tag'],
      )!,
      buddyDisplayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}buddy_display_name'],
      ),
      buddyProgressPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}buddy_progress_percent'],
      ),
      buddyAsOf: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}buddy_as_of'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChallengesTable createAlias(String alias) {
    return $ChallengesTable(attachedDatabase, alias);
  }
}

class ChallengeRow extends DataClass implements Insertable<ChallengeRow> {
  /// Deterministically derived from the challenge's own defining bytes
  /// (kind, activity types, target, window, salt) — **not** a UUIDv7,
  /// deliberately, and the one place in this schema that departs from ADR
  /// 004's client-generated-UUID convention. Two devices that never talk
  /// to a server have to agree on this id from the code alone; a locally
  /// generated UUID cannot do that, and shipping one inside the code would
  /// cost 22 characters of a budget meant for a messaging app. See
  /// `features/challenges/domain/challenge_codes.dart`.
  final String id;

  /// `ChallengeKind`'s storage key — `'total_distance'` or
  /// `'session_count'`.
  final String kind;

  /// Comma-separated `ActivityType` storage keys, or `''` meaning "any
  /// type counts". Parsed at the repository boundary.
  final String activityTypes;

  /// The target in the kind's own units: hundreds of metres for
  /// `total_distance`, sessions for `session_count`. See
  /// `features/challenges/domain/challenge.dart`.
  final int targetUnits;

  /// ISO-8601 date string (`YYYY-MM-DD`), inclusive first day of the
  /// window. Calendar days, never cycle-relative — a challenge window is a
  /// date range both people can read off a calendar
  /// (`knowledge/architecture/data_architecture.md`'s calendar-day
  /// semantics).
  final String windowStart;

  /// ISO-8601 date string, inclusive last day of the window.
  final String windowEnd;

  /// The 32-bit salt mixed into [id], so two challenges created with
  /// identical parameters are still distinct challenges.
  final int salt;

  /// The name the user chose to show their buddy for this challenge. S1 —
  /// self-chosen and per-challenge, never their profile name by default.
  final String selfDisplayName;

  /// `ChallengeOrigin`'s storage key — `'created'` or `'joined'`. Kept
  /// only so the UI can say "you started this" rather than to rank anyone.
  final String origin;

  /// This device's 32-bit author tag for this challenge, drawn at random
  /// when it was created or joined and stamped into every progress code
  /// exported from here.
  ///
  /// **Local, and deliberately not part of [id].** The two devices in a
  /// challenge hold different tags for the same challenge; a pasted code
  /// carrying *this* tag is this device's own code coming back, and
  /// importing it would overwrite the buddy snapshot with the user's own
  /// figure (`features/challenges/application/challenge_code_service.dart`).
  ///
  /// S1, and only barely: it is random noise with no relationship to their
  /// name, their device or anything they have logged.
  final int authorTag;

  /// The buddy's self-chosen name from their last pasted progress code.
  /// Null until one has been pasted; null together with the two columns
  /// below.
  final String? buddyDisplayName;

  /// The buddy's progress against **their own** privately-adjusted target,
  /// as a percentage. May exceed 100. This is the only number a progress
  /// code carries, and it is deliberately not decomposable into what they
  /// did and what they were asked for.
  final double? buddyProgressPercent;

  /// ISO-8601 date string — the day the buddy's code was exported for.
  /// The repository never lets an older snapshot replace a newer one
  /// (`features/challenges/application/challenge_code_service.dart`).
  final String? buddyAsOf;

  /// UTC milliseconds since epoch — when this device first learned about
  /// the challenge (created or joined). Local metadata; not part of [id]
  /// and not carried by any code, because the two devices join at
  /// different moments and the challenge is the same challenge.
  final int createdAt;
  const ChallengeRow({
    required this.id,
    required this.kind,
    required this.activityTypes,
    required this.targetUnits,
    required this.windowStart,
    required this.windowEnd,
    required this.salt,
    required this.selfDisplayName,
    required this.origin,
    required this.authorTag,
    this.buddyDisplayName,
    this.buddyProgressPercent,
    this.buddyAsOf,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['activity_types'] = Variable<String>(activityTypes);
    map['target_units'] = Variable<int>(targetUnits);
    map['window_start'] = Variable<String>(windowStart);
    map['window_end'] = Variable<String>(windowEnd);
    map['salt'] = Variable<int>(salt);
    map['self_display_name'] = Variable<String>(selfDisplayName);
    map['origin'] = Variable<String>(origin);
    map['author_tag'] = Variable<int>(authorTag);
    if (!nullToAbsent || buddyDisplayName != null) {
      map['buddy_display_name'] = Variable<String>(buddyDisplayName);
    }
    if (!nullToAbsent || buddyProgressPercent != null) {
      map['buddy_progress_percent'] = Variable<double>(buddyProgressPercent);
    }
    if (!nullToAbsent || buddyAsOf != null) {
      map['buddy_as_of'] = Variable<String>(buddyAsOf);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ChallengesCompanion toCompanion(bool nullToAbsent) {
    return ChallengesCompanion(
      id: Value(id),
      kind: Value(kind),
      activityTypes: Value(activityTypes),
      targetUnits: Value(targetUnits),
      windowStart: Value(windowStart),
      windowEnd: Value(windowEnd),
      salt: Value(salt),
      selfDisplayName: Value(selfDisplayName),
      origin: Value(origin),
      authorTag: Value(authorTag),
      buddyDisplayName: buddyDisplayName == null && nullToAbsent
          ? const Value.absent()
          : Value(buddyDisplayName),
      buddyProgressPercent: buddyProgressPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(buddyProgressPercent),
      buddyAsOf: buddyAsOf == null && nullToAbsent
          ? const Value.absent()
          : Value(buddyAsOf),
      createdAt: Value(createdAt),
    );
  }

  factory ChallengeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChallengeRow(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      activityTypes: serializer.fromJson<String>(json['activityTypes']),
      targetUnits: serializer.fromJson<int>(json['targetUnits']),
      windowStart: serializer.fromJson<String>(json['windowStart']),
      windowEnd: serializer.fromJson<String>(json['windowEnd']),
      salt: serializer.fromJson<int>(json['salt']),
      selfDisplayName: serializer.fromJson<String>(json['selfDisplayName']),
      origin: serializer.fromJson<String>(json['origin']),
      authorTag: serializer.fromJson<int>(json['authorTag']),
      buddyDisplayName: serializer.fromJson<String?>(json['buddyDisplayName']),
      buddyProgressPercent: serializer.fromJson<double?>(
        json['buddyProgressPercent'],
      ),
      buddyAsOf: serializer.fromJson<String?>(json['buddyAsOf']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'activityTypes': serializer.toJson<String>(activityTypes),
      'targetUnits': serializer.toJson<int>(targetUnits),
      'windowStart': serializer.toJson<String>(windowStart),
      'windowEnd': serializer.toJson<String>(windowEnd),
      'salt': serializer.toJson<int>(salt),
      'selfDisplayName': serializer.toJson<String>(selfDisplayName),
      'origin': serializer.toJson<String>(origin),
      'authorTag': serializer.toJson<int>(authorTag),
      'buddyDisplayName': serializer.toJson<String?>(buddyDisplayName),
      'buddyProgressPercent': serializer.toJson<double?>(buddyProgressPercent),
      'buddyAsOf': serializer.toJson<String?>(buddyAsOf),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ChallengeRow copyWith({
    String? id,
    String? kind,
    String? activityTypes,
    int? targetUnits,
    String? windowStart,
    String? windowEnd,
    int? salt,
    String? selfDisplayName,
    String? origin,
    int? authorTag,
    Value<String?> buddyDisplayName = const Value.absent(),
    Value<double?> buddyProgressPercent = const Value.absent(),
    Value<String?> buddyAsOf = const Value.absent(),
    int? createdAt,
  }) => ChallengeRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    activityTypes: activityTypes ?? this.activityTypes,
    targetUnits: targetUnits ?? this.targetUnits,
    windowStart: windowStart ?? this.windowStart,
    windowEnd: windowEnd ?? this.windowEnd,
    salt: salt ?? this.salt,
    selfDisplayName: selfDisplayName ?? this.selfDisplayName,
    origin: origin ?? this.origin,
    authorTag: authorTag ?? this.authorTag,
    buddyDisplayName: buddyDisplayName.present
        ? buddyDisplayName.value
        : this.buddyDisplayName,
    buddyProgressPercent: buddyProgressPercent.present
        ? buddyProgressPercent.value
        : this.buddyProgressPercent,
    buddyAsOf: buddyAsOf.present ? buddyAsOf.value : this.buddyAsOf,
    createdAt: createdAt ?? this.createdAt,
  );
  ChallengeRow copyWithCompanion(ChallengesCompanion data) {
    return ChallengeRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      activityTypes: data.activityTypes.present
          ? data.activityTypes.value
          : this.activityTypes,
      targetUnits: data.targetUnits.present
          ? data.targetUnits.value
          : this.targetUnits,
      windowStart: data.windowStart.present
          ? data.windowStart.value
          : this.windowStart,
      windowEnd: data.windowEnd.present ? data.windowEnd.value : this.windowEnd,
      salt: data.salt.present ? data.salt.value : this.salt,
      selfDisplayName: data.selfDisplayName.present
          ? data.selfDisplayName.value
          : this.selfDisplayName,
      origin: data.origin.present ? data.origin.value : this.origin,
      authorTag: data.authorTag.present ? data.authorTag.value : this.authorTag,
      buddyDisplayName: data.buddyDisplayName.present
          ? data.buddyDisplayName.value
          : this.buddyDisplayName,
      buddyProgressPercent: data.buddyProgressPercent.present
          ? data.buddyProgressPercent.value
          : this.buddyProgressPercent,
      buddyAsOf: data.buddyAsOf.present ? data.buddyAsOf.value : this.buddyAsOf,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChallengeRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('activityTypes: $activityTypes, ')
          ..write('targetUnits: $targetUnits, ')
          ..write('windowStart: $windowStart, ')
          ..write('windowEnd: $windowEnd, ')
          ..write('salt: $salt, ')
          ..write('selfDisplayName: $selfDisplayName, ')
          ..write('origin: $origin, ')
          ..write('authorTag: $authorTag, ')
          ..write('buddyDisplayName: $buddyDisplayName, ')
          ..write('buddyProgressPercent: $buddyProgressPercent, ')
          ..write('buddyAsOf: $buddyAsOf, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    activityTypes,
    targetUnits,
    windowStart,
    windowEnd,
    salt,
    selfDisplayName,
    origin,
    authorTag,
    buddyDisplayName,
    buddyProgressPercent,
    buddyAsOf,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChallengeRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.activityTypes == this.activityTypes &&
          other.targetUnits == this.targetUnits &&
          other.windowStart == this.windowStart &&
          other.windowEnd == this.windowEnd &&
          other.salt == this.salt &&
          other.selfDisplayName == this.selfDisplayName &&
          other.origin == this.origin &&
          other.authorTag == this.authorTag &&
          other.buddyDisplayName == this.buddyDisplayName &&
          other.buddyProgressPercent == this.buddyProgressPercent &&
          other.buddyAsOf == this.buddyAsOf &&
          other.createdAt == this.createdAt);
}

class ChallengesCompanion extends UpdateCompanion<ChallengeRow> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> activityTypes;
  final Value<int> targetUnits;
  final Value<String> windowStart;
  final Value<String> windowEnd;
  final Value<int> salt;
  final Value<String> selfDisplayName;
  final Value<String> origin;
  final Value<int> authorTag;
  final Value<String?> buddyDisplayName;
  final Value<double?> buddyProgressPercent;
  final Value<String?> buddyAsOf;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ChallengesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.activityTypes = const Value.absent(),
    this.targetUnits = const Value.absent(),
    this.windowStart = const Value.absent(),
    this.windowEnd = const Value.absent(),
    this.salt = const Value.absent(),
    this.selfDisplayName = const Value.absent(),
    this.origin = const Value.absent(),
    this.authorTag = const Value.absent(),
    this.buddyDisplayName = const Value.absent(),
    this.buddyProgressPercent = const Value.absent(),
    this.buddyAsOf = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChallengesCompanion.insert({
    required String id,
    required String kind,
    required String activityTypes,
    required int targetUnits,
    required String windowStart,
    required String windowEnd,
    required int salt,
    required String selfDisplayName,
    required String origin,
    required int authorTag,
    this.buddyDisplayName = const Value.absent(),
    this.buddyProgressPercent = const Value.absent(),
    this.buddyAsOf = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       activityTypes = Value(activityTypes),
       targetUnits = Value(targetUnits),
       windowStart = Value(windowStart),
       windowEnd = Value(windowEnd),
       salt = Value(salt),
       selfDisplayName = Value(selfDisplayName),
       origin = Value(origin),
       authorTag = Value(authorTag),
       createdAt = Value(createdAt);
  static Insertable<ChallengeRow> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? activityTypes,
    Expression<int>? targetUnits,
    Expression<String>? windowStart,
    Expression<String>? windowEnd,
    Expression<int>? salt,
    Expression<String>? selfDisplayName,
    Expression<String>? origin,
    Expression<int>? authorTag,
    Expression<String>? buddyDisplayName,
    Expression<double>? buddyProgressPercent,
    Expression<String>? buddyAsOf,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (activityTypes != null) 'activity_types': activityTypes,
      if (targetUnits != null) 'target_units': targetUnits,
      if (windowStart != null) 'window_start': windowStart,
      if (windowEnd != null) 'window_end': windowEnd,
      if (salt != null) 'salt': salt,
      if (selfDisplayName != null) 'self_display_name': selfDisplayName,
      if (origin != null) 'origin': origin,
      if (authorTag != null) 'author_tag': authorTag,
      if (buddyDisplayName != null) 'buddy_display_name': buddyDisplayName,
      if (buddyProgressPercent != null)
        'buddy_progress_percent': buddyProgressPercent,
      if (buddyAsOf != null) 'buddy_as_of': buddyAsOf,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChallengesCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String>? activityTypes,
    Value<int>? targetUnits,
    Value<String>? windowStart,
    Value<String>? windowEnd,
    Value<int>? salt,
    Value<String>? selfDisplayName,
    Value<String>? origin,
    Value<int>? authorTag,
    Value<String?>? buddyDisplayName,
    Value<double?>? buddyProgressPercent,
    Value<String?>? buddyAsOf,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return ChallengesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      activityTypes: activityTypes ?? this.activityTypes,
      targetUnits: targetUnits ?? this.targetUnits,
      windowStart: windowStart ?? this.windowStart,
      windowEnd: windowEnd ?? this.windowEnd,
      salt: salt ?? this.salt,
      selfDisplayName: selfDisplayName ?? this.selfDisplayName,
      origin: origin ?? this.origin,
      authorTag: authorTag ?? this.authorTag,
      buddyDisplayName: buddyDisplayName ?? this.buddyDisplayName,
      buddyProgressPercent: buddyProgressPercent ?? this.buddyProgressPercent,
      buddyAsOf: buddyAsOf ?? this.buddyAsOf,
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
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (activityTypes.present) {
      map['activity_types'] = Variable<String>(activityTypes.value);
    }
    if (targetUnits.present) {
      map['target_units'] = Variable<int>(targetUnits.value);
    }
    if (windowStart.present) {
      map['window_start'] = Variable<String>(windowStart.value);
    }
    if (windowEnd.present) {
      map['window_end'] = Variable<String>(windowEnd.value);
    }
    if (salt.present) {
      map['salt'] = Variable<int>(salt.value);
    }
    if (selfDisplayName.present) {
      map['self_display_name'] = Variable<String>(selfDisplayName.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (authorTag.present) {
      map['author_tag'] = Variable<int>(authorTag.value);
    }
    if (buddyDisplayName.present) {
      map['buddy_display_name'] = Variable<String>(buddyDisplayName.value);
    }
    if (buddyProgressPercent.present) {
      map['buddy_progress_percent'] = Variable<double>(
        buddyProgressPercent.value,
      );
    }
    if (buddyAsOf.present) {
      map['buddy_as_of'] = Variable<String>(buddyAsOf.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChallengesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('activityTypes: $activityTypes, ')
          ..write('targetUnits: $targetUnits, ')
          ..write('windowStart: $windowStart, ')
          ..write('windowEnd: $windowEnd, ')
          ..write('salt: $salt, ')
          ..write('selfDisplayName: $selfDisplayName, ')
          ..write('origin: $origin, ')
          ..write('authorTag: $authorTag, ')
          ..write('buddyDisplayName: $buddyDisplayName, ')
          ..write('buddyProgressPercent: $buddyProgressPercent, ')
          ..write('buddyAsOf: $buddyAsOf, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyStepTotalsTable extends DailyStepTotals
    with TableInfo<$DailyStepTotalsTable, DailyStepTotal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyStepTotalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<int> steps = GeneratedColumn<int>(
    'steps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<int> syncedAt = GeneratedColumn<int>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [day, steps, source, syncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_step_totals';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyStepTotal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    } else if (isInserting) {
      context.missing(_stepsMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  DailyStepTotal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyStepTotal(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}steps'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $DailyStepTotalsTable createAlias(String alias) {
    return $DailyStepTotalsTable(attachedDatabase, alias);
  }
}

class DailyStepTotal extends DataClass implements Insertable<DailyStepTotal> {
  /// ISO-8601 date string (`YYYY-MM-DD`), user-local calendar day. The
  /// primary key — see the class doc for why one row per day.
  final String day;

  /// Steps accrued on [day], as reported by the health platform. Zero is a
  /// real, honest value (a day they did not carry their phone), which is why a
  /// day with no data has **no row** rather than a zero row.
  final int steps;

  /// The health platform's own label for where the count came from
  /// (`'Health Connect'`, `'Apple Health'`, …), or null when the source
  /// could not be named. Never a device identifier — a human-readable
  /// platform label only.
  final String? source;

  /// UTC milliseconds since epoch — when this row was last read from the
  /// platform. Not when the steps were taken; today's row is re-read
  /// repeatedly while the day is still accruing.
  final int syncedAt;
  const DailyStepTotal({
    required this.day,
    required this.steps,
    this.source,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['steps'] = Variable<int>(steps);
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    map['synced_at'] = Variable<int>(syncedAt);
    return map;
  }

  DailyStepTotalsCompanion toCompanion(bool nullToAbsent) {
    return DailyStepTotalsCompanion(
      day: Value(day),
      steps: Value(steps),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      syncedAt: Value(syncedAt),
    );
  }

  factory DailyStepTotal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyStepTotal(
      day: serializer.fromJson<String>(json['day']),
      steps: serializer.fromJson<int>(json['steps']),
      source: serializer.fromJson<String?>(json['source']),
      syncedAt: serializer.fromJson<int>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'steps': serializer.toJson<int>(steps),
      'source': serializer.toJson<String?>(source),
      'syncedAt': serializer.toJson<int>(syncedAt),
    };
  }

  DailyStepTotal copyWith({
    String? day,
    int? steps,
    Value<String?> source = const Value.absent(),
    int? syncedAt,
  }) => DailyStepTotal(
    day: day ?? this.day,
    steps: steps ?? this.steps,
    source: source.present ? source.value : this.source,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  DailyStepTotal copyWithCompanion(DailyStepTotalsCompanion data) {
    return DailyStepTotal(
      day: data.day.present ? data.day.value : this.day,
      steps: data.steps.present ? data.steps.value : this.steps,
      source: data.source.present ? data.source.value : this.source,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyStepTotal(')
          ..write('day: $day, ')
          ..write('steps: $steps, ')
          ..write('source: $source, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, steps, source, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyStepTotal &&
          other.day == this.day &&
          other.steps == this.steps &&
          other.source == this.source &&
          other.syncedAt == this.syncedAt);
}

class DailyStepTotalsCompanion extends UpdateCompanion<DailyStepTotal> {
  final Value<String> day;
  final Value<int> steps;
  final Value<String?> source;
  final Value<int> syncedAt;
  final Value<int> rowid;
  const DailyStepTotalsCompanion({
    this.day = const Value.absent(),
    this.steps = const Value.absent(),
    this.source = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyStepTotalsCompanion.insert({
    required String day,
    required int steps,
    this.source = const Value.absent(),
    required int syncedAt,
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       steps = Value(steps),
       syncedAt = Value(syncedAt);
  static Insertable<DailyStepTotal> custom({
    Expression<String>? day,
    Expression<int>? steps,
    Expression<String>? source,
    Expression<int>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (steps != null) 'steps': steps,
      if (source != null) 'source': source,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyStepTotalsCompanion copyWith({
    Value<String>? day,
    Value<int>? steps,
    Value<String?>? source,
    Value<int>? syncedAt,
    Value<int>? rowid,
  }) {
    return DailyStepTotalsCompanion(
      day: day ?? this.day,
      steps: steps ?? this.steps,
      source: source ?? this.source,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (steps.present) {
      map['steps'] = Variable<int>(steps.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<int>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyStepTotalsCompanion(')
          ..write('day: $day, ')
          ..write('steps: $steps, ')
          ..write('source: $source, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $YogaSequencesTable extends YogaSequences
    with TableInfo<$YogaSequencesTable, YogaSequence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $YogaSequencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _posesJsonMeta = const VerificationMeta(
    'posesJson',
  );
  @override
  late final GeneratedColumn<String> posesJson = GeneratedColumn<String>(
    'poses_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transitionSecondsMeta = const VerificationMeta(
    'transitionSeconds',
  );
  @override
  late final GeneratedColumn<int> transitionSeconds = GeneratedColumn<int>(
    'transition_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _styleMeta = const VerificationMeta('style');
  @override
  late final GeneratedColumn<String> style = GeneratedColumn<String>(
    'style',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    posesJson,
    transitionSeconds,
    style,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'yoga_sequences';
  @override
  VerificationContext validateIntegrity(
    Insertable<YogaSequence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('poses_json')) {
      context.handle(
        _posesJsonMeta,
        posesJson.isAcceptableOrUnknown(data['poses_json']!, _posesJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_posesJsonMeta);
    }
    if (data.containsKey('transition_seconds')) {
      context.handle(
        _transitionSecondsMeta,
        transitionSeconds.isAcceptableOrUnknown(
          data['transition_seconds']!,
          _transitionSecondsMeta,
        ),
      );
    }
    if (data.containsKey('style')) {
      context.handle(
        _styleMeta,
        style.isAcceptableOrUnknown(data['style']!, _styleMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  YogaSequence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return YogaSequence(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      posesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poses_json'],
      )!,
      transitionSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transition_seconds'],
      )!,
      style: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}style'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $YogaSequencesTable createAlias(String alias) {
    return $YogaSequencesTable(attachedDatabase, alias);
  }
}

class YogaSequence extends DataClass implements Insertable<YogaSequence> {
  /// Client-generated UUIDv7.
  final String id;
  final String name;
  final String description;

  /// Serialized JSON list of poses (name, hold, side, cue).
  final String posesJson;

  /// Gap held *between* consecutive poses, in seconds; never after the last
  /// pose. Zero is a legitimate value (flow straight through).
  final int transitionSeconds;

  /// One of `MindfulStyles.yogaStyles`, or null when the user picked none.
  /// Free text rather than an enum column so a label written by a newer app
  /// version round-trips instead of being coerced.
  final String? style;

  /// UTC milliseconds since epoch.
  final int createdAt;

  /// UTC milliseconds since epoch.
  final int updatedAt;

  /// UTC milliseconds since epoch; null while the row is live. Soft-delete.
  final int? deletedAt;
  const YogaSequence({
    required this.id,
    required this.name,
    required this.description,
    required this.posesJson,
    required this.transitionSeconds,
    this.style,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['poses_json'] = Variable<String>(posesJson);
    map['transition_seconds'] = Variable<int>(transitionSeconds);
    if (!nullToAbsent || style != null) {
      map['style'] = Variable<String>(style);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  YogaSequencesCompanion toCompanion(bool nullToAbsent) {
    return YogaSequencesCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      posesJson: Value(posesJson),
      transitionSeconds: Value(transitionSeconds),
      style: style == null && nullToAbsent
          ? const Value.absent()
          : Value(style),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory YogaSequence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return YogaSequence(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      posesJson: serializer.fromJson<String>(json['posesJson']),
      transitionSeconds: serializer.fromJson<int>(json['transitionSeconds']),
      style: serializer.fromJson<String?>(json['style']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'posesJson': serializer.toJson<String>(posesJson),
      'transitionSeconds': serializer.toJson<int>(transitionSeconds),
      'style': serializer.toJson<String?>(style),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  YogaSequence copyWith({
    String? id,
    String? name,
    String? description,
    String? posesJson,
    int? transitionSeconds,
    Value<String?> style = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => YogaSequence(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    posesJson: posesJson ?? this.posesJson,
    transitionSeconds: transitionSeconds ?? this.transitionSeconds,
    style: style.present ? style.value : this.style,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  YogaSequence copyWithCompanion(YogaSequencesCompanion data) {
    return YogaSequence(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      posesJson: data.posesJson.present ? data.posesJson.value : this.posesJson,
      transitionSeconds: data.transitionSeconds.present
          ? data.transitionSeconds.value
          : this.transitionSeconds,
      style: data.style.present ? data.style.value : this.style,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('YogaSequence(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('posesJson: $posesJson, ')
          ..write('transitionSeconds: $transitionSeconds, ')
          ..write('style: $style, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    posesJson,
    transitionSeconds,
    style,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is YogaSequence &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.posesJson == this.posesJson &&
          other.transitionSeconds == this.transitionSeconds &&
          other.style == this.style &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class YogaSequencesCompanion extends UpdateCompanion<YogaSequence> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String> posesJson;
  final Value<int> transitionSeconds;
  final Value<String?> style;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const YogaSequencesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.posesJson = const Value.absent(),
    this.transitionSeconds = const Value.absent(),
    this.style = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  YogaSequencesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String posesJson,
    this.transitionSeconds = const Value.absent(),
    this.style = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       posesJson = Value(posesJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<YogaSequence> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? posesJson,
    Expression<int>? transitionSeconds,
    Expression<String>? style,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (posesJson != null) 'poses_json': posesJson,
      if (transitionSeconds != null) 'transition_seconds': transitionSeconds,
      if (style != null) 'style': style,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  YogaSequencesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String>? posesJson,
    Value<int>? transitionSeconds,
    Value<String?>? style,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return YogaSequencesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      posesJson: posesJson ?? this.posesJson,
      transitionSeconds: transitionSeconds ?? this.transitionSeconds,
      style: style ?? this.style,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (posesJson.present) {
      map['poses_json'] = Variable<String>(posesJson.value);
    }
    if (transitionSeconds.present) {
      map['transition_seconds'] = Variable<int>(transitionSeconds.value);
    }
    if (style.present) {
      map['style'] = Variable<String>(style.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('YogaSequencesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('posesJson: $posesJson, ')
          ..write('transitionSeconds: $transitionSeconds, ')
          ..write('style: $style, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WellbeingEventsTable extends WellbeingEvents
    with TableInfo<$WellbeingEventsTable, WellbeingEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WellbeingEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _isCustomSavedMeta = const VerificationMeta(
    'isCustomSaved',
  );
  @override
  late final GeneratedColumn<bool> isCustomSaved = GeneratedColumn<bool>(
    'is_custom_saved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom_saved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    type,
    title,
    isCustomSaved,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wellbeing_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<WellbeingEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_custom_saved')) {
      context.handle(
        _isCustomSavedMeta,
        isCustomSaved.isAcceptableOrUnknown(
          data['is_custom_saved']!,
          _isCustomSavedMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WellbeingEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WellbeingEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      isCustomSaved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom_saved'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $WellbeingEventsTable createAlias(String alias) {
    return $WellbeingEventsTable(attachedDatabase, alias);
  }
}

class WellbeingEvent extends DataClass implements Insertable<WellbeingEvent> {
  /// Client-generated UUIDv7.
  final String id;

  /// ISO-8601 date string (`YYYY-MM-DD`), user-local calendar day.
  final String day;

  /// Persisted as `'intimacy'`, `'injury'`, `'holiday'`, or `'other'`.
  final String type;

  /// Display title for the event (e.g. "Intimacy", "Sprained Ankle", "Hawaii").
  final String title;

  /// Whether saved to the user's reusable custom templates.
  final bool isCustomSaved;

  /// Optional free-text notes.
  final String? notes;

  /// UTC milliseconds since epoch.
  final int createdAt;

  /// UTC milliseconds since epoch.
  final int updatedAt;

  /// UTC milliseconds since epoch; null while the row is live.
  final int? deletedAt;
  const WellbeingEvent({
    required this.id,
    required this.day,
    required this.type,
    required this.title,
    required this.isCustomSaved,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day'] = Variable<String>(day);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['is_custom_saved'] = Variable<bool>(isCustomSaved);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  WellbeingEventsCompanion toCompanion(bool nullToAbsent) {
    return WellbeingEventsCompanion(
      id: Value(id),
      day: Value(day),
      type: Value(type),
      title: Value(title),
      isCustomSaved: Value(isCustomSaved),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory WellbeingEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WellbeingEvent(
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      isCustomSaved: serializer.fromJson<bool>(json['isCustomSaved']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<String>(day),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'isCustomSaved': serializer.toJson<bool>(isCustomSaved),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  WellbeingEvent copyWith({
    String? id,
    String? day,
    String? type,
    String? title,
    bool? isCustomSaved,
    Value<String?> notes = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => WellbeingEvent(
    id: id ?? this.id,
    day: day ?? this.day,
    type: type ?? this.type,
    title: title ?? this.title,
    isCustomSaved: isCustomSaved ?? this.isCustomSaved,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  WellbeingEvent copyWithCompanion(WellbeingEventsCompanion data) {
    return WellbeingEvent(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      isCustomSaved: data.isCustomSaved.present
          ? data.isCustomSaved.value
          : this.isCustomSaved,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WellbeingEvent(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('isCustomSaved: $isCustomSaved, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    day,
    type,
    title,
    isCustomSaved,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WellbeingEvent &&
          other.id == this.id &&
          other.day == this.day &&
          other.type == this.type &&
          other.title == this.title &&
          other.isCustomSaved == this.isCustomSaved &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class WellbeingEventsCompanion extends UpdateCompanion<WellbeingEvent> {
  final Value<String> id;
  final Value<String> day;
  final Value<String> type;
  final Value<String> title;
  final Value<bool> isCustomSaved;
  final Value<String?> notes;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const WellbeingEventsCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.isCustomSaved = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WellbeingEventsCompanion.insert({
    required String id,
    required String day,
    required String type,
    required String title,
    this.isCustomSaved = const Value.absent(),
    this.notes = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       day = Value(day),
       type = Value(type),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WellbeingEvent> custom({
    Expression<String>? id,
    Expression<String>? day,
    Expression<String>? type,
    Expression<String>? title,
    Expression<bool>? isCustomSaved,
    Expression<String>? notes,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (isCustomSaved != null) 'is_custom_saved': isCustomSaved,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WellbeingEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? day,
    Value<String>? type,
    Value<String>? title,
    Value<bool>? isCustomSaved,
    Value<String?>? notes,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return WellbeingEventsCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      type: type ?? this.type,
      title: title ?? this.title,
      isCustomSaved: isCustomSaved ?? this.isCustomSaved,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isCustomSaved.present) {
      map['is_custom_saved'] = Variable<bool>(isCustomSaved.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WellbeingEventsCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('isCustomSaved: $isCustomSaved, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KetoneReadingsTable extends KetoneReadings
    with TableInfo<$KetoneReadingsTable, KetoneReading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KetoneReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _measuredAtMeta = const VerificationMeta(
    'measuredAt',
  );
  @override
  late final GeneratedColumn<int> measuredAt = GeneratedColumn<int>(
    'measured_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    measuredAt,
    type,
    result,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ketone_readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<KetoneReading> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('measured_at')) {
      context.handle(
        _measuredAtMeta,
        measuredAt.isAcceptableOrUnknown(data['measured_at']!, _measuredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_measuredAtMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KetoneReading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KetoneReading(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      measuredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}measured_at'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $KetoneReadingsTable createAlias(String alias) {
    return $KetoneReadingsTable(attachedDatabase, alias);
  }
}

class KetoneReading extends DataClass implements Insertable<KetoneReading> {
  final String id;
  final String day;
  final int measuredAt;
  final String type;
  final String result;
  final int createdAt;
  final int updatedAt;
  const KetoneReading({
    required this.id,
    required this.day,
    required this.measuredAt,
    required this.type,
    required this.result,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day'] = Variable<String>(day);
    map['measured_at'] = Variable<int>(measuredAt);
    map['type'] = Variable<String>(type);
    map['result'] = Variable<String>(result);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  KetoneReadingsCompanion toCompanion(bool nullToAbsent) {
    return KetoneReadingsCompanion(
      id: Value(id),
      day: Value(day),
      measuredAt: Value(measuredAt),
      type: Value(type),
      result: Value(result),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory KetoneReading.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KetoneReading(
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      measuredAt: serializer.fromJson<int>(json['measuredAt']),
      type: serializer.fromJson<String>(json['type']),
      result: serializer.fromJson<String>(json['result']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<String>(day),
      'measuredAt': serializer.toJson<int>(measuredAt),
      'type': serializer.toJson<String>(type),
      'result': serializer.toJson<String>(result),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  KetoneReading copyWith({
    String? id,
    String? day,
    int? measuredAt,
    String? type,
    String? result,
    int? createdAt,
    int? updatedAt,
  }) => KetoneReading(
    id: id ?? this.id,
    day: day ?? this.day,
    measuredAt: measuredAt ?? this.measuredAt,
    type: type ?? this.type,
    result: result ?? this.result,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  KetoneReading copyWithCompanion(KetoneReadingsCompanion data) {
    return KetoneReading(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      measuredAt: data.measuredAt.present
          ? data.measuredAt.value
          : this.measuredAt,
      type: data.type.present ? data.type.value : this.type,
      result: data.result.present ? data.result.value : this.result,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KetoneReading(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('type: $type, ')
          ..write('result: $result, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, day, measuredAt, type, result, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KetoneReading &&
          other.id == this.id &&
          other.day == this.day &&
          other.measuredAt == this.measuredAt &&
          other.type == this.type &&
          other.result == this.result &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class KetoneReadingsCompanion extends UpdateCompanion<KetoneReading> {
  final Value<String> id;
  final Value<String> day;
  final Value<int> measuredAt;
  final Value<String> type;
  final Value<String> result;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const KetoneReadingsCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.type = const Value.absent(),
    this.result = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KetoneReadingsCompanion.insert({
    required String id,
    required String day,
    required int measuredAt,
    required String type,
    required String result,
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       day = Value(day),
       measuredAt = Value(measuredAt),
       type = Value(type),
       result = Value(result),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<KetoneReading> custom({
    Expression<String>? id,
    Expression<String>? day,
    Expression<int>? measuredAt,
    Expression<String>? type,
    Expression<String>? result,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (measuredAt != null) 'measured_at': measuredAt,
      if (type != null) 'type': type,
      if (result != null) 'result': result,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KetoneReadingsCompanion copyWith({
    Value<String>? id,
    Value<String>? day,
    Value<int>? measuredAt,
    Value<String>? type,
    Value<String>? result,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return KetoneReadingsCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      measuredAt: measuredAt ?? this.measuredAt,
      type: type ?? this.type,
      result: result ?? this.result,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (measuredAt.present) {
      map['measured_at'] = Variable<int>(measuredAt.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KetoneReadingsCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('type: $type, ')
          ..write('result: $result, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BloodPressureReadingsTable extends BloodPressureReadings
    with TableInfo<$BloodPressureReadingsTable, BloodPressureReading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BloodPressureReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _measuredAtMeta = const VerificationMeta(
    'measuredAt',
  );
  @override
  late final GeneratedColumn<int> measuredAt = GeneratedColumn<int>(
    'measured_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systolicMeta = const VerificationMeta(
    'systolic',
  );
  @override
  late final GeneratedColumn<int> systolic = GeneratedColumn<int>(
    'systolic',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diastolicMeta = const VerificationMeta(
    'diastolic',
  );
  @override
  late final GeneratedColumn<int> diastolic = GeneratedColumn<int>(
    'diastolic',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pulseMeta = const VerificationMeta('pulse');
  @override
  late final GeneratedColumn<int> pulse = GeneratedColumn<int>(
    'pulse',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    measuredAt,
    systolic,
    diastolic,
    pulse,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'blood_pressure_readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<BloodPressureReading> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('measured_at')) {
      context.handle(
        _measuredAtMeta,
        measuredAt.isAcceptableOrUnknown(data['measured_at']!, _measuredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_measuredAtMeta);
    }
    if (data.containsKey('systolic')) {
      context.handle(
        _systolicMeta,
        systolic.isAcceptableOrUnknown(data['systolic']!, _systolicMeta),
      );
    } else if (isInserting) {
      context.missing(_systolicMeta);
    }
    if (data.containsKey('diastolic')) {
      context.handle(
        _diastolicMeta,
        diastolic.isAcceptableOrUnknown(data['diastolic']!, _diastolicMeta),
      );
    } else if (isInserting) {
      context.missing(_diastolicMeta);
    }
    if (data.containsKey('pulse')) {
      context.handle(
        _pulseMeta,
        pulse.isAcceptableOrUnknown(data['pulse']!, _pulseMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BloodPressureReading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BloodPressureReading(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      measuredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}measured_at'],
      )!,
      systolic: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}systolic'],
      )!,
      diastolic: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}diastolic'],
      )!,
      pulse: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pulse'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BloodPressureReadingsTable createAlias(String alias) {
    return $BloodPressureReadingsTable(attachedDatabase, alias);
  }
}

class BloodPressureReading extends DataClass
    implements Insertable<BloodPressureReading> {
  final String id;
  final String day;
  final int measuredAt;
  final int systolic;
  final int diastolic;
  final int? pulse;
  final String? note;
  final int createdAt;
  final int updatedAt;
  const BloodPressureReading({
    required this.id,
    required this.day,
    required this.measuredAt,
    required this.systolic,
    required this.diastolic,
    this.pulse,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day'] = Variable<String>(day);
    map['measured_at'] = Variable<int>(measuredAt);
    map['systolic'] = Variable<int>(systolic);
    map['diastolic'] = Variable<int>(diastolic);
    if (!nullToAbsent || pulse != null) {
      map['pulse'] = Variable<int>(pulse);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  BloodPressureReadingsCompanion toCompanion(bool nullToAbsent) {
    return BloodPressureReadingsCompanion(
      id: Value(id),
      day: Value(day),
      measuredAt: Value(measuredAt),
      systolic: Value(systolic),
      diastolic: Value(diastolic),
      pulse: pulse == null && nullToAbsent
          ? const Value.absent()
          : Value(pulse),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BloodPressureReading.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BloodPressureReading(
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      measuredAt: serializer.fromJson<int>(json['measuredAt']),
      systolic: serializer.fromJson<int>(json['systolic']),
      diastolic: serializer.fromJson<int>(json['diastolic']),
      pulse: serializer.fromJson<int?>(json['pulse']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<String>(day),
      'measuredAt': serializer.toJson<int>(measuredAt),
      'systolic': serializer.toJson<int>(systolic),
      'diastolic': serializer.toJson<int>(diastolic),
      'pulse': serializer.toJson<int?>(pulse),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  BloodPressureReading copyWith({
    String? id,
    String? day,
    int? measuredAt,
    int? systolic,
    int? diastolic,
    Value<int?> pulse = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => BloodPressureReading(
    id: id ?? this.id,
    day: day ?? this.day,
    measuredAt: measuredAt ?? this.measuredAt,
    systolic: systolic ?? this.systolic,
    diastolic: diastolic ?? this.diastolic,
    pulse: pulse.present ? pulse.value : this.pulse,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BloodPressureReading copyWithCompanion(BloodPressureReadingsCompanion data) {
    return BloodPressureReading(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      measuredAt: data.measuredAt.present
          ? data.measuredAt.value
          : this.measuredAt,
      systolic: data.systolic.present ? data.systolic.value : this.systolic,
      diastolic: data.diastolic.present ? data.diastolic.value : this.diastolic,
      pulse: data.pulse.present ? data.pulse.value : this.pulse,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BloodPressureReading(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('systolic: $systolic, ')
          ..write('diastolic: $diastolic, ')
          ..write('pulse: $pulse, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    day,
    measuredAt,
    systolic,
    diastolic,
    pulse,
    note,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BloodPressureReading &&
          other.id == this.id &&
          other.day == this.day &&
          other.measuredAt == this.measuredAt &&
          other.systolic == this.systolic &&
          other.diastolic == this.diastolic &&
          other.pulse == this.pulse &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BloodPressureReadingsCompanion
    extends UpdateCompanion<BloodPressureReading> {
  final Value<String> id;
  final Value<String> day;
  final Value<int> measuredAt;
  final Value<int> systolic;
  final Value<int> diastolic;
  final Value<int?> pulse;
  final Value<String?> note;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const BloodPressureReadingsCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.systolic = const Value.absent(),
    this.diastolic = const Value.absent(),
    this.pulse = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BloodPressureReadingsCompanion.insert({
    required String id,
    required String day,
    required int measuredAt,
    required int systolic,
    required int diastolic,
    this.pulse = const Value.absent(),
    this.note = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       day = Value(day),
       measuredAt = Value(measuredAt),
       systolic = Value(systolic),
       diastolic = Value(diastolic),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BloodPressureReading> custom({
    Expression<String>? id,
    Expression<String>? day,
    Expression<int>? measuredAt,
    Expression<int>? systolic,
    Expression<int>? diastolic,
    Expression<int>? pulse,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (measuredAt != null) 'measured_at': measuredAt,
      if (systolic != null) 'systolic': systolic,
      if (diastolic != null) 'diastolic': diastolic,
      if (pulse != null) 'pulse': pulse,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BloodPressureReadingsCompanion copyWith({
    Value<String>? id,
    Value<String>? day,
    Value<int>? measuredAt,
    Value<int>? systolic,
    Value<int>? diastolic,
    Value<int?>? pulse,
    Value<String?>? note,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return BloodPressureReadingsCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      measuredAt: measuredAt ?? this.measuredAt,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      pulse: pulse ?? this.pulse,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (measuredAt.present) {
      map['measured_at'] = Variable<int>(measuredAt.value);
    }
    if (systolic.present) {
      map['systolic'] = Variable<int>(systolic.value);
    }
    if (diastolic.present) {
      map['diastolic'] = Variable<int>(diastolic.value);
    }
    if (pulse.present) {
      map['pulse'] = Variable<int>(pulse.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BloodPressureReadingsCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('systolic: $systolic, ')
          ..write('diastolic: $diastolic, ')
          ..write('pulse: $pulse, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BloodMarkerReadingsTable extends BloodMarkerReadings
    with TableInfo<$BloodMarkerReadingsTable, BloodMarkerReading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BloodMarkerReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _measuredAtMeta = const VerificationMeta(
    'measuredAt',
  );
  @override
  late final GeneratedColumn<int> measuredAt = GeneratedColumn<int>(
    'measured_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _markerMeta = const VerificationMeta('marker');
  @override
  late final GeneratedColumn<String> marker = GeneratedColumn<String>(
    'marker',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextMeta = const VerificationMeta(
    'context',
  );
  @override
  late final GeneratedColumn<String> context = GeneratedColumn<String>(
    'context',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    measuredAt,
    marker,
    value,
    unit,
    context,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'blood_marker_readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<BloodMarkerReading> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('measured_at')) {
      context.handle(
        _measuredAtMeta,
        measuredAt.isAcceptableOrUnknown(data['measured_at']!, _measuredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_measuredAtMeta);
    }
    if (data.containsKey('marker')) {
      context.handle(
        _markerMeta,
        marker.isAcceptableOrUnknown(data['marker']!, _markerMeta),
      );
    } else if (isInserting) {
      context.missing(_markerMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('context')) {
      context.handle(
        _contextMeta,
        this.context.isAcceptableOrUnknown(data['context']!, _contextMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BloodMarkerReading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BloodMarkerReading(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      measuredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}measured_at'],
      )!,
      marker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marker'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      context: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BloodMarkerReadingsTable createAlias(String alias) {
    return $BloodMarkerReadingsTable(attachedDatabase, alias);
  }
}

class BloodMarkerReading extends DataClass
    implements Insertable<BloodMarkerReading> {
  final String id;
  final String day;
  final int measuredAt;
  final String marker;
  final double value;
  final String unit;
  final String? context;
  final String? note;
  final int createdAt;
  final int updatedAt;
  const BloodMarkerReading({
    required this.id,
    required this.day,
    required this.measuredAt,
    required this.marker,
    required this.value,
    required this.unit,
    this.context,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day'] = Variable<String>(day);
    map['measured_at'] = Variable<int>(measuredAt);
    map['marker'] = Variable<String>(marker);
    map['value'] = Variable<double>(value);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || context != null) {
      map['context'] = Variable<String>(context);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  BloodMarkerReadingsCompanion toCompanion(bool nullToAbsent) {
    return BloodMarkerReadingsCompanion(
      id: Value(id),
      day: Value(day),
      measuredAt: Value(measuredAt),
      marker: Value(marker),
      value: Value(value),
      unit: Value(unit),
      context: context == null && nullToAbsent
          ? const Value.absent()
          : Value(context),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BloodMarkerReading.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BloodMarkerReading(
      id: serializer.fromJson<String>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      measuredAt: serializer.fromJson<int>(json['measuredAt']),
      marker: serializer.fromJson<String>(json['marker']),
      value: serializer.fromJson<double>(json['value']),
      unit: serializer.fromJson<String>(json['unit']),
      context: serializer.fromJson<String?>(json['context']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'day': serializer.toJson<String>(day),
      'measuredAt': serializer.toJson<int>(measuredAt),
      'marker': serializer.toJson<String>(marker),
      'value': serializer.toJson<double>(value),
      'unit': serializer.toJson<String>(unit),
      'context': serializer.toJson<String?>(context),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  BloodMarkerReading copyWith({
    String? id,
    String? day,
    int? measuredAt,
    String? marker,
    double? value,
    String? unit,
    Value<String?> context = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => BloodMarkerReading(
    id: id ?? this.id,
    day: day ?? this.day,
    measuredAt: measuredAt ?? this.measuredAt,
    marker: marker ?? this.marker,
    value: value ?? this.value,
    unit: unit ?? this.unit,
    context: context.present ? context.value : this.context,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BloodMarkerReading copyWithCompanion(BloodMarkerReadingsCompanion data) {
    return BloodMarkerReading(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      measuredAt: data.measuredAt.present
          ? data.measuredAt.value
          : this.measuredAt,
      marker: data.marker.present ? data.marker.value : this.marker,
      value: data.value.present ? data.value.value : this.value,
      unit: data.unit.present ? data.unit.value : this.unit,
      context: data.context.present ? data.context.value : this.context,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BloodMarkerReading(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('marker: $marker, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('context: $context, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    day,
    measuredAt,
    marker,
    value,
    unit,
    context,
    note,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BloodMarkerReading &&
          other.id == this.id &&
          other.day == this.day &&
          other.measuredAt == this.measuredAt &&
          other.marker == this.marker &&
          other.value == this.value &&
          other.unit == this.unit &&
          other.context == this.context &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BloodMarkerReadingsCompanion extends UpdateCompanion<BloodMarkerReading> {
  final Value<String> id;
  final Value<String> day;
  final Value<int> measuredAt;
  final Value<String> marker;
  final Value<double> value;
  final Value<String> unit;
  final Value<String?> context;
  final Value<String?> note;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const BloodMarkerReadingsCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.marker = const Value.absent(),
    this.value = const Value.absent(),
    this.unit = const Value.absent(),
    this.context = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BloodMarkerReadingsCompanion.insert({
    required String id,
    required String day,
    required int measuredAt,
    required String marker,
    required double value,
    required String unit,
    this.context = const Value.absent(),
    this.note = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       day = Value(day),
       measuredAt = Value(measuredAt),
       marker = Value(marker),
       value = Value(value),
       unit = Value(unit),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BloodMarkerReading> custom({
    Expression<String>? id,
    Expression<String>? day,
    Expression<int>? measuredAt,
    Expression<String>? marker,
    Expression<double>? value,
    Expression<String>? unit,
    Expression<String>? context,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (measuredAt != null) 'measured_at': measuredAt,
      if (marker != null) 'marker': marker,
      if (value != null) 'value': value,
      if (unit != null) 'unit': unit,
      if (context != null) 'context': context,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BloodMarkerReadingsCompanion copyWith({
    Value<String>? id,
    Value<String>? day,
    Value<int>? measuredAt,
    Value<String>? marker,
    Value<double>? value,
    Value<String>? unit,
    Value<String?>? context,
    Value<String?>? note,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return BloodMarkerReadingsCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      measuredAt: measuredAt ?? this.measuredAt,
      marker: marker ?? this.marker,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      context: context ?? this.context,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (measuredAt.present) {
      map['measured_at'] = Variable<int>(measuredAt.value);
    }
    if (marker.present) {
      map['marker'] = Variable<String>(marker.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (context.present) {
      map['context'] = Variable<String>(context.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BloodMarkerReadingsCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('marker: $marker, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('context: $context, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $ActivitySamplesTable activitySamples = $ActivitySamplesTable(
    this,
  );
  late final $DailyCheckinsTable dailyCheckins = $DailyCheckinsTable(this);
  late final $FlareEventsTable flareEvents = $FlareEventsTable(this);
  late final $RecoveryDaysTable recoveryDays = $RecoveryDaysTable(this);
  late final $RoutesTable routes = $RoutesTable(this);
  late final $FoodsTable foods = $FoodsTable(this);
  late final $NutritionEntriesTable nutritionEntries = $NutritionEntriesTable(
    this,
  );
  late final $NutritionGoalsTable nutritionGoals = $NutritionGoalsTable(this);
  late final $WaterLogsTable waterLogs = $WaterLogsTable(this);
  late final $StrengthRoutinesTable strengthRoutines = $StrengthRoutinesTable(
    this,
  );
  late final $StrengthCyclesTable strengthCycles = $StrengthCyclesTable(this);
  late final $WeightLogsTable weightLogs = $WeightLogsTable(this);
  late final $BadgeAwardsTable badgeAwards = $BadgeAwardsTable(this);
  late final $ChallengesTable challenges = $ChallengesTable(this);
  late final $DailyStepTotalsTable dailyStepTotals = $DailyStepTotalsTable(
    this,
  );
  late final $YogaSequencesTable yogaSequences = $YogaSequencesTable(this);
  late final $WellbeingEventsTable wellbeingEvents = $WellbeingEventsTable(
    this,
  );
  late final $KetoneReadingsTable ketoneReadings = $KetoneReadingsTable(this);
  late final $BloodPressureReadingsTable bloodPressureReadings =
      $BloodPressureReadingsTable(this);
  late final $BloodMarkerReadingsTable bloodMarkerReadings =
      $BloodMarkerReadingsTable(this);
  late final Index idxActivitiesStartedAt = Index(
    'idx_activities_started_at',
    'CREATE INDEX idx_activities_started_at ON activities (started_at)',
  );
  late final Index idxActivitySamplesActivityIdTimestampMs = Index(
    'idx_activity_samples_activity_id_timestamp_ms',
    'CREATE INDEX idx_activity_samples_activity_id_timestamp_ms ON activity_samples (activity_id, timestamp_ms)',
  );
  late final Index idxDailyCheckinsDay = Index(
    'idx_daily_checkins_day',
    'CREATE UNIQUE INDEX idx_daily_checkins_day ON daily_checkins (day)',
  );
  late final Index idxFlareEventsDay = Index(
    'idx_flare_events_day',
    'CREATE INDEX idx_flare_events_day ON flare_events (day)',
  );
  late final Index idxRecoveryDaysDay = Index(
    'idx_recovery_days_day',
    'CREATE UNIQUE INDEX idx_recovery_days_day ON recovery_days (day)',
  );
  late final Index idxFoodsName = Index(
    'idx_foods_name',
    'CREATE INDEX idx_foods_name ON foods (name)',
  );
  late final Index idxFoodsBarcode = Index(
    'idx_foods_barcode',
    'CREATE INDEX idx_foods_barcode ON foods (barcode)',
  );
  late final Index idxFoodsProviderFoodId = Index(
    'idx_foods_provider_food_id',
    'CREATE INDEX idx_foods_provider_food_id ON foods (source, provider_food_id)',
  );
  late final Index idxNutritionEntriesDay = Index(
    'idx_nutrition_entries_day',
    'CREATE INDEX idx_nutrition_entries_day ON nutrition_entries (day)',
  );
  late final Index idxWaterLogsDay = Index(
    'idx_water_logs_day',
    'CREATE INDEX idx_water_logs_day ON water_logs (day)',
  );
  late final Index idxWeightLogsDay = Index(
    'idx_weight_logs_day',
    'CREATE INDEX idx_weight_logs_day ON weight_logs (day)',
  );
  late final Index idxKetoneReadingsDay = Index(
    'idx_ketone_readings_day',
    'CREATE INDEX idx_ketone_readings_day ON ketone_readings (day)',
  );
  late final Index idxBloodPressureReadingsMeasuredAt = Index(
    'idx_blood_pressure_readings_measured_at',
    'CREATE INDEX idx_blood_pressure_readings_measured_at ON blood_pressure_readings (measured_at)',
  );
  late final Index idxBloodMarkerReadingsMarkerMeasuredAt = Index(
    'idx_blood_marker_readings_marker_measured_at',
    'CREATE INDEX idx_blood_marker_readings_marker_measured_at ON blood_marker_readings (marker, measured_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    activities,
    activitySamples,
    dailyCheckins,
    flareEvents,
    recoveryDays,
    routes,
    foods,
    nutritionEntries,
    nutritionGoals,
    waterLogs,
    strengthRoutines,
    strengthCycles,
    weightLogs,
    badgeAwards,
    challenges,
    dailyStepTotals,
    yogaSequences,
    wellbeingEvents,
    ketoneReadings,
    bloodPressureReadings,
    bloodMarkerReadings,
    idxActivitiesStartedAt,
    idxActivitySamplesActivityIdTimestampMs,
    idxDailyCheckinsDay,
    idxFlareEventsDay,
    idxRecoveryDaysDay,
    idxFoodsName,
    idxFoodsBarcode,
    idxFoodsProviderFoodId,
    idxNutritionEntriesDay,
    idxWaterLogsDay,
    idxWeightLogsDay,
    idxKetoneReadingsDay,
    idxBloodPressureReadingsMeasuredAt,
    idxBloodMarkerReadingsMarkerMeasuredAt,
  ];
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      required String id,
      required String displayName,
      required String unitSystem,
      Value<int?> weeklyActivityGoal,
      Value<String?> dateOfBirth,
      Value<double?> heightCm,
      Value<double?> weightKg,
      Value<String?> fitnessGoal,
      Value<String?> runningExperience,
      Value<String?> strengthExperience,
      Value<String> trainingDays,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<String> unitSystem,
      Value<int?> weeklyActivityGoal,
      Value<String?> dateOfBirth,
      Value<double?> heightCm,
      Value<double?> weightKg,
      Value<String?> fitnessGoal,
      Value<String?> runningExperience,
      Value<String?> strengthExperience,
      Value<String> trainingDays,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weeklyActivityGoal => $composableBuilder(
    column: $table.weeklyActivityGoal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fitnessGoal => $composableBuilder(
    column: $table.fitnessGoal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get runningExperience => $composableBuilder(
    column: $table.runningExperience,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strengthExperience => $composableBuilder(
    column: $table.strengthExperience,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trainingDays => $composableBuilder(
    column: $table.trainingDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weeklyActivityGoal => $composableBuilder(
    column: $table.weeklyActivityGoal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fitnessGoal => $composableBuilder(
    column: $table.fitnessGoal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get runningExperience => $composableBuilder(
    column: $table.runningExperience,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strengthExperience => $composableBuilder(
    column: $table.strengthExperience,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trainingDays => $composableBuilder(
    column: $table.trainingDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weeklyActivityGoal => $composableBuilder(
    column: $table.weeklyActivityGoal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get fitnessGoal => $composableBuilder(
    column: $table.fitnessGoal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get runningExperience => $composableBuilder(
    column: $table.runningExperience,
    builder: (column) => column,
  );

  GeneratedColumn<String> get strengthExperience => $composableBuilder(
    column: $table.strengthExperience,
    builder: (column) => column,
  );

  GeneratedColumn<String> get trainingDays => $composableBuilder(
    column: $table.trainingDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> unitSystem = const Value.absent(),
                Value<int?> weeklyActivityGoal = const Value.absent(),
                Value<String?> dateOfBirth = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String?> fitnessGoal = const Value.absent(),
                Value<String?> runningExperience = const Value.absent(),
                Value<String?> strengthExperience = const Value.absent(),
                Value<String> trainingDays = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                displayName: displayName,
                unitSystem: unitSystem,
                weeklyActivityGoal: weeklyActivityGoal,
                dateOfBirth: dateOfBirth,
                heightCm: heightCm,
                weightKg: weightKg,
                fitnessGoal: fitnessGoal,
                runningExperience: runningExperience,
                strengthExperience: strengthExperience,
                trainingDays: trainingDays,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                required String unitSystem,
                Value<int?> weeklyActivityGoal = const Value.absent(),
                Value<String?> dateOfBirth = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String?> fitnessGoal = const Value.absent(),
                Value<String?> runningExperience = const Value.absent(),
                Value<String?> strengthExperience = const Value.absent(),
                Value<String> trainingDays = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                displayName: displayName,
                unitSystem: unitSystem,
                weeklyActivityGoal: weeklyActivityGoal,
                dateOfBirth: dateOfBirth,
                heightCm: heightCm,
                weightKg: weightKg,
                fitnessGoal: fitnessGoal,
                runningExperience: runningExperience,
                strengthExperience: strengthExperience,
                trainingDays: trainingDays,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$ActivitiesTableCreateCompanionBuilder = ActivitiesCompanion Function({
  required String id,
  required String activityType,
  required String title,
  Value<String?> notes,
  required int startedAt,
  required int movingTimeMs,
  required int elapsedTimeMs,
  required double distanceMeters,
  Value<double?> elevationGainMeters,
  Value<int?> avgHeartRate,
  required String source,
  Value<String?> routeId,
  Value<String?> metadataJson,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$ActivitiesTableUpdateCompanionBuilder = ActivitiesCompanion Function({
  Value<String> id,
  Value<String> activityType,
  Value<String> title,
  Value<String?> notes,
  Value<int> startedAt,
  Value<int> movingTimeMs,
  Value<int> elapsedTimeMs,
  Value<double> distanceMeters,
  Value<double?> elevationGainMeters,
  Value<int?> avgHeartRate,
  Value<String> source,
  Value<String?> routeId,
  Value<String?> metadataJson,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

final class $$ActivitiesTableReferences
    extends BaseReferences<_$AppDatabase, $ActivitiesTable, Activity> {
  $$ActivitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ActivitySamplesTable, List<ActivitySample>>
  _activitySamplesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activitySamples,
    aliasName: 'activities__id__activity_samples__activity_id',
  );

  $$ActivitySamplesTableProcessedTableManager get activitySamplesRefs {
    final manager = $$ActivitySamplesTableTableManager(
      $_db,
      $_db.activitySamples,
    ).filter((f) => f.activityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _activitySamplesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get movingTimeMs => $composableBuilder(
    column: $table.movingTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedTimeMs => $composableBuilder(
    column: $table.elapsedTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routeId => $composableBuilder(
    column: $table.routeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> activitySamplesRefs(
    Expression<bool> Function($$ActivitySamplesTableFilterComposer f) f,
  ) {
    final $$ActivitySamplesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activitySamples,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitySamplesTableFilterComposer(
            $db: $db,
            $table: $db.activitySamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get movingTimeMs => $composableBuilder(
    column: $table.movingTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedTimeMs => $composableBuilder(
    column: $table.elapsedTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routeId => $composableBuilder(
    column: $table.routeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get movingTimeMs => $composableBuilder(
    column: $table.movingTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedTimeMs => $composableBuilder(
    column: $table.elapsedTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get routeId =>
      $composableBuilder(column: $table.routeId, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  Expression<T> activitySamplesRefs<T extends Object>(
    Expression<T> Function($$ActivitySamplesTableAnnotationComposer a) f,
  ) {
    final $$ActivitySamplesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activitySamples,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitySamplesTableAnnotationComposer(
            $db: $db,
            $table: $db.activitySamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitiesTable,
          Activity,
          $$ActivitiesTableFilterComposer,
          $$ActivitiesTableOrderingComposer,
          $$ActivitiesTableAnnotationComposer,
          $$ActivitiesTableCreateCompanionBuilder,
          $$ActivitiesTableUpdateCompanionBuilder,
          (Activity, $$ActivitiesTableReferences),
          Activity,
          PrefetchHooks Function({bool activitySamplesRefs})
        > {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> activityType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int> movingTimeMs = const Value.absent(),
                Value<int> elapsedTimeMs = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<double?> elevationGainMeters = const Value.absent(),
                Value<int?> avgHeartRate = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> routeId = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion(
                id: id,
                activityType: activityType,
                title: title,
                notes: notes,
                startedAt: startedAt,
                movingTimeMs: movingTimeMs,
                elapsedTimeMs: elapsedTimeMs,
                distanceMeters: distanceMeters,
                elevationGainMeters: elevationGainMeters,
                avgHeartRate: avgHeartRate,
                source: source,
                routeId: routeId,
                metadataJson: metadataJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String activityType,
                required String title,
                Value<String?> notes = const Value.absent(),
                required int startedAt,
                required int movingTimeMs,
                required int elapsedTimeMs,
                required double distanceMeters,
                Value<double?> elevationGainMeters = const Value.absent(),
                Value<int?> avgHeartRate = const Value.absent(),
                required String source,
                Value<String?> routeId = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion.insert(
                id: id,
                activityType: activityType,
                title: title,
                notes: notes,
                startedAt: startedAt,
                movingTimeMs: movingTimeMs,
                elapsedTimeMs: elapsedTimeMs,
                distanceMeters: distanceMeters,
                elevationGainMeters: elevationGainMeters,
                avgHeartRate: avgHeartRate,
                source: source,
                routeId: routeId,
                metadataJson: metadataJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ActivitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({activitySamplesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (activitySamplesRefs) db.activitySamples,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (activitySamplesRefs)
                    await $_getPrefetchedData<
                      Activity,
                      $ActivitiesTable,
                      ActivitySample
                    >(
                      currentTable: table,
                      referencedTable: $$ActivitiesTableReferences
                          ._activitySamplesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ActivitiesTableReferences(
                            db,
                            table,
                            p0,
                          ).activitySamplesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.activityId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitiesTable,
      Activity,
      $$ActivitiesTableFilterComposer,
      $$ActivitiesTableOrderingComposer,
      $$ActivitiesTableAnnotationComposer,
      $$ActivitiesTableCreateCompanionBuilder,
      $$ActivitiesTableUpdateCompanionBuilder,
      (Activity, $$ActivitiesTableReferences),
      Activity,
      PrefetchHooks Function({bool activitySamplesRefs})
    >;
typedef $$ActivitySamplesTableCreateCompanionBuilder =
    ActivitySamplesCompanion Function({
      required String id,
      required String activityId,
      required int timestampMs,
      required double latitude,
      required double longitude,
      Value<double?> elevationMeters,
      Value<double?> horizontalAccuracyMeters,
      Value<int?> heartRate,
      Value<bool> isPaused,
      Value<int> rowid,
    });
typedef $$ActivitySamplesTableUpdateCompanionBuilder =
    ActivitySamplesCompanion Function({
      Value<String> id,
      Value<String> activityId,
      Value<int> timestampMs,
      Value<double> latitude,
      Value<double> longitude,
      Value<double?> elevationMeters,
      Value<double?> horizontalAccuracyMeters,
      Value<int?> heartRate,
      Value<bool> isPaused,
      Value<int> rowid,
    });

final class $$ActivitySamplesTableReferences
    extends
        BaseReferences<_$AppDatabase, $ActivitySamplesTable, ActivitySample> {
  $$ActivitySamplesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ActivitiesTable _activityIdTable(_$AppDatabase db) => db.activities
      .createAlias('activity_samples__activity_id__activities__id');

  $$ActivitiesTableProcessedTableManager get activityId {
    final $_column = $_itemColumn<String>('activity_id')!;

    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActivitySamplesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitySamplesTable> {
  $$ActivitySamplesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationMeters => $composableBuilder(
    column: $table.elevationMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get horizontalAccuracyMeters => $composableBuilder(
    column: $table.horizontalAccuracyMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heartRate => $composableBuilder(
    column: $table.heartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnFilters(column),
  );

  $$ActivitiesTableFilterComposer get activityId {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitySamplesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitySamplesTable> {
  $$ActivitySamplesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationMeters => $composableBuilder(
    column: $table.elevationMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get horizontalAccuracyMeters => $composableBuilder(
    column: $table.horizontalAccuracyMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heartRate => $composableBuilder(
    column: $table.heartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnOrderings(column),
  );

  $$ActivitiesTableOrderingComposer get activityId {
    final $$ActivitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableOrderingComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitySamplesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitySamplesTable> {
  $$ActivitySamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get timestampMs => $composableBuilder(
    column: $table.timestampMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get elevationMeters => $composableBuilder(
    column: $table.elevationMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get horizontalAccuracyMeters => $composableBuilder(
    column: $table.horizontalAccuracyMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get heartRate =>
      $composableBuilder(column: $table.heartRate, builder: (column) => column);

  GeneratedColumn<bool> get isPaused =>
      $composableBuilder(column: $table.isPaused, builder: (column) => column);

  $$ActivitiesTableAnnotationComposer get activityId {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitySamplesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitySamplesTable,
          ActivitySample,
          $$ActivitySamplesTableFilterComposer,
          $$ActivitySamplesTableOrderingComposer,
          $$ActivitySamplesTableAnnotationComposer,
          $$ActivitySamplesTableCreateCompanionBuilder,
          $$ActivitySamplesTableUpdateCompanionBuilder,
          (ActivitySample, $$ActivitySamplesTableReferences),
          ActivitySample,
          PrefetchHooks Function({bool activityId})
        > {
  $$ActivitySamplesTableTableManager(
    _$AppDatabase db,
    $ActivitySamplesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitySamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitySamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitySamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> activityId = const Value.absent(),
                Value<int> timestampMs = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double?> elevationMeters = const Value.absent(),
                Value<double?> horizontalAccuracyMeters = const Value.absent(),
                Value<int?> heartRate = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitySamplesCompanion(
                id: id,
                activityId: activityId,
                timestampMs: timestampMs,
                latitude: latitude,
                longitude: longitude,
                elevationMeters: elevationMeters,
                horizontalAccuracyMeters: horizontalAccuracyMeters,
                heartRate: heartRate,
                isPaused: isPaused,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String activityId,
                required int timestampMs,
                required double latitude,
                required double longitude,
                Value<double?> elevationMeters = const Value.absent(),
                Value<double?> horizontalAccuracyMeters = const Value.absent(),
                Value<int?> heartRate = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitySamplesCompanion.insert(
                id: id,
                activityId: activityId,
                timestampMs: timestampMs,
                latitude: latitude,
                longitude: longitude,
                elevationMeters: elevationMeters,
                horizontalAccuracyMeters: horizontalAccuracyMeters,
                heartRate: heartRate,
                isPaused: isPaused,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ActivitySamplesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({activityId = false}) {
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
                    if (activityId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.activityId,
                        referencedTable: $$ActivitySamplesTableReferences
                            ._activityIdTable(db),
                        referencedColumn: $$ActivitySamplesTableReferences
                            ._activityIdTable(db)
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
        ),
      );
}

typedef $$ActivitySamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitySamplesTable,
      ActivitySample,
      $$ActivitySamplesTableFilterComposer,
      $$ActivitySamplesTableOrderingComposer,
      $$ActivitySamplesTableAnnotationComposer,
      $$ActivitySamplesTableCreateCompanionBuilder,
      $$ActivitySamplesTableUpdateCompanionBuilder,
      (ActivitySample, $$ActivitySamplesTableReferences),
      ActivitySample,
      PrefetchHooks Function({bool activityId})
    >;
typedef $$DailyCheckinsTableCreateCompanionBuilder =
    DailyCheckinsCompanion Function({
      required String id,
      required String day,
      Value<int?> energy,
      Value<int?> sleep,
      Value<int?> soreness,
      Value<int?> stress,
      Value<int?> pain,
      Value<String> symptoms,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$DailyCheckinsTableUpdateCompanionBuilder =
    DailyCheckinsCompanion Function({
      Value<String> id,
      Value<String> day,
      Value<int?> energy,
      Value<int?> sleep,
      Value<int?> soreness,
      Value<int?> stress,
      Value<int?> pain,
      Value<String> symptoms,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$DailyCheckinsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyCheckinsTable> {
  $$DailyCheckinsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sleep => $composableBuilder(
    column: $table.sleep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get soreness => $composableBuilder(
    column: $table.soreness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stress => $composableBuilder(
    column: $table.stress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pain => $composableBuilder(
    column: $table.pain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyCheckinsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyCheckinsTable> {
  $$DailyCheckinsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleep => $composableBuilder(
    column: $table.sleep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get soreness => $composableBuilder(
    column: $table.soreness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stress => $composableBuilder(
    column: $table.stress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pain => $composableBuilder(
    column: $table.pain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyCheckinsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyCheckinsTable> {
  $$DailyCheckinsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => column);

  GeneratedColumn<int> get sleep =>
      $composableBuilder(column: $table.sleep, builder: (column) => column);

  GeneratedColumn<int> get soreness =>
      $composableBuilder(column: $table.soreness, builder: (column) => column);

  GeneratedColumn<int> get stress =>
      $composableBuilder(column: $table.stress, builder: (column) => column);

  GeneratedColumn<int> get pain =>
      $composableBuilder(column: $table.pain, builder: (column) => column);

  GeneratedColumn<String> get symptoms =>
      $composableBuilder(column: $table.symptoms, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$DailyCheckinsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyCheckinsTable,
          DailyCheckin,
          $$DailyCheckinsTableFilterComposer,
          $$DailyCheckinsTableOrderingComposer,
          $$DailyCheckinsTableAnnotationComposer,
          $$DailyCheckinsTableCreateCompanionBuilder,
          $$DailyCheckinsTableUpdateCompanionBuilder,
          (
            DailyCheckin,
            BaseReferences<_$AppDatabase, $DailyCheckinsTable, DailyCheckin>,
          ),
          DailyCheckin,
          PrefetchHooks Function()
        > {
  $$DailyCheckinsTableTableManager(_$AppDatabase db, $DailyCheckinsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyCheckinsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyCheckinsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyCheckinsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<int?> energy = const Value.absent(),
                Value<int?> sleep = const Value.absent(),
                Value<int?> soreness = const Value.absent(),
                Value<int?> stress = const Value.absent(),
                Value<int?> pain = const Value.absent(),
                Value<String> symptoms = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyCheckinsCompanion(
                id: id,
                day: day,
                energy: energy,
                sleep: sleep,
                soreness: soreness,
                stress: stress,
                pain: pain,
                symptoms: symptoms,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String day,
                Value<int?> energy = const Value.absent(),
                Value<int?> sleep = const Value.absent(),
                Value<int?> soreness = const Value.absent(),
                Value<int?> stress = const Value.absent(),
                Value<int?> pain = const Value.absent(),
                Value<String> symptoms = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyCheckinsCompanion.insert(
                id: id,
                day: day,
                energy: energy,
                sleep: sleep,
                soreness: soreness,
                stress: stress,
                pain: pain,
                symptoms: symptoms,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyCheckinsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyCheckinsTable,
      DailyCheckin,
      $$DailyCheckinsTableFilterComposer,
      $$DailyCheckinsTableOrderingComposer,
      $$DailyCheckinsTableAnnotationComposer,
      $$DailyCheckinsTableCreateCompanionBuilder,
      $$DailyCheckinsTableUpdateCompanionBuilder,
      (
        DailyCheckin,
        BaseReferences<_$AppDatabase, $DailyCheckinsTable, DailyCheckin>,
      ),
      DailyCheckin,
      PrefetchHooks Function()
    >;
typedef $$FlareEventsTableCreateCompanionBuilder =
    FlareEventsCompanion Function({
      required String id,
      required String day,
      Value<String?> endDay,
      required String severity,
      Value<String> symptoms,
      required String impact,
      Value<String?> category,
      Value<String?> notes,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$FlareEventsTableUpdateCompanionBuilder =
    FlareEventsCompanion Function({
      Value<String> id,
      Value<String> day,
      Value<String?> endDay,
      Value<String> severity,
      Value<String> symptoms,
      Value<String> impact,
      Value<String?> category,
      Value<String?> notes,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$FlareEventsTableFilterComposer
    extends Composer<_$AppDatabase, $FlareEventsTable> {
  $$FlareEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endDay => $composableBuilder(
    column: $table.endDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get impact => $composableBuilder(
    column: $table.impact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FlareEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $FlareEventsTable> {
  $$FlareEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDay => $composableBuilder(
    column: $table.endDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get impact => $composableBuilder(
    column: $table.impact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FlareEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlareEventsTable> {
  $$FlareEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get endDay =>
      $composableBuilder(column: $table.endDay, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get symptoms =>
      $composableBuilder(column: $table.symptoms, builder: (column) => column);

  GeneratedColumn<String> get impact =>
      $composableBuilder(column: $table.impact, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$FlareEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FlareEventsTable,
          FlareEvent,
          $$FlareEventsTableFilterComposer,
          $$FlareEventsTableOrderingComposer,
          $$FlareEventsTableAnnotationComposer,
          $$FlareEventsTableCreateCompanionBuilder,
          $$FlareEventsTableUpdateCompanionBuilder,
          (
            FlareEvent,
            BaseReferences<_$AppDatabase, $FlareEventsTable, FlareEvent>,
          ),
          FlareEvent,
          PrefetchHooks Function()
        > {
  $$FlareEventsTableTableManager(_$AppDatabase db, $FlareEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlareEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlareEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlareEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<String?> endDay = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String> symptoms = const Value.absent(),
                Value<String> impact = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlareEventsCompanion(
                id: id,
                day: day,
                endDay: endDay,
                severity: severity,
                symptoms: symptoms,
                impact: impact,
                category: category,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String day,
                Value<String?> endDay = const Value.absent(),
                required String severity,
                Value<String> symptoms = const Value.absent(),
                required String impact,
                Value<String?> category = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlareEventsCompanion.insert(
                id: id,
                day: day,
                endDay: endDay,
                severity: severity,
                symptoms: symptoms,
                impact: impact,
                category: category,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FlareEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FlareEventsTable,
      FlareEvent,
      $$FlareEventsTableFilterComposer,
      $$FlareEventsTableOrderingComposer,
      $$FlareEventsTableAnnotationComposer,
      $$FlareEventsTableCreateCompanionBuilder,
      $$FlareEventsTableUpdateCompanionBuilder,
      (
        FlareEvent,
        BaseReferences<_$AppDatabase, $FlareEventsTable, FlareEvent>,
      ),
      FlareEvent,
      PrefetchHooks Function()
    >;
typedef $$RecoveryDaysTableCreateCompanionBuilder =
    RecoveryDaysCompanion Function({
      required String id,
      required String day,
      Value<String?> note,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$RecoveryDaysTableUpdateCompanionBuilder =
    RecoveryDaysCompanion Function({
      Value<String> id,
      Value<String> day,
      Value<String?> note,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$RecoveryDaysTableFilterComposer
    extends Composer<_$AppDatabase, $RecoveryDaysTable> {
  $$RecoveryDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecoveryDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $RecoveryDaysTable> {
  $$RecoveryDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecoveryDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecoveryDaysTable> {
  $$RecoveryDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$RecoveryDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecoveryDaysTable,
          RecoveryDay,
          $$RecoveryDaysTableFilterComposer,
          $$RecoveryDaysTableOrderingComposer,
          $$RecoveryDaysTableAnnotationComposer,
          $$RecoveryDaysTableCreateCompanionBuilder,
          $$RecoveryDaysTableUpdateCompanionBuilder,
          (
            RecoveryDay,
            BaseReferences<_$AppDatabase, $RecoveryDaysTable, RecoveryDay>,
          ),
          RecoveryDay,
          PrefetchHooks Function()
        > {
  $$RecoveryDaysTableTableManager(_$AppDatabase db, $RecoveryDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecoveryDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecoveryDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecoveryDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecoveryDaysCompanion(
                id: id,
                day: day,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String day,
                Value<String?> note = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecoveryDaysCompanion.insert(
                id: id,
                day: day,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecoveryDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecoveryDaysTable,
      RecoveryDay,
      $$RecoveryDaysTableFilterComposer,
      $$RecoveryDaysTableOrderingComposer,
      $$RecoveryDaysTableAnnotationComposer,
      $$RecoveryDaysTableCreateCompanionBuilder,
      $$RecoveryDaysTableUpdateCompanionBuilder,
      (
        RecoveryDay,
        BaseReferences<_$AppDatabase, $RecoveryDaysTable, RecoveryDay>,
      ),
      RecoveryDay,
      PrefetchHooks Function()
    >;
typedef $$RoutesTableCreateCompanionBuilder = RoutesCompanion Function({
  required String id,
  required String name,
  required double distanceMeters,
  Value<int?> estimatedDurationSeconds,
  Value<double?> ascentMeters,
  Value<double?> descentMeters,
  required String geometry,
  required String activityType,
  Value<String> source,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$RoutesTableUpdateCompanionBuilder = RoutesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<double> distanceMeters,
  Value<int?> estimatedDurationSeconds,
  Value<double?> ascentMeters,
  Value<double?> descentMeters,
  Value<String> geometry,
  Value<String> activityType,
  Value<String> source,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$RoutesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedDurationSeconds => $composableBuilder(
    column: $table.estimatedDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ascentMeters => $composableBuilder(
    column: $table.ascentMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get descentMeters => $composableBuilder(
    column: $table.descentMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get geometry => $composableBuilder(
    column: $table.geometry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoutesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedDurationSeconds => $composableBuilder(
    column: $table.estimatedDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ascentMeters => $composableBuilder(
    column: $table.ascentMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get descentMeters => $composableBuilder(
    column: $table.descentMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get geometry => $composableBuilder(
    column: $table.geometry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedDurationSeconds => $composableBuilder(
    column: $table.estimatedDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ascentMeters => $composableBuilder(
    column: $table.ascentMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get descentMeters => $composableBuilder(
    column: $table.descentMeters,
    builder: (column) => column,
  );

  GeneratedColumn<String> get geometry =>
      $composableBuilder(column: $table.geometry, builder: (column) => column);

  GeneratedColumn<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$RoutesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutesTable,
          Route,
          $$RoutesTableFilterComposer,
          $$RoutesTableOrderingComposer,
          $$RoutesTableAnnotationComposer,
          $$RoutesTableCreateCompanionBuilder,
          $$RoutesTableUpdateCompanionBuilder,
          (Route, BaseReferences<_$AppDatabase, $RoutesTable, Route>),
          Route,
          PrefetchHooks Function()
        > {
  $$RoutesTableTableManager(_$AppDatabase db, $RoutesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<int?> estimatedDurationSeconds = const Value.absent(),
                Value<double?> ascentMeters = const Value.absent(),
                Value<double?> descentMeters = const Value.absent(),
                Value<String> geometry = const Value.absent(),
                Value<String> activityType = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutesCompanion(
                id: id,
                name: name,
                distanceMeters: distanceMeters,
                estimatedDurationSeconds: estimatedDurationSeconds,
                ascentMeters: ascentMeters,
                descentMeters: descentMeters,
                geometry: geometry,
                activityType: activityType,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required double distanceMeters,
                Value<int?> estimatedDurationSeconds = const Value.absent(),
                Value<double?> ascentMeters = const Value.absent(),
                Value<double?> descentMeters = const Value.absent(),
                required String geometry,
                required String activityType,
                Value<String> source = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutesCompanion.insert(
                id: id,
                name: name,
                distanceMeters: distanceMeters,
                estimatedDurationSeconds: estimatedDurationSeconds,
                ascentMeters: ascentMeters,
                descentMeters: descentMeters,
                geometry: geometry,
                activityType: activityType,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RoutesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutesTable,
      Route,
      $$RoutesTableFilterComposer,
      $$RoutesTableOrderingComposer,
      $$RoutesTableAnnotationComposer,
      $$RoutesTableCreateCompanionBuilder,
      $$RoutesTableUpdateCompanionBuilder,
      (Route, BaseReferences<_$AppDatabase, $RoutesTable, Route>),
      Route,
      PrefetchHooks Function()
    >;
typedef $$FoodsTableCreateCompanionBuilder = FoodsCompanion Function({
  required String id,
  Value<String?> providerFoodId,
  required String name,
  Value<String?> brand,
  required String servingDescription,
  Value<double?> servingGrams,
  Value<double?> servingVolumeMl,
  required double caloriesKcal,
  required double proteinGrams,
  required double carbsGrams,
  required double fatGrams,
  Value<double?> ironMg,
  Value<double?> saturatedFatGrams,
  Value<double?> transFatGrams,
  Value<double?> monounsaturatedFatGrams,
  Value<double?> polyunsaturatedFatGrams,
  Value<double?> fiberGrams,
  Value<double?> sugarsGrams,
  Value<double?> addedSugarsGrams,
  Value<double?> sodiumMg,
  Value<double?> potassiumMg,
  Value<double?> cholesterolMg,
  Value<double?> calciumMg,
  Value<double?> vitaminDMcg,
  Value<double?> vitaminCMg,
  Value<String?> barcode,
  Value<String> source,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$FoodsTableUpdateCompanionBuilder = FoodsCompanion Function({
  Value<String> id,
  Value<String?> providerFoodId,
  Value<String> name,
  Value<String?> brand,
  Value<String> servingDescription,
  Value<double?> servingGrams,
  Value<double?> servingVolumeMl,
  Value<double> caloriesKcal,
  Value<double> proteinGrams,
  Value<double> carbsGrams,
  Value<double> fatGrams,
  Value<double?> ironMg,
  Value<double?> saturatedFatGrams,
  Value<double?> transFatGrams,
  Value<double?> monounsaturatedFatGrams,
  Value<double?> polyunsaturatedFatGrams,
  Value<double?> fiberGrams,
  Value<double?> sugarsGrams,
  Value<double?> addedSugarsGrams,
  Value<double?> sodiumMg,
  Value<double?> potassiumMg,
  Value<double?> cholesterolMg,
  Value<double?> calciumMg,
  Value<double?> vitaminDMcg,
  Value<double?> vitaminCMg,
  Value<String?> barcode,
  Value<String> source,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$FoodsTableFilterComposer extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerFoodId => $composableBuilder(
    column: $table.providerFoodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingDescription => $composableBuilder(
    column: $table.servingDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servingGrams => $composableBuilder(
    column: $table.servingGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servingVolumeMl => $composableBuilder(
    column: $table.servingVolumeMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caloriesKcal => $composableBuilder(
    column: $table.caloriesKcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsGrams => $composableBuilder(
    column: $table.carbsGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatGrams => $composableBuilder(
    column: $table.fatGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ironMg => $composableBuilder(
    column: $table.ironMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get saturatedFatGrams => $composableBuilder(
    column: $table.saturatedFatGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get transFatGrams => $composableBuilder(
    column: $table.transFatGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monounsaturatedFatGrams => $composableBuilder(
    column: $table.monounsaturatedFatGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get polyunsaturatedFatGrams => $composableBuilder(
    column: $table.polyunsaturatedFatGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiberGrams => $composableBuilder(
    column: $table.fiberGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sugarsGrams => $composableBuilder(
    column: $table.sugarsGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get addedSugarsGrams => $composableBuilder(
    column: $table.addedSugarsGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sodiumMg => $composableBuilder(
    column: $table.sodiumMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get potassiumMg => $composableBuilder(
    column: $table.potassiumMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cholesterolMg => $composableBuilder(
    column: $table.cholesterolMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calciumMg => $composableBuilder(
    column: $table.calciumMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vitaminDMcg => $composableBuilder(
    column: $table.vitaminDMcg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vitaminCMg => $composableBuilder(
    column: $table.vitaminCMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerFoodId => $composableBuilder(
    column: $table.providerFoodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingDescription => $composableBuilder(
    column: $table.servingDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servingGrams => $composableBuilder(
    column: $table.servingGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servingVolumeMl => $composableBuilder(
    column: $table.servingVolumeMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caloriesKcal => $composableBuilder(
    column: $table.caloriesKcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsGrams => $composableBuilder(
    column: $table.carbsGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatGrams => $composableBuilder(
    column: $table.fatGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ironMg => $composableBuilder(
    column: $table.ironMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get saturatedFatGrams => $composableBuilder(
    column: $table.saturatedFatGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get transFatGrams => $composableBuilder(
    column: $table.transFatGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monounsaturatedFatGrams => $composableBuilder(
    column: $table.monounsaturatedFatGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get polyunsaturatedFatGrams => $composableBuilder(
    column: $table.polyunsaturatedFatGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiberGrams => $composableBuilder(
    column: $table.fiberGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sugarsGrams => $composableBuilder(
    column: $table.sugarsGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get addedSugarsGrams => $composableBuilder(
    column: $table.addedSugarsGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sodiumMg => $composableBuilder(
    column: $table.sodiumMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get potassiumMg => $composableBuilder(
    column: $table.potassiumMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cholesterolMg => $composableBuilder(
    column: $table.cholesterolMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calciumMg => $composableBuilder(
    column: $table.calciumMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vitaminDMcg => $composableBuilder(
    column: $table.vitaminDMcg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vitaminCMg => $composableBuilder(
    column: $table.vitaminCMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerFoodId => $composableBuilder(
    column: $table.providerFoodId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get servingDescription => $composableBuilder(
    column: $table.servingDescription,
    builder: (column) => column,
  );

  GeneratedColumn<double> get servingGrams => $composableBuilder(
    column: $table.servingGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get servingVolumeMl => $composableBuilder(
    column: $table.servingVolumeMl,
    builder: (column) => column,
  );

  GeneratedColumn<double> get caloriesKcal => $composableBuilder(
    column: $table.caloriesKcal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbsGrams => $composableBuilder(
    column: $table.carbsGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatGrams =>
      $composableBuilder(column: $table.fatGrams, builder: (column) => column);

  GeneratedColumn<double> get ironMg =>
      $composableBuilder(column: $table.ironMg, builder: (column) => column);

  GeneratedColumn<double> get saturatedFatGrams => $composableBuilder(
    column: $table.saturatedFatGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get transFatGrams => $composableBuilder(
    column: $table.transFatGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monounsaturatedFatGrams => $composableBuilder(
    column: $table.monounsaturatedFatGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get polyunsaturatedFatGrams => $composableBuilder(
    column: $table.polyunsaturatedFatGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fiberGrams => $composableBuilder(
    column: $table.fiberGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sugarsGrams => $composableBuilder(
    column: $table.sugarsGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get addedSugarsGrams => $composableBuilder(
    column: $table.addedSugarsGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sodiumMg =>
      $composableBuilder(column: $table.sodiumMg, builder: (column) => column);

  GeneratedColumn<double> get potassiumMg => $composableBuilder(
    column: $table.potassiumMg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cholesterolMg => $composableBuilder(
    column: $table.cholesterolMg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get calciumMg =>
      $composableBuilder(column: $table.calciumMg, builder: (column) => column);

  GeneratedColumn<double> get vitaminDMcg => $composableBuilder(
    column: $table.vitaminDMcg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get vitaminCMg => $composableBuilder(
    column: $table.vitaminCMg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$FoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodsTable,
          Food,
          $$FoodsTableFilterComposer,
          $$FoodsTableOrderingComposer,
          $$FoodsTableAnnotationComposer,
          $$FoodsTableCreateCompanionBuilder,
          $$FoodsTableUpdateCompanionBuilder,
          (Food, BaseReferences<_$AppDatabase, $FoodsTable, Food>),
          Food,
          PrefetchHooks Function()
        > {
  $$FoodsTableTableManager(_$AppDatabase db, $FoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> providerFoodId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String> servingDescription = const Value.absent(),
                Value<double?> servingGrams = const Value.absent(),
                Value<double?> servingVolumeMl = const Value.absent(),
                Value<double> caloriesKcal = const Value.absent(),
                Value<double> proteinGrams = const Value.absent(),
                Value<double> carbsGrams = const Value.absent(),
                Value<double> fatGrams = const Value.absent(),
                Value<double?> ironMg = const Value.absent(),
                Value<double?> saturatedFatGrams = const Value.absent(),
                Value<double?> transFatGrams = const Value.absent(),
                Value<double?> monounsaturatedFatGrams = const Value.absent(),
                Value<double?> polyunsaturatedFatGrams = const Value.absent(),
                Value<double?> fiberGrams = const Value.absent(),
                Value<double?> sugarsGrams = const Value.absent(),
                Value<double?> addedSugarsGrams = const Value.absent(),
                Value<double?> sodiumMg = const Value.absent(),
                Value<double?> potassiumMg = const Value.absent(),
                Value<double?> cholesterolMg = const Value.absent(),
                Value<double?> calciumMg = const Value.absent(),
                Value<double?> vitaminDMcg = const Value.absent(),
                Value<double?> vitaminCMg = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodsCompanion(
                id: id,
                providerFoodId: providerFoodId,
                name: name,
                brand: brand,
                servingDescription: servingDescription,
                servingGrams: servingGrams,
                servingVolumeMl: servingVolumeMl,
                caloriesKcal: caloriesKcal,
                proteinGrams: proteinGrams,
                carbsGrams: carbsGrams,
                fatGrams: fatGrams,
                ironMg: ironMg,
                saturatedFatGrams: saturatedFatGrams,
                transFatGrams: transFatGrams,
                monounsaturatedFatGrams: monounsaturatedFatGrams,
                polyunsaturatedFatGrams: polyunsaturatedFatGrams,
                fiberGrams: fiberGrams,
                sugarsGrams: sugarsGrams,
                addedSugarsGrams: addedSugarsGrams,
                sodiumMg: sodiumMg,
                potassiumMg: potassiumMg,
                cholesterolMg: cholesterolMg,
                calciumMg: calciumMg,
                vitaminDMcg: vitaminDMcg,
                vitaminCMg: vitaminCMg,
                barcode: barcode,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> providerFoodId = const Value.absent(),
                required String name,
                Value<String?> brand = const Value.absent(),
                required String servingDescription,
                Value<double?> servingGrams = const Value.absent(),
                Value<double?> servingVolumeMl = const Value.absent(),
                required double caloriesKcal,
                required double proteinGrams,
                required double carbsGrams,
                required double fatGrams,
                Value<double?> ironMg = const Value.absent(),
                Value<double?> saturatedFatGrams = const Value.absent(),
                Value<double?> transFatGrams = const Value.absent(),
                Value<double?> monounsaturatedFatGrams = const Value.absent(),
                Value<double?> polyunsaturatedFatGrams = const Value.absent(),
                Value<double?> fiberGrams = const Value.absent(),
                Value<double?> sugarsGrams = const Value.absent(),
                Value<double?> addedSugarsGrams = const Value.absent(),
                Value<double?> sodiumMg = const Value.absent(),
                Value<double?> potassiumMg = const Value.absent(),
                Value<double?> cholesterolMg = const Value.absent(),
                Value<double?> calciumMg = const Value.absent(),
                Value<double?> vitaminDMcg = const Value.absent(),
                Value<double?> vitaminCMg = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String> source = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodsCompanion.insert(
                id: id,
                providerFoodId: providerFoodId,
                name: name,
                brand: brand,
                servingDescription: servingDescription,
                servingGrams: servingGrams,
                servingVolumeMl: servingVolumeMl,
                caloriesKcal: caloriesKcal,
                proteinGrams: proteinGrams,
                carbsGrams: carbsGrams,
                fatGrams: fatGrams,
                ironMg: ironMg,
                saturatedFatGrams: saturatedFatGrams,
                transFatGrams: transFatGrams,
                monounsaturatedFatGrams: monounsaturatedFatGrams,
                polyunsaturatedFatGrams: polyunsaturatedFatGrams,
                fiberGrams: fiberGrams,
                sugarsGrams: sugarsGrams,
                addedSugarsGrams: addedSugarsGrams,
                sodiumMg: sodiumMg,
                potassiumMg: potassiumMg,
                cholesterolMg: cholesterolMg,
                calciumMg: calciumMg,
                vitaminDMcg: vitaminDMcg,
                vitaminCMg: vitaminCMg,
                barcode: barcode,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodsTable,
      Food,
      $$FoodsTableFilterComposer,
      $$FoodsTableOrderingComposer,
      $$FoodsTableAnnotationComposer,
      $$FoodsTableCreateCompanionBuilder,
      $$FoodsTableUpdateCompanionBuilder,
      (Food, BaseReferences<_$AppDatabase, $FoodsTable, Food>),
      Food,
      PrefetchHooks Function()
    >;
typedef $$NutritionEntriesTableCreateCompanionBuilder =
    NutritionEntriesCompanion Function({
      required String id,
      required String day,
      required String meal,
      Value<String?> foodId,
      required String foodName,
      Value<String?> foodBrand,
      Value<String?> servingDescription,
      required double quantityServings,
      Value<double> quantityAmount,
      Value<String> quantityUnit,
      Value<double?> servingGrams,
      Value<double?> servingVolumeMl,
      required double caloriesKcal,
      required double proteinGrams,
      required double carbsGrams,
      required double fatGrams,
      Value<double?> ironMg,
      Value<double?> saturatedFatGrams,
      Value<double?> transFatGrams,
      Value<double?> monounsaturatedFatGrams,
      Value<double?> polyunsaturatedFatGrams,
      Value<double?> fiberGrams,
      Value<double?> sugarsGrams,
      Value<double?> addedSugarsGrams,
      Value<double?> sodiumMg,
      Value<double?> potassiumMg,
      Value<double?> cholesterolMg,
      Value<double?> calciumMg,
      Value<double?> vitaminDMcg,
      Value<double?> vitaminCMg,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$NutritionEntriesTableUpdateCompanionBuilder =
    NutritionEntriesCompanion Function({
      Value<String> id,
      Value<String> day,
      Value<String> meal,
      Value<String?> foodId,
      Value<String> foodName,
      Value<String?> foodBrand,
      Value<String?> servingDescription,
      Value<double> quantityServings,
      Value<double> quantityAmount,
      Value<String> quantityUnit,
      Value<double?> servingGrams,
      Value<double?> servingVolumeMl,
      Value<double> caloriesKcal,
      Value<double> proteinGrams,
      Value<double> carbsGrams,
      Value<double> fatGrams,
      Value<double?> ironMg,
      Value<double?> saturatedFatGrams,
      Value<double?> transFatGrams,
      Value<double?> monounsaturatedFatGrams,
      Value<double?> polyunsaturatedFatGrams,
      Value<double?> fiberGrams,
      Value<double?> sugarsGrams,
      Value<double?> addedSugarsGrams,
      Value<double?> sodiumMg,
      Value<double?> potassiumMg,
      Value<double?> cholesterolMg,
      Value<double?> calciumMg,
      Value<double?> vitaminDMcg,
      Value<double?> vitaminCMg,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$NutritionEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $NutritionEntriesTable> {
  $$NutritionEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meal => $composableBuilder(
    column: $table.meal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodBrand => $composableBuilder(
    column: $table.foodBrand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingDescription => $composableBuilder(
    column: $table.servingDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityServings => $composableBuilder(
    column: $table.quantityServings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityAmount => $composableBuilder(
    column: $table.quantityAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servingGrams => $composableBuilder(
    column: $table.servingGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servingVolumeMl => $composableBuilder(
    column: $table.servingVolumeMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caloriesKcal => $composableBuilder(
    column: $table.caloriesKcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsGrams => $composableBuilder(
    column: $table.carbsGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatGrams => $composableBuilder(
    column: $table.fatGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ironMg => $composableBuilder(
    column: $table.ironMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get saturatedFatGrams => $composableBuilder(
    column: $table.saturatedFatGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get transFatGrams => $composableBuilder(
    column: $table.transFatGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monounsaturatedFatGrams => $composableBuilder(
    column: $table.monounsaturatedFatGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get polyunsaturatedFatGrams => $composableBuilder(
    column: $table.polyunsaturatedFatGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiberGrams => $composableBuilder(
    column: $table.fiberGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sugarsGrams => $composableBuilder(
    column: $table.sugarsGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get addedSugarsGrams => $composableBuilder(
    column: $table.addedSugarsGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sodiumMg => $composableBuilder(
    column: $table.sodiumMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get potassiumMg => $composableBuilder(
    column: $table.potassiumMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cholesterolMg => $composableBuilder(
    column: $table.cholesterolMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calciumMg => $composableBuilder(
    column: $table.calciumMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vitaminDMcg => $composableBuilder(
    column: $table.vitaminDMcg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vitaminCMg => $composableBuilder(
    column: $table.vitaminCMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NutritionEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $NutritionEntriesTable> {
  $$NutritionEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meal => $composableBuilder(
    column: $table.meal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodBrand => $composableBuilder(
    column: $table.foodBrand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingDescription => $composableBuilder(
    column: $table.servingDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityServings => $composableBuilder(
    column: $table.quantityServings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityAmount => $composableBuilder(
    column: $table.quantityAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servingGrams => $composableBuilder(
    column: $table.servingGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servingVolumeMl => $composableBuilder(
    column: $table.servingVolumeMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caloriesKcal => $composableBuilder(
    column: $table.caloriesKcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsGrams => $composableBuilder(
    column: $table.carbsGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatGrams => $composableBuilder(
    column: $table.fatGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ironMg => $composableBuilder(
    column: $table.ironMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get saturatedFatGrams => $composableBuilder(
    column: $table.saturatedFatGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get transFatGrams => $composableBuilder(
    column: $table.transFatGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monounsaturatedFatGrams => $composableBuilder(
    column: $table.monounsaturatedFatGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get polyunsaturatedFatGrams => $composableBuilder(
    column: $table.polyunsaturatedFatGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiberGrams => $composableBuilder(
    column: $table.fiberGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sugarsGrams => $composableBuilder(
    column: $table.sugarsGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get addedSugarsGrams => $composableBuilder(
    column: $table.addedSugarsGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sodiumMg => $composableBuilder(
    column: $table.sodiumMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get potassiumMg => $composableBuilder(
    column: $table.potassiumMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cholesterolMg => $composableBuilder(
    column: $table.cholesterolMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calciumMg => $composableBuilder(
    column: $table.calciumMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vitaminDMcg => $composableBuilder(
    column: $table.vitaminDMcg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vitaminCMg => $composableBuilder(
    column: $table.vitaminCMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NutritionEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NutritionEntriesTable> {
  $$NutritionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get meal =>
      $composableBuilder(column: $table.meal, builder: (column) => column);

  GeneratedColumn<String> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<String> get foodName =>
      $composableBuilder(column: $table.foodName, builder: (column) => column);

  GeneratedColumn<String> get foodBrand =>
      $composableBuilder(column: $table.foodBrand, builder: (column) => column);

  GeneratedColumn<String> get servingDescription => $composableBuilder(
    column: $table.servingDescription,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantityServings => $composableBuilder(
    column: $table.quantityServings,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantityAmount => $composableBuilder(
    column: $table.quantityAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get servingGrams => $composableBuilder(
    column: $table.servingGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get servingVolumeMl => $composableBuilder(
    column: $table.servingVolumeMl,
    builder: (column) => column,
  );

  GeneratedColumn<double> get caloriesKcal => $composableBuilder(
    column: $table.caloriesKcal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinGrams => $composableBuilder(
    column: $table.proteinGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbsGrams => $composableBuilder(
    column: $table.carbsGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatGrams =>
      $composableBuilder(column: $table.fatGrams, builder: (column) => column);

  GeneratedColumn<double> get ironMg =>
      $composableBuilder(column: $table.ironMg, builder: (column) => column);

  GeneratedColumn<double> get saturatedFatGrams => $composableBuilder(
    column: $table.saturatedFatGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get transFatGrams => $composableBuilder(
    column: $table.transFatGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monounsaturatedFatGrams => $composableBuilder(
    column: $table.monounsaturatedFatGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get polyunsaturatedFatGrams => $composableBuilder(
    column: $table.polyunsaturatedFatGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fiberGrams => $composableBuilder(
    column: $table.fiberGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sugarsGrams => $composableBuilder(
    column: $table.sugarsGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get addedSugarsGrams => $composableBuilder(
    column: $table.addedSugarsGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sodiumMg =>
      $composableBuilder(column: $table.sodiumMg, builder: (column) => column);

  GeneratedColumn<double> get potassiumMg => $composableBuilder(
    column: $table.potassiumMg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cholesterolMg => $composableBuilder(
    column: $table.cholesterolMg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get calciumMg =>
      $composableBuilder(column: $table.calciumMg, builder: (column) => column);

  GeneratedColumn<double> get vitaminDMcg => $composableBuilder(
    column: $table.vitaminDMcg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get vitaminCMg => $composableBuilder(
    column: $table.vitaminCMg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$NutritionEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NutritionEntriesTable,
          NutritionEntry,
          $$NutritionEntriesTableFilterComposer,
          $$NutritionEntriesTableOrderingComposer,
          $$NutritionEntriesTableAnnotationComposer,
          $$NutritionEntriesTableCreateCompanionBuilder,
          $$NutritionEntriesTableUpdateCompanionBuilder,
          (
            NutritionEntry,
            BaseReferences<
              _$AppDatabase,
              $NutritionEntriesTable,
              NutritionEntry
            >,
          ),
          NutritionEntry,
          PrefetchHooks Function()
        > {
  $$NutritionEntriesTableTableManager(
    _$AppDatabase db,
    $NutritionEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NutritionEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NutritionEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NutritionEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<String> meal = const Value.absent(),
                Value<String?> foodId = const Value.absent(),
                Value<String> foodName = const Value.absent(),
                Value<String?> foodBrand = const Value.absent(),
                Value<String?> servingDescription = const Value.absent(),
                Value<double> quantityServings = const Value.absent(),
                Value<double> quantityAmount = const Value.absent(),
                Value<String> quantityUnit = const Value.absent(),
                Value<double?> servingGrams = const Value.absent(),
                Value<double?> servingVolumeMl = const Value.absent(),
                Value<double> caloriesKcal = const Value.absent(),
                Value<double> proteinGrams = const Value.absent(),
                Value<double> carbsGrams = const Value.absent(),
                Value<double> fatGrams = const Value.absent(),
                Value<double?> ironMg = const Value.absent(),
                Value<double?> saturatedFatGrams = const Value.absent(),
                Value<double?> transFatGrams = const Value.absent(),
                Value<double?> monounsaturatedFatGrams = const Value.absent(),
                Value<double?> polyunsaturatedFatGrams = const Value.absent(),
                Value<double?> fiberGrams = const Value.absent(),
                Value<double?> sugarsGrams = const Value.absent(),
                Value<double?> addedSugarsGrams = const Value.absent(),
                Value<double?> sodiumMg = const Value.absent(),
                Value<double?> potassiumMg = const Value.absent(),
                Value<double?> cholesterolMg = const Value.absent(),
                Value<double?> calciumMg = const Value.absent(),
                Value<double?> vitaminDMcg = const Value.absent(),
                Value<double?> vitaminCMg = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NutritionEntriesCompanion(
                id: id,
                day: day,
                meal: meal,
                foodId: foodId,
                foodName: foodName,
                foodBrand: foodBrand,
                servingDescription: servingDescription,
                quantityServings: quantityServings,
                quantityAmount: quantityAmount,
                quantityUnit: quantityUnit,
                servingGrams: servingGrams,
                servingVolumeMl: servingVolumeMl,
                caloriesKcal: caloriesKcal,
                proteinGrams: proteinGrams,
                carbsGrams: carbsGrams,
                fatGrams: fatGrams,
                ironMg: ironMg,
                saturatedFatGrams: saturatedFatGrams,
                transFatGrams: transFatGrams,
                monounsaturatedFatGrams: monounsaturatedFatGrams,
                polyunsaturatedFatGrams: polyunsaturatedFatGrams,
                fiberGrams: fiberGrams,
                sugarsGrams: sugarsGrams,
                addedSugarsGrams: addedSugarsGrams,
                sodiumMg: sodiumMg,
                potassiumMg: potassiumMg,
                cholesterolMg: cholesterolMg,
                calciumMg: calciumMg,
                vitaminDMcg: vitaminDMcg,
                vitaminCMg: vitaminCMg,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String day,
                required String meal,
                Value<String?> foodId = const Value.absent(),
                required String foodName,
                Value<String?> foodBrand = const Value.absent(),
                Value<String?> servingDescription = const Value.absent(),
                required double quantityServings,
                Value<double> quantityAmount = const Value.absent(),
                Value<String> quantityUnit = const Value.absent(),
                Value<double?> servingGrams = const Value.absent(),
                Value<double?> servingVolumeMl = const Value.absent(),
                required double caloriesKcal,
                required double proteinGrams,
                required double carbsGrams,
                required double fatGrams,
                Value<double?> ironMg = const Value.absent(),
                Value<double?> saturatedFatGrams = const Value.absent(),
                Value<double?> transFatGrams = const Value.absent(),
                Value<double?> monounsaturatedFatGrams = const Value.absent(),
                Value<double?> polyunsaturatedFatGrams = const Value.absent(),
                Value<double?> fiberGrams = const Value.absent(),
                Value<double?> sugarsGrams = const Value.absent(),
                Value<double?> addedSugarsGrams = const Value.absent(),
                Value<double?> sodiumMg = const Value.absent(),
                Value<double?> potassiumMg = const Value.absent(),
                Value<double?> cholesterolMg = const Value.absent(),
                Value<double?> calciumMg = const Value.absent(),
                Value<double?> vitaminDMcg = const Value.absent(),
                Value<double?> vitaminCMg = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NutritionEntriesCompanion.insert(
                id: id,
                day: day,
                meal: meal,
                foodId: foodId,
                foodName: foodName,
                foodBrand: foodBrand,
                servingDescription: servingDescription,
                quantityServings: quantityServings,
                quantityAmount: quantityAmount,
                quantityUnit: quantityUnit,
                servingGrams: servingGrams,
                servingVolumeMl: servingVolumeMl,
                caloriesKcal: caloriesKcal,
                proteinGrams: proteinGrams,
                carbsGrams: carbsGrams,
                fatGrams: fatGrams,
                ironMg: ironMg,
                saturatedFatGrams: saturatedFatGrams,
                transFatGrams: transFatGrams,
                monounsaturatedFatGrams: monounsaturatedFatGrams,
                polyunsaturatedFatGrams: polyunsaturatedFatGrams,
                fiberGrams: fiberGrams,
                sugarsGrams: sugarsGrams,
                addedSugarsGrams: addedSugarsGrams,
                sodiumMg: sodiumMg,
                potassiumMg: potassiumMg,
                cholesterolMg: cholesterolMg,
                calciumMg: calciumMg,
                vitaminDMcg: vitaminDMcg,
                vitaminCMg: vitaminCMg,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NutritionEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NutritionEntriesTable,
      NutritionEntry,
      $$NutritionEntriesTableFilterComposer,
      $$NutritionEntriesTableOrderingComposer,
      $$NutritionEntriesTableAnnotationComposer,
      $$NutritionEntriesTableCreateCompanionBuilder,
      $$NutritionEntriesTableUpdateCompanionBuilder,
      (
        NutritionEntry,
        BaseReferences<_$AppDatabase, $NutritionEntriesTable, NutritionEntry>,
      ),
      NutritionEntry,
      PrefetchHooks Function()
    >;
typedef $$NutritionGoalsTableCreateCompanionBuilder =
    NutritionGoalsCompanion Function({
      required String id,
      Value<int?> calorieTargetKcal,
      Value<double?> proteinTargetGrams,
      Value<double?> carbTargetGrams,
      Value<double?> fatTargetGrams,
      Value<String> macroTargetMode,
      Value<double?> proteinTargetPercent,
      Value<double?> carbTargetPercent,
      Value<double?> fatTargetPercent,
      Value<String> macroLocks,
      Value<bool> hideCalorieNumbers,
      Value<String?> activityLevel,
      Value<String> weightGoal,
      Value<int> dailyDeficitKcal,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$NutritionGoalsTableUpdateCompanionBuilder =
    NutritionGoalsCompanion Function({
      Value<String> id,
      Value<int?> calorieTargetKcal,
      Value<double?> proteinTargetGrams,
      Value<double?> carbTargetGrams,
      Value<double?> fatTargetGrams,
      Value<String> macroTargetMode,
      Value<double?> proteinTargetPercent,
      Value<double?> carbTargetPercent,
      Value<double?> fatTargetPercent,
      Value<String> macroLocks,
      Value<bool> hideCalorieNumbers,
      Value<String?> activityLevel,
      Value<String> weightGoal,
      Value<int> dailyDeficitKcal,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$NutritionGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $NutritionGoalsTable> {
  $$NutritionGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calorieTargetKcal => $composableBuilder(
    column: $table.calorieTargetKcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinTargetGrams => $composableBuilder(
    column: $table.proteinTargetGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbTargetGrams => $composableBuilder(
    column: $table.carbTargetGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatTargetGrams => $composableBuilder(
    column: $table.fatTargetGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get macroTargetMode => $composableBuilder(
    column: $table.macroTargetMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinTargetPercent => $composableBuilder(
    column: $table.proteinTargetPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbTargetPercent => $composableBuilder(
    column: $table.carbTargetPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatTargetPercent => $composableBuilder(
    column: $table.fatTargetPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get macroLocks => $composableBuilder(
    column: $table.macroLocks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hideCalorieNumbers => $composableBuilder(
    column: $table.hideCalorieNumbers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weightGoal => $composableBuilder(
    column: $table.weightGoal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyDeficitKcal => $composableBuilder(
    column: $table.dailyDeficitKcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NutritionGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $NutritionGoalsTable> {
  $$NutritionGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calorieTargetKcal => $composableBuilder(
    column: $table.calorieTargetKcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinTargetGrams => $composableBuilder(
    column: $table.proteinTargetGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbTargetGrams => $composableBuilder(
    column: $table.carbTargetGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatTargetGrams => $composableBuilder(
    column: $table.fatTargetGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get macroTargetMode => $composableBuilder(
    column: $table.macroTargetMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinTargetPercent => $composableBuilder(
    column: $table.proteinTargetPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbTargetPercent => $composableBuilder(
    column: $table.carbTargetPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatTargetPercent => $composableBuilder(
    column: $table.fatTargetPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get macroLocks => $composableBuilder(
    column: $table.macroLocks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hideCalorieNumbers => $composableBuilder(
    column: $table.hideCalorieNumbers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightGoal => $composableBuilder(
    column: $table.weightGoal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyDeficitKcal => $composableBuilder(
    column: $table.dailyDeficitKcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NutritionGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NutritionGoalsTable> {
  $$NutritionGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get calorieTargetKcal => $composableBuilder(
    column: $table.calorieTargetKcal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinTargetGrams => $composableBuilder(
    column: $table.proteinTargetGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbTargetGrams => $composableBuilder(
    column: $table.carbTargetGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatTargetGrams => $composableBuilder(
    column: $table.fatTargetGrams,
    builder: (column) => column,
  );

  GeneratedColumn<String> get macroTargetMode => $composableBuilder(
    column: $table.macroTargetMode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinTargetPercent => $composableBuilder(
    column: $table.proteinTargetPercent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbTargetPercent => $composableBuilder(
    column: $table.carbTargetPercent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatTargetPercent => $composableBuilder(
    column: $table.fatTargetPercent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get macroLocks => $composableBuilder(
    column: $table.macroLocks,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hideCalorieNumbers => $composableBuilder(
    column: $table.hideCalorieNumbers,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weightGoal => $composableBuilder(
    column: $table.weightGoal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyDeficitKcal => $composableBuilder(
    column: $table.dailyDeficitKcal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$NutritionGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NutritionGoalsTable,
          NutritionGoal,
          $$NutritionGoalsTableFilterComposer,
          $$NutritionGoalsTableOrderingComposer,
          $$NutritionGoalsTableAnnotationComposer,
          $$NutritionGoalsTableCreateCompanionBuilder,
          $$NutritionGoalsTableUpdateCompanionBuilder,
          (
            NutritionGoal,
            BaseReferences<_$AppDatabase, $NutritionGoalsTable, NutritionGoal>,
          ),
          NutritionGoal,
          PrefetchHooks Function()
        > {
  $$NutritionGoalsTableTableManager(
    _$AppDatabase db,
    $NutritionGoalsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NutritionGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NutritionGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NutritionGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int?> calorieTargetKcal = const Value.absent(),
                Value<double?> proteinTargetGrams = const Value.absent(),
                Value<double?> carbTargetGrams = const Value.absent(),
                Value<double?> fatTargetGrams = const Value.absent(),
                Value<String> macroTargetMode = const Value.absent(),
                Value<double?> proteinTargetPercent = const Value.absent(),
                Value<double?> carbTargetPercent = const Value.absent(),
                Value<double?> fatTargetPercent = const Value.absent(),
                Value<String> macroLocks = const Value.absent(),
                Value<bool> hideCalorieNumbers = const Value.absent(),
                Value<String?> activityLevel = const Value.absent(),
                Value<String> weightGoal = const Value.absent(),
                Value<int> dailyDeficitKcal = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NutritionGoalsCompanion(
                id: id,
                calorieTargetKcal: calorieTargetKcal,
                proteinTargetGrams: proteinTargetGrams,
                carbTargetGrams: carbTargetGrams,
                fatTargetGrams: fatTargetGrams,
                macroTargetMode: macroTargetMode,
                proteinTargetPercent: proteinTargetPercent,
                carbTargetPercent: carbTargetPercent,
                fatTargetPercent: fatTargetPercent,
                macroLocks: macroLocks,
                hideCalorieNumbers: hideCalorieNumbers,
                activityLevel: activityLevel,
                weightGoal: weightGoal,
                dailyDeficitKcal: dailyDeficitKcal,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int?> calorieTargetKcal = const Value.absent(),
                Value<double?> proteinTargetGrams = const Value.absent(),
                Value<double?> carbTargetGrams = const Value.absent(),
                Value<double?> fatTargetGrams = const Value.absent(),
                Value<String> macroTargetMode = const Value.absent(),
                Value<double?> proteinTargetPercent = const Value.absent(),
                Value<double?> carbTargetPercent = const Value.absent(),
                Value<double?> fatTargetPercent = const Value.absent(),
                Value<String> macroLocks = const Value.absent(),
                Value<bool> hideCalorieNumbers = const Value.absent(),
                Value<String?> activityLevel = const Value.absent(),
                Value<String> weightGoal = const Value.absent(),
                Value<int> dailyDeficitKcal = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NutritionGoalsCompanion.insert(
                id: id,
                calorieTargetKcal: calorieTargetKcal,
                proteinTargetGrams: proteinTargetGrams,
                carbTargetGrams: carbTargetGrams,
                fatTargetGrams: fatTargetGrams,
                macroTargetMode: macroTargetMode,
                proteinTargetPercent: proteinTargetPercent,
                carbTargetPercent: carbTargetPercent,
                fatTargetPercent: fatTargetPercent,
                macroLocks: macroLocks,
                hideCalorieNumbers: hideCalorieNumbers,
                activityLevel: activityLevel,
                weightGoal: weightGoal,
                dailyDeficitKcal: dailyDeficitKcal,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NutritionGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NutritionGoalsTable,
      NutritionGoal,
      $$NutritionGoalsTableFilterComposer,
      $$NutritionGoalsTableOrderingComposer,
      $$NutritionGoalsTableAnnotationComposer,
      $$NutritionGoalsTableCreateCompanionBuilder,
      $$NutritionGoalsTableUpdateCompanionBuilder,
      (
        NutritionGoal,
        BaseReferences<_$AppDatabase, $NutritionGoalsTable, NutritionGoal>,
      ),
      NutritionGoal,
      PrefetchHooks Function()
    >;
typedef $$WaterLogsTableCreateCompanionBuilder = WaterLogsCompanion Function({
  required String id,
  required String day,
  required int milliliters,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$WaterLogsTableUpdateCompanionBuilder = WaterLogsCompanion Function({
  Value<String> id,
  Value<String> day,
  Value<int> milliliters,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$WaterLogsTableFilterComposer
    extends Composer<_$AppDatabase, $WaterLogsTable> {
  $$WaterLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get milliliters => $composableBuilder(
    column: $table.milliliters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WaterLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $WaterLogsTable> {
  $$WaterLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get milliliters => $composableBuilder(
    column: $table.milliliters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WaterLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WaterLogsTable> {
  $$WaterLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get milliliters => $composableBuilder(
    column: $table.milliliters,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WaterLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WaterLogsTable,
          WaterLog,
          $$WaterLogsTableFilterComposer,
          $$WaterLogsTableOrderingComposer,
          $$WaterLogsTableAnnotationComposer,
          $$WaterLogsTableCreateCompanionBuilder,
          $$WaterLogsTableUpdateCompanionBuilder,
          (WaterLog, BaseReferences<_$AppDatabase, $WaterLogsTable, WaterLog>),
          WaterLog,
          PrefetchHooks Function()
        > {
  $$WaterLogsTableTableManager(_$AppDatabase db, $WaterLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WaterLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WaterLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WaterLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<int> milliliters = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WaterLogsCompanion(
                id: id,
                day: day,
                milliliters: milliliters,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String day,
                required int milliliters,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => WaterLogsCompanion.insert(
                id: id,
                day: day,
                milliliters: milliliters,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WaterLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WaterLogsTable,
      WaterLog,
      $$WaterLogsTableFilterComposer,
      $$WaterLogsTableOrderingComposer,
      $$WaterLogsTableAnnotationComposer,
      $$WaterLogsTableCreateCompanionBuilder,
      $$WaterLogsTableUpdateCompanionBuilder,
      (WaterLog, BaseReferences<_$AppDatabase, $WaterLogsTable, WaterLog>),
      WaterLog,
      PrefetchHooks Function()
    >;
typedef $$StrengthRoutinesTableCreateCompanionBuilder =
    StrengthRoutinesCompanion Function({
      required String id,
      required String name,
      Value<String> description,
      required String exercisesJson,
      Value<int> estimatedDurationMinutes,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });
typedef $$StrengthRoutinesTableUpdateCompanionBuilder =
    StrengthRoutinesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> description,
      Value<String> exercisesJson,
      Value<int> estimatedDurationMinutes,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });

class $$StrengthRoutinesTableFilterComposer
    extends Composer<_$AppDatabase, $StrengthRoutinesTable> {
  $$StrengthRoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exercisesJson => $composableBuilder(
    column: $table.exercisesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedDurationMinutes => $composableBuilder(
    column: $table.estimatedDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StrengthRoutinesTableOrderingComposer
    extends Composer<_$AppDatabase, $StrengthRoutinesTable> {
  $$StrengthRoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exercisesJson => $composableBuilder(
    column: $table.exercisesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedDurationMinutes => $composableBuilder(
    column: $table.estimatedDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StrengthRoutinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StrengthRoutinesTable> {
  $$StrengthRoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exercisesJson => $composableBuilder(
    column: $table.exercisesJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedDurationMinutes => $composableBuilder(
    column: $table.estimatedDurationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$StrengthRoutinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StrengthRoutinesTable,
          StrengthRoutine,
          $$StrengthRoutinesTableFilterComposer,
          $$StrengthRoutinesTableOrderingComposer,
          $$StrengthRoutinesTableAnnotationComposer,
          $$StrengthRoutinesTableCreateCompanionBuilder,
          $$StrengthRoutinesTableUpdateCompanionBuilder,
          (
            StrengthRoutine,
            BaseReferences<
              _$AppDatabase,
              $StrengthRoutinesTable,
              StrengthRoutine
            >,
          ),
          StrengthRoutine,
          PrefetchHooks Function()
        > {
  $$StrengthRoutinesTableTableManager(
    _$AppDatabase db,
    $StrengthRoutinesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StrengthRoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StrengthRoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StrengthRoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> exercisesJson = const Value.absent(),
                Value<int> estimatedDurationMinutes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StrengthRoutinesCompanion(
                id: id,
                name: name,
                description: description,
                exercisesJson: exercisesJson,
                estimatedDurationMinutes: estimatedDurationMinutes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> description = const Value.absent(),
                required String exercisesJson,
                Value<int> estimatedDurationMinutes = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StrengthRoutinesCompanion.insert(
                id: id,
                name: name,
                description: description,
                exercisesJson: exercisesJson,
                estimatedDurationMinutes: estimatedDurationMinutes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StrengthRoutinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StrengthRoutinesTable,
      StrengthRoutine,
      $$StrengthRoutinesTableFilterComposer,
      $$StrengthRoutinesTableOrderingComposer,
      $$StrengthRoutinesTableAnnotationComposer,
      $$StrengthRoutinesTableCreateCompanionBuilder,
      $$StrengthRoutinesTableUpdateCompanionBuilder,
      (
        StrengthRoutine,
        BaseReferences<_$AppDatabase, $StrengthRoutinesTable, StrengthRoutine>,
      ),
      StrengthRoutine,
      PrefetchHooks Function()
    >;
typedef $$StrengthCyclesTableCreateCompanionBuilder =
    StrengthCyclesCompanion Function({
      required String id,
      required String name,
      Value<String> description,
      required String routinesJson,
      Value<int> currentDayIndex,
      Value<int> totalSessionsCompleted,
      Value<double> totalVolumeLiftedKg,
      Value<bool> isActive,
      Value<int?> startedAt,
      Value<int?> lastCompletedAt,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });
typedef $$StrengthCyclesTableUpdateCompanionBuilder =
    StrengthCyclesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> description,
      Value<String> routinesJson,
      Value<int> currentDayIndex,
      Value<int> totalSessionsCompleted,
      Value<double> totalVolumeLiftedKg,
      Value<bool> isActive,
      Value<int?> startedAt,
      Value<int?> lastCompletedAt,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });

class $$StrengthCyclesTableFilterComposer
    extends Composer<_$AppDatabase, $StrengthCyclesTable> {
  $$StrengthCyclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routinesJson => $composableBuilder(
    column: $table.routinesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentDayIndex => $composableBuilder(
    column: $table.currentDayIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSessionsCompleted => $composableBuilder(
    column: $table.totalSessionsCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalVolumeLiftedKg => $composableBuilder(
    column: $table.totalVolumeLiftedKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastCompletedAt => $composableBuilder(
    column: $table.lastCompletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StrengthCyclesTableOrderingComposer
    extends Composer<_$AppDatabase, $StrengthCyclesTable> {
  $$StrengthCyclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routinesJson => $composableBuilder(
    column: $table.routinesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentDayIndex => $composableBuilder(
    column: $table.currentDayIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSessionsCompleted => $composableBuilder(
    column: $table.totalSessionsCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalVolumeLiftedKg => $composableBuilder(
    column: $table.totalVolumeLiftedKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastCompletedAt => $composableBuilder(
    column: $table.lastCompletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StrengthCyclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StrengthCyclesTable> {
  $$StrengthCyclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get routinesJson => $composableBuilder(
    column: $table.routinesJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentDayIndex => $composableBuilder(
    column: $table.currentDayIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalSessionsCompleted => $composableBuilder(
    column: $table.totalSessionsCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalVolumeLiftedKg => $composableBuilder(
    column: $table.totalVolumeLiftedKg,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get lastCompletedAt => $composableBuilder(
    column: $table.lastCompletedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$StrengthCyclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StrengthCyclesTable,
          StrengthCycle,
          $$StrengthCyclesTableFilterComposer,
          $$StrengthCyclesTableOrderingComposer,
          $$StrengthCyclesTableAnnotationComposer,
          $$StrengthCyclesTableCreateCompanionBuilder,
          $$StrengthCyclesTableUpdateCompanionBuilder,
          (
            StrengthCycle,
            BaseReferences<_$AppDatabase, $StrengthCyclesTable, StrengthCycle>,
          ),
          StrengthCycle,
          PrefetchHooks Function()
        > {
  $$StrengthCyclesTableTableManager(
    _$AppDatabase db,
    $StrengthCyclesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StrengthCyclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StrengthCyclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StrengthCyclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> routinesJson = const Value.absent(),
                Value<int> currentDayIndex = const Value.absent(),
                Value<int> totalSessionsCompleted = const Value.absent(),
                Value<double> totalVolumeLiftedKg = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> startedAt = const Value.absent(),
                Value<int?> lastCompletedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StrengthCyclesCompanion(
                id: id,
                name: name,
                description: description,
                routinesJson: routinesJson,
                currentDayIndex: currentDayIndex,
                totalSessionsCompleted: totalSessionsCompleted,
                totalVolumeLiftedKg: totalVolumeLiftedKg,
                isActive: isActive,
                startedAt: startedAt,
                lastCompletedAt: lastCompletedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> description = const Value.absent(),
                required String routinesJson,
                Value<int> currentDayIndex = const Value.absent(),
                Value<int> totalSessionsCompleted = const Value.absent(),
                Value<double> totalVolumeLiftedKg = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> startedAt = const Value.absent(),
                Value<int?> lastCompletedAt = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StrengthCyclesCompanion.insert(
                id: id,
                name: name,
                description: description,
                routinesJson: routinesJson,
                currentDayIndex: currentDayIndex,
                totalSessionsCompleted: totalSessionsCompleted,
                totalVolumeLiftedKg: totalVolumeLiftedKg,
                isActive: isActive,
                startedAt: startedAt,
                lastCompletedAt: lastCompletedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StrengthCyclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StrengthCyclesTable,
      StrengthCycle,
      $$StrengthCyclesTableFilterComposer,
      $$StrengthCyclesTableOrderingComposer,
      $$StrengthCyclesTableAnnotationComposer,
      $$StrengthCyclesTableCreateCompanionBuilder,
      $$StrengthCyclesTableUpdateCompanionBuilder,
      (
        StrengthCycle,
        BaseReferences<_$AppDatabase, $StrengthCyclesTable, StrengthCycle>,
      ),
      StrengthCycle,
      PrefetchHooks Function()
    >;
typedef $$WeightLogsTableCreateCompanionBuilder = WeightLogsCompanion Function({
  required String id,
  required String day,
  required double weightKg,
  Value<String?> notes,
  Value<String> source,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$WeightLogsTableUpdateCompanionBuilder = WeightLogsCompanion Function({
  Value<String> id,
  Value<String> day,
  Value<double> weightKg,
  Value<String?> notes,
  Value<String> source,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$WeightLogsTableFilterComposer
    extends Composer<_$AppDatabase, $WeightLogsTable> {
  $$WeightLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeightLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $WeightLogsTable> {
  $$WeightLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeightLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeightLogsTable> {
  $$WeightLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WeightLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeightLogsTable,
          WeightLog,
          $$WeightLogsTableFilterComposer,
          $$WeightLogsTableOrderingComposer,
          $$WeightLogsTableAnnotationComposer,
          $$WeightLogsTableCreateCompanionBuilder,
          $$WeightLogsTableUpdateCompanionBuilder,
          (
            WeightLog,
            BaseReferences<_$AppDatabase, $WeightLogsTable, WeightLog>,
          ),
          WeightLog,
          PrefetchHooks Function()
        > {
  $$WeightLogsTableTableManager(_$AppDatabase db, $WeightLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeightLogsCompanion(
                id: id,
                day: day,
                weightKg: weightKg,
                notes: notes,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String day,
                required double weightKg,
                Value<String?> notes = const Value.absent(),
                Value<String> source = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WeightLogsCompanion.insert(
                id: id,
                day: day,
                weightKg: weightKg,
                notes: notes,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeightLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeightLogsTable,
      WeightLog,
      $$WeightLogsTableFilterComposer,
      $$WeightLogsTableOrderingComposer,
      $$WeightLogsTableAnnotationComposer,
      $$WeightLogsTableCreateCompanionBuilder,
      $$WeightLogsTableUpdateCompanionBuilder,
      (WeightLog, BaseReferences<_$AppDatabase, $WeightLogsTable, WeightLog>),
      WeightLog,
      PrefetchHooks Function()
    >;
typedef $$BadgeAwardsTableCreateCompanionBuilder =
    BadgeAwardsCompanion Function({
      required String id,
      required String badgeId,
      required String tierKey,
      required int awardedAt,
      Value<int> rowid,
    });
typedef $$BadgeAwardsTableUpdateCompanionBuilder =
    BadgeAwardsCompanion Function({
      Value<String> id,
      Value<String> badgeId,
      Value<String> tierKey,
      Value<int> awardedAt,
      Value<int> rowid,
    });

class $$BadgeAwardsTableFilterComposer
    extends Composer<_$AppDatabase, $BadgeAwardsTable> {
  $$BadgeAwardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get badgeId => $composableBuilder(
    column: $table.badgeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tierKey => $composableBuilder(
    column: $table.tierKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get awardedAt => $composableBuilder(
    column: $table.awardedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BadgeAwardsTableOrderingComposer
    extends Composer<_$AppDatabase, $BadgeAwardsTable> {
  $$BadgeAwardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get badgeId => $composableBuilder(
    column: $table.badgeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tierKey => $composableBuilder(
    column: $table.tierKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get awardedAt => $composableBuilder(
    column: $table.awardedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BadgeAwardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BadgeAwardsTable> {
  $$BadgeAwardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get badgeId =>
      $composableBuilder(column: $table.badgeId, builder: (column) => column);

  GeneratedColumn<String> get tierKey =>
      $composableBuilder(column: $table.tierKey, builder: (column) => column);

  GeneratedColumn<int> get awardedAt =>
      $composableBuilder(column: $table.awardedAt, builder: (column) => column);
}

class $$BadgeAwardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BadgeAwardsTable,
          BadgeAwardRow,
          $$BadgeAwardsTableFilterComposer,
          $$BadgeAwardsTableOrderingComposer,
          $$BadgeAwardsTableAnnotationComposer,
          $$BadgeAwardsTableCreateCompanionBuilder,
          $$BadgeAwardsTableUpdateCompanionBuilder,
          (
            BadgeAwardRow,
            BaseReferences<_$AppDatabase, $BadgeAwardsTable, BadgeAwardRow>,
          ),
          BadgeAwardRow,
          PrefetchHooks Function()
        > {
  $$BadgeAwardsTableTableManager(_$AppDatabase db, $BadgeAwardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BadgeAwardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BadgeAwardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BadgeAwardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> badgeId = const Value.absent(),
                Value<String> tierKey = const Value.absent(),
                Value<int> awardedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BadgeAwardsCompanion(
                id: id,
                badgeId: badgeId,
                tierKey: tierKey,
                awardedAt: awardedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String badgeId,
                required String tierKey,
                required int awardedAt,
                Value<int> rowid = const Value.absent(),
              }) => BadgeAwardsCompanion.insert(
                id: id,
                badgeId: badgeId,
                tierKey: tierKey,
                awardedAt: awardedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BadgeAwardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BadgeAwardsTable,
      BadgeAwardRow,
      $$BadgeAwardsTableFilterComposer,
      $$BadgeAwardsTableOrderingComposer,
      $$BadgeAwardsTableAnnotationComposer,
      $$BadgeAwardsTableCreateCompanionBuilder,
      $$BadgeAwardsTableUpdateCompanionBuilder,
      (
        BadgeAwardRow,
        BaseReferences<_$AppDatabase, $BadgeAwardsTable, BadgeAwardRow>,
      ),
      BadgeAwardRow,
      PrefetchHooks Function()
    >;
typedef $$ChallengesTableCreateCompanionBuilder = ChallengesCompanion Function({
  required String id,
  required String kind,
  required String activityTypes,
  required int targetUnits,
  required String windowStart,
  required String windowEnd,
  required int salt,
  required String selfDisplayName,
  required String origin,
  required int authorTag,
  Value<String?> buddyDisplayName,
  Value<double?> buddyProgressPercent,
  Value<String?> buddyAsOf,
  required int createdAt,
  Value<int> rowid,
});
typedef $$ChallengesTableUpdateCompanionBuilder = ChallengesCompanion Function({
  Value<String> id,
  Value<String> kind,
  Value<String> activityTypes,
  Value<int> targetUnits,
  Value<String> windowStart,
  Value<String> windowEnd,
  Value<int> salt,
  Value<String> selfDisplayName,
  Value<String> origin,
  Value<int> authorTag,
  Value<String?> buddyDisplayName,
  Value<double?> buddyProgressPercent,
  Value<String?> buddyAsOf,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$ChallengesTableFilterComposer
    extends Composer<_$AppDatabase, $ChallengesTable> {
  $$ChallengesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityTypes => $composableBuilder(
    column: $table.activityTypes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetUnits => $composableBuilder(
    column: $table.targetUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get windowStart => $composableBuilder(
    column: $table.windowStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get windowEnd => $composableBuilder(
    column: $table.windowEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selfDisplayName => $composableBuilder(
    column: $table.selfDisplayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get authorTag => $composableBuilder(
    column: $table.authorTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buddyDisplayName => $composableBuilder(
    column: $table.buddyDisplayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get buddyProgressPercent => $composableBuilder(
    column: $table.buddyProgressPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buddyAsOf => $composableBuilder(
    column: $table.buddyAsOf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChallengesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChallengesTable> {
  $$ChallengesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityTypes => $composableBuilder(
    column: $table.activityTypes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetUnits => $composableBuilder(
    column: $table.targetUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get windowStart => $composableBuilder(
    column: $table.windowStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get windowEnd => $composableBuilder(
    column: $table.windowEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selfDisplayName => $composableBuilder(
    column: $table.selfDisplayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get authorTag => $composableBuilder(
    column: $table.authorTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buddyDisplayName => $composableBuilder(
    column: $table.buddyDisplayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get buddyProgressPercent => $composableBuilder(
    column: $table.buddyProgressPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buddyAsOf => $composableBuilder(
    column: $table.buddyAsOf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChallengesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChallengesTable> {
  $$ChallengesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get activityTypes => $composableBuilder(
    column: $table.activityTypes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetUnits => $composableBuilder(
    column: $table.targetUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get windowStart => $composableBuilder(
    column: $table.windowStart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get windowEnd =>
      $composableBuilder(column: $table.windowEnd, builder: (column) => column);

  GeneratedColumn<int> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<String> get selfDisplayName => $composableBuilder(
    column: $table.selfDisplayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<int> get authorTag =>
      $composableBuilder(column: $table.authorTag, builder: (column) => column);

  GeneratedColumn<String> get buddyDisplayName => $composableBuilder(
    column: $table.buddyDisplayName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get buddyProgressPercent => $composableBuilder(
    column: $table.buddyProgressPercent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get buddyAsOf =>
      $composableBuilder(column: $table.buddyAsOf, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ChallengesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChallengesTable,
          ChallengeRow,
          $$ChallengesTableFilterComposer,
          $$ChallengesTableOrderingComposer,
          $$ChallengesTableAnnotationComposer,
          $$ChallengesTableCreateCompanionBuilder,
          $$ChallengesTableUpdateCompanionBuilder,
          (
            ChallengeRow,
            BaseReferences<_$AppDatabase, $ChallengesTable, ChallengeRow>,
          ),
          ChallengeRow,
          PrefetchHooks Function()
        > {
  $$ChallengesTableTableManager(_$AppDatabase db, $ChallengesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChallengesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChallengesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChallengesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> activityTypes = const Value.absent(),
                Value<int> targetUnits = const Value.absent(),
                Value<String> windowStart = const Value.absent(),
                Value<String> windowEnd = const Value.absent(),
                Value<int> salt = const Value.absent(),
                Value<String> selfDisplayName = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<int> authorTag = const Value.absent(),
                Value<String?> buddyDisplayName = const Value.absent(),
                Value<double?> buddyProgressPercent = const Value.absent(),
                Value<String?> buddyAsOf = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChallengesCompanion(
                id: id,
                kind: kind,
                activityTypes: activityTypes,
                targetUnits: targetUnits,
                windowStart: windowStart,
                windowEnd: windowEnd,
                salt: salt,
                selfDisplayName: selfDisplayName,
                origin: origin,
                authorTag: authorTag,
                buddyDisplayName: buddyDisplayName,
                buddyProgressPercent: buddyProgressPercent,
                buddyAsOf: buddyAsOf,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required String activityTypes,
                required int targetUnits,
                required String windowStart,
                required String windowEnd,
                required int salt,
                required String selfDisplayName,
                required String origin,
                required int authorTag,
                Value<String?> buddyDisplayName = const Value.absent(),
                Value<double?> buddyProgressPercent = const Value.absent(),
                Value<String?> buddyAsOf = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ChallengesCompanion.insert(
                id: id,
                kind: kind,
                activityTypes: activityTypes,
                targetUnits: targetUnits,
                windowStart: windowStart,
                windowEnd: windowEnd,
                salt: salt,
                selfDisplayName: selfDisplayName,
                origin: origin,
                authorTag: authorTag,
                buddyDisplayName: buddyDisplayName,
                buddyProgressPercent: buddyProgressPercent,
                buddyAsOf: buddyAsOf,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChallengesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChallengesTable,
      ChallengeRow,
      $$ChallengesTableFilterComposer,
      $$ChallengesTableOrderingComposer,
      $$ChallengesTableAnnotationComposer,
      $$ChallengesTableCreateCompanionBuilder,
      $$ChallengesTableUpdateCompanionBuilder,
      (
        ChallengeRow,
        BaseReferences<_$AppDatabase, $ChallengesTable, ChallengeRow>,
      ),
      ChallengeRow,
      PrefetchHooks Function()
    >;
typedef $$DailyStepTotalsTableCreateCompanionBuilder =
    DailyStepTotalsCompanion Function({
      required String day,
      required int steps,
      Value<String?> source,
      required int syncedAt,
      Value<int> rowid,
    });
typedef $$DailyStepTotalsTableUpdateCompanionBuilder =
    DailyStepTotalsCompanion Function({
      Value<String> day,
      Value<int> steps,
      Value<String?> source,
      Value<int> syncedAt,
      Value<int> rowid,
    });

class $$DailyStepTotalsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyStepTotalsTable> {
  $$DailyStepTotalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyStepTotalsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyStepTotalsTable> {
  $$DailyStepTotalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyStepTotalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyStepTotalsTable> {
  $$DailyStepTotalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$DailyStepTotalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyStepTotalsTable,
          DailyStepTotal,
          $$DailyStepTotalsTableFilterComposer,
          $$DailyStepTotalsTableOrderingComposer,
          $$DailyStepTotalsTableAnnotationComposer,
          $$DailyStepTotalsTableCreateCompanionBuilder,
          $$DailyStepTotalsTableUpdateCompanionBuilder,
          (
            DailyStepTotal,
            BaseReferences<
              _$AppDatabase,
              $DailyStepTotalsTable,
              DailyStepTotal
            >,
          ),
          DailyStepTotal,
          PrefetchHooks Function()
        > {
  $$DailyStepTotalsTableTableManager(
    _$AppDatabase db,
    $DailyStepTotalsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyStepTotalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyStepTotalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyStepTotalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> day = const Value.absent(),
                Value<int> steps = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<int> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyStepTotalsCompanion(
                day: day,
                steps: steps,
                source: source,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String day,
                required int steps,
                Value<String?> source = const Value.absent(),
                required int syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => DailyStepTotalsCompanion.insert(
                day: day,
                steps: steps,
                source: source,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyStepTotalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyStepTotalsTable,
      DailyStepTotal,
      $$DailyStepTotalsTableFilterComposer,
      $$DailyStepTotalsTableOrderingComposer,
      $$DailyStepTotalsTableAnnotationComposer,
      $$DailyStepTotalsTableCreateCompanionBuilder,
      $$DailyStepTotalsTableUpdateCompanionBuilder,
      (
        DailyStepTotal,
        BaseReferences<_$AppDatabase, $DailyStepTotalsTable, DailyStepTotal>,
      ),
      DailyStepTotal,
      PrefetchHooks Function()
    >;
typedef $$YogaSequencesTableCreateCompanionBuilder =
    YogaSequencesCompanion Function({
      required String id,
      required String name,
      Value<String> description,
      required String posesJson,
      Value<int> transitionSeconds,
      Value<String?> style,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });
typedef $$YogaSequencesTableUpdateCompanionBuilder =
    YogaSequencesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> description,
      Value<String> posesJson,
      Value<int> transitionSeconds,
      Value<String?> style,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });

class $$YogaSequencesTableFilterComposer
    extends Composer<_$AppDatabase, $YogaSequencesTable> {
  $$YogaSequencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posesJson => $composableBuilder(
    column: $table.posesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transitionSeconds => $composableBuilder(
    column: $table.transitionSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get style => $composableBuilder(
    column: $table.style,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$YogaSequencesTableOrderingComposer
    extends Composer<_$AppDatabase, $YogaSequencesTable> {
  $$YogaSequencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posesJson => $composableBuilder(
    column: $table.posesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transitionSeconds => $composableBuilder(
    column: $table.transitionSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get style => $composableBuilder(
    column: $table.style,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$YogaSequencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $YogaSequencesTable> {
  $$YogaSequencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get posesJson =>
      $composableBuilder(column: $table.posesJson, builder: (column) => column);

  GeneratedColumn<int> get transitionSeconds => $composableBuilder(
    column: $table.transitionSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get style =>
      $composableBuilder(column: $table.style, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$YogaSequencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $YogaSequencesTable,
          YogaSequence,
          $$YogaSequencesTableFilterComposer,
          $$YogaSequencesTableOrderingComposer,
          $$YogaSequencesTableAnnotationComposer,
          $$YogaSequencesTableCreateCompanionBuilder,
          $$YogaSequencesTableUpdateCompanionBuilder,
          (
            YogaSequence,
            BaseReferences<_$AppDatabase, $YogaSequencesTable, YogaSequence>,
          ),
          YogaSequence,
          PrefetchHooks Function()
        > {
  $$YogaSequencesTableTableManager(_$AppDatabase db, $YogaSequencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$YogaSequencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$YogaSequencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$YogaSequencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> posesJson = const Value.absent(),
                Value<int> transitionSeconds = const Value.absent(),
                Value<String?> style = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => YogaSequencesCompanion(
                id: id,
                name: name,
                description: description,
                posesJson: posesJson,
                transitionSeconds: transitionSeconds,
                style: style,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> description = const Value.absent(),
                required String posesJson,
                Value<int> transitionSeconds = const Value.absent(),
                Value<String?> style = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => YogaSequencesCompanion.insert(
                id: id,
                name: name,
                description: description,
                posesJson: posesJson,
                transitionSeconds: transitionSeconds,
                style: style,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$YogaSequencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $YogaSequencesTable,
      YogaSequence,
      $$YogaSequencesTableFilterComposer,
      $$YogaSequencesTableOrderingComposer,
      $$YogaSequencesTableAnnotationComposer,
      $$YogaSequencesTableCreateCompanionBuilder,
      $$YogaSequencesTableUpdateCompanionBuilder,
      (
        YogaSequence,
        BaseReferences<_$AppDatabase, $YogaSequencesTable, YogaSequence>,
      ),
      YogaSequence,
      PrefetchHooks Function()
    >;
typedef $$WellbeingEventsTableCreateCompanionBuilder =
    WellbeingEventsCompanion Function({
      required String id,
      required String day,
      required String type,
      required String title,
      Value<bool> isCustomSaved,
      Value<String?> notes,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });
typedef $$WellbeingEventsTableUpdateCompanionBuilder =
    WellbeingEventsCompanion Function({
      Value<String> id,
      Value<String> day,
      Value<String> type,
      Value<String> title,
      Value<bool> isCustomSaved,
      Value<String?> notes,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });

class $$WellbeingEventsTableFilterComposer
    extends Composer<_$AppDatabase, $WellbeingEventsTable> {
  $$WellbeingEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustomSaved => $composableBuilder(
    column: $table.isCustomSaved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WellbeingEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $WellbeingEventsTable> {
  $$WellbeingEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustomSaved => $composableBuilder(
    column: $table.isCustomSaved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WellbeingEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WellbeingEventsTable> {
  $$WellbeingEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get isCustomSaved => $composableBuilder(
    column: $table.isCustomSaved,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$WellbeingEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WellbeingEventsTable,
          WellbeingEvent,
          $$WellbeingEventsTableFilterComposer,
          $$WellbeingEventsTableOrderingComposer,
          $$WellbeingEventsTableAnnotationComposer,
          $$WellbeingEventsTableCreateCompanionBuilder,
          $$WellbeingEventsTableUpdateCompanionBuilder,
          (
            WellbeingEvent,
            BaseReferences<
              _$AppDatabase,
              $WellbeingEventsTable,
              WellbeingEvent
            >,
          ),
          WellbeingEvent,
          PrefetchHooks Function()
        > {
  $$WellbeingEventsTableTableManager(
    _$AppDatabase db,
    $WellbeingEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WellbeingEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WellbeingEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WellbeingEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> isCustomSaved = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WellbeingEventsCompanion(
                id: id,
                day: day,
                type: type,
                title: title,
                isCustomSaved: isCustomSaved,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String day,
                required String type,
                required String title,
                Value<bool> isCustomSaved = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WellbeingEventsCompanion.insert(
                id: id,
                day: day,
                type: type,
                title: title,
                isCustomSaved: isCustomSaved,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WellbeingEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WellbeingEventsTable,
      WellbeingEvent,
      $$WellbeingEventsTableFilterComposer,
      $$WellbeingEventsTableOrderingComposer,
      $$WellbeingEventsTableAnnotationComposer,
      $$WellbeingEventsTableCreateCompanionBuilder,
      $$WellbeingEventsTableUpdateCompanionBuilder,
      (
        WellbeingEvent,
        BaseReferences<_$AppDatabase, $WellbeingEventsTable, WellbeingEvent>,
      ),
      WellbeingEvent,
      PrefetchHooks Function()
    >;
typedef $$KetoneReadingsTableCreateCompanionBuilder =
    KetoneReadingsCompanion Function({
      required String id,
      required String day,
      required int measuredAt,
      required String type,
      required String result,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$KetoneReadingsTableUpdateCompanionBuilder =
    KetoneReadingsCompanion Function({
      Value<String> id,
      Value<String> day,
      Value<int> measuredAt,
      Value<String> type,
      Value<String> result,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$KetoneReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $KetoneReadingsTable> {
  $$KetoneReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KetoneReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $KetoneReadingsTable> {
  $$KetoneReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KetoneReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $KetoneReadingsTable> {
  $$KetoneReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$KetoneReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KetoneReadingsTable,
          KetoneReading,
          $$KetoneReadingsTableFilterComposer,
          $$KetoneReadingsTableOrderingComposer,
          $$KetoneReadingsTableAnnotationComposer,
          $$KetoneReadingsTableCreateCompanionBuilder,
          $$KetoneReadingsTableUpdateCompanionBuilder,
          (
            KetoneReading,
            BaseReferences<_$AppDatabase, $KetoneReadingsTable, KetoneReading>,
          ),
          KetoneReading,
          PrefetchHooks Function()
        > {
  $$KetoneReadingsTableTableManager(
    _$AppDatabase db,
    $KetoneReadingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KetoneReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KetoneReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KetoneReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<int> measuredAt = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KetoneReadingsCompanion(
                id: id,
                day: day,
                measuredAt: measuredAt,
                type: type,
                result: result,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String day,
                required int measuredAt,
                required String type,
                required String result,
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => KetoneReadingsCompanion.insert(
                id: id,
                day: day,
                measuredAt: measuredAt,
                type: type,
                result: result,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KetoneReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KetoneReadingsTable,
      KetoneReading,
      $$KetoneReadingsTableFilterComposer,
      $$KetoneReadingsTableOrderingComposer,
      $$KetoneReadingsTableAnnotationComposer,
      $$KetoneReadingsTableCreateCompanionBuilder,
      $$KetoneReadingsTableUpdateCompanionBuilder,
      (
        KetoneReading,
        BaseReferences<_$AppDatabase, $KetoneReadingsTable, KetoneReading>,
      ),
      KetoneReading,
      PrefetchHooks Function()
    >;
typedef $$BloodPressureReadingsTableCreateCompanionBuilder =
    BloodPressureReadingsCompanion Function({
      required String id,
      required String day,
      required int measuredAt,
      required int systolic,
      required int diastolic,
      Value<int?> pulse,
      Value<String?> note,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$BloodPressureReadingsTableUpdateCompanionBuilder =
    BloodPressureReadingsCompanion Function({
      Value<String> id,
      Value<String> day,
      Value<int> measuredAt,
      Value<int> systolic,
      Value<int> diastolic,
      Value<int?> pulse,
      Value<String?> note,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$BloodPressureReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $BloodPressureReadingsTable> {
  $$BloodPressureReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get systolic => $composableBuilder(
    column: $table.systolic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diastolic => $composableBuilder(
    column: $table.diastolic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pulse => $composableBuilder(
    column: $table.pulse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BloodPressureReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $BloodPressureReadingsTable> {
  $$BloodPressureReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get systolic => $composableBuilder(
    column: $table.systolic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diastolic => $composableBuilder(
    column: $table.diastolic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pulse => $composableBuilder(
    column: $table.pulse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BloodPressureReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BloodPressureReadingsTable> {
  $$BloodPressureReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get systolic =>
      $composableBuilder(column: $table.systolic, builder: (column) => column);

  GeneratedColumn<int> get diastolic =>
      $composableBuilder(column: $table.diastolic, builder: (column) => column);

  GeneratedColumn<int> get pulse =>
      $composableBuilder(column: $table.pulse, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BloodPressureReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BloodPressureReadingsTable,
          BloodPressureReading,
          $$BloodPressureReadingsTableFilterComposer,
          $$BloodPressureReadingsTableOrderingComposer,
          $$BloodPressureReadingsTableAnnotationComposer,
          $$BloodPressureReadingsTableCreateCompanionBuilder,
          $$BloodPressureReadingsTableUpdateCompanionBuilder,
          (
            BloodPressureReading,
            BaseReferences<
              _$AppDatabase,
              $BloodPressureReadingsTable,
              BloodPressureReading
            >,
          ),
          BloodPressureReading,
          PrefetchHooks Function()
        > {
  $$BloodPressureReadingsTableTableManager(
    _$AppDatabase db,
    $BloodPressureReadingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BloodPressureReadingsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$BloodPressureReadingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BloodPressureReadingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<int> measuredAt = const Value.absent(),
                Value<int> systolic = const Value.absent(),
                Value<int> diastolic = const Value.absent(),
                Value<int?> pulse = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BloodPressureReadingsCompanion(
                id: id,
                day: day,
                measuredAt: measuredAt,
                systolic: systolic,
                diastolic: diastolic,
                pulse: pulse,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String day,
                required int measuredAt,
                required int systolic,
                required int diastolic,
                Value<int?> pulse = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BloodPressureReadingsCompanion.insert(
                id: id,
                day: day,
                measuredAt: measuredAt,
                systolic: systolic,
                diastolic: diastolic,
                pulse: pulse,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BloodPressureReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BloodPressureReadingsTable,
      BloodPressureReading,
      $$BloodPressureReadingsTableFilterComposer,
      $$BloodPressureReadingsTableOrderingComposer,
      $$BloodPressureReadingsTableAnnotationComposer,
      $$BloodPressureReadingsTableCreateCompanionBuilder,
      $$BloodPressureReadingsTableUpdateCompanionBuilder,
      (
        BloodPressureReading,
        BaseReferences<
          _$AppDatabase,
          $BloodPressureReadingsTable,
          BloodPressureReading
        >,
      ),
      BloodPressureReading,
      PrefetchHooks Function()
    >;
typedef $$BloodMarkerReadingsTableCreateCompanionBuilder =
    BloodMarkerReadingsCompanion Function({
      required String id,
      required String day,
      required int measuredAt,
      required String marker,
      required double value,
      required String unit,
      Value<String?> context,
      Value<String?> note,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$BloodMarkerReadingsTableUpdateCompanionBuilder =
    BloodMarkerReadingsCompanion Function({
      Value<String> id,
      Value<String> day,
      Value<int> measuredAt,
      Value<String> marker,
      Value<double> value,
      Value<String> unit,
      Value<String?> context,
      Value<String?> note,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$BloodMarkerReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $BloodMarkerReadingsTable> {
  $$BloodMarkerReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get marker => $composableBuilder(
    column: $table.marker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BloodMarkerReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $BloodMarkerReadingsTable> {
  $$BloodMarkerReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marker => $composableBuilder(
    column: $table.marker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BloodMarkerReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BloodMarkerReadingsTable> {
  $$BloodMarkerReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get marker =>
      $composableBuilder(column: $table.marker, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BloodMarkerReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BloodMarkerReadingsTable,
          BloodMarkerReading,
          $$BloodMarkerReadingsTableFilterComposer,
          $$BloodMarkerReadingsTableOrderingComposer,
          $$BloodMarkerReadingsTableAnnotationComposer,
          $$BloodMarkerReadingsTableCreateCompanionBuilder,
          $$BloodMarkerReadingsTableUpdateCompanionBuilder,
          (
            BloodMarkerReading,
            BaseReferences<
              _$AppDatabase,
              $BloodMarkerReadingsTable,
              BloodMarkerReading
            >,
          ),
          BloodMarkerReading,
          PrefetchHooks Function()
        > {
  $$BloodMarkerReadingsTableTableManager(
    _$AppDatabase db,
    $BloodMarkerReadingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BloodMarkerReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BloodMarkerReadingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BloodMarkerReadingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<int> measuredAt = const Value.absent(),
                Value<String> marker = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String?> context = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BloodMarkerReadingsCompanion(
                id: id,
                day: day,
                measuredAt: measuredAt,
                marker: marker,
                value: value,
                unit: unit,
                context: context,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String day,
                required int measuredAt,
                required String marker,
                required double value,
                required String unit,
                Value<String?> context = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BloodMarkerReadingsCompanion.insert(
                id: id,
                day: day,
                measuredAt: measuredAt,
                marker: marker,
                value: value,
                unit: unit,
                context: context,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BloodMarkerReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BloodMarkerReadingsTable,
      BloodMarkerReading,
      $$BloodMarkerReadingsTableFilterComposer,
      $$BloodMarkerReadingsTableOrderingComposer,
      $$BloodMarkerReadingsTableAnnotationComposer,
      $$BloodMarkerReadingsTableCreateCompanionBuilder,
      $$BloodMarkerReadingsTableUpdateCompanionBuilder,
      (
        BloodMarkerReading,
        BaseReferences<
          _$AppDatabase,
          $BloodMarkerReadingsTable,
          BloodMarkerReading
        >,
      ),
      BloodMarkerReading,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$ActivitySamplesTableTableManager get activitySamples =>
      $$ActivitySamplesTableTableManager(_db, _db.activitySamples);
  $$DailyCheckinsTableTableManager get dailyCheckins =>
      $$DailyCheckinsTableTableManager(_db, _db.dailyCheckins);
  $$FlareEventsTableTableManager get flareEvents =>
      $$FlareEventsTableTableManager(_db, _db.flareEvents);
  $$RecoveryDaysTableTableManager get recoveryDays =>
      $$RecoveryDaysTableTableManager(_db, _db.recoveryDays);
  $$RoutesTableTableManager get routes =>
      $$RoutesTableTableManager(_db, _db.routes);
  $$FoodsTableTableManager get foods =>
      $$FoodsTableTableManager(_db, _db.foods);
  $$NutritionEntriesTableTableManager get nutritionEntries =>
      $$NutritionEntriesTableTableManager(_db, _db.nutritionEntries);
  $$NutritionGoalsTableTableManager get nutritionGoals =>
      $$NutritionGoalsTableTableManager(_db, _db.nutritionGoals);
  $$WaterLogsTableTableManager get waterLogs =>
      $$WaterLogsTableTableManager(_db, _db.waterLogs);
  $$StrengthRoutinesTableTableManager get strengthRoutines =>
      $$StrengthRoutinesTableTableManager(_db, _db.strengthRoutines);
  $$StrengthCyclesTableTableManager get strengthCycles =>
      $$StrengthCyclesTableTableManager(_db, _db.strengthCycles);
  $$WeightLogsTableTableManager get weightLogs =>
      $$WeightLogsTableTableManager(_db, _db.weightLogs);
  $$BadgeAwardsTableTableManager get badgeAwards =>
      $$BadgeAwardsTableTableManager(_db, _db.badgeAwards);
  $$ChallengesTableTableManager get challenges =>
      $$ChallengesTableTableManager(_db, _db.challenges);
  $$DailyStepTotalsTableTableManager get dailyStepTotals =>
      $$DailyStepTotalsTableTableManager(_db, _db.dailyStepTotals);
  $$YogaSequencesTableTableManager get yogaSequences =>
      $$YogaSequencesTableTableManager(_db, _db.yogaSequences);
  $$WellbeingEventsTableTableManager get wellbeingEvents =>
      $$WellbeingEventsTableTableManager(_db, _db.wellbeingEvents);
  $$KetoneReadingsTableTableManager get ketoneReadings =>
      $$KetoneReadingsTableTableManager(_db, _db.ketoneReadings);
  $$BloodPressureReadingsTableTableManager get bloodPressureReadings =>
      $$BloodPressureReadingsTableTableManager(_db, _db.bloodPressureReadings);
  $$BloodMarkerReadingsTableTableManager get bloodMarkerReadings =>
      $$BloodMarkerReadingsTableTableManager(_db, _db.bloodMarkerReadings);
}
