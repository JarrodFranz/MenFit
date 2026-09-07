import 'package:menfit_app/core/domain/entity_id.dart';
import 'package:meta/meta.dart';

/// Shortest hold a pose may be given, in seconds.
const int minPoseHoldSeconds = 5;

/// Longest hold a pose may be given, in seconds.
const int maxPoseHoldSeconds = 600;

/// Hold given to a newly added pose, in seconds.
const int defaultPoseHoldSeconds = 30;

/// Shortest gap between two poses, in seconds. Zero means "no gap".
const int minTransitionSeconds = 0;

/// Longest gap between two poses, in seconds.
const int maxTransitionSeconds = 60;

/// Default gap between two poses, in seconds.
const int defaultTransitionSeconds = 5;

/// Which side of the body a pose is held on.
///
/// A one-sided pose is stored once per side rather than as a single entry
/// with a "repeat on the other side" flag, so the runner can announce
/// "Warrior II, left" and time each side independently.
enum YogaPoseSide {
  none,
  left,
  right;

  /// Parses the persisted string form, defaulting to [none] for anything
  /// unrecognised (including a value written by a newer app version).
  static YogaPoseSide fromStorage(String? value) => switch (value) {
    'left' => YogaPoseSide.left,
    'right' => YogaPoseSide.right,
    _ => YogaPoseSide.none,
  };

  /// The persisted string form of this value.
  String toStorage() => switch (this) {
    YogaPoseSide.none => 'none',
    YogaPoseSide.left => 'left',
    YogaPoseSide.right => 'right',
  };
}

/// One pose in a [YogaSequence], with the time it is held for.
///
/// Plain immutable class rather than freezed, matching
/// `StrengthExerciseTemplate` in `strength_routine.dart`: both are JSON
/// blobs inside a single text column, so `fromJson` has to tolerate rows
/// written by an older app version and freezed's generated parser does not.
@immutable
class YogaPose {
  const YogaPose({
    required this.name,
    required this.holdSeconds,
    this.side = YogaPoseSide.none,
    this.cue = '',
  });

  factory YogaPose.fromJson(Map<String, dynamic> json) {
    return YogaPose(
      name: json['name'] as String? ?? 'Pose',
      holdSeconds:
          (json['holdSeconds'] as num?)?.toInt() ?? defaultPoseHoldSeconds,
      side: YogaPoseSide.fromStorage(json['side'] as String?),
      cue: json['cue'] as String? ?? '',
    );
  }

  final String name;
  final int holdSeconds;
  final YogaPoseSide side;

  /// Free-text reminder shown while the pose is held. Never medical
  /// guidance — see `knowledge/domain/womens_health.md`.
  final String cue;

  /// The name as it should be spoken/shown, with the side appended when the
  /// pose has one ("Warrior II, left").
  String get displayName => switch (side) {
    YogaPoseSide.none => name,
    YogaPoseSide.left => '$name, left',
    YogaPoseSide.right => '$name, right',
  };

  Map<String, dynamic> toJson() => {
    'name': name,
    'holdSeconds': holdSeconds,
    'side': side.toStorage(),
    'cue': cue,
  };

