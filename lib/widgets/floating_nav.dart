import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/a11y/a11y.dart';
import '../core/theme/tokens.dart';
import '../l10n/app_localizations.dart';

/// Floating pill bottom navigation with a circular Start button docked into the
/// bar. The bar has a CONCAVE NOTCH scooped out around the button, leaving a
/// ring of empty (background) space between the button and the bar edge — and
/// the button sits a bit more than halfway down into the bar.
/// Slots: Home · Progress · [Start] · Profile · Settings. Taps only.
class FloatingNav extends StatelessWidget {
  const FloatingNav({
    super.key,
    required this.index,
    required this.onSelect,
    required this.onStart,
  });

  /// 0=Home, 1=Progress, 2=Profile, 3=Settings (centre Start isn't an index).
  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onStart;

  static const double _barHeight = 66;
  static const double _btnSize = 64;
  static const double _ringGap = 7; // empty space between button and bar cutout
  static const double _overlapDown = 9; // how far the button centre sits below bar top

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const notchRadius = _btnSize / 2 + _ringGap;
    // Region tall enough for the part of the button that pops above the bar.
    const regionH = _barHeight + _btnSize / 2 - _overlapDown;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: SizedBox(
        height: regionH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // The notched bar, anchored to the bottom.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: _barHeight,
                child: Stack(
                  children: [
                    // Frosted glass blur layer clipped to the pill shape.
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(_barHeight / 2),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                    // Semi-transparent notched bar + nav items on top.
                    CustomPaint(
                      painter: _NotchedBarPainter(
                        notchCenterY: _overlapDown,
                        notchRadius: notchRadius,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _NavItem(
                              icon: Icons.home_rounded,
                              label: l10n?.navHome ?? 'Home',
                              selected: index == 0,
                              onTap: () => onSelect(0)),
                          _NavItem(
                              icon: Icons.insights_rounded,
                              label: l10n?.navProgress ?? 'Progress',
                              selected: index == 1,
                              onTap: () => onSelect(1)),
                          const SizedBox(width: _btnSize + 24),
                          _NavItem(
                              icon: Icons.person_rounded,
                              label: l10n?.navProfile ?? 'Profile',
                              selected: index == 2,
                              onTap: () => onSelect(2)),
                          _NavItem(
                              icon: Icons.settings_rounded,
                              label: l10n?.navSettings ?? 'Settings',
                              selected: index == 3,
                              onTap: () => onSelect(3)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // The Start button, sitting in the notch.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(child: _StartButton(onTap: onStart, size: _btnSize)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints the white pill bar with a circular notch (plus ring gap) cut out at
/// top-centre, and a soft shadow that follows the notched shape.
class _NotchedBarPainter extends CustomPainter {
  _NotchedBarPainter({required this.notchCenterY, required this.notchRadius});
  final double notchCenterY;
  final double notchRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final host = Offset.zero & size;
    final guest = Rect.fromCircle(
      center: Offset(size.width / 2, notchCenterY),
      radius: notchRadius,
    );
    // CircularNotchedRectangle gives smooth S-curve shoulders (soft corners)
    // around the button instead of sharp cusps.
    final notched = const CircularNotchedRectangle().getOuterPath(host, guest);
    final pill = Path()
      ..addRRect(RRect.fromRectAndRadius(host, Radius.circular(size.height / 2)));
    // Intersect to keep the rounded pill ends while using the smooth notch.
    final path = Path.combine(PathOperation.intersect, notched, pill);

    canvas.drawShadow(path, const Color(0x55394A40), 8, false);
    canvas.drawPath(path, Paint()
      ..color = AppColors.card.withValues(alpha: 0.82)
      ..isAntiAlias = true);
  }

  @override
  bool shouldRepaint(covariant _NotchedBarPainter old) =>
      old.notchCenterY != notchCenterY || old.notchRadius != notchRadius;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.label;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
              minWidth: A11y.minTapTarget, minHeight: A11y.minTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 25),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onTap, required this.size});
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Start walk',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkResponse(
          onTap: onTap,
          radius: size * 0.7,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              gradient: AppColors.accentGradient,
              shape: BoxShape.circle,
              boxShadow: AppShadows.raised,
            ),
            child: const Icon(Icons.directions_walk, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }
}
