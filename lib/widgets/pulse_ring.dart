import 'package:flutter/material.dart';

import '../core/theme/tokens.dart';

/// Animated concentric "pulse" used for the start-walk ring (Home) and the
/// live cadence ring (Walking). Recoloured per state by the caller.
///
/// Pure visual animation — NOT interactive (no gestures). Wrap it in a button
/// where a tap is needed (Home). Set [active] false to freeze the pulse.
class PulseRing extends StatefulWidget {
  const PulseRing({
    super.key,
    required this.color,
    this.size = 240,
    this.active = true,
    this.child,
  });

  final Color color;
  final double size;
  final bool active;
  final Widget? child;

  @override
  State<PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

  @override
  void initState() {
    super.initState();
    if (widget.active) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant PulseRing old) {
    super.didUpdateWidget(old);
    if (widget.active && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.active && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final core = widget.size * 0.62;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              _pulse((_c.value) % 1.0),
              _pulse((_c.value + 0.5) % 1.0),
              // Solid core.
              Container(
                width: core,
                height: core,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [widget.color, widget.color.withValues(alpha: 0.82)],
                  ),
                  boxShadow: AppShadows.raised,
                ),
                child: Center(child: widget.child),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _pulse(double t) {
    // t: 0 -> 1 ; ring grows from core to full size and fades out.
    final scale = 0.62 + t * 0.38;
    final opacity = (1.0 - t) * 0.35;
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Container(
        width: widget.size * scale,
        height: widget.size * scale,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withValues(alpha: 0.18),
        ),
      ),
    );
  }
}
