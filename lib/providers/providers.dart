import 'package:flutter/widgets.dart';
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
import '../services/voice/keyword_voice_assistant.dart';
import '../services/voice/mock_voice_assistant.dart';
import '../services/voice/voice_assistant.dart';

/// Global navigator key so the voice agent can drive navigation from outside the
/// widget tree. Wired to MaterialApp.navigatorKey.
final navigatorKey = GlobalKey<NavigatorState>();

/// App locale — driven by the Settings Language toggle.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en');
  void set(Locale locale) => state = locale;
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

/// Set true to use the mic-free MockVoiceAssistant (e.g. on an emulator).
const bool kUseMockVoice = false;

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

final voiceAssistantProvider = Provider<VoiceAssistant>((ref) {
  final VoiceAssistant v =
      kUseMockVoice ? MockVoiceAssistant() : KeywordVoiceAssistant();
  ref.onDispose(() => v.dispose());
  return v;
});

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionSnapshot>(SessionController.new);

/// Active bottom-nav tab index (Home/Progress/Profile/Settings). Lifted out of
/// MainShell so the voice agent can switch tabs.
class NavIndexController extends Notifier<int> {
  @override
  int build() => 0;
  void set(int i) => state = i;
}

final navIndexProvider = NotifierProvider<NavIndexController, int>(
  NavIndexController.new,
);
