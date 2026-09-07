import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/activity_file_importer.dart';

void main() {
  const importer = ActivityFileImporter();

  group('ActivityFileImporter (GPX)', () {
    test(
      'parses GPX run file with coordinates, elevations, and timestamps',
      () {
        const gpxContent = '''

<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="Garmin Forerunner 265">
  <trk>
    <name>Garmin Morning 5K</name>
    <type>running</type>
    <trkseg>
      <trkpt lat="51.5000" lon="-0.1400">
        <ele>15.0</ele>
        <time>2026-08-29T07:00:00Z</time>
      </trkpt>
      <trkpt lat="51.5010" lon="-0.1400">
        <ele>18.0</ele>
        <time>2026-08-29T07:01:00Z</time>
      </trkpt>
      <trkpt lat="51.5020" lon="-0.1400">
        <ele>22.0</ele>
        <time>2026-08-29T07:02:00Z</time>
      </trkpt>
    </trkseg>
  </trk>
</gpx>''';

        final result = importer.parseXmlString(gpxContent);

        expect(result.activity.title, equals('Garmin Morning 5K'));
        expect(result.activity.activityType, equals(ActivityType.run));
        expect(result.activity.source, equals(ActivitySource.recorded));
        expect(result.samples.length, equals(3));
        expect(result.activity.distanceMeters, greaterThan(200));
        expect(
          result.activity.elevationGainMeters,
          equals(7.0),
        ); // (18-15) + (22-18) = 7
        expect(result.samples.first.latitude, equals(51.5));
        expect(result.samples.first.longitude, equals(-0.14));
        expect(result.samples.first.elevationMeters, equals(15.0));
      },
    );

    test('maps cycling activity type from GPX', () {
      const gpxCycling = '''

<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="Garmin Edge 840">
  <trk>
    <name>Afternoon Ride</name>
    <type>cycling</type>
    <trkseg>
      <trkpt lat="51.500" lon="-0.140"><time>2026-08-29T14:00:00Z</time></trkpt>
      <trkpt lat="51.510" lon="-0.140"><time>2026-08-29T14:10:00Z</time></trkpt>
    </trkseg>
  </trk>
</gpx>''';

      final result = importer.parseXmlString(gpxCycling);
      expect(result.activity.activityType, equals(ActivityType.ride));
      expect(result.activity.title, equals('Afternoon Ride'));
    });

    test('throws FormatException on empty or non-GPS xml', () {
      expect(
        () => importer.parseXmlString('<note><body>Hello</body></note>'),
        throwsFormatException,
      );
      expect(
        () =>
            importer.parseXmlString('<gpx><trk><trkseg></trkseg></trk></gpx>'),
        throwsFormatException,
      );
    });
  });

  group('ActivityFileImporter (TCX)', () {
    test('parses Garmin TCX file with Trackpoints and Sport attribute', () {
      const tcxContent = '''

<?xml version="1.0" encoding="UTF-8"?>
<TrainingCenterDatabase xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2">
  <Activities>
    <Activity Sport="Running">
      <Id>2026-08-29T06:30:00Z</Id>
      <Lap StartTime="2026-08-29T06:30:00Z">
        <Track>
          <Trackpoint>
            <Time>2026-08-29T06:30:00Z</Time>
            <Position>
              <LatitudeDegrees>51.5050</LatitudeDegrees>
              <LongitudeDegrees>-0.0900</LongitudeDegrees>
            </Position>
            <AltitudeMeters>10.0</AltitudeMeters>
          </Trackpoint>
          <Trackpoint>
            <Time>2026-08-29T06:35:00Z</Time>
            <Position>
              <LatitudeDegrees>51.5100</LatitudeDegrees>
              <LongitudeDegrees>-0.0900</LongitudeDegrees>
            </Position>
            <AltitudeMeters>15.0</AltitudeMeters>
          </Trackpoint>
        </Track>
      </Lap>
    </Activity>
  </Activities>
</TrainingCenterDatabase>''';

      final result = importer.parseXmlString(
        tcxContent,
        fallbackTitle: 'Morning Tempo Run',
      );

      expect(result.activity.activityType, equals(ActivityType.run));
      expect(result.activity.title, equals('Morning Tempo Run'));
      expect(result.samples.length, equals(2));
      expect(result.samples.first.latitude, equals(51.505));
      expect(result.samples.first.elevationMeters, equals(10.0));
      expect(result.activity.elevationGainMeters, equals(5.0));
    });

    test(
      'parses TCX with HeartRateBpm and Cadence into samples and activity',
      () {
        const tcxWithHr = '''
<?xml version="1.0" encoding="UTF-8"?>
<TrainingCenterDatabase xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2">
  <Activities>
    <Activity Sport="Running">
      <Id>2026-08-29T06:30:00Z</Id>
      <Lap StartTime="2026-08-29T06:30:00Z">
        <Track>
          <Trackpoint>
            <Time>2026-08-29T06:30:00Z</Time>
            <Position>
              <LatitudeDegrees>51.5050</LatitudeDegrees>
              <LongitudeDegrees>-0.0900</LongitudeDegrees>
            </Position>
            <AltitudeMeters>10.0</AltitudeMeters>
            <HeartRateBpm><Value>140</Value></HeartRateBpm>
            <Cadence>80</Cadence>
          </Trackpoint>
          <Trackpoint>
            <Time>2026-08-29T06:35:00Z</Time>
            <Position>
              <LatitudeDegrees>51.5100</LatitudeDegrees>
              <LongitudeDegrees>-0.0900</LongitudeDegrees>
            </Position>
            <AltitudeMeters>15.0</AltitudeMeters>
            <HeartRateBpm><Value>160</Value></HeartRateBpm>
            <Cadence>84</Cadence>
          </Trackpoint>
        </Track>
      </Lap>
    </Activity>
  </Activities>
</TrainingCenterDatabase>''';

        final result = importer.parseXmlString(
          tcxWithHr,
          fallbackTitle: 'Garmin Run HR',
        );
        expect(result.samples.length, 2);
        expect(result.samples[0].heartRate, 140);
        expect(result.samples[1].heartRate, 160);
        expect(result.activity.avgHeartRate, 150);
      },
    );

    test('parses GPX TrackPointExtension with hr and cad', () {
      const gpxWithHr = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="Garmin Forerunner">
  <trk>
    <name>Garmin Run with HR</name>
    <type>running</type>
    <trkseg>
      <trkpt lat="51.5000" lon="-0.1400">
        <ele>15.0</ele>
        <time>2026-08-29T07:00:00Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>150</gpxtpx:hr>
            <gpxtpx:cad>88</gpxtpx:cad>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
      <trkpt lat="51.5010" lon="-0.1400">
        <ele>18.0</ele>
        <time>2026-08-29T07:01:00Z</time>
        <extensions>
          <gpxtpx:TrackPointExtension>
            <gpxtpx:hr>160</gpxtpx:hr>
            <gpxtpx:cad>90</gpxtpx:cad>
          </gpxtpx:TrackPointExtension>
        </extensions>
      </trkpt>
    </trkseg>
  </trk>
</gpx>''';

      final result = importer.parseXmlString(gpxWithHr);
      expect(result.samples.length, 2);
      expect(result.samples[0].heartRate, 150);
      expect(result.samples[1].heartRate, 160);
      expect(result.activity.avgHeartRate, 155);
    });
  });
}
