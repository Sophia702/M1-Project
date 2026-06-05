import 'dart:async';

import 'voice_assistant.dart';

/// Dev/demo voice agent.
///
/// Doesn't touch the microphone or TTS engine (those arrive in M3 with
/// `speech_to_text` + `flutter_tts`). Instead it lets the app inject intents
/// programmatically via [emit] — e.g. from a debug "🎤 say 'start walk'" button —
/// so voice-driven navigation can be wired and demoed now. [speak] logs.
class MockVoiceAssistant implements VoiceAssistant {
  final _intents = StreamController<VoiceIntent>.broadcast();
  bool _enabled = false;
  ScreenDescriptor? _current;

  @override
  bool get enabled => _enabled;

  @override
  set enabled(bool value) => _enabled = value;

  @override
  Stream<VoiceIntent> get intents => _intents.stream;

  @override
  Future<void> init() async {}

  @override
  Future<void> speak(String text) async {
    // ignore: avoid_print
    print('[aria voice] $text');
  }

  @override
  Future<void> listen() async {
    // No-op for the mock; real STT begins capture here.
  }

  @override
  void describeScreen(ScreenDescriptor descriptor) {
    _current = descriptor;
    if (_enabled) speak(descriptor.spokenSummary);
  }

  /// Test/demo hook: simulate the user saying something that maps to [intent].
  void emit(VoiceIntent intent) => _intents.add(intent);

  /// The screen the agent currently believes is showing.
  ScreenDescriptor? get currentScreen => _current;

  @override
  Future<void> dispose() async {
    await _intents.close();
  }
}
