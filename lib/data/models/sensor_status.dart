import '../../core/sensor_schema.dart';

/// Per-location BLE connection state, shown on the "Connect sensors" body view.
/// Color is paired with an icon + label in the UI — never color alone.
enum SensorConnState { notConnected, pairing, connected }

/// Snapshot of every expected location's connection state.
class SensorStatusMap {
  final Map<SensorLocation, SensorConnState> states;
  const SensorStatusMap(this.states);

  SensorConnState of(SensorLocation l) =>
      states[l] ?? SensorConnState.notConnected;

  bool get allConnected =>
      SensorLocation.values.every((l) => of(l) == SensorConnState.connected);

  bool get anyConnected =>
      states.values.any((s) => s == SensorConnState.connected);

  int get connectedCount =>
      states.values.where((s) => s == SensorConnState.connected).length;

  SensorStatusMap copyWith(SensorLocation l, SensorConnState s) {
    final next = Map<SensorLocation, SensorConnState>.from(states);
    next[l] = s;
    return SensorStatusMap(next);
  }

  static SensorStatusMap allNotConnected() => SensorStatusMap({
        for (final l in SensorLocation.values) l: SensorConnState.notConnected,
      });

  static SensorStatusMap allConnectedMap() => SensorStatusMap({
        for (final l in SensorLocation.values) l: SensorConnState.connected,
      });
}
