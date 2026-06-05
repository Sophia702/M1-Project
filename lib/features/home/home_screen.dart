import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/sensor_status.dart';
import '../../providers/providers.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/pulse_ring.dart';
import '../session/walking_screen.dart';

/// Screen 06 — Home. Greeting + the pulsing start-walk ring + sensor status.
/// (M1 subset of the full home; floating nav arrives in M2.)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.name = 'Margaret'});
  final String name;

  Future<void> _startWalk(BuildContext context, WidgetRef ref) async {
    // Mock sensors auto-connect inside startSession. (Real flow: if no sensors
    // are connected, route to the Connect-sensors screen — M2.)
    await ref.read(sessionControllerProvider.notifier).startSession(bpm: 108);
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WalkingScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensors = ref.watch(sensorSourceProvider);
    return Scaffold(
      body: AppTheme.pageBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Text('Welcome,', style: AppType.h1),
                Text(name, style: AppType.display),
                const SizedBox(height: AppSpacing.sm),
                Text('Ready to take a mindful walk?', style: AppType.body),
                const Spacer(),
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
                        onTap: () => _startWalk(context, ref),
                        child: PulseRing(
                          color: AppColors.indigo,
                          size: 250,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.directions_walk,
                                  color: Colors.white, size: 46),
                              SizedBox(height: 6),
                              Text('Start walk',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                StreamBuilder<SensorStatusMap>(
                  stream: sensors.status,
                  initialData: sensors.statusNow,
                  builder: (context, snap) {
                    final s = snap.data ?? SensorStatusMap.allNotConnected();
                    final ready = s.allConnected;
                    return _SensorStatusChip(
                      connected: s.connectedCount,
                      total: 4,
                      ready: ready,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                // Demo affordance: voice-driven start (full speech-assist in M3).
                GradientButton(
                  label: 'Start walk',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => _startWalk(context, ref),
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

class _SensorStatusChip extends StatelessWidget {
  const _SensorStatusChip({
    required this.connected,
    required this.total,
    required this.ready,
  });
  final int connected;
  final int total;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final color = ready ? AppColors.connected : AppColors.labelGray;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ready ? Icons.check_circle : Icons.sensors, color: color, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Text(
            ready ? 'Sensors ready' : '$connected of $total sensors connected',
            style: AppType.label.copyWith(color: AppColors.navy),
          ),
        ],
      ),
    );
  }
}
