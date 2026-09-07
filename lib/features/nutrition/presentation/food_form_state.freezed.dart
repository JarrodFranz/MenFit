// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FoodFormState {

 String get name; String get brand; FoodBasisMode get basisMode; String get basisAmount; String get basisUnit; String get servingDescription; String get servingGrams; String get servingVolumeMl; String get calories; String get protein; String get carbs; String get fat; String get saturatedFat; String get transFat; String get monounsaturatedFat; String get polyunsaturatedFat; String get fiber; String get sugars; String get addedSugars; String get sodium; String get potassium; String get cholesterol; String get iron; String get calcium; String get vitaminD; String get vitaminC;/// Raw digits as typed or scanned, `''` when the food has none.
///
/// Held as typed rather than as a parsed `Barcode` for the same reason
/// every other field here is a string: the field holds what is in it, and
/// parsing happens once, at save.
///
/// S2 — a barcode names a product the user is about to eat. Nothing here
/// or downstream logs it, and no message repeats it.
 String get barcode;/// `null` until a save attempt rejects the barcode. The text comes from
/// `validateBarcode`, whose copy rules forbid interpolating the input.
 String? get barcodeError;/// A live catalogue food that already carries the barcode about to be
/// saved, set when `FoodFormController.save` refuses to create a second
/// row for the same product. The screen turns this into a choice; it is
/// cleared at the start of every save attempt.
 Food? get duplicateBarcodeMatch;/// Whether a nutrition label has been photographed into this form.
///
/// Drives the review banner, which is shown for the rest of the form's
/// life once it is set: ADR 012's mandatory review is a property of
/// where the numbers came from, not of how recently they arrived.
 bool get labelScanApplied;/// The `ScanField` names whose reading scored below
/// `labelScanCheckThreshold`, so the field can be marked "check this".
///
/// A field the user then edits themselves is **not** removed from the set;
/// it is only ever recomputed by another scan. The marker says "this
/// number came off a photo and was not read cleanly", which stays true
/// of the row until they save.
 Set<String> get lowConfidenceFields;/// Cautions to list under the review banner: the parser's own
/// (`domain/label_ocr/label_warnings.dart`, fixed strings) plus the
/// merge's "kept your value" notes.
///
/// S2, and the one place in this feature where a recognised value is
/// interpolated into a message — see `label_scan_merge.dart`. Display
/// only: never logged, never in an exception.
 List<String> get labelWarnings;/// A scanned panel was per 100 **mL**, so no weight could be derived
/// from it and one is required before saving.
///
/// A stored flag rather than a guess from an empty amount: a per-100 g
/// scan also fills the amount, and if the user cleared *that* field the
/// form would otherwise show them a message about millilitres.
///
/// **Sticky.** Once a per-volume panel has been read, this stays true
/// for the life of the form: the numbers in the fields are still per
/// 100 mL however many times they scan afterwards.
 bool get labelIsPerVolume;/// Whether the user has set the amount **since** the per-volume scan.
///
/// A weight they typed before scanning was not about this label's basis
/// — they were defining a food by weight and then photographed a drink
/// printed per 100 mL. Saving that pair records "these macros are per
/// 250 g" about figures printed per 100 mL, which is false, so the form
/// asks again rather than accepting the coincidence.
 bool get labelVolumeWeightConfirmed;/// `null` until the first save attempt — the form doesn't mark fields
/// wrong before the user has finished with them.
 FoodValidation? get validation; bool get isSubmitting; String? get submitError;
