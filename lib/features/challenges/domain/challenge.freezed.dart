// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChallengeBlueprint {

/// Deterministic id — see the class doc. Build blueprints through
/// `challenge_codes.dart#challengeBlueprintFrom` so this stays true.
 String get id; ChallengeKind get kind;/// Which activity types count. **Empty means every type counts** —
/// that is a real, useful choice ("12 sessions of anything"), not a
/// missing value.
 Set<ActivityType> get activityTypes;/// The target in [kind]'s own units: hundreds of metres for
/// [ChallengeKind.totalDistance], sessions for
/// [ChallengeKind.sessionCount]. Stored in coarse units because that
/// is what the code encodes, and a shared target nobody can express
/// exactly is worse than one both sides read identically.
 int get targetUnits;/// Inclusive first day of the window.
 LocalDate get windowStart;/// Inclusive last day of the window.
 LocalDate get windowEnd;/// 32-bit salt, so two challenges created with identical parameters
/// are still two challenges.
 int get salt;
/// Create a copy of ChallengeBlueprint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChallengeBlueprintCopyWith<ChallengeBlueprint> get copyWith => _$ChallengeBlueprintCopyWithImpl<ChallengeBlueprint>(this as ChallengeBlueprint, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChallengeBlueprint&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other.activityTypes, activityTypes)&&(identical(other.targetUnits, targetUnits) || other.targetUnits == targetUnits)&&(identical(other.windowStart, windowStart) || other.windowStart == windowStart)&&(identical(other.windowEnd, windowEnd) || other.windowEnd == windowEnd)&&(identical(other.salt, salt) || other.salt == salt));
}


@override
int get hashCode => Object.hash(runtimeType,id,kind,const DeepCollectionEquality().hash(activityTypes),targetUnits,windowStart,windowEnd,salt);

@override
String toString() {
  return 'ChallengeBlueprint(id: $id, kind: $kind, activityTypes: $activityTypes, targetUnits: $targetUnits, windowStart: $windowStart, windowEnd: $windowEnd, salt: $salt)';
}


}

