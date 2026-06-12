import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/a11y/a11y.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/persistence/app_prefs.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../services/voice/voice_controller.dart';
import '../onboarding/onboarding_flow.dart';
import '../session/connect_sensors_screen.dart';

/// Settings. Audio preferences, sensor configuration, notifications,
/// accessibility, and language selector.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _volume = 80;
  int _tempo = 108;
  bool _reminders = true;

  void _setVoice(bool v) {
    final c = ref.read(voiceControllerProvider.notifier);
    if (v) {
      c.enable();
    } else {
      c.disable();
    }
    AppPrefs.setVoiceEnabled(v);
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md,
          AppSpacing.lg, AppSpacing.navClearance),
      children: [
        Text(l10n?.settings ?? 'Settings', style: AppType.h1),
        const SizedBox(height: AppSpacing.md),
        _Section(title: l10n?.audioPrefs ?? 'Audio preferences', children: [
          _VolumeControl(
            label: l10n?.cueVolume ?? 'Cue volume',
            value: _volume,
            onChanged: (v) => setState(() => _volume = v.clamp(0, 100)),
          ),
          const Divider(height: AppSpacing.lg, color: AppColors.surfaceDeep),
          _StepperRow(
            label: l10n?.beatTempo ?? 'Beat tempo',
            value: '$_tempo bpm',
            onMinus: _tempo > 60 ? () => setState(() => _tempo -= 2) : null,
            onPlus: _tempo < 140 ? () => setState(() => _tempo += 2) : null,
          ),
        ]),
        const SizedBox(height: AppSpacing.md),
        _Section(title: l10n?.sensorConfig ?? 'Sensor configuration', children: [
          _RowTile(
            icon: Icons.sensors,
            title: l10n?.manageSensors ?? 'Manage sensors',
            trailing: Text('3 connected',
                style: AppType.label.copyWith(color: AppColors.connected)),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const ConnectSensorsScreen()),
            ),
          ),
        ]),
        const SizedBox(height: AppSpacing.md),
        _Section(title: l10n?.notifications ?? 'Notifications', children: [
          _RowTile(
            icon: Icons.notifications_rounded,
            title: l10n?.dailyReminders ?? 'Daily reminders',
            trailing: Switch(
              value: _reminders,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => setState(() => _reminders = v),
            ),
            onTap: () => setState(() => _reminders = !_reminders),
          ),
        ]),
        const SizedBox(height: AppSpacing.md),
        _Section(title: l10n?.accessibility ?? 'Accessibility', children: [
          _RowTile(
            icon: Icons.mic_rounded,
            title: l10n?.speechAssistHandsFree ?? 'Speech assist (hands-free)',
            trailing: Switch(
              value: ref.watch(voiceControllerProvider).enabled,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => _setVoice(v),
            ),
            onTap: () =>
                _setVoice(!ref.read(voiceControllerProvider).enabled),
          ),
        ]),
        const SizedBox(height: AppSpacing.md),
        _Section(title: l10n?.language ?? 'Language', children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                _LangButton(
                  label: 'English',
                  locale: const Locale('en'),
                  currentLocale: currentLocale,
                  onTap: () =>
                      ref.read(localeProvider.notifier).set(const Locale('en')),
                ),
                const SizedBox(width: 12),
                _LangButton(
                  label: 'Français',
                  locale: const Locale('fr'),
                  currentLocale: currentLocale,
                  onTap: () =>
                      ref.read(localeProvider.notifier).set(const Locale('fr')),
                ),
              ],
            ),
          ),
        ]),
        const SizedBox(height: AppSpacing.md),
        _Section(title: '🛠  Developer', children: [
          _RowTile(
            icon: Icons.replay_rounded,
            title: 'Restart onboarding',
            trailing: const Icon(Icons.chevron_right, color: AppColors.inkFaint),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const OnboardingFlow(),
                fullscreenDialog: true,
              ),
            ),
          ),
        ]),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppType.label),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  const _LangButton({
    required this.label,
    required this.locale,
    required this.currentLocale,
    required this.onTap,
  });
  final String label;
  final Locale locale;
  final Locale currentLocale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = currentLocale.languageCode == locale.languageCode;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.field,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: selected ? Colors.white : AppColors.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VolumeControl extends StatelessWidget {
  const _VolumeControl(
      {required this.label, required this.value, required this.onChanged});
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppType.h2.copyWith(fontSize: 18)),
            const Spacer(),
            Text('$value%', style: AppType.label),
          ],
        ),
        Row(
          children: [
            _RoundBtn(
                icon: Icons.remove,
                onTap: value > 0 ? () => onChanged(value - 10) : null),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.surfaceDeep,
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withValues(alpha: 0.15),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: value.toDouble(),
                  max: 100,
                  divisions: 20,
                  onChanged: (v) => onChanged(v.round()),
                ),
              ),
            ),
            _RoundBtn(
                icon: Icons.add,
                onTap: value < 100 ? () => onChanged(value + 10) : null),
          ],
        ),
      ],
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });
  final String label;
  final String value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppType.h2.copyWith(fontSize: 18)),
              Text(value, style: AppType.label),
            ],
          ),
        ),
        _RoundBtn(icon: Icons.remove, onTap: onMinus),
        const SizedBox(width: AppSpacing.sm),
        _RoundBtn(icon: Icons.add, onTap: onPlus),
      ],
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      child: Material(
        color: Colors.transparent,
        child: InkResponse(
          onTap: onTap,
          radius: 32,
          child: Container(
            width: A11y.minTapTarget,
            height: A11y.minTapTarget,
            decoration: BoxDecoration(
              color: enabled
                  ? AppColors.surface
                  : AppColors.surface.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                color: enabled ? AppColors.ink : AppColors.inkFaint,
                size: 24),
          ),
        ),
      ),
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({
    required this.icon,
    required this.title,
    required this.trailing,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.md),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: A11y.minTapTarget),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: Text(title, style: AppType.h2.copyWith(fontSize: 18))),
            trailing,
          ],
        ),
      ),
    );
  }
}
