// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nutrition_totals.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NutritionTotals {

 NutritionFacts get facts;/// How many diary entries were summed into [facts].
 int get entryCount;/// Whether at least one summed entry didn't state its iron, making
/// `facts.ironMg` a floor rather than a complete figure.
 bool get ironIsPartial;/// Whether at least one summed entry didn't state its calcium.
 bool get calciumIsPartial;/// Whether at least one summed entry didn't state its vitamin D.
 bool get vitaminDIsPartial;/// Whether at least one summed entry didn't state its fiber.
 bool get fiberIsPartial;/// Whether at least one summed entry didn't state its vitamin C.
 bool get vitaminCIsPartial;/// Whether at least one summed entry didn't state its potassium.
 bool get potassiumIsPartial;
/// Create a copy of NutritionTotals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NutritionTotalsCopyWith<NutritionTotals> get copyWith => _$NutritionTotalsCopyWithImpl<NutritionTotals>(this as NutritionTotals, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NutritionTotals&&(identical(other.facts, facts) || other.facts == facts)&&(identical(other.entryCount, entryCount) || other.entryCount == entryCount)&&(identical(other.ironIsPartial, ironIsPartial) || other.ironIsPartial == ironIsPartial)&&(identical(other.calciumIsPartial, calciumIsPartial) || other.calciumIsPartial == calciumIsPartial)&&(identical(other.vitaminDIsPartial, vitaminDIsPartial) || other.vitaminDIsPartial == vitaminDIsPartial)&&(identical(other.fiberIsPartial, fiberIsPartial) || other.fiberIsPartial == fiberIsPartial)&&(identical(other.vitaminCIsPartial, vitaminCIsPartial) || other.vitaminCIsPartial == vitaminCIsPartial)&&(identical(other.potassiumIsPartial, potassiumIsPartial) || other.potassiumIsPartial == potassiumIsPartial));
}


@override
int get hashCode => Object.hash(runtimeType,facts,entryCount,ironIsPartial,calciumIsPartial,vitaminDIsPartial,fiberIsPartial,vitaminCIsPartial,potassiumIsPartial);

@override
String toString() {
  return 'NutritionTotals(facts: $facts, entryCount: $entryCount, ironIsPartial: $ironIsPartial, calciumIsPartial: $calciumIsPartial, vitaminDIsPartial: $vitaminDIsPartial, fiberIsPartial: $fiberIsPartial, vitaminCIsPartial: $vitaminCIsPartial, potassiumIsPartial: $potassiumIsPartial)';
}


}

