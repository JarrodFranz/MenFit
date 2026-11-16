// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Food {

 String get id; String get name;/// Plain-English description of one serving, e.g. `'1 cup (dry)'`.
 String get servingDescription;/// The nutrition of exactly one [servingDescription].
 NutritionFacts get perServing;/// UTC.
 DateTime get createdAt;/// UTC.
 DateTime get updatedAt;/// Brand or maker. `null` for generic foods.
 String? get brand;/// Mass of one serving in grams, when known. `null` when the serving
/// has no meaningful gram weight or the user simply didn't say.
 double? get servingGrams;/// Volume of one serving in millilitres, when known. `null` when the
/// serving has no fluid volume specified.
 double? get servingVolumeMl;/// EAN/UPC barcode, when known. `null` for hand-entered foods.
 String? get barcode;/// Source-scoped catalogue key; never a product barcode.
 String? get providerFoodId; FoodSource get source;
/// Create a copy of Food
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoodCopyWith<Food> get copyWith => _$FoodCopyWithImpl<Food>(this as Food, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Food&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.servingDescription, servingDescription) || other.servingDescription == servingDescription)&&(identical(other.perServing, perServing) || other.perServing == perServing)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.servingGrams, servingGrams) || other.servingGrams == servingGrams)&&(identical(other.servingVolumeMl, servingVolumeMl) || other.servingVolumeMl == servingVolumeMl)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.providerFoodId, providerFoodId) || other.providerFoodId == providerFoodId)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,servingDescription,perServing,createdAt,updatedAt,brand,servingGrams,servingVolumeMl,barcode,providerFoodId,source);

@override
String toString() {
  return 'Food(id: $id, name: $name, servingDescription: $servingDescription, perServing: $perServing, createdAt: $createdAt, updatedAt: $updatedAt, brand: $brand, servingGrams: $servingGrams, servingVolumeMl: $servingVolumeMl, barcode: $barcode, providerFoodId: $providerFoodId, source: $source)';
}


}

/// @nodoc
abstract mixin class $FoodCopyWith<$Res>  {
  factory $FoodCopyWith(Food value, $Res Function(Food) _then) = _$FoodCopyWithImpl;
@useResult
$Res call({
 String id, String name, String servingDescription, NutritionFacts perServing, DateTime createdAt, DateTime updatedAt, String? brand, double? servingGrams, double? servingVolumeMl, String? barcode, String? providerFoodId, FoodSource source
});


$NutritionFactsCopyWith<$Res> get perServing;

}
/// @nodoc
class _$FoodCopyWithImpl<$Res>
    implements $FoodCopyWith<$Res> {
  _$FoodCopyWithImpl(this._self, this._then);

  final Food _self;
  final $Res Function(Food) _then;

/// Create a copy of Food
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? servingDescription = null,Object? perServing = null,Object? createdAt = null,Object? updatedAt = null,Object? brand = freezed,Object? servingGrams = freezed,Object? servingVolumeMl = freezed,Object? barcode = freezed,Object? providerFoodId = freezed,Object? source = null,}) {
  return _then(Food(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,servingDescription: null == servingDescription ? _self.servingDescription : servingDescription // ignore: cast_nullable_to_non_nullable
as String,perServing: null == perServing ? _self.perServing : perServing // ignore: cast_nullable_to_non_nullable
as NutritionFacts,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,servingGrams: freezed == servingGrams ? _self.servingGrams : servingGrams // ignore: cast_nullable_to_non_nullable
as double?,servingVolumeMl: freezed == servingVolumeMl ? _self.servingVolumeMl : servingVolumeMl // ignore: cast_nullable_to_non_nullable
as double?,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,providerFoodId: freezed == providerFoodId ? _self.providerFoodId : providerFoodId // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as FoodSource,
  ));
}
/// Create a copy of Food
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionFactsCopyWith<$Res> get perServing {
  
  return $NutritionFactsCopyWith<$Res>(_self.perServing, (value) {
    return _then(_self.copyWith(perServing: value));
  });
}
}


