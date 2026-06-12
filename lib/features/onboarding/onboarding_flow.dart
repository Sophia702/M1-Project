import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/sensor_status.dart';
import '../../data/persistence/app_prefs.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../services/voice/voice_controller.dart';
import '../../widgets/aria_logo.dart';
import '../../widgets/body_view.dart';
import '../../widgets/gradient_button.dart';
import '../shell/main_shell.dart';

/// First-run onboarding. Navigation is BUTTON-ONLY (no swipe) per the
/// no-fine-motor-gesture accessibility rule.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

enum _Baseline { idle, walking, done }

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  static const _steps = 5;
  static const _baselineSecs = 12;

  int _step = 0;
  bool _speechAssist = false;

  final _name = TextEditingController(text: 'Margaret');
  final _age = TextEditingController();
  final _years = TextEditingController();
  final _meds = TextEditingController();
  final _contactType = TextEditingController();
  final _contactName = TextEditingController();
  final _contactPhone = TextEditingController();

  _Baseline _baseline = _Baseline.idle;
  int _secsLeft = _baselineSecs;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in [
      _name,
      _age,
      _years,
      _meds,
      _contactType,
      _contactName,
      _contactPhone
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() => setState(() => _step++);

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _finish() async {
    await AppPrefs.setOnboarded();
    await AppPrefs.setVoiceEnabled(_speechAssist);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
    if (_speechAssist) {
      ref.read(voiceControllerProvider.notifier).enable();
    }
  }

  void _startBaseline() {
    setState(() {
      _baseline = _Baseline.walking;
      _secsLeft = _baselineSecs;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secsLeft <= 1) {
        t.cancel();
        setState(() {
          _secsLeft = 0;
          _baseline = _Baseline.done;
        });
        Future.delayed(const Duration(milliseconds: 900), _finish);
      } else {
        setState(() => _secsLeft--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: AppTheme.pageBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                    step: _step,
                    total: _steps,
                    onBack: _step > 0 ? _back : null),
                const SizedBox(height: AppSpacing.lg),
                Expanded(child: _buildStep(l10n)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(AppLocalizations? l10n) => switch (_step) {
        0 => _landing(l10n),
        1 => _howItHelps(l10n),
        2 => _aboutYou(l10n),
        3 => _connectSensors(l10n),
        _ => _baselineWalk(l10n),
      };

  // Step 0 — Landing.
  Widget _landing(AppLocalizations? l10n) {
    return Column(
      children: [
        const Spacer(),
        const AriaLogo(size: 64, showWordmark: false),
        const SizedBox(height: AppSpacing.lg),
        // "aria" wordmark in Newsreader italic.
        Text(
          'aria',
          style: AppType.displaySerif.copyWith(fontSize: 50),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n?.tagline ?? "Keep your life's rhythm",
          style: AppType.body.copyWith(
              fontWeight: FontWeight.w500, color: AppColors.inkSoft),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        _SpeechAssistButton(
          value: _speechAssist,
          onTap: () {
            setState(() => _speechAssist = !_speechAssist);
            AppPrefs.setVoiceEnabled(!_speechAssist);
          },
        ),
        const Spacer(),
        GradientButton(
            label: l10n?.getStarted ?? 'Get started',
            icon: Icons.arrow_forward_rounded,
            onPressed: _next),
      ],
    );
  }

  // Step 1 — How aria helps.
  Widget _howItHelps(AppLocalizations? l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n?.howHelps ?? 'How aria helps', style: AppType.h1),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: Column(
            children: [
              _HelpPoint(
                icon: Icons.sensors,
                title: l10n?.sensesWalk ?? 'Senses your walk',
                body: 'Wearable sensors read your gait in real time.',
                gradient: const LinearGradient(
                  colors: [Color(0xFF164D3C), Color(0xFF4E9A57)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _HelpPoint(
                icon: Icons.music_note,
                title: l10n?.playsABeat ?? 'Plays a beat',
                body: 'A steady rhythm helps keep you moving smoothly.',
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E3E48), Color(0xFFC4687A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _HelpPoint(
                icon: Icons.auto_awesome,
                title: l10n?.learnsAdapts ?? 'Learns & adapts',
                body: 'aria senses when you need support and steps in to help.',
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F5C49), Color(0xFF6E978A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ],
          ),
        ),
        GradientButton(
            label: l10n?.next ?? 'Next',
            icon: Icons.arrow_forward_rounded,
            onPressed: _next),
      ],
    );
  }

  // Step 2 — About you.
  Widget _aboutYou(AppLocalizations? l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n?.aboutYou ?? 'About you', style: AppType.h1),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: ListView(
            children: [
              _OnbField(label: 'Name', controller: _name),
              _OnbField(label: 'Age', controller: _age),
              _OnbField(label: 'Years since diagnosis', controller: _years),
              _OnbField(label: 'Medications (optional)', controller: _meds),
              _OnbField(
                  label: 'Emergency contact — relationship',
                  controller: _contactType),
              _OnbField(
                  label: 'Emergency contact — name',
                  controller: _contactName),
              _OnbField(
                  label: 'Emergency contact — phone',
                  controller: _contactPhone),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.lock_outline,
                      size: 18, color: AppColors.inkFaint),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'We ask for location only to share with your contact in an '
                      'emergency. Your data stays private.',
                      style:
                          AppType.label.copyWith(color: AppColors.inkFaint),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GradientButton(
            label: l10n?.continueBtn ?? 'Continue',
            icon: Icons.arrow_forward_rounded,
            onPressed: _next),
      ],
    );
  }

  // Step 3 — Connect sensors.
  Widget _connectSensors(AppLocalizations? l10n) {
    final sensors = ref.watch(sensorSourceProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n?.connectSensors ?? 'Connect sensors', style: AppType.h1),
        const SizedBox(height: AppSpacing.xs),
        Text(
            'Place a sensor on your lower back and each ankle, then tap to pair.',
            style: AppType.body),
        Expanded(
          child: StreamBuilder<SensorStatusMap>(
            stream: sensors.status,
            initialData: sensors.statusNow,
            builder: (context, snap) {
              final status = snap.data ?? SensorStatusMap.allNotConnected();
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
                      child: Text(l10n?.connectAll ?? 'Connect all',
                          style: AppType.button
                              .copyWith(color: AppColors.primary)),
                    )
                  else
                    GradientButton(
                        label: l10n?.next ?? 'Next',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _next),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // Step 4 — Baseline walk.
  Widget _baselineWalk(AppLocalizations? l10n) {
    final progress = (_baselineSecs - _secsLeft) / _baselineSecs;
    final elapsed = _baselineSecs - _secsLeft;
    final elapsedMins = (elapsed ~/ 60).toString();
    final elapsedSecs = (elapsed % 60).toString().padLeft(2, '0');
    final totalMins = (_baselineSecs ~/ 60).toString();
    final totalSecs = (_baselineSecs % 60).toString().padLeft(2, '0');

    final (label, onTap) = switch (_baseline) {
      _Baseline.idle => ('Start', _startBaseline),
      _Baseline.walking => ('Walking…', null),
      _Baseline.done => ('Complete', null),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(l10n?.baselineWalk ?? 'Baseline walk', style: AppType.h1),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('Take a few steps so aria can learn your natural pace.',
            style: AppType.body, textAlign: TextAlign.center),
        const Spacer(),
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: _baseline == _Baseline.idle ? 0 : progress,
                  strokeWidth: 12,
                  backgroundColor: AppColors.surfaceDeep,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              if (_baseline == _Baseline.done)
                const Icon(Icons.check_rounded,
                    size: 56, color: AppColors.primary)
              else
                Text(
                  '$elapsedMins:$elapsedSecs / $totalMins:$totalSecs',
                  style: AppType.h2.copyWith(
                      fontSize: 18, letterSpacing: -0.5),
                ),
            ],
          ),
        ),
        const Spacer(),
        GradientButton(
            label: label,
            icon: Icons.directions_walk,
            onPressed: onTap),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(
      {required this.step, required this.total, required this.onBack});
  final int step;
  final int total;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null)
          Semantics(
            button: true,
            label: 'Back',
            child: Material(
              color: AppColors.card,
              shape: const CircleBorder(),
              child: InkResponse(
                onTap: onBack,
                radius: 26,
                child: const SizedBox(
                    width: 48,
                    height: 48,
                    child:
                        Icon(Icons.arrow_back_rounded, color: AppColors.ink)),
              ),
            ),
          ),
        const Spacer(),
        Row(
          children: [
            for (var i = 0; i < total; i++)
              Container(
                margin: const EdgeInsets.only(left: 6),
                width: i == step ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == step ? AppColors.primary : AppColors.surfaceDeep,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
        const Spacer(),
        if (onBack != null) const SizedBox(width: 48),
      ],
    );
  }
}

/// Full-width burgundy speech-assist button for the landing step.
class _SpeechAssistButton extends StatelessWidget {
  const _SpeechAssistButton({required this.value, required this.onTap});
  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: 'Speech assist — hands-free voice mode',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 76),
          decoration: BoxDecoration(
            color: value ? AppColors.accent : AppColors.accentSoft,
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.mic_rounded,
                  color: value ? Colors.white : AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n?.speechAssist ?? 'Speech assist',
                      style: AppType.h2.copyWith(
                        fontSize: 17,
                        color: value ? Colors.white : AppColors.accent,
                      ),
                    ),
                    Text(
                      l10n?.speechAssistSub ?? 'Hands-free voice mode',
                      style: AppType.label.copyWith(
                        color: value
                            ? Colors.white.withValues(alpha: 0.75)
                            : AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: value ? Colors.white : AppColors.accent,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpPoint extends StatelessWidget {
  const _HelpPoint({
    required this.icon,
    required this.title,
    required this.body,
    required this.gradient,
  });
  final IconData icon;
  final String title;
  final String body;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppTheme.cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppType.h2.copyWith(fontSize: 18)),
                const SizedBox(height: 2),
                Text(body, style: AppType.body.copyWith(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnbField extends StatelessWidget {
  const _OnbField({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppType.label.copyWith(color: AppColors.inkSoft)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            style: AppType.h2.copyWith(fontSize: 18),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.field,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
