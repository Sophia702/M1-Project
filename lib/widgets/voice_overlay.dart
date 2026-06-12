import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/tokens.dart';
import '../data/persistence/app_prefs.dart';
import '../services/voice/voice_controller.dart';

/// Wraps the whole app (via MaterialApp.builder). Shows the speech-assist
/// status banner (mic state + live captions + tap-to-talk + turn-off) whenever
/// voice mode is on, and auto-enables it on launch if the user saved the
/// preference.
class VoiceOverlay extends ConsumerStatefulWidget {
  const VoiceOverlay({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<VoiceOverlay> createState() => _VoiceOverlayState();
}

class _VoiceOverlayState extends ConsumerState<VoiceOverlay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await AppPrefs.voiceEnabled()) {
        ref.read(voiceControllerProvider.notifier).enable();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final v = ref.watch(voiceControllerProvider);
    final show = v.enabled || v.status == VoiceStatus.unavailable;
    return Stack(
      children: [
        widget.child,
        if (show)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: _VoiceBanner(state: v),
            ),
          ),
      ],
    );
  }
}

class _VoiceBanner extends ConsumerWidget {
  const _VoiceBanner({required this.state});
  final VoiceUiState state;

  ({IconData icon, Color color, String label}) get _status =>
      switch (state.status) {
        VoiceStatus.listening =>
          (icon: Icons.mic, color: AppColors.connected, label: 'Listening…'),
        VoiceStatus.speaking => (
            icon: Icons.volume_up_rounded,
            color: AppColors.primary,
            label: 'aria is speaking'
          ),
        VoiceStatus.confirming =>
          (icon: Icons.help_outline, color: AppColors.cue, label: 'Say yes or no'),
        VoiceStatus.unavailable => (
            icon: Icons.mic_off,
            color: AppColors.notConnected,
            label: 'Voice unavailable'
          ),
        _ => (icon: Icons.mic_none, color: AppColors.label, label: 'Voice assist'),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = _status;
    final controller = ref.read(voiceControllerProvider.notifier);
    // Material ancestor so IconButton ink works (we're above the Navigator's
    // Overlay here, so no Tooltip — it would need an Overlay ancestor).
    return Material(
      color: Colors.transparent,
      child: Container(
      margin: const EdgeInsets.all(AppSpacing.sm),
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm,
          AppSpacing.sm, AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.raised,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(s.icon, color: s.color, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(s.label,
                    style: AppType.label.copyWith(color: AppColors.ink)),
              ),
              // Tap-to-talk fallback.
              Semantics(
                button: true,
                label: 'Listen now',
                child: IconButton(
                  onPressed: controller.listenNow,
                  icon: const Icon(Icons.touch_app_rounded,
                      color: AppColors.primary),
                ),
              ),
              // Turn voice off.
              Semantics(
                button: true,
                label: 'Turn off voice',
                child: IconButton(
                  onPressed: () async {
                    await controller.disable();
                    await AppPrefs.setVoiceEnabled(false);
                  },
                  icon: const Icon(Icons.close_rounded, color: AppColors.label),
                ),
              ),
            ],
          ),
          if (state.caption.isNotEmpty || state.lastHeard.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                  left: 2, right: 2, top: 2, bottom: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.caption.isNotEmpty)
                    Text('aria: ${state.caption}',
                        style: AppType.body.copyWith(fontSize: 14)),
                  if (state.lastHeard.isNotEmpty)
                    Text('you: ${state.lastHeard}',
                        style: AppType.label.copyWith(color: AppColors.inkSoft)),
                ],
              ),
            ),
        ],
      ),
      ),
    );
  }
}
