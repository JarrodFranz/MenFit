import 'package:menfit_app/core/db/app_database_provider.dart';
import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/keto/data/drift_ketone_repository.dart';
import 'package:menfit_app/features/keto/domain/ketone_reading.dart';
import 'package:menfit_app/features/keto/domain/ketone_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'keto_providers.g.dart';

@Riverpod(keepAlive: true)
KetoneRepository ketoneRepository(Ref ref) =>
    DriftKetoneRepository(ref.watch(appDatabaseProvider));

@riverpod
Stream<List<KetoneReading>> ketoneReadings(Ref ref, LocalDate day) =>
    ref.watch(ketoneRepositoryProvider).watchReadingsForDay(day);
