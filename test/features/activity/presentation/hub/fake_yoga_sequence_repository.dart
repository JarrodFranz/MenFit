import 'dart:async';

import 'package:menfit_app/core/errors/app_exception.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence.dart';
import 'package:menfit_app/features/activity/domain/yoga_sequence_repository.dart';

/// In-memory [YogaSequenceRepository] for widget tests.
///
/// Matches the Drift implementation's two contract points the UI depends
/// on: `watchSequences` emits stored rows only (never a starter), most
/// recently updated first; and `saveSequence` on a soft-deleted id restores
/// it, which is what the delete snackbar's Undo relies on.
class FakeYogaSequenceRepository implements YogaSequenceRepository {
  /// While true every write throws a [StorageException], the sealed type
  /// the Drift repository wraps its failures in. The UI's job on a failed
  /// write is to say so and stay usable, and only this shows whether it
  /// does.
  bool failWrites = false;

  final Map<String, YogaSequence> _live = {};
  final Set<String> _deleted = {};
  final StreamController<List<YogaSequence>> _controller =
      StreamController<List<YogaSequence>>.broadcast();

  /// Every non-deleted sequence, newest update first.
  List<YogaSequence> get sequences {
    final list = _live.values.where((s) => !_deleted.contains(s.id)).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  /// Seeds without going through [saveSequence], so a test's arrange step
  /// is not indistinguishable from its act step.
  void seed(Iterable<YogaSequence> initial) {
    for (final sequence in initial) {
      _live[sequence.id] = sequence;
    }
    _emit();
  }

  void _emit() {
    if (!_controller.isClosed) _controller.add(sequences);
  }

  Future<void> dispose() => _controller.close();

  @override
  Stream<List<YogaSequence>> watchSequences() async* {
    yield sequences;
    yield* _controller.stream;
  }

  @override
  Future<YogaSequence?> getSequence(String id) async =>
      _deleted.contains(id) ? null : _live[id];

  @override
  Future<void> saveSequence(YogaSequence s) async {
    if (failWrites) throw const StorageException(message: 'disk full');
    _live[s.id] = s;
    _deleted.remove(s.id);
    _emit();
  }

  @override
  Future<void> deleteSequence(String id) async {
    if (failWrites) throw const StorageException(message: 'disk full');
    _deleted.add(id);
    _emit();
  }

  @override
  Future<void> deleteAllData() async {
    _live.clear();
    _deleted.clear();
    _emit();
  }
}
