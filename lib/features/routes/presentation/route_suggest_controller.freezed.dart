// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route_suggest_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RouteSuggestState {

 SuggestPhase get phase; String get distanceInput; ActivityType get activityType; RouteShapePreference get shapePreference;/// The chosen start point (map tap, place search, or "Use my location").
 GeoPoint? get start;/// Optional readable address or landmark for the start point.
 String? get startAddress;/// Current location search query.
 String get searchQuery;/// Search results from place/address search.
 List<LocationSearchResult> get searchResults;/// True while searching places.
 bool get isSearching;/// Error from place search.
 String? get searchError; List<SuggestedRoute> get suggestions; int get selectedIndex;/// Inline validation message for the distance field.
 String? get distanceError;/// Inline hint when "Find routes" was pressed without a start point.
 String? get startError;/// User-facing message for a failed suggestion request
/// ([SuggestPhase.error]).
 String? get error;/// True while "Use my location" is resolving.
 bool get isLocating;/// User-facing message when "Use my location" failed (permission
/// denied, services off, plugin error) — the map-tap path remains
/// available throughout.
 String? get locationError;/// True while a save is in flight.
 bool get isSaving;/// User-facing message for a failed save.
 String? get saveError;
/// Create a copy of RouteSuggestState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteSuggestStateCopyWith<RouteSuggestState> get copyWith => _$RouteSuggestStateCopyWithImpl<RouteSuggestState>(this as RouteSuggestState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteSuggestState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.distanceInput, distanceInput) || other.distanceInput == distanceInput)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.shapePreference, shapePreference) || other.shapePreference == shapePreference)&&(identical(other.start, start) || other.start == start)&&(identical(other.startAddress, startAddress) || other.startAddress == startAddress)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&const DeepCollectionEquality().equals(other.searchResults, searchResults)&&(identical(other.isSearching, isSearching) || other.isSearching == isSearching)&&(identical(other.searchError, searchError) || other.searchError == searchError)&&const DeepCollectionEquality().equals(other.suggestions, suggestions)&&(identical(other.selectedIndex, selectedIndex) || other.selectedIndex == selectedIndex)&&(identical(other.distanceError, distanceError) || other.distanceError == distanceError)&&(identical(other.startError, startError) || other.startError == startError)&&(identical(other.error, error) || other.error == error)&&(identical(other.isLocating, isLocating) || other.isLocating == isLocating)&&(identical(other.locationError, locationError) || other.locationError == locationError)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.saveError, saveError) || other.saveError == saveError));
}


@override
int get hashCode => Object.hashAll([runtimeType,phase,distanceInput,activityType,shapePreference,start,startAddress,searchQuery,const DeepCollectionEquality().hash(searchResults),isSearching,searchError,const DeepCollectionEquality().hash(suggestions),selectedIndex,distanceError,startError,error,isLocating,locationError,isSaving,saveError]);

@override
String toString() {
  return 'RouteSuggestState(phase: $phase, distanceInput: $distanceInput, activityType: $activityType, shapePreference: $shapePreference, start: $start, startAddress: $startAddress, searchQuery: $searchQuery, searchResults: $searchResults, isSearching: $isSearching, searchError: $searchError, suggestions: $suggestions, selectedIndex: $selectedIndex, distanceError: $distanceError, startError: $startError, error: $error, isLocating: $isLocating, locationError: $locationError, isSaving: $isSaving, saveError: $saveError)';
}


}

