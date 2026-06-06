import 'package:flutter/material.dart';

/// Central design tokens for aria.
///
/// EVERYTHING tunable about the look lives here. Premium, calm, minimal — a
/// soft neutral-sage background, white cards that lift off the page, a deep
/// forest-green primary with a plum secondary, and sage / rose / gold accents
/// for variety. Light mode only.
class AppColors {
  AppColors._();

  // Page background — soft neutral paper with a faint sage warmth.
  static const Color bgTop = Color(0xFFF4F3ED);
  static const Color bgBottom = Color(0xFFE8EBE1);

  // Text (deep green-charcoal through muted sage-greys).
  static const Color ink = Color(0xFF26312B); // primary text, active nav
  static const Color inkSoft = Color(0xFF5C6A61); // body / muted text
  static const Color label = Color(0xFF97A096); // small labels

  // Primary accent — deep forest green.
  static const Color primary = Color(0xFF2F5D4A);
  static const Color primaryDeep = Color(0xFF234A3B);

  // Secondary accent — plum.
  static const Color plum = Color(0xFF6E4C66);
  static const Color plumDeep = Color(0xFF553B4F);

  // Extra soft accents (stat cards, variety).
  static const Color sage = Color(0xFF7BA38C);
  static const Color rose = Color(0xFFC68793);
  static const Color amber = Color(0xFFC99A4A); // warm gold
  static const Color sky = Color(0xFF6E90B0);

  // Cards + surfaces.
  static const Color card = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFECEEE6); // sage-tinted chip
  static const Color surfaceDeep = Color(0xFFDBE0D5);

  // Status — always paired with an icon + label (colour is never the only cue).
  static const Color connected = Color(0xFF4E9E78); // green
  static const Color notConnected = Color(0xFFC65B4E); // red
  static const Color cue = Color(0xFFC99A4A); // gold — cue / pre-freeze

  // Soft wash for the live walking screen.
  static const Color walkingWashTop = Color(0xFFEFF2EA);
  static const Color walkingWashBottom = Color(0xFFE2E9DC);

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgBottom],
  );

  /// Primary action gradient (buttons, start ring).
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDeep],
  );

  /// Secondary gradient (plum accent cards).
  static const LinearGradient plumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [plum, plumDeep],
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

  /// Bottom padding tab content reserves so the floating nav doesn't cover it.
  static const double navClearance = 122;
}

class AppShadows {
  AppShadows._();

  /// White-card lift, soft and warm: 0 8px 22px rgba(38,49,43,.10).
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x1A26312B),
      blurRadius: 22,
      offset: Offset(0, 8),
    ),
  ];

  /// Stronger lift for the raised start button / floating nav.
  static const List<BoxShadow> raised = [
    BoxShadow(
      color: Color(0x33394A40),
      blurRadius: 26,
      offset: Offset(0, 10),
    ),
  ];
}

/// Type scale — Lexend (chosen for reading-proficiency / accessibility),
/// BUNDLED in assets/fonts so it never depends on a network fetch. Min body
/// ~18sp for low-vision / older-adult readability (WCAG 2.2 §1.4.4; large type
/// recommended by Parkinson's UI guidance, Nunes et al. Springer
/// 10.1007/s10209-015-0440-1). To change typeface: swap [kFontFamily] + the
/// pubspec font entry.
const String kFontFamily = 'Lexend';

class AppType {
  AppType._();

  static const TextStyle display = TextStyle(
    fontFamily: kFontFamily,
    fontSize: 56,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
    height: 1.0,
    letterSpacing: -1.5,
  );
  static const TextStyle h1 = TextStyle(
    fontFamily: kFontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    letterSpacing: -0.5,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: kFontFamily,
    fontSize: 23,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
  static const TextStyle body = TextStyle(
    fontFamily: kFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.inkSoft,
    height: 1.35,
  );
  static const TextStyle label = TextStyle(
    fontFamily: kFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.label,
    letterSpacing: 0.3,
  );
  static const TextStyle button = TextStyle(
    fontFamily: kFontFamily,
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}
