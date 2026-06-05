import 'package:flutter/material.dart';

/// Central design tokens for aria.
///
/// EVERYTHING tunable about the look lives here so the visual language can be
/// adjusted in one place. Light mode only ("premium with depth"): soft gradient
/// backgrounds, white cards that lift off the page, lavender accent surfaces,
/// big bold display numbers, generous whitespace, large rounded corners.
class AppColors {
  AppColors._();

  // Page background — vertical gradient.
  static const Color bgTop = Color(0xFFF6F5FC);
  static const Color bgBottom = Color(0xFFEAE8F4);

  // Brand.
  static const Color navy = Color(0xFF2C3563); // primary text, buttons, active nav
  static const Color indigo = Color(0xFF5B4FB0); // accent

  // Lavender surfaces.
  static const Color lavender = Color(0xFFECEAF6);
  static const Color lavenderDeep = Color(0xFFDAD7EB);

  // Cards.
  static const Color card = Color(0xFFFFFFFF);

  // Text.
  static const Color labelGray = Color(0xFF8A8CA3);
  static const Color mutedText = Color(0xFF6E7191);

  // Status — always paired with an icon + label (color is never the only signal).
  static const Color connected = Color(0xFF3BA776); // green
  static const Color notConnected = Color(0xFFE06A5A); // red
  static const Color cue = Color(0xFFE8A53A); // amber — cue / intervention

  // Soft lavender wash for the live walking screen.
  static const Color walkingWashTop = Color(0xFFEFEDFA);
  static const Color walkingWashBottom = Color(0xFFE3E0F3);

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgBottom],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [indigo, navy],
  );

  static const LinearGradient walkingWash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [walkingWashTop, walkingWashBottom],
  );
}

class AppRadii {
  AppRadii._();
  static const double sm = 14;
  static const double md = 18;
  static const double lg = 24;
  static const double xl = 28;
  static const double pill = 999;
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 6;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppShadows {
  AppShadows._();

  /// White-card lift: 0 8px 22px rgba(44,53,99,.09).
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x172C3563), // ~9% navy
      blurRadius: 22,
      offset: Offset(0, 8),
    ),
  ];

  /// Stronger lift for the raised start-walk button / floating nav.
  static const List<BoxShadow> raised = [
    BoxShadow(
      color: Color(0x332C3563), // ~20% navy
      blurRadius: 28,
      offset: Offset(0, 10),
    ),
  ];
}

/// Type scale. Min body ~18sp for low-vision / older-adult readability
/// (WCAG 2.2 §1.4.4 resize text; large type recommended by Parkinson's UI
/// guidance, Nunes et al. Springer 10.1007/s10209-015-0440-1).
class AppType {
  AppType._();
  static const String? family = null; // system font for MVP

  static const TextStyle display = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w800,
    color: AppColors.navy,
    height: 1.0,
    letterSpacing: -1.0,
  );
  static const TextStyle h1 = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.navy,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.w700,
    color: AppColors.navy,
  );
  static const TextStyle body = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.mutedText,
    height: 1.35,
  );
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.labelGray,
    letterSpacing: 0.3,
  );
  static const TextStyle button = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}
