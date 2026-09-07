// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wellbeing_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WellbeingEvent {

 String get id; LocalDate get day; WellbeingEventType get type; String get title; DateTime get createdAt; DateTime get updatedAt; bool get isCustomSaved; String? get notes;
/// Create a copy of WellbeingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WellbeingEventCopyWith<WellbeingEvent> get copyWith => _$WellbeingEventCopyWithImpl<WellbeingEvent>(this as WellbeingEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WellbeingEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.day, day) || other.day == day)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isCustomSaved, isCustomSaved) || other.isCustomSaved == isCustomSaved)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode => Object.hash(runtimeType,id,day,type,title,createdAt,updatedAt,isCustomSaved,notes);

@override
String toString() {
  return 'WellbeingEvent(id: $id, day: $day, type: $type, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, isCustomSaved: $isCustomSaved, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $WellbeingEventCopyWith<$Res>  {
  factory $WellbeingEventCopyWith(WellbeingEvent value, $Res Function(WellbeingEvent) _then) = _$WellbeingEventCopyWithImpl;
@useResult
$Res call({
 String id, LocalDate day, WellbeingEventType type, String title, DateTime createdAt, DateTime updatedAt, bool isCustomSaved, String? notes
});




}
/// @nodoc
class _$WellbeingEventCopyWithImpl<$Res>
    implements $WellbeingEventCopyWith<$Res> {
  _$WellbeingEventCopyWithImpl(this._self, this._then);

  final WellbeingEvent _self;
  final $Res Function(WellbeingEvent) _then;

/// Create a copy of WellbeingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? day = null,Object? type = null,Object? title = null,Object? createdAt = null,Object? updatedAt = null,Object? isCustomSaved = null,Object? notes = freezed,}) {
  return _then(WellbeingEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WellbeingEventType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isCustomSaved: null == isCustomSaved ? _self.isCustomSaved : isCustomSaved // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WellbeingEvent].
extension WellbeingEventPatterns on WellbeingEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WellbeingEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WellbeingEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WellbeingEvent value)  $default,){
final _that = this;
switch (_that) {
case _WellbeingEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WellbeingEvent value)?  $default,){
final _that = this;
switch (_that) {
case _WellbeingEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  LocalDate day,  WellbeingEventType type,  String title,  DateTime createdAt,  DateTime updatedAt,  bool isCustomSaved,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WellbeingEvent() when $default != null:
return $default(_that.id,_that.day,_that.type,_that.title,_that.createdAt,_that.updatedAt,_that.isCustomSaved,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  LocalDate day,  WellbeingEventType type,  String title,  DateTime createdAt,  DateTime updatedAt,  bool isCustomSaved,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _WellbeingEvent():
return $default(_that.id,_that.day,_that.type,_that.title,_that.createdAt,_that.updatedAt,_that.isCustomSaved,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  LocalDate day,  WellbeingEventType type,  String title,  DateTime createdAt,  DateTime updatedAt,  bool isCustomSaved,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _WellbeingEvent() when $default != null:
return $default(_that.id,_that.day,_that.type,_that.title,_that.createdAt,_that.updatedAt,_that.isCustomSaved,_that.notes);case _:
  return null;

}
}

}

/// @nodoc


class _WellbeingEvent extends WellbeingEvent {
  const _WellbeingEvent({required this.id, required this.day, required this.type, required this.title, required this.createdAt, required this.updatedAt, this.isCustomSaved = false, this.notes}): super._();
  

@override final  String id;
@override final  LocalDate day;
@override final  WellbeingEventType type;
@override final  String title;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  bool isCustomSaved;
@override final  String? notes;

/// Create a copy of WellbeingEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WellbeingEventCopyWith<_WellbeingEvent> get copyWith => __$WellbeingEventCopyWithImpl<_WellbeingEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WellbeingEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.day, day) || other.day == day)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isCustomSaved, isCustomSaved) || other.isCustomSaved == isCustomSaved)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode => Object.hash(runtimeType,id,day,type,title,createdAt,updatedAt,isCustomSaved,notes);

@override
String toString() {
  return 'WellbeingEvent(id: $id, day: $day, type: $type, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, isCustomSaved: $isCustomSaved, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$WellbeingEventCopyWith<$Res> implements $WellbeingEventCopyWith<$Res> {
  factory _$WellbeingEventCopyWith(_WellbeingEvent value, $Res Function(_WellbeingEvent) _then) = __$WellbeingEventCopyWithImpl;
@override @useResult
$Res call({
 String id, LocalDate day, WellbeingEventType type, String title, DateTime createdAt, DateTime updatedAt, bool isCustomSaved, String? notes
});




}
/// @nodoc
class __$WellbeingEventCopyWithImpl<$Res>
    implements _$WellbeingEventCopyWith<$Res> {
  __$WellbeingEventCopyWithImpl(this._self, this._then);

  final _WellbeingEvent _self;
  final $Res Function(_WellbeingEvent) _then;

/// Create a copy of WellbeingEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? day = null,Object? type = null,Object? title = null,Object? createdAt = null,Object? updatedAt = null,Object? isCustomSaved = null,Object? notes = freezed,}) {
  return _then(_WellbeingEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WellbeingEventType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isCustomSaved: null == isCustomSaved ? _self.isCustomSaved : isCustomSaved // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
