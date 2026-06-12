import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central design tokens for aria.
///
/// Refined palette: flat warm paper backgrounds, deep forest-green primary,
/// burgundy accent for speech-assist/help pops only. Newsreader italic for
/// display/hero moments; Lexend for all other text.
class AppColors {
  AppColors._();

  // Page background — flat warm paper.
  static const Color bgTop    = Color(0xFFF4F2EC);
  static const Color bgBottom = Color(0xFFECE9E1);

  // Primary — deep forest green.
  static const Color primary     = Color(0xFF164D3C);
  static const Color primaryDeep = Color(0xFF0E392C);

  // FAB / action circles.
  static const Color fab     = Color(0xFF1F5C49);
  static const Color fabSoft = Color(0xFF6E978A);

  // Accent — deep burgundy (speech assist, help button, freeze chip ONLY).
  static const Color accent     = Color(0xFF8E3E48);
  static const Color accentSoft = Color(0xFFEEE0DF);

  // Text.
  static const Color ink      = Color(0xFF171B17);
  static const Color inkSoft  = Color(0xFF565C55);
  static const Color inkFaint = Color(0xFF9A9A8F);

  // Surfaces.
  static const Color card        = Color(0xFFFFFFFF);
  static const Color field       = Color(0xFFEBE9E1);
  static const Color surface     = Color(0xFFEFE8DE);
  static const Color surfaceDeep = Color(0xFFE2D9CC);
  static const Color line        = Color(0xFFE5E2D9); // hairline borders

  // Status — always paired with icon + label.
  static const Color connected    = Color(0xFF4E9A57);
  static const Color notConnected = Color(0xFFB04040);
  static const Color cue          = Color(0xFF7E6320); // amber — pre-freeze

  // Clay — streak chips, stat cards secondary accent.
  static const Color clay     = Color(0xFF7E6346);
  static const Color claySoft = Color(0xFFE7E1D5);

  // Flat soft tints — icon tiles, chips, hairline dividers.
  static const Color primarySoft = Color(0xFFE2EAE4); // soft green tile behind primary icons
  static const Color surfaceSunk  = Color(0xFFFAF9F5); // selected/recessed card fill
  static const Color lineSoft     = Color(0xFFEEEBE3); // in-card hairline divider
  static const Color okSoft       = Color(0xFFE2EAE4); // green status pill bg
  static const Color warnSoft     = Color(0xFFECE6D6); // amber status pill bg
  static const Color chipBg       = Color(0xFFEDEAE1); // neutral chip bg

  // Walking screen radial gradient (speech-assist mode only).
  static const LinearGradient walkingWash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1B2F28), Color(0xFF0F1C19)],
  );

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgBottom],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDeep],
  );

  static const LinearGradient pinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7A2D42), Color(0xFF8E3E48)],
  );

  // Legacy aliases — kept so unedited files compile without changes.
  static const Color label    = inkFaint;
  static const Color plum     = accent;
  static const Color plumDeep = accent;
  static const Color sage     = fabSoft;
  static const Color rose     = accent;
  static const Color amber    = Color(0xFFC99A4A);
  static const Color sky      = Color(0xFF6E90B0);
  static const LinearGradient plumGradient = pinkGradient;
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

  /// Minimal warm shadow — used for raised elements like the start button.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x12553B2A),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> raised = [
    BoxShadow(
      color: Color(0x33394A40),
      blurRadius: 26,
      offset: Offset(0, 10),
    ),
  ];
}

/// Type scale.
///
/// [kFontFamily] — Lexend, bundled. All body/UI text.
/// [kSerifFamily] — Newsreader italic (via google_fonts). Display moments only:
///   app wordmark on landing, session name in summary, quote card text.
const String kFontFamily   = 'Lexend';
const String kSerifFamily  = 'Newsreader';

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

  /// Newsreader italic — app wordmark, session name, quote text.
  /// Not const: google_fonts returns a runtime TextStyle.
  static TextStyle get displaySerif => GoogleFonts.newsreader(
    fontStyle: FontStyle.italic,
    fontSize: 42,
    fontWeight: FontWeight.w500,
    color: AppColors.ink,
    height: 1.04,
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
    color: AppColors.inkFaint,
    letterSpacing: 0.3,
  );
  static const TextStyle button = TextStyle(
    fontFamily: kFontFamily,
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}
