import 'package:flutter/material.dart';

import '../a11y/a11y.dart';
import 'tokens.dart';

/// Light-only ThemeData built from [AppColors] / [AppType].
///
/// Kept thin on purpose — most surfaces are bespoke widgets that read tokens
/// directly. This handles defaults (text, color scheme, min tap target).
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.ink,
      secondary: AppColors.plum,
      surface: AppColors.card,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bgTop,
      // Bundled Lexend as the default family; inline/AppType styles inherit it.
      fontFamily: kFontFamily,
      // Ensures interactive widgets honour the >=56dp tap target (A11y).
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

  /// A full-bleed gradient page background. Wrap screen bodies in this.
  static Widget pageBackground({required Widget child, Gradient? gradient}) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient ?? AppColors.pageGradient),
      child: child,
    );
  }

  /// Standard white card container with the signature lift shadow.
  static BoxDecoration cardDecoration({double radius = AppRadii.lg}) {
    return BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: AppShadows.card,
    );
  }

  /// Minimum interactive size as a constraint (see [A11y.minTapTarget]).
  static const Size minButtonSize = Size(A11y.minTapTarget, A11y.minTapTarget);
}
