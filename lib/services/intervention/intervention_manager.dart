import 'dart:async';

import '../../data/models/fog_prediction.dart';

/// What the user can choose when an intervention is surfaced.
enum InterventionAction {
  breathing,
  callEmergencyContact,
  callSupportLine,
  imOkayContinue,
}

/// A request to show the intervention flow, raised on preFreeze/freezing.
class InterventionRequest {
  final FogState trigger;
  final DateTime at;
  const InterventionRequest({required this.trigger, required this.at});
}

/// Outcome of an intervention, fed back to the session machine.
class InterventionResult {
  final InterventionAction action;

  /// True if the user wants to resume walking (e.g. "I'm okay, continue").
  final bool resumeWalking;
  const InterventionResult({required this.action, required this.resumeWalking});
}

/// Seam #4 — decides when to surface an intervention and resolves the choice.
///
/// The [SessionController] forwards every [FogState] to [onFogState]; the
/// manager debounces/decides and emits [requests]. The UI listens, shows the
/// intervention screen, and reports the chosen action via [resolve].
abstract class InterventionManager {
  Stream<InterventionRequest> get requests;

  /// Feed the latest gait state in. May (or may not) emit a request.
  void onFogState(FogState state);

  /// Resolve the active intervention with the user's choice.
  Future<InterventionResult> resolve(InterventionAction action);

  Future<void> dispose();
}
