import 'package:menfit_app/core/domain/local_date.dart';
import 'package:menfit_app/features/keto/domain/ketone_reading.dart';

/// Local-first S3 storage; deletion removes the row permanently.
abstract interface class KetoneRepository {
  /// Multiple readings per day, oldest measured instant first, then creation
  /// instant and id to make ties deterministic.
  Stream<List<KetoneReading>> watchReadingsForDay(LocalDate day);

  /// Upserts by id while preserving the original creation timestamp.
  Future<void> saveReading(KetoneReading reading);

  Future<void> deleteReading(String id);

  Future<void> deleteAllData();
}
