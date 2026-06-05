import 'package:flutter/widgets.dart';

/// Accessibility constants for aria, with the source of each rule cited inline.
///
/// Target users have Parkinson's disease: hand tremor, bradykinesia (slowness),
/// and possible visual / cognitive changes; many are older adults. These
/// constants encode the resulting UI rules so they're applied consistently.
///
/// Sources:
///  - Nunes, Silva et al., "Design recommendations for a smartphone UI for
///    people with Parkinson's", Universal Access in the Information Society,
///    Springer, DOI 10.1007/s10209-015-0440-1.
///  - WCAG 2.2: §2.5.5 Target Size, §2.5.8 Target Size (Minimum),
///    §1.4.3 Contrast (Minimum), §1.4.4 Resize Text.
///  - Hand-tremor accessibility research (large, well-spaced, non-gestural
///    controls reduce mis-taps for tremor and motor impairment).
class A11y {
  A11y._();

  /// Minimum tap-target edge. WCAG 2.2 §2.5.5 asks for >=44px and Material
  /// for 48dp; we use 56dp because tremor/bradykinesia raise the miss rate on
  /// small targets (Springer 10.1007/s10209-015-0440-1).
  static const double minTapTarget = 56.0;

  /// Generous gap BETWEEN tap targets so a tremor near one control doesn't
  /// trigger its neighbour.
  static const double minTargetSpacing = 16.0;

  /// One primary action per screen — keep flows simple for cognitive load.
  static const int maxPrimaryActionsPerScreen = 1;

  /// NO fine-motor gestures anywhere in the app: no swipe, drag, double-tap,
  /// long-press, or pinch. Single taps only. (Tab/segment bars are taps.)
  /// This is a design rule enforced by code review, surfaced here for intent.
  static const bool gesturesDisabled = true;

  /// Wrap any tappable child so it always meets the minimum target size,
  /// regardless of its visual size.
  static Widget tappable({required Widget child}) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: minTapTarget,
            minHeight: minTapTarget,
          ),
          child: child,
        ),
      );
}