  YogaPose copyWith({
    String? name,
    int? holdSeconds,
    YogaPoseSide? side,
    String? cue,
  }) {
    return YogaPose(
      name: name ?? this.name,
      holdSeconds: holdSeconds ?? this.holdSeconds,
      side: side ?? this.side,
      cue: cue ?? this.cue,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YogaPose &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          holdSeconds == other.holdSeconds &&
          side == other.side &&
          cue == other.cue;

  @override
  int get hashCode => Object.hash(name, holdSeconds, side, cue);
}

/// An ordered routine of poses the user built, practised with a fixed gap
/// between consecutive poses.
@immutable
class YogaSequence {
  const YogaSequence({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.description = '',
    this.poses = const [],
    this.transitionSeconds = defaultTransitionSeconds,
    this.style,
  });

  /// A brand-new sequence with a client-generated UUIDv7 id and matching
  /// created/updated stamps.
  factory YogaSequence.create({
    required String name,
    String description = '',
    List<YogaPose> poses = const [],
    int transitionSeconds = defaultTransitionSeconds,
    String? style,
  }) {
    final now = DateTime.now().toUtc();
    return YogaSequence(
      id: EntityId.generate(),
      name: name,
      createdAt: now,
      updatedAt: now,
      description: description,
      poses: poses,
      transitionSeconds: transitionSeconds,
      style: style,
    );
  }

  factory YogaSequence.fromJson(Map<String, dynamic> json) {
    return YogaSequence(
      id: json['id'] as String? ?? EntityId.generate(),
      name: json['name'] as String? ?? 'Sequence',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now().toUtc(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now().toUtc(),
      description: json['description'] as String? ?? '',
      poses:
          (json['poses'] as List<dynamic>?)
              ?.map((p) => YogaPose.fromJson(p as Map<String, dynamic>))
              .toList() ??
          const [],
      transitionSeconds:
          (json['transitionSeconds'] as num?)?.toInt() ??
          defaultTransitionSeconds,
      style: json['style'] as String?,
    );
  }

  final String id;
  final String name;
  final String description;
  final List<YogaPose> poses;

  /// Gap held between two consecutive poses. Applies *between* poses only —
  /// see [totalDuration].
  final int transitionSeconds;

  /// One of `MindfulStyles.yogaStyles` (`mindful_styles.dart`), or null when
  /// the user did not pick one. Stored as free text, not an enum: a label
  /// written by a newer version must still round-trip.
  final String? style;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Holds plus the transitions *between* poses — there is no transition
  /// after the last pose, and a single-pose sequence has none at all.
  Duration get totalDuration {
    final holds = poses.fold<int>(0, (sum, pose) => sum + pose.holdSeconds);
    final gaps = poses.isEmpty ? 0 : (poses.length - 1) * transitionSeconds;
    return Duration(seconds: holds + gaps);
  }

  int get poseCount => poses.length;

  bool get isEmpty => poses.isEmpty;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'poses': poses.map((p) => p.toJson()).toList(),
    'transitionSeconds': transitionSeconds,
    'style': style,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  YogaSequence copyWith({
    String? id,
    String? name,
    String? description,
    List<YogaPose>? poses,
    int? transitionSeconds,
    String? style,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return YogaSequence(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
      poses: poses ?? this.poses,
      transitionSeconds: transitionSeconds ?? this.transitionSeconds,
      style: style ?? this.style,
    );
  }

  /// A saveable copy of this sequence under a fresh id and fresh timestamps.
  ///
  /// This is how a starter from [YogaSequenceStarters] becomes the user's
  /// own: starters are a domain constant with fixed ids and are **never**
  /// persisted, so "Add a starter sequence" saves `starter.copyAsNew()` and
  /// from that moment the copy is an ordinary user row she can edit or
  /// delete without the starter changing.
  YogaSequence copyAsNew({String? name}) {
    final now = DateTime.now().toUtc();
    return YogaSequence(
      id: EntityId.generate(),
      name: name ?? this.name,
      createdAt: now,
      updatedAt: now,
      description: description,
      poses: poses,
      transitionSeconds: transitionSeconds,
      style: style,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YogaSequence &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Everything wrong with [sequence], as messages fit to show the user.
///
/// An empty list means it is saveable. Pure function, no I/O — the editor
/// calls it on every keystroke and the repository never has to.
List<String> validateYogaSequence(YogaSequence sequence) {
  final problems = <String>[];

  if (sequence.name.trim().isEmpty) {
    problems.add('Give the sequence a name.');
  }
  if (sequence.poses.isEmpty) {
    problems.add('Add at least one pose.');
  }

  for (var i = 0; i < sequence.poses.length; i++) {
    final pose = sequence.poses[i];
    final position = i + 1;
    if (pose.name.trim().isEmpty) {
      problems.add('Pose $position needs a name.');
    }
    if (pose.holdSeconds < minPoseHoldSeconds ||
        pose.holdSeconds > maxPoseHoldSeconds) {
      problems.add(
        'Pose $position: hold between $minPoseHoldSeconds and '
        '$maxPoseHoldSeconds seconds.',
      );
    }
  }

  if (sequence.transitionSeconds < minTransitionSeconds ||
      sequence.transitionSeconds > maxTransitionSeconds) {
    problems.add(
      'Transition between poses must be $minTransitionSeconds to '
      '$maxTransitionSeconds seconds.',
    );
  }

  return problems;
}

/// Widely used English pose names, offered as autocomplete while building a
/// sequence.
///
/// Names only. No benefit claims, no "good for X" copy, nothing that reads
/// as guidance about a body or a condition — the app does not make those
/// claims (`knowledge/domain/womens_health.md`). The list is a convenience,
/// not a closed set: a user may type any pose name she likes, and
/// [validateYogaSequence] never checks membership here.
abstract final class YogaPoseCatalogue {
  static const List<String> commonPoses = [
    'Mountain',
    "Child's Pose",
    'Downward Dog',
    'Cat-Cow',
    'Cobra',
    'Warrior I',
    'Warrior II',
    'Warrior III',
    'Triangle',
    'Tree',
    'Chair',
    'Bridge',
    'Pigeon',
    'Low Lunge',
    'High Lunge',
    'Plank',
    'Side Plank',
    'Boat',
    'Camel',
    'Bow',
    'Seated Forward Fold',
    'Standing Forward Fold',
    'Half Moon',
    'Eagle',
    'Happy Baby',
    'Supine Twist',
    'Reclined Butterfly',
    'Legs Up the Wall',
    'Corpse Pose (Savasana)',
    'Sun Salutation flow',
  ];
}

/// Two ready-made sequences offered on an empty sequence list.
///
/// **These are never persisted.** `YogaSequenceRepository.watchSequences()`
/// returns stored rows and nothing else, so the list is honestly empty until
/// the user saves something. The UI offers "Add a starter sequence", which
/// saves `starter.copyAsNew()` — a fresh id, her row, hers to edit or
/// delete. The fixed ids below exist so the offer can tell which starters
/// are on screen, not so anything can be looked up by them in the database.
///
/// Copy is deliberately neutral: what you do, not what it does to you. No
/// "burn", "detox", "tone", "slim" — same rule as the nutrition copy
/// (`knowledge/domain/nutrition.md`).
abstract final class YogaSequenceStarters {
  /// Fixed id of the morning starter. Not a database key — see the class
  /// doc.
  static const String morningFlowId = 'starter-morning-flow';

  /// Fixed id of the wind-down starter. Not a database key — see the class
  /// doc.
  static const String windDownId = 'starter-wind-down';

  /// A fixed instant, so the starters are `const`-shaped constants rather
  /// than values that differ per call. A saved copy gets real timestamps
  /// from [YogaSequence.copyAsNew].
  static final DateTime _epoch = DateTime.utc(2026);

  static final YogaSequence morningFlow = YogaSequence(
    id: morningFlowId,
    name: 'Morning flow',
    description: 'A short standing sequence to start the day.',
    createdAt: _epoch,
    updatedAt: _epoch,
    style: 'Vinyasa',
    poses: const [
      YogaPose(
        name: 'Mountain',
        holdSeconds: 30,
        cue: 'Stand tall, arms by your sides, breathing steadily.',
      ),
      YogaPose(
        name: 'Sun Salutation flow',
        holdSeconds: 45,
        cue: 'Move with your breath at whatever pace suits you today.',
      ),
      YogaPose(
        name: 'Downward Dog',
        holdSeconds: 40,
        cue: 'Hands shoulder-width, knees as bent as you like.',
      ),
      YogaPose(
        name: 'Low Lunge',
        holdSeconds: 30,
        side: YogaPoseSide.left,
        cue: 'Back knee down, front knee over the ankle.',
      ),
      YogaPose(
        name: 'Low Lunge',
        holdSeconds: 30,
        side: YogaPoseSide.right,
        cue: 'Back knee down, front knee over the ankle.',
      ),
      YogaPose(
        name: 'Warrior II',
        holdSeconds: 40,
        side: YogaPoseSide.left,
        cue: 'Arms wide, gaze over the front hand.',
      ),
      YogaPose(
        name: 'Warrior II',
        holdSeconds: 40,
        side: YogaPoseSide.right,
        cue: 'Arms wide, gaze over the front hand.',
      ),
      YogaPose(
        name: 'Standing Forward Fold',
        holdSeconds: 30,
        cue: 'Soft knees, let the head hang.',
      ),
    ],
  );

  static final YogaSequence windDown = YogaSequence(
    id: windDownId,
    name: 'Wind down',
    description: 'A slower floor sequence for the end of the day.',
    createdAt: _epoch,
    updatedAt: _epoch,
    style: 'Yin',
    poses: const [
      YogaPose(
        name: "Child's Pose",
        holdSeconds: 45,
        cue: 'Knees wide or together, whichever settles.',
      ),
      YogaPose(
        name: 'Cat-Cow',
        holdSeconds: 40,
        cue: 'Round and arch slowly, one breath each way.',
      ),
      YogaPose(
        name: 'Seated Forward Fold',
        holdSeconds: 45,
        cue: 'Bend the knees as much as you need.',
      ),
      YogaPose(
        name: 'Pigeon',
        holdSeconds: 45,
        side: YogaPoseSide.left,
        cue: 'Support the hip with a cushion if that is more comfortable.',
      ),
      YogaPose(
        name: 'Pigeon',
        holdSeconds: 45,
        side: YogaPoseSide.right,
        cue: 'Support the hip with a cushion if that is more comfortable.',
      ),
      YogaPose(
        name: 'Supine Twist',
        holdSeconds: 30,
        side: YogaPoseSide.left,
        cue: 'Knees drop to one side, shoulders stay down.',
      ),
      YogaPose(
        name: 'Supine Twist',
        holdSeconds: 30,
        side: YogaPoseSide.right,
        cue: 'Knees drop to one side, shoulders stay down.',
      ),
      YogaPose(
        name: 'Corpse Pose (Savasana)',
        holdSeconds: 45,
        cue: 'Lie still and let the breath find its own rhythm.',
      ),
    ],
  );

  /// The starters offered on an empty list, in the order they are shown.
  static List<YogaSequence> get starters => [morningFlow, windDown];
}
