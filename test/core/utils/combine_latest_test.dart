import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/utils/combine_latest.dart';

/// Lets pending microtasks (stream event delivery is always microtask
/// -scheduled, even for a `StreamController.add` called synchronously)
/// run before the next assertion.
Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  group('combineLatest3', () {
    test(
      'emits nothing until every source has emitted at least once',
      () async {
        final a = StreamController<int>();
        final b = StreamController<String>();
        final c = StreamController<bool>();
        final events = <String>[];

        final sub = combineLatest3(
          a.stream,
          b.stream,
          c.stream,
          (x, y, z) => '$x-$y-$z',
        ).listen(events.add);
        addTearDown(sub.cancel);
        addTearDown(a.close);
        addTearDown(b.close);
        addTearDown(c.close);

        a.add(1);
        await _flush();
        expect(events, isEmpty);

        b.add('x');
        await _flush();
        expect(events, isEmpty);

        c.add(true);
        await _flush();
        expect(events, ['1-x-true']);
      },
    );

    test('re-emits on every subsequent event from any single source', () async {
      final a = StreamController<int>();
      final b = StreamController<String>();
      final c = StreamController<bool>();
      final events = <String>[];

      final sub = combineLatest3(
        a.stream,
        b.stream,
        c.stream,
        (x, y, z) => '$x-$y-$z',
      ).listen(events.add);
      addTearDown(sub.cancel);
      addTearDown(a.close);
      addTearDown(b.close);
      addTearDown(c.close);

      a.add(1);
      b.add('x');
      c.add(true);
      await _flush();
      expect(events, ['1-x-true']);

      a.add(2); // only A changes - B and C's latest values carry over.
      await _flush();
      expect(events, ['1-x-true', '2-x-true']);

      c.add(false); // only C changes.
      await _flush();
      expect(events, ['1-x-true', '2-x-true', '2-x-false']);
    });

    test('an error on any source propagates as an error on the combined '
        'stream', () async {
      final a = StreamController<int>();
      final b = StreamController<String>();
      final c = StreamController<bool>();
      final errors = <Object>[];

      final sub = combineLatest3(
        a.stream,
        b.stream,
        c.stream,
        (x, y, z) => '$x-$y-$z',
      ).listen((_) {}, onError: errors.add);
      addTearDown(sub.cancel);
      addTearDown(a.close);
      addTearDown(b.close);
      addTearDown(c.close);

      a.addError('boom from A');
      await _flush();
      expect(errors, ['boom from A']);

      b.addError('boom from B');
      await _flush();
      expect(errors, ['boom from A', 'boom from B']);
    });

    test(
      'a single listener subscribes every source on listen and cancels '
      'every source on cancel',
      () async {
        final a = StreamController<int>();
        final b = StreamController<String>();
        final c = StreamController<bool>();

        expect(a.hasListener, isFalse);
        expect(b.hasListener, isFalse);
        expect(c.hasListener, isFalse);

        final sub = combineLatest3(
          a.stream,
          b.stream,
          c.stream,
          (x, y, z) => '$x-$y-$z',
        ).listen((_) {});

        expect(a.hasListener, isTrue);
        expect(b.hasListener, isTrue);
        expect(c.hasListener, isTrue);

        await sub.cancel();
        // Cleanup is fire-and-forget (see the dartdoc on `onCancel`), so
        // give the event loop a turn to actually process the cancels.
        await _flush();

        expect(a.hasListener, isFalse);
        expect(b.hasListener, isFalse);
        expect(c.hasListener, isFalse);

        await a.close();
        await b.close();
        await c.close();
      },
    );
  });

  group('combineLatest5', () {
    test(
      'emits nothing until every source has emitted at least once',
      () async {
        final a = StreamController<int>();
        final b = StreamController<String>();
        final c = StreamController<bool>();
        final d = StreamController<double>();
        final e = StreamController<int>();
        final events = <String>[];

        final sub = combineLatest5(
          a.stream,
          b.stream,
          c.stream,
          d.stream,
          e.stream,
          (v, w, x, y, z) => '$v-$w-$x-$y-$z',
        ).listen(events.add);
        addTearDown(sub.cancel);
        addTearDown(a.close);
        addTearDown(b.close);
        addTearDown(c.close);
        addTearDown(d.close);
        addTearDown(e.close);

        a.add(1);
        b.add('x');
        c.add(true);
        d.add(1.5);
        await _flush();
        expect(events, isEmpty);

        e.add(9);
        await _flush();
        expect(events, ['1-x-true-1.5-9']);
      },
    );

    test('re-emits on every subsequent event from any single source', () async {
      final a = StreamController<int>();
      final b = StreamController<String>();
      final c = StreamController<bool>();
      final d = StreamController<double>();
      final e = StreamController<int>();
      final events = <String>[];

      final sub = combineLatest5(
        a.stream,
        b.stream,
        c.stream,
        d.stream,
        e.stream,
        (v, w, x, y, z) => '$v-$w-$x-$y-$z',
      ).listen(events.add);
      addTearDown(sub.cancel);
      addTearDown(a.close);
      addTearDown(b.close);
      addTearDown(c.close);
      addTearDown(d.close);
      addTearDown(e.close);

      a.add(1);
      b.add('x');
      c.add(true);
      d.add(1.5);
      e.add(9);
      await _flush();
      expect(events, ['1-x-true-1.5-9']);

      e.add(10); // only E changes - everything else's latest carries over.
      await _flush();
      expect(events, ['1-x-true-1.5-9', '1-x-true-1.5-10']);
    });

    test(
      'a single listener subscribes every source on listen and cancels '
      'every source on cancel',
      () async {
        final a = StreamController<int>();
        final b = StreamController<String>();
        final c = StreamController<bool>();
        final d = StreamController<double>();
        final e = StreamController<int>();

        expect(a.hasListener, isFalse);
        expect(e.hasListener, isFalse);

        final sub = combineLatest5(
          a.stream,
          b.stream,
          c.stream,
          d.stream,
          e.stream,
          (v, w, x, y, z) => '$v-$w-$x-$y-$z',
        ).listen((_) {});

        expect(a.hasListener, isTrue);
        expect(b.hasListener, isTrue);
        expect(c.hasListener, isTrue);
        expect(d.hasListener, isTrue);
        expect(e.hasListener, isTrue);

        await sub.cancel();
        await _flush();

        expect(a.hasListener, isFalse);
        expect(b.hasListener, isFalse);
        expect(c.hasListener, isFalse);
        expect(d.hasListener, isFalse);
        expect(e.hasListener, isFalse);

        await a.close();
        await b.close();
        await c.close();
        await d.close();
        await e.close();
      },
    );
  });
}
