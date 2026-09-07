import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/features/profile/data/drift_profile_repository.dart';
import 'package:menfit_app/features/profile/domain/profile_repository.dart';
import 'package:menfit_app/features/profile/domain/user_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_providers.g.dart';

/// Composition surface for the `profile` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root) to
/// reach this feature's persistence: other features may import this file,
/// never `data/` or `presentation/` directly (see
/// `knowledge/decisions/007_cross_feature_providers.md`).
@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftProfileRepository(database);
}

@riverpod
Stream<UserProfile?> userProfile(Ref ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.watchProfile();
}
