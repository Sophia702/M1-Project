import 'package:flutter/material.dart';

/// Three concentric stroked circles with a filled centre dot.
/// Used on the Help & Respiration button and the Breathing exercise option.
class BreathGlyph extends StatelessWidget {
  const BreathGlyph({
    super.key,
    this.size = 24,
    required this.color,
    this.strokeWidth = 1.5,
  });

  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _Painter(color: color, strokeWidth: strokeWidth),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  const _Painter({required this.color, required this.strokeWidth});
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final u = size.width / 24; // scale unit (1 u = 1/24th of box)

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    canvas.drawCircle(center, 9.5 * u, stroke); // outer
    canvas.drawCircle(center, 6.0 * u, stroke); // mid
    canvas.drawCircle(center, 2.5 * u, stroke); // inner

    canvas.drawCircle(center, 1.3 * u,
        Paint()..color = color..isAntiAlias = true); // dot
  }

  @override
  bool shouldRepaint(covariant _Painter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
