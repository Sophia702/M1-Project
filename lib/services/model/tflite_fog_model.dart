import 'dart:typed_data';

import '../../core/sensor_schema.dart';
import '../../data/models/fog_prediction.dart';
import 'fog_model.dart';

/// STUB — real on-device inference for the trained FoG model.
///
/// A teammate implements this in M4 using `tflite_flutter`:
///   1. Drop the exported model at assets/models/fog_model.tflite (declare it
///      in pubspec assets).
///   2. load(): create an Interpreter from the asset.
///   3. predict(window): reshape to [1, 120, 24], run, read the FoG probability.
///
/// IMPORTANT — normalisation: prepare_data.py scales features PER SUBJECT with
/// StandardScaler. Inference must apply equivalent normalisation, either baked
/// into the graph or by loading exported mean/std and normalising `window`
/// here before running. Then map probability -> FogState via [FogThresholds]
/// and tune the bands for a real 1–2 s pre-freeze lead.
class TfliteFogModel implements FogModel {
  TfliteFogModel({this.thresholds = const FogThresholds()});

  final FogThresholds thresholds;

  @override
  int get windowSize => kWindowSize;

  @override
  int get featureCount => kFeatureCount;

  @override
  Future<void> load() =>
      throw UnimplementedError('TfliteFogModel.load — implement in M4');

  @override
  FogPrediction predict(Float32List window) =>
      throw UnimplementedError('TfliteFogModel.predict — implement in M4');

  @override
  Future<void> dispose() async {}
}
