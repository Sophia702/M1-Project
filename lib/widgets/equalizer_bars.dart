import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animated equalizer bars — staggered vertical pulses when [active].
/// Holds static heights when [active] is false or
/// `MediaQuery.disableAnimations` is true (reduced-motion).
class EqualizerBars extends StatefulWidget {
  const EqualizerBars({
    super.key,
    this.barCount = 5,
    required this.color,
    required this.active,
    this.barWidth = 3.2,
    this.gap = 3.0,
    this.minHeight = 4.0,
    this.maxHeight = 18.0,
  });

  final int barCount;
  final Color color;
  final bool active;
  final double barWidth;
  final double gap;
  final double minHeight;
  final double maxHeight;

  @override
  State<EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<EqualizerBars>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _sync();
  }

  @override
  void didUpdateWidget(EqualizerBars old) {
    super.didUpdateWidget(old);
    if (widget.active != old.active) _sync();
  }

  void _sync() {
    if (widget.active) {
      _ctrl.repeat();
    } else {
      _ctrl.animateBack(0.0, duration: const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _barHeight(int i, bool reduced) {
    // Static stagger for reduced motion or inactive state.
    const staticPattern = [0.30, 0.70, 0.50, 0.85, 0.40];
    if (!widget.active || reduced) {
      final ratio = i < staticPattern.length
          ? staticPattern[i]
          : 0.4 + (i % 3) * 0.15;
      return widget.minHeight +
          (widget.maxHeight - widget.minHeight) * ratio;
    }
    final phase = (i / widget.barCount) * 2 * math.pi;
    final t = _ctrl.value * 2 * math.pi;
    return widget.minHeight +
        (widget.maxHeight - widget.minHeight) *
            (0.5 + 0.5 * math.sin(t + phase));
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.barCount, (i) {
          return Padding(
            padding: EdgeInsets.only(left: i > 0 ? widget.gap : 0),
            child: AnimatedContainer(
              duration: reduced
                  ? Duration.zero
                  : const Duration(milliseconds: 50),
              width: widget.barWidth,
              height: _barHeight(i, reduced),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius:
                    BorderRadius.circular(widget.barWidth / 2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
