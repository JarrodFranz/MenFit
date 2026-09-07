// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'suggested_route.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SuggestedRoute {

/// The route's polyline, in travel order. Round trips start and end at
/// (approximately) the requested start point.
 List<GeoPoint> get points;/// Actual route length in metres (the service targets, but rarely
/// exactly hits, the requested distance).
 double get distanceMeters;/// Service-estimated travel time, when provided.
 Duration? get estimatedDuration;/// Total climb in metres, when the service returned elevation data.
 double? get ascentMeters;/// Total descent in metres, when the service returned elevation data.
 double? get descentMeters;
/// Create a copy of SuggestedRoute
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuggestedRouteCopyWith<SuggestedRoute> get copyWith => _$SuggestedRouteCopyWithImpl<SuggestedRoute>(this as SuggestedRoute, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SuggestedRoute&&const DeepCollectionEquality().equals(other.points, points)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.estimatedDuration, estimatedDuration) || other.estimatedDuration == estimatedDuration)&&(identical(other.ascentMeters, ascentMeters) || other.ascentMeters == ascentMeters)&&(identical(other.descentMeters, descentMeters) || other.descentMeters == descentMeters));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(points),distanceMeters,estimatedDuration,ascentMeters,descentMeters);

@override
String toString() {
  return 'SuggestedRoute(points: $points, distanceMeters: $distanceMeters, estimatedDuration: $estimatedDuration, ascentMeters: $ascentMeters, descentMeters: $descentMeters)';
}


}

/// @nodoc
abstract mixin class $SuggestedRouteCopyWith<$Res>  {
  factory $SuggestedRouteCopyWith(SuggestedRoute value, $Res Function(SuggestedRoute) _then) = _$SuggestedRouteCopyWithImpl;
@useResult
$Res call({
 List<GeoPoint> points, double distanceMeters, Duration? estimatedDuration, double? ascentMeters, double? descentMeters
});




}
/// @nodoc
class _$SuggestedRouteCopyWithImpl<$Res>
    implements $SuggestedRouteCopyWith<$Res> {
  _$SuggestedRouteCopyWithImpl(this._self, this._then);

  final SuggestedRoute _self;
  final $Res Function(SuggestedRoute) _then;

/// Create a copy of SuggestedRoute
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? points = null,Object? distanceMeters = null,Object? estimatedDuration = freezed,Object? ascentMeters = freezed,Object? descentMeters = freezed,}) {
  return _then(SuggestedRoute(
points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<GeoPoint>,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,estimatedDuration: freezed == estimatedDuration ? _self.estimatedDuration : estimatedDuration // ignore: cast_nullable_to_non_nullable
as Duration?,ascentMeters: freezed == ascentMeters ? _self.ascentMeters : ascentMeters // ignore: cast_nullable_to_non_nullable
as double?,descentMeters: freezed == descentMeters ? _self.descentMeters : descentMeters // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [SuggestedRoute].
extension SuggestedRoutePatterns on SuggestedRoute {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SuggestedRoute value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SuggestedRoute() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SuggestedRoute value)  $default,){
final _that = this;
switch (_that) {
case _SuggestedRoute():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SuggestedRoute value)?  $default,){
final _that = this;
switch (_that) {
case _SuggestedRoute() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<GeoPoint> points,  double distanceMeters,  Duration? estimatedDuration,  double? ascentMeters,  double? descentMeters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SuggestedRoute() when $default != null:
return $default(_that.points,_that.distanceMeters,_that.estimatedDuration,_that.ascentMeters,_that.descentMeters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<GeoPoint> points,  double distanceMeters,  Duration? estimatedDuration,  double? ascentMeters,  double? descentMeters)  $default,) {final _that = this;
switch (_that) {
case _SuggestedRoute():
return $default(_that.points,_that.distanceMeters,_that.estimatedDuration,_that.ascentMeters,_that.descentMeters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<GeoPoint> points,  double distanceMeters,  Duration? estimatedDuration,  double? ascentMeters,  double? descentMeters)?  $default,) {final _that = this;
switch (_that) {
case _SuggestedRoute() when $default != null:
return $default(_that.points,_that.distanceMeters,_that.estimatedDuration,_that.ascentMeters,_that.descentMeters);case _:
  return null;

}
}

}

/// @nodoc


class _SuggestedRoute implements SuggestedRoute {
  const _SuggestedRoute({required  List<GeoPoint> points, required this.distanceMeters, this.estimatedDuration, this.ascentMeters, this.descentMeters}): _points = points;
  

/// The route's polyline, in travel order. Round trips start and end at
/// (approximately) the requested start point.
 final  List<GeoPoint> _points;
/// The route's polyline, in travel order. Round trips start and end at
/// (approximately) the requested start point.
@override List<GeoPoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

/// Actual route length in metres (the service targets, but rarely
/// exactly hits, the requested distance).
@override final  double distanceMeters;
/// Service-estimated travel time, when provided.
@override final  Duration? estimatedDuration;
/// Total climb in metres, when the service returned elevation data.
@override final  double? ascentMeters;
/// Total descent in metres, when the service returned elevation data.
@override final  double? descentMeters;

/// Create a copy of SuggestedRoute
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuggestedRouteCopyWith<_SuggestedRoute> get copyWith => __$SuggestedRouteCopyWithImpl<_SuggestedRoute>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SuggestedRoute&&const DeepCollectionEquality().equals(other._points, _points)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.estimatedDuration, estimatedDuration) || other.estimatedDuration == estimatedDuration)&&(identical(other.ascentMeters, ascentMeters) || other.ascentMeters == ascentMeters)&&(identical(other.descentMeters, descentMeters) || other.descentMeters == descentMeters));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_points),distanceMeters,estimatedDuration,ascentMeters,descentMeters);

@override
String toString() {
  return 'SuggestedRoute(points: $points, distanceMeters: $distanceMeters, estimatedDuration: $estimatedDuration, ascentMeters: $ascentMeters, descentMeters: $descentMeters)';
}


}

/// @nodoc
abstract mixin class _$SuggestedRouteCopyWith<$Res> implements $SuggestedRouteCopyWith<$Res> {
  factory _$SuggestedRouteCopyWith(_SuggestedRoute value, $Res Function(_SuggestedRoute) _then) = __$SuggestedRouteCopyWithImpl;
@override @useResult
$Res call({
 List<GeoPoint> points, double distanceMeters, Duration? estimatedDuration, double? ascentMeters, double? descentMeters
});




}
/// @nodoc
class __$SuggestedRouteCopyWithImpl<$Res>
    implements _$SuggestedRouteCopyWith<$Res> {
  __$SuggestedRouteCopyWithImpl(this._self, this._then);

  final _SuggestedRoute _self;
  final $Res Function(_SuggestedRoute) _then;

/// Create a copy of SuggestedRoute
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? points = null,Object? distanceMeters = null,Object? estimatedDuration = freezed,Object? ascentMeters = freezed,Object? descentMeters = freezed,}) {
  return _then(_SuggestedRoute(
points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<GeoPoint>,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,estimatedDuration: freezed == estimatedDuration ? _self.estimatedDuration : estimatedDuration // ignore: cast_nullable_to_non_nullable
as Duration?,ascentMeters: freezed == ascentMeters ? _self.ascentMeters : ascentMeters // ignore: cast_nullable_to_non_nullable
as double?,descentMeters: freezed == descentMeters ? _self.descentMeters : descentMeters // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