/// @nodoc
abstract mixin class $NutritionTotalsCopyWith<$Res>  {
  factory $NutritionTotalsCopyWith(NutritionTotals value, $Res Function(NutritionTotals) _then) = _$NutritionTotalsCopyWithImpl;
@useResult
$Res call({
 NutritionFacts facts, int entryCount, bool ironIsPartial, bool calciumIsPartial, bool vitaminDIsPartial, bool fiberIsPartial, bool vitaminCIsPartial, bool potassiumIsPartial
});


$NutritionFactsCopyWith<$Res> get facts;

}
/// @nodoc
class _$NutritionTotalsCopyWithImpl<$Res>
    implements $NutritionTotalsCopyWith<$Res> {
  _$NutritionTotalsCopyWithImpl(this._self, this._then);

  final NutritionTotals _self;
  final $Res Function(NutritionTotals) _then;

/// Create a copy of NutritionTotals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? facts = null,Object? entryCount = null,Object? ironIsPartial = null,Object? calciumIsPartial = null,Object? vitaminDIsPartial = null,Object? fiberIsPartial = null,Object? vitaminCIsPartial = null,Object? potassiumIsPartial = null,}) {
  return _then(NutritionTotals(
facts: null == facts ? _self.facts : facts // ignore: cast_nullable_to_non_nullable
as NutritionFacts,entryCount: null == entryCount ? _self.entryCount : entryCount // ignore: cast_nullable_to_non_nullable
as int,ironIsPartial: null == ironIsPartial ? _self.ironIsPartial : ironIsPartial // ignore: cast_nullable_to_non_nullable
as bool,calciumIsPartial: null == calciumIsPartial ? _self.calciumIsPartial : calciumIsPartial // ignore: cast_nullable_to_non_nullable
as bool,vitaminDIsPartial: null == vitaminDIsPartial ? _self.vitaminDIsPartial : vitaminDIsPartial // ignore: cast_nullable_to_non_nullable
as bool,fiberIsPartial: null == fiberIsPartial ? _self.fiberIsPartial : fiberIsPartial // ignore: cast_nullable_to_non_nullable
as bool,vitaminCIsPartial: null == vitaminCIsPartial ? _self.vitaminCIsPartial : vitaminCIsPartial // ignore: cast_nullable_to_non_nullable
as bool,potassiumIsPartial: null == potassiumIsPartial ? _self.potassiumIsPartial : potassiumIsPartial // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of NutritionTotals
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionFactsCopyWith<$Res> get facts {
  
  return $NutritionFactsCopyWith<$Res>(_self.facts, (value) {
    return _then(_self.copyWith(facts: value));
  });
}
}


/// Adds pattern-matching-related methods to [NutritionTotals].
extension NutritionTotalsPatterns on NutritionTotals {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NutritionTotals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NutritionTotals() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NutritionTotals value)  $default,){
final _that = this;
switch (_that) {
case _NutritionTotals():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NutritionTotals value)?  $default,){
final _that = this;
switch (_that) {
case _NutritionTotals() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NutritionFacts facts,  int entryCount,  bool ironIsPartial,  bool calciumIsPartial,  bool vitaminDIsPartial,  bool fiberIsPartial,  bool vitaminCIsPartial,  bool potassiumIsPartial)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NutritionTotals() when $default != null:
return $default(_that.facts,_that.entryCount,_that.ironIsPartial,_that.calciumIsPartial,_that.vitaminDIsPartial,_that.fiberIsPartial,_that.vitaminCIsPartial,_that.potassiumIsPartial);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NutritionFacts facts,  int entryCount,  bool ironIsPartial,  bool calciumIsPartial,  bool vitaminDIsPartial,  bool fiberIsPartial,  bool vitaminCIsPartial,  bool potassiumIsPartial)  $default,) {final _that = this;
switch (_that) {
case _NutritionTotals():
return $default(_that.facts,_that.entryCount,_that.ironIsPartial,_that.calciumIsPartial,_that.vitaminDIsPartial,_that.fiberIsPartial,_that.vitaminCIsPartial,_that.potassiumIsPartial);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NutritionFacts facts,  int entryCount,  bool ironIsPartial,  bool calciumIsPartial,  bool vitaminDIsPartial,  bool fiberIsPartial,  bool vitaminCIsPartial,  bool potassiumIsPartial)?  $default,) {final _that = this;
switch (_that) {
case _NutritionTotals() when $default != null:
return $default(_that.facts,_that.entryCount,_that.ironIsPartial,_that.calciumIsPartial,_that.vitaminDIsPartial,_that.fiberIsPartial,_that.vitaminCIsPartial,_that.potassiumIsPartial);case _:
  return null;

}
}

}

/// @nodoc