/// Create a copy of FoodFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FoodFormStateCopyWith<FoodFormState> get copyWith => _$FoodFormStateCopyWithImpl<FoodFormState>(this as FoodFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FoodFormState&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.basisMode, basisMode) || other.basisMode == basisMode)&&(identical(other.basisAmount, basisAmount) || other.basisAmount == basisAmount)&&(identical(other.basisUnit, basisUnit) || other.basisUnit == basisUnit)&&(identical(other.servingDescription, servingDescription) || other.servingDescription == servingDescription)&&(identical(other.servingGrams, servingGrams) || other.servingGrams == servingGrams)&&(identical(other.servingVolumeMl, servingVolumeMl) || other.servingVolumeMl == servingVolumeMl)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.saturatedFat, saturatedFat) || other.saturatedFat == saturatedFat)&&(identical(other.transFat, transFat) || other.transFat == transFat)&&(identical(other.monounsaturatedFat, monounsaturatedFat) || other.monounsaturatedFat == monounsaturatedFat)&&(identical(other.polyunsaturatedFat, polyunsaturatedFat) || other.polyunsaturatedFat == polyunsaturatedFat)&&(identical(other.fiber, fiber) || other.fiber == fiber)&&(identical(other.sugars, sugars) || other.sugars == sugars)&&(identical(other.addedSugars, addedSugars) || other.addedSugars == addedSugars)&&(identical(other.sodium, sodium) || other.sodium == sodium)&&(identical(other.potassium, potassium) || other.potassium == potassium)&&(identical(other.cholesterol, cholesterol) || other.cholesterol == cholesterol)&&(identical(other.iron, iron) || other.iron == iron)&&(identical(other.calcium, calcium) || other.calcium == calcium)&&(identical(other.vitaminD, vitaminD) || other.vitaminD == vitaminD)&&(identical(other.vitaminC, vitaminC) || other.vitaminC == vitaminC)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.barcodeError, barcodeError) || other.barcodeError == barcodeError)&&(identical(other.duplicateBarcodeMatch, duplicateBarcodeMatch) || other.duplicateBarcodeMatch == duplicateBarcodeMatch)&&(identical(other.labelScanApplied, labelScanApplied) || other.labelScanApplied == labelScanApplied)&&const DeepCollectionEquality().equals(other.lowConfidenceFields, lowConfidenceFields)&&const DeepCollectionEquality().equals(other.labelWarnings, labelWarnings)&&(identical(other.labelIsPerVolume, labelIsPerVolume) || other.labelIsPerVolume == labelIsPerVolume)&&(identical(other.labelVolumeWeightConfirmed, labelVolumeWeightConfirmed) || other.labelVolumeWeightConfirmed == labelVolumeWeightConfirmed)&&(identical(other.validation, validation) || other.validation == validation)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.submitError, submitError) || other.submitError == submitError));
}


@override
int get hashCode => Object.hashAll([runtimeType,name,brand,basisMode,basisAmount,basisUnit,servingDescription,servingGrams,servingVolumeMl,calories,protein,carbs,fat,saturatedFat,transFat,monounsaturatedFat,polyunsaturatedFat,fiber,sugars,addedSugars,sodium,potassium,cholesterol,iron,calcium,vitaminD,vitaminC,barcode,barcodeError,duplicateBarcodeMatch,labelScanApplied,const DeepCollectionEquality().hash(lowConfidenceFields),const DeepCollectionEquality().hash(labelWarnings),labelIsPerVolume,labelVolumeWeightConfirmed,validation,isSubmitting,submitError]);

@override
String toString() {
  return 'FoodFormState(name: $name, brand: $brand, basisMode: $basisMode, basisAmount: $basisAmount, basisUnit: $basisUnit, servingDescription: $servingDescription, servingGrams: $servingGrams, servingVolumeMl: $servingVolumeMl, calories: $calories, protein: $protein, carbs: $carbs, fat: $fat, saturatedFat: $saturatedFat, transFat: $transFat, monounsaturatedFat: $monounsaturatedFat, polyunsaturatedFat: $polyunsaturatedFat, fiber: $fiber, sugars: $sugars, addedSugars: $addedSugars, sodium: $sodium, potassium: $potassium, cholesterol: $cholesterol, iron: $iron, calcium: $calcium, vitaminD: $vitaminD, vitaminC: $vitaminC, barcode: $barcode, barcodeError: $barcodeError, duplicateBarcodeMatch: $duplicateBarcodeMatch, labelScanApplied: $labelScanApplied, lowConfidenceFields: $lowConfidenceFields, labelWarnings: $labelWarnings, labelIsPerVolume: $labelIsPerVolume, labelVolumeWeightConfirmed: $labelVolumeWeightConfirmed, validation: $validation, isSubmitting: $isSubmitting, submitError: $submitError)';
}


}

