import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/features/activity/domain/mindful_styles.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence.dart';

void main() {
  final stamp = DateTime.utc(2026, 9, 4, 7, 30);

  YogaSequence sequenceOf(
    List<YogaPose> poses, {
    String name = 'Evening flow',
    int transitionSeconds = defaultTransitionSeconds,
  }) {
    return YogaSequence(
      id: 'seq-1',
      name: name,
      createdAt: stamp,
      updatedAt: stamp,
      poses: poses,
      transitionSeconds: transitionSeconds,
    );
  }

  group('totalDuration', () {
    test('is zero for a sequence with no poses', () {
      expect(sequenceOf(const []).totalDuration, Duration.zero);
    });

    test('a single pose has no transition after it', () {
      final sequence = sequenceOf(
        const [YogaPose(name: 'Mountain', holdSeconds: 40)],
        transitionSeconds: 10,
      );
      expect(sequence.totalDuration, const Duration(seconds: 40));
    });

    test('transitions sit between poses, never after the last one', () {
      final sequence = sequenceOf(
        const [
          YogaPose(name: 'Mountain', holdSeconds: 30),
          YogaPose(name: 'Tree', holdSeconds: 30),
          YogaPose(name: 'Chair', holdSeconds: 30),
        ],
      );
      // 90s of holds + 2 gaps at the default 5s, not 3.
      expect(sequence.totalDuration, const Duration(seconds: 100));
    });

    test('a zero transition is honoured (a flow straight through)', () {
      final sequence = sequenceOf(
        const [
          YogaPose(name: 'Mountain', holdSeconds: 30),
          YogaPose(name: 'Tree', holdSeconds: 30),
        ],
        transitionSeconds: 0,
      );
      expect(sequence.totalDuration, const Duration(seconds: 60));
    });
  });

  group('poseCount / isEmpty', () {
    test('an empty sequence reports zero poses and isEmpty', () {
      final sequence = sequenceOf(const []);
      expect(sequence.poseCount, 0);
      expect(sequence.isEmpty, isTrue);
    });

    test('a populated sequence is not empty', () {
      final sequence = sequenceOf(
        const [
          YogaPose(name: 'Mountain', holdSeconds: 30),
          YogaPose(name: 'Tree', holdSeconds: 30),
        ],
      );
      expect(sequence.poseCount, 2);
      expect(sequence.isEmpty, isFalse);
    });
  });

  group('validateYogaSequence', () {
    test('a well-formed sequence has no problems', () {
      final problems = validateYogaSequence(
        sequenceOf(const [YogaPose(name: 'Mountain', holdSeconds: 30)]),
      );
      expect(problems, isEmpty);
    });

    test('a blank name is a problem, whitespace included', () {
      final problems = validateYogaSequence(
        sequenceOf(
          const [YogaPose(name: 'Mountain', holdSeconds: 30)],
          name: '   ',
        ),
      );
      expect(problems, contains('Give the sequence a name.'));
    });

    test('a sequence with no poses is a problem', () {
      final problems = validateYogaSequence(sequenceOf(const []));
      expect(problems, contains('Add at least one pose.'));
    });

    test('a pose with a blank name is reported by its position', () {
      final problems = validateYogaSequence(
        sequenceOf(
          const [
            YogaPose(name: 'Mountain', holdSeconds: 30),
            YogaPose(name: '  ', holdSeconds: 30),
          ],
        ),
      );
      expect(problems, contains('Pose 2 needs a name.'));
    });

    test('a hold below the minimum is a problem', () {
      final problems = validateYogaSequence(
        sequenceOf(
          const [
            YogaPose(name: 'Mountain', holdSeconds: minPoseHoldSeconds - 1),
          ],
        ),
      );
      expect(problems, hasLength(1));
      expect(problems.single, contains('Pose 1'));
    });

    test('a hold above the maximum is a problem', () {
      final problems = validateYogaSequence(
        sequenceOf(
          const [
            YogaPose(name: 'Mountain', holdSeconds: maxPoseHoldSeconds + 1),
          ],
        ),
      );
      expect(problems, hasLength(1));
    });

    test('the boundary holds themselves are fine', () {
      expect(
        validateYogaSequence(
          sequenceOf(
            const [
              YogaPose(name: 'Mountain', holdSeconds: minPoseHoldSeconds),
              YogaPose(name: 'Tree', holdSeconds: maxPoseHoldSeconds),
            ],
          ),
        ),
        isEmpty,
      );
    });

    test('a negative transition is a problem', () {
      final problems = validateYogaSequence(
        sequenceOf(
          const [YogaPose(name: 'Mountain', holdSeconds: 30)],
          transitionSeconds: -1,
        ),
      );
      expect(problems, hasLength(1));
      expect(problems.single, contains('Transition'));
    });

    test('a transition beyond the maximum is a problem', () {
      final problems = validateYogaSequence(
        sequenceOf(
          const [YogaPose(name: 'Mountain', holdSeconds: 30)],
          transitionSeconds: maxTransitionSeconds + 1,
        ),
      );
      expect(problems, hasLength(1));
    });

    test('a zero transition is allowed', () {
      expect(
        validateYogaSequence(
          sequenceOf(
            const [YogaPose(name: 'Mountain', holdSeconds: 30)],
            transitionSeconds: 0,
          ),
        ),
        isEmpty,
      );
    });

    test('every problem is reported at once, not just the first', () {
      final problems = validateYogaSequence(
        sequenceOf(
          const [YogaPose(name: '', holdSeconds: 1)],
          name: '',
          transitionSeconds: 99,
        ),
      );
      // Blank sequence name, blank pose name, out-of-range hold, and an
      // out-of-range transition: four independent facts to fix.
      expect(problems, hasLength(4));
    });
  });

  group('JSON round-trip', () {
    test('a pose keeps its side and cue', () {
      const pose = YogaPose(
        name: 'Warrior II',
        holdSeconds: 45,
        side: YogaPoseSide.left,
        cue: 'Arms wide, gaze over the front hand.',
      );

      final restored = YogaPose.fromJson(pose.toJson());

      expect(restored, pose);
      expect(restored.side, YogaPoseSide.left);
      expect(restored.cue, 'Arms wide, gaze over the front hand.');
    });

    test('a pose with no side round-trips as none', () {
      const pose = YogaPose(name: 'Mountain', holdSeconds: 30);
      expect(YogaPose.fromJson(pose.toJson()).side, YogaPoseSide.none);
    });

    test('an unrecognised stored side falls back to none, not a crash', () {
      final restored = YogaPose.fromJson(const {
        'name': 'Mountain',
        'holdSeconds': 30,
        'side': 'sideways',
      });
      expect(restored.side, YogaPoseSide.none);
    });

    test('a sequence keeps every field, poses included', () {
      final sequence = YogaSequence(
        id: 'seq-42',
        name: 'Morning',
        description: 'Short and slow.',
        createdAt: stamp,
        updatedAt: stamp.add(const Duration(hours: 2)),
        transitionSeconds: 8,
        style: 'Yin',
        poses: const [
          YogaPose(name: 'Mountain', holdSeconds: 30, cue: 'Stand tall.'),
          YogaPose(
            name: 'Pigeon',
            holdSeconds: 45,
            side: YogaPoseSide.right,
          ),
        ],
      );

      final restored = YogaSequence.fromJson(sequence.toJson());

      expect(restored.id, 'seq-42');
      expect(restored.name, 'Morning');
      expect(restored.description, 'Short and slow.');
      expect(restored.transitionSeconds, 8);
      expect(restored.style, 'Yin');
      expect(restored.createdAt, stamp);
      expect(restored.updatedAt, stamp.add(const Duration(hours: 2)));
      expect(restored.poses, sequence.poses);
      expect(restored.totalDuration, sequence.totalDuration);
    });

    test('a null style round-trips as null, not as an empty string', () {
      final sequence = sequenceOf(
        const [YogaPose(name: 'Mountain', holdSeconds: 30)],
      );
      expect(sequence.style, isNull);
      expect(YogaSequence.fromJson(sequence.toJson()).style, isNull);
    });
  });

  group('copyAsNew', () {
    test('takes a fresh id and fresh timestamps, keeping the content', () {
      final starter = YogaSequenceStarters.morningFlow;

      final copy = starter.copyAsNew();

      expect(copy.id, isNot(starter.id));
      expect(copy.id, isNot(YogaSequenceStarters.morningFlowId));
      expect(copy.name, starter.name);
      expect(copy.poses, starter.poses);
      expect(copy.transitionSeconds, starter.transitionSeconds);
      expect(copy.style, starter.style);
      expect(copy.createdAt.isAfter(starter.createdAt), isTrue);
      expect(copy.createdAt.isUtc, isTrue);
    });

    test('two copies of one starter are two distinct sequences', () {
      final first = YogaSequenceStarters.windDown.copyAsNew();
      final second = YogaSequenceStarters.windDown.copyAsNew();
      expect(first.id, isNot(second.id));
    });

    test('an optional name overrides the starter name', () {
      final copy = YogaSequenceStarters.windDown.copyAsNew(name: 'My evening');
      expect(copy.name, 'My evening');
    });
  });

  group('YogaPoseCatalogue', () {
    test('offers pose names, with no duplicates and nothing blank', () {
      const poses = YogaPoseCatalogue.commonPoses;
      expect(poses, isNotEmpty);
      expect(poses.toSet(), hasLength(poses.length));
      expect(poses.every((p) => p.trim().isNotEmpty), isTrue);
    });

    test('carries no benefit or medical language', () {
      // The catalogue is names only - a claim about what a pose does to a
      // body is exactly what this app does not make (mens_health.md).
      const banned = [
        'burn',
        'detox',
        'tone',
        'slim',
        'cure',
        'heal',
        'fix',
        'treat',
        'relieve',
        'boost',
      ];
      for (final pose in YogaPoseCatalogue.commonPoses) {
        final lower = pose.toLowerCase();
        for (final word in banned) {
          expect(
            lower.contains(word),
            isFalse,
            reason: '"$pose" reads as a claim, not a name',
          );
        }
      }
    });
  });

  group('YogaSequenceStarters', () {
    test('there are exactly two, under their fixed ids', () {
      final starters = YogaSequenceStarters.starters;
      expect(starters, hasLength(2));
      expect(
        starters.map((s) => s.id),
        [YogaSequenceStarters.morningFlowId, YogaSequenceStarters.windDownId],
      );
      expect(YogaSequenceStarters.morningFlowId, 'starter-morning-flow');
      expect(YogaSequenceStarters.windDownId, 'starter-wind-down');
    });

    test('both validate clean', () {
      for (final starter in YogaSequenceStarters.starters) {
        expect(
          validateYogaSequence(starter),
          isEmpty,
          reason: '${starter.name} must be saveable as-is',
        );
      }
    });

    test('each has eight poses held 30-45 seconds, five seconds apart', () {
      for (final starter in YogaSequenceStarters.starters) {
        expect(starter.poseCount, 8, reason: starter.name);
        expect(starter.transitionSeconds, 5, reason: starter.name);
        for (final pose in starter.poses) {
          expect(pose.holdSeconds, inInclusiveRange(30, 45), reason: pose.name);
        }
      }
    });

    test('every pose name comes from the catalogue', () {
      for (final starter in YogaSequenceStarters.starters) {
        for (final pose in starter.poses) {
          expect(
            YogaPoseCatalogue.commonPoses,
            contains(pose.name),
            reason:
                '"${pose.name}" is not in the autocomplete catalogue, so a '
                'user editing this starter would see a name they cannot '
                'retype from the suggestions',
          );
        }
      }
    });

    test('their styles come from the offered yoga styles', () {
      for (final starter in YogaSequenceStarters.starters) {
        expect(MindfulStyles.yogaStyles, contains(starter.style));
      }
    });

    test('the copy carries no body-shaping or medical claims', () {
      const banned = [
        'burn',
        'detox',
        'tone',
        'slim',
        'fat',
        'calorie',
        'cure',
        'heal',
        'treat',
        'therapy',
        'relieve',
        'anxiety',
        'pain',
      ];
      for (final starter in YogaSequenceStarters.starters) {
        final text = [
          starter.name,
          starter.description,
          ...starter.poses.map((p) => '${p.name} ${p.cue}'),
        ].join(' ').toLowerCase();
        for (final word in banned) {
          expect(
            text.contains(word),
            isFalse,
            reason: '"${starter.name}" copy contains "$word"',
          );
        }
      }
    });

    test('one-sided poses appear once per side, and say which', () {
      final sided = YogaSequenceStarters.morningFlow.poses
          .where((p) => p.side != YogaPoseSide.none)
          .toList();
      expect(sided, isNotEmpty);
      expect(
        sided.where((p) => p.side == YogaPoseSide.left).length,
        sided.where((p) => p.side == YogaPoseSide.right).length,
        reason: 'a sequence that works one side must work the other',
      );
      expect(
        sided.firstWhere((p) => p.side == YogaPoseSide.left).displayName,
        endsWith(', left'),
      );
    });
  });
}
