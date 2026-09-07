// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flare_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FlareEvent {

 String get id; LocalDate get day; FlareSeverity get severity; FlareImpact get impact;/// UTC.
 DateTime get createdAt;/// UTC.
 DateTime get updatedAt; List<SymptomType> get symptoms;/// The inclusive last day of a multi-day flare. `null` — the default,
/// and every pre-schema-v9 row — means the flare covers only [day].
/// Read [lastDay]/[days] rather than this field directly.
 LocalDate? get endDay;/// `null` when left unset ("Prefer not to say") — never required.
 FlareCategory? get category; String? get notes;/// Free-text description when [SymptomType.other] is selected.
 String? get customSymptom;
/// Create a copy of FlareEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlareEventCopyWith<FlareEvent> get copyWith => _$FlareEventCopyWithImpl<FlareEvent>(this as FlareEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FlareEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.day, day) || other.day == day)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.impact, impact) || other.impact == impact)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.symptoms, symptoms)&&(identical(other.endDay, endDay) || other.endDay == endDay)&&(identical(other.category, category) || other.category == category)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.customSymptom, customSymptom) || other.customSymptom == customSymptom));
}


@override
int get hashCode => Object.hash(runtimeType,id,day,severity,impact,createdAt,updatedAt,const DeepCollectionEquality().hash(symptoms),endDay,category,notes,customSymptom);

@override
String toString() {
  return 'FlareEvent(id: $id, day: $day, severity: $severity, impact: $impact, createdAt: $createdAt, updatedAt: $updatedAt, symptoms: $symptoms, endDay: $endDay, category: $category, notes: $notes, customSymptom: $customSymptom)';
}


}

/// @nodoc
abstract mixin class $FlareEventCopyWith<$Res>  {
  factory $FlareEventCopyWith(FlareEvent value, $Res Function(FlareEvent) _then) = _$FlareEventCopyWithImpl;
@useResult
$Res call({
 String id, LocalDate day, FlareSeverity severity, FlareImpact impact, DateTime createdAt, DateTime updatedAt, List<SymptomType> symptoms, LocalDate? endDay, FlareCategory? category, String? notes, String? customSymptom
});




}
/// @nodoc
class _$FlareEventCopyWithImpl<$Res>
    implements $FlareEventCopyWith<$Res> {
  _$FlareEventCopyWithImpl(this._self, this._then);

  final FlareEvent _self;
  final $Res Function(FlareEvent) _then;

/// Create a copy of FlareEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? day = null,Object? severity = null,Object? impact = null,Object? createdAt = null,Object? updatedAt = null,Object? symptoms = null,Object? endDay = freezed,Object? category = freezed,Object? notes = freezed,Object? customSymptom = freezed,}) {
  return _then(FlareEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as FlareSeverity,impact: null == impact ? _self.impact : impact // ignore: cast_nullable_to_non_nullable
as FlareImpact,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,symptoms: null == symptoms ? _self.symptoms : symptoms // ignore: cast_nullable_to_non_nullable
as List<SymptomType>,endDay: freezed == endDay ? _self.endDay : endDay // ignore: cast_nullable_to_non_nullable
as LocalDate?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as FlareCategory?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,customSymptom: freezed == customSymptom ? _self.customSymptom : customSymptom // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FlareEvent].
extension FlareEventPatterns on FlareEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FlareEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FlareEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FlareEvent value)  $default,){
final _that = this;
switch (_that) {
case _FlareEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FlareEvent value)?  $default,){
final _that = this;
switch (_that) {
case _FlareEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  LocalDate day,  FlareSeverity severity,  FlareImpact impact,  DateTime createdAt,  DateTime updatedAt,  List<SymptomType> symptoms,  LocalDate? endDay,  FlareCategory? category,  String? notes,  String? customSymptom)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FlareEvent() when $default != null:
return $default(_that.id,_that.day,_that.severity,_that.impact,_that.createdAt,_that.updatedAt,_that.symptoms,_that.endDay,_that.category,_that.notes,_that.customSymptom);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  LocalDate day,  FlareSeverity severity,  FlareImpact impact,  DateTime createdAt,  DateTime updatedAt,  List<SymptomType> symptoms,  LocalDate? endDay,  FlareCategory? category,  String? notes,  String? customSymptom)  $default,) {final _that = this;
switch (_that) {
case _FlareEvent():
return $default(_that.id,_that.day,_that.severity,_that.impact,_that.createdAt,_that.updatedAt,_that.symptoms,_that.endDay,_that.category,_that.notes,_that.customSymptom);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  LocalDate day,  FlareSeverity severity,  FlareImpact impact,  DateTime createdAt,  DateTime updatedAt,  List<SymptomType> symptoms,  LocalDate? endDay,  FlareCategory? category,  String? notes,  String? customSymptom)?  $default,) {final _that = this;
switch (_that) {
case _FlareEvent() when $default != null:
return $default(_that.id,_that.day,_that.severity,_that.impact,_that.createdAt,_that.updatedAt,_that.symptoms,_that.endDay,_that.category,_that.notes,_that.customSymptom);case _:
  return null;

}
}

}

