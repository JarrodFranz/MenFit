import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_file_exporter.dart';
import 'package:menfit_app/features/activity/domain/activity_file_importer.dart';
import 'package:menfit_app/features/activity/domain/activity_sample.dart';
import 'package:xml/xml.dart';

Activity _activity({
  ActivityType type = ActivityType.run,
  String title = 'Morning Tempo Run',
  DateTime? startedAt,
  Duration elapsedTime = const Duration(minutes: 30),
  double distanceMeters = 5000,
  ActivitySource source = ActivitySource.recorded,
}) {
  final started = startedAt ?? DateTime.utc(2026, 8, 29, 7);
  return Activity(
    id: EntityId.generate(),
    activityType: type,
    title: title,
    startedAt: started,
    movingTime: elapsedTime,
    elapsedTime: elapsedTime,
    distanceMeters: distanceMeters,
    source: source,
    createdAt: started,
    updatedAt: started,
  );
}

ActivitySample _sample({
  required String activityId,
  required DateTime timestamp,
  required double latitude,
  required double longitude,
  double? elevationMeters,
  int? heartRate,
  bool isPaused = false,
}) {
  return ActivitySample(
    id: EntityId.generate(),
    activityId: activityId,
    timestamp: timestamp,
    latitude: latitude,
    longitude: longitude,
    elevationMeters: elevationMeters,
    heartRate: heartRate,
    isPaused: isPaused,
  );
}

