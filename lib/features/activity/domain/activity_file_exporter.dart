import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:xml/xml.dart';

/// Renders a recorded/logged [Activity] and its [ActivitySample]s as GPX
/// 1.1 or Garmin TCX, for the user to save or share (e.g. to hand-import
/// into Strava or Garmin Connect - see `TASKS_TO_DO.md` Task 1.5; the
/// OAuth/direct-upload half of that task is a separate, deferred piece of
/// work and shares nothing with this file). This is the writer counterpart
/// of `activity_file_importer.dart` - read that file's doc first.
///
/// ## Decision: paused samples are excluded from the exported track
/// `ActivitySample.isPaused` marks a sample accepted while the recording
/// was paused (manually or automatically - see `recording_session.dart`).
/// `track_analysis.dart`'s splits/best-effort analytics already treat
/// paused samples as outside any segment - they contribute no distance and
/// no time to the activity's own stats. GPX/TCX have no `isPaused`
/// equivalent, so a paused sample handed to an external consumer (Strava,
/// Garmin Connect, or our own re-import) would silently count as real
/// track data and skew whatever distance/pace/moving-time it recomputes
/// from the points - exactly the miscount `track_analysis.dart` was built
/// to avoid internally. This file makes the same call for exported files:
/// [_trackPoints] drops every `isPaused` sample before either format is
/// built. The one deliberate exception is
/// `presentation/widgets/route_map.dart`, which draws every sample
/// (including paused ones) for visual continuity on-screen - that's a
/// rendering concern local to that widget, not a property of the
/// exported file.
///
/// ## Decision: activities with no GPS track
/// GPX is meaningless without trackpoints, so [exportGpx] never fabricates
/// coordinates or emits an empty `<trkseg>` - it returns a typed
/// [GpxNotExportable] outcome instead (e.g. for `strength`/`yoga`/`hiit`/
/// indoor `swim` activities, or a `recorded` activity whose every sample
/// happened to be paused). [exportTcx] always succeeds: when there are no
/// usable points it still emits the `Lap` with `TotalTimeSeconds`/
/// `DistanceMeters` from the [Activity] record itself, simply omitting the
/// `Track` element (legal per the TCX schema, where `Track` is optional
/// and repeatable) - the file is a valid duration+distance record even
/// though it carries no route.
///
/// ## Decision: activity type mapping is the importer's, reversed
/// [_exportTypeString] must round-trip through
/// `ActivityFileImporter._mapActivityType`'s keyword matching so a file
/// this class writes parses back to the same [ActivityType]
/// (`activity_file_importer_test.dart` / this file's own round-trip
/// tests). That method is private to its own file, so it can't be called
/// directly from here - the strings below were chosen and tested against
/// its documented keyword logic rather than by inventing an unrelated
/// table, but the two mappings still live as separate literals that must
/// be kept in sync by hand. Extracting a single shared mapping function
/// both files import would remove that duplication; flagged for a
/// follow-up refactor rather than done here since it would mean editing
/// `activity_file_importer.dart`, outside this change's scope. Only
/// `run`/`walk`/`hike`/`ride` round-trip to themselves - the importer's
/// keyword matching has no branch for strength/yoga/hiit/pilates/swim/
/// other, so those always default back to `run` on re-import. That's an
/// existing, pre-dating asymmetry of the importer, not something
/// introduced here; those activity types are also the ones with no GPS
/// track in the first place; round-tripping them through the importer
/// isn't really meaningful (the importer requires at least one
/// trackpoint and throws otherwise).
class ActivityFileExporter {
  const ActivityFileExporter();

  /// Renders [activity] and [samples] as a GPX 1.1 document, or an
  /// outcome explaining why it can't be (see class doc). Namespaces
  /// declared on the root: the base GPX 1.1 namespace, and
  /// `gpxtpx` (Garmin's `TrackPointExtension`) for heart rate - several
  /// importers (including Strava's, per this task's research) key off the
  /// literal `gpxtpx` prefix rather than resolving the namespace URI, so
  /// that literal prefix is used for every extension element rather than
  /// letting the XML builder pick one.
  GpxExportOutcome exportGpx(Activity activity, List<ActivitySample> samples) {
    final points = _trackPoints(samples);
    if (points.isEmpty) {
      return const GpxNotExportable(
        'This activity has no GPS track to export as GPX.',
      );
    }

    // Initialised BEFORE the cascade below: `nest` closures execute
    // synchronously inside `XmlBuilder.element`, i.e. while the enclosing
    // expression is still evaluating - so `builder` must already hold the
    // instance when the first closure runs (a `late` local assigned by the
    // same cascade expression throws LateInitializationError here).
    final builder = XmlBuilder();
    builder
      ..declaration(encoding: 'UTF-8')
      ..element(
        'gpx',
        attributes: {
          'version': '1.1',
          'creator': 'MenFit',
          'xmlns': 'http://www.topografix.com/GPX/1/1',
          'xmlns:gpxtpx':
              'http://www.garmin.com/xmlschemas/TrackPointExtension/v1',
        },
        nest: () {
          builder.element(
            'metadata',
            nest: () => builder.element(
              'time',
              nest: _isoUtc(activity.startedAt),
            ),
          );
          builder.element(
            'trk',
            nest: () {
              builder
                ..element('name', nest: activity.title)
                ..element(
                  'type',
                  nest: _exportTypeString(activity.activityType),
                )
                ..element(
                  'trkseg',
                  nest: () {
                    for (final sample in points) {
                      _writeGpxTrackpoint(builder, sample);
                    }
                  },
                );
            },
          );
        },
      );

    return GpxExported(builder.buildDocument().toXmlString(pretty: true));
  }

