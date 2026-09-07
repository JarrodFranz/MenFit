// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track_analysis.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Split {

/// 1-based position among the activity's splits.
 int get index;/// The distance this split covers, in metres. Equal to the
/// `splitMeters` argument [computeSplits] was called with, except for a
/// trailing partial split, whose [distanceMeters] is whatever remained.
 double get distanceMeters;/// Time to cover [distanceMeters] while actually moving - a split that
/// spans a paused stretch (see library doc) excludes the paused time
/// entirely, the same way `RecordingSession.movingTime` does. Boundary
/// crossings within a segment are linearly interpolated between the two
/// straddling samples (never snapped to a sample timestamp).
 Duration get duration;/// Average pace over this split, seconds per kilometre. Always
/// well-defined since [distanceMeters] is always positive for any
/// [Split] this file produces.
 double get paceSecondsPerKm;/// End elevation minus start elevation of this split, in metres.
/// `null` when either boundary sample lacks elevation data.
 double? get elevationDeltaMeters;
/// Create a copy of Split
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SplitCopyWith<Split> get copyWith => _$SplitCopyWithImpl<Split>(this as Split, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Split&&(identical(other.index, index) || other.index == index)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.paceSecondsPerKm, paceSecondsPerKm) || other.paceSecondsPerKm == paceSecondsPerKm)&&(identical(other.elevationDeltaMeters, elevationDeltaMeters) || other.elevationDeltaMeters == elevationDeltaMeters));
}


@override
int get hashCode => Object.hash(runtimeType,index,distanceMeters,duration,paceSecondsPerKm,elevationDeltaMeters);

@override
String toString() {
  return 'Split(index: $index, distanceMeters: $distanceMeters, duration: $duration, paceSecondsPerKm: $paceSecondsPerKm, elevationDeltaMeters: $elevationDeltaMeters)';
}


}

/// @nodoc
abstract mixin class $SplitCopyWith<$Res>  {
  factory $SplitCopyWith(Split value, $Res Function(Split) _then) = _$SplitCopyWithImpl;
@useResult
$Res call({
 int index, double distanceMeters, Duration duration, double paceSecondsPerKm, double? elevationDeltaMeters
});




}
/// @nodoc
class _$SplitCopyWithImpl<$Res>
    implements $SplitCopyWith<$Res> {
  _$SplitCopyWithImpl(this._self, this._then);

  final Split _self;
  final $Res Function(Split) _then;

/// Create a copy of Split
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = null,Object? distanceMeters = null,Object? duration = null,Object? paceSecondsPerKm = null,Object? elevationDeltaMeters = freezed,}) {
  return _then(Split(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,paceSecondsPerKm: null == paceSecondsPerKm ? _self.paceSecondsPerKm : paceSecondsPerKm // ignore: cast_nullable_to_non_nullable
as double,elevationDeltaMeters: freezed == elevationDeltaMeters ? _self.elevationDeltaMeters : elevationDeltaMeters // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [Split].
extension SplitPatterns on Split {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Split value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Split() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Split value)  $default,){
final _that = this;
switch (_that) {
case _Split():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Split value)?  $default,){
final _that = this;
switch (_that) {
case _Split() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int index,  double distanceMeters,  Duration duration,  double paceSecondsPerKm,  double? elevationDeltaMeters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Split() when $default != null:
return $default(_that.index,_that.distanceMeters,_that.duration,_that.paceSecondsPerKm,_that.elevationDeltaMeters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int index,  double distanceMeters,  Duration duration,  double paceSecondsPerKm,  double? elevationDeltaMeters)  $default,) {final _that = this;
switch (_that) {
case _Split():
return $default(_that.index,_that.distanceMeters,_that.duration,_that.paceSecondsPerKm,_that.elevationDeltaMeters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int index,  double distanceMeters,  Duration duration,  double paceSecondsPerKm,  double? elevationDeltaMeters)?  $default,) {final _that = this;
switch (_that) {
case _Split() when $default != null:
return $default(_that.index,_that.distanceMeters,_that.duration,_that.paceSecondsPerKm,_that.elevationDeltaMeters);case _:
  return null;

}
}

}

/// @nodoc


class _Split implements Split {
  const _Split({required this.index, required this.distanceMeters, required this.duration, required this.paceSecondsPerKm, this.elevationDeltaMeters});
  

/// 1-based position among the activity's splits.
@override final  int index;
/// The distance this split covers, in metres. Equal to the
/// `splitMeters` argument [computeSplits] was called with, except for a
/// trailing partial split, whose [distanceMeters] is whatever remained.
@override final  double distanceMeters;
/// Time to cover [distanceMeters] while actually moving - a split that
/// spans a paused stretch (see library doc) excludes the paused time
/// entirely, the same way `RecordingSession.movingTime` does. Boundary
/// crossings within a segment are linearly interpolated between the two
/// straddling samples (never snapped to a sample timestamp).
@override final  Duration duration;
/// Average pace over this split, seconds per kilometre. Always
/// well-defined since [distanceMeters] is always positive for any
/// [Split] this file produces.
@override final  double paceSecondsPerKm;
/// End elevation minus start elevation of this split, in metres.
/// `null` when either boundary sample lacks elevation data.
@override final  double? elevationDeltaMeters;

/// Create a copy of Split
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SplitCopyWith<_Split> get copyWith => __$SplitCopyWithImpl<_Split>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Split&&(identical(other.index, index) || other.index == index)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.paceSecondsPerKm, paceSecondsPerKm) || other.paceSecondsPerKm == paceSecondsPerKm)&&(identical(other.elevationDeltaMeters, elevationDeltaMeters) || other.elevationDeltaMeters == elevationDeltaMeters));
}