/// @nodoc
abstract mixin class $FoodFormStateCopyWith<$Res>  {
  factory $FoodFormStateCopyWith(FoodFormState value, $Res Function(FoodFormState) _then) = _$FoodFormStateCopyWithImpl;
@useResult
$Res call({
 String name, String brand, FoodBasisMode basisMode, String basisAmount, String basisUnit, String servingDescription, String servingGrams, String servingVolumeMl, String calories, String protein, String carbs, String fat, String saturatedFat, String transFat, String monounsaturatedFat, String polyunsaturatedFat, String fiber, String sugars, String addedSugars, String sodium, String potassium, String cholesterol, String iron, String calcium, String vitaminD, String vitaminC, String barcode, String? barcodeError, Food? duplicateBarcodeMatch, bool labelScanApplied, Set<String> lowConfidenceFields, List<String> labelWarnings, bool labelIsPerVolume, bool labelVolumeWeightConfirmed, FoodValidation? validation, bool isSubmitting, String? submitError
});


$FoodCopyWith<$Res>? get duplicateBarcodeMatch;

}
/// @nodoc
class _$FoodFormStateCopyWithImpl<$Res>
    implements $FoodFormStateCopyWith<$Res> {
  _$FoodFormStateCopyWithImpl(this._self, this._then);

  final FoodFormState _self;
  final $Res Function(FoodFormState) _then;

/// Create a copy of FoodFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? brand = null,Object? basisMode = null,Object? basisAmount = null,Object? basisUnit = null,Object? servingDescription = null,Object? servingGrams = null,Object? servingVolumeMl = null,Object? calories = null,Object? protein = null,Object? carbs = null,Object? fat = null,Object? saturatedFat = null,Object? transFat = null,Object? monounsaturatedFat = null,Object? polyunsaturatedFat = null,Object? fiber = null,Object? sugars = null,Object? addedSugars = null,Object? sodium = null,Object? potassium = null,Object? cholesterol = null,Object? iron = null,Object? calcium = null,Object? vitaminD = null,Object? vitaminC = null,Object? barcode = null,Object? barcodeError = freezed,Object? duplicateBarcodeMatch = freezed,Object? labelScanApplied = null,Object? lowConfidenceFields = null,Object? labelWarnings = null,Object? labelIsPerVolume = null,Object? labelVolumeWeightConfirmed = null,Object? validation = freezed,Object? isSubmitting = null,Object? submitError = freezed,}) {
  return _then(FoodFormState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,basisMode: null == basisMode ? _self.basisMode : basisMode // ignore: cast_nullable_to_non_nullable
as FoodBasisMode,basisAmount: null == basisAmount ? _self.basisAmount : basisAmount // ignore: cast_nullable_to_non_nullable
as String,basisUnit: null == basisUnit ? _self.basisUnit : basisUnit // ignore: cast_nullable_to_non_nullable
as String,servingDescription: null == servingDescription ? _self.servingDescription : servingDescription // ignore: cast_nullable_to_non_nullable
as String,servingGrams: null == servingGrams ? _self.servingGrams : servingGrams // ignore: cast_nullable_to_non_nullable
as String,servingVolumeMl: null == servingVolumeMl ? _self.servingVolumeMl : servingVolumeMl // ignore: cast_nullable_to_non_nullable
as String,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as String,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as String,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as String,fat: null == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as String,saturatedFat: null == saturatedFat ? _self.saturatedFat : saturatedFat // ignore: cast_nullable_to_non_nullable
as String,transFat: null == transFat ? _self.transFat : transFat // ignore: cast_nullable_to_non_nullable
as String,monounsaturatedFat: null == monounsaturatedFat ? _self.monounsaturatedFat : monounsaturatedFat // ignore: cast_nullable_to_non_nullable
as String,polyunsaturatedFat: null == polyunsaturatedFat ? _self.polyunsaturatedFat : polyunsaturatedFat // ignore: cast_nullable_to_non_nullable
as String,fiber: null == fiber ? _self.fiber : fiber // ignore: cast_nullable_to_non_nullable
as String,sugars: null == sugars ? _self.sugars : sugars // ignore: cast_nullable_to_non_nullable
as String,addedSugars: null == addedSugars ? _self.addedSugars : addedSugars // ignore: cast_nullable_to_non_nullable
as String,sodium: null == sodium ? _self.sodium : sodium // ignore: cast_nullable_to_non_nullable
as String,potassium: null == potassium ? _self.potassium : potassium // ignore: cast_nullable_to_non_nullable
as String,cholesterol: null == cholesterol ? _self.cholesterol : cholesterol // ignore: cast_nullable_to_non_nullable
as String,iron: null == iron ? _self.iron : iron // ignore: cast_nullable_to_non_nullable
as String,calcium: null == calcium ? _self.calcium : calcium // ignore: cast_nullable_to_non_nullable
as String,vitaminD: null == vitaminD ? _self.vitaminD : vitaminD // ignore: cast_nullable_to_non_nullable
as String,vitaminC: null == vitaminC ? _self.vitaminC : vitaminC // ignore: cast_nullable_to_non_nullable
as String,barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,barcodeError: freezed == barcodeError ? _self.barcodeError : barcodeError // ignore: cast_nullable_to_non_nullable
as String?,duplicateBarcodeMatch: freezed == duplicateBarcodeMatch ? _self.duplicateBarcodeMatch : duplicateBarcodeMatch // ignore: cast_nullable_to_non_nullable
as Food?,labelScanApplied: null == labelScanApplied ? _self.labelScanApplied : labelScanApplied // ignore: cast_nullable_to_non_nullable
as bool,lowConfidenceFields: null == lowConfidenceFields ? _self.lowConfidenceFields : lowConfidenceFields // ignore: cast_nullable_to_non_nullable
as Set<String>,labelWarnings: null == labelWarnings ? _self.labelWarnings : labelWarnings // ignore: cast_nullable_to_non_nullable
as List<String>,labelIsPerVolume: null == labelIsPerVolume ? _self.labelIsPerVolume : labelIsPerVolume // ignore: cast_nullable_to_non_nullable
as bool,labelVolumeWeightConfirmed: null == labelVolumeWeightConfirmed ? _self.labelVolumeWeightConfirmed : labelVolumeWeightConfirmed // ignore: cast_nullable_to_non_nullable
as bool,validation: freezed == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as FoodValidation?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,submitError: freezed == submitError ? _self.submitError : submitError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of FoodFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FoodCopyWith<$Res>? get duplicateBarcodeMatch {
    if (_self.duplicateBarcodeMatch == null) {
    return null;
  }

  return $FoodCopyWith<$Res>(_self.duplicateBarcodeMatch!, (value) {
    return _then(_self.copyWith(duplicateBarcodeMatch: value));
  });
}
}


/// Adds pattern-matching-related methods to [FoodFormState].
extension FoodFormStatePatterns on FoodFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FoodFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FoodFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FoodFormState value)  $default,){
final _that = this;
switch (_that) {
case _FoodFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FoodFormState value)?  $default,){
final _that = this;
switch (_that) {
case _FoodFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String brand,  FoodBasisMode basisMode,  String basisAmount,  String basisUnit,  String servingDescription,  String servingGrams,  String servingVolumeMl,  String calories,  String protein,  String carbs,  String fat,  String saturatedFat,  String transFat,  String monounsaturatedFat,  String polyunsaturatedFat,  String fiber,  String sugars,  String addedSugars,  String sodium,  String potassium,  String cholesterol,  String iron,  String calcium,  String vitaminD,  String vitaminC,  String barcode,  String? barcodeError,  Food? duplicateBarcodeMatch,  bool labelScanApplied,  Set<String> lowConfidenceFields,  List<String> labelWarnings,  bool labelIsPerVolume,  bool labelVolumeWeightConfirmed,  FoodValidation? validation,  bool isSubmitting,  String? submitError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FoodFormState() when $default != null:
return $default(_that.name,_that.brand,_that.basisMode,_that.basisAmount,_that.basisUnit,_that.servingDescription,_that.servingGrams,_that.servingVolumeMl,_that.calories,_that.protein,_that.carbs,_that.fat,_that.saturatedFat,_that.transFat,_that.monounsaturatedFat,_that.polyunsaturatedFat,_that.fiber,_that.sugars,_that.addedSugars,_that.sodium,_that.potassium,_that.cholesterol,_that.iron,_that.calcium,_that.vitaminD,_that.vitaminC,_that.barcode,_that.barcodeError,_that.duplicateBarcodeMatch,_that.labelScanApplied,_that.lowConfidenceFields,_that.labelWarnings,_that.labelIsPerVolume,_that.labelVolumeWeightConfirmed,_that.validation,_that.isSubmitting,_that.submitError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String brand,  FoodBasisMode basisMode,  String basisAmount,  String basisUnit,  String servingDescription,  String servingGrams,  String servingVolumeMl,  String calories,  String protein,  String carbs,  String fat,  String saturatedFat,  String transFat,  String monounsaturatedFat,  String polyunsaturatedFat,  String fiber,  String sugars,  String addedSugars,  String sodium,  String potassium,  String cholesterol,  String iron,  String calcium,  String vitaminD,  String vitaminC,  String barcode,  String? barcodeError,  Food? duplicateBarcodeMatch,  bool labelScanApplied,  Set<String> lowConfidenceFields,  List<String> labelWarnings,  bool labelIsPerVolume,  bool labelVolumeWeightConfirmed,  FoodValidation? validation,  bool isSubmitting,  String? submitError)  $default,) {final _that = this;
switch (_that) {
case _FoodFormState():
return $default(_that.name,_that.brand,_that.basisMode,_that.basisAmount,_that.basisUnit,_that.servingDescription,_that.servingGrams,_that.servingVolumeMl,_that.calories,_that.protein,_that.carbs,_that.fat,_that.saturatedFat,_that.transFat,_that.monounsaturatedFat,_that.polyunsaturatedFat,_that.fiber,_that.sugars,_that.addedSugars,_that.sodium,_that.potassium,_that.cholesterol,_that.iron,_that.calcium,_that.vitaminD,_that.vitaminC,_that.barcode,_that.barcodeError,_that.duplicateBarcodeMatch,_that.labelScanApplied,_that.lowConfidenceFields,_that.labelWarnings,_that.labelIsPerVolume,_that.labelVolumeWeightConfirmed,_that.validation,_that.isSubmitting,_that.submitError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String brand,  FoodBasisMode basisMode,  String basisAmount,  String basisUnit,  String servingDescription,  String servingGrams,  String servingVolumeMl,  String calories,  String protein,  String carbs,  String fat,  String saturatedFat,  String transFat,  String monounsaturatedFat,  String polyunsaturatedFat,  String fiber,  String sugars,  String addedSugars,  String sodium,  String potassium,  String cholesterol,  String iron,  String calcium,  String vitaminD,  String vitaminC,  String barcode,  String? barcodeError,  Food? duplicateBarcodeMatch,  bool labelScanApplied,  Set<String> lowConfidenceFields,  List<String> labelWarnings,  bool labelIsPerVolume,  bool labelVolumeWeightConfirmed,  FoodValidation? validation,  bool isSubmitting,  String? submitError)?  $default,) {final _that = this;
switch (_that) {
case _FoodFormState() when $default != null:
return $default(_that.name,_that.brand,_that.basisMode,_that.basisAmount,_that.basisUnit,_that.servingDescription,_that.servingGrams,_that.servingVolumeMl,_that.calories,_that.protein,_that.carbs,_that.fat,_that.saturatedFat,_that.transFat,_that.monounsaturatedFat,_that.polyunsaturatedFat,_that.fiber,_that.sugars,_that.addedSugars,_that.sodium,_that.potassium,_that.cholesterol,_that.iron,_that.calcium,_that.vitaminD,_that.vitaminC,_that.barcode,_that.barcodeError,_that.duplicateBarcodeMatch,_that.labelScanApplied,_that.lowConfidenceFields,_that.labelWarnings,_that.labelIsPerVolume,_that.labelVolumeWeightConfirmed,_that.validation,_that.isSubmitting,_that.submitError);case _:
  return null;

}
}

}

/// @nodoc


class _FoodFormState extends FoodFormState {
  const _FoodFormState({this.name = '', this.brand = '', this.basisMode = FoodBasisMode.serving, this.basisAmount = '1', this.basisUnit = 'serving', this.servingDescription = '', this.servingGrams = '', this.servingVolumeMl = '', this.calories = '', this.protein = '', this.carbs = '', this.fat = '', this.saturatedFat = '', this.transFat = '', this.monounsaturatedFat = '', this.polyunsaturatedFat = '', this.fiber = '', this.sugars = '', this.addedSugars = '', this.sodium = '', this.potassium = '', this.cholesterol = '', this.iron = '', this.calcium = '', this.vitaminD = '', this.vitaminC = '', this.barcode = '', this.barcodeError, this.duplicateBarcodeMatch, this.labelScanApplied = false,  Set<String> lowConfidenceFields = const <String>{},  List<String> labelWarnings = const <String>[], this.labelIsPerVolume = false, this.labelVolumeWeightConfirmed = false, this.validation, this.isSubmitting = false, this.submitError}): _lowConfidenceFields = lowConfidenceFields,_labelWarnings = labelWarnings,super._();
  

@override@JsonKey() final  String name;
@override@JsonKey() final  String brand;
@override@JsonKey() final  FoodBasisMode basisMode;
@override@JsonKey() final  String basisAmount;
@override@JsonKey() final  String basisUnit;
@override@JsonKey() final  String servingDescription;
@override@JsonKey() final  String servingGrams;
@override@JsonKey() final  String servingVolumeMl;
@override@JsonKey() final  String calories;
@override@JsonKey() final  String protein;
@override@JsonKey() final  String carbs;
@override@JsonKey() final  String fat;
@override@JsonKey() final  String saturatedFat;
@override@JsonKey() final  String transFat;
@override@JsonKey() final  String monounsaturatedFat;
@override@JsonKey() final  String polyunsaturatedFat;
@override@JsonKey() final  String fiber;
@override@JsonKey() final  String sugars;
@override@JsonKey() final  String addedSugars;
@override@JsonKey() final  String sodium;
@override@JsonKey() final  String potassium;
@override@JsonKey() final  String cholesterol;
@override@JsonKey() final  String iron;
@override@JsonKey() final  String calcium;
@override@JsonKey() final  String vitaminD;
@override@JsonKey() final  String vitaminC;
/// Raw digits as typed or scanned, `''` when the food has none.
///
/// Held as typed rather than as a parsed `Barcode` for the same reason
/// every other field here is a string: the field holds what is in it, and
/// parsing happens once, at save.
///
/// S2 — a barcode names a product the user is about to eat. Nothing here
/// or downstream logs it, and no message repeats it.
@override@JsonKey() final  String barcode;
/// `null` until a save attempt rejects the barcode. The text comes from
/// `validateBarcode`, whose copy rules forbid interpolating the input.
@override final  String? barcodeError;
/// A live catalogue food that already carries the barcode about to be
/// saved, set when `FoodFormController.save` refuses to create a second
/// row for the same product. The screen turns this into a choice; it is
/// cleared at the start of every save attempt.
@override final  Food? duplicateBarcodeMatch;
/// Whether a nutrition label has been photographed into this form.
///
/// Drives the review banner, which is shown for the rest of the form's
/// life once it is set: ADR 012's mandatory review is a property of
/// where the numbers came from, not of how recently they arrived.
@override@JsonKey() final  bool labelScanApplied;
/// The `ScanField` names whose reading scored below
/// `labelScanCheckThreshold`, so the field can be marked "check this".
///
/// A field the user then edits themselves is **not** removed from the set;
/// it is only ever recomputed by another scan. The marker says "this
/// number came off a photo and was not read cleanly", which stays true
/// of the row until they save.
 final  Set<String> _lowConfidenceFields;
/// The `ScanField` names whose reading scored below
/// `labelScanCheckThreshold`, so the field can be marked "check this".
///
/// A field the user then edits themselves is **not** removed from the set;
/// it is only ever recomputed by another scan. The marker says "this
/// number came off a photo and was not read cleanly", which stays true
/// of the row until they save.
@override@JsonKey() Set<String> get lowConfidenceFields {
  if (_lowConfidenceFields is EqualUnmodifiableSetView) return _lowConfidenceFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_lowConfidenceFields);
}

/// Cautions to list under the review banner: the parser's own
/// (`domain/label_ocr/label_warnings.dart`, fixed strings) plus the
/// merge's "kept your value" notes.
///
/// S2, and the one place in this feature where a recognised value is
/// interpolated into a message — see `label_scan_merge.dart`. Display
/// only: never logged, never in an exception.
 final  List<String> _labelWarnings;
/// Cautions to list under the review banner: the parser's own
/// (`domain/label_ocr/label_warnings.dart`, fixed strings) plus the
/// merge's "kept your value" notes.
///
/// S2, and the one place in this feature where a recognised value is
/// interpolated into a message — see `label_scan_merge.dart`. Display
/// only: never logged, never in an exception.
@override@JsonKey() List<String> get labelWarnings {
  if (_labelWarnings is EqualUnmodifiableListView) return _labelWarnings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_labelWarnings);
}