class _NutritionTotals extends NutritionTotals {
  const _NutritionTotals({this.facts = NutritionFacts.zero, this.entryCount = 0, this.ironIsPartial = false, this.calciumIsPartial = false, this.vitaminDIsPartial = false, this.fiberIsPartial = false, this.vitaminCIsPartial = false, this.potassiumIsPartial = false}): super._();
  

@override@JsonKey() final  NutritionFacts facts;
/// How many diary entries were summed into [facts].
@override@JsonKey() final  int entryCount;
/// Whether at least one summed entry didn't state its iron, making
/// `facts.ironMg` a floor rather than a complete figure.
@override@JsonKey() final  bool ironIsPartial;
/// Whether at least one summed entry didn't state its calcium.
@override@JsonKey() final  bool calciumIsPartial;
/// Whether at least one summed entry didn't state its vitamin D.
@override@JsonKey() final  bool vitaminDIsPartial;
/// Whether at least one summed entry didn't state its fiber.
@override@JsonKey() final  bool fiberIsPartial;
/// Whether at least one summed entry didn't state its vitamin C.
@override@JsonKey() final  bool vitaminCIsPartial;
/// Whether at least one summed entry didn't state its potassium.
@override@JsonKey() final  bool potassiumIsPartial;

/// Create a copy of NutritionTotals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NutritionTotalsCopyWith<_NutritionTotals> get copyWith => __$NutritionTotalsCopyWithImpl<_NutritionTotals>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NutritionTotals&&(identical(other.facts, facts) || other.facts == facts)&&(identical(other.entryCount, entryCount) || other.entryCount == entryCount)&&(identical(other.ironIsPartial, ironIsPartial) || other.ironIsPartial == ironIsPartial)&&(identical(other.calciumIsPartial, calciumIsPartial) || other.calciumIsPartial == calciumIsPartial)&&(identical(other.vitaminDIsPartial, vitaminDIsPartial) || other.vitaminDIsPartial == vitaminDIsPartial)&&(identical(other.fiberIsPartial, fiberIsPartial) || other.fiberIsPartial == fiberIsPartial)&&(identical(other.vitaminCIsPartial, vitaminCIsPartial) || other.vitaminCIsPartial == vitaminCIsPartial)&&(identical(other.potassiumIsPartial, potassiumIsPartial) || other.potassiumIsPartial == potassiumIsPartial));
}


@override
int get hashCode => Object.hash(runtimeType,facts,entryCount,ironIsPartial,calciumIsPartial,vitaminDIsPartial,fiberIsPartial,vitaminCIsPartial,potassiumIsPartial);

@override
String toString() {
  return 'NutritionTotals(facts: $facts, entryCount: $entryCount, ironIsPartial: $ironIsPartial, calciumIsPartial: $calciumIsPartial, vitaminDIsPartial: $vitaminDIsPartial, fiberIsPartial: $fiberIsPartial, vitaminCIsPartial: $vitaminCIsPartial, potassiumIsPartial: $potassiumIsPartial)';
}


}

