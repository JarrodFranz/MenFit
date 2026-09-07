// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'personal_records.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PrEntry<T> {

 String get activityId; String get activityTitle;/// UTC.
 DateTime get startedAt; T get value;
/// Create a copy of PrEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrEntryCopyWith<T, PrEntry<T>> get copyWith => _$PrEntryCopyWithImpl<T, PrEntry<T>>(this as PrEntry<T>, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrEntry<T>&&(identical(other.activityId, activityId) || other.activityId == activityId)&&(identical(other.activityTitle, activityTitle) || other.activityTitle == activityTitle)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&const DeepCollectionEquality().equals(other.value, value));
}


@override
int get hashCode => Object.hash(runtimeType,activityId,activityTitle,startedAt,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'PrEntry<$T>(activityId: $activityId, activityTitle: $activityTitle, startedAt: $startedAt, value: $value)';
}


}

/// @nodoc
abstract mixin class $PrEntryCopyWith<T,$Res>  {
  factory $PrEntryCopyWith(PrEntry<T> value, $Res Function(PrEntry<T>) _then) = _$PrEntryCopyWithImpl;
@useResult
$Res call({
 String activityId, String activityTitle, DateTime startedAt, T value
});




}
/// @nodoc
class _$PrEntryCopyWithImpl<T,$Res>
    implements $PrEntryCopyWith<T, $Res> {
  _$PrEntryCopyWithImpl(this._self, this._then);

  final PrEntry<T> _self;
  final $Res Function(PrEntry<T>) _then;

/// Create a copy of PrEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activityId = null,Object? activityTitle = null,Object? startedAt = null,Object? value = freezed,}) {
  return _then(PrEntry(
activityId: null == activityId ? _self.activityId : activityId // ignore: cast_nullable_to_non_nullable
as String,activityTitle: null == activityTitle ? _self.activityTitle : activityTitle // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as T,
  ));
}

}


/// Adds pattern-matching-related methods to [PrEntry].
extension PrEntryPatterns<T> on PrEntry<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrEntry<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrEntry<T> value)  $default,){
final _that = this;
switch (_that) {
case _PrEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrEntry<T> value)?  $default,){
final _that = this;
switch (_that) {
case _PrEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String activityId,  String activityTitle,  DateTime startedAt,  T value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrEntry() when $default != null:
return $default(_that.activityId,_that.activityTitle,_that.startedAt,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String activityId,  String activityTitle,  DateTime startedAt,  T value)  $default,) {final _that = this;
switch (_that) {
case _PrEntry():
return $default(_that.activityId,_that.activityTitle,_that.startedAt,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String activityId,  String activityTitle,  DateTime startedAt,  T value)?  $default,) {final _that = this;
switch (_that) {
case _PrEntry() when $default != null:
return $default(_that.activityId,_that.activityTitle,_that.startedAt,_that.value);case _:
  return null;

}
}

}

/// @nodoc


class _PrEntry<T> implements PrEntry<T> {
  const _PrEntry({required this.activityId, required this.activityTitle, required this.startedAt, required this.value});
  

@override final  String activityId;
@override final  String activityTitle;
/// UTC.
@override final  DateTime startedAt;
@override final  T value;

/// Create a copy of PrEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrEntryCopyWith<T, _PrEntry<T>> get copyWith => __$PrEntryCopyWithImpl<T, _PrEntry<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrEntry<T>&&(identical(other.activityId, activityId) || other.activityId == activityId)&&(identical(other.activityTitle, activityTitle) || other.activityTitle == activityTitle)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&const DeepCollectionEquality().equals(other.value, value));
}


@override
int get hashCode => Object.hash(runtimeType,activityId,activityTitle,startedAt,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'PrEntry<$T>(activityId: $activityId, activityTitle: $activityTitle, startedAt: $startedAt, value: $value)';
}


}