/// @nodoc
abstract mixin class $ChallengeBlueprintCopyWith<$Res>  {
  factory $ChallengeBlueprintCopyWith(ChallengeBlueprint value, $Res Function(ChallengeBlueprint) _then) = _$ChallengeBlueprintCopyWithImpl;
@useResult
$Res call({
 String id, ChallengeKind kind, Set<ActivityType> activityTypes, int targetUnits, LocalDate windowStart, LocalDate windowEnd, int salt
});




}
/// @nodoc
class _$ChallengeBlueprintCopyWithImpl<$Res>
    implements $ChallengeBlueprintCopyWith<$Res> {
  _$ChallengeBlueprintCopyWithImpl(this._self, this._then);

  final ChallengeBlueprint _self;
  final $Res Function(ChallengeBlueprint) _then;

/// Create a copy of ChallengeBlueprint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? activityTypes = null,Object? targetUnits = null,Object? windowStart = null,Object? windowEnd = null,Object? salt = null,}) {
  return _then(ChallengeBlueprint(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ChallengeKind,activityTypes: null == activityTypes ? _self.activityTypes : activityTypes // ignore: cast_nullable_to_non_nullable
as Set<ActivityType>,targetUnits: null == targetUnits ? _self.targetUnits : targetUnits // ignore: cast_nullable_to_non_nullable
as int,windowStart: null == windowStart ? _self.windowStart : windowStart // ignore: cast_nullable_to_non_nullable
as LocalDate,windowEnd: null == windowEnd ? _self.windowEnd : windowEnd // ignore: cast_nullable_to_non_nullable
as LocalDate,salt: null == salt ? _self.salt : salt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChallengeBlueprint].
extension ChallengeBlueprintPatterns on ChallengeBlueprint {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChallengeBlueprint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChallengeBlueprint() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChallengeBlueprint value)  $default,){
final _that = this;
switch (_that) {
case _ChallengeBlueprint():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChallengeBlueprint value)?  $default,){
final _that = this;
switch (_that) {
case _ChallengeBlueprint() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ChallengeKind kind,  Set<ActivityType> activityTypes,  int targetUnits,  LocalDate windowStart,  LocalDate windowEnd,  int salt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChallengeBlueprint() when $default != null:
return $default(_that.id,_that.kind,_that.activityTypes,_that.targetUnits,_that.windowStart,_that.windowEnd,_that.salt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ChallengeKind kind,  Set<ActivityType> activityTypes,  int targetUnits,  LocalDate windowStart,  LocalDate windowEnd,  int salt)  $default,) {final _that = this;
switch (_that) {
case _ChallengeBlueprint():
return $default(_that.id,_that.kind,_that.activityTypes,_that.targetUnits,_that.windowStart,_that.windowEnd,_that.salt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ChallengeKind kind,  Set<ActivityType> activityTypes,  int targetUnits,  LocalDate windowStart,  LocalDate windowEnd,  int salt)?  $default,) {final _that = this;
switch (_that) {
case _ChallengeBlueprint() when $default != null:
return $default(_that.id,_that.kind,_that.activityTypes,_that.targetUnits,_that.windowStart,_that.windowEnd,_that.salt);case _:
  return null;

}
}

}

/// @nodoc


class _ChallengeBlueprint extends ChallengeBlueprint {
  const _ChallengeBlueprint({required this.id, required this.kind, required  Set<ActivityType> activityTypes, required this.targetUnits, required this.windowStart, required this.windowEnd, required this.salt}): _activityTypes = activityTypes,super._();
  

/// Deterministic id — see the class doc. Build blueprints through
/// `challenge_codes.dart#challengeBlueprintFrom` so this stays true.
@override final  String id;
@override final  ChallengeKind kind;
/// Which activity types count. **Empty means every type counts** —
/// that is a real, useful choice ("12 sessions of anything"), not a
/// missing value.
 final  Set<ActivityType> _activityTypes;
/// Which activity types count. **Empty means every type counts** —
/// that is a real, useful choice ("12 sessions of anything"), not a
/// missing value.
@override Set<ActivityType> get activityTypes {
  if (_activityTypes is EqualUnmodifiableSetView) return _activityTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_activityTypes);
}

/// The target in [kind]'s own units: hundreds of metres for
/// [ChallengeKind.totalDistance], sessions for
/// [ChallengeKind.sessionCount]. Stored in coarse units because that
/// is what the code encodes, and a shared target nobody can express
/// exactly is worse than one both sides read identically.
@override final  int targetUnits;
/// Inclusive first day of the window.
@override final  LocalDate windowStart;
/// Inclusive last day of the window.
@override final  LocalDate windowEnd;
/// 32-bit salt, so two challenges created with identical parameters
/// are still two challenges.
@override final  int salt;

/// Create a copy of ChallengeBlueprint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChallengeBlueprintCopyWith<_ChallengeBlueprint> get copyWith => __$ChallengeBlueprintCopyWithImpl<_ChallengeBlueprint>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChallengeBlueprint&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&const DeepCollectionEquality().equals(other._activityTypes, _activityTypes)&&(identical(other.targetUnits, targetUnits) || other.targetUnits == targetUnits)&&(identical(other.windowStart, windowStart) || other.windowStart == windowStart)&&(identical(other.windowEnd, windowEnd) || other.windowEnd == windowEnd)&&(identical(other.salt, salt) || other.salt == salt));
}


@override
int get hashCode => Object.hash(runtimeType,id,kind,const DeepCollectionEquality().hash(_activityTypes),targetUnits,windowStart,windowEnd,salt);

@override
String toString() {
  return 'ChallengeBlueprint(id: $id, kind: $kind, activityTypes: $activityTypes, targetUnits: $targetUnits, windowStart: $windowStart, windowEnd: $windowEnd, salt: $salt)';
}


}