/// @nodoc
abstract mixin class _$NutritionTotalsCopyWith<$Res> implements $NutritionTotalsCopyWith<$Res> {
  factory _$NutritionTotalsCopyWith(_NutritionTotals value, $Res Function(_NutritionTotals) _then) = __$NutritionTotalsCopyWithImpl;
@override @useResult
$Res call({
 NutritionFacts facts, int entryCount, bool ironIsPartial, bool calciumIsPartial, bool vitaminDIsPartial, bool fiberIsPartial, bool vitaminCIsPartial, bool potassiumIsPartial
});


@override $NutritionFactsCopyWith<$Res> get facts;

}
/// @nodoc
class __$NutritionTotalsCopyWithImpl<$Res>
    implements _$NutritionTotalsCopyWith<$Res> {
  __$NutritionTotalsCopyWithImpl(this._self, this._then);

  final _NutritionTotals _self;
  final $Res Function(_NutritionTotals) _then;

/// Create a copy of NutritionTotals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? facts = null,Object? entryCount = null,Object? ironIsPartial = null,Object? calciumIsPartial = null,Object? vitaminDIsPartial = null,Object? fiberIsPartial = null,Object? vitaminCIsPartial = null,Object? potassiumIsPartial = null,}) {
  return _then(_NutritionTotals(
facts: null == facts ? _self.facts : facts // ignore: cast_nullable_to_non_nullable
as NutritionFacts,entryCount: null == entryCount ? _self.entryCount : entryCount // ignore: cast_nullable_to_non_nullable
as int,ironIsPartial: null == ironIsPartial ? _self.ironIsPartial : ironIsPartial // ignore: cast_nullable_to_non_nullable
as bool,calciumIsPartial: null == calciumIsPartial ? _self.calciumIsPartial : calciumIsPartial // ignore: cast_nullable_to_non_nullable
as bool,vitaminDIsPartial: null == vitaminDIsPartial ? _self.vitaminDIsPartial : vitaminDIsPartial // ignore: cast_nullable_to_non_nullable
as bool,fiberIsPartial: null == fiberIsPartial ? _self.fiberIsPartial : fiberIsPartial // ignore: cast_nullable_to_non_nullable
as bool,vitaminCIsPartial: null == vitaminCIsPartial ? _self.vitaminCIsPartial : vitaminCIsPartial // ignore: cast_nullable_to_non_nullable
as bool,potassiumIsPartial: null == potassiumIsPartial ? _self.potassiumIsPartial : potassiumIsPartial // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of NutritionTotals
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionFactsCopyWith<$Res> get facts {
  
  return $NutritionFactsCopyWith<$Res>(_self.facts, (value) {
    return _then(_self.copyWith(facts: value));
  });
}
}

/// @nodoc
mixin _$DayNutritionTotals {

 NutritionTotals get total; Map<MealType, NutritionTotals> get byMeal;
/// Create a copy of DayNutritionTotals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DayNutritionTotalsCopyWith<DayNutritionTotals> get copyWith => _$DayNutritionTotalsCopyWithImpl<DayNutritionTotals>(this as DayNutritionTotals, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DayNutritionTotals&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other.byMeal, byMeal));
}


@override
int get hashCode => Object.hash(runtimeType,total,const DeepCollectionEquality().hash(byMeal));

@override
String toString() {
  return 'DayNutritionTotals(total: $total, byMeal: $byMeal)';
}


}

/// @nodoc
abstract mixin class $DayNutritionTotalsCopyWith<$Res>  {
  factory $DayNutritionTotalsCopyWith(DayNutritionTotals value, $Res Function(DayNutritionTotals) _then) = _$DayNutritionTotalsCopyWithImpl;
@useResult
$Res call({
 NutritionTotals total, Map<MealType, NutritionTotals> byMeal
});


$NutritionTotalsCopyWith<$Res> get total;

}
/// @nodoc
class _$DayNutritionTotalsCopyWithImpl<$Res>
    implements $DayNutritionTotalsCopyWith<$Res> {
  _$DayNutritionTotalsCopyWithImpl(this._self, this._then);

  final DayNutritionTotals _self;
  final $Res Function(DayNutritionTotals) _then;

/// Create a copy of DayNutritionTotals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? byMeal = null,}) {
  return _then(DayNutritionTotals(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as NutritionTotals,byMeal: null == byMeal ? _self.byMeal : byMeal // ignore: cast_nullable_to_non_nullable
as Map<MealType, NutritionTotals>,
  ));
}
/// Create a copy of DayNutritionTotals
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionTotalsCopyWith<$Res> get total {
  
  return $NutritionTotalsCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}
}


