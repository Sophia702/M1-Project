import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import '../../core/sensor_schema.dart';
import '../../data/models/imu_sample.dart';
import '../../data/models/sensor_status.dart';
import 'sensor_source.dart';

/// Dev driver + "demo mode": emits synthetic 60 Hz / 24-feature samples so the
/// whole pipeline runs on the emulator with no hardware.
///
/// Later this can replay a bundled FoGSTAR-format CSV (drop it in
/// assets/data/fog_sample.csv and parse with the `csv` package) — the synthetic
/// generator below is enough for M1.
class MockSensorSource implements SensorSource {
  MockSensorSource({this.cadenceHz = 1.8}); // ~1.8 steps/s ≈ 108 spm

  /// Walking frequency used to shape the synthetic signal.
  final double cadenceHz;

  final _samples = StreamController<ImuSample>.broadcast();
  final _status = StreamController<SensorStatusMap>.broadcast();
  SensorStatusMap _statusMap = SensorStatusMap.allNotConnected();

  Timer? _timer;
  int _t = 0; // sample index
  final _rng = Random(7);

  @override
  Set<SensorLocation> get expectedLocations => SensorLocation.values.toSet();

  @override
  Stream<ImuSample> get samples => _samples.stream;

  @override
  Stream<SensorStatusMap> get status => _status.stream;

  @override
  SensorStatusMap get statusNow => _statusMap;

  void _emitStatus() => _status.add(_statusMap);

  @override
  Future<void> connect(SensorLocation location) async {
    _statusMap = _statusMap.copyWith(location, SensorConnState.pairing);
    _emitStatus();
    await Future<void>.delayed(const Duration(milliseconds: 350));
    _statusMap = _statusMap.copyWith(location, SensorConnState.connected);
    _emitStatus();
  }

  @override
  Future<void> connectAll() async {
    for (final l in SensorLocation.values) {
      await connect(l);
    }
  }

  @override
  Future<void> start() async {
    _timer?.cancel();
    const periodMs = 1000 ~/ kSampleRateHz; // ~16ms @ 60 Hz
    _timer = Timer.periodic(const Duration(milliseconds: periodMs), (_) {
      _samples.add(_synthSample());
    });
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _samples.close();
    await _status.close();
  }

  /// Build one 24-feature sample: per-axis sinusoids at the walking cadence
  /// plus a little noise. Values are illustrative, not physically calibrated —
  /// the MockFogModel ignores content; this just makes the buffers non-trivial.
  ImuSample _synthSample() {
    final tSec = _t / kSampleRateHz;
    final phase = 2 * pi * cadenceHz * tSec;
    final f = Float32List(kFeatureCount);
    for (var i = 0; i < kFeatureCount; i++) {
      final isGyro = (i % 6) >= 3; // each block: acc(0-2), gyro(3-5)
      final amp = isGyro ? 30.0 : 1.0; // gyro deg/s vs accel g-ish
      final axisOffset = (i % 3) * 1.1;
      final noise = (_rng.nextDouble() - 0.5) * (isGyro ? 4 : 0.08);
      f[i] = amp * sin(phase + axisOffset) + noise;
    }
    final sample = ImuSample(tMillis: (tSec * 1000).round(), features: f);
    _t++;
    return sample;
  }
}
