import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../widgets/gradient_button.dart';

/// Post-walk Summary. Newsreader serif for name, 2×2 stats grid,
/// flat primarySoft stat tiles, quote card with "Today's note" eyebrow.
class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key, this.name = 'Margaret'});
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(sessionControllerProvider);
    final minutes = s.elapsed.inSeconds / 60.0;
    final steps = (s.stepsPerMin * minutes).round();
    final mins =
        s.elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs =
        s.elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Scaffold(
      body: AppTheme.pageBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const SizedBox(height: AppSpacing.lg),

              // Check ring
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 136,
                      height: 136,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.fab.withValues(alpha: 0.18),
                            AppColors.fab.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.fab.withValues(alpha: 0.22),
                          width: 2,
                        ),
                      ),
                    ),
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.fab, AppColors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.raised,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 46),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Center(
                child: Text(
                  '${l10n?.niceWalk ?? 'Nice walk,'} $name',
                  style: AppType.displaySerif.copyWith(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: Text(
                  l10n?.keptRhythm ??
                      'You kept a steady rhythm the whole way.',
                  style: AppType.body,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 2×2 stats grid — all tiles use primarySoft / primary
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _FlatStatCard(
                          icon: Icons.timer_rounded,
                          value: '$mins:$secs',
                          caption: l10n?.duration ?? 'Duration',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _FlatStatCard(
                          icon: Icons.speed,
                          value: '${s.stepsPerMin.round()}',
                          caption: l10n?.avgPace ?? 'Avg pace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _FlatStatCard(
                          icon: Icons.directions_walk,
                          value: '$steps',
                          caption: l10n?.steps ?? 'Steps',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _FlatStatCard(
                          icon: Icons.shield_outlined,
                          value: '${s.freezesEased}',
                          caption: l10n?.freezeEased ?? 'Freeze eased',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),
              const _QuoteCard(),
              const SizedBox(height: AppSpacing.lg),

              GradientButton(
                label: l10n?.done ?? 'Done',
                icon: Icons.home_rounded,
                onPressed: () {
                  ref.read(sessionControllerProvider.notifier).reset();
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Flat stat tile: primarySoft icon badge, no gradient strip, radius 16.
class _FlatStatCard extends StatelessWidget {
  const _FlatStatCard({
    required this.icon,
    required this.value,
    required this.caption,
  });
  final IconData icon;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(value,
              style: AppType.h1.copyWith(fontSize: 28, letterSpacing: -1)),
          const SizedBox(height: 2),
          Text(caption, style: AppType.label),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.pinkGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -12,
            right: 4,
            child: Icon(Icons.format_quote_rounded,
                color: Colors.white.withValues(alpha: 0.10), size: 88),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.todaysNote ?? "Today's note",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: kFontFamily,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n?.summaryQuote ??
                    'Rhythm is a gentle anchor — you found yours today.',
                style: AppType.displaySerif.copyWith(
                  fontSize: 19,
                  color: Colors.white,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
