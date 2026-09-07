// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio_coaching_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AudioCoachingSettings {

/// Whether audio coaching cues are enabled globally for recordings.
 bool get enabled;/// Preferred unit system for spoken announcements.
 UnitSystem get unitSystem;/// Sound mode: voice + chime, voice only, or chime only.
 AudioCueMode get cueMode;/// Distance interval in metres between periodic split announcements.
/// If null, defaults to 1,000 m (1 km) or 1,609.344 m (1 mile) based on
/// the user's unit system.
 double? get splitIntervalMeters;/// Whether to announce periodic split milestones (e.g. at every km/mile).
 bool get announceSplits;/// Whether split announcements include the split pace.
 bool get announcePace;/// Whether to announce workout status changes (start, pause, resume).
 bool get announceStatusChanges;/// Whether to announce distance milestones (e.g. 5k, 10k).
 bool get announceMilestones;/// Speech rate between 0.0 and 1.0 (default 0.5 for natural pacing).
 double get speechRate;/// Speech volume between 0.0 and 1.0.
 double get volume;
/// Create a copy of AudioCoachingSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AudioCoachingSettingsCopyWith<AudioCoachingSettings> get copyWith => _$AudioCoachingSettingsCopyWithImpl<AudioCoachingSettings>(this as AudioCoachingSettings, _$identity);

  /// Serializes this AudioCoachingSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudioCoachingSettings&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.unitSystem, unitSystem) || other.unitSystem == unitSystem)&&(identical(other.cueMode, cueMode) || other.cueMode == cueMode)&&(identical(other.splitIntervalMeters, splitIntervalMeters) || other.splitIntervalMeters == splitIntervalMeters)&&(identical(other.announceSplits, announceSplits) || other.announceSplits == announceSplits)&&(identical(other.announcePace, announcePace) || other.announcePace == announcePace)&&(identical(other.announceStatusChanges, announceStatusChanges) || other.announceStatusChanges == announceStatusChanges)&&(identical(other.announceMilestones, announceMilestones) || other.announceMilestones == announceMilestones)&&(identical(other.speechRate, speechRate) || other.speechRate == speechRate)&&(identical(other.volume, volume) || other.volume == volume));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,unitSystem,cueMode,splitIntervalMeters,announceSplits,announcePace,announceStatusChanges,announceMilestones,speechRate,volume);

@override
String toString() {
  return 'AudioCoachingSettings(enabled: $enabled, unitSystem: $unitSystem, cueMode: $cueMode, splitIntervalMeters: $splitIntervalMeters, announceSplits: $announceSplits, announcePace: $announcePace, announceStatusChanges: $announceStatusChanges, announceMilestones: $announceMilestones, speechRate: $speechRate, volume: $volume)';
}


}

