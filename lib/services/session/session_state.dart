import '../../data/models/fog_prediction.dart';

/// High-level session phase that drives screen routing.
///
/// M1 actively uses: idle, walkingNormal, intervention, ended.
/// The others are defined for the full machine (M2+): calibrating during the
/// baseline walk, choosingCue on the beat-picker, paused, and the discrete
/// preFreeze/frozen phases if we later route them to their own screens.
enum SessionState {
  idle,
  calibrating,
  choosingCue,
  walkingNormal,
  preFreeze,
  intervention,
  frozen,
  paused,
  ended,
}

/// Immutable snapshot the UI renders from. The UI reacts to THIS, never to raw
/// sensor data.
class SessionSnapshot {
  final SessionState state;
  final FogState fogState; // colours the walking PulseRing
  final double fogProbability;
  final double stepsPerMin; // displayed cadence (= cue tempo in M1)
  final double bpm; // current cue tempo
  final Duration elapsed;
  final int freezesEased; // interventions resolved with "continue"
  final bool cuePlaying;

  const SessionSnapshot({
    this.state = SessionState.idle,
    this.fogState = FogState.normal,
    this.fogProbability = 0,
    this.stepsPerMin = 0,
    this.bpm = 0,
    this.elapsed = Duration.zero,
    this.freezesEased = 0,
    this.cuePlaying = false,
  });

  SessionSnapshot copyWith({
    SessionState? state,
    FogState? fogState,
    double? fogProbability,
    double? stepsPerMin,
    double? bpm,
    Duration? elapsed,
    int? freezesEased,
    bool? cuePlaying,
  }) {
    return SessionSnapshot(
      state: state ?? this.state,
      fogState: fogState ?? this.fogState,
      fogProbability: fogProbability ?? this.fogProbability,
      stepsPerMin: stepsPerMin ?? this.stepsPerMin,
      bpm: bpm ?? this.bpm,
      elapsed: elapsed ?? this.elapsed,
      freezesEased: freezesEased ?? this.freezesEased,
      cuePlaying: cuePlaying ?? this.cuePlaying,
    );
  }
}
