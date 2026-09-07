import 'dart:convert';

import 'package:menfit_app/features/activity/activity_providers.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_file_exporter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_export_service.g.dart';

/// Which file format [ActivityExportService.exportActivity] should render.
enum ActivityExportFormat { gpx, tcx }

/// Result of [ActivityExportService.exportActivity]. Expected outcomes
/// (activity missing, no GPS track for GPX) are values here rather than
/// thrown exceptions, per `knowledge/engineering/error_handling.md`.
sealed class ActivityExportResult {
  const ActivityExportResult();
}

/// Export succeeded. [bytes] is the UTF-8-encoded file content and
/// [filename] a filesystem-safe suggested name (see
/// `ActivityExportService._filenameFor`) - saving or sharing that data is
/// left to the caller (UI/platform concern, wired up separately; see
/// `activity_file_exporter.dart`'s top doc for the wider Task 1.5 context).
final class ActivityExported extends ActivityExportResult {
  const ActivityExported({required this.bytes, required this.filename});

  final List<int> bytes;
  final String filename;
}

/// No non-deleted activity exists with the requested id.
final class ActivityNotFoundForExport extends ActivityExportResult {
  const ActivityNotFoundForExport(this.activityId);

  final String activityId;
}

/// [ActivityExportFormat.gpx] was requested for an activity with no
/// exportable GPS track - see [GpxNotExportable]'s doc for exactly which
/// activities that covers. Never returned for
/// [ActivityExportFormat.tcx]: TCX always succeeds (same doc).
final class ActivityNotExportableAsGpx extends ActivityExportResult {
  const ActivityNotExportableAsGpx(this.reason);

  final String reason;
}

/// Renders a previously recorded/logged activity as a GPX or TCX file for
/// the user to save or share.
///
/// Mirrors `activity_import_service.dart`'s shape, but the direction of
/// data flow is reversed: this loads an [Activity] and its samples via
/// `ActivityRepository` (through the feature's composition surface,
/// `activity_providers.dart` - ADR 007) and hands back file bytes, rather
/// than parsing a picked file into the repository. It never touches a
/// file picker, a share sheet, or `dart:io` itself - that belongs to
/// whichever presentation-layer code wires this up, not this
/// application-layer service.
class ActivityExportService {
  const ActivityExportService({
    required this.ref,
    this.exporter = const ActivityFileExporter(),
  });

  final Ref ref;
  final ActivityFileExporter exporter;

  /// Loads the activity with [activityId] and its samples, and renders
  /// them as [format].
  Future<ActivityExportResult> exportActivity(
    String activityId, {
    required ActivityExportFormat format,
  }) async {
    final repo = ref.read(activityRepositoryProvider);
    final activity = await repo.getActivity(activityId);
    if (activity == null) {
      return ActivityNotFoundForExport(activityId);
    }

    final samples = await repo.getSamples(activityId);

    final String content;
    if (format == ActivityExportFormat.tcx) {
      content = exporter.exportTcx(activity, samples);
    } else {
      final outcome = exporter.exportGpx(activity, samples);
      if (outcome is GpxNotExportable) {
        return ActivityNotExportableAsGpx(outcome.reason);
      }
      content = (outcome as GpxExported).xml;
    }

    return ActivityExported(
      bytes: utf8.encode(content),
      filename: _filenameFor(activity, format),
    );
  }

  /// e.g. `femfit-run-2026-09-01-morning-tempo-run.gpx`. Built from the
  /// activity's date and type plus a slugified title, rather than the
  /// title alone, so two activities on the same day never collide and an
  /// empty/whitespace-only title still produces a sensible name.
  String _filenameFor(Activity activity, ActivityExportFormat format) {
    final datePart = activity.startedAt.toUtc().toIso8601String().substring(
      0,
      10,
    );
    final typePart = activity.activityType.toStorage();
    final titleSlug = _slugify(activity.title);
    final extension = format == ActivityExportFormat.gpx ? 'gpx' : 'tcx';
    final base = titleSlug.isEmpty
        ? 'femfit-$typePart-$datePart'
        : 'femfit-$typePart-$datePart-$titleSlug';
    return '$base.$extension';
  }

  /// Reduces free-form user text to a filesystem-safe slug: lowercased,
  /// with every run of characters outside `a-z0-9` collapsed to a single
  /// hyphen, and capped in length. [Activity.title] is user-entered and
  /// therefore untrusted here - without this, a title containing `/`,
  /// `\`, `..`, or control characters could otherwise reach a filename
  /// (a path separator turning one path segment into several, or a
  /// Windows-illegal character breaking the save/share call entirely).
  /// Restricting the surviving alphabet to `a-z0-9` and `-` makes every
  /// one of those impossible by construction rather than by denylisting
  /// specific characters.
  static String _slugify(String input) {
    final collapsed = input.toLowerCase().replaceAll(
      RegExp('[^a-z0-9]+'),
      '-',
    );
    final trimmed = collapsed.replaceAll(RegExp(r'^-+|-+$'), '');
    return trimmed.length > 40 ? trimmed.substring(0, 40) : trimmed;
  }
}

/// Provider for [ActivityExportService].
///
/// `keepAlive` because the service holds the [Ref] it later reads the
/// activity repository from: an autoDispose provider's ref can be disposed
/// between construction and the `exportActivity` call it is used in, and
/// reading a disposed ref throws. It is app-scoped and stateless anyway,
/// like every other service on a composition surface here.
@Riverpod(keepAlive: true)
ActivityExportService activityExportService(Ref ref) {
  return ActivityExportService(ref: ref);
}
