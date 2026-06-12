import 'dart:async';
import 'dart:collection';

import 'voice_assistant.dart';

/// Dev/demo voice agent — no microphone or TTS engine. [speak] logs, and
/// [listenOnce] returns phrases queued via [inject] (e.g. from a debug
/// "say…" button), so the voice loop can be exercised on an emulator.
class MockVoiceAssistant implements VoiceAssistant {
  final Queue<String> _queued = Queue<String>();
  final List<String> spoken = [];

  @override
  bool get isAvailable => true;

  @override
  Future<bool> init() async => true;

  @override
  Future<void> speak(String text) async {
    spoken.add(text);
    // ignore: avoid_print
    print('[aria voice] $text');
  }

  @override
  Future<String?> listenOnce({Duration listenFor = const Duration(seconds: 6)}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _queued.isEmpty ? null : _queued.removeFirst();
  }

  @override
  Future<void> stopListening() async {}

  /// Test/demo hook: queue a phrase the next [listenOnce] will "hear".
  void inject(String phrase) => _queued.add(phrase);

  @override
  Future<void> dispose() async {}
}
