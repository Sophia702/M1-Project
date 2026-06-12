import 'package:flutter/foundation.dart';

/// The sensor / feature contract.
///
/// The aria device uses **3** IMU sensors — lower back + both ankles — each
/// streaming accel (x,y,z) + gyro (x,y,z) = 6 channels, for 3 x 6 = 18 features
/// per timestep at 60 Hz. Sliding window 120 samples (2 s), step 60 (1 s). The
/// model output is a single FoG probability (binary task).
///
/// ⚠️ ML TEAM — CONTRACT MISMATCH TO RESOLVE:
/// `prepare_data.py` currently lists a 4th sensor (a `wrist`) in SENSOR_COLS,
/// i.e. 24 features. The physical device is 3 sensors (18 features). To match,
/// drop the six `wrist_*` columns from SENSOR_COLS and retrain so the model
/// input is (120, 18) in the [kFeatureOrder] below. If the wrist is in fact
/// kept, revert this file to 4 locations / 24 features instead.
///
/// The trained model normalises per-subject with StandardScaler; the real
/// [FogModel] must apply equivalent normalisation at inference (see README).

enum SensorLocation { lowerBack, ankleLeft, ankleRight }

extension SensorLocationLabel on SensorLocation {
  String get label => switch (this) {
        SensorLocation.lowerBack => 'Lower back',
        SensorLocation.ankleLeft => 'Left ankle',
        SensorLocation.ankleRight => 'Right ankle',
      };
}

const int kSampleRateHz = 60;
const int kWindowSize = 120; // 2 s at 60 Hz
const int kStepSize = 60; // 1 s — run inference once per second
const int kFeatureCount = 18; // 3 locations x (accel xyz + gyro xyz)

/// Canonical feature column order. Must match SENSOR_COLS in prepare_data.py
/// (with the wrist columns removed — see the ML-team note above):
///   back   acc xyz, back   gyro xyz,
///   ankleL acc xyz, ankleL gyro xyz,
///   ankleR acc xyz, ankleR gyro xyz
/// A window passed to [FogModel.predict] is this 18-wide vector x 120 rows,
/// flattened row-major.
const List<String> kFeatureOrder = <String>[
  'back_acc_x', 'back_acc_y', 'back_acc_z',
  'back_gyro_x', 'back_gyro_y', 'back_gyro_z',
  'ankleL_acc_x', 'ankleL_acc_y', 'ankleL_acc_z',
  'ankleL_gyro_x', 'ankleL_gyro_y', 'ankleL_gyro_z',
  'ankleR_acc_x', 'ankleR_acc_y', 'ankleR_acc_z',
  'ankleR_gyro_x', 'ankleR_gyro_y', 'ankleR_gyro_z',
];

/// Compile-time sanity check that the column list matches the feature count.
@visibleForTesting
bool get sensorSchemaIsConsistent => kFeatureOrder.length == kFeatureCount;
