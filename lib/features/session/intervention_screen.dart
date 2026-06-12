import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/a11y/a11y.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../services/intervention/intervention_manager.dart';
import '../../widgets/breath_glyph.dart';
import '../../widgets/gradient_button.dart';

/// Freeze intervention screen. Light background, no emojis.
/// Ambient breathing animation guides the user while they decide.
class InterventionScreen extends ConsumerWidget {
  const InterventionScreen({super.key});

  Future<void> _choose(
    BuildContext context,
    WidgetRef ref,
    InterventionAction action, {
    String? dial,
  }) async {
    if (dial != null) {
      final uri = Uri(scheme: 'tel', path: dial);
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    }
    await ref
        .read(sessionControllerProvider.notifier)
        .resolveIntervention(action);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: AppTheme.pageBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sm),

                // ── Status chip — centered ─────────────────────────────
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_outlined,
                            color: AppColors.accent, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          l10n?.freezeDetected ?? 'Freeze detected',
                          style: AppType.label.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Breathing circle ──────────────────────────────────
                const Center(child: _BreathingCircle()),

                const SizedBox(height: AppSpacing.xl),

                Text(
                  l10n?.hereWithYou ?? "I'm right here with you",
                  style: AppType.h1.copyWith(fontSize: 22),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n?.breatheFollow ??
                      'Follow the circle and breathe. Take your time.',
                  style: AppType.body.copyWith(fontSize: 15),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Option: breathing exercise ────────────────────────
                _OptionCard(
                  icon: null,
                  breathGlyph: true,
                  title: l10n?.breathingExercise ?? 'Breathing exercise',
                  subtitle: l10n?.breathingSub ?? 'Slow, guided breaths',
                  accentFg: AppColors.primary,
                  accentBg: AppColors.primarySoft,
                  onTap: () =>
                      _choose(context, ref, InterventionAction.breathing),
                ),
                const SizedBox(height: A11y.minTargetSpacing),

                // ── Option: call emergency ────────────────────────────
                _OptionCard(
                  icon: Icons.call_rounded,
                  breathGlyph: false,
                  title:
                      l10n?.callEmergencyContact ?? 'Call emergency contact',
                  subtitle: l10n?.callEmergencySub ?? 'Reach your saved contact',
                  accentFg: AppColors.accent,
                  accentBg: AppColors.accentSoft,
                  onTap: () => _choose(
                      context, ref, InterventionAction.callEmergencyContact,
                      dial: '911'),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── I'm okay — GradientButton ─────────────────────────
                GradientButton(
                  label: l10n?.imOkayContinue ?? "I'm okay, continue",
                  icon: Icons.check_rounded,
                  onPressed: () => _choose(
                      context, ref, InterventionAction.imOkayContinue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated concentric breathing rings — 4-phase box-breath (in→hold→out→hold)
/// each 2 s (8 s total cycle). Holds static when animations are disabled.
class _BreathingCircle extends StatefulWidget {
  const _BreathingCircle();

  @override
  State<_BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<_BreathingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _phaseLabel {
    final v = _ctrl.value;
    if (v < 0.25) return 'Breathe in';
    if (v < 0.50) return 'Hold';
    if (v < 0.75) return 'Breathe out';
    return 'Hold';
  }

  double get _scale {
    final v = _ctrl.value;
    if (v < 0.25) return 0.85 + (v / 0.25) * 0.30; // growing
    if (v < 0.50) return 1.15; // hold
    if (v < 0.75) return 1.15 - ((v - 0.50) / 0.25) * 0.30; // shrinking
    return 0.85; // hold small
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final scale = reduced ? 1.0 : _scale;
        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.fab.withValues(alpha: 0.07),
                  ),
                ),
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.fab.withValues(alpha: 0.14),
                  ),
                ),
                Container(
                  width: 104,
                  height: 104,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.fab, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.raised,
                  ),
                  child: Center(
                    child: Text(
                      reduced ? 'Breathe' : _phaseLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: kFontFamily,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.breathGlyph,
    required this.title,
    required this.subtitle,
    required this.accentFg,
    required this.accentBg,
    required this.onTap,
  });

  final IconData? icon;
  final bool breathGlyph;
  final String title;
  final String subtitle;
  final Color accentFg;
  final Color accentBg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 76),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: AppTheme.cardDecoration(),
            child: Row(
              children: [
                // Circular icon tile
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accentBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: breathGlyph
                        ? BreathGlyph(
                            size: 24,
                            color: accentFg,
                            strokeWidth: 1.6,
                          )
                        : Icon(icon!, color: accentFg, size: 26),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title,
                          style: AppType.h2.copyWith(fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: AppType.body.copyWith(fontSize: 15)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.inkFaint, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
