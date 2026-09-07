import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:menfit_app/core/platform/wearables/ble_heart_rate_parser.dart';

void main() {
  group('BleHeartRateParser', () {
    test('parses standard 8-bit heart rate packet', () {
      final bytes = Uint8List.fromList([0x00, 142]);
      final measurement = BleHeartRateParser.parse(bytes);

      expect(measurement, isNotNull);
      expect(measurement!.heartRateBpm, 142);
      expect(measurement.contactSupported, isFalse);
      expect(measurement.contactDetected, isFalse);
      expect(measurement.energyExpendedKj, isNull);
      expect(measurement.rrIntervalsMs, isEmpty);
    });

    test('parses 16-bit heart rate packet', () {
      // 185 bpm = 0x00B9
      final bytes = Uint8List.fromList([0x01, 0xB9, 0x00]);
      final measurement = BleHeartRateParser.parse(bytes);

      expect(measurement, isNotNull);
      expect(measurement!.heartRateBpm, 185);
    });

    test('parses skin contact status correctly', () {
      // 0x06 = bits 1 and 2 set (supported and detected)
      final bytesWithContact = Uint8List.fromList([0x06, 135]);
      final m1 = BleHeartRateParser.parse(bytesWithContact);
      expect(m1!.contactSupported, isTrue);
      expect(m1.contactDetected, isTrue);

      // 0x04 = bit 2 set but not bit 1 (contact supported but not detected)
      final bytesNoContact = Uint8List.fromList([0x04, 135]);
      final m2 = BleHeartRateParser.parse(bytesNoContact);
      expect(m2!.contactSupported, isTrue);
      expect(m2.contactDetected, isFalse);
    });

    test('parses energy expended field', () {
      // Flags 0x08 = energy expended present (2 bytes uint16: 450 kJ = 0x01C2)
      final bytes = Uint8List.fromList([0x08, 140, 0xC2, 0x01]);
      final measurement = BleHeartRateParser.parse(bytes);

      expect(measurement, isNotNull);
      expect(measurement!.heartRateBpm, 140);
      expect(measurement.energyExpendedKj, 450);
    });

    test('parses RR-intervals with resolution 1/1024s', () {
      // Flags 0x10 = RR-intervals present
      // 1024 ticks = 1.0 second = 1000.0 ms
      // (1024 = 0x0400 -> little endian [0x00, 0x04])
      final bytes = Uint8List.fromList([0x10, 60, 0x00, 0x04]);
      final measurement = BleHeartRateParser.parse(bytes);

      expect(measurement, isNotNull);
      expect(measurement!.heartRateBpm, 60);
      expect(measurement.rrIntervalsMs.length, 1);
      expect(measurement.rrIntervalsMs.first, 1000.0);
    });

    test('returns null on truncated or invalid byte arrays', () {
      expect(BleHeartRateParser.parse(Uint8List(0)), isNull);
      expect(BleHeartRateParser.parse(Uint8List.fromList([0x00])), isNull);
      // 16-bit flag set but only 1 data byte
      expect(
        BleHeartRateParser.parse(Uint8List.fromList([0x01, 0x50])),
        isNull,
      );
    });
  });
}
