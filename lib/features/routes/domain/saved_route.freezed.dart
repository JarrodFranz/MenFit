// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_route.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SavedRoute {

 String get id; String get name; ActivityType get activityType; double get distanceMeters;/// The route's polyline, in travel order.
 List<GeoPoint> get points; RouteSource get source;/// UTC.
 DateTime get createdAt;/// UTC.
 DateTime get updatedAt; Duration? get estimatedDuration;/// Total climb in metres, when the source provided elevation data.
 double? get ascentMeters;/// Total descent in metres, when the source provided elevation data.
/// A closed loop's descent is close to — but rarely exactly — its
/// ascent, so it's stored rather than derived.
 double? get descentMeters;
/// Create a copy of SavedRoute
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedRouteCopyWith<SavedRoute> get copyWith => _$SavedRouteCopyWithImpl<SavedRoute>(this as SavedRoute, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedRoute&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&const DeepCollectionEquality().equals(other.points, points)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.estimatedDuration, estimatedDuration) || other.estimatedDuration == estimatedDuration)&&(identical(other.ascentMeters, ascentMeters) || other.ascentMeters == ascentMeters)&&(identical(other.descentMeters, descentMeters) || other.descentMeters == descentMeters));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,activityType,distanceMeters,const DeepCollectionEquality().hash(points),source,createdAt,updatedAt,estimatedDuration,ascentMeters,descentMeters);

@override
String toString() {
  return 'SavedRoute(id: $id, name: $name, activityType: $activityType, distanceMeters: $distanceMeters, points: $points, source: $source, createdAt: $createdAt, updatedAt: $updatedAt, estimatedDuration: $estimatedDuration, ascentMeters: $ascentMeters, descentMeters: $descentMeters)';
}


}

/// @nodoc
abstract mixin class $SavedRouteCopyWith<$Res>  {
  factory $SavedRouteCopyWith(SavedRoute value, $Res Function(SavedRoute) _then) = _$SavedRouteCopyWithImpl;
@useResult
$Res call({
 String id, String name, ActivityType activityType, double distanceMeters, List<GeoPoint> points, RouteSource source, DateTime createdAt, DateTime updatedAt, Duration? estimatedDuration, double? ascentMeters, double? descentMeters
});




}
/// @nodoc
class _$SavedRouteCopyWithImpl<$Res>
    implements $SavedRouteCopyWith<$Res> {
  _$SavedRouteCopyWithImpl(this._self, this._then);

  final SavedRoute _self;
  final $Res Function(SavedRoute) _then;

/// Create a copy of SavedRoute
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? activityType = null,Object? distanceMeters = null,Object? points = null,Object? source = null,Object? createdAt = null,Object? updatedAt = null,Object? estimatedDuration = freezed,Object? ascentMeters = freezed,Object? descentMeters = freezed,}) {
  return _then(SavedRoute(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as ActivityType,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<GeoPoint>,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as RouteSource,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,estimatedDuration: freezed == estimatedDuration ? _self.estimatedDuration : estimatedDuration // ignore: cast_nullable_to_non_nullable
as Duration?,ascentMeters: freezed == ascentMeters ? _self.ascentMeters : ascentMeters // ignore: cast_nullable_to_non_nullable
as double?,descentMeters: freezed == descentMeters ? _self.descentMeters : descentMeters // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedRoute].
extension SavedRoutePatterns on SavedRoute {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedRoute value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedRoute() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedRoute value)  $default,){
final _that = this;
switch (_that) {
case _SavedRoute():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedRoute value)?  $default,){
final _that = this;
switch (_that) {
case _SavedRoute() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  ActivityType activityType,  double distanceMeters,  List<GeoPoint> points,  RouteSource source,  DateTime createdAt,  DateTime updatedAt,  Duration? estimatedDuration,  double? ascentMeters,  double? descentMeters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedRoute() when $default != null:
return $default(_that.id,_that.name,_that.activityType,_that.distanceMeters,_that.points,_that.source,_that.createdAt,_that.updatedAt,_that.estimatedDuration,_that.ascentMeters,_that.descentMeters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  ActivityType activityType,  double distanceMeters,  List<GeoPoint> points,  RouteSource source,  DateTime createdAt,  DateTime updatedAt,  Duration? estimatedDuration,  double? ascentMeters,  double? descentMeters)  $default,) {final _that = this;
switch (_that) {
case _SavedRoute():
return $default(_that.id,_that.name,_that.activityType,_that.distanceMeters,_that.points,_that.source,_that.createdAt,_that.updatedAt,_that.estimatedDuration,_that.ascentMeters,_that.descentMeters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  ActivityType activityType,  double distanceMeters,  List<GeoPoint> points,  RouteSource source,  DateTime createdAt,  DateTime updatedAt,  Duration? estimatedDuration,  double? ascentMeters,  double? descentMeters)?  $default,) {final _that = this;
switch (_that) {
case _SavedRoute() when $default != null:
return $default(_that.id,_that.name,_that.activityType,_that.distanceMeters,_that.points,_that.source,_that.createdAt,_that.updatedAt,_that.estimatedDuration,_that.ascentMeters,_that.descentMeters);case _:
  return null;

}
}

}

/// @nodoc


class _SavedRoute implements SavedRoute {
  const _SavedRoute({required this.id, required this.name, required this.activityType, required this.distanceMeters, required  List<GeoPoint> points, required this.source, required this.createdAt, required this.updatedAt, this.estimatedDuration, this.ascentMeters, this.descentMeters}): _points = points;
  

@override final  String id;
@override final  String name;
@override final  ActivityType activityType;
@override final  double distanceMeters;
/// The route's polyline, in travel order.
 final  List<GeoPoint> _points;
/// The route's polyline, in travel order.
@override List<GeoPoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

@override final  RouteSource source;
/// UTC.
@override final  DateTime createdAt;
/// UTC.
@override final  DateTime updatedAt;
@override final  Duration? estimatedDuration;
/// Total climb in metres, when the source provided elevation data.
@override final  double? ascentMeters;
/// Total descent in metres, when the source provided elevation data.
/// A closed loop's descent is close to — but rarely exactly — its
/// ascent, so it's stored rather than derived.
@override final  double? descentMeters;

/// Create a copy of SavedRoute
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedRouteCopyWith<_SavedRoute> get copyWith => __$SavedRouteCopyWithImpl<_SavedRoute>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedRoute&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&const DeepCollectionEquality().equals(other._points, _points)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.estimatedDuration, estimatedDuration) || other.estimatedDuration == estimatedDuration)&&(identical(other.ascentMeters, ascentMeters) || other.ascentMeters == ascentMeters)&&(identical(other.descentMeters, descentMeters) || other.descentMeters == descentMeters));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,activityType,distanceMeters,const DeepCollectionEquality().hash(_points),source,createdAt,updatedAt,estimatedDuration,ascentMeters,descentMeters);

