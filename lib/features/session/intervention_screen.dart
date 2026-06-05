import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/a11y/a11y.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../providers/providers.dart';
import '../../services/intervention/intervention_manager.dart';

/// Screen 13 — Intervention. Surfaced on a predicted/active freeze. One tap per
/// option, large targets, icon + label on every choice (no colour-only cues).
class InterventionScreen extends ConsumerWidget {
  const InterventionScreen({super.key});

  Future<void> _choose(
    BuildContext context,
    WidgetRef ref,
    InterventionAction action, {
    String? dial,
  }) async {
    if (dial != null) {
      final uri = Uri(scheme: 'tel', path: dial);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
    await ref.read(sessionControllerProvider.notifier).resolveIntervention(action);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: AppTheme.pageBackground(
        gradient: AppColors.walkingWash,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),
                Text('Let’s ease this', style: AppType.h1),
                const SizedBox(height: AppSpacing.xs),
                Text('Pick what helps right now. The beat keeps playing.',
                    style: AppType.body),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: ListView(
                    children: [
                      _Option(
                        icon: Icons.self_improvement,
                        title: 'Breathing exercise',
                        subtitle: 'Slow, guided breaths',
                        color: AppColors.indigo,
                        onTap: () => _choose(
                            context, ref, InterventionAction.breathing),
                      ),
                      _Option(
                        icon: Icons.call,
                        title: 'Call emergency contact',
                        subtitle: 'Reach your saved contact',
                        color: AppColors.notConnected,
                        onTap: () => _choose(
                            context, ref, InterventionAction.callEmergencyContact,
                            dial: '911'),
                      ),
                      _Option(
                        icon: Icons.support_agent,
                        title: 'Call support line',
                        subtitle: 'Talk to a helpline',
                        color: AppColors.cue,
                        onTap: () => _choose(
                            context, ref, InterventionAction.callSupportLine,
                            dial: '811'),
                      ),
                      _Option(
                        icon: Icons.check_circle,
                        title: 'I’m okay, continue',
                        subtitle: 'Resume the walk',
                        color: AppColors.connected,
                        onTap: () => _choose(
                            context, ref, InterventionAction.imOkayContinue),
                      ),
                    ],
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

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: A11y.minTargetSpacing),
      child: Semantics(
        button: true,
        label: title,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 84),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: AppTheme.cardDecoration(),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: AppType.h2.copyWith(fontSize: 20)),
                        const SizedBox(height: 2),
                        Text(subtitle, style: AppType.body.copyWith(fontSize: 15)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.labelGray),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
