// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'micronutrient_adequacy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MicronutrientAdequacyItem {

 MicronutrientType get type;/// Logged amount for the period. Null when no entries listed this
/// nutrient.
 double? get loggedAmount;/// Biological daily reference intake.
 double get dailyReference;/// Whether at least one logged food did not state this nutrient, making
/// [loggedAmount] a minimum floor rather than a complete figure.
 bool get isPartial;/// Progress ratio towards daily reference intake clamped between 0.0
/// and 1.0.
 double get progress;/// Contextual message explaining status, menstrual demands, or partial
/// data.
 String get statusMessage;/// Active menstrual cycle phase on the evaluated day, if known.
 CyclePhase? get cyclePhase;
/// Create a copy of MicronutrientAdequacyItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MicronutrientAdequacyItemCopyWith<MicronutrientAdequacyItem> get copyWith => _$MicronutrientAdequacyItemCopyWithImpl<MicronutrientAdequacyItem>(this as MicronutrientAdequacyItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MicronutrientAdequacyItem&&(identical(other.type, type) || other.type == type)&&(identical(other.loggedAmount, loggedAmount) || other.loggedAmount == loggedAmount)&&(identical(other.dailyReference, dailyReference) || other.dailyReference == dailyReference)&&(identical(other.isPartial, isPartial) || other.isPartial == isPartial)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.statusMessage, statusMessage) || other.statusMessage == statusMessage)&&const DeepCollectionEquality().equals(other.cyclePhase, cyclePhase));
}


@override
int get hashCode => Object.hash(runtimeType,type,loggedAmount,dailyReference,isPartial,progress,statusMessage,const DeepCollectionEquality().hash(cyclePhase));

@override
String toString() {
  return 'MicronutrientAdequacyItem(type: $type, loggedAmount: $loggedAmount, dailyReference: $dailyReference, isPartial: $isPartial, progress: $progress, statusMessage: $statusMessage, cyclePhase: $cyclePhase)';
}


}

/// @nodoc
abstract mixin class $MicronutrientAdequacyItemCopyWith<$Res>  {
  factory $MicronutrientAdequacyItemCopyWith(MicronutrientAdequacyItem value, $Res Function(MicronutrientAdequacyItem) _then) = _$MicronutrientAdequacyItemCopyWithImpl;
@useResult
$Res call({
 MicronutrientType type, double? loggedAmount, double dailyReference, bool isPartial, double progress, String statusMessage, CyclePhase? cyclePhase
});




}
/// @nodoc
class _$MicronutrientAdequacyItemCopyWithImpl<$Res>
    implements $MicronutrientAdequacyItemCopyWith<$Res> {
  _$MicronutrientAdequacyItemCopyWithImpl(this._self, this._then);

  final MicronutrientAdequacyItem _self;
  final $Res Function(MicronutrientAdequacyItem) _then;

/// Create a copy of MicronutrientAdequacyItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? loggedAmount = freezed,Object? dailyReference = null,Object? isPartial = null,Object? progress = null,Object? statusMessage = null,Object? cyclePhase = freezed,}) {
  return _then(MicronutrientAdequacyItem(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MicronutrientType,loggedAmount: freezed == loggedAmount ? _self.loggedAmount : loggedAmount // ignore: cast_nullable_to_non_nullable
as double?,dailyReference: null == dailyReference ? _self.dailyReference : dailyReference // ignore: cast_nullable_to_non_nullable
as double,isPartial: null == isPartial ? _self.isPartial : isPartial // ignore: cast_nullable_to_non_nullable
as bool,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,statusMessage: null == statusMessage ? _self.statusMessage : statusMessage // ignore: cast_nullable_to_non_nullable
as String,cyclePhase: freezed == cyclePhase ? _self.cyclePhase : cyclePhase // ignore: cast_nullable_to_non_nullable
as CyclePhase?,
  ));
}

}


/// Adds pattern-matching-related methods to [MicronutrientAdequacyItem].
extension MicronutrientAdequacyItemPatterns on MicronutrientAdequacyItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MicronutrientAdequacyItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MicronutrientAdequacyItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MicronutrientAdequacyItem value)  $default,){
final _that = this;
switch (_that) {
case _MicronutrientAdequacyItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MicronutrientAdequacyItem value)?  $default,){
final _that = this;
switch (_that) {
case _MicronutrientAdequacyItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MicronutrientType type,  double? loggedAmount,  double dailyReference,  bool isPartial,  double progress,  String statusMessage,  CyclePhase? cyclePhase)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MicronutrientAdequacyItem() when $default != null:
return $default(_that.type,_that.loggedAmount,_that.dailyReference,_that.isPartial,_that.progress,_that.statusMessage,_that.cyclePhase);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MicronutrientType type,  double? loggedAmount,  double dailyReference,  bool isPartial,  double progress,  String statusMessage,  CyclePhase? cyclePhase)  $default,) {final _that = this;
switch (_that) {
case _MicronutrientAdequacyItem():
return $default(_that.type,_that.loggedAmount,_that.dailyReference,_that.isPartial,_that.progress,_that.statusMessage,_that.cyclePhase);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MicronutrientType type,  double? loggedAmount,  double dailyReference,  bool isPartial,  double progress,  String statusMessage,  CyclePhase? cyclePhase)?  $default,) {final _that = this;
switch (_that) {
case _MicronutrientAdequacyItem() when $default != null:
return $default(_that.type,_that.loggedAmount,_that.dailyReference,_that.isPartial,_that.progress,_that.statusMessage,_that.cyclePhase);case _:
  return null;

}
}

}

