import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'voice_assistant.dart';

/// Real voice agent: on-device speech-to-text (Android SpeechRecognizer via
/// speech_to_text) + text-to-speech (flutter_tts). Needs a physical device with
/// a microphone and the RECORD_AUDIO permission; STT is unreliable on emulators.
class KeywordVoiceAssistant implements VoiceAssistant {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _available = false;

  @override
  bool get isAvailable => _available;

  @override
  Future<bool> init() async {
    _available = await _stt.initialize(
      onError: (e) {/* swallow; loop will retry */},
      onStatus: (_) {},
    );
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45); // calm, clear pace for older adults
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    return _available;
  }

  @override
  Future<void> speak(String text) async {
    // With awaitSpeakCompletion(true), speak() resolves when talking finishes.
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  Future<String?> listenOnce({
    Duration listenFor = const Duration(seconds: 6),
  }) async {
    if (!_available) return null;
    final completer = Completer<String?>();

    await _stt.listen(
      onResult: (result) {
        if (result.finalResult && !completer.isCompleted) {
          completer.complete(result.recognizedWords);
        }
      },
      listenOptions: SpeechListenOptions(
        partialResults: false,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
        listenFor: listenFor,
        pauseFor: const Duration(seconds: 3),
      ),
    );

    // Safety net: if no final result arrives, return whatever we have (or null).
    Timer(listenFor + const Duration(milliseconds: 600), () async {
      if (!completer.isCompleted) {
        await _stt.stop();
        final words = _stt.lastRecognizedWords;
        completer.complete(words.isEmpty ? null : words);
      }
    });

    return completer.future;
  }

  @override
  Future<void> stopListening() async {
    if (_stt.isListening) await _stt.stop();
  }

  @override
  Future<void> dispose() async {
    await _stt.cancel();
    await _tts.stop();
  }
}