/// A scanned panel was per 100 **mL**, so no weight could be derived
/// from it and one is required before saving.
///
/// A stored flag rather than a guess from an empty amount: a per-100 g
/// scan also fills the amount, and if the user cleared *that* field the
/// form would otherwise show them a message about millilitres.
///
/// **Sticky.** Once a per-volume panel has been read, this stays true
/// for the life of the form: the numbers in the fields are still per
/// 100 mL however many times they scan afterwards.
@override@JsonKey() final  bool labelIsPerVolume;
/// Whether the user has set the amount **since** the per-volume scan.
///
/// A weight they typed before scanning was not about this label's basis
/// — they were defining a food by weight and then photographed a drink
/// printed per 100 mL. Saving that pair records "these macros are per
/// 250 g" about figures printed per 100 mL, which is false, so the form
/// asks again rather than accepting the coincidence.
@override@JsonKey() final  bool labelVolumeWeightConfirmed;
/// `null` until the first save attempt — the form doesn't mark fields
/// wrong before the user has finished with them.
@override final  FoodValidation? validation;
@override@JsonKey() final  bool isSubmitting;
@override final  String? submitError;

/// Create a copy of FoodFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FoodFormStateCopyWith<_FoodFormState> get copyWith => __$FoodFormStateCopyWithImpl<_FoodFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FoodFormState&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.basisMode, basisMode) || other.basisMode == basisMode)&&(identical(other.basisAmount, basisAmount) || other.basisAmount == basisAmount)&&(identical(other.basisUnit, basisUnit) || other.basisUnit == basisUnit)&&(identical(other.servingDescription, servingDescription) || other.servingDescription == servingDescription)&&(identical(other.servingGrams, servingGrams) || other.servingGrams == servingGrams)&&(identical(other.servingVolumeMl, servingVolumeMl) || other.servingVolumeMl == servingVolumeMl)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.saturatedFat, saturatedFat) || other.saturatedFat == saturatedFat)&&(identical(other.transFat, transFat) || other.transFat == transFat)&&(identical(other.monounsaturatedFat, monounsaturatedFat) || other.monounsaturatedFat == monounsaturatedFat)&&(identical(other.polyunsaturatedFat, polyunsaturatedFat) || other.polyunsaturatedFat == polyunsaturatedFat)&&(identical(other.fiber, fiber) || other.fiber == fiber)&&(identical(other.sugars, sugars) || other.sugars == sugars)&&(identical(other.addedSugars, addedSugars) || other.addedSugars == addedSugars)&&(identical(other.sodium, sodium) || other.sodium == sodium)&&(identical(other.potassium, potassium) || other.potassium == potassium)&&(identical(other.cholesterol, cholesterol) || other.cholesterol == cholesterol)&&(identical(other.iron, iron) || other.iron == iron)&&(identical(other.calcium, calcium) || other.calcium == calcium)&&(identical(other.vitaminD, vitaminD) || other.vitaminD == vitaminD)&&(identical(other.vitaminC, vitaminC) || other.vitaminC == vitaminC)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.barcodeError, barcodeError) || other.barcodeError == barcodeError)&&(identical(other.duplicateBarcodeMatch, duplicateBarcodeMatch) || other.duplicateBarcodeMatch == duplicateBarcodeMatch)&&(identical(other.labelScanApplied, labelScanApplied) || other.labelScanApplied == labelScanApplied)&&const DeepCollectionEquality().equals(other._lowConfidenceFields, _lowConfidenceFields)&&const DeepCollectionEquality().equals(other._labelWarnings, _labelWarnings)&&(identical(other.labelIsPerVolume, labelIsPerVolume) || other.labelIsPerVolume == labelIsPerVolume)&&(identical(other.labelVolumeWeightConfirmed, labelVolumeWeightConfirmed) || other.labelVolumeWeightConfirmed == labelVolumeWeightConfirmed)&&(identical(other.validation, validation) || other.validation == validation)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.submitError, submitError) || other.submitError == submitError));
}


