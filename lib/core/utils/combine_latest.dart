import 'dart:async';

/// Combines the latest values of three streams into a single stream via
/// [combiner], emitting once every source has emitted at least once, then
/// again on every subsequent event from any source.
///
/// First need: `features/streaks/streaks_providers.dart`'s streak
/// provider watches three independent repository streams (activities,
/// cycle records, streak-pausing preference) and must recompute whenever
/// any of them changes. `package:rxdart`'s `combineLatest3` would be the
/// obvious tool, but it isn't a dependency and the project avoids adding
/// packages for something this small (`CLAUDE.md`); `package:async`'s
/// `StreamGroup`/`StreamZip` are resolved only transitively (not a
/// declared dependency — see `pubspec.lock`), so depending on them
/// directly would be an undeclared, silently-fragile dependency, which is
/// no better than adding a new one. Hand-rolled here instead, per
/// `architecture_overview.md`'s `core/utils/` note: "create when first
/// needed, not speculatively" — this is that first need.
///
/// Listening starts (and each source is subscribed to) only when the
/// returned stream itself gains its first listener, and every subscription
/// is cancelled when the returned stream's last listener cancels — the
/// same "cold until listened to, cleaned up on cancel" behaviour as the
/// underlying source streams (e.g. Drift's `.watch()`).
///
/// Nit N6: the returned stream is **broadcast**, so it supports multiple
/// simultaneous listeners, but it is **not** safe to cancel every listener
/// and then re-listen if any source stream is single-subscription (as
/// Drift's `.watch()` and most repository streams are) — a second
/// `onListen` would try to subscribe to those same single-subscription
/// sources a second time, which throws. Every current consumer of this
/// function passes a **fresh** source stream into each call instead of
/// reusing one across calls, which sidesteps this entirely; if a future
/// caller wants cancel-then-relisten semantics over long-lived source
/// streams, it needs different plumbing (e.g. re-fetching fresh source
/// streams on every listen, or switching the sources to broadcast).
Stream<T> combineLatest3<A, B, C, T>(
  Stream<A> streamA,
  Stream<B> streamB,
  Stream<C> streamC,
  T Function(A a, B b, C c) combiner,
) {
  late final StreamController<T> controller;
  StreamSubscription<A>? subA;
  StreamSubscription<B>? subB;
  StreamSubscription<C>? subC;

  A? latestA;
  B? latestB;
  C? latestC;
  var hasA = false;
  var hasB = false;
  var hasC = false;

  void emitIfReady() {
    if (hasA && hasB && hasC) {
      controller.add(combiner(latestA as A, latestB as B, latestC as C));
    }
  }

  controller = StreamController<T>.broadcast(
    onListen: () {
      subA = streamA.listen(
        (value) {
          latestA = value;
          hasA = true;
          emitIfReady();
        },
        onError: controller.addError,
      );
      subB = streamB.listen(
        (value) {
          latestB = value;
          hasB = true;
          emitIfReady();
        },
        onError: controller.addError,
      );
      subC = streamC.listen(
        (value) {
          latestC = value;
          hasC = true;
          emitIfReady();
        },
        onError: controller.addError,
      );
    },
    // Fire-and-forget: awaiting the source cancels here would make the
    // combined stream's own cancel (and therefore provider disposal) block
    // on them — and a Drift stream subscription's cancel future does not
    // complete under a widget test's fake-async zone, wedging teardown
    // until the 10-minute per-test cap (diagnosed 2026-08-27). Cleanup is
    // best-effort; nothing downstream depends on its completion.
    onCancel: () {
      unawaited(subA?.cancel());
      unawaited(subB?.cancel());
      unawaited(subC?.cancel());
    },
  );

  return controller.stream;
}

/// Two-source sibling of [combineLatest3] — same semantics (emits once
/// every source has emitted at least once, then again on every subsequent
/// event from any source; cold until listened to; best-effort
/// fire-and-forget cleanup on cancel for the same "Drift stream cancel
/// future doesn't complete under a widget test's fake-async zone" reason
/// documented on [combineLatest3]'s `onCancel`).
///
/// First need: `features/nutrition/nutrition_providers.dart` (S1-4) derives
/// the energy estimate and the daily calorie target from exactly two
/// streams — the user profile (height/weight/DOB) and the nutrition goals
/// (activity level, weight goal, requested deficit). Same `core/utils/`
/// note as its siblings: "create when first needed, not speculatively."
Stream<T> combineLatest2<A, B, T>(
  Stream<A> streamA,
  Stream<B> streamB,
  T Function(A a, B b) combiner,
) {
  late final StreamController<T> controller;
  StreamSubscription<A>? subA;
  StreamSubscription<B>? subB;

  A? latestA;
  B? latestB;
  var hasA = false;
  var hasB = false;

  void emitIfReady() {
    if (hasA && hasB) {
      controller.add(combiner(latestA as A, latestB as B));
    }
  }

  controller = StreamController<T>.broadcast(
    onListen: () {
      subA = streamA.listen(
        (value) {
          latestA = value;
          hasA = true;
          emitIfReady();
        },
        onError: controller.addError,
      );
      subB = streamB.listen(
        (value) {
          latestB = value;
          hasB = true;
          emitIfReady();
        },
        onError: controller.addError,
      );
    },
    onCancel: () {
      unawaited(subA?.cancel());
      unawaited(subB?.cancel());
    },
  );

  return controller.stream;
}