/// @nodoc
abstract mixin class _$ChallengeBlueprintCopyWith<$Res> implements $ChallengeBlueprintCopyWith<$Res> {
  factory _$ChallengeBlueprintCopyWith(_ChallengeBlueprint value, $Res Function(_ChallengeBlueprint) _then) = __$ChallengeBlueprintCopyWithImpl;
@override @useResult
$Res call({
 String id, ChallengeKind kind, Set<ActivityType> activityTypes, int targetUnits, LocalDate windowStart, LocalDate windowEnd, int salt
});




}
/// @nodoc
class __$ChallengeBlueprintCopyWithImpl<$Res>
    implements _$ChallengeBlueprintCopyWith<$Res> {
  __$ChallengeBlueprintCopyWithImpl(this._self, this._then);

  final _ChallengeBlueprint _self;
  final $Res Function(_ChallengeBlueprint) _then;

/// Create a copy of ChallengeBlueprint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? activityTypes = null,Object? targetUnits = null,Object? windowStart = null,Object? windowEnd = null,Object? salt = null,}) {
  return _then(_ChallengeBlueprint(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ChallengeKind,activityTypes: null == activityTypes ? _self._activityTypes : activityTypes // ignore: cast_nullable_to_non_nullable
as Set<ActivityType>,targetUnits: null == targetUnits ? _self.targetUnits : targetUnits // ignore: cast_nullable_to_non_nullable
as int,windowStart: null == windowStart ? _self.windowStart : windowStart // ignore: cast_nullable_to_non_nullable
as LocalDate,windowEnd: null == windowEnd ? _self.windowEnd : windowEnd // ignore: cast_nullable_to_non_nullable
as LocalDate,salt: null == salt ? _self.salt : salt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$Challenge {

 ChallengeBlueprint get blueprint;/// The name they chose to show their buddy for this challenge. Per
/// challenge, not per account: the same person may be "Ana" to a
/// running club and something else to a sister.
 String get selfDisplayName; ChallengeOrigin get origin;/// This device's 32-bit tag for this challenge, drawn at random when
/// they created or joined it and stamped into every progress code they
/// export for it.
///
/// Local, not shared identity: the two devices in a challenge hold
/// **different** tags for the same challenge, which is the entire
/// point — a pasted code whose tag equals this one is their own code
/// coming back, and importing it would overwrite their buddy's snapshot
/// with their own figure
/// (`application/challenge_code_service.dart#importProgressCode`).
///
/// It is random noise: not derived from their name, their device or
/// anything they have logged. See the privacy invariant on
/// `challenge_codes.dart`.
 int get authorTag;/// UTC. When this device created or joined the challenge — local
/// metadata, not part of the shared identity.
 DateTime get createdAt;/// The buddy's last pasted progress, or null if they have not pasted
/// one yet. Null is a completely normal, permanent-if-they-likes state:
/// a challenge works perfectly well with nobody exchanging progress at
/// all.
 ChallengeBuddySnapshot? get buddy;
/// Create a copy of Challenge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChallengeCopyWith<Challenge> get copyWith => _$ChallengeCopyWithImpl<Challenge>(this as Challenge, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Challenge&&(identical(other.blueprint, blueprint) || other.blueprint == blueprint)&&(identical(other.selfDisplayName, selfDisplayName) || other.selfDisplayName == selfDisplayName)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.authorTag, authorTag) || other.authorTag == authorTag)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.buddy, buddy) || other.buddy == buddy));
}


@override
int get hashCode => Object.hash(runtimeType,blueprint,selfDisplayName,origin,authorTag,createdAt,buddy);

@override
String toString() {
  return 'Challenge(blueprint: $blueprint, selfDisplayName: $selfDisplayName, origin: $origin, authorTag: $authorTag, createdAt: $createdAt, buddy: $buddy)';
}


}

/// @nodoc
abstract mixin class $ChallengeCopyWith<$Res>  {
  factory $ChallengeCopyWith(Challenge value, $Res Function(Challenge) _then) = _$ChallengeCopyWithImpl;
@useResult
$Res call({
 ChallengeBlueprint blueprint, String selfDisplayName, ChallengeOrigin origin, int authorTag, DateTime createdAt, ChallengeBuddySnapshot? buddy
});


$ChallengeBlueprintCopyWith<$Res> get blueprint;$ChallengeBuddySnapshotCopyWith<$Res>? get buddy;

}
/// @nodoc
class _$ChallengeCopyWithImpl<$Res>
    implements $ChallengeCopyWith<$Res> {
  _$ChallengeCopyWithImpl(this._self, this._then);

  final Challenge _self;
  final $Res Function(Challenge) _then;

/// Create a copy of Challenge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? blueprint = null,Object? selfDisplayName = null,Object? origin = null,Object? authorTag = null,Object? createdAt = null,Object? buddy = freezed,}) {
  return _then(Challenge(
blueprint: null == blueprint ? _self.blueprint : blueprint // ignore: cast_nullable_to_non_nullable
as ChallengeBlueprint,selfDisplayName: null == selfDisplayName ? _self.selfDisplayName : selfDisplayName // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as ChallengeOrigin,authorTag: null == authorTag ? _self.authorTag : authorTag // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,buddy: freezed == buddy ? _self.buddy : buddy // ignore: cast_nullable_to_non_nullable
as ChallengeBuddySnapshot?,
  ));
}
/// Create a copy of Challenge
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChallengeBlueprintCopyWith<$Res> get blueprint {
  
  return $ChallengeBlueprintCopyWith<$Res>(_self.blueprint, (value) {
    return _then(_self.copyWith(blueprint: value));
  });
}/// Create a copy of Challenge
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChallengeBuddySnapshotCopyWith<$Res>? get buddy {
    if (_self.buddy == null) {
    return null;
  }

  return $ChallengeBuddySnapshotCopyWith<$Res>(_self.buddy!, (value) {
    return _then(_self.copyWith(buddy: value));
  });
}
}


/// Adds pattern-matching-related methods to [Challenge].
extension ChallengePatterns on Challenge {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Challenge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Challenge() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Challenge value)  $default,){
final _that = this;
switch (_that) {
case _Challenge():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Challenge value)?  $default,){
final _that = this;
switch (_that) {
case _Challenge() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChallengeBlueprint blueprint,  String selfDisplayName,  ChallengeOrigin origin,  int authorTag,  DateTime createdAt,  ChallengeBuddySnapshot? buddy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Challenge() when $default != null:
return $default(_that.blueprint,_that.selfDisplayName,_that.origin,_that.authorTag,_that.createdAt,_that.buddy);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChallengeBlueprint blueprint,  String selfDisplayName,  ChallengeOrigin origin,  int authorTag,  DateTime createdAt,  ChallengeBuddySnapshot? buddy)  $default,) {final _that = this;
switch (_that) {
case _Challenge():
return $default(_that.blueprint,_that.selfDisplayName,_that.origin,_that.authorTag,_that.createdAt,_that.buddy);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChallengeBlueprint blueprint,  String selfDisplayName,  ChallengeOrigin origin,  int authorTag,  DateTime createdAt,  ChallengeBuddySnapshot? buddy)?  $default,) {final _that = this;
switch (_that) {
case _Challenge() when $default != null:
return $default(_that.blueprint,_that.selfDisplayName,_that.origin,_that.authorTag,_that.createdAt,_that.buddy);case _:
  return null;

}
}

}