/// @nodoc
abstract mixin class $RouteSuggestStateCopyWith<$Res>  {
  factory $RouteSuggestStateCopyWith(RouteSuggestState value, $Res Function(RouteSuggestState) _then) = _$RouteSuggestStateCopyWithImpl;
@useResult
$Res call({
 SuggestPhase phase, String distanceInput, ActivityType activityType, RouteShapePreference shapePreference, GeoPoint? start, String? startAddress, String searchQuery, List<LocationSearchResult> searchResults, bool isSearching, String? searchError, List<SuggestedRoute> suggestions, int selectedIndex, String? distanceError, String? startError, String? error, bool isLocating, String? locationError, bool isSaving, String? saveError
});


$GeoPointCopyWith<$Res>? get start;

}
/// @nodoc
class _$RouteSuggestStateCopyWithImpl<$Res>
    implements $RouteSuggestStateCopyWith<$Res> {
  _$RouteSuggestStateCopyWithImpl(this._self, this._then);

  final RouteSuggestState _self;
  final $Res Function(RouteSuggestState) _then;

/// Create a copy of RouteSuggestState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? distanceInput = null,Object? activityType = null,Object? shapePreference = null,Object? start = freezed,Object? startAddress = freezed,Object? searchQuery = null,Object? searchResults = null,Object? isSearching = null,Object? searchError = freezed,Object? suggestions = null,Object? selectedIndex = null,Object? distanceError = freezed,Object? startError = freezed,Object? error = freezed,Object? isLocating = null,Object? locationError = freezed,Object? isSaving = null,Object? saveError = freezed,}) {
  return _then(RouteSuggestState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SuggestPhase,distanceInput: null == distanceInput ? _self.distanceInput : distanceInput // ignore: cast_nullable_to_non_nullable
as String,activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as ActivityType,shapePreference: null == shapePreference ? _self.shapePreference : shapePreference // ignore: cast_nullable_to_non_nullable
as RouteShapePreference,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as GeoPoint?,startAddress: freezed == startAddress ? _self.startAddress : startAddress // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,searchResults: null == searchResults ? _self.searchResults : searchResults // ignore: cast_nullable_to_non_nullable
as List<LocationSearchResult>,isSearching: null == isSearching ? _self.isSearching : isSearching // ignore: cast_nullable_to_non_nullable
as bool,searchError: freezed == searchError ? _self.searchError : searchError // ignore: cast_nullable_to_non_nullable
as String?,suggestions: null == suggestions ? _self.suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as List<SuggestedRoute>,selectedIndex: null == selectedIndex ? _self.selectedIndex : selectedIndex // ignore: cast_nullable_to_non_nullable
as int,distanceError: freezed == distanceError ? _self.distanceError : distanceError // ignore: cast_nullable_to_non_nullable
as String?,startError: freezed == startError ? _self.startError : startError // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,isLocating: null == isLocating ? _self.isLocating : isLocating // ignore: cast_nullable_to_non_nullable
as bool,locationError: freezed == locationError ? _self.locationError : locationError // ignore: cast_nullable_to_non_nullable
as String?,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,saveError: freezed == saveError ? _self.saveError : saveError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RouteSuggestState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeoPointCopyWith<$Res>? get start {
    if (_self.start == null) {
    return null;
  }

  return $GeoPointCopyWith<$Res>(_self.start!, (value) {
    return _then(_self.copyWith(start: value));
  });
}
}


/// Adds pattern-matching-related methods to [RouteSuggestState].
extension RouteSuggestStatePatterns on RouteSuggestState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteSuggestState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteSuggestState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteSuggestState value)  $default,){
final _that = this;
switch (_that) {
case _RouteSuggestState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteSuggestState value)?  $default,){
final _that = this;
switch (_that) {
case _RouteSuggestState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SuggestPhase phase,  String distanceInput,  ActivityType activityType,  RouteShapePreference shapePreference,  GeoPoint? start,  String? startAddress,  String searchQuery,  List<LocationSearchResult> searchResults,  bool isSearching,  String? searchError,  List<SuggestedRoute> suggestions,  int selectedIndex,  String? distanceError,  String? startError,  String? error,  bool isLocating,  String? locationError,  bool isSaving,  String? saveError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteSuggestState() when $default != null:
return $default(_that.phase,_that.distanceInput,_that.activityType,_that.shapePreference,_that.start,_that.startAddress,_that.searchQuery,_that.searchResults,_that.isSearching,_that.searchError,_that.suggestions,_that.selectedIndex,_that.distanceError,_that.startError,_that.error,_that.isLocating,_that.locationError,_that.isSaving,_that.saveError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SuggestPhase phase,  String distanceInput,  ActivityType activityType,  RouteShapePreference shapePreference,  GeoPoint? start,  String? startAddress,  String searchQuery,  List<LocationSearchResult> searchResults,  bool isSearching,  String? searchError,  List<SuggestedRoute> suggestions,  int selectedIndex,  String? distanceError,  String? startError,  String? error,  bool isLocating,  String? locationError,  bool isSaving,  String? saveError)  $default,) {final _that = this;
switch (_that) {
case _RouteSuggestState():
return $default(_that.phase,_that.distanceInput,_that.activityType,_that.shapePreference,_that.start,_that.startAddress,_that.searchQuery,_that.searchResults,_that.isSearching,_that.searchError,_that.suggestions,_that.selectedIndex,_that.distanceError,_that.startError,_that.error,_that.isLocating,_that.locationError,_that.isSaving,_that.saveError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SuggestPhase phase,  String distanceInput,  ActivityType activityType,  RouteShapePreference shapePreference,  GeoPoint? start,  String? startAddress,  String searchQuery,  List<LocationSearchResult> searchResults,  bool isSearching,  String? searchError,  List<SuggestedRoute> suggestions,  int selectedIndex,  String? distanceError,  String? startError,  String? error,  bool isLocating,  String? locationError,  bool isSaving,  String? saveError)?  $default,) {final _that = this;
switch (_that) {
case _RouteSuggestState() when $default != null:
return $default(_that.phase,_that.distanceInput,_that.activityType,_that.shapePreference,_that.start,_that.startAddress,_that.searchQuery,_that.searchResults,_that.isSearching,_that.searchError,_that.suggestions,_that.selectedIndex,_that.distanceError,_that.startError,_that.error,_that.isLocating,_that.locationError,_that.isSaving,_that.saveError);case _:
  return null;

}
}

}

/// @nodoc


class _RouteSuggestState extends RouteSuggestState {
  const _RouteSuggestState({this.phase = SuggestPhase.input, this.distanceInput = '', this.activityType = ActivityType.run, this.shapePreference = RouteShapePreference.loop, this.start, this.startAddress, this.searchQuery = '',  List<LocationSearchResult> searchResults = const <LocationSearchResult>[], this.isSearching = false, this.searchError,  List<SuggestedRoute> suggestions = const <SuggestedRoute>[], this.selectedIndex = 0, this.distanceError, this.startError, this.error, this.isLocating = false, this.locationError, this.isSaving = false, this.saveError}): _searchResults = searchResults,_suggestions = suggestions,super._();
  

@override@JsonKey() final  SuggestPhase phase;
@override@JsonKey() final  String distanceInput;
@override@JsonKey() final  ActivityType activityType;
@override@JsonKey() final  RouteShapePreference shapePreference;
/// The chosen start point (map tap, place search, or "Use my location").
@override final  GeoPoint? start;
/// Optional readable address or landmark for the start point.
@override final  String? startAddress;
/// Current location search query.
@override@JsonKey() final  String searchQuery;
/// Search results from place/address search.
 final  List<LocationSearchResult> _searchResults;
/// Search results from place/address search.
@override@JsonKey() List<LocationSearchResult> get searchResults {
  if (_searchResults is EqualUnmodifiableListView) return _searchResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_searchResults);
}

/// True while searching places.
@override@JsonKey() final  bool isSearching;
/// Error from place search.
@override final  String? searchError;
 final  List<SuggestedRoute> _suggestions;
@override@JsonKey() List<SuggestedRoute> get suggestions {
  if (_suggestions is EqualUnmodifiableListView) return _suggestions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_suggestions);
}

