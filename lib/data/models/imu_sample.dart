import 'dart:typed_data';

import '../../core/sensor_schema.dart';

/// One timestep of IMU data across ALL sensor locations.
///
/// [features] is a length-[kFeatureCount] (24) vector in the canonical
/// [kFeatureOrder] column order. Whatever produces samples (mock or BLE) is
/// responsible for placing values in that order so the model sees what it saw
/// in training.
class ImuSample {
  /// Milliseconds since session start (monotonic), not wall-clock.
  final int tMillis;

  /// 24 features, canonical order. Length must equal [kFeatureCount].
  final Float32List features;

  ImuSample({required this.tMillis, required this.features})
      : assert(features.length == kFeatureCount,
            'ImuSample needs $kFeatureCount features, got ${features.length}');
}
