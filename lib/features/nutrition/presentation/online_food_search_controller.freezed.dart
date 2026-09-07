// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'online_food_search_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnlineFoodSearchState {

 List<ProviderFoodSummary> get results; bool get isSearching;/// Whether a search has been run at all in this session — what tells an
/// empty results list apart from a region nobody has asked anything of
/// yet.
 bool get hasSearched;/// Whether a further page is worth asking for. Goes `false` the moment
/// a short page arrives, which is the provider's only end-of-results
/// signal.
 bool get hasMore;/// Ready-to-show copy, never the query itself — S2.
 String? get errorMessage;/// The query the current results belong to, kept so
/// [OnlineFoodSearchController.loadMore] pages the same search rather
/// than whatever is in the field by then.
 String get query;/// Last page fetched; the next request asks for this plus one.
 int get page;
/// Create a copy of OnlineFoodSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnlineFoodSearchStateCopyWith<OnlineFoodSearchState> get copyWith => _$OnlineFoodSearchStateCopyWithImpl<OnlineFoodSearchState>(this as OnlineFoodSearchState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnlineFoodSearchState&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.isSearching, isSearching) || other.isSearching == isSearching)&&(identical(other.hasSearched, hasSearched) || other.hasSearched == hasSearched)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.query, query) || other.query == query)&&(identical(other.page, page) || other.page == page));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(results),isSearching,hasSearched,hasMore,errorMessage,query,page);

@override
String toString() {
  return 'OnlineFoodSearchState(results: $results, isSearching: $isSearching, hasSearched: $hasSearched, hasMore: $hasMore, errorMessage: $errorMessage, query: $query, page: $page)';
}


}

/// @nodoc
abstract mixin class $OnlineFoodSearchStateCopyWith<$Res>  {
  factory $OnlineFoodSearchStateCopyWith(OnlineFoodSearchState value, $Res Function(OnlineFoodSearchState) _then) = _$OnlineFoodSearchStateCopyWithImpl;
@useResult
$Res call({
 List<ProviderFoodSummary> results, bool isSearching, bool hasSearched, bool hasMore, String? errorMessage, String query, int page
});




}
/// @nodoc
class _$OnlineFoodSearchStateCopyWithImpl<$Res>
    implements $OnlineFoodSearchStateCopyWith<$Res> {
  _$OnlineFoodSearchStateCopyWithImpl(this._self, this._then);

  final OnlineFoodSearchState _self;
  final $Res Function(OnlineFoodSearchState) _then;

/// Create a copy of OnlineFoodSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? results = null,Object? isSearching = null,Object? hasSearched = null,Object? hasMore = null,Object? errorMessage = freezed,Object? query = null,Object? page = null,}) {
  return _then(OnlineFoodSearchState(
results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<ProviderFoodSummary>,isSearching: null == isSearching ? _self.isSearching : isSearching // ignore: cast_nullable_to_non_nullable
as bool,hasSearched: null == hasSearched ? _self.hasSearched : hasSearched // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OnlineFoodSearchState].
extension OnlineFoodSearchStatePatterns on OnlineFoodSearchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnlineFoodSearchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnlineFoodSearchState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnlineFoodSearchState value)  $default,){
final _that = this;
switch (_that) {
case _OnlineFoodSearchState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnlineFoodSearchState value)?  $default,){
final _that = this;
switch (_that) {
case _OnlineFoodSearchState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ProviderFoodSummary> results,  bool isSearching,  bool hasSearched,  bool hasMore,  String? errorMessage,  String query,  int page)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnlineFoodSearchState() when $default != null:
return $default(_that.results,_that.isSearching,_that.hasSearched,_that.hasMore,_that.errorMessage,_that.query,_that.page);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ProviderFoodSummary> results,  bool isSearching,  bool hasSearched,  bool hasMore,  String? errorMessage,  String query,  int page)  $default,) {final _that = this;
switch (_that) {
case _OnlineFoodSearchState():
return $default(_that.results,_that.isSearching,_that.hasSearched,_that.hasMore,_that.errorMessage,_that.query,_that.page);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ProviderFoodSummary> results,  bool isSearching,  bool hasSearched,  bool hasMore,  String? errorMessage,  String query,  int page)?  $default,) {final _that = this;
switch (_that) {
case _OnlineFoodSearchState() when $default != null:
return $default(_that.results,_that.isSearching,_that.hasSearched,_that.hasMore,_that.errorMessage,_that.query,_that.page);case _:
  return null;

}
}

}

