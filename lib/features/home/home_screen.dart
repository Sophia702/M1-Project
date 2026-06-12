import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/sensor_schema.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/sensor_status.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../services/sensors/sensor_source.dart';
import '../../services/voice/voice_controller.dart';
import '../../widgets/aria_logo.dart';
import '../../widgets/pulse_ring.dart';
import '../session/start_walk.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.name = 'Margaret'});
  final String name;

  static String _greeting(AppLocalizations? l10n) {
    final h = DateTime.now().hour;
    if (h < 12) return l10n?.goodMorning ?? 'Good morning,';
    if (h < 17) return l10n?.goodAfternoon ?? 'Good afternoon,';
    return l10n?.goodEvening ?? 'Good evening,';
  }

  Widget _orb(Color color, double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sensors = ref.watch(sensorSourceProvider);
    final voiceEnabled = ref.watch(voiceControllerProvider).enabled;

    return Stack(
      children: [
        Positioned(
            top: -55,
            right: -55,
            child: _orb(AppColors.primary, 200, 0.08)),

        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md,
              AppSpacing.lg, AppSpacing.navClearance),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              Row(
                children: [
                  const AriaLogo(size: 36, showWordmark: false),
                  const SizedBox(width: 8),
                  Text(
                    'aria',
                    style: AppType.displaySerif.copyWith(
                      fontSize: 24,
                      color: AppColors.ink,
                    ),
                  ),
                  const Spacer(),
                  Semantics(
                    button: true,
                    label: 'Speech assist',
                    child: GestureDetector(
                      onTap: () {
                        final notifier =
                            ref.read(voiceControllerProvider.notifier);
                        if (voiceEnabled) {
                          notifier.disable();
                        } else {
                          notifier.enable();
                        }
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.28),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.mic_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Greeting ─────────────────────────────────────────────────
              Text(
                _greeting(l10n),
                style: const TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.inkSoft,
                ),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -1.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(l10n?.readyWalk ?? 'Ready to take a mindful walk?',
                  style: AppType.body),
              const SizedBox(height: AppSpacing.md),

              // ── Streak chip — soft clay ────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.claySoft,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: AppColors.clay, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      l10n?.dayStreak(6) ?? '6 day streak',
                      style: const TextStyle(
                        color: AppColors.clay,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        fontFamily: kFontFamily,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Last-walk stat strip ──────────────────────────────────
              Row(
                children: [
                  Expanded(child: _MiniStatCard(
                    icon: Icons.directions_walk,
                    value: '642',
                    caption: 'steps',
                  )),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: _MiniStatCard(
                    icon: Icons.timer_rounded,
                    value: '18',
                    caption: 'min',
                  )),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Start walk ring — size 280 ────────────────────────────
              Center(
                child: Semantics(
                  button: true,
                  label: 'Start walk',
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => startWalk(context, ref),
                      child: PulseRing(
                        color: AppColors.primary,
                        size: 280,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.directions_walk,
                                color: Colors.white, size: 54),
                            const SizedBox(height: 8),
                            Text(
                              l10n?.startWalk ?? 'Start walk',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                fontFamily: kFontFamily,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              StreamBuilder<SensorStatusMap>(
                stream: sensors.status,
                initialData: sensors.statusNow,
                builder: (context, snap) {
                  final status =
                      snap.data ?? SensorStatusMap.allNotConnected();
                  return _SensorsCard(
                      status: status, sensors: sensors, l10n: l10n);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Small 2-col stat card for the returning-user last-walk strip.
class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
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
      decoration: AppTheme.cardDecoration(radius: AppRadii.md),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              Text(caption, style: AppType.label),
            ],
          ),
        ],
      ),
    );
  }
}

class _SensorsCard extends StatelessWidget {
  const _SensorsCard(
      {required this.status, required this.sensors, required this.l10n});
  final SensorStatusMap status;
  final SensorSource sensors;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final locations = SensorLocation.values;
    return Container(
      decoration: AppTheme.cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(l10n?.sensors ?? 'Sensors', style: AppType.label),
                const Spacer(),
                if (!status.allConnected)
                  InkWell(
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    onTap: () => sensors.connectAll(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDeep],
                        ),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Text(
                        l10n?.connectAll ?? 'Connect all',
                        style: AppType.label.copyWith(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.okSoft,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.connected, size: 13),
                        const SizedBox(width: 4),
                        Text(l10n?.allReady ?? 'All ready',
                            style: AppType.label.copyWith(
                                color: AppColors.connected, fontSize: 12)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Rows with lineSoft dividers.
            for (var idx = 0; idx < locations.length; idx++) ...[
              if (idx > 0)
                const Divider(
                    height: 1, thickness: 1, color: AppColors.lineSoft),
              _SensorRow(
                location: locations[idx],
                state: status.of(locations[idx]),
                onTap: () => sensors.connect(locations[idx]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SensorRow extends StatelessWidget {
  const _SensorRow(
      {required this.location, required this.state, required this.onTap});
  final SensorLocation location;
  final SensorConnState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    String locLabel;
    if (l10n != null) {
      locLabel = switch (location) {
        SensorLocation.lowerBack => l10n.lowerBack,
        SensorLocation.ankleLeft => l10n.leftAnkle,
        SensorLocation.ankleRight => l10n.rightAnkle,
      };
    } else {
      locLabel = location.label;
    }

    final (iconColor, tileColor, trailingIcon, trailingColor, trailingText) =
        switch (state) {
      SensorConnState.connected => (
          AppColors.primary,
          AppColors.primarySoft,
          Icons.check,
          AppColors.primary,
          l10n?.connected ?? 'Connected',
        ),
      SensorConnState.pairing => (
          AppColors.primary,
          AppColors.primarySoft,
          Icons.bluetooth_searching,
          AppColors.cue,
          l10n?.pairing ?? 'Pairing…',
        ),
      SensorConnState.notConnected => (
          AppColors.inkSoft,
          AppColors.field,
          Icons.add_circle_outline,
          AppColors.notConnected,
          'Tap to connect',
        ),
    };

    return Semantics(
      button: state != SensorConnState.connected,
      label: '$locLabel, $trailingText',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: state == SensorConnState.connected ? null : onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(Icons.bluetooth, color: iconColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(locLabel,
                    style: AppType.h2.copyWith(fontSize: 17)),
              ),
              Icon(trailingIcon, color: trailingColor, size: 16),
              const SizedBox(width: 5),
              Text(
                trailingText,
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: trailingColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
