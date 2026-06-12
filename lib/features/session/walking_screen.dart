import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/fog_prediction.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../services/session/session_state.dart';
import '../../widgets/breath_glyph.dart';
import '../../widgets/equalizer_bars.dart';
import '../../widgets/pulse_ring.dart';
import 'intervention_screen.dart';
import 'summary_screen.dart';

/// Live walk screen. Light paper background. "Help & Respiration" button always
/// visible. Intervention screen surfaces on freeze prediction.
class WalkingScreen extends ConsumerStatefulWidget {
  const WalkingScreen({super.key});

  @override
  ConsumerState<WalkingScreen> createState() => _WalkingScreenState();
}

class _WalkingScreenState extends ConsumerState<WalkingScreen> {
  bool _interventionOpen = false;

  Color _ringColor(FogState s) => switch (s) {
        FogState.normal => AppColors.connected,
        FogState.preFreeze => AppColors.cue,
        FogState.freezing => AppColors.notConnected,
      };

  String _stateLabel(FogState s, AppLocalizations? l10n) => switch (s) {
        FogState.normal => l10n?.inRhythm ?? 'In rhythm',
        FogState.preFreeze => l10n?.steadying ?? 'Steadying',
        FogState.freezing => l10n?.steadying ?? 'Steadying',
      };

  ({IconData icon, Color fg, Color bg}) _pillStyle(FogState s) =>
      switch (s) {
        FogState.normal => (
            icon: Icons.check_circle,
            fg: AppColors.connected,
            bg: AppColors.okSoft,
          ),
        FogState.preFreeze || FogState.freezing => (
            icon: Icons.shield_outlined,
            fg: AppColors.accent,
            bg: AppColors.accentSoft,
          ),
      };

  void _openIntervention() {
    if (_interventionOpen) return;
    _interventionOpen = true;
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (_) => const InterventionScreen(),
            fullscreenDialog: true))
        .then((_) => _interventionOpen = false);
  }

  Future<void> _endWalk() async {
    await ref.read(sessionControllerProvider.notifier).endSession();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SummaryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SessionSnapshot>(sessionControllerProvider, (prev, next) {
      if (next.state == SessionState.intervention && !_interventionOpen) {
        _openIntervention();
      }
    });

    final l10n = AppLocalizations.of(context);
    final s = ref.watch(sessionControllerProvider);
    final mins =
        s.elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs =
        s.elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');

    final ringColor = _ringColor(s.fogState);
    final pill = _pillStyle(s.fogState);

    return Scaffold(
      body: AppTheme.pageBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
            child: Column(
              children: [
                // ── Timer row ──────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (l10n?.keepGoing ?? 'Keep going').toUpperCase(),
                          style: const TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkFaint,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$mins:$secs',
                          style: const TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 62,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                            letterSpacing: -1.8,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const SizedBox(height: 6),
                    // Status pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: pill.bg,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(pill.icon, color: pill.fg, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            _stateLabel(s.fogState, l10n),
                            style: TextStyle(
                              fontFamily: kFontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: pill.fg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // ── Cadence ring — size 230 ────────────────────────────
                PulseRing(
                  color: ringColor,
                  size: 230,
                  active: s.cuePlaying,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${s.stepsPerMin.round()}',
                        style: const TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -2,
                          height: 1.0,
                        ),
                      ),
                      const Text(
                        'steps / min',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontFamily: kFontFamily),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Now playing strip — waveform style ────────────────
                _NowPlayingStrip(bpm: s.bpm, playing: s.cuePlaying),
                const SizedBox(height: AppSpacing.sm),

                // ── Help & Respiration — always visible ───────────────
                _HelpRespirationButton(onTap: _openIntervention),
                const SizedBox(height: AppSpacing.sm),

                // ── End walk — ghost ──────────────────────────────────
                _EndWalkButton(onTap: _endWalk),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ),
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
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppTheme.cardDecoration(radius: AppRadii.lg),
      child: Row(
        children: [
          // Equalizer tile
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: EqualizerBars(
                barCount: 5,
                color: AppColors.primary,
                active: playing,
                barWidth: 3.2,
                gap: 2.5,
                minHeight: 3,
                maxHeight: 16,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Steady · ${bpm.round()} bpm',
                  style: const TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n?.matchedToPace ?? 'matched to your pace',
                  style: const TextStyle(
                    fontFamily: kFontFamily,
                    fontSize: 13,
                    color: AppColors.inkFaint,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.equalizer, color: AppColors.fabSoft, size: 22),
        ],
      ),
    );
  }
}

class _HelpRespirationButton extends StatelessWidget {
  const _HelpRespirationButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: 'Help and Respiration',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            height: 58,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: BreathGlyph(
                        size: 22, color: Colors.white, strokeWidth: 1.6),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    l10n?.helpRespiration ?? 'Help & Respiration',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontFamily: kFontFamily,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Colors.white70, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EndWalkButton extends StatelessWidget {
  const _EndWalkButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: 'End walk',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stop_rounded, color: AppColors.ink, size: 22),
                const SizedBox(width: 8),
                Text(
                  l10n?.endWalk ?? 'End walk',
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: kFontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
