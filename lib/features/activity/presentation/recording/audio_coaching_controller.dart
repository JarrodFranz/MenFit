import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/features/activity/data/audio_coaching_repository.dart';
import 'package:menfit_app/features/activity/domain/audio_coaching/audio_coaching_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_coaching_controller.g.dart';

@Riverpod(keepAlive: true)
AudioCoachingRepository audioCoachingRepository(Ref ref) {
  try {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AudioCoachingRepository(prefs);
  } on Object catch (_) {
    return const AudioCoachingRepository(null);
  }
}

@Riverpod(keepAlive: true)
class AudioCoachingController extends _$AudioCoachingController {
  @override
  AudioCoachingSettings build() {
    final repository = ref.watch(audioCoachingRepositoryProvider);
    return repository.getSettings();
  }

  Future<void> updateSettings(AudioCoachingSettings updated) async {
    state = updated;
    await ref.read(audioCoachingRepositoryProvider).setSettings(updated);
  }

  Future<void> toggleEnabled({required bool enabled}) async {
    final updated = state.copyWith(enabled: enabled);
    state = updated;
    await ref.read(audioCoachingRepositoryProvider).setSettings(updated);
  }

  Future<void> setCueMode(AudioCueMode mode) async {
    final updated = state.copyWith(cueMode: mode);
    state = updated;
    await ref.read(audioCoachingRepositoryProvider).setSettings(updated);
  }

  Future<void> setSplitIntervalMeters(double? meters) async {
    final updated = state.copyWith(splitIntervalMeters: meters);
    state = updated;
    await ref.read(audioCoachingRepositoryProvider).setSettings(updated);
  }

  Future<void> setAnnouncePace({required bool announce}) async {
    final updated = state.copyWith(announcePace: announce);
    state = updated;
    await ref.read(audioCoachingRepositoryProvider).setSettings(updated);
  }

  Future<void> setAnnounceSplits({required bool announce}) async {
    final updated = state.copyWith(announceSplits: announce);
    state = updated;
    await ref.read(audioCoachingRepositoryProvider).setSettings(updated);
  }

  Future<void> setAnnounceStatusChanges({required bool announce}) async {
    final updated = state.copyWith(announceStatusChanges: announce);
    state = updated;
    await ref.read(audioCoachingRepositoryProvider).setSettings(updated);
  }

  Future<void> setAnnounceMilestones({required bool announce}) async {
    final updated = state.copyWith(announceMilestones: announce);
    state = updated;
    await ref.read(audioCoachingRepositoryProvider).setSettings(updated);
  }
}