/// Adds pattern-matching-related methods to [DayNutritionTotals].
extension DayNutritionTotalsPatterns on DayNutritionTotals {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DayNutritionTotals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DayNutritionTotals() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DayNutritionTotals value)  $default,){
final _that = this;
switch (_that) {
case _DayNutritionTotals():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DayNutritionTotals value)?  $default,){
final _that = this;
switch (_that) {
case _DayNutritionTotals() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NutritionTotals total,  Map<MealType, NutritionTotals> byMeal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DayNutritionTotals() when $default != null:
return $default(_that.total,_that.byMeal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NutritionTotals total,  Map<MealType, NutritionTotals> byMeal)  $default,) {final _that = this;
switch (_that) {
case _DayNutritionTotals():
return $default(_that.total,_that.byMeal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NutritionTotals total,  Map<MealType, NutritionTotals> byMeal)?  $default,) {final _that = this;
switch (_that) {
case _DayNutritionTotals() when $default != null:
return $default(_that.total,_that.byMeal);case _:
  return null;

}
}

}

/// @nodoc


class _DayNutritionTotals extends DayNutritionTotals {
  const _DayNutritionTotals({required this.total, required  Map<MealType, NutritionTotals> byMeal}): _byMeal = byMeal,super._();
  

@override final  NutritionTotals total;
 final  Map<MealType, NutritionTotals> _byMeal;
@override Map<MealType, NutritionTotals> get byMeal {
  if (_byMeal is EqualUnmodifiableMapView) return _byMeal;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_byMeal);
}


/// Create a copy of DayNutritionTotals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DayNutritionTotalsCopyWith<_DayNutritionTotals> get copyWith => __$DayNutritionTotalsCopyWithImpl<_DayNutritionTotals>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DayNutritionTotals&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other._byMeal, _byMeal));
}


@override
int get hashCode => Object.hash(runtimeType,total,const DeepCollectionEquality().hash(_byMeal));

@override
String toString() {
  return 'DayNutritionTotals(total: $total, byMeal: $byMeal)';
}


}

/// @nodoc
abstract mixin class _$DayNutritionTotalsCopyWith<$Res> implements $DayNutritionTotalsCopyWith<$Res> {
  factory _$DayNutritionTotalsCopyWith(_DayNutritionTotals value, $Res Function(_DayNutritionTotals) _then) = __$DayNutritionTotalsCopyWithImpl;
@override @useResult
$Res call({
 NutritionTotals total, Map<MealType, NutritionTotals> byMeal
});


@override $NutritionTotalsCopyWith<$Res> get total;

}
/// @nodoc
class __$DayNutritionTotalsCopyWithImpl<$Res>
    implements _$DayNutritionTotalsCopyWith<$Res> {
  __$DayNutritionTotalsCopyWithImpl(this._self, this._then);

  final _DayNutritionTotals _self;
  final $Res Function(_DayNutritionTotals) _then;

/// Create a copy of DayNutritionTotals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? byMeal = null,}) {
  return _then(_DayNutritionTotals(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as NutritionTotals,byMeal: null == byMeal ? _self._byMeal : byMeal // ignore: cast_nullable_to_non_nullable
as Map<MealType, NutritionTotals>,
  ));
}

/// Create a copy of DayNutritionTotals
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionTotalsCopyWith<$Res> get total {
  
  return $NutritionTotalsCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}
}

/// @nodoc
mixin _$RangeNutritionTotals {

 NutritionTotals get total; NutritionTotals get dailyAverage; int get daysInRange; int get daysWithEntries; Map<LocalDate, DayNutritionTotals> get byDay;
/// Create a copy of RangeNutritionTotals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RangeNutritionTotalsCopyWith<RangeNutritionTotals> get copyWith => _$RangeNutritionTotalsCopyWithImpl<RangeNutritionTotals>(this as RangeNutritionTotals, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RangeNutritionTotals&&(identical(other.total, total) || other.total == total)&&(identical(other.dailyAverage, dailyAverage) || other.dailyAverage == dailyAverage)&&(identical(other.daysInRange, daysInRange) || other.daysInRange == daysInRange)&&(identical(other.daysWithEntries, daysWithEntries) || other.daysWithEntries == daysWithEntries)&&const DeepCollectionEquality().equals(other.byDay, byDay));
}


@override
int get hashCode => Object.hash(runtimeType,total,dailyAverage,daysInRange,daysWithEntries,const DeepCollectionEquality().hash(byDay));

@override
String toString() {
  return 'RangeNutritionTotals(total: $total, dailyAverage: $dailyAverage, daysInRange: $daysInRange, daysWithEntries: $daysWithEntries, byDay: $byDay)';
}


}

