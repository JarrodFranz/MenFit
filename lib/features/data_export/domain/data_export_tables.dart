/// The SQL tables that hold S3-tier health check-in and ketone data, and are
/// therefore left out of a whole-app export unless the user explicitly asks
/// for them.
///
/// Named here in `domain/` rather than inside the exporter because this is a
/// privacy classification, not a persistence detail: it mirrors the grouping
/// `features/settings/application/delete_my_data_service.dart` deletes first
/// ("wellbeing, recovery days") and the S3 row of
/// `knowledge/engineering/security_and_privacy.md`. The exporter reads it,
/// and `test/features/data_export/data_export_table_coverage_test.dart` reads
/// it too — a new table that is neither here nor in that test's inventory
/// fails the build, so nobody can add one without deciding its tier.
///
/// SQL table names (Drift's snake_case of the table class), not Dart class
/// names: this set is compared against `TableInfo.actualTableName`.
const Set<String> sensitiveHealthTables = {
  'daily_checkins',
  'flare_events',
  'recovery_days',
  'wellbeing_events',
  'ketone_readings',
};
