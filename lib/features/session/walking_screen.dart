import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/fog_prediction.dart';
import '../../providers/providers.dart';
import '../../services/session/session_state.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/pulse_ring.dart';
import 'intervention_screen.dart';

/// Screen 12 — the live walk. Full-screen, no nav. The cadence ring recolours
/// with the gait state; the now-playing strip shows the continuous cue. When
/// the session machine enters `intervention`, the intervention screen is shown.
class WalkingScreen extends ConsumerStatefulWidget {
  const WalkingScreen({super.key});

  @override
  ConsumerState<WalkingScreen> createState() => _WalkingScreenState();
}

class _WalkingScreenState extends ConsumerState<WalkingScreen> {
  bool _interventionOpen = false;

  Color _ringColor(FogState s) => switch (s) {
        FogState.normal => AppColors.indigo,
        FogState.preFreeze => AppColors.cue,
        FogState.freezing => AppColors.notConnected,
      };

  String _stateLabel(FogState s) => switch (s) {
        FogState.normal => 'In rhythm',
        FogState.preFreeze => 'Steady your steps',
        FogState.freezing => 'Freeze detected',
      };

  Future<void> _endWalk() async {
    await ref.read(sessionControllerProvider.notifier).endSession();
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    // Surface the intervention flow when the machine asks for it.
    ref.listen<SessionSnapshot>(sessionControllerProvider, (prev, next) {
      if (next.state == SessionState.intervention && !_interventionOpen) {
        _interventionOpen = true;
        Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (_) => const InterventionScreen(), fullscreenDialog: true))
            .then((_) => _interventionOpen = false);
      }
    });

    final s = ref.watch(sessionControllerProvider);
    final mins = s.elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = s.elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Scaffold(
      body: AppTheme.pageBackground(
        gradient: AppColors.walkingWash,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.md),
                Text('Keep going', style: AppType.h1),
                Text('$mins:$secs', style: AppType.label),
                const Spacer(),
                PulseRing(
                  color: _ringColor(s.fogState),
                  size: 270,
                  active: s.cuePlaying,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${s.stepsPerMin.round()}',
                          style: AppType.display.copyWith(color: Colors.white)),
                      const Text('steps / min',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _StateBanner(
                  label: _stateLabel(s.fogState),
                  color: _ringColor(s.fogState),
                ),
                const Spacer(),
                _NowPlayingStrip(bpm: s.bpm, playing: s.cuePlaying),
                const SizedBox(height: AppSpacing.md),
                GradientButton(
                  label: 'End walk',
                  icon: Icons.stop_rounded,
                  onPressed: _endWalk,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StateBanner extends StatelessWidget {
  const _StateBanner({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 12, color: color),
          const SizedBox(width: AppSpacing.sm),
          Text(label,
              style: AppType.label.copyWith(color: AppColors.navy)),
        ],
      ),
    );
  }
}

class _NowPlayingStrip extends StatelessWidget {
  const _NowPlayingStrip({required this.bpm, required this.playing});
  final double bpm;
  final bool playing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppTheme.cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
                gradient: AppColors.accentGradient, shape: BoxShape.circle),
            child: Icon(playing ? Icons.music_note : Icons.music_off,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Metronome cue', style: AppType.label),
              Text('${bpm.round()} bpm',
                  style: AppType.h2.copyWith(fontSize: 20)),
            ],
          ),
          const Spacer(),
          Icon(playing ? Icons.graphic_eq : Icons.pause,
              color: AppColors.indigo, size: 26),
        ],
      ),
    );
  }
}
