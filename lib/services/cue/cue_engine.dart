/// Seam #3 — the rhythmic audio cue.
///
/// Plays a CONTINUOUS rhythmic cue at a target tempo for the WHOLE session
/// (tempo = baseline cadence measured during calibration). It does NOT only
/// fire on a freeze — keeping the person in rhythm is the core therapy.
///
/// MVP implementation: [MetronomeCueEngine] (a looped click). The [playTrack]
/// extension point is where tempo-matched music (e.g. Spotify) plugs in later.
abstract class CueEngine {
  Future<void> init();

  /// Start the continuous cue at [bpm] beats (steps) per minute.
  Future<void> startCue({required double bpm});

  /// Change tempo while playing (keeps the cue going).
  Future<void> setTempo(double bpm);

  /// 0..1 volume.
  Future<void> setVolume(double volume01);

  /// Stop the cue.
  Future<void> stopCue();

  bool get isPlaying;
  double get bpm;

  Future<void> dispose();

  // Extension point for M4+: play a tempo-matched music track instead of the
  // metronome. The continuous-cue contract above already fits this.
  // Future<void> playTrack(TempoMatchedTrack track);
}