/// Four-source sibling of [combineLatest3] — same semantics (emits once
/// every source has emitted at least once, then again on every subsequent
/// event from any source; cold until listened to; best-effort fire-and-forget
/// cleanup on cancel for the same "Drift stream cancel future doesn't
/// complete under a widget test's fake-async zone" reason documented on
/// [combineLatest3]'s `onCancel`).
///
/// First need: `features/streaks/streaks_providers.dart`'s
/// `todayProtectionSourcesProvider` (S1-3, the streak card's "Today"
/// management sheet) combines exactly four independent per-source streams
/// (recovery day entries, protecting flare days, cycle records, and the
/// streak-pausing preference) — one fewer than [combineLatest5]'s streak
/// provider, since the per-source breakdown doesn't also need activities.
/// Same `core/utils/` note as [combineLatest5]: "create when first needed,
/// not speculatively."
Stream<T> combineLatest4<A, B, C, D, T>(
  Stream<A> streamA,
  Stream<B> streamB,
  Stream<C> streamC,
  Stream<D> streamD,
  T Function(A a, B b, C c, D d) combiner,
) {
  late final StreamController<T> controller;
  StreamSubscription<A>? subA;
  StreamSubscription<B>? subB;
  StreamSubscription<C>? subC;
  StreamSubscription<D>? subD;

  A? latestA;
  B? latestB;
  C? latestC;
  D? latestD;
  var hasA = false;
  var hasB = false;
  var hasC = false;
  var hasD = false;

  void emitIfReady() {
    if (hasA && hasB && hasC && hasD) {
      controller.add(
        combiner(latestA as A, latestB as B, latestC as C, latestD as D),
      );
    }
  }

  controller = StreamController<T>.broadcast(
    onListen: () {
      subA = streamA.listen(
        (value) {
          latestA = value;
          hasA = true;
          emitIfReady();
        },
        onError: controller.addError,
      );
      subB = streamB.listen(
        (value) {
          latestB = value;
          hasB = true;
          emitIfReady();
        },
        onError: controller.addError,
      );
      subC = streamC.listen(
        (value) {
          latestC = value;
          hasC = true;
          emitIfReady();
        },
        onError: controller.addError,
      );
      subD = streamD.listen(
        (value) {
          latestD = value;
          hasD = true;
          emitIfReady();
        },
        onError: controller.addError,
      );
    },
    onCancel: () {
      unawaited(subA?.cancel());
      unawaited(subB?.cancel());
      unawaited(subC?.cancel());
      unawaited(subD?.cancel());
    },
  );

  return controller.stream;
}

/// Five-source sibling of [combineLatest3] — same semantics (emits once
/// every source has emitted at least once, then again on every subsequent
/// event from any source; cold until listened to; best-effort fire-and-forget
/// cleanup on cancel for the same "Drift stream cancel future doesn't
/// complete under a widget test's fake-async zone" reason documented on
/// [combineLatest3]'s `onCancel`).
///
/// First need: `features/streaks/streaks_providers.dart`'s streak provider
/// grew a fifth source stream (recovery days, alongside activities, recent
/// flares, cycle records, and the streak-pausing preference) with the S1-2
/// `DayStatus` protected-recovery evolution — see
/// `architecture_overview.md`'s `core/utils/` note: "create when first
/// needed, not speculatively."
Stream<T> combineLatest5<A, B, C, D, E, T>(
  Stream<A> streamA,
  Stream<B> streamB,
  Stream<C> streamC,
  Stream<D> streamD,
  Stream<E> streamE,
  T Function(A a, B b, C c, D d, E e) combiner,
) {
  late final StreamController<T> controller;
  StreamSubscription<A>? subA;
  StreamSubscription<B>? subB;
  StreamSubscription<C>? subC;
  StreamSubscription<D>? subD;
  StreamSubscription<E>? subE;

  A? latestA;
  B? latestB;
  C? latestC;
  D? latestD;
  E? latestE;
  var hasA = false;
  var hasB = false;
  var hasC = false;
  var hasD = false;
  var hasE = false;

  void emitIfReady() {
    if (hasA && hasB && hasC && hasD && hasE) {
      controller.add(
        combiner(
          latestA as A,
          latestB as B,
          latestC as C,
          latestD as D,
          latestE as E,
        ),
      );
    }
  }

  controller = StreamController<T>.broadcast(
    onListen: () {
      subA = streamA.listen(
        (value) {
          latestA = value;
          hasA = true;
          emitIfReady();
        },
        onError: controller.addError,
      );
      subB = streamB.listen(
        (value) {
          latestB = value;
          hasB = true;
          emitIfReady();
        },
        onError: controller.addError,
      );
      subC = streamC.listen(
        (value) {
          latestC = value;
          hasC = true;
          emitIfReady();
        },
        onError: controller.addError,
      );
      subD = streamD.listen(
        (value) {
          latestD = value;
          hasD = true;
          emitIfReady();
        },
        onError: controller.addError,
      );
      subE = streamE.listen(
        (value) {
          latestE = value;
          hasE = true;
          emitIfReady();
        },
        onError: controller.addError,
      );
    },
    onCancel: () {
      unawaited(subA?.cancel());
      unawaited(subB?.cancel());
      unawaited(subC?.cancel());
      unawaited(subD?.cancel());
      unawaited(subE?.cancel());
    },
  );

  return controller.stream;
}