/// @nodoc
abstract mixin class $RangeNutritionTotalsCopyWith<$Res>  {
  factory $RangeNutritionTotalsCopyWith(RangeNutritionTotals value, $Res Function(RangeNutritionTotals) _then) = _$RangeNutritionTotalsCopyWithImpl;
@useResult
$Res call({
 NutritionTotals total, NutritionTotals dailyAverage, int daysInRange, int daysWithEntries, Map<LocalDate, DayNutritionTotals> byDay
});


$NutritionTotalsCopyWith<$Res> get total;$NutritionTotalsCopyWith<$Res> get dailyAverage;

}
/// @nodoc
class _$RangeNutritionTotalsCopyWithImpl<$Res>
    implements $RangeNutritionTotalsCopyWith<$Res> {
  _$RangeNutritionTotalsCopyWithImpl(this._self, this._then);

  final RangeNutritionTotals _self;
  final $Res Function(RangeNutritionTotals) _then;

/// Create a copy of RangeNutritionTotals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? dailyAverage = null,Object? daysInRange = null,Object? daysWithEntries = null,Object? byDay = null,}) {
  return _then(RangeNutritionTotals(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as NutritionTotals,dailyAverage: null == dailyAverage ? _self.dailyAverage : dailyAverage // ignore: cast_nullable_to_non_nullable
as NutritionTotals,daysInRange: null == daysInRange ? _self.daysInRange : daysInRange // ignore: cast_nullable_to_non_nullable
as int,daysWithEntries: null == daysWithEntries ? _self.daysWithEntries : daysWithEntries // ignore: cast_nullable_to_non_nullable
as int,byDay: null == byDay ? _self.byDay : byDay // ignore: cast_nullable_to_non_nullable
as Map<LocalDate, DayNutritionTotals>,
  ));
}
/// Create a copy of RangeNutritionTotals
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionTotalsCopyWith<$Res> get total {
  
  return $NutritionTotalsCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}/// Create a copy of RangeNutritionTotals
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionTotalsCopyWith<$Res> get dailyAverage {
  
  return $NutritionTotalsCopyWith<$Res>(_self.dailyAverage, (value) {
    return _then(_self.copyWith(dailyAverage: value));
  });
}
}


/// Adds pattern-matching-related methods to [RangeNutritionTotals].
extension RangeNutritionTotalsPatterns on RangeNutritionTotals {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RangeNutritionTotals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RangeNutritionTotals() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RangeNutritionTotals value)  $default,){
final _that = this;
switch (_that) {
case _RangeNutritionTotals():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RangeNutritionTotals value)?  $default,){
final _that = this;
switch (_that) {
case _RangeNutritionTotals() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NutritionTotals total,  NutritionTotals dailyAverage,  int daysInRange,  int daysWithEntries,  Map<LocalDate, DayNutritionTotals> byDay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RangeNutritionTotals() when $default != null:
return $default(_that.total,_that.dailyAverage,_that.daysInRange,_that.daysWithEntries,_that.byDay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NutritionTotals total,  NutritionTotals dailyAverage,  int daysInRange,  int daysWithEntries,  Map<LocalDate, DayNutritionTotals> byDay)  $default,) {final _that = this;
switch (_that) {
case _RangeNutritionTotals():
return $default(_that.total,_that.dailyAverage,_that.daysInRange,_that.daysWithEntries,_that.byDay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NutritionTotals total,  NutritionTotals dailyAverage,  int daysInRange,  int daysWithEntries,  Map<LocalDate, DayNutritionTotals> byDay)?  $default,) {final _that = this;
switch (_that) {
case _RangeNutritionTotals() when $default != null:
return $default(_that.total,_that.dailyAverage,_that.daysInRange,_that.daysWithEntries,_that.byDay);case _:
  return null;

}
}

}

/// @nodoc


class _RangeNutritionTotals extends RangeNutritionTotals {
  const _RangeNutritionTotals({required this.total, required this.dailyAverage, required this.daysInRange, required this.daysWithEntries, required  Map<LocalDate, DayNutritionTotals> byDay}): _byDay = byDay,super._();
  

@override final  NutritionTotals total;
@override final  NutritionTotals dailyAverage;
@override final  int daysInRange;
@override final  int daysWithEntries;
 final  Map<LocalDate, DayNutritionTotals> _byDay;
@override Map<LocalDate, DayNutritionTotals> get byDay {
  if (_byDay is EqualUnmodifiableMapView) return _byDay;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_byDay);
}


/// Create a copy of RangeNutritionTotals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RangeNutritionTotalsCopyWith<_RangeNutritionTotals> get copyWith => __$RangeNutritionTotalsCopyWithImpl<_RangeNutritionTotals>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RangeNutritionTotals&&(identical(other.total, total) || other.total == total)&&(identical(other.dailyAverage, dailyAverage) || other.dailyAverage == dailyAverage)&&(identical(other.daysInRange, daysInRange) || other.daysInRange == daysInRange)&&(identical(other.daysWithEntries, daysWithEntries) || other.daysWithEntries == daysWithEntries)&&const DeepCollectionEquality().equals(other._byDay, _byDay));
}