@override
int get hashCode => Object.hash(runtimeType,index,distanceMeters,duration,paceSecondsPerKm,elevationDeltaMeters);

@override
String toString() {
  return 'Split(index: $index, distanceMeters: $distanceMeters, duration: $duration, paceSecondsPerKm: $paceSecondsPerKm, elevationDeltaMeters: $elevationDeltaMeters)';
}


}

/// @nodoc
abstract mixin class _$SplitCopyWith<$Res> implements $SplitCopyWith<$Res> {
  factory _$SplitCopyWith(_Split value, $Res Function(_Split) _then) = __$SplitCopyWithImpl;
@override @useResult
$Res call({
 int index, double distanceMeters, Duration duration, double paceSecondsPerKm, double? elevationDeltaMeters
});




}
/// @nodoc
class __$SplitCopyWithImpl<$Res>
    implements _$SplitCopyWith<$Res> {
  __$SplitCopyWithImpl(this._self, this._then);

  final _Split _self;
  final $Res Function(_Split) _then;

/// Create a copy of Split
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = null,Object? distanceMeters = null,Object? duration = null,Object? paceSecondsPerKm = null,Object? elevationDeltaMeters = freezed,}) {
  return _then(_Split(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,paceSecondsPerKm: null == paceSecondsPerKm ? _self.paceSecondsPerKm : paceSecondsPerKm // ignore: cast_nullable_to_non_nullable
as double,elevationDeltaMeters: freezed == elevationDeltaMeters ? _self.elevationDeltaMeters : elevationDeltaMeters // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc
mixin _$BestEffort {

/// The distance this effort was scanned for, in metres.
 double get targetMeters;/// Minimal time to cover [targetMeters] anywhere in a single segment of
/// the track (see library doc - a window never spans a pause).
 Duration get duration;/// Average pace over the window, seconds per kilometre.
 double get paceSecondsPerKm;/// How far into the activity (cumulative *moving* track distance, in
/// metres - paused stretches add nothing) this window begins.
 double get startOffsetMeters;
/// Create a copy of BestEffort
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BestEffortCopyWith<BestEffort> get copyWith => _$BestEffortCopyWithImpl<BestEffort>(this as BestEffort, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BestEffort&&(identical(other.targetMeters, targetMeters) || other.targetMeters == targetMeters)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.paceSecondsPerKm, paceSecondsPerKm) || other.paceSecondsPerKm == paceSecondsPerKm)&&(identical(other.startOffsetMeters, startOffsetMeters) || other.startOffsetMeters == startOffsetMeters));
}


@override
int get hashCode => Object.hash(runtimeType,targetMeters,duration,paceSecondsPerKm,startOffsetMeters);

@override
String toString() {
  return 'BestEffort(targetMeters: $targetMeters, duration: $duration, paceSecondsPerKm: $paceSecondsPerKm, startOffsetMeters: $startOffsetMeters)';
}


}