@override
String toString() {
  return 'SavedRoute(id: $id, name: $name, activityType: $activityType, distanceMeters: $distanceMeters, points: $points, source: $source, createdAt: $createdAt, updatedAt: $updatedAt, estimatedDuration: $estimatedDuration, ascentMeters: $ascentMeters, descentMeters: $descentMeters)';
}


}

/// @nodoc
abstract mixin class _$SavedRouteCopyWith<$Res> implements $SavedRouteCopyWith<$Res> {
  factory _$SavedRouteCopyWith(_SavedRoute value, $Res Function(_SavedRoute) _then) = __$SavedRouteCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, ActivityType activityType, double distanceMeters, List<GeoPoint> points, RouteSource source, DateTime createdAt, DateTime updatedAt, Duration? estimatedDuration, double? ascentMeters, double? descentMeters
});




}
/// @nodoc
class __$SavedRouteCopyWithImpl<$Res>
    implements _$SavedRouteCopyWith<$Res> {
  __$SavedRouteCopyWithImpl(this._self, this._then);

  final _SavedRoute _self;
  final $Res Function(_SavedRoute) _then;

/// Create a copy of SavedRoute
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? activityType = null,Object? distanceMeters = null,Object? points = null,Object? source = null,Object? createdAt = null,Object? updatedAt = null,Object? estimatedDuration = freezed,Object? ascentMeters = freezed,Object? descentMeters = freezed,}) {
  return _then(_SavedRoute(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as ActivityType,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<GeoPoint>,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as RouteSource,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,estimatedDuration: freezed == estimatedDuration ? _self.estimatedDuration : estimatedDuration // ignore: cast_nullable_to_non_nullable
as Duration?,ascentMeters: freezed == ascentMeters ? _self.ascentMeters : ascentMeters // ignore: cast_nullable_to_non_nullable
as double?,descentMeters: freezed == descentMeters ? _self.descentMeters : descentMeters // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
