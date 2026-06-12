import 'dart:typed_data';

import '../../data/models/fog_prediction.dart';

/// Seam #2 — the freezing-of-gait predictor.
///
/// Takes one sliding window and returns a [FogPrediction]. Implementations:
///   - MockFogModel   : scripted/random states so the UI reacts now.
///   - TfliteFogModel : loads a .tflite via tflite_flutter (M4).
///
/// Input contract (see sensor_schema.dart): a Float32List of
/// windowSize * featureCount values, row-major, canonical column order.
abstract class FogModel {
  /// Expected window length in timesteps (120).
  int get windowSize;

  /// Expected features per timestep (24).
  int get featureCount;

  /// Load weights / warm up. Call once before [predict].
  Future<void> load();

  /// Run inference over one flattened window. Synchronous so the session loop
  /// can call it on each step; heavy backends may cache an isolate internally.
  FogPrediction predict(Float32List window);

  /// Release native resources.
  Future<void> dispose();
}