/// Adds pattern-matching-related methods to [Food].
extension FoodPatterns on Food {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Food value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Food() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Food value)  $default,){
final _that = this;
switch (_that) {
case _Food():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Food value)?  $default,){
final _that = this;
switch (_that) {
case _Food() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String servingDescription,  NutritionFacts perServing,  DateTime createdAt,  DateTime updatedAt,  String? brand,  double? servingGrams,  double? servingVolumeMl,  String? barcode,  String? providerFoodId,  FoodSource source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Food() when $default != null:
return $default(_that.id,_that.name,_that.servingDescription,_that.perServing,_that.createdAt,_that.updatedAt,_that.brand,_that.servingGrams,_that.servingVolumeMl,_that.barcode,_that.providerFoodId,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String servingDescription,  NutritionFacts perServing,  DateTime createdAt,  DateTime updatedAt,  String? brand,  double? servingGrams,  double? servingVolumeMl,  String? barcode,  String? providerFoodId,  FoodSource source)  $default,) {final _that = this;
switch (_that) {
case _Food():
return $default(_that.id,_that.name,_that.servingDescription,_that.perServing,_that.createdAt,_that.updatedAt,_that.brand,_that.servingGrams,_that.servingVolumeMl,_that.barcode,_that.providerFoodId,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String servingDescription,  NutritionFacts perServing,  DateTime createdAt,  DateTime updatedAt,  String? brand,  double? servingGrams,  double? servingVolumeMl,  String? barcode,  String? providerFoodId,  FoodSource source)?  $default,) {final _that = this;
switch (_that) {
case _Food() when $default != null:
return $default(_that.id,_that.name,_that.servingDescription,_that.perServing,_that.createdAt,_that.updatedAt,_that.brand,_that.servingGrams,_that.servingVolumeMl,_that.barcode,_that.providerFoodId,_that.source);case _:
  return null;

}
}

}

/// @nodoc


class _Food extends Food {
  const _Food({required this.id, required this.name, required this.servingDescription, required this.perServing, required this.createdAt, required this.updatedAt, this.brand, this.servingGrams, this.servingVolumeMl, this.barcode, this.providerFoodId, this.source = FoodSource.custom}): super._();
  

@override final  String id;
@override final  String name;
/// Plain-English description of one serving, e.g. `'1 cup (dry)'`.
@override final  String servingDescription;
/// The nutrition of exactly one [servingDescription].
@override final  NutritionFacts perServing;
/// UTC.
@override final  DateTime createdAt;
/// UTC.
@override final  DateTime updatedAt;
/// Brand or maker. `null` for generic foods.
@override final  String? brand;
/// Mass of one serving in grams, when known. `null` when the serving
/// has no meaningful gram weight or the user simply didn't say.
@override final  double? servingGrams;
/// Volume of one serving in millilitres, when known. `null` when the
/// serving has no fluid volume specified.
@override final  double? servingVolumeMl;
/// EAN/UPC barcode, when known. `null` for hand-entered foods.
@override final  String? barcode;
/// Source-scoped catalogue key; never a product barcode.
@override final  String? providerFoodId;
@override@JsonKey() final  FoodSource source;

/// Create a copy of Food
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoodCopyWith<_Food> get copyWith => __$FoodCopyWithImpl<_Food>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Food&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.servingDescription, servingDescription) || other.servingDescription == servingDescription)&&(identical(other.perServing, perServing) || other.perServing == perServing)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.servingGrams, servingGrams) || other.servingGrams == servingGrams)&&(identical(other.servingVolumeMl, servingVolumeMl) || other.servingVolumeMl == servingVolumeMl)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.providerFoodId, providerFoodId) || other.providerFoodId == providerFoodId)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,servingDescription,perServing,createdAt,updatedAt,brand,servingGrams,servingVolumeMl,barcode,providerFoodId,source);

@override
String toString() {
  return 'Food(id: $id, name: $name, servingDescription: $servingDescription, perServing: $perServing, createdAt: $createdAt, updatedAt: $updatedAt, brand: $brand, servingGrams: $servingGrams, servingVolumeMl: $servingVolumeMl, barcode: $barcode, providerFoodId: $providerFoodId, source: $source)';
}


}

/// @nodoc
abstract mixin class _$FoodCopyWith<$Res> implements $FoodCopyWith<$Res> {
  factory _$FoodCopyWith(_Food value, $Res Function(_Food) _then) = __$FoodCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String servingDescription, NutritionFacts perServing, DateTime createdAt, DateTime updatedAt, String? brand, double? servingGrams, double? servingVolumeMl, String? barcode, String? providerFoodId, FoodSource source
});


@override $NutritionFactsCopyWith<$Res> get perServing;

}
/// @nodoc
class __$FoodCopyWithImpl<$Res>
    implements _$FoodCopyWith<$Res> {
  __$FoodCopyWithImpl(this._self, this._then);

  final _Food _self;
  final $Res Function(_Food) _then;

/// Create a copy of Food
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? servingDescription = null,Object? perServing = null,Object? createdAt = null,Object? updatedAt = null,Object? brand = freezed,Object? servingGrams = freezed,Object? servingVolumeMl = freezed,Object? barcode = freezed,Object? providerFoodId = freezed,Object? source = null,}) {
  return _then(_Food(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,servingDescription: null == servingDescription ? _self.servingDescription : servingDescription // ignore: cast_nullable_to_non_nullable
as String,perServing: null == perServing ? _self.perServing : perServing // ignore: cast_nullable_to_non_nullable
as NutritionFacts,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,servingGrams: freezed == servingGrams ? _self.servingGrams : servingGrams // ignore: cast_nullable_to_non_nullable
as double?,servingVolumeMl: freezed == servingVolumeMl ? _self.servingVolumeMl : servingVolumeMl // ignore: cast_nullable_to_non_nullable
as double?,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,providerFoodId: freezed == providerFoodId ? _self.providerFoodId : providerFoodId // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as FoodSource,
  ));
}

/// Create a copy of Food
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NutritionFactsCopyWith<$Res> get perServing {
  
  return $NutritionFactsCopyWith<$Res>(_self.perServing, (value) {
    return _then(_self.copyWith(perServing: value));
  });
}
}

// dart format on