/// @nodoc


class _OnlineFoodSearchState implements OnlineFoodSearchState {
  const _OnlineFoodSearchState({ List<ProviderFoodSummary> results = const <ProviderFoodSummary>[], this.isSearching = false, this.hasSearched = false, this.hasMore = false, this.errorMessage, this.query = '', this.page = 0}): _results = results;
  

 final  List<ProviderFoodSummary> _results;
@override@JsonKey() List<ProviderFoodSummary> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override@JsonKey() final  bool isSearching;
/// Whether a search has been run at all in this session — what tells an
/// empty results list apart from a region nobody has asked anything of
/// yet.
@override@JsonKey() final  bool hasSearched;
/// Whether a further page is worth asking for. Goes `false` the moment
/// a short page arrives, which is the provider's only end-of-results
/// signal.
@override@JsonKey() final  bool hasMore;
/// Ready-to-show copy, never the query itself — S2.
@override final  String? errorMessage;
/// The query the current results belong to, kept so
/// [OnlineFoodSearchController.loadMore] pages the same search rather
/// than whatever is in the field by then.
@override@JsonKey() final  String query;
/// Last page fetched; the next request asks for this plus one.
@override@JsonKey() final  int page;

/// Create a copy of OnlineFoodSearchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnlineFoodSearchStateCopyWith<_OnlineFoodSearchState> get copyWith => __$OnlineFoodSearchStateCopyWithImpl<_OnlineFoodSearchState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnlineFoodSearchState&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.isSearching, isSearching) || other.isSearching == isSearching)&&(identical(other.hasSearched, hasSearched) || other.hasSearched == hasSearched)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.query, query) || other.query == query)&&(identical(other.page, page) || other.page == page));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_results),isSearching,hasSearched,hasMore,errorMessage,query,page);

@override
String toString() {
  return 'OnlineFoodSearchState(results: $results, isSearching: $isSearching, hasSearched: $hasSearched, hasMore: $hasMore, errorMessage: $errorMessage, query: $query, page: $page)';
}


}

/// @nodoc
abstract mixin class _$OnlineFoodSearchStateCopyWith<$Res> implements $OnlineFoodSearchStateCopyWith<$Res> {
  factory _$OnlineFoodSearchStateCopyWith(_OnlineFoodSearchState value, $Res Function(_OnlineFoodSearchState) _then) = __$OnlineFoodSearchStateCopyWithImpl;
@override @useResult
$Res call({
 List<ProviderFoodSummary> results, bool isSearching, bool hasSearched, bool hasMore, String? errorMessage, String query, int page
});




}
/// @nodoc
class __$OnlineFoodSearchStateCopyWithImpl<$Res>
    implements _$OnlineFoodSearchStateCopyWith<$Res> {
  __$OnlineFoodSearchStateCopyWithImpl(this._self, this._then);

  final _OnlineFoodSearchState _self;
  final $Res Function(_OnlineFoodSearchState) _then;

/// Create a copy of OnlineFoodSearchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? results = null,Object? isSearching = null,Object? hasSearched = null,Object? hasMore = null,Object? errorMessage = freezed,Object? query = null,Object? page = null,}) {
  return _then(_OnlineFoodSearchState(
results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<ProviderFoodSummary>,isSearching: null == isSearching ? _self.isSearching : isSearching // ignore: cast_nullable_to_non_nullable
as bool,hasSearched: null == hasSearched ? _self.hasSearched : hasSearched // ignore: cast_nullable_to_non_nullable
as bool,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