void main() {
  const exporter = ActivityFileExporter();
  const importer = ActivityFileImporter();

  group('ActivityFileExporter (GPX)', () {
    test('round-trips a run through ActivityFileImporter', () {
      final activity = _activity();
      final samples = [
        _sample(
          activityId: activity.id,
          timestamp: DateTime.utc(2026, 8, 29, 7),
          latitude: 51.5000,
          longitude: -0.1400,
          elevationMeters: 15,
        ),
        _sample(
          activityId: activity.id,
          timestamp: DateTime.utc(2026, 8, 29, 7, 1),
          latitude: 51.5010,
          longitude: -0.1400,
          elevationMeters: 18,
        ),
        _sample(
          activityId: activity.id,
          timestamp: DateTime.utc(2026, 8, 29, 7, 2),
          latitude: 51.5020,
          longitude: -0.1400,
          elevationMeters: 22,
        ),
      ];

      final outcome = exporter.exportGpx(activity, samples);
      expect(outcome, isA<GpxExported>());
      final xml = (outcome as GpxExported).xml;

      final imported = importer.parseXmlString(xml);

      expect(imported.activity.title, equals(activity.title));
      expect(imported.activity.activityType, equals(ActivityType.run));
      expect(imported.samples.length, equals(3));
      for (var i = 0; i < samples.length; i++) {
        expect(imported.samples[i].latitude, equals(samples[i].latitude));
        expect(imported.samples[i].longitude, equals(samples[i].longitude));
        expect(
          imported.samples[i].elevationMeters,
          equals(samples[i].elevationMeters),
        );
        expect(
          imported.samples[i].timestamp.isAtSameMomentAs(
            samples[i].timestamp,
          ),
          isTrue,
        );
      }
    });

    test(
      'excludes paused samples from both the file and the round-trip',
      () {
        final activity = _activity();
        final samples = [
          _sample(
            activityId: activity.id,
            timestamp: DateTime.utc(2026, 8, 29, 7),
            latitude: 51.5000,
            longitude: -0.1400,
          ),
          _sample(
            activityId: activity.id,
            timestamp: DateTime.utc(2026, 8, 29, 7, 1),
            latitude: 51.9999,
            longitude: -0.9999,
            isPaused: true,
          ),
          _sample(
            activityId: activity.id,
            timestamp: DateTime.utc(2026, 8, 29, 7, 2),
            latitude: 51.5010,
            longitude: -0.1400,
          ),
        ];

        final outcome = exporter.exportGpx(activity, samples) as GpxExported;
        expect(outcome.xml, isNot(contains('51.9999')));

        final imported = importer.parseXmlString(outcome.xml);
        expect(imported.samples.length, equals(2));
      },
    );

    test(
      'returns GpxNotExportable when there are no non-paused samples',
      () {
        final activity = _activity(source: ActivitySource.manual);

        final noSamples = exporter.exportGpx(activity, const []);
        expect(noSamples, isA<GpxNotExportable>());

        final onlyPaused = exporter.exportGpx(activity, [
          _sample(
            activityId: activity.id,
            timestamp: DateTime.utc(2026, 8, 29, 7),
            latitude: 51.5,
            longitude: -0.14,
            isPaused: true,
          ),
        ]);
        expect(onlyPaused, isA<GpxNotExportable>());
      },
    );

    test('emits the gpxtpx heart-rate extension only when HR exists', () {
      final activity = _activity();
      final withHr = _sample(
        activityId: activity.id,
        timestamp: DateTime.utc(2026, 8, 29, 7),
        latitude: 51.5,
        longitude: -0.14,
        heartRate: 152,
      );
      final withoutHr = _sample(
        activityId: activity.id,
        timestamp: DateTime.utc(2026, 8, 29, 7, 1),
        latitude: 51.501,
        longitude: -0.14,
      );

      final outcome =
          exporter.exportGpx(activity, [withHr, withoutHr]) as GpxExported;
      final doc = XmlDocument.parse(outcome.xml);

      // Namespace declared with the literal `gpxtpx` prefix on the root.
      final gpx = doc.rootElement;
      expect(gpx.getAttribute('xmlns:gpxtpx'), isNotNull);

      final trackpoints = doc.findAllElements('trkpt').toList();
      expect(trackpoints, hasLength(2));

      final hrElements = doc.findAllElements('gpxtpx:hr').toList();
      expect(hrElements, hasLength(1));
      expect(hrElements.single.innerText, equals('152'));

      // The trackpoint without HR has no <extensions> at all.
      final secondExtensions = trackpoints[1]
          .findElements('extensions')
          .toList();
      expect(secondExtensions, isEmpty);
    });

    test('timestamps serialise as UTC with a trailing Z', () {
      final activity = _activity();
      final outcome = exporter.exportGpx(activity, [
        _sample(
          activityId: activity.id,
          timestamp: DateTime.utc(2026, 8, 29, 7),
          latitude: 51.5,
          longitude: -0.14,
        ),
      ]) as GpxExported;

      final doc = XmlDocument.parse(outcome.xml);
      final metadataTime = doc
          .findAllElements('metadata')
          .single
          .findElements('time')
          .single
          .innerText;
      final trkptTime = doc
          .findAllElements('trkpt')
          .single
          .findElements('time')
          .single
          .innerText;

      expect(metadataTime, endsWith('Z'));
      expect(trkptTime, endsWith('Z'));
    });

    test('produces well-formed XML that package:xml can re-parse', () {
      final activity = _activity();
      final outcome = exporter.exportGpx(activity, [
        _sample(
          activityId: activity.id,
          timestamp: DateTime.utc(2026, 8, 29, 7),
          latitude: 51.5,
          longitude: -0.14,
        ),
      ]) as GpxExported;

      expect(() => XmlDocument.parse(outcome.xml), returnsNormally);
    });

    test(
      'activity type mapping round-trips through the importer for every '
      'GPS-capable type',
      () {
        const cases = {
          ActivityType.run: ActivityType.run,
          ActivityType.walk: ActivityType.walk,
          ActivityType.hike: ActivityType.hike,
          ActivityType.ride: ActivityType.ride,
        };

        for (final entry in cases.entries) {
          final activity = _activity(type: entry.key);
          final outcome = exporter.exportGpx(activity, [
            _sample(
              activityId: activity.id,
              timestamp: DateTime.utc(2026, 8, 29, 7),
              latitude: 51.5,
              longitude: -0.14,
            ),
          ]) as GpxExported;

          final imported = importer.parseXmlString(outcome.xml);
          expect(
            imported.activity.activityType,
            equals(entry.value),
            reason: '${entry.key} should round-trip to ${entry.value}',
          );
        }
      },
    );
  });

  group('ActivityFileExporter (TCX)', () {
    test('round-trips a run through ActivityFileImporter', () {
      final activity = _activity(title: 'Evening Hills');
      final samples = [
        _sample(
          activityId: activity.id,
          timestamp: DateTime.utc(2026, 8, 29, 18),
          latitude: 51.505,
          longitude: -0.09,
          elevationMeters: 10,
        ),
        _sample(
          activityId: activity.id,
          timestamp: DateTime.utc(2026, 8, 29, 18, 5),
          latitude: 51.510,
          longitude: -0.09,
          elevationMeters: 15,
        ),
      ];

      final xml = exporter.exportTcx(activity, samples);
      // The importer never reads a title out of TCX (see
      // `activity_file_importer.dart`'s `_parseTcx` - it always uses
      // `fallbackTitle`), so the caller supplies it explicitly, exactly as
      // `ActivityImportService` would when re-importing an exported file.
      final imported = importer.parseXmlString(
        xml,
        fallbackTitle: activity.title,
      );

      expect(imported.activity.title, equals(activity.title));
      expect(imported.activity.activityType, equals(ActivityType.run));
      expect(imported.samples.length, equals(2));
      expect(imported.samples.first.latitude, equals(51.505));
      expect(imported.samples.first.elevationMeters, equals(10.0));
      expect(
        imported.samples.last.timestamp.isAtSameMomentAs(
          samples.last.timestamp,
        ),
        isTrue,
      );
    });

    test('excludes paused samples', () {
      final activity = _activity();
      final samples = [
        _sample(
          activityId: activity.id,
          timestamp: DateTime.utc(2026, 8, 29, 7),
          latitude: 51.5,
          longitude: -0.14,
        ),
        _sample(
          activityId: activity.id,
          timestamp: DateTime.utc(2026, 8, 29, 7, 1),
          latitude: 51.9999,
          longitude: -0.9999,
          isPaused: true,
        ),
      ];

      final xml = exporter.exportTcx(activity, samples);
      expect(xml, isNot(contains('51.9999')));

      final imported = importer.parseXmlString(
        xml,
        fallbackTitle: activity.title,
      );
      expect(imported.samples.length, equals(1));
    });

    test(
      'a no-GPS activity still produces a valid lap-only TCX (no Track)',
      () {
        final activity = _activity(
          type: ActivityType.strength,
          source: ActivitySource.manual,
          elapsedTime: const Duration(minutes: 45),
          distanceMeters: 0,
        );

        final xml = exporter.exportTcx(activity, const []);
        final doc = XmlDocument.parse(xml);

        expect(doc.findAllElements('Track'), isEmpty);
        expect(
          doc.findAllElements('TotalTimeSeconds').single.innerText,
          equals('2700'),
        );
        expect(
          doc.findAllElements('DistanceMeters').single.innerText,
          equals('0.0'),
        );
      },
    );

    test('emits HeartRateBpm/Value only when HR exists', () {
      final activity = _activity();
      final withHr = _sample(
        activityId: activity.id,
        timestamp: DateTime.utc(2026, 8, 29, 7),
        latitude: 51.5,
        longitude: -0.14,
        heartRate: 140,
      );
      final withoutHr = _sample(
        activityId: activity.id,
        timestamp: DateTime.utc(2026, 8, 29, 7, 1),
        latitude: 51.501,
        longitude: -0.14,
      );

      final xml = exporter.exportTcx(activity, [withHr, withoutHr]);
      final doc = XmlDocument.parse(xml);

      final heartRates = doc.findAllElements('HeartRateBpm').toList();
      expect(heartRates, hasLength(1));
      expect(
        heartRates.single.findElements('Value').single.innerText,
        equals('140'),
      );
    });

    test('timestamps serialise as UTC with a trailing Z', () {
      final activity = _activity();
      final xml = exporter.exportTcx(activity, [
        _sample(
          activityId: activity.id,
          timestamp: DateTime.utc(2026, 8, 29, 7),
          latitude: 51.5,
          longitude: -0.14,
        ),
      ]);

      final doc = XmlDocument.parse(xml);
      expect(doc.findAllElements('Id').single.innerText, endsWith('Z'));
      expect(doc.findAllElements('Time').single.innerText, endsWith('Z'));
    });

    test('produces well-formed XML that package:xml can re-parse', () {
      final activity = _activity(
        type: ActivityType.yoga,
        source: ActivitySource.manual,
        distanceMeters: 0,
      );
      final xml = exporter.exportTcx(activity, const []);
      expect(() => XmlDocument.parse(xml), returnsNormally);
    });
  });
}