@override
int get hashCode => Object.hashAll([runtimeType,name,brand,basisMode,basisAmount,basisUnit,servingDescription,servingGrams,servingVolumeMl,calories,protein,carbs,fat,saturatedFat,transFat,monounsaturatedFat,polyunsaturatedFat,fiber,sugars,addedSugars,sodium,potassium,cholesterol,iron,calcium,vitaminD,vitaminC,barcode,barcodeError,duplicateBarcodeMatch,labelScanApplied,const DeepCollectionEquality().hash(_lowConfidenceFields),const DeepCollectionEquality().hash(_labelWarnings),labelIsPerVolume,labelVolumeWeightConfirmed,validation,isSubmitting,submitError]);

@override
String toString() {
  return 'FoodFormState(name: $name, brand: $brand, basisMode: $basisMode, basisAmount: $basisAmount, basisUnit: $basisUnit, servingDescription: $servingDescription, servingGrams: $servingGrams, servingVolumeMl: $servingVolumeMl, calories: $calories, protein: $protein, carbs: $carbs, fat: $fat, saturatedFat: $saturatedFat, transFat: $transFat, monounsaturatedFat: $monounsaturatedFat, polyunsaturatedFat: $polyunsaturatedFat, fiber: $fiber, sugars: $sugars, addedSugars: $addedSugars, sodium: $sodium, potassium: $potassium, cholesterol: $cholesterol, iron: $iron, calcium: $calcium, vitaminD: $vitaminD, vitaminC: $vitaminC, barcode: $barcode, barcodeError: $barcodeError, duplicateBarcodeMatch: $duplicateBarcodeMatch, labelScanApplied: $labelScanApplied, lowConfidenceFields: $lowConfidenceFields, labelWarnings: $labelWarnings, labelIsPerVolume: $labelIsPerVolume, labelVolumeWeightConfirmed: $labelVolumeWeightConfirmed, validation: $validation, isSubmitting: $isSubmitting, submitError: $submitError)';
}


}