/// @nodoc


class _FlareEvent extends FlareEvent {
  const _FlareEvent({required this.id, required this.day, required this.severity, required this.impact, required this.createdAt, required this.updatedAt,  List<SymptomType> symptoms = const <SymptomType>[], this.endDay, this.category, this.notes, this.customSymptom}): _symptoms = symptoms,super._();
  

@override final  String id;
@override final  LocalDate day;
@override final  FlareSeverity severity;
@override final  FlareImpact impact;
/// UTC.
@override final  DateTime createdAt;
/// UTC.
@override final  DateTime updatedAt;
 final  List<SymptomType> _symptoms;
@override@JsonKey() List<SymptomType> get symptoms {
  if (_symptoms is EqualUnmodifiableListView) return _symptoms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_symptoms);
}

/// The inclusive last day of a multi-day flare. `null` — the default,
/// and every pre-schema-v9 row — means the flare covers only [day].
/// Read [lastDay]/[days] rather than this field directly.
@override final  LocalDate? endDay;
/// `null` when left unset ("Prefer not to say") — never required.
@override final  FlareCategory? category;
@override final  String? notes;
/// Free-text description when [SymptomType.other] is selected.
@override final  String? customSymptom;

/// Create a copy of FlareEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FlareEventCopyWith<_FlareEvent> get copyWith => __$FlareEventCopyWithImpl<_FlareEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FlareEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.day, day) || other.day == day)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.impact, impact) || other.impact == impact)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._symptoms, _symptoms)&&(identical(other.endDay, endDay) || other.endDay == endDay)&&(identical(other.category, category) || other.category == category)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.customSymptom, customSymptom) || other.customSymptom == customSymptom));
}


@override
int get hashCode => Object.hash(runtimeType,id,day,severity,impact,createdAt,updatedAt,const DeepCollectionEquality().hash(_symptoms),endDay,category,notes,customSymptom);

@override
String toString() {
  return 'FlareEvent(id: $id, day: $day, severity: $severity, impact: $impact, createdAt: $createdAt, updatedAt: $updatedAt, symptoms: $symptoms, endDay: $endDay, category: $category, notes: $notes, customSymptom: $customSymptom)';
}


}

/// @nodoc
abstract mixin class _$FlareEventCopyWith<$Res> implements $FlareEventCopyWith<$Res> {
  factory _$FlareEventCopyWith(_FlareEvent value, $Res Function(_FlareEvent) _then) = __$FlareEventCopyWithImpl;
@override @useResult
$Res call({
 String id, LocalDate day, FlareSeverity severity, FlareImpact impact, DateTime createdAt, DateTime updatedAt, List<SymptomType> symptoms, LocalDate? endDay, FlareCategory? category, String? notes, String? customSymptom
});




}
/// @nodoc
class __$FlareEventCopyWithImpl<$Res>
    implements _$FlareEventCopyWith<$Res> {
  __$FlareEventCopyWithImpl(this._self, this._then);

  final _FlareEvent _self;
  final $Res Function(_FlareEvent) _then;

/// Create a copy of FlareEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? day = null,Object? severity = null,Object? impact = null,Object? createdAt = null,Object? updatedAt = null,Object? symptoms = null,Object? endDay = freezed,Object? category = freezed,Object? notes = freezed,Object? customSymptom = freezed,}) {
  return _then(_FlareEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as LocalDate,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as FlareSeverity,impact: null == impact ? _self.impact : impact // ignore: cast_nullable_to_non_nullable
as FlareImpact,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,symptoms: null == symptoms ? _self._symptoms : symptoms // ignore: cast_nullable_to_non_nullable
as List<SymptomType>,endDay: freezed == endDay ? _self.endDay : endDay // ignore: cast_nullable_to_non_nullable
as LocalDate?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as FlareCategory?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,customSymptom: freezed == customSymptom ? _self.customSymptom : customSymptom // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
