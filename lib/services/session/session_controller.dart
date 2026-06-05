import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/sensor_schema.dart';
import '../../data/models/fog_prediction.dart';
import '../../data/models/imu_sample.dart';
import '../../providers/providers.dart';
import '../cue/cue_engine.dart';
import '../intervention/intervention_manager.dart';
import '../model/fog_model.dart';
import '../sensors/sensor_source.dart';
import 'ring_buffer.dart';
import 'session_state.dart';

/// Wires the whole pipeline and exposes a [SessionSnapshot] the UI reacts to:
///
///   SensorSource.samples -> WindowBuffer -> (every kStepSize) FogModel.predict
///     -> FogState -> session-state transitions -> CueEngine (continuous) +
///        InterventionManager.
///
/// The UI never touches raw samples; it only reads the snapshot and calls the
/// command methods below. (Riverpod 3 `Notifier` — dependencies are resolved in
/// [build] via `ref`.)
class SessionController extends Notifier<SessionSnapshot> {
  late final SensorSource sensors;
  late final FogModel model;
  late final CueEngine cue;
  late final InterventionManager intervention;

  final WindowBuffer _window = WindowBuffer();
  StreamSubscription? _sampleSub;
  StreamSubscription? _interventionSub;

  int _sinceStep = 0;
  int _lastTickMs = 0;

  @override
  SessionSnapshot build() {
    sensors = ref.watch(sensorSourceProvider);
    model = ref.watch(fogModelProvider);
    cue = ref.watch(cueEngineProvider);
    intervention = ref.watch(interventionManagerProvider);

    _interventionSub = intervention.requests.listen(_onInterventionRequest);
    ref.onDispose(() {
      _sampleSub?.cancel();
      _interventionSub?.cancel();
    });

    return const SessionSnapshot();
  }

  /// Begin a walking session. [bpm] is the baseline cadence from calibration
  /// (steps/min); for M1 it's passed in directly.
  Future<void> startSession({double bpm = 100}) async {
    _window.clear();
    _sinceStep = 0;
    _lastTickMs = 0;

    await model.load();

    // Make sure sensors are connected (mock connects instantly).
    if (!sensors.statusNow.allConnected) {
      await sensors.connectAll();
    }

    await cue.init();
    await cue.startCue(bpm: bpm);
    await sensors.start();
    _sampleSub = sensors.samples.listen(_onSample);

    state = state.copyWith(
      state: SessionState.walkingNormal,
      fogState: FogState.normal,
      fogProbability: 0,
      bpm: bpm,
      stepsPerMin: bpm,
      elapsed: Duration.zero,
      freezesEased: 0,
      cuePlaying: true,
    );
  }

  void _onSample(ImuSample sample) {
    _window.add(sample.features);
    _sinceStep++;

    final shouldPredict = _window.isFull && _sinceStep >= kStepSize;
    if (shouldPredict) {
      _sinceStep = 0;
      final prediction = model.predict(_window.snapshot());
      _applyPrediction(prediction, sample.tMillis);
    } else if (sample.tMillis - _lastTickMs >= 500) {
      // Keep the elapsed timer ticking even before the first prediction.
      _lastTickMs = sample.tMillis;
      state = state.copyWith(elapsed: Duration(milliseconds: sample.tMillis));
    }
  }

  void _applyPrediction(FogPrediction p, int tMillis) {
    _lastTickMs = tMillis;
    // Forward to the intervention manager (it decides whether to surface one).
    intervention.onFogState(p.state);

    // Don't overwrite the screen while an intervention is showing.
    final nextSessionState = state.state == SessionState.intervention
        ? SessionState.intervention
        : SessionState.walkingNormal;

    state = state.copyWith(
      state: nextSessionState,
      fogState: p.state,
      fogProbability: p.fogProbability,
      elapsed: Duration(milliseconds: tMillis),
    );
  }

  void _onInterventionRequest(InterventionRequest req) {
    // Surface the intervention flow. The cue KEEPS PLAYING — rhythmic auditory
    // cueing is itself a strategy to overcome a freeze.
    state = state.copyWith(state: SessionState.intervention);
  }

  /// Called by the intervention UI with the user's choice.
  Future<InterventionResult> resolveIntervention(InterventionAction action) async {
    final result = await intervention.resolve(action);
    final eased =
        result.resumeWalking ? state.freezesEased + 1 : state.freezesEased;
    state = state.copyWith(
      state: SessionState.walkingNormal,
      fogState: FogState.normal,
      fogProbability: 0,
      freezesEased: eased,
    );
    return result;
  }

  /// End the walk; snapshot stats remain for the summary screen.
  Future<void> endSession() async {
    await _sampleSub?.cancel();
    _sampleSub = null;
    await sensors.stop();
    await cue.stopCue();
    state = state.copyWith(state: SessionState.ended, cuePlaying: false);
  }

  /// Reset back to idle (e.g. after the summary screen).
  void reset() => state = const SessionSnapshot();
}
