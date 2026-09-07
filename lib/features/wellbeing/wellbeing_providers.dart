import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/features/wellbeing/data/drift_wellbeing_repository.dart';
import 'package:menfit_app/features/wellbeing/domain/wellbeing_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:menfit_app/features/wellbeing/presentation/wellbeing_watch_providers.dart';

part 'wellbeing_providers.g.dart';

/// Composition surface for the `wellbeing` feature (ADR 007).
///
/// The only legal way for another feature (e.g. `home`'s check-in card, or
/// the future streak `DayStatus` evolution reading flare impact) to reach
/// this feature's persistence: other features may import this file, never
/// `data/` or `presentation/` directly.
@Riverpod(keepAlive: true)
WellbeingRepository wellbeingRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return DriftWellbeingRepository(database);
}