@override
int get hashCode => Object.hash(runtimeType,total,dailyAverage,daysInRange,daysWithEntries,const DeepCollectionEquality().hash(_byDay));

@override
String toString() {
  return 'RangeNutritionTotals(total: $total, dailyAverage: $dailyAverage, daysInRange: $daysInRange, daysWithEntries: $daysWithEntries, byDay: $byDay)';
}


}

/// @nodoc
abstract mixin class _$RangeNutritionTotalsCopyWith<$Res> implements $RangeNutritionTotalsCopyWith<$Res> {
  factory _$RangeNutritionTotalsCopyWith(_RangeNutritionTotals value, $Res Function(_RangeNutritionTotals) _then) = __$RangeNutritionTotalsCopyWithImpl;
@override @useResult
$Res call({
 NutritionTotals total, NutritionTotals dailyAverage, int daysInRange, int daysWithEntries, Map<LocalDate, DayNutritionTotals> byDay
});


@override $NutritionTotalsCopyWith<$Res> get total;@override $NutritionTotalsCopyWith<$Res> get dailyAverage;

}
/// @nodoc
class __$RangeNutritionTotalsCopyWithImpl<$Res>
    implements _$RangeNutritionTotalsCopyWith<$Res> {
  __$RangeNutritionTotalsCopyWithImpl(this._self, this._then);

  final _RangeNutritionTotals _self;
  final $Res Function(_RangeNutritionTotals) _then;

/// Create a copy of RangeNutritionTotals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? dailyAverage = null,Object? daysInRange = null,Object? daysWithEntries = null,Object? byDay = null,}) {
  return _then(_RangeNutritionTotals(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as NutritionTotals,dailyAverage: null == dailyAverage ? _self.dailyAverage : dailyAverage // ignore: cast_nullable_to_non_nullable
as NutritionTotals,daysInRange: null == daysInRange ? _self.daysInRange : daysInRange // ignore: cast_nullable_to_non_nullable
as int,daysWithEntries: null == daysWithEntries ? _self.daysWithEntries : daysWithEntries // ignore: cast_nullable_to_non_nullable
as int,byDay: null == byDay ? _self._byDay : byDay // ignore: cast_nullable_to_non_nullable
as Map<LocalDate, DayNutritionTotals>,
  ));
}

/// Create a copy of RangeNutritionTotals
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionTotalsCopyWith<$Res> get total {
  
  return $NutritionTotalsCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}/// Create a copy of RangeNutritionTotals
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionTotalsCopyWith<$Res> get dailyAverage {
  
  return $NutritionTotalsCopyWith<$Res>(_self.dailyAverage, (value) {
    return _then(_self.copyWith(dailyAverage: value));
  });
}
}

// dart format on
