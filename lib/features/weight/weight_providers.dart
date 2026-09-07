import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/features/weight/data/drift_weight_repository.dart';
import 'package:menfit_app/features/weight/domain/weight_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weight_providers.g.dart';

/// Composition surface for the `weight` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root's
/// "Delete my data" flow) to reach this feature's persistence: other
/// features may import this file, never `data/` or `presentation/`
/// directly (see `knowledge/decisions/007_cross_feature_providers.md`).
///
/// Typed as the domain interface so nothing above `data/` knows Drift is
/// behind it.
@Riverpod(keepAlive: true)
WeightRepository weightRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftWeightRepository(database);
}
