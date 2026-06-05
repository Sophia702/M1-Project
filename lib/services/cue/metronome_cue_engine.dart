import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import 'cue_engine.dart';

/// MVP cue: a continuous metronome.
///
/// Instead of bundling an audio asset, we SYNTHESISE one beat as a 16-bit PCM
/// WAV at the exact target tempo and loop it gaplessly (LoopMode.one). Changing
/// tempo regenerates the one-beat buffer, so timing stays sample-accurate and
/// there's no binary asset to ship.
///
/// Background playback (screen off) will be added in M2 via `audio_service`
/// (Android foreground service); for the M1 emulator demo, foreground playback
/// through just_audio is enough.
class MetronomeCueEngine implements CueEngine {
  MetronomeCueEngine();

  final AudioPlayer _player = AudioPlayer();
  static const int _sampleRate = 22050; // small files, plenty for a click
  double _bpm = 100;
  double _volume = 0.9;
  bool _playing = false;
  int _fileSeq = 0;

  @override
  bool get isPlaying => _playing;

  @override
  double get bpm => _bpm;

  @override
  Future<void> init() async {
    await _player.setLoopMode(LoopMode.one);
    await _player.setVolume(_volume);
  }

  @override
  Future<void> startCue({required double bpm}) async {
    _bpm = bpm.clamp(30, 240);
    await _loadBeat();
    await _player.setVolume(_volume);
    // Do NOT await: with LoopMode.one the player loops forever, so play()'s
    // future only completes when the cue is stopped. Awaiting it would block
    // the caller (e.g. startSession) indefinitely.
    unawaited(_player.play());
    _playing = true;
  }

  @override
  Future<void> setTempo(double bpm) async {
    _bpm = bpm.clamp(30, 240);
    if (_playing) {
      final wasPlaying = _player.playing;
      await _loadBeat();
      if (wasPlaying) unawaited(_player.play());
    }
  }

  @override
  Future<void> setVolume(double volume01) async {
    _volume = volume01.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
  }

  @override
  Future<void> stopCue() async {
    _playing = false;
    await _player.stop();
  }

  @override
  Future<void> dispose() async {
    _playing = false;
    await _player.dispose();
  }

  /// Write a fresh one-beat WAV for the current bpm and load it looped.
  Future<void> _loadBeat() async {
    final bytes = _encodeBeatWav(_bpm, _sampleRate);
    final dir = await getTemporaryDirectory();
    // New filename each time so just_audio reloads rather than caching.
    final file = File('${dir.path}/aria_click_${_fileSeq++}.wav');
    await file.writeAsBytes(bytes, flush: true);
    await _player.setFilePath(file.path);
    await _player.setLoopMode(LoopMode.one);
  }

  /// One beat = a short percussive click followed by silence to fill the
  /// inter-beat interval (60/bpm seconds).
  static Uint8List _encodeBeatWav(double bpm, int sampleRate) {
    final beatSamples = (sampleRate * 60.0 / bpm).round();
    final pcm = Int16List(beatSamples); // zero-filled = silence

    const clickMs = 35;
    const freq = 1400.0; // crisp, easy to hear over footsteps
    final clickSamples = (sampleRate * clickMs / 1000).round();
    for (var i = 0; i < clickSamples && i < beatSamples; i++) {
      final t = i / sampleRate;
      final env = exp(-t * 45); // fast exponential decay
      final s = sin(2 * pi * freq * t) * env;
      pcm[i] = (s * 28000).round().clamp(-32768, 32767);
    }
    return _wrapWav(pcm, sampleRate);
  }

  /// Wrap mono 16-bit PCM samples in a 44-byte WAV header (little-endian,
  /// matching ARM/x86 host byte order).
  static Uint8List _wrapWav(Int16List samples, int sampleRate) {
    final data =
        samples.buffer.asUint8List(samples.offsetInBytes, samples.lengthInBytes);
    final out = BytesBuilder();
    void str(String s) => out.add(s.codeUnits);
    void u32(int v) =>
        out.add((ByteData(4)..setUint32(0, v, Endian.little)).buffer.asUint8List());
    void u16(int v) =>
        out.add((ByteData(2)..setUint16(0, v, Endian.little)).buffer.asUint8List());

    str('RIFF');
    u32(36 + data.length);
    str('WAVE');
    str('fmt ');
    u32(16); // PCM fmt chunk size
    u16(1); // audio format = PCM
    u16(1); // channels = mono
    u32(sampleRate);
    u32(sampleRate * 2); // byte rate = sampleRate * channels * bytesPerSample
    u16(2); // block align
    u16(16); // bits per sample
    str('data');
    u32(data.length);
    out.add(data);
    return out.toBytes();
  }
}
