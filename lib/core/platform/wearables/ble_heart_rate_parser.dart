import 'dart:typed_data';

/// Decoded representation of a Bluetooth SIG GATT Heart Rate Measurement
/// packet (Service UUID 0x180D, Characteristic UUID 0x2A37).
class BleHeartRateMeasurement {
  const BleHeartRateMeasurement({
    required this.heartRateBpm,
    required this.contactSupported,
    required this.contactDetected,
    this.energyExpendedKj,
    this.rrIntervalsMs = const [],
  });

  /// Instantaneous heart rate in beats per minute (BPM).
  final int heartRateBpm;

  /// Whether the heart rate sensor supports skin contact detection.
  final bool contactSupported;

  /// Whether good skin contact is currently detected.
  final bool contactDetected;

  /// Accumulated energy expended in kilo Joules, if reported by sensor.
  final int? energyExpendedKj;

  /// RR-intervals in milliseconds (resolution 1/1024s mapped to ms).
  final List<double> rrIntervalsMs;
}

/// Pure-Dart decoder for standard Bluetooth SIG Heart Rate Measurement packets.
///
/// Implements Bluetooth GATT Specification for Characteristic 0x2A37:
/// https://www.bluetooth.com/specifications/specs/heart-rate-service-1-0/
class BleHeartRateParser {
  const BleHeartRateParser();

  /// Parses raw byte payload received from a BLE Heart Rate characteristic.
  /// Returns [BleHeartRateMeasurement], or null if payload is invalid/empty.
  static BleHeartRateMeasurement? parse(Uint8List bytes) {
    if (bytes.length < 2) return null;

    final flags = bytes[0];
    var offset = 1;

    // Bit 0: Heart Rate format (0 = uint8, 1 = uint16)
    final is16Bit = (flags & 0x01) != 0;
    int heartRate;
    if (is16Bit) {
      if (bytes.length < offset + 2) return null;
      heartRate = bytes[offset] | (bytes[offset + 1] << 8);
      offset += 2;
    } else {
      heartRate = bytes[offset];
      offset += 1;
    }

    // Bits 1 & 2: Sensor Contact Status
    // Bit 1: Contact support (1 = supported)
    // Bit 2: Contact status (1 = detected)
    final contactSupported = (flags & 0x04) != 0 || (flags & 0x02) != 0;
    final contactDetected = (flags & 0x06) == 0x06;

    // Bit 3: Energy Expended field presence
    final hasEnergyExpended = (flags & 0x08) != 0;
    int? energyExpended;
    if (hasEnergyExpended && bytes.length >= offset + 2) {
      energyExpended = bytes[offset] | (bytes[offset + 1] << 8);
      offset += 2;
    }

    // Bit 4: RR-Interval values presence
    final hasRrIntervals = (flags & 0x10) != 0;
    final rrIntervals = <double>[];
    if (hasRrIntervals) {
      while (offset + 1 < bytes.length) {
        final rawRr = bytes[offset] | (bytes[offset + 1] << 8);
        // Standard resolution is 1/1024 second. Convert to milliseconds:
        final ms = (rawRr * 1000.0) / 1024.0;
        rrIntervals.add(double.parse(ms.toStringAsFixed(1)));
        offset += 2;
      }
    }

    return BleHeartRateMeasurement(
      heartRateBpm: heartRate,
      contactSupported: contactSupported,
      contactDetected: contactDetected,
      energyExpendedKj: energyExpended,
      rrIntervalsMs: rrIntervals,
    );
  }
}
