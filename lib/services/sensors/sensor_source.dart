import '../../core/sensor_schema.dart';
import '../../data/models/imu_sample.dart';
import '../../data/models/sensor_status.dart';

/// Seam #1 — a stream of timestamped 24-feature IMU samples at ~60 Hz.
///
/// Implementations:
///   - MockSensorSource  : synthetic / replayed data — dev driver + demo mode.
///   - BleSensorSource   : real Arduino Nano 33 BLE via flutter_blue_plus (M4).
///
/// The UI and [SessionController] depend ONLY on this interface, so swapping
/// mock -> real is a single provider change.
abstract class SensorSource {
  /// Locations this source expects to manage (all 4 per [SensorLocation]).
  Set<SensorLocation> get expectedLocations;

  /// Per-location connection state (drives the Connect-sensors body view).
  Stream<SensorStatusMap> get status;

  /// Current connection snapshot (synchronous read for UI build).
  SensorStatusMap get statusNow;

  /// Merged IMU stream — one [ImuSample] per timestep, canonical feature order.
  Stream<ImuSample> get samples;

  /// Begin connecting a single location (BLE pairing; mock = near-instant).
  Future<void> connect(SensorLocation location);

  /// Connect every expected location.
  Future<void> connectAll();

  /// Start streaming samples (call once sensors are connected).
  Future<void> start();

  /// Stop streaming; releases resources.
  Future<void> stop();

  /// Release everything (close streams).
  Future<void> dispose();
}