/// @nodoc
abstract mixin class _$PrEntryCopyWith<T,$Res> implements $PrEntryCopyWith<T, $Res> {
  factory _$PrEntryCopyWith(_PrEntry<T> value, $Res Function(_PrEntry<T>) _then) = __$PrEntryCopyWithImpl;
@override @useResult
$Res call({
 String activityId, String activityTitle, DateTime startedAt, T value
});




}
/// @nodoc
class __$PrEntryCopyWithImpl<T,$Res>
    implements _$PrEntryCopyWith<T, $Res> {
  __$PrEntryCopyWithImpl(this._self, this._then);

  final _PrEntry<T> _self;
  final $Res Function(_PrEntry<T>) _then;

/// Create a copy of PrEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activityId = null,Object? activityTitle = null,Object? startedAt = null,Object? value = freezed,}) {
  return _then(_PrEntry<T>(
activityId: null == activityId ? _self.activityId : activityId // ignore: cast_nullable_to_non_nullable
as String,activityTitle: null == activityTitle ? _self.activityTitle : activityTitle // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc
mixin _$PersonalRecords {

/// Fastest [PrEntry] per `standardEffortDistances` target (metres) that
/// at least one activity's samples cover. Distances no activity has
/// reached yet are simply absent from the map.
 Map<double, PrEntry<Duration>> get bestEfforts; PrEntry<double>? get longestDistance; PrEntry<double>? get mostElevationGain;
/// Create a copy of PersonalRecords
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonalRecordsCopyWith<PersonalRecords> get copyWith => _$PersonalRecordsCopyWithImpl<PersonalRecords>(this as PersonalRecords, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonalRecords&&const DeepCollectionEquality().equals(other.bestEfforts, bestEfforts)&&(identical(other.longestDistance, longestDistance) || other.longestDistance == longestDistance)&&(identical(other.mostElevationGain, mostElevationGain) || other.mostElevationGain == mostElevationGain));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bestEfforts),longestDistance,mostElevationGain);

@override
String toString() {
  return 'PersonalRecords(bestEfforts: $bestEfforts, longestDistance: $longestDistance, mostElevationGain: $mostElevationGain)';
}


}

/// @nodoc
abstract mixin class $PersonalRecordsCopyWith<$Res>  {
  factory $PersonalRecordsCopyWith(PersonalRecords value, $Res Function(PersonalRecords) _then) = _$PersonalRecordsCopyWithImpl;
@useResult
$Res call({
 Map<double, PrEntry<Duration>> bestEfforts, PrEntry<double>? longestDistance, PrEntry<double>? mostElevationGain
});


$PrEntryCopyWith<double, $Res>? get longestDistance;$PrEntryCopyWith<double, $Res>? get mostElevationGain;

}
/// @nodoc
class _$PersonalRecordsCopyWithImpl<$Res>
    implements $PersonalRecordsCopyWith<$Res> {
  _$PersonalRecordsCopyWithImpl(this._self, this._then);

  final PersonalRecords _self;
  final $Res Function(PersonalRecords) _then;

/// Create a copy of PersonalRecords
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bestEfforts = null,Object? longestDistance = freezed,Object? mostElevationGain = freezed,}) {
  return _then(PersonalRecords(
bestEfforts: null == bestEfforts ? _self.bestEfforts : bestEfforts // ignore: cast_nullable_to_non_nullable
as Map<double, PrEntry<Duration>>,longestDistance: freezed == longestDistance ? _self.longestDistance : longestDistance // ignore: cast_nullable_to_non_nullable
as PrEntry<double>?,mostElevationGain: freezed == mostElevationGain ? _self.mostElevationGain : mostElevationGain // ignore: cast_nullable_to_non_nullable
as PrEntry<double>?,
  ));
}
/// Create a copy of PersonalRecords
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PrEntryCopyWith<double, $Res>? get longestDistance {
    if (_self.longestDistance == null) {
    return null;
  }

  return $PrEntryCopyWith<double, $Res>(_self.longestDistance!, (value) {
    return _then(_self.copyWith(longestDistance: value));
  });
}/// Create a copy of PersonalRecords
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PrEntryCopyWith<double, $Res>? get mostElevationGain {
    if (_self.mostElevationGain == null) {
    return null;
  }

  return $PrEntryCopyWith<double, $Res>(_self.mostElevationGain!, (value) {
    return _then(_self.copyWith(mostElevationGain: value));
  });
}
}


/// Adds pattern-matching-related methods to [PersonalRecords].
extension PersonalRecordsPatterns on PersonalRecords {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonalRecords value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonalRecords() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonalRecords value)  $default,){
final _that = this;
switch (_that) {
case _PersonalRecords():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonalRecords value)?  $default,){
final _that = this;
switch (_that) {
case _PersonalRecords() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<double, PrEntry<Duration>> bestEfforts,  PrEntry<double>? longestDistance,  PrEntry<double>? mostElevationGain)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonalRecords() when $default != null:
return $default(_that.bestEfforts,_that.longestDistance,_that.mostElevationGain);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<double, PrEntry<Duration>> bestEfforts,  PrEntry<double>? longestDistance,  PrEntry<double>? mostElevationGain)  $default,) {final _that = this;
switch (_that) {
case _PersonalRecords():
return $default(_that.bestEfforts,_that.longestDistance,_that.mostElevationGain);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<double, PrEntry<Duration>> bestEfforts,  PrEntry<double>? longestDistance,  PrEntry<double>? mostElevationGain)?  $default,) {final _that = this;
switch (_that) {
case _PersonalRecords() when $default != null:
return $default(_that.bestEfforts,_that.longestDistance,_that.mostElevationGain);case _:
  return null;

}
}

}

