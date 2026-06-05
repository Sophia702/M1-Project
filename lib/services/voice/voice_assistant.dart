/// Intents the voice agent can recognise (keyword matching for MVP; richer NLU
/// later). Kept small and explicit so the mapping to actions is obvious.
enum VoiceIntent {
  startWalk,
  endWalk,
  imOkay,
  breathing,
  callEmergency,
  callSupport,
  goHome,
  goProgress,
  unknown,
}

/// Describes the current screen so the agent can narrate it and offer actions.
class ScreenDescriptor {
  final String screenId;
  final String spokenSummary;
  final List<VoiceIntent> availableIntents;
  const ScreenDescriptor({
    required this.screenId,
    required this.spokenSummary,
    this.availableIntents = const [],
  });
}

/// Seam #5 — the hands-free "aria agent".
///
/// Operates the whole app by voice: speech-to-text -> intent -> action, with
/// text-to-speech narration. A FIRST-CLASS but SEPARABLE layer — the core walk
/// pipeline never depends on it.
///
/// Implementations:
///   - MockVoiceAssistant   : dev/demo — inject intents programmatically.
///   - KeywordVoiceAssistant : speech_to_text + flutter_tts (M3).
abstract class VoiceAssistant {
  bool get enabled;
  set enabled(bool value);

  Future<void> init();

  /// Speak text to the user (TTS).
  Future<void> speak(String text);

  /// Start listening for a command (STT).
  Future<void> listen();

  /// Stream of recognised intents.
  Stream<VoiceIntent> get intents;

  /// Tell the agent which screen is showing so it can narrate + offer actions.
  void describeScreen(ScreenDescriptor descriptor);

  Future<void> dispose();
}