/// @nodoc
abstract mixin class _$FoodFormStateCopyWith<$Res> implements $FoodFormStateCopyWith<$Res> {
  factory _$FoodFormStateCopyWith(_FoodFormState value, $Res Function(_FoodFormState) _then) = __$FoodFormStateCopyWithImpl;
@override @useResult
$Res call({
 String name, String brand, FoodBasisMode basisMode, String basisAmount, String basisUnit, String servingDescription, String servingGrams, String servingVolumeMl, String calories, String protein, String carbs, String fat, String saturatedFat, String transFat, String monounsaturatedFat, String polyunsaturatedFat, String fiber, String sugars, String addedSugars, String sodium, String potassium, String cholesterol, String iron, String calcium, String vitaminD, String vitaminC, String barcode, String? barcodeError, Food? duplicateBarcodeMatch, bool labelScanApplied, Set<String> lowConfidenceFields, List<String> labelWarnings, bool labelIsPerVolume, bool labelVolumeWeightConfirmed, FoodValidation? validation, bool isSubmitting, String? submitError
});


@override $FoodCopyWith<$Res>? get duplicateBarcodeMatch;

}
/// @nodoc
class __$FoodFormStateCopyWithImpl<$Res>
    implements _$FoodFormStateCopyWith<$Res> {
  __$FoodFormStateCopyWithImpl(this._self, this._then);

  final _FoodFormState _self;
  final $Res Function(_FoodFormState) _then;

/// Create a copy of FoodFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? brand = null,Object? basisMode = null,Object? basisAmount = null,Object? basisUnit = null,Object? servingDescription = null,Object? servingGrams = null,Object? servingVolumeMl = null,Object? calories = null,Object? protein = null,Object? carbs = null,Object? fat = null,Object? saturatedFat = null,Object? transFat = null,Object? monounsaturatedFat = null,Object? polyunsaturatedFat = null,Object? fiber = null,Object? sugars = null,Object? addedSugars = null,Object? sodium = null,Object? potassium = null,Object? cholesterol = null,Object? iron = null,Object? calcium = null,Object? vitaminD = null,Object? vitaminC = null,Object? barcode = null,Object? barcodeError = freezed,Object? duplicateBarcodeMatch = freezed,Object? labelScanApplied = null,Object? lowConfidenceFields = null,Object? labelWarnings = null,Object? labelIsPerVolume = null,Object? labelVolumeWeightConfirmed = null,Object? validation = freezed,Object? isSubmitting = null,Object? submitError = freezed,}) {
  return _then(_FoodFormState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,basisMode: null == basisMode ? _self.basisMode : basisMode // ignore: cast_nullable_to_non_nullable
as FoodBasisMode,basisAmount: null == basisAmount ? _self.basisAmount : basisAmount // ignore: cast_nullable_to_non_nullable
as String,basisUnit: null == basisUnit ? _self.basisUnit : basisUnit // ignore: cast_nullable_to_non_nullable
as String,servingDescription: null == servingDescription ? _self.servingDescription : servingDescription // ignore: cast_nullable_to_non_nullable
as String,servingGrams: null == servingGrams ? _self.servingGrams : servingGrams // ignore: cast_nullable_to_non_nullable
as String,servingVolumeMl: null == servingVolumeMl ? _self.servingVolumeMl : servingVolumeMl // ignore: cast_nullable_to_non_nullable
as String,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as String,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as String,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as String,fat: null == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as String,saturatedFat: null == saturatedFat ? _self.saturatedFat : saturatedFat // ignore: cast_nullable_to_non_nullable
as String,transFat: null == transFat ? _self.transFat : transFat // ignore: cast_nullable_to_non_nullable
as String,monounsaturatedFat: null == monounsaturatedFat ? _self.monounsaturatedFat : monounsaturatedFat // ignore: cast_nullable_to_non_nullable
as String,polyunsaturatedFat: null == polyunsaturatedFat ? _self.polyunsaturatedFat : polyunsaturatedFat // ignore: cast_nullable_to_non_nullable
as String,fiber: null == fiber ? _self.fiber : fiber // ignore: cast_nullable_to_non_nullable
as String,sugars: null == sugars ? _self.sugars : sugars // ignore: cast_nullable_to_non_nullable
as String,addedSugars: null == addedSugars ? _self.addedSugars : addedSugars // ignore: cast_nullable_to_non_nullable
as String,sodium: null == sodium ? _self.sodium : sodium // ignore: cast_nullable_to_non_nullable
as String,potassium: null == potassium ? _self.potassium : potassium // ignore: cast_nullable_to_non_nullable
as String,cholesterol: null == cholesterol ? _self.cholesterol : cholesterol // ignore: cast_nullable_to_non_nullable
as String,iron: null == iron ? _self.iron : iron // ignore: cast_nullable_to_non_nullable
as String,calcium: null == calcium ? _self.calcium : calcium // ignore: cast_nullable_to_non_nullable
as String,vitaminD: null == vitaminD ? _self.vitaminD : vitaminD // ignore: cast_nullable_to_non_nullable
as String,vitaminC: null == vitaminC ? _self.vitaminC : vitaminC // ignore: cast_nullable_to_non_nullable
as String,barcode: null == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String,barcodeError: freezed == barcodeError ? _self.barcodeError : barcodeError // ignore: cast_nullable_to_non_nullable
as String?,duplicateBarcodeMatch: freezed == duplicateBarcodeMatch ? _self.duplicateBarcodeMatch : duplicateBarcodeMatch // ignore: cast_nullable_to_non_nullable
as Food?,labelScanApplied: null == labelScanApplied ? _self.labelScanApplied : labelScanApplied // ignore: cast_nullable_to_non_nullable
as bool,lowConfidenceFields: null == lowConfidenceFields ? _self._lowConfidenceFields : lowConfidenceFields // ignore: cast_nullable_to_non_nullable
as Set<String>,labelWarnings: null == labelWarnings ? _self._labelWarnings : labelWarnings // ignore: cast_nullable_to_non_nullable
as List<String>,labelIsPerVolume: null == labelIsPerVolume ? _self.labelIsPerVolume : labelIsPerVolume // ignore: cast_nullable_to_non_nullable
as bool,labelVolumeWeightConfirmed: null == labelVolumeWeightConfirmed ? _self.labelVolumeWeightConfirmed : labelVolumeWeightConfirmed // ignore: cast_nullable_to_non_nullable
as bool,validation: freezed == validation ? _self.validation : validation // ignore: cast_nullable_to_non_nullable
as FoodValidation?,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,submitError: freezed == submitError ? _self.submitError : submitError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of FoodFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FoodCopyWith<$Res>? get duplicateBarcodeMatch {
    if (_self.duplicateBarcodeMatch == null) {
    return null;
  }

  return $FoodCopyWith<$Res>(_self.duplicateBarcodeMatch!, (value) {
    return _then(_self.copyWith(duplicateBarcodeMatch: value));
  });
}
}

// dart format on
