import 'dart:async';

import '../../data/models/fog_prediction.dart';
import 'intervention_manager.dart';

/// Default intervention logic.
///
/// Raises ONE request per freeze episode: the first time gait enters
/// preFreeze/freezing it emits an [InterventionRequest]; it won't re-fire until
/// gait returns to normal (so the user isn't spammed during a long freeze).
/// [resolve] records the user's choice and re-arms for the next episode.
///
/// Pure logic only — actually placing a phone call (tel:) is done in the UI via
/// url_launcher, keeping this class platform-free and testable.
class DefaultInterventionManager implements InterventionManager {
  final _requests = StreamController<InterventionRequest>.broadcast();
  bool _episodeActive = false;

  @override
  Stream<InterventionRequest> get requests => _requests.stream;

  @override
  void onFogState(FogState state) {
    final isFreeze = state == FogState.preFreeze || state == FogState.freezing;
    if (isFreeze && !_episodeActive) {
      _episodeActive = true;
      _requests.add(
        InterventionRequest(trigger: state, at: DateTime.now()),
      );
    } else if (state == FogState.normal) {
      _episodeActive = false;
    }
  }

  @override
  Future<InterventionResult> resolve(InterventionAction action) async {
    // After resolving, re-arm so a fresh episode can trigger again.
    _episodeActive = false;
    final resume = action == InterventionAction.imOkayContinue ||
        action == InterventionAction.breathing;
    return InterventionResult(action: action, resumeWalking: resume);
  }

  @override
  Future<void> dispose() async {
    await _requests.close();
  }
}
