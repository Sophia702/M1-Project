import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/sensor_schema.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/sensor_status.dart';
import '../../providers/providers.dart';
import '../../services/sensors/sensor_source.dart';
import '../../widgets/aria_logo.dart';
import '../../widgets/pulse_ring.dart';
import '../session/start_walk.dart';

/// Screen 06 — Home tab. Logo, greeting, the pulsing start-walk ring, and a
/// detailed per-sensor list (tap a sensor to pair, or connect all).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.name = 'Margaret'});
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensors = ref.watch(sensorSourceProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md,
          AppSpacing.lg, AppSpacing.navClearance),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AriaLogo(size: 38),
          const SizedBox(height: AppSpacing.xl),
          Text('Welcome,', style: AppType.h1),
          Text(name, style: AppType.display),
          const SizedBox(height: AppSpacing.sm),
          Text('Ready to take a mindful walk?', style: AppType.body),
          const SizedBox(height: AppSpacing.xl),
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
                    size: 268,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.directions_walk,
                            color: Colors.white, size: 54),
                        SizedBox(height: 8),
                        Text('Start walk',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700)),
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
              final status = snap.data ?? SensorStatusMap.allNotConnected();
              return _SensorsCard(status: status, sensors: sensors);
            },
          ),
        ],
      ),
    );
  }
}

class _SensorsCard extends StatelessWidget {
  const _SensorsCard({required this.status, required this.sensors});
  final SensorStatusMap status;
  final SensorSource sensors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Sensors', style: AppType.label),
              const Spacer(),
              if (!status.allConnected)
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  onTap: () => sensors.connectAll(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    child: Text('Connect all',
                        style: AppType.label.copyWith(color: AppColors.primary)),
                  ),
                )
              else
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.connected, size: 18),
                    const SizedBox(width: 4),
                    Text('All ready',
                        style: AppType.label.copyWith(color: AppColors.connected)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final loc in SensorLocation.values)
            _SensorRow(
              location: loc,
              state: status.of(loc),
              onTap: () => sensors.connect(loc),
            ),
        ],
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

  ({Color color, String text, IconData icon}) get _status => switch (state) {
        SensorConnState.connected =>
          (color: AppColors.connected, text: 'Connected', icon: Icons.check_circle),
        SensorConnState.pairing => (
            color: AppColors.cue,
            text: 'Pairing…',
            icon: Icons.bluetooth_searching
          ),
        SensorConnState.notConnected => (
            color: AppColors.notConnected,
            text: 'Tap to connect',
            icon: Icons.add_circle_outline
          ),
      };

  @override
  Widget build(BuildContext context) {
    final s = _status;
    return Semantics(
      button: state != SensorConnState.connected,
      label: '${location.label}, ${s.text}',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: state == SensorConnState.connected ? null : onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: const Icon(Icons.sensors, color: AppColors.ink, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(location.label,
                    style: AppType.h2.copyWith(fontSize: 17)),
              ),
              Icon(s.icon, color: s.color, size: 18),
              const SizedBox(width: 6),
              Text(s.text, style: AppType.label.copyWith(color: s.color)),
            ],
          ),
        ),
      ),
    );
  }
}
