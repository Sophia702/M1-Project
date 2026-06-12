import 'dart:math';
import 'dart:typed_data';

import '../../core/sensor_schema.dart';
import '../../data/models/fog_prediction.dart';
import 'fog_model.dart';

/// Scripted FoG model for development + demos.
///
/// Ignores the window contents and instead walks a deterministic timeline so
/// the UI predictably cycles normal -> preFreeze -> freezing -> normal. Each
/// [predict] call is treated as one step (the session runs inference once per
/// [kStepSize] = 1 s), so the phases below are roughly in seconds.
class MockFogModel implements FogModel {
  MockFogModel({this.thresholds = const FogThresholds()});

  final FogThresholds thresholds;
  final _rng = Random(11);
  int _step = 0;

  // One demo cycle (in steps ≈ seconds): a long calm stretch, then a short
  // freeze episode, repeat. Kept calm so the demo isn't constantly interrupted.
  static const int _normalSteps = 18;
  static const int _preFreezeSteps = 2;
  static const int _freezingSteps = 3;
  static const int _cycle = _normalSteps + _preFreezeSteps + _freezingSteps;

  @override
  int get windowSize => kWindowSize;

  @override
  int get featureCount => kFeatureCount;

  @override
  Future<void> load() async {}

  @override
  FogPrediction predict(Float32List window) {
    assert(window.length == windowSize * featureCount,
        'window must be ${windowSize * featureCount} long');
    final phase = _step % _cycle;
    _step++;

    double p;
    if (phase < _normalSteps) {
      p = 0.10 + _rng.nextDouble() * 0.15; // ~0.10–0.25
    } else if (phase < _normalSteps + _preFreezeSteps) {
      p = 0.45 + _rng.nextDouble() * 0.15; // ~0.45–0.60
    } else {
      p = 0.78 + _rng.nextDouble() * 0.15; // ~0.78–0.93
    }

    return FogPrediction(
      fogProbability: p,
      state: thresholds.classify(p),
      confidence: 0.6 + _rng.nextDouble() * 0.35,
    );
  }

  @override
  Future<void> dispose() async {}
}
