import 'dart:typed_data';

import '../../core/sensor_schema.dart';

/// Fixed-size circular buffer of the most recent IMU rows, able to emit the
/// current sliding window as one flattened (windowSize * featureCount) vector
/// in chronological order (oldest -> newest), row-major — exactly the shape
/// [FogModel.predict] expects.
class WindowBuffer {
  WindowBuffer({this.windowSize = kWindowSize, this.featureCount = kFeatureCount})
      : _buf = Float32List(windowSize * featureCount);

  final int windowSize;
  final int featureCount;
  final Float32List _buf;
  int _count = 0; // total rows ever added
  int _head = 0; // next write row (also oldest row once full)

  bool get isFull => _count >= windowSize;
  int get length => _count < windowSize ? _count : windowSize;

  /// Append one timestep (length must equal [featureCount]).
  void add(Float32List features) {
    assert(features.length == featureCount);
    final base = _head * featureCount;
    _buf.setRange(base, base + featureCount, features);
    _head = (_head + 1) % windowSize;
    _count++;
  }

  /// Snapshot the window oldest->newest. Only meaningful once [isFull].
  Float32List snapshot() {
    final out = Float32List(windowSize * featureCount);
    final start = isFull ? _head : 0; // oldest row index
    for (var r = 0; r < windowSize; r++) {
      final srcRow = (start + r) % windowSize;
      out.setRange(
        r * featureCount,
        r * featureCount + featureCount,
        _buf,
        srcRow * featureCount,
      );
    }
    return out;
  }

  void clear() {
    _count = 0;
    _head = 0;
  }
}
