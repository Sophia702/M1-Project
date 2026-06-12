import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/tokens.dart';
import '../data/persistence/app_prefs.dart';
import '../services/voice/voice_controller.dart';

/// Big round button to turn hands-free speech assist on/off. Filled green when
/// active, outlined when off; reflects [voiceControllerProvider] state.
class VoiceToggleButton extends ConsumerWidget {
  const VoiceToggleButton({super.key, this.size = 56});
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(voiceControllerProvider).enabled;
    return Semantics(
      button: true,
      toggled: enabled,
      label: enabled ? 'Turn off speech assist' : 'Turn on speech assist',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () async {
            final c = ref.read(voiceControllerProvider.notifier);
            if (enabled) {
              await c.disable();
            } else {
              await c.enable();
            }
            await AppPrefs.setVoiceEnabled(!enabled);
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: enabled ? AppColors.accentGradient : null,
              color: enabled ? null : AppColors.card,
              border: enabled
                  ? null
                  : Border.all(color: AppColors.surfaceDeep, width: 1.5),
              boxShadow: AppShadows.card,
            ),
            child: Icon(
              enabled ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: enabled ? Colors.white : AppColors.ink,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