/// @nodoc


class _PersonalRecords implements PersonalRecords {
  const _PersonalRecords({required  Map<double, PrEntry<Duration>> bestEfforts, this.longestDistance, this.mostElevationGain}): _bestEfforts = bestEfforts;
  

/// Fastest [PrEntry] per `standardEffortDistances` target (metres) that
/// at least one activity's samples cover. Distances no activity has
/// reached yet are simply absent from the map.
 final  Map<double, PrEntry<Duration>> _bestEfforts;
/// Fastest [PrEntry] per `standardEffortDistances` target (metres) that
/// at least one activity's samples cover. Distances no activity has
/// reached yet are simply absent from the map.
@override Map<double, PrEntry<Duration>> get bestEfforts {
  if (_bestEfforts is EqualUnmodifiableMapView) return _bestEfforts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_bestEfforts);
}

@override final  PrEntry<double>? longestDistance;
@override final  PrEntry<double>? mostElevationGain;

/// Create a copy of PersonalRecords
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonalRecordsCopyWith<_PersonalRecords> get copyWith => __$PersonalRecordsCopyWithImpl<_PersonalRecords>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonalRecords&&const DeepCollectionEquality().equals(other._bestEfforts, _bestEfforts)&&(identical(other.longestDistance, longestDistance) || other.longestDistance == longestDistance)&&(identical(other.mostElevationGain, mostElevationGain) || other.mostElevationGain == mostElevationGain));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_bestEfforts),longestDistance,mostElevationGain);

@override
String toString() {
  return 'PersonalRecords(bestEfforts: $bestEfforts, longestDistance: $longestDistance, mostElevationGain: $mostElevationGain)';
}


}

/// @nodoc
abstract mixin class _$PersonalRecordsCopyWith<$Res> implements $PersonalRecordsCopyWith<$Res> {
  factory _$PersonalRecordsCopyWith(_PersonalRecords value, $Res Function(_PersonalRecords) _then) = __$PersonalRecordsCopyWithImpl;
@override @useResult
$Res call({
 Map<double, PrEntry<Duration>> bestEfforts, PrEntry<double>? longestDistance, PrEntry<double>? mostElevationGain
});


@override $PrEntryCopyWith<double, $Res>? get longestDistance;@override $PrEntryCopyWith<double, $Res>? get mostElevationGain;

}
/// @nodoc
class __$PersonalRecordsCopyWithImpl<$Res>
    implements _$PersonalRecordsCopyWith<$Res> {
  __$PersonalRecordsCopyWithImpl(this._self, this._then);

  final _PersonalRecords _self;
  final $Res Function(_PersonalRecords) _then;

/// Create a copy of PersonalRecords
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bestEfforts = null,Object? longestDistance = freezed,Object? mostElevationGain = freezed,}) {
  return _then(_PersonalRecords(
bestEfforts: null == bestEfforts ? _self._bestEfforts : bestEfforts // ignore: cast_nullable_to_non_nullable
as Map<double, PrEntry<Duration>>,longestDistance: freezed == longestDistance ? _self.longestDistance : longestDistance // ignore: cast_nullable_to_non_nullable
as PrEntry<double>?,mostElevationGain: freezed == mostElevationGain ? _self.mostElevationGain : mostElevationGain // ignore: cast_nullable_to_non_nullable
as PrEntry<double>?,
  ));
}

/// Create a copy of PersonalRecords
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PrEntryCopyWith<double, $Res>? get longestDistance {
    if (_self.longestDistance == null) {
    return null;
  }

  return $PrEntryCopyWith<double, $Res>(_self.longestDistance!, (value) {
    return _then(_self.copyWith(longestDistance: value));
  });
}/// Create a copy of PersonalRecords
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PrEntryCopyWith<double, $Res>? get mostElevationGain {
    if (_self.mostElevationGain == null) {
    return null;
  }

  return $PrEntryCopyWith<double, $Res>(_self.mostElevationGain!, (value) {
    return _then(_self.copyWith(mostElevationGain: value));
  });
}
}

// dart format on
