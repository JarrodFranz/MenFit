import 'dart:convert';

import 'package:menfit_app/features/cycle/domain/cycle_record.dart';

/// Exports cycle data to CSV and JSON formats for backup and portability.
class CycleDataExporter {
  const CycleDataExporter();

  /// Exports [records] to standard CSV format.
  String exportToCsv(List<CycleRecord> records) {
    final buffer = StringBuffer()
      ..writeln('Period Start,Period End,Duration (Days),Status');

    final sorted = List<CycleRecord>.from(records)
      ..sort((a, b) => a.periodStart.compareTo(b.periodStart));

    for (final r in sorted) {
      final start = r.periodStart.toIso();
      final end = r.periodEnd?.toIso() ?? '';
      final duration = r.periodEnd != null
          ? (r.periodStart.difference(r.periodEnd!) + 1).toString()
          : '';
      final status = r.isOngoing ? 'Ongoing' : 'Completed';

      buffer.writeln('$start,$end,$duration,$status');
    }

    return buffer.toString();
  }

  /// Exports [records] to standard JSON format.
  String exportToJson(List<CycleRecord> records) {
    final sorted = List<CycleRecord>.from(records)
      ..sort((a, b) => a.periodStart.compareTo(b.periodStart));

    final mapList = sorted.map((r) {
      return {
        'id': r.id,
        'periodStart': r.periodStart.toIso(),
        'periodEnd': r.periodEnd?.toIso(),
        'isOngoing': r.isOngoing,
        'createdAt': r.createdAt.toIso8601String(),
        'updatedAt': r.updatedAt.toIso8601String(),
      };
    }).toList();

    return const JsonEncoder.withIndent('  ').convert({
      'version': '1.0',
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'records': mapList,
    });
  }
}
