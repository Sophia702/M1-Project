import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/cue/cue_engine.dart';
import '../services/cue/metronome_cue_engine.dart';
import '../services/intervention/default_intervention_manager.dart';
import '../services/intervention/intervention_manager.dart';
import '../services/model/fog_model.dart';
import '../services/model/mock_fog_model.dart';
import '../services/sensors/mock_sensor_source.dart';
import '../services/sensors/sensor_source.dart';
import '../services/session/session_controller.dart';
import '../services/session/session_state.dart';
import '../services/voice/mock_voice_assistant.dart';

/// Dependency wiring. To go from mock -> real (M4), change ONLY the concrete
/// type constructed here — nothing in the UI or session logic changes:
///   sensorSourceProvider : MockSensorSource -> BleSensorSource
///   fogModelProvider     : MockFogModel     -> TfliteFogModel
///   cueEngineProvider    : MetronomeCueEngine (+ audio_service for background)

final sensorSourceProvider = Provider<SensorSource>((ref) {
  final s = MockSensorSource();
  ref.onDispose(() => s.dispose());
  return s;
});

final fogModelProvider = Provider<FogModel>((ref) {
  final m = MockFogModel();
  ref.onDispose(() => m.dispose());
  return m;
});

final cueEngineProvider = Provider<CueEngine>((ref) {
  final c = MetronomeCueEngine();
  ref.onDispose(() => c.dispose());
  return c;
});

final interventionManagerProvider = Provider<InterventionManager>((ref) {
  final i = DefaultInterventionManager();
  ref.onDispose(() => i.dispose());
  return i;
});

/// Concrete type exposed so the debug "simulate voice" hook (emit) is reachable.
final voiceAssistantProvider = Provider<MockVoiceAssistant>((ref) {
  final v = MockVoiceAssistant();
  ref.onDispose(() => v.dispose());
  return v;
});

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionSnapshot>(SessionController.new);
