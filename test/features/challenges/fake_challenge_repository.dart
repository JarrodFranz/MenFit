import 'dart:async';

import 'package:menfit_app/features/challenges/domain/challenge.dart';
import 'package:menfit_app/features/challenges/domain/challenge_repository.dart';

/// An in-memory [ChallengeRepository] for the presentation tests.
///
/// Deliberately not a Drift database: these tests are about what the
/// screens render, and a real database would drag in the query-stream
/// cleanup timers that wedge widget suites (see
/// `test/features/weight/weight_test_vocabulary.dart#flushDriftTimers`).
/// The Drift implementation has its own tests in
/// `challenge_repository_test.dart`.
///
/// Emits the current list immediately on subscribe and again on every
/// write, which is what a Drift `watch` query does and what every
/// `StreamProvider` above it assumes.
class FakeChallengeRepository implements ChallengeRepository {
  final Map<String, Challenge> _byId = <String, Challenge>{};
  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// Seeds without notifying — for arranging state before a screen mounts.
  void seed(Iterable<Challenge> challenges) {
    for (final challenge in challenges) {
      _byId[challenge.id] = challenge;
    }
  }

  Future<void> dispose() => _changes.close();

  /// Newest window first, ties broken on id descending — the ordering
  /// `domain/challenge_repository.dart` promises on every read.
  List<Challenge> _sorted() {
    final all = _byId.values.toList()
      ..sort((a, b) {
        final byWindow = b.blueprint.windowStart.compareTo(
          a.blueprint.windowStart,
        );
        return byWindow != 0 ? byWindow : b.id.compareTo(a.id);
      });
    return all;
  }

  @override
  Stream<List<Challenge>> watchChallenges() async* {
    yield _sorted();
    yield* _changes.stream.map((_) => _sorted());
  }

  @override
  Future<List<Challenge>> getChallenges() async => _sorted();

  @override
  Stream<Challenge?> watchChallenge(String id) async* {
    yield _byId[id];
    yield* _changes.stream.map((_) => _byId[id]);
  }

  @override
  Future<Challenge?> getChallenge(String id) async => _byId[id];

  @override
  Future<void> saveChallenge(Challenge challenge) async {
    // `createdAt` never moves after the first save — the convention the
    // real repository documents, and the one that makes a second join of
    // the same challenge harmless.
    final existing = _byId[challenge.id];
    _byId[challenge.id] = existing == null
        ? challenge
        : challenge.copyWith(createdAt: existing.createdAt);
    _changes.add(null);
  }

  @override
  Future<void> deleteChallenge(String id) async {
    _byId.remove(id);
    _changes.add(null);
  }

  @override
  Future<void> deleteAllData() async {
    _byId.clear();
    _changes.add(null);
  }
}