@override@JsonKey() final  int selectedIndex;
/// Inline validation message for the distance field.
@override final  String? distanceError;
/// Inline hint when "Find routes" was pressed without a start point.
@override final  String? startError;
/// User-facing message for a failed suggestion request
/// ([SuggestPhase.error]).
@override final  String? error;
/// True while "Use my location" is resolving.
@override@JsonKey() final  bool isLocating;
/// User-facing message when "Use my location" failed (permission
/// denied, services off, plugin error) — the map-tap path remains
/// available throughout.
@override final  String? locationError;
/// True while a save is in flight.
@override@JsonKey() final  bool isSaving;
/// User-facing message for a failed save.
@override final  String? saveError;

/// Create a copy of RouteSuggestState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteSuggestStateCopyWith<_RouteSuggestState> get copyWith => __$RouteSuggestStateCopyWithImpl<_RouteSuggestState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteSuggestState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.distanceInput, distanceInput) || other.distanceInput == distanceInput)&&(identical(other.activityType, activityType) || other.activityType == activityType)&&(identical(other.shapePreference, shapePreference) || other.shapePreference == shapePreference)&&(identical(other.start, start) || other.start == start)&&(identical(other.startAddress, startAddress) || other.startAddress == startAddress)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&const DeepCollectionEquality().equals(other._searchResults, _searchResults)&&(identical(other.isSearching, isSearching) || other.isSearching == isSearching)&&(identical(other.searchError, searchError) || other.searchError == searchError)&&const DeepCollectionEquality().equals(other._suggestions, _suggestions)&&(identical(other.selectedIndex, selectedIndex) || other.selectedIndex == selectedIndex)&&(identical(other.distanceError, distanceError) || other.distanceError == distanceError)&&(identical(other.startError, startError) || other.startError == startError)&&(identical(other.error, error) || other.error == error)&&(identical(other.isLocating, isLocating) || other.isLocating == isLocating)&&(identical(other.locationError, locationError) || other.locationError == locationError)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.saveError, saveError) || other.saveError == saveError));
}


