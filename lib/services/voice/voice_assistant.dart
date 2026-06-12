/// Seam #5 — the hands-free "aria agent".
///
/// Primitives the [VoiceController] orchestrates into a narrate → listen → act
/// loop. A FIRST-CLASS but SEPARABLE layer — the core walk pipeline never
/// depends on it.
///
/// Implementations:
///   - KeywordVoiceAssistant : speech_to_text + flutter_tts (real device).
///   - MockVoiceAssistant    : dev/demo — speak() logs, listenOnce() returns
///                              programmatically-injected phrases.
abstract class VoiceAssistant {
  /// Whether STT/TTS initialised successfully (mic permission granted, engine ok).
  bool get isAvailable;

  /// Initialise STT + TTS. Returns availability.
  Future<bool> init();

  /// Speak [text] and complete when finished talking.
  Future<void> speak(String text);

  /// Listen for a single utterance; returns the recognised text (or null on
  /// silence/timeout). [listenFor] caps how long to wait.
  Future<String?> listenOnce({Duration listenFor});

  /// Stop any in-progress listening immediately.
  Future<void> stopListening();

  Future<void> dispose();
}