/// @nodoc


class _MicronutrientAdequacyItem extends MicronutrientAdequacyItem {
  const _MicronutrientAdequacyItem({required this.type, required this.loggedAmount, required this.dailyReference, required this.isPartial, required this.progress, required this.statusMessage, this.cyclePhase}): super._();
  

@override final  MicronutrientType type;
/// Logged amount for the period. Null when no entries listed this
/// nutrient.
@override final  double? loggedAmount;
/// Biological daily reference intake.
@override final  double dailyReference;
/// Whether at least one logged food did not state this nutrient, making
/// [loggedAmount] a minimum floor rather than a complete figure.
@override final  bool isPartial;
/// Progress ratio towards daily reference intake clamped between 0.0
/// and 1.0.
@override final  double progress;
/// Contextual message explaining status, menstrual demands, or partial
/// data.
@override final  String statusMessage;
/// Active menstrual cycle phase on the evaluated day, if known.
@override final  CyclePhase? cyclePhase;

/// Create a copy of MicronutrientAdequacyItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MicronutrientAdequacyItemCopyWith<_MicronutrientAdequacyItem> get copyWith => __$MicronutrientAdequacyItemCopyWithImpl<_MicronutrientAdequacyItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MicronutrientAdequacyItem&&(identical(other.type, type) || other.type == type)&&(identical(other.loggedAmount, loggedAmount) || other.loggedAmount == loggedAmount)&&(identical(other.dailyReference, dailyReference) || other.dailyReference == dailyReference)&&(identical(other.isPartial, isPartial) || other.isPartial == isPartial)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.statusMessage, statusMessage) || other.statusMessage == statusMessage)&&const DeepCollectionEquality().equals(other.cyclePhase, cyclePhase));
}


@override
int get hashCode => Object.hash(runtimeType,type,loggedAmount,dailyReference,isPartial,progress,statusMessage,const DeepCollectionEquality().hash(cyclePhase));

@override
String toString() {
  return 'MicronutrientAdequacyItem(type: $type, loggedAmount: $loggedAmount, dailyReference: $dailyReference, isPartial: $isPartial, progress: $progress, statusMessage: $statusMessage, cyclePhase: $cyclePhase)';
}


}

/// @nodoc
abstract mixin class _$MicronutrientAdequacyItemCopyWith<$Res> implements $MicronutrientAdequacyItemCopyWith<$Res> {
  factory _$MicronutrientAdequacyItemCopyWith(_MicronutrientAdequacyItem value, $Res Function(_MicronutrientAdequacyItem) _then) = __$MicronutrientAdequacyItemCopyWithImpl;
@override @useResult
$Res call({
 MicronutrientType type, double? loggedAmount, double dailyReference, bool isPartial, double progress, String statusMessage, CyclePhase? cyclePhase
});




}
/// @nodoc
class __$MicronutrientAdequacyItemCopyWithImpl<$Res>
    implements _$MicronutrientAdequacyItemCopyWith<$Res> {
  __$MicronutrientAdequacyItemCopyWithImpl(this._self, this._then);

  final _MicronutrientAdequacyItem _self;
  final $Res Function(_MicronutrientAdequacyItem) _then;

/// Create a copy of MicronutrientAdequacyItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? loggedAmount = freezed,Object? dailyReference = null,Object? isPartial = null,Object? progress = null,Object? statusMessage = null,Object? cyclePhase = freezed,}) {
  return _then(_MicronutrientAdequacyItem(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MicronutrientType,loggedAmount: freezed == loggedAmount ? _self.loggedAmount : loggedAmount // ignore: cast_nullable_to_non_nullable
as double?,dailyReference: null == dailyReference ? _self.dailyReference : dailyReference // ignore: cast_nullable_to_non_nullable
as double,isPartial: null == isPartial ? _self.isPartial : isPartial // ignore: cast_nullable_to_non_nullable
as bool,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,statusMessage: null == statusMessage ? _self.statusMessage : statusMessage // ignore: cast_nullable_to_non_nullable
as String,cyclePhase: freezed == cyclePhase ? _self.cyclePhase : cyclePhase // ignore: cast_nullable_to_non_nullable
as CyclePhase?,
  ));
}


}

// dart format on