/// @nodoc


class _Challenge extends Challenge {
  const _Challenge({required this.blueprint, required this.selfDisplayName, required this.origin, required this.authorTag, required this.createdAt, this.buddy}): super._();
  

@override final  ChallengeBlueprint blueprint;
/// The name they chose to show their buddy for this challenge. Per
/// challenge, not per account: the same person may be "Ana" to a
/// running club and something else to a sister.
@override final  String selfDisplayName;
@override final  ChallengeOrigin origin;
/// This device's 32-bit tag for this challenge, drawn at random when
/// they created or joined it and stamped into every progress code they
/// export for it.
///
/// Local, not shared identity: the two devices in a challenge hold
/// **different** tags for the same challenge, which is the entire
/// point — a pasted code whose tag equals this one is their own code
/// coming back, and importing it would overwrite their buddy's snapshot
/// with their own figure
/// (`application/challenge_code_service.dart#importProgressCode`).
///
/// It is random noise: not derived from their name, their device or
/// anything they have logged. See the privacy invariant on
/// `challenge_codes.dart`.
@override final  int authorTag;
/// UTC. When this device created or joined the challenge — local
/// metadata, not part of the shared identity.
@override final  DateTime createdAt;
/// The buddy's last pasted progress, or null if they have not pasted
/// one yet. Null is a completely normal, permanent-if-they-likes state:
/// a challenge works perfectly well with nobody exchanging progress at
/// all.
@override final  ChallengeBuddySnapshot? buddy;

/// Create a copy of Challenge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChallengeCopyWith<_Challenge> get copyWith => __$ChallengeCopyWithImpl<_Challenge>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Challenge&&(identical(other.blueprint, blueprint) || other.blueprint == blueprint)&&(identical(other.selfDisplayName, selfDisplayName) || other.selfDisplayName == selfDisplayName)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.authorTag, authorTag) || other.authorTag == authorTag)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.buddy, buddy) || other.buddy == buddy));
}


