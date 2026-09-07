// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'macro_locks.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MacroLocks {

 bool get protein; bool get carbs; bool get fat;
/// Create a copy of MacroLocks
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MacroLocksCopyWith<MacroLocks> get copyWith => _$MacroLocksCopyWithImpl<MacroLocks>(this as MacroLocks, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MacroLocks&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.fat, fat) || other.fat == fat));
}


@override
int get hashCode => Object.hash(runtimeType,protein,carbs,fat);

@override
String toString() {
  return 'MacroLocks(protein: $protein, carbs: $carbs, fat: $fat)';
}


}

/// @nodoc
abstract mixin class $MacroLocksCopyWith<$Res>  {
  factory $MacroLocksCopyWith(MacroLocks value, $Res Function(MacroLocks) _then) = _$MacroLocksCopyWithImpl;
@useResult
$Res call({
 bool protein, bool carbs, bool fat
});




}
/// @nodoc
class _$MacroLocksCopyWithImpl<$Res>
    implements $MacroLocksCopyWith<$Res> {
  _$MacroLocksCopyWithImpl(this._self, this._then);

  final MacroLocks _self;
  final $Res Function(MacroLocks) _then;

/// Create a copy of MacroLocks
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? protein = null,Object? carbs = null,Object? fat = null,}) {
  return _then(MacroLocks(
protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as bool,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as bool,fat: null == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MacroLocks].
extension MacroLocksPatterns on MacroLocks {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MacroLocks value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MacroLocks() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MacroLocks value)  $default,){
final _that = this;
switch (_that) {
case _MacroLocks():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MacroLocks value)?  $default,){
final _that = this;
switch (_that) {
case _MacroLocks() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool protein,  bool carbs,  bool fat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MacroLocks() when $default != null:
return $default(_that.protein,_that.carbs,_that.fat);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool protein,  bool carbs,  bool fat)  $default,) {final _that = this;
switch (_that) {
case _MacroLocks():
return $default(_that.protein,_that.carbs,_that.fat);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool protein,  bool carbs,  bool fat)?  $default,) {final _that = this;
switch (_that) {
case _MacroLocks() when $default != null:
return $default(_that.protein,_that.carbs,_that.fat);case _:
  return null;

}
}

}

/// @nodoc


class _MacroLocks extends MacroLocks {
  const _MacroLocks({this.protein = false, this.carbs = false, this.fat = false}): super._();
  

@override@JsonKey() final  bool protein;
@override@JsonKey() final  bool carbs;
@override@JsonKey() final  bool fat;

/// Create a copy of MacroLocks
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MacroLocksCopyWith<_MacroLocks> get copyWith => __$MacroLocksCopyWithImpl<_MacroLocks>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MacroLocks&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.fat, fat) || other.fat == fat));
}


@override
int get hashCode => Object.hash(runtimeType,protein,carbs,fat);

@override
String toString() {
  return 'MacroLocks(protein: $protein, carbs: $carbs, fat: $fat)';
}


}

/// @nodoc
abstract mixin class _$MacroLocksCopyWith<$Res> implements $MacroLocksCopyWith<$Res> {
  factory _$MacroLocksCopyWith(_MacroLocks value, $Res Function(_MacroLocks) _then) = __$MacroLocksCopyWithImpl;
@override @useResult
$Res call({
 bool protein, bool carbs, bool fat
});




}
/// @nodoc
class __$MacroLocksCopyWithImpl<$Res>
    implements _$MacroLocksCopyWith<$Res> {
  __$MacroLocksCopyWithImpl(this._self, this._then);

  final _MacroLocks _self;
  final $Res Function(_MacroLocks) _then;

/// Create a copy of MacroLocks
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? protein = null,Object? carbs = null,Object? fat = null,}) {
  return _then(_MacroLocks(
protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as bool,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as bool,fat: null == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
