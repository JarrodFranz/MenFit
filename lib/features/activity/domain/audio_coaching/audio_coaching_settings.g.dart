// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_coaching_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AudioCoachingSettings _$AudioCoachingSettingsFromJson(
  Map<String, dynamic> json,
) => _AudioCoachingSettings(
  enabled: json['enabled'] as bool? ?? true,
  unitSystem:
      $enumDecodeNullable(_$UnitSystemEnumMap, json['unitSystem']) ??
      UnitSystem.metric,
  cueMode:
      $enumDecodeNullable(_$AudioCueModeEnumMap, json['cueMode']) ??
      AudioCueMode.voiceAndChime,
  splitIntervalMeters: (json['splitIntervalMeters'] as num?)?.toDouble(),
  announceSplits: json['announceSplits'] as bool? ?? true,
  announcePace: json['announcePace'] as bool? ?? true,
  announceStatusChanges: json['announceStatusChanges'] as bool? ?? true,
  announceMilestones: json['announceMilestones'] as bool? ?? true,
  speechRate: (json['speechRate'] as num?)?.toDouble() ?? 0.5,
  volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
);

Map<String, dynamic> _$AudioCoachingSettingsToJson(
  _AudioCoachingSettings instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'unitSystem': _$UnitSystemEnumMap[instance.unitSystem]!,
  'cueMode': _$AudioCueModeEnumMap[instance.cueMode]!,
  'splitIntervalMeters': instance.splitIntervalMeters,
  'announceSplits': instance.announceSplits,
  'announcePace': instance.announcePace,
  'announceStatusChanges': instance.announceStatusChanges,
  'announceMilestones': instance.announceMilestones,
  'speechRate': instance.speechRate,
  'volume': instance.volume,
};

const _$UnitSystemEnumMap = {
  UnitSystem.metric: 'metric',
  UnitSystem.imperial: 'imperial',
};

const _$AudioCueModeEnumMap = {
  AudioCueMode.voiceAndChime: 'voiceAndChime',
  AudioCueMode.voiceOnly: 'voiceOnly',
  AudioCueMode.chimeOnly: 'chimeOnly',
};
