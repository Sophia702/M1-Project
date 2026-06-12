import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/sensor_status.dart';
import '../../providers/providers.dart';
import '../../widgets/body_view.dart';
import '../../widgets/gradient_button.dart';

class ConnectSensorsScreen extends ConsumerWidget {
  const ConnectSensorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensors = ref.watch(sensorSourceProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect sensors'),
        backgroundColor: AppColors.bgTop,
        foregroundColor: AppColors.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: AppTheme.pageBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Place a sensor on your lower back and each ankle, then tap to pair.',
                    style: AppType.body),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: StreamBuilder<SensorStatusMap>(
                    stream: sensors.status,
                    initialData: sensors.statusNow,
                    builder: (context, snap) {
                      final status =
                          snap.data ?? SensorStatusMap.allNotConnected();
                      return Column(
                        children: [
                          Expanded(
                            child: BodyView(
                              status: status,
                              onTap: (loc) => sensors.connect(loc),
                            ),
                          ),
                          if (!status.allConnected)
                            OutlinedButton(
                              onPressed: () => sensors.connectAll(),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                side: const BorderSide(
                                    color: AppColors.primary, width: 1.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.pill)),
                              ),
                              child: Text('Connect all',
                                  style: AppType.button
                                      .copyWith(color: AppColors.primary)),
                            )
                          else
                            GradientButton(
                              label: 'Done',
                              icon: Icons.check_rounded,
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                        ],
                      );
                    },
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