@override
int get hashCode => Object.hash(runtimeType,blueprint,selfDisplayName,origin,authorTag,createdAt,buddy);

@override
String toString() {
  return 'Challenge(blueprint: $blueprint, selfDisplayName: $selfDisplayName, origin: $origin, authorTag: $authorTag, createdAt: $createdAt, buddy: $buddy)';
}


}

/// @nodoc
abstract mixin class _$ChallengeCopyWith<$Res> implements $ChallengeCopyWith<$Res> {
  factory _$ChallengeCopyWith(_Challenge value, $Res Function(_Challenge) _then) = __$ChallengeCopyWithImpl;
@override @useResult
$Res call({
 ChallengeBlueprint blueprint, String selfDisplayName, ChallengeOrigin origin, int authorTag, DateTime createdAt, ChallengeBuddySnapshot? buddy
});


@override $ChallengeBlueprintCopyWith<$Res> get blueprint;@override $ChallengeBuddySnapshotCopyWith<$Res>? get buddy;

}
/// @nodoc
class __$ChallengeCopyWithImpl<$Res>
    implements _$ChallengeCopyWith<$Res> {
  __$ChallengeCopyWithImpl(this._self, this._then);

  final _Challenge _self;
  final $Res Function(_Challenge) _then;

/// Create a copy of Challenge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? blueprint = null,Object? selfDisplayName = null,Object? origin = null,Object? authorTag = null,Object? createdAt = null,Object? buddy = freezed,}) {
  return _then(_Challenge(
blueprint: null == blueprint ? _self.blueprint : blueprint // ignore: cast_nullable_to_non_nullable
as ChallengeBlueprint,selfDisplayName: null == selfDisplayName ? _self.selfDisplayName : selfDisplayName // ignore: cast_nullable_to_non_nullable
as String,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as ChallengeOrigin,authorTag: null == authorTag ? _self.authorTag : authorTag // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,buddy: freezed == buddy ? _self.buddy : buddy // ignore: cast_nullable_to_non_nullable
as ChallengeBuddySnapshot?,
  ));
}

/// Create a copy of Challenge
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChallengeBlueprintCopyWith<$Res> get blueprint {
  
  return $ChallengeBlueprintCopyWith<$Res>(_self.blueprint, (value) {
    return _then(_self.copyWith(blueprint: value));
  });
}/// Create a copy of Challenge
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChallengeBuddySnapshotCopyWith<$Res>? get buddy {
    if (_self.buddy == null) {
    return null;
  }

  return $ChallengeBuddySnapshotCopyWith<$Res>(_self.buddy!, (value) {
    return _then(_self.copyWith(buddy: value));
  });
}
}

/// @nodoc
mixin _$ChallengeBuddySnapshot {

/// The name they chose for themselves.
 String get displayName;/// Their progress against their own privately-adjusted target, as a
/// percentage. May exceed 100 — going past your own goal is a thing
/// that happens, and clamping it would quietly delete the best part.
 double get progressPercent;/// The day the code was exported for.
 LocalDate get asOf;
/// Create a copy of ChallengeBuddySnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChallengeBuddySnapshotCopyWith<ChallengeBuddySnapshot> get copyWith => _$ChallengeBuddySnapshotCopyWithImpl<ChallengeBuddySnapshot>(this as ChallengeBuddySnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChallengeBuddySnapshot&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.progressPercent, progressPercent) || other.progressPercent == progressPercent)&&(identical(other.asOf, asOf) || other.asOf == asOf));
}


@override
int get hashCode => Object.hash(runtimeType,displayName,progressPercent,asOf);

@override
String toString() {
  return 'ChallengeBuddySnapshot(displayName: $displayName, progressPercent: $progressPercent, asOf: $asOf)';
}


}