/// @nodoc
abstract mixin class $BestEffortCopyWith<$Res>  {
  factory $BestEffortCopyWith(BestEffort value, $Res Function(BestEffort) _then) = _$BestEffortCopyWithImpl;
@useResult
$Res call({
 double targetMeters, Duration duration, double paceSecondsPerKm, double startOffsetMeters
});




}
/// @nodoc
class _$BestEffortCopyWithImpl<$Res>
    implements $BestEffortCopyWith<$Res> {
  _$BestEffortCopyWithImpl(this._self, this._then);

  final BestEffort _self;
  final $Res Function(BestEffort) _then;

/// Create a copy of BestEffort
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targetMeters = null,Object? duration = null,Object? paceSecondsPerKm = null,Object? startOffsetMeters = null,}) {
  return _then(BestEffort(
targetMeters: null == targetMeters ? _self.targetMeters : targetMeters // ignore: cast_nullable_to_non_nullable
as double,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,paceSecondsPerKm: null == paceSecondsPerKm ? _self.paceSecondsPerKm : paceSecondsPerKm // ignore: cast_nullable_to_non_nullable
as double,startOffsetMeters: null == startOffsetMeters ? _self.startOffsetMeters : startOffsetMeters // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [BestEffort].
extension BestEffortPatterns on BestEffort {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BestEffort value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BestEffort() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BestEffort value)  $default,){
final _that = this;
switch (_that) {
case _BestEffort():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BestEffort value)?  $default,){
final _that = this;
switch (_that) {
case _BestEffort() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double targetMeters,  Duration duration,  double paceSecondsPerKm,  double startOffsetMeters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BestEffort() when $default != null:
return $default(_that.targetMeters,_that.duration,_that.paceSecondsPerKm,_that.startOffsetMeters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double targetMeters,  Duration duration,  double paceSecondsPerKm,  double startOffsetMeters)  $default,) {final _that = this;
switch (_that) {
case _BestEffort():
return $default(_that.targetMeters,_that.duration,_that.paceSecondsPerKm,_that.startOffsetMeters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double targetMeters,  Duration duration,  double paceSecondsPerKm,  double startOffsetMeters)?  $default,) {final _that = this;
switch (_that) {
case _BestEffort() when $default != null:
return $default(_that.targetMeters,_that.duration,_that.paceSecondsPerKm,_that.startOffsetMeters);case _:
  return null;

}
}

}

/// @nodoc


class _BestEffort implements BestEffort {
  const _BestEffort({required this.targetMeters, required this.duration, required this.paceSecondsPerKm, required this.startOffsetMeters});
  

/// The distance this effort was scanned for, in metres.
@override final  double targetMeters;
/// Minimal time to cover [targetMeters] anywhere in a single segment of
/// the track (see library doc - a window never spans a pause).
@override final  Duration duration;
/// Average pace over the window, seconds per kilometre.
@override final  double paceSecondsPerKm;
/// How far into the activity (cumulative *moving* track distance, in
/// metres - paused stretches add nothing) this window begins.
@override final  double startOffsetMeters;

/// Create a copy of BestEffort
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BestEffortCopyWith<_BestEffort> get copyWith => __$BestEffortCopyWithImpl<_BestEffort>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BestEffort&&(identical(other.targetMeters, targetMeters) || other.targetMeters == targetMeters)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.paceSecondsPerKm, paceSecondsPerKm) || other.paceSecondsPerKm == paceSecondsPerKm)&&(identical(other.startOffsetMeters, startOffsetMeters) || other.startOffsetMeters == startOffsetMeters));
}


@override
int get hashCode => Object.hash(runtimeType,targetMeters,duration,paceSecondsPerKm,startOffsetMeters);

@override
String toString() {
  return 'BestEffort(targetMeters: $targetMeters, duration: $duration, paceSecondsPerKm: $paceSecondsPerKm, startOffsetMeters: $startOffsetMeters)';
}


}

/// @nodoc
abstract mixin class _$BestEffortCopyWith<$Res> implements $BestEffortCopyWith<$Res> {
  factory _$BestEffortCopyWith(_BestEffort value, $Res Function(_BestEffort) _then) = __$BestEffortCopyWithImpl;
@override @useResult
$Res call({
 double targetMeters, Duration duration, double paceSecondsPerKm, double startOffsetMeters
});




}
/// @nodoc
class __$BestEffortCopyWithImpl<$Res>
    implements _$BestEffortCopyWith<$Res> {
  __$BestEffortCopyWithImpl(this._self, this._then);

  final _BestEffort _self;
  final $Res Function(_BestEffort) _then;

/// Create a copy of BestEffort
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targetMeters = null,Object? duration = null,Object? paceSecondsPerKm = null,Object? startOffsetMeters = null,}) {
  return _then(_BestEffort(
targetMeters: null == targetMeters ? _self.targetMeters : targetMeters // ignore: cast_nullable_to_non_nullable
as double,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,paceSecondsPerKm: null == paceSecondsPerKm ? _self.paceSecondsPerKm : paceSecondsPerKm // ignore: cast_nullable_to_non_nullable
as double,startOffsetMeters: null == startOffsetMeters ? _self.startOffsetMeters : startOffsetMeters // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