/// @nodoc
abstract mixin class $AudioCoachingSettingsCopyWith<$Res>  {
  factory $AudioCoachingSettingsCopyWith(AudioCoachingSettings value, $Res Function(AudioCoachingSettings) _then) = _$AudioCoachingSettingsCopyWithImpl;
@useResult
$Res call({
 bool enabled, UnitSystem unitSystem, AudioCueMode cueMode, double? splitIntervalMeters, bool announceSplits, bool announcePace, bool announceStatusChanges, bool announceMilestones, double speechRate, double volume
});




}
/// @nodoc
class _$AudioCoachingSettingsCopyWithImpl<$Res>
    implements $AudioCoachingSettingsCopyWith<$Res> {
  _$AudioCoachingSettingsCopyWithImpl(this._self, this._then);

  final AudioCoachingSettings _self;
  final $Res Function(AudioCoachingSettings) _then;

/// Create a copy of AudioCoachingSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? unitSystem = null,Object? cueMode = null,Object? splitIntervalMeters = freezed,Object? announceSplits = null,Object? announcePace = null,Object? announceStatusChanges = null,Object? announceMilestones = null,Object? speechRate = null,Object? volume = null,}) {
  return _then(AudioCoachingSettings(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,unitSystem: null == unitSystem ? _self.unitSystem : unitSystem // ignore: cast_nullable_to_non_nullable
as UnitSystem,cueMode: null == cueMode ? _self.cueMode : cueMode // ignore: cast_nullable_to_non_nullable
as AudioCueMode,splitIntervalMeters: freezed == splitIntervalMeters ? _self.splitIntervalMeters : splitIntervalMeters // ignore: cast_nullable_to_non_nullable
as double?,announceSplits: null == announceSplits ? _self.announceSplits : announceSplits // ignore: cast_nullable_to_non_nullable
as bool,announcePace: null == announcePace ? _self.announcePace : announcePace // ignore: cast_nullable_to_non_nullable
as bool,announceStatusChanges: null == announceStatusChanges ? _self.announceStatusChanges : announceStatusChanges // ignore: cast_nullable_to_non_nullable
as bool,announceMilestones: null == announceMilestones ? _self.announceMilestones : announceMilestones // ignore: cast_nullable_to_non_nullable
as bool,speechRate: null == speechRate ? _self.speechRate : speechRate // ignore: cast_nullable_to_non_nullable
as double,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [AudioCoachingSettings].
extension AudioCoachingSettingsPatterns on AudioCoachingSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AudioCoachingSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AudioCoachingSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AudioCoachingSettings value)  $default,){
final _that = this;
switch (_that) {
case _AudioCoachingSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AudioCoachingSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AudioCoachingSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  UnitSystem unitSystem,  AudioCueMode cueMode,  double? splitIntervalMeters,  bool announceSplits,  bool announcePace,  bool announceStatusChanges,  bool announceMilestones,  double speechRate,  double volume)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AudioCoachingSettings() when $default != null:
return $default(_that.enabled,_that.unitSystem,_that.cueMode,_that.splitIntervalMeters,_that.announceSplits,_that.announcePace,_that.announceStatusChanges,_that.announceMilestones,_that.speechRate,_that.volume);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  UnitSystem unitSystem,  AudioCueMode cueMode,  double? splitIntervalMeters,  bool announceSplits,  bool announcePace,  bool announceStatusChanges,  bool announceMilestones,  double speechRate,  double volume)  $default,) {final _that = this;
switch (_that) {
case _AudioCoachingSettings():
return $default(_that.enabled,_that.unitSystem,_that.cueMode,_that.splitIntervalMeters,_that.announceSplits,_that.announcePace,_that.announceStatusChanges,_that.announceMilestones,_that.speechRate,_that.volume);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  UnitSystem unitSystem,  AudioCueMode cueMode,  double? splitIntervalMeters,  bool announceSplits,  bool announcePace,  bool announceStatusChanges,  bool announceMilestones,  double speechRate,  double volume)?  $default,) {final _that = this;
switch (_that) {
case _AudioCoachingSettings() when $default != null:
return $default(_that.enabled,_that.unitSystem,_that.cueMode,_that.splitIntervalMeters,_that.announceSplits,_that.announcePace,_that.announceStatusChanges,_that.announceMilestones,_that.speechRate,_that.volume);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AudioCoachingSettings implements AudioCoachingSettings {
  const _AudioCoachingSettings({this.enabled = true, this.unitSystem = UnitSystem.metric, this.cueMode = AudioCueMode.voiceAndChime, this.splitIntervalMeters, this.announceSplits = true, this.announcePace = true, this.announceStatusChanges = true, this.announceMilestones = true, this.speechRate = 0.5, this.volume = 1.0});
  factory _AudioCoachingSettings.fromJson(Map<String, dynamic> json) => _$AudioCoachingSettingsFromJson(json);

/// Whether audio coaching cues are enabled globally for recordings.
@override@JsonKey() final  bool enabled;
/// Preferred unit system for spoken announcements.
@override@JsonKey() final  UnitSystem unitSystem;
/// Sound mode: voice + chime, voice only, or chime only.
@override@JsonKey() final  AudioCueMode cueMode;
/// Distance interval in metres between periodic split announcements.
/// If null, defaults to 1,000 m (1 km) or 1,609.344 m (1 mile) based on
/// the user's unit system.
@override final  double? splitIntervalMeters;
/// Whether to announce periodic split milestones (e.g. at every km/mile).
@override@JsonKey() final  bool announceSplits;
/// Whether split announcements include the split pace.
@override@JsonKey() final  bool announcePace;
/// Whether to announce workout status changes (start, pause, resume).
@override@JsonKey() final  bool announceStatusChanges;
/// Whether to announce distance milestones (e.g. 5k, 10k).
@override@JsonKey() final  bool announceMilestones;
/// Speech rate between 0.0 and 1.0 (default 0.5 for natural pacing).
@override@JsonKey() final  double speechRate;
/// Speech volume between 0.0 and 1.0.
@override@JsonKey() final  double volume;

/// Create a copy of AudioCoachingSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AudioCoachingSettingsCopyWith<_AudioCoachingSettings> get copyWith => __$AudioCoachingSettingsCopyWithImpl<_AudioCoachingSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AudioCoachingSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AudioCoachingSettings&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.unitSystem, unitSystem) || other.unitSystem == unitSystem)&&(identical(other.cueMode, cueMode) || other.cueMode == cueMode)&&(identical(other.splitIntervalMeters, splitIntervalMeters) || other.splitIntervalMeters == splitIntervalMeters)&&(identical(other.announceSplits, announceSplits) || other.announceSplits == announceSplits)&&(identical(other.announcePace, announcePace) || other.announcePace == announcePace)&&(identical(other.announceStatusChanges, announceStatusChanges) || other.announceStatusChanges == announceStatusChanges)&&(identical(other.announceMilestones, announceMilestones) || other.announceMilestones == announceMilestones)&&(identical(other.speechRate, speechRate) || other.speechRate == speechRate)&&(identical(other.volume, volume) || other.volume == volume));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,unitSystem,cueMode,splitIntervalMeters,announceSplits,announcePace,announceStatusChanges,announceMilestones,speechRate,volume);

@override
String toString() {
  return 'AudioCoachingSettings(enabled: $enabled, unitSystem: $unitSystem, cueMode: $cueMode, splitIntervalMeters: $splitIntervalMeters, announceSplits: $announceSplits, announcePace: $announcePace, announceStatusChanges: $announceStatusChanges, announceMilestones: $announceMilestones, speechRate: $speechRate, volume: $volume)';
}


}

/// @nodoc
abstract mixin class _$AudioCoachingSettingsCopyWith<$Res> implements $AudioCoachingSettingsCopyWith<$Res> {
  factory _$AudioCoachingSettingsCopyWith(_AudioCoachingSettings value, $Res Function(_AudioCoachingSettings) _then) = __$AudioCoachingSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, UnitSystem unitSystem, AudioCueMode cueMode, double? splitIntervalMeters, bool announceSplits, bool announcePace, bool announceStatusChanges, bool announceMilestones, double speechRate, double volume
});




}
/// @nodoc
class __$AudioCoachingSettingsCopyWithImpl<$Res>
    implements _$AudioCoachingSettingsCopyWith<$Res> {
  __$AudioCoachingSettingsCopyWithImpl(this._self, this._then);

  final _AudioCoachingSettings _self;
  final $Res Function(_AudioCoachingSettings) _then;

/// Create a copy of AudioCoachingSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? unitSystem = null,Object? cueMode = null,Object? splitIntervalMeters = freezed,Object? announceSplits = null,Object? announcePace = null,Object? announceStatusChanges = null,Object? announceMilestones = null,Object? speechRate = null,Object? volume = null,}) {
  return _then(_AudioCoachingSettings(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,unitSystem: null == unitSystem ? _self.unitSystem : unitSystem // ignore: cast_nullable_to_non_nullable
as UnitSystem,cueMode: null == cueMode ? _self.cueMode : cueMode // ignore: cast_nullable_to_non_nullable
as AudioCueMode,splitIntervalMeters: freezed == splitIntervalMeters ? _self.splitIntervalMeters : splitIntervalMeters // ignore: cast_nullable_to_non_nullable
as double?,announceSplits: null == announceSplits ? _self.announceSplits : announceSplits // ignore: cast_nullable_to_non_nullable
as bool,announcePace: null == announcePace ? _self.announcePace : announcePace // ignore: cast_nullable_to_non_nullable
as bool,announceStatusChanges: null == announceStatusChanges ? _self.announceStatusChanges : announceStatusChanges // ignore: cast_nullable_to_non_nullable
as bool,announceMilestones: null == announceMilestones ? _self.announceMilestones : announceMilestones // ignore: cast_nullable_to_non_nullable
as bool,speechRate: null == speechRate ? _self.speechRate : speechRate // ignore: cast_nullable_to_non_nullable
as double,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
