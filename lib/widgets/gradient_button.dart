import 'package:flutter/material.dart';

import '../core/a11y/a11y.dart';
import '../core/theme/tokens.dart';

/// The single primary action on a screen. Large (>= [A11y.minTapTarget] tall),
/// high-contrast, rounded, gradient-filled, with an icon + label so colour is
/// never the only signal. Taps only — no gestures.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          onTap: onPressed,
          child: Opacity(
            opacity: enabled ? 1 : 0.5,
            child: Container(
              constraints: const BoxConstraints(minHeight: A11y.minTapTarget),
              width: expand ? double.infinity : null,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                gradient: gradient ?? AppColors.accentGradient,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                boxShadow: AppShadows.raised,
              ),
              child: Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 24),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: AppType.button,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
