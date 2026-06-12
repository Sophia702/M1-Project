import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/no_stretch_scroll.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/tokens.dart';
import 'data/persistence/app_prefs.dart';
import 'features/onboarding/onboarding_flow.dart';
import 'features/shell/main_shell.dart';
import 'l10n/app_localizations.dart';
import 'providers/providers.dart';
import 'widgets/aria_logo.dart';
import 'widgets/voice_overlay.dart';

class AriaApp extends ConsumerWidget {
  const AriaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      title: 'aria',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      scrollBehavior: const NoStretchScrollBehavior(),
      navigatorKey: navigatorKey,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => VoiceOverlay(child: child ?? const SizedBox()),
      home: const _Boot(),
    );
  }
}

class _Boot extends StatefulWidget {
  const _Boot();

  @override
  State<_Boot> createState() => _BootState();
}

class _BootState extends State<_Boot> with SingleTickerProviderStateMixin {
  late final AnimationController _fade;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade.forward();
    _run();
  }

  Future<void> _run() async {
    // Start prefs load immediately; hold splash for at least 3.0 s.
    final onboardedFuture = AppPrefs.isOnboarded();
    await Future.delayed(const Duration(milliseconds: 3000));
    final onboarded = await onboardedFuture;
    if (!mounted) return;
    // Push the next screen fading IN over the splash (no reverse-fade to black).
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) =>
            onboarded ? const MainShell() : const OnboardingFlow(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FadeTransition(
      opacity: _fade,
      child: Scaffold(
        body: AppTheme.pageBackground(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AriaLogo(size: 88, showWordmark: false),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'aria',
                  style: AppType.displaySerif.copyWith(fontSize: 58),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n?.tagline ?? "Keep your life's rhythm",
                  style: AppType.body.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.inkSoft,
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
