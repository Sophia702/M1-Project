import 'package:flutter/material.dart';

import '../a11y/a11y.dart';
import 'tokens.dart';

/// Light-only ThemeData built from [AppColors] / [AppType].
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.ink,
      secondary: AppColors.accent,
      surface: AppColors.card,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bgTop,
      fontFamily: kFontFamily,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      splashFactory: InkRipple.splashFactory,
      iconTheme: const IconThemeData(color: AppColors.ink, size: 26),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  /// Full-bleed gradient page background.
  static Widget pageBackground({required Widget child, Gradient? gradient}) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient ?? AppColors.pageGradient),
      child: child,
    );
  }

  /// White card with hairline border — flat paper aesthetic.
  static BoxDecoration cardDecoration({double radius = AppRadii.lg}) {
    return BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.line, width: 1),
    );
  }

  static const Size minButtonSize = Size(A11y.minTapTarget, A11y.minTapTarget);
}
