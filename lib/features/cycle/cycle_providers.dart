import 'package:menfit_app/core/config/shared_preferences_provider.dart';
import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/features/cycle/data/drift_cycle_repository.dart';
import 'package:menfit_app/features/cycle/domain/cycle_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:menfit_app/features/cycle/presentation/cycle_records_controller.dart';

part 'cycle_providers.g.dart';

/// Composition surface for the `cycle` feature (ADR 007).
///
/// The only legal way for another feature (or the composition root) to
/// reach this feature's persistence: other features may import this file,
/// never `data/` or `presentation/` directly - the streak engine (next
/// wave) will depend on this to read confirmed period records via
/// `domain/period_days.dart`'s pure functions.
@Riverpod(keepAlive: true)
CycleRepository cycleRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  final preferences = ref.watch(sharedPreferencesProvider);
  return DriftCycleRepository(database, preferences);
}
