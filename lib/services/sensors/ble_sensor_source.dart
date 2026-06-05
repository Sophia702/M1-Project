import 'dart:async';

import '../../core/sensor_schema.dart';
import '../../data/models/imu_sample.dart';
import '../../data/models/sensor_status.dart';
import 'sensor_source.dart';

/// STUB — real Bluetooth source for the Arduino Nano 33 BLE sensors.
///
/// A teammate implements this in M4 using `flutter_blue_plus`:
///   1. scan + connect to each of the 4 boards (lowerBack, ankleL, ankleR, wrist),
///   2. subscribe to the IMU notify characteristic,
///   3. decode each packet into the canonical [kFeatureOrder] 24-feature vector
///      at ~60 Hz, and add it to [samples].
///
/// BLE does NOT work in the Android emulator — test on a real phone.
/// Until then, the app uses MockSensorSource (see providers).
class BleSensorSource implements SensorSource {
  final _samples = StreamController<ImuSample>.broadcast();
  final _status = StreamController<SensorStatusMap>.broadcast();

  @override
  Set<SensorLocation> get expectedLocations => SensorLocation.values.toSet();

  @override
  Stream<ImuSample> get samples => _samples.stream;

  @override
  Stream<SensorStatusMap> get status => _status.stream;

  @override
  SensorStatusMap get statusNow => SensorStatusMap.allNotConnected();

  @override
  Future<void> connect(SensorLocation location) =>
      throw UnimplementedError('BleSensorSource.connect — implement in M4');

  @override
  Future<void> connectAll() =>
      throw UnimplementedError('BleSensorSource.connectAll — implement in M4');

  @override
  Future<void> start() =>
      throw UnimplementedError('BleSensorSource.start — implement in M4');

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {
    await _samples.close();
    await _status.close();
  }
}
