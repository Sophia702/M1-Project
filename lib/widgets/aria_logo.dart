import 'package:flutter/material.dart';

import '../core/theme/tokens.dart';

/// aria brand mark — uses the real logo PNG asset (aria_logo.png).
/// [showWordmark] controls whether the "aria" serif text follows the badge.
class AriaLogo extends StatelessWidget {
  const AriaLogo({super.key, this.size = 40, this.showWordmark = true});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final badge = ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.26),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          'assets/images/aria_logo.png',
          fit: BoxFit.cover,
        ),
      ),
    );

    if (!showWordmark) return badge;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge,
        SizedBox(width: size * 0.28),
        Text(
          'aria',
          style: AppType.displaySerif.copyWith(
            fontSize: size * 0.60,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}
