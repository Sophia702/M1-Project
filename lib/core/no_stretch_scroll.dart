import 'package:flutter/material.dart';

/// App-wide scroll behaviour: removes the Material "stretch" overscroll effect
/// (which warps the whole page when you fling past the edge) but keeps smooth,
/// momentum-y BouncingScrollPhysics so scrolling feels flowy. Applied via
/// MaterialApp.scrollBehavior.
class NoStretchScrollBehavior extends MaterialScrollBehavior {
  const NoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child; // no glow, no stretch warp

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
}
