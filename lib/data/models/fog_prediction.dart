/// Discrete gait state surfaced to the UI and session machine.
///
/// The trained model is a *binary* FoG classifier (freeze / no-freeze). We map
/// its probability into three states so the app can act with lead time:
///   - [normal]    walking fine — cue keeps playing
///   - [preFreeze] rising freeze probability — show intervention readiness
///   - [freezing]  freeze predicted/occurring — surface the intervention
/// The probability->state thresholds live in [FogThresholds].
enum FogState { normal, preFreeze, freezing }

/// Output of a single inference over one [kWindowSize] window.
class FogPrediction {
  final double fogProbability; // 0..1
  final FogState state;
  final double confidence; // 0..1 — how sure (mock supplies a value)

  const FogPrediction({
    required this.fogProbability,
    required this.state,
    required this.confidence,
  });
}

/// Probability bands that turn a binary FoG probability into a [FogState].
/// Tunable in one place; teammates retune once a real model + lead time exist.
class FogThresholds {
  const FogThresholds({this.preFreeze = 0.40, this.freezing = 0.70});
  final double preFreeze;
  final double freezing;

  FogState classify(double p) {
    if (p >= freezing) return FogState.freezing;
    if (p >= preFreeze) return FogState.preFreeze;
    return FogState.normal;
  }
}
