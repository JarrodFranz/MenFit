import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/location/location_fix.dart';
import 'package:menfit_app/features/activity/domain/activity.dart';
import 'package:menfit_app/features/activity/domain/geo_math.dart';
import 'package:menfit_app/features/activity/domain/recording_session.dart';

/// Metres per degree of latitude, using the same spherical Earth radius as
/// `geo_math.dart` - lets these tests place fixes at a known distance apart
/// (moving due north) without hardcoding a separately-sourced constant that
/// could silently drift from the SUT's own notion of distance.
const double _metersPerDegreeLat = 111194.92664455873;

LocationFix _fixAt(
  DateTime timestamp, {
  double metersNorth = 0,
  double? speedMetersPerSecond,
  double? horizontalAccuracyMeters,
  double? elevationMeters,
}) {
  return LocationFix(
    timestamp: timestamp,
    latitude: metersNorth / _metersPerDegreeLat,
    longitude: 0,
    speedMetersPerSecond: speedMetersPerSecond,
    horizontalAccuracyMeters: horizontalAccuracyMeters,
    elevationMeters: elevationMeters,
  );
}

void main() {
  final t0 = DateTime.utc(2026);

  group('accuracy filter', () {
    test(
      'drops a fix reporting accuracy worse than 35m; distance unchanged',
      () {
        final session =
            RecordingSession(activityType: ActivityType.run, clock: () => t0)
              ..start()
              ..addFix(_fixAt(t0, speedMetersPerSecond: 2))
              ..addFix(
                _fixAt(
                  t0.add(const Duration(seconds: 1)),
                  metersNorth: 50,
                  horizontalAccuracyMeters: 40,
                  speedMetersPerSecond: 2,
                ),
              );

        expect(session.samples, hasLength(1));
        expect(session.distanceMeters, 0);
      },
    );

    test('keeps a fix that omits accuracy entirely', () {
      final session =
          RecordingSession(activityType: ActivityType.run, clock: () => t0)
            ..start()
            ..addFix(_fixAt(t0));
      expect(session.samples, hasLength(1));
    });
  });

  group('implausible-jump filter', () {
    test('discards a teleport for a run (>10 m/s implied)', () {
      final session =
          RecordingSession(activityType: ActivityType.run, clock: () => t0)
            ..start()
            ..addFix(_fixAt(t0, speedMetersPerSecond: 2))
            // 100m in 1s = 100 m/s implied - way over the 10 m/s run
            // ceiling.
            ..addFix(
              _fixAt(
                t0.add(const Duration(seconds: 1)),
                metersNorth: 100,
                speedMetersPerSecond: 2,
              ),
            )
            // A normal follow-up fix relative to the *first* accepted fix
            // (not the discarded teleport) should still be accepted.
            ..addFix(
              _fixAt(
                t0.add(const Duration(seconds: 2)),
                metersNorth: 5,
                speedMetersPerSecond: 2,
              ),
            );

      expect(session.samples, hasLength(2));
      expect(session.distanceMeters, closeTo(5, 0.01));
    });

    test(
      'a fix accepted while paused is still the jump reference - a teleport '
      'during a pause is still a teleport',
      () {
        var current = t0;
        final session =
            RecordingSession(
                activityType: ActivityType.run,
                clock: () => current,
              )
              ..start()
              ..addFix(_fixAt(current, speedMetersPerSecond: 2))
              ..pause();

        // Accepted while paused (paused samples are still recorded, tagged
        // isPaused) - and it becomes the reference for the NEXT jump check.
        current = current.add(const Duration(seconds: 1));
        session.addFix(_fixAt(current, speedMetersPerSecond: 0));
        expect(session.samples, hasLength(2));

        current = current.add(const Duration(seconds: 2));
        session
          ..resume()
          // 25m from the paused fix, 2s later => 12.5 m/s, over the 10 m/s
          // run ceiling. Deliberately discriminating: measured from the
          // last *recording*-status fix instead (3s earlier) it would be
          // 8.3 m/s and slip through - so this fails if the filter ever
          // regresses to skipping paused-status fixes.
          ..addFix(_fixAt(current, metersNorth: 25, speedMetersPerSecond: 2));

        expect(
          session.samples,
          hasLength(2),
          reason: 'the teleport must be rejected, not recorded',
        );
      },
    );

    test('accepts a 20 m/s implied jump for a ride', () {
      final session =
          RecordingSession(activityType: ActivityType.ride, clock: () => t0)
            ..start()
            ..addFix(_fixAt(t0, speedMetersPerSecond: 20))
            ..addFix(
              _fixAt(
                t0.add(const Duration(seconds: 1)),
                metersNorth: 20,
                speedMetersPerSecond: 20,
              ),
            );

      expect(session.samples, hasLength(2));
      expect(session.distanceMeters, closeTo(20, 0.01));
    });

    test('rejects a 20 m/s implied jump for a run', () {
      final session =
          RecordingSession(activityType: ActivityType.run, clock: () => t0)
            ..start()
            ..addFix(_fixAt(t0, speedMetersPerSecond: 2))
            ..addFix(
              _fixAt(
                t0.add(const Duration(seconds: 1)),
                metersNorth: 20,
                speedMetersPerSecond: 2,
              ),
            );

      expect(session.samples, hasLength(1));
      expect(session.distanceMeters, 0);
    });
  });

  test(
    'distance accumulation matches the haversine sum of accepted fixes',
    () {
      final session = RecordingSession(
        activityType: ActivityType.run,
        clock: () => t0,
      )..start();

      final offsetsMeters = [0.0, 5.0, 12.0, 12.0, 20.0];
      for (var i = 0; i < offsetsMeters.length; i++) {
        session.addFix(
          _fixAt(
            t0.add(Duration(seconds: i)),
            metersNorth: offsetsMeters[i],
            speedMetersPerSecond: 2,
          ),
        );
      }

      var expected = 0.0;
      for (var i = 1; i < offsetsMeters.length; i++) {
        expected += haversineDistanceMeters(
          offsetsMeters[i - 1] / _metersPerDegreeLat,
          0,
          offsetsMeters[i] / _metersPerDegreeLat,
          0,
        );
      }

      expect(session.distanceMeters, closeTo(expected, 1e-6));
    },
  );

  test(
    'manual pause stops distance and moving time; elapsed keeps growing',
    () {
      var current = t0;
      final session =
          RecordingSession(
              activityType: ActivityType.run,
              clock: () => current,
            )
            ..start()
            ..addFix(_fixAt(current, speedMetersPerSecond: 2));
      current = current.add(const Duration(seconds: 5));
      session.addFix(
        _fixAt(current, metersNorth: 10, speedMetersPerSecond: 2),
      );
      expect(session.distanceMeters, closeTo(10, 0.01));
      expect(session.movingTime, const Duration(seconds: 5));

      session.pause();
      current = current.add(const Duration(seconds: 20));

      expect(session.status, RecordingSessionStatus.paused);
      expect(
        session.movingTime,
        const Duration(seconds: 5),
        reason: 'frozen while paused',
      );
      expect(
        session.elapsedTime,
        const Duration(seconds: 25),
        reason: 'keeps growing while paused',
      );

      // A fix arriving while paused is stored (route point) but doesn't move
      // the distance counter.
      session.addFix(
        _fixAt(current, metersNorth: 100, speedMetersPerSecond: 2),
      );
      expect(session.samples, hasLength(3));
      expect(session.distanceMeters, closeTo(10, 0.01));
      // The first two fixes were accepted while recording; the one just
      // added while manually paused is tagged accordingly (F1: pause-aware
      // samples).
      expect(session.samples.map((s) => s.wasPaused), [false, false, true]);

      session.resume();
      current = current.add(const Duration(seconds: 3));
      // First fix after resume only establishes a new reference - the
      // pre-pause -> post-resume gap is never counted as distance.
      session.addFix(
        _fixAt(current, metersNorth: 103, speedMetersPerSecond: 2),
      );
      expect(session.distanceMeters, closeTo(10, 0.01));

      current = current.add(const Duration(seconds: 2));
      session.addFix(
        _fixAt(current, metersNorth: 108, speedMetersPerSecond: 2),
      );
      expect(session.distanceMeters, closeTo(15, 0.01));
    },
  );

  group('auto-pause', () {
    test('a brief 3s dip below the speed threshold does not trigger', () {
      var current = t0;
      final session =
          RecordingSession(activityType: ActivityType.run, clock: () => current)
            ..start()
            ..addFix(_fixAt(current, speedMetersPerSecond: 2));
      current = current.add(const Duration(seconds: 1));
      session.addFix(
        _fixAt(current, speedMetersPerSecond: 0.2),
      ); // low speed starts
      current = current.add(const Duration(seconds: 3));
      session.addFix(
        _fixAt(current, speedMetersPerSecond: 0.2),
      ); // 3s sustained

      expect(session.status, RecordingSessionStatus.recording);
    });

    test('speed sustained below threshold for >5s triggers auto-pause', () {
      var current = t0;
      final session =
          RecordingSession(activityType: ActivityType.run, clock: () => current)
            ..start()
            ..addFix(_fixAt(current, speedMetersPerSecond: 2));
      current = current.add(const Duration(seconds: 1));
      session.addFix(
        _fixAt(current, speedMetersPerSecond: 0.2),
      ); // low speed starts
      current = current.add(const Duration(seconds: 6));
      session.addFix(
        _fixAt(current, speedMetersPerSecond: 0.2),
      ); // 6s sustained

      expect(session.status, RecordingSessionStatus.autoPaused);
      // The triggering fix is accepted under the status it arrived to find
      // (still `recording`, per [RecordedFix]'s doc) - it is the *next*
      // fix, arriving once the session is already autoPaused, that gets
      // tagged.
      expect(session.samples.last.wasPaused, isFalse);
      current = current.add(const Duration(seconds: 1));
      session.addFix(_fixAt(current, speedMetersPerSecond: 0.2));
      expect(session.samples.last.wasPaused, isTrue);
    });

    test('speed above 1.0 m/s resumes from auto-pause', () {
      var current = t0;
      final session =
          RecordingSession(activityType: ActivityType.run, clock: () => current)
            ..start()
            ..addFix(_fixAt(current, speedMetersPerSecond: 2));
      current = current.add(const Duration(seconds: 1));
      session.addFix(_fixAt(current, speedMetersPerSecond: 0.2));
      current = current.add(const Duration(seconds: 6));
      session.addFix(_fixAt(current, speedMetersPerSecond: 0.2));
      expect(session.status, RecordingSessionStatus.autoPaused);

      current = current.add(const Duration(seconds: 1));
      session.addFix(
        _fixAt(current, metersNorth: 0.5, speedMetersPerSecond: 1.5),
      );
      expect(session.status, RecordingSessionStatus.recording);
    });

    test('manual pause suppresses auto-pause detection entirely', () {
      var current = t0;
      final session =
          RecordingSession(activityType: ActivityType.run, clock: () => current)
            ..start()
            ..addFix(_fixAt(current, speedMetersPerSecond: 2))
            ..pause();

      // Even a long stretch of low-speed fixes while manually paused must
      // not surface as autoPaused - it stays manually paused until resume().
      for (var i = 1; i <= 8; i++) {
        current = current.add(const Duration(seconds: 1));
        session.addFix(_fixAt(current, speedMetersPerSecond: 0.1));
      }

      expect(session.status, RecordingSessionStatus.paused);
    });

    test(
      'manual pause/resume clears low-speed tracking - a single low-speed '
      'fix right after resume does not immediately auto-pause, but '
      'sustained low speed after resume still does',
      () {
        var current = t0;
        final session =
            RecordingSession(
                activityType: ActivityType.run,
                clock: () => current,
              )
              ..start()
              ..addFix(_fixAt(current, speedMetersPerSecond: 2));

        // Low speed starts pre-pause, t=1s.
        current = current.add(const Duration(seconds: 1));
        session
          ..addFix(_fixAt(current, speedMetersPerSecond: 0.2))
          ..pause();
        current = current.add(const Duration(seconds: 10)); // long paused gap
        session.resume();

        // t=12s: a single post-resume low-speed fix. Under a buggy
        // implementation that doesn't clear the pre-pause low-speed-since
        // timestamp, this fix's 11s gap from the t=1s low-speed start (1s
        // pre-pause + 10s paused + 1s post-resume) would look like an
        // already-sustained streak and trigger immediately.
        current = current.add(const Duration(seconds: 1));
        session.addFix(_fixAt(current, speedMetersPerSecond: 0.2));
        expect(
          session.status,
          RecordingSessionStatus.recording,
          reason:
              'pause()/resume() must clear the pre-pause low-speed '
              'tracking - a single post-resume low-speed fix must not '
              'inherit an 11s-old low-speed-since timestamp and '
              'auto-pause immediately.',
        );

        // t=19s: sustained low speed for >5s since the post-resume fix
        // must still auto-pause normally.
        current = current.add(const Duration(seconds: 7));
        session.addFix(_fixAt(current, speedMetersPerSecond: 0.2));
        expect(session.status, RecordingSessionStatus.autoPaused);
      },
    );

    test(
      'falls back to implied speed when a fix omits speedMetersPerSecond',
      () {
        var current = t0;
        final session =
            RecordingSession(
                activityType: ActivityType.run,
                clock: () => current,
              )
              ..start()
              // No speed field on any fix below - only lat/lon+timestamp deltas.
              ..addFix(_fixAt(current));
        current = current.add(const Duration(seconds: 1));
        // ~0.1 m/s implied - below the 0.5 threshold.
        session.addFix(_fixAt(current, metersNorth: 0.1));
        current = current.add(const Duration(seconds: 6));
        session.addFix(_fixAt(current, metersNorth: 0.2));

        expect(session.status, RecordingSessionStatus.autoPaused);
      },
    );
  });

  test(
    'movingTime vs elapsedTime accounting across mixed pause/auto-pause spans',
    () {
      var current = t0;
      final session = RecordingSession(
        activityType: ActivityType.run,
        clock: () => current,
      )..start();

      // 0 -> 10s: recording.
      current = current.add(const Duration(seconds: 10));
      expect(session.movingTime, const Duration(seconds: 10));
      expect(session.elapsedTime, const Duration(seconds: 10));

      // 10s: manual pause. 10 -> 15s: paused.
      session.pause();
      current = current.add(const Duration(seconds: 5));
      expect(session.movingTime, const Duration(seconds: 10));
      expect(session.elapsedTime, const Duration(seconds: 15));

      // 15s: resume.
      session.resume();
      current = current.add(const Duration(seconds: 5)); // -> 20s
      session.addFix(
        _fixAt(current, speedMetersPerSecond: 2),
      ); // establishes reference
      current = current.add(const Duration(seconds: 1)); // -> 21s
      session.addFix(
        _fixAt(current, speedMetersPerSecond: 0.2),
      ); // low speed starts (low-speed-since clock: 21s)
      current = current.add(const Duration(seconds: 6)); // -> 27s
      session.addFix(
        _fixAt(current, speedMetersPerSecond: 0.2),
      ); // 6s sustained -> auto-pause
      expect(session.status, RecordingSessionStatus.autoPaused);
      // Auto-pause back-dates the span close to when the low-speed streak
      // began (21s), not to this triggering fix's time (27s) - the
      // 6s sustain-detection window itself is never counted as moving
      // time. Moving span 15s->21s (6s) closes on auto-pause entry, on
      // top of the earlier 10s span: 10 + 6 = 16s.
      expect(session.movingTime, const Duration(seconds: 16));
      expect(session.elapsedTime, const Duration(seconds: 27));

      // 30s: movement resumes.
      current = current.add(const Duration(seconds: 3)); // -> 30s
      session.addFix(
        _fixAt(current, metersNorth: 0.5, speedMetersPerSecond: 1.5),
      );
      expect(session.status, RecordingSessionStatus.recording);

      // 35s: finish. Final span 30s->35s (5s): 16 + 5 = 21s.
      current = current.add(const Duration(seconds: 5));
      final result = session.finish();

      expect(result.movingTime, const Duration(seconds: 21));
      expect(result.elapsedTime, const Duration(seconds: 35));
      expect(session.status, RecordingSessionStatus.finished);
    },
  );

  group('finish() trims elapsed time for a forgotten end', () {
    test(
      'finishing an hour into autoPause trims elapsedTime to the moment '
      'movement stopped; movingTime and startedAt are unaffected',
      () {
        var current = t0;
        final session =
            RecordingSession(
                activityType: ActivityType.run,
                clock: () => current,
              )
              ..start()
              ..addFix(_fixAt(current, speedMetersPerSecond: 2));
        current = current.add(const Duration(seconds: 10));
        // Still moving, same position (position isn't this test's concern -
        // holding it steady avoids an incidental implausible-jump
        // rejection against the next, stationary fix).
        session.addFix(_fixAt(current, speedMetersPerSecond: 2));
        // Movement stops here (t=11s): the low-speed streak begins.
        current = current.add(const Duration(seconds: 1));
        session.addFix(_fixAt(current, speedMetersPerSecond: 0.2));
        // 6s sustained low speed -> auto-pause, back-dated to t=11s (when
        // the low-speed streak began), not to t=17s (this triggering fix).
        current = current.add(const Duration(seconds: 6));
        session.addFix(_fixAt(current, speedMetersPerSecond: 0.2));
        expect(session.status, RecordingSessionStatus.autoPaused);
        expect(session.autoPausedAt, t0.add(const Duration(seconds: 11)));

        // Forgotten for an hour before finish() is finally called.
        current = current.add(const Duration(hours: 1));
        final result = session.finish();

        expect(result.startedAt, t0);
        expect(result.movingTime, const Duration(seconds: 11));
        expect(
          result.elapsedTime,
          const Duration(seconds: 11),
          reason:
              'elapsedTime ends at the auto-pause boundary (t=11s), not the '
              'finish() call an hour later',
        );
        expect(
          result.finishedAt,
          current,
          reason: 'finishedAt itself remains the actual finish() call time',
        );
      },
    );

    test('finishing from a manual pause is unaffected (regression)', () {
      var current = t0;
      final session =
          RecordingSession(
              activityType: ActivityType.run,
              clock: () => current,
            )
            ..start()
            ..addFix(_fixAt(current, speedMetersPerSecond: 2));
      current = current.add(const Duration(seconds: 10));
      session.pause();
      current = current.add(const Duration(hours: 1));

      final result = session.finish();

      expect(result.movingTime, const Duration(seconds: 10));
      expect(
        result.elapsedTime,
        const Duration(hours: 1, seconds: 10),
        reason:
            'a manual pause is a deliberate stop, not a forgotten one - '
            'elapsedTime keeps counting all the way to the finish() call, '
            'unchanged',
      );
    });

    test('finishing while actively recording is unaffected (regression)', () {
      var current = t0;
      final session =
          RecordingSession(
              activityType: ActivityType.run,
              clock: () => current,
            )
            ..start()
            ..addFix(_fixAt(current, speedMetersPerSecond: 2));
      current = current.add(const Duration(seconds: 42));

      final result = session.finish();

      expect(result.movingTime, const Duration(seconds: 42));
      expect(result.elapsedTime, const Duration(seconds: 42));
    });

    test(
      'a mixed episode (autoPause -> resume -> autoPause -> finish) trims '
      'only the trailing episode',
      () {
        var current = t0;
        final session =
            RecordingSession(
                activityType: ActivityType.run,
                clock: () => current,
              )
              ..start()
              ..addFix(_fixAt(current, speedMetersPerSecond: 2));

        // First auto-pause episode: low speed starts at t=1s, sustained to
        // t=7s (6s) - boundary t=1s.
        current = current.add(const Duration(seconds: 1));
        session.addFix(_fixAt(current, speedMetersPerSecond: 0.2));
        current = current.add(const Duration(seconds: 6));
        session.addFix(_fixAt(current, speedMetersPerSecond: 0.2));
        expect(session.status, RecordingSessionStatus.autoPaused);
        expect(session.autoPausedAt, t0.add(const Duration(seconds: 1)));

        // Movement resumes at t=10s - the first episode's boundary is now
        // moot.
        current = current.add(const Duration(seconds: 3));
        session.addFix(
          _fixAt(current, metersNorth: 5, speedMetersPerSecond: 1.5),
        );
        expect(session.status, RecordingSessionStatus.recording);
        expect(session.autoPausedAt, isNull);

        // Recording continues, moving, for 5s (t=10 -> t=15).
        current = current.add(const Duration(seconds: 5));
        session.addFix(
          _fixAt(current, metersNorth: 15, speedMetersPerSecond: 2),
        );

        // Second auto-pause episode: low speed starts at t=16s, sustained
        // to t=22s (6s) - this is the boundary that must be used to trim.
        // Position held at the last moving fix's 15m mark (not the default
        // 0) so neither low-speed fix reads as an implausible jump back to
        // the origin.
        current = current.add(const Duration(seconds: 1));
        session.addFix(
          _fixAt(current, metersNorth: 15, speedMetersPerSecond: 0.2),
        );
        current = current.add(const Duration(seconds: 6));
        session.addFix(
          _fixAt(current, metersNorth: 15, speedMetersPerSecond: 0.2),
        );
        expect(session.status, RecordingSessionStatus.autoPaused);
        final secondEpisodeBoundary = t0.add(const Duration(seconds: 16));
        expect(session.autoPausedAt, secondEpisodeBoundary);

        // Forgotten for 20 minutes before finish() is finally called.
        current = current.add(const Duration(minutes: 20));
        final result = session.finish();

        expect(
          result.elapsedTime,
          secondEpisodeBoundary.difference(t0),
          reason:
              'only the trailing (second) auto-pause episode is trimmed - '
              'the first episode (already closed by resume, well before '
              'this one began) has no bearing on where the finish() trim '
              'lands',
        );
      },
    );
  });

  test(
    'a fix timestamp far ahead of the injected clock cannot inflate or '
    'negate moving time - moving-span boundaries are governed by the '
    'clock, never by fix timestamps',
    () {
      var clockNow = t0;
      final session =
          RecordingSession(
              activityType: ActivityType.run,
              clock: () => clockNow,
            )
            ..start()
            // Fix timestamps run an hour ahead of the injected clock (e.g. a
            // device with a badly skewed system clock).
            ..addFix(
              _fixAt(t0.add(const Duration(hours: 1)), speedMetersPerSecond: 2),
            );
      clockNow = clockNow.add(const Duration(seconds: 5));
      session.addFix(
        _fixAt(
          t0.add(const Duration(hours: 1, seconds: 1)),
          metersNorth: 10,
          speedMetersPerSecond: 2,
        ),
      );

      expect(session.movingTime, const Duration(seconds: 5));
      expect(session.movingTime.isNegative, isFalse);

      final result = session.finish();
      expect(result.movingTime, const Duration(seconds: 5));
      expect(result.movingTime.isNegative, isFalse);
    },
  );

  group('elevation gain hysteresis', () {
    test(
      'a gradual climb made of sub-threshold steps still accumulates gain',
      () {
        // 10 climbs of 0.5m each (100 -> 105). Every individual step is
        // well under the 2m noise threshold, so a naive "compare to the
        // previous fix" implementation banks nothing at all - the held
        // reference must let these small steps accumulate until the
        // *cumulative* move crosses the threshold.
        final session = RecordingSession(
          activityType: ActivityType.run,
          clock: () => t0,
        )..start();

        final elevations = [for (var i = 0; i <= 10; i++) 100.0 + i * 0.5];
        for (var i = 0; i < elevations.length; i++) {
          session.addFix(
            _fixAt(
              t0.add(Duration(seconds: i)),
              speedMetersPerSecond: 2,
              elevationMeters: elevations[i],
            ),
          );
        }

        expect(session.elevationGainMeters, closeTo(5.0, 0.5));
      },
    );

    test('noise oscillation within the threshold produces no gain', () {
      final session = RecordingSession(
        activityType: ActivityType.run,
        clock: () => t0,
      )..start();

      final elevations = [
        100.0,
        101.0,
        100.0,
        101.0,
        100.0,
        100.5,
        99.5,
        100.0,
      ];
      for (var i = 0; i < elevations.length; i++) {
        session.addFix(
          _fixAt(
            t0.add(Duration(seconds: i)),
            speedMetersPerSecond: 2,
            elevationMeters: elevations[i],
          ),
        );
      }

      expect(session.elevationGainMeters, isNull);
    });

    test('a single clean 5m jump banks the full delta', () {
      final session =
          RecordingSession(
              activityType: ActivityType.run,
              clock: () => t0,
            )
            ..start()
            ..addFix(_fixAt(t0, speedMetersPerSecond: 2, elevationMeters: 100))
            ..addFix(
              _fixAt(
                t0.add(const Duration(seconds: 1)),
                speedMetersPerSecond: 2,
                elevationMeters: 105,
              ),
            );

      expect(session.elevationGainMeters, closeTo(5.0, 1e-9));
    });
  });

  test('finish() summary matches accumulated inputs', () {
    var current = t0;
    final session =
        RecordingSession(
            activityType: ActivityType.walk,
            clock: () => current,
          )
          ..start()
          ..addFix(_fixAt(current, speedMetersPerSecond: 1));
    current = current.add(const Duration(seconds: 10));
    session.addFix(
      _fixAt(current, metersNorth: 12, speedMetersPerSecond: 1),
    );
    current = current.add(const Duration(seconds: 30));

    final result = session.finish();

    expect(result.activityType, ActivityType.walk);
    expect(result.startedAt, t0);
    expect(result.finishedAt, current);
    expect(result.elapsedTime, const Duration(seconds: 40));
    expect(result.movingTime, const Duration(seconds: 40));
    expect(result.distanceMeters, closeTo(12, 0.01));
    expect(result.samples, hasLength(2));
  });

  test(
    'samples are ordered and complete; filtered fixes are excluded',
    () {
      final session = RecordingSession(
        activityType: ActivityType.run,
        clock: () => t0,
      )..start();

      final good1 = _fixAt(t0, speedMetersPerSecond: 2);
      final badAccuracy = _fixAt(
        t0.add(const Duration(seconds: 1)),
        metersNorth: 2,
        horizontalAccuracyMeters: 100,
        speedMetersPerSecond: 2,
      );
      final teleport = _fixAt(
        t0.add(const Duration(seconds: 2)),
        metersNorth: 500,
        speedMetersPerSecond: 2,
      );
      final good2 = _fixAt(
        t0.add(const Duration(seconds: 3)),
        metersNorth: 8,
        speedMetersPerSecond: 2,
      );

      session
        ..addFix(good1)
        ..addFix(badAccuracy)
        ..addFix(teleport)
        ..addFix(good2);

      expect(session.samples.map((s) => s.fix), [good1, good2]);
      expect(session.samples.every((s) => !s.wasPaused), isTrue);
      final result = session.finish();
      expect(result.samples.map((s) => s.fix), [good1, good2]);
    },
  );

  group('evaluateStaleness', () {
    test(
      'no fixes for more than 10s triggers auto-pause and moving time '
      'stops accruing',
      () {
        var current = t0;
        final session =
            RecordingSession(
                activityType: ActivityType.run,
                clock: () => current,
              )
              ..start()
              ..addFix(_fixAt(current, speedMetersPerSecond: 2));

        current = current.add(const Duration(seconds: 11));
        session.evaluateStaleness(current);

        expect(session.status, RecordingSessionStatus.autoPaused);
        final movingTimeAtTrigger = session.movingTime;

        current = current.add(const Duration(seconds: 5));
        expect(
          session.movingTime,
          movingTimeAtTrigger,
          reason:
              'movingTime must stop accruing once auto-paused by '
              'staleness',
        );
      },
    );

    test('is a no-op before the 10s threshold is reached', () {
      var current = t0;
      final session =
          RecordingSession(activityType: ActivityType.run, clock: () => current)
            ..start()
            ..addFix(_fixAt(current, speedMetersPerSecond: 2));

      current = current.add(const Duration(seconds: 9));
      session.evaluateStaleness(current);

      expect(session.status, RecordingSessionStatus.recording);
    });

    test('is a harmless no-op while manually paused', () {
      var current = t0;
      final session =
          RecordingSession(activityType: ActivityType.run, clock: () => current)
            ..start()
            ..addFix(_fixAt(current, speedMetersPerSecond: 2))
            ..pause();

      current = current.add(const Duration(seconds: 20));
      session.evaluateStaleness(current);

      expect(session.status, RecordingSessionStatus.paused);
    });

    test('is a harmless no-op before any fix has arrived', () {
      final session =
          RecordingSession(
              activityType: ActivityType.run,
              clock: () => t0,
            )
            ..start()
            // status is `recording` immediately after start(), even before the
            // first fix - evaluateStaleness must not judge staleness against a
            // nonexistent last fix.
            ..evaluateStaleness(t0.add(const Duration(minutes: 5)));

      expect(session.status, RecordingSessionStatus.recording);
    });

    test(
      'measures staleness against wall-clock, not the fix timestamp: a fix '
      'whose device timestamp leads wall-clock by an hour still goes stale',
      () {
        var current = t0;
        final session =
            RecordingSession(
                activityType: ActivityType.run,
                clock: () => current,
              )
              ..start()
              // Device/GPS timestamp an hour AHEAD of wall-clock. Judged
              // against `fix.timestamp`, `now.difference(...)` stays
              // negative for the next hour and staleness never fires -
              // silently disabling forgotten-end detection for exactly the
              // stalled-GPS case it exists to catch.
              ..addFix(
                _fixAt(
                  current.add(const Duration(hours: 1)),
                  speedMetersPerSecond: 2,
                ),
              );

        current = current.add(const Duration(seconds: 11));
        session.evaluateStaleness(current);

        expect(session.status, RecordingSessionStatus.autoPaused);
        expect(session.autoPausedAt, current);
      },
    );

    test(
      'a fix timestamp lagging wall-clock by an hour does not fire a false '
      'auto-pause while fixes are still arriving',
      () {
        var current = t0;
        final session =
            RecordingSession(
                activityType: ActivityType.run,
                clock: () => current,
              )
              ..start()
              ..addFix(
                _fixAt(
                  current.subtract(const Duration(hours: 1)),
                  speedMetersPerSecond: 2,
                ),
              );

        current = current.add(const Duration(seconds: 5));
        session.evaluateStaleness(current);

        expect(
          session.status,
          RecordingSessionStatus.recording,
          reason:
              'the fix arrived 5s ago by the clock; only its device '
              'timestamp is skewed',
        );
      },
    );

    test(
      'auto-resumes on the next accepted moving fix after a staleness '
      'auto-pause',
      () {
        var current = t0;
        final session =
            RecordingSession(
                activityType: ActivityType.run,
                clock: () => current,
              )
              ..start()
              ..addFix(_fixAt(current, speedMetersPerSecond: 2));

        current = current.add(const Duration(seconds: 11));
        session.evaluateStaleness(current);
        expect(session.status, RecordingSessionStatus.autoPaused);

        current = current.add(const Duration(seconds: 1));
        session.addFix(
          _fixAt(current, metersNorth: 5, speedMetersPerSecond: 2),
        );
        expect(session.status, RecordingSessionStatus.recording);
      },
    );
  });

  group('forgotten-end sample trimming (data minimisation)', () {
    test(
      'drops the trailing run of stationary paused fixes when finishing a '
      'forgotten end',
      () {
        var current = t0;
        final session =
            RecordingSession(
                activityType: ActivityType.run,
                clock: () => current,
              )
              ..start()
              ..addFix(_fixAt(current, speedMetersPerSecond: 2));

        current = current.add(const Duration(minutes: 20));
        session.markSignalLost(current);

        // An hour of stationary readings at wherever they stopped.
        for (var i = 1; i <= 30; i++) {
          current = current.add(const Duration(minutes: 2));
          session.addFix(_fixAt(current, speedMetersPerSecond: 0));
        }
        expect(session.samples, hasLength(31));

        final result = session.finish();

        expect(
          result.samples,
          hasLength(1),
          reason:
              'only the pre-stop fix describes the workout; the rest just '
              'pinpoint where they stopped and for how long',
        );
        expect(result.samples.every((s) => !s.wasPaused), isTrue);
      },
    );

    test('keeps paused fixes from a mid-workout pause', () {
      var current = t0;
      final session =
          RecordingSession(activityType: ActivityType.run, clock: () => current)
            ..start()
            ..addFix(_fixAt(current, speedMetersPerSecond: 2))
            ..pause();

      // Stopped at a crossing.
      current = current.add(const Duration(seconds: 30));
      session.addFix(_fixAt(current, speedMetersPerSecond: 0));

      // ...then ran on, and stopped for good.
      current = current.add(const Duration(seconds: 30));
      session
        ..resume()
        ..addFix(_fixAt(current, metersNorth: 50, speedMetersPerSecond: 2));

      current = current.add(const Duration(minutes: 10));
      session.markSignalLost(current);

      final result = session.finish();

      expect(
        result.samples,
        hasLength(3),
        reason:
            'the mid-workout paused fix keeps the route map continuous - '
            'only the trailing run is trimmed',
      );
      expect(result.samples[1].wasPaused, isTrue);
    });

    test('a deliberate finish keeps every sample', () {
      var current = t0;
      final session =
          RecordingSession(activityType: ActivityType.run, clock: () => current)
            ..start()
            ..addFix(_fixAt(current, speedMetersPerSecond: 2))
            ..pause();

      current = current.add(const Duration(seconds: 30));
      session.addFix(_fixAt(current, speedMetersPerSecond: 0));

      final result = session.finish();

      expect(
        result.samples,
        hasLength(2),
        reason:
            'a manual pause is a deliberate stop, not a forgotten one - no '
            'trim applies',
      );
    });
  });

  group('markSignalLost', () {
    test(
      'auto-pauses (not manual-pauses) so finish() still trims a forgotten '
      'end',
      () {
        var current = t0;
        final session =
            RecordingSession(
                activityType: ActivityType.run,
                clock: () => current,
              )
              ..start()
              ..addFix(_fixAt(current, speedMetersPerSecond: 2));

        current = current.add(const Duration(minutes: 20));
        session.markSignalLost(current);

        expect(session.status, RecordingSessionStatus.autoPaused);
        expect(session.autoPausedAt, current);

        // The user notices three hours later.
        final lostAt = current;
        current = current.add(const Duration(hours: 3));
        final result = session.finish();

        expect(
          result.elapsedTime,
          lostAt.difference(t0),
          reason:
              'elapsed must end at the signal-loss boundary, not three '
              'hours later - a manual pause here would bank the lot',
        );
      },
    );

    test('fires even before the first fix has arrived', () {
      var current = t0;
      final session = RecordingSession(
        activityType: ActivityType.run,
        clock: () => current,
      )..start();

      current = current.add(const Duration(seconds: 3));
      session.markSignalLost(current);

      expect(
        session.status,
        RecordingSessionStatus.autoPaused,
        reason:
            'the stream can die before any fix arrives - unlike '
            'evaluateStaleness, this needs no prior fix to measure against',
      );
    });

    test('is a harmless no-op while manually paused', () {
      var current = t0;
      final session =
          RecordingSession(activityType: ActivityType.run, clock: () => current)
            ..start()
            ..addFix(_fixAt(current, speedMetersPerSecond: 2))
            ..pause();

      current = current.add(const Duration(seconds: 30));
      session.markSignalLost(current);

      expect(session.status, RecordingSessionStatus.paused);
      expect(session.autoPausedAt, isNull);
    });
  });

  group('currentPaceSecondsPerKm', () {
    test('null with fewer than two moving points in the window', () {
      final session =
          RecordingSession(
              activityType: ActivityType.run,
              clock: () => t0,
            )
            ..start()
            ..addFix(_fixAt(t0, speedMetersPerSecond: 2));

      expect(session.currentPaceSecondsPerKm, isNull);
    });

    test('rolling window trims points older than 15s', () {
      var current = t0;
      final session =
          RecordingSession(activityType: ActivityType.run, clock: () => current)
            ..start()
            ..addFix(_fixAt(current, speedMetersPerSecond: 2));

      // A moving point every 5s for 20s (at 5, 10, 15, 20). By t=20s the
      // window only covers the last 15s, so the point at t=5 must have
      // been trimmed out.
      for (var i = 1; i <= 4; i++) {
        current = current.add(const Duration(seconds: 5));
        session.addFix(
          _fixAt(current, metersNorth: 10.0 * i, speedMetersPerSecond: 2),
        );
      }

      final expectedMeters = haversineDistanceMeters(
        10.0 / _metersPerDegreeLat,
        0,
        40.0 / _metersPerDegreeLat,
        0,
      );
      final expectedPace = 15.0 / (expectedMeters / 1000);
      expect(session.currentPaceSecondsPerKm, closeTo(expectedPace, 0.5));
    });

    test('cleared at a manual pause/resume boundary', () {
      var current = t0;
      final session =
          RecordingSession(activityType: ActivityType.run, clock: () => current)
            ..start()
            // First fix only establishes the reference (no point added);
            // the next two each add a distance point, giving >=2 points
            // in the window so pace is non-null.
            ..addFix(_fixAt(current, speedMetersPerSecond: 2));
      current = current.add(const Duration(seconds: 2));
      session.addFix(
        _fixAt(current, metersNorth: 10, speedMetersPerSecond: 2),
      );
      current = current.add(const Duration(seconds: 2));
      session.addFix(
        _fixAt(current, metersNorth: 20, speedMetersPerSecond: 2),
      );
      expect(session.currentPaceSecondsPerKm, isNotNull);

      session
        ..pause()
        ..resume();

      // A single fix right after resume only re-establishes the distance
      // reference - the pre-pause window must have been discarded, so
      // pace stays null until a second post-resume point exists.
      current = current.add(const Duration(seconds: 2));
      session.addFix(
        _fixAt(current, metersNorth: 30, speedMetersPerSecond: 2),
      );
      expect(session.currentPaceSecondsPerKm, isNull);
    });

    test(
      'an out-of-order fix (dtSeconds <= 0) is rejected and does not '
      'perturb pace',
      () {
        final session =
            RecordingSession(
                activityType: ActivityType.run,
                clock: () => t0,
              )
              ..start()
              // First fix establishes the reference; the next two each add a
              // distance point, giving >=2 points so pace is non-null.
              ..addFix(_fixAt(t0, speedMetersPerSecond: 2))
              ..addFix(
                _fixAt(
                  t0.add(const Duration(seconds: 2)),
                  metersNorth: 10,
                  speedMetersPerSecond: 2,
                ),
              )
              ..addFix(
                _fixAt(
                  t0.add(const Duration(seconds: 4)),
                  metersNorth: 20,
                  speedMetersPerSecond: 2,
                ),
              );
        final paceBefore = session.currentPaceSecondsPerKm;
        expect(paceBefore, isNotNull);

        // At/before the previous accepted fix's timestamp - discarded by
        // the dtSeconds <= 0 guard.
        session.addFix(
          _fixAt(
            t0.add(const Duration(seconds: 1)),
            metersNorth: 5,
            speedMetersPerSecond: 2,
          ),
        );

        expect(session.currentPaceSecondsPerKm, paceBefore);
        expect(session.samples, hasLength(3));
      },
    );
  });

  // Replays the exact input from the on-device review that reported "pace
  // stayed --:--/km for the whole session": Android-emulator `geo fix`
  // steps roughly 30s apart, each ~50m further on (~1.7 m/s, a 10:00/km
  // jog). The two tests below separate the two independent things that
  // input hits - one was a real defect in the pace window, the other is
  // deliberate auto-pause behaviour.
  group('sparse fix cadence (30s between fixes)', () {
    test(
      'still yields a live pace once distance is accumulating - the pace '
      'window is never trimmed below the two points a pace needs',
      () {
        var current = t0;
        final session =
            RecordingSession(
                activityType: ActivityType.run,
                clock: () => current,
              )
              ..start()
              // Speed is reported here (as a real GPS chipset does), so
              // the low-speed auto-pause never engages and the session
              // stays `recording` for the whole replay - isolating the
              // pace window from the staleness behaviour covered below.
              ..addFix(_fixAt(current, speedMetersPerSecond: 1.7));

        for (var step = 1; step <= 3; step++) {
          current = current.add(const Duration(seconds: 30));
          session.addFix(
            _fixAt(
              current,
              metersNorth: 50.0 * step,
              speedMetersPerSecond: 1.7,
            ),
          );
        }

        final segmentMeters = haversineDistanceMeters(
          0,
          0,
          50 / _metersPerDegreeLat,
          0,
        );
        expect(session.status, RecordingSessionStatus.recording);
        expect(session.distanceMeters, closeTo(segmentMeters * 3, 0.5));
        expect(session.movingTime, const Duration(seconds: 90));

        // 50m per 30s is 10:00/km. Before the `_trimRollingWindow` fix
        // this was null: each trim left a single point behind, because
        // consecutive fixes are further apart than the 15s window.
        expect(
          session.currentPaceSecondsPerKm,
          closeTo(30 / (segmentMeters / 1000), 1),
        );
      },
    );

    test(
      'with the controller ticker running, the staleness check auto-pauses '
      'in every gap - distance and pace stay unavailable, deliberately',
      () {
        var current = t0;
        final session =
            RecordingSession(
                activityType: ActivityType.run,
                clock: () => current,
              )
              ..start()
              // No reported speed, so auto-pause/resume runs on the speed
              // implied between fixes - the emulator's own behaviour.
              ..addFix(_fixAt(current));

        for (var step = 1; step <= 3; step++) {
          for (var second = 0; second < 30; second++) {
            current = current.add(const Duration(seconds: 1));
            // Mirrors RecordingController's 1s ticker.
            session.evaluateStaleness(current);
          }
          session.addFix(_fixAt(current, metersNorth: 50.0 * step));
        }

        // Every fix arrives to find the session auto-paused (the gap is
        // longer than the 10s staleness threshold) and only re-establishes
        // the distance reference on resume, so no segment is ever banked.
        // This is the documented rule, not a defect: across a 30s silence
        // the session has no evidence the user moved, and auto-pause
        // deliberately discards the gap's distance rather than inventing
        // a straight line through it.
        expect(session.distanceMeters, 0);
        expect(session.currentPaceSecondsPerKm, isNull);
        // 11s of moving time per gap: the staleness check fires on the
        // first tick strictly past the 10s threshold and back-dates the
        // moving-span close to that tick.
        expect(session.movingTime, const Duration(seconds: 33));
      },
    );
  });

  group('invalid transitions throw', () {
    test('start() twice', () {
      final session = RecordingSession(
        activityType: ActivityType.run,
        clock: () => t0,
      )..start();
      expect(session.start, throwsStateError);
    });

    test('pause() before start()', () {
      final session = RecordingSession(
        activityType: ActivityType.run,
        clock: () => t0,
      );
      expect(session.pause, throwsStateError);
    });

    test('resume() while recording (not paused)', () {
      final session = RecordingSession(
        activityType: ActivityType.run,
        clock: () => t0,
      )..start();
      expect(session.resume, throwsStateError);
    });

    test('finish() before start()', () {
      final session = RecordingSession(
        activityType: ActivityType.run,
        clock: () => t0,
      );
      expect(session.finish, throwsStateError);
    });

    test('finish() twice', () {
      final session =
          RecordingSession(activityType: ActivityType.run, clock: () => t0)
            ..start()
            ..finish();
      expect(session.finish, throwsStateError);
    });
  });

  test('addFix() before start() and after finish() are silently ignored', () {
    final session = RecordingSession(
      activityType: ActivityType.run,
      clock: () => t0,
    )..addFix(_fixAt(t0));
    expect(session.samples, isEmpty);

    session
      ..start()
      ..finish()
      ..addFix(_fixAt(t0));
    expect(session.samples, isEmpty);
  });
}