/// @nodoc
abstract mixin class $ChallengeBuddySnapshotCopyWith<$Res>  {
  factory $ChallengeBuddySnapshotCopyWith(ChallengeBuddySnapshot value, $Res Function(ChallengeBuddySnapshot) _then) = _$ChallengeBuddySnapshotCopyWithImpl;
@useResult
$Res call({
 String displayName, double progressPercent, LocalDate asOf
});




}
/// @nodoc
class _$ChallengeBuddySnapshotCopyWithImpl<$Res>
    implements $ChallengeBuddySnapshotCopyWith<$Res> {
  _$ChallengeBuddySnapshotCopyWithImpl(this._self, this._then);

  final ChallengeBuddySnapshot _self;
  final $Res Function(ChallengeBuddySnapshot) _then;

/// Create a copy of ChallengeBuddySnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = null,Object? progressPercent = null,Object? asOf = null,}) {
  return _then(ChallengeBuddySnapshot(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,progressPercent: null == progressPercent ? _self.progressPercent : progressPercent // ignore: cast_nullable_to_non_nullable
as double,asOf: null == asOf ? _self.asOf : asOf // ignore: cast_nullable_to_non_nullable
as LocalDate,
  ));
}

}


/// Adds pattern-matching-related methods to [ChallengeBuddySnapshot].
extension ChallengeBuddySnapshotPatterns on ChallengeBuddySnapshot {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChallengeBuddySnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChallengeBuddySnapshot() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChallengeBuddySnapshot value)  $default,){
final _that = this;
switch (_that) {
case _ChallengeBuddySnapshot():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChallengeBuddySnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _ChallengeBuddySnapshot() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String displayName,  double progressPercent,  LocalDate asOf)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChallengeBuddySnapshot() when $default != null:
return $default(_that.displayName,_that.progressPercent,_that.asOf);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String displayName,  double progressPercent,  LocalDate asOf)  $default,) {final _that = this;
switch (_that) {
case _ChallengeBuddySnapshot():
return $default(_that.displayName,_that.progressPercent,_that.asOf);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String displayName,  double progressPercent,  LocalDate asOf)?  $default,) {final _that = this;
switch (_that) {
case _ChallengeBuddySnapshot() when $default != null:
return $default(_that.displayName,_that.progressPercent,_that.asOf);case _:
  return null;

}
}

}

/// @nodoc


class _ChallengeBuddySnapshot extends ChallengeBuddySnapshot {
  const _ChallengeBuddySnapshot({required this.displayName, required this.progressPercent, required this.asOf}): super._();
  

/// The name they chose for themselves.
@override final  String displayName;
/// Their progress against their own privately-adjusted target, as a
/// percentage. May exceed 100 — going past your own goal is a thing
/// that happens, and clamping it would quietly delete the best part.
@override final  double progressPercent;
/// The day the code was exported for.
@override final  LocalDate asOf;

/// Create a copy of ChallengeBuddySnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChallengeBuddySnapshotCopyWith<_ChallengeBuddySnapshot> get copyWith => __$ChallengeBuddySnapshotCopyWithImpl<_ChallengeBuddySnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChallengeBuddySnapshot&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.progressPercent, progressPercent) || other.progressPercent == progressPercent)&&(identical(other.asOf, asOf) || other.asOf == asOf));
}


@override
int get hashCode => Object.hash(runtimeType,displayName,progressPercent,asOf);

@override
String toString() {
  return 'ChallengeBuddySnapshot(displayName: $displayName, progressPercent: $progressPercent, asOf: $asOf)';
}


}

/// @nodoc
abstract mixin class _$ChallengeBuddySnapshotCopyWith<$Res> implements $ChallengeBuddySnapshotCopyWith<$Res> {
  factory _$ChallengeBuddySnapshotCopyWith(_ChallengeBuddySnapshot value, $Res Function(_ChallengeBuddySnapshot) _then) = __$ChallengeBuddySnapshotCopyWithImpl;
@override @useResult
$Res call({
 String displayName, double progressPercent, LocalDate asOf
});




}
/// @nodoc
class __$ChallengeBuddySnapshotCopyWithImpl<$Res>
    implements _$ChallengeBuddySnapshotCopyWith<$Res> {
  __$ChallengeBuddySnapshotCopyWithImpl(this._self, this._then);

  final _ChallengeBuddySnapshot _self;
  final $Res Function(_ChallengeBuddySnapshot) _then;

/// Create a copy of ChallengeBuddySnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = null,Object? progressPercent = null,Object? asOf = null,}) {
  return _then(_ChallengeBuddySnapshot(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,progressPercent: null == progressPercent ? _self.progressPercent : progressPercent // ignore: cast_nullable_to_non_nullable
as double,asOf: null == asOf ? _self.asOf : asOf // ignore: cast_nullable_to_non_nullable
as LocalDate,
  ));
}


}

// dart format on