  void _writeGpxTrackpoint(XmlBuilder builder, ActivitySample sample) {
    builder.element(
      'trkpt',
      attributes: {
        'lat': sample.latitude.toString(),
        'lon': sample.longitude.toString(),
      },
      nest: () {
        if (sample.elevationMeters != null) {
          builder.element('ele', nest: sample.elevationMeters!.toString());
        }
        builder.element('time', nest: _isoUtc(sample.timestamp));
        if (sample.heartRate != null) {
          builder.element(
            'extensions',
            nest: () => builder.element(
              'gpxtpx:TrackPointExtension',
              nest: () => builder.element(
                'gpxtpx:hr',
                nest: sample.heartRate.toString(),
              ),
            ),
          );
        }
      },
    );
  }

  /// Renders [activity] and [samples] as a Garmin Training Center Database
  /// (TCX) document. Always succeeds (see class doc) - the single `Lap`
  /// carries [Activity.elapsedTime]/[Activity.distanceMeters] regardless
  /// of whether there's a usable track, and only gains a `Track` element
  /// when [samples] has at least one non-paused point.
  String exportTcx(Activity activity, List<ActivitySample> samples) {
    final points = _trackPoints(samples);

    // See the matching comment in [exportGpx]: initialise before cascading.
    final builder = XmlBuilder();
    builder
      ..declaration(encoding: 'UTF-8')
      ..element(
        'TrainingCenterDatabase',
        attributes: {
          'xmlns': 'http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2',
        },
        nest: () {
          builder.element(
            'Activities',
            nest: () {
              builder.element(
                'Activity',
                attributes: {
                  'Sport': _exportTypeString(activity.activityType),
                },
                nest: () {
                  builder.element('Id', nest: _isoUtc(activity.startedAt));
                  builder.element(
                    'Lap',
                    attributes: {'StartTime': _isoUtc(activity.startedAt)},
                    nest: () {
                      // Calories/Intensity/TriggerMethod aren't tracked by
                      // this app but are mandatory per the TCX schema - a
                      // fixed, honest-about-being-unknown placeholder for
                      // each keeps the file schema-valid for consumers
                      // that enforce it, without claiming data we don't
                      // have.
                      builder
                        ..element(
                          'TotalTimeSeconds',
                          nest: activity.elapsedTime.inSeconds.toString(),
                        )
                        ..element(
                          'DistanceMeters',
                          nest: activity.distanceMeters.toString(),
                        )
                        ..element('Calories', nest: '0')
                        ..element('Intensity', nest: 'Active')
                        ..element('TriggerMethod', nest: 'Manual');
                      if (points.isNotEmpty) {
                        builder.element(
                          'Track',
                          nest: () {
                            for (final sample in points) {
                              _writeTcxTrackpoint(builder, sample);
                            }
                          },
                        );
                      }
                    },
                  );
                },
              );
            },
          );
        },
      );

    return builder.buildDocument().toXmlString(pretty: true);
  }

  void _writeTcxTrackpoint(XmlBuilder builder, ActivitySample sample) {
    builder.element(
      'Trackpoint',
      nest: () {
        builder.element('Time', nest: _isoUtc(sample.timestamp));
        builder.element(
          'Position',
          nest: () {
            builder
              ..element('LatitudeDegrees', nest: sample.latitude.toString())
              ..element(
                'LongitudeDegrees',
                nest: sample.longitude.toString(),
              );
          },
        );
        if (sample.elevationMeters != null) {
          builder.element(
            'AltitudeMeters',
            nest: sample.elevationMeters!.toString(),
          );
        }
        if (sample.heartRate != null) {
          builder.element(
            'HeartRateBpm',
            nest: () =>
                builder.element('Value', nest: sample.heartRate.toString()),
          );
        }
      },
    );
  }

  /// The samples that belong in an exported track: every [samples] entry
  /// except paused ones (see class doc), in the order given. Relies on
  /// the caller already handing samples in ascending timestamp order -
  /// the same contract `ActivityRepository.getSamples` documents - rather
  /// than re-sorting here.
  List<ActivitySample> _trackPoints(List<ActivitySample> samples) =>
      samples.where((sample) => !sample.isPaused).toList(growable: false);

  /// The reverse of `ActivityFileImporter._mapActivityType` (see class
  /// doc) - used for both GPX's `<type>` and TCX's `Activity/@Sport`,
  /// since the importer applies the exact same keyword matching to both.
  String _exportTypeString(ActivityType type) => switch (type) {
    ActivityType.run => 'Running',
    ActivityType.walk => 'Walking',
    ActivityType.hike => 'Hiking',
    ActivityType.ride => 'Cycling',
    ActivityType.strength ||
    ActivityType.yoga ||
    ActivityType.hiit ||
    ActivityType.pilates ||
    ActivityType.swim ||
    ActivityType.other => 'Other',
  };

  /// ISO 8601 with a trailing `Z`, guaranteed - [dateTime] is documented
  /// UTC everywhere it comes from ([Activity.startedAt],
  /// [ActivitySample.timestamp]), but converting defensively here means a
  /// non-UTC value could never silently export as naive local time with
  /// no offset.
  String _isoUtc(DateTime dateTime) => dateTime.toUtc().toIso8601String();
}

/// Outcome of [ActivityFileExporter.exportGpx].
sealed class GpxExportOutcome {
  const GpxExportOutcome();
}

/// A rendered GPX 1.1 document, ready to write to a file.
final class GpxExported extends GpxExportOutcome {
  const GpxExported(this.xml);

  final String xml;
}

/// [ActivityFileExporter.exportGpx] was asked to render an activity with
/// no usable GPS track (see class doc for exactly which activities that
/// covers).
final class GpxNotExportable extends GpxExportOutcome {
  const GpxNotExportable(this.reason);

  final String reason;
}
