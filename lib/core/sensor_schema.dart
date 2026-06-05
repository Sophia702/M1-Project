import 'package:flutter/foundation.dart';

/// The sensor / feature contract.
///
/// This MIRRORS the training pipeline in `prepare_data.py` exactly so the
/// Flutter inference path matches the model's expected input. Any change here
/// must be made in lockstep with the Python side.
///
///  - 4 sensor locations: ankleL, ankleR, lowerBack, wrist
///  - each location: accel (x,y,z) + gyro (x,y,z) = 6 channels
///  - 4 x 6 = 24 features per timestep
///  - sample rate 60 Hz
///  - sliding window 120 samples (2 s), step 60 samples (1 s)
///  - model output: a single FoG probability (binary task in training)
///
/// The trained model normalises per-subject with StandardScaler; the real
/// [FogModel] implementation must apply equivalent normalisation at inference
/// (see README — teammate plug-in notes).

enum SensorLocation { ankleLeft, ankleRight, lowerBack, wrist }

extension SensorLocationLabel on SensorLocation {
  String get label => switch (this) {
        SensorLocation.ankleLeft => 'Left ankle',
        SensorLocation.ankleRight => 'Right ankle',
        SensorLocation.lowerBack => 'Lower back',
        SensorLocation.wrist => 'Wrist',
      };
}

const int kSampleRateHz = 60;
const int kWindowSize = 120; // 2 s at 60 Hz
const int kStepSize = 60; // 1 s — run inference once per second
const int kFeatureCount = 24; // 4 locations x (accel xyz + gyro xyz)

/// Canonical feature column order — IDENTICAL to SENSOR_COLS in prepare_data.py:
///   ankleL acc xyz, ankleL gyro xyz,
///   ankleR acc xyz, ankleR gyro xyz,
///   back   acc xyz, back   gyro xyz,
///   wrist  acc xyz, wrist  gyro xyz
/// A window passed to [FogModel.predict] is this 24-wide vector x 120 rows,
/// flattened row-major.
const List<String> kFeatureOrder = <String>[
  'ankleL_acc_x', 'ankleL_acc_y', 'ankleL_acc_z',
  'ankleL_gyro_x', 'ankleL_gyro_y', 'ankleL_gyro_z',
  'ankleR_acc_x', 'ankleR_acc_y', 'ankleR_acc_z',
  'ankleR_gyro_x', 'ankleR_gyro_y', 'ankleR_gyro_z',
  'back_acc_x', 'back_acc_y', 'back_acc_z',
  'back_gyro_x', 'back_gyro_y', 'back_gyro_z',
  'wrist_acc_x', 'wrist_acc_y', 'wrist_acc_z',
  'wrist_gyro_x', 'wrist_gyro_y', 'wrist_gyro_z',
];

/// Compile-time sanity check that the column list matches the feature count.
@visibleForTesting
bool get sensorSchemaIsConsistent => kFeatureOrder.length == kFeatureCount;