@override
int get hashCode => Object.hashAll([runtimeType,phase,distanceInput,activityType,shapePreference,start,startAddress,searchQuery,const DeepCollectionEquality().hash(_searchResults),isSearching,searchError,const DeepCollectionEquality().hash(_suggestions),selectedIndex,distanceError,startError,error,isLocating,locationError,isSaving,saveError]);

@override
String toString() {
  return 'RouteSuggestState(phase: $phase, distanceInput: $distanceInput, activityType: $activityType, shapePreference: $shapePreference, start: $start, startAddress: $startAddress, searchQuery: $searchQuery, searchResults: $searchResults, isSearching: $isSearching, searchError: $searchError, suggestions: $suggestions, selectedIndex: $selectedIndex, distanceError: $distanceError, startError: $startError, error: $error, isLocating: $isLocating, locationError: $locationError, isSaving: $isSaving, saveError: $saveError)';
}


}

/// @nodoc
abstract mixin class _$RouteSuggestStateCopyWith<$Res> implements $RouteSuggestStateCopyWith<$Res> {
  factory _$RouteSuggestStateCopyWith(_RouteSuggestState value, $Res Function(_RouteSuggestState) _then) = __$RouteSuggestStateCopyWithImpl;
@override @useResult
$Res call({
 SuggestPhase phase, String distanceInput, ActivityType activityType, RouteShapePreference shapePreference, GeoPoint? start, String? startAddress, String searchQuery, List<LocationSearchResult> searchResults, bool isSearching, String? searchError, List<SuggestedRoute> suggestions, int selectedIndex, String? distanceError, String? startError, String? error, bool isLocating, String? locationError, bool isSaving, String? saveError
});


@override $GeoPointCopyWith<$Res>? get start;

}
/// @nodoc
class __$RouteSuggestStateCopyWithImpl<$Res>
    implements _$RouteSuggestStateCopyWith<$Res> {
  __$RouteSuggestStateCopyWithImpl(this._self, this._then);

  final _RouteSuggestState _self;
  final $Res Function(_RouteSuggestState) _then;

/// Create a copy of RouteSuggestState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? distanceInput = null,Object? activityType = null,Object? shapePreference = null,Object? start = freezed,Object? startAddress = freezed,Object? searchQuery = null,Object? searchResults = null,Object? isSearching = null,Object? searchError = freezed,Object? suggestions = null,Object? selectedIndex = null,Object? distanceError = freezed,Object? startError = freezed,Object? error = freezed,Object? isLocating = null,Object? locationError = freezed,Object? isSaving = null,Object? saveError = freezed,}) {
  return _then(_RouteSuggestState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SuggestPhase,distanceInput: null == distanceInput ? _self.distanceInput : distanceInput // ignore: cast_nullable_to_non_nullable
as String,activityType: null == activityType ? _self.activityType : activityType // ignore: cast_nullable_to_non_nullable
as ActivityType,shapePreference: null == shapePreference ? _self.shapePreference : shapePreference // ignore: cast_nullable_to_non_nullable
as RouteShapePreference,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as GeoPoint?,startAddress: freezed == startAddress ? _self.startAddress : startAddress // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,searchResults: null == searchResults ? _self._searchResults : searchResults // ignore: cast_nullable_to_non_nullable
as List<LocationSearchResult>,isSearching: null == isSearching ? _self.isSearching : isSearching // ignore: cast_nullable_to_non_nullable
as bool,searchError: freezed == searchError ? _self.searchError : searchError // ignore: cast_nullable_to_non_nullable
as String?,suggestions: null == suggestions ? _self._suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as List<SuggestedRoute>,selectedIndex: null == selectedIndex ? _self.selectedIndex : selectedIndex // ignore: cast_nullable_to_non_nullable
as int,distanceError: freezed == distanceError ? _self.distanceError : distanceError // ignore: cast_nullable_to_non_nullable
as String?,startError: freezed == startError ? _self.startError : startError // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,isLocating: null == isLocating ? _self.isLocating : isLocating // ignore: cast_nullable_to_non_nullable
as bool,locationError: freezed == locationError ? _self.locationError : locationError // ignore: cast_nullable_to_non_nullable
as String?,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,saveError: freezed == saveError ? _self.saveError : saveError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RouteSuggestState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeoPointCopyWith<$Res>? get start {
    if (_self.start == null) {
    return null;
  }

  return $GeoPointCopyWith<$Res>(_self.start!, (value) {
    return _then(_self.copyWith(start: value));
  });
}
}

// dart format on
