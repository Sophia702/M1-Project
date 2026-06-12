import 'package:flutter/material.dart';

import '../core/a11y/a11y.dart';
import '../core/sensor_schema.dart';
import '../core/theme/tokens.dart';
import '../data/models/sensor_status.dart';

/// Body view for the Connect-sensors screen: a full-body silhouette that gently
/// turns (a pseudo-3D sway), with the 3 sensor placements — lower back and BOTH
/// ankles — sitting on the figure. Each is a tappable status dot.
///
/// NOTE: this is a 2D silhouette with a 3D-style turn. A true textured rotating
/// 3D model would use a `.glb` asset via `model_viewer_plus` / `flutter_3d_controller`;
/// drop a humanoid model in assets and swap the painter for that when available.
class BodyView extends StatefulWidget {
  const BodyView({super.key, required this.status, required this.onTap});

  final SensorStatusMap status;
  final ValueChanged<SensorLocation> onTap;

  @override
  State<BodyView> createState() => _BodyViewState();
}

class _BodyViewState extends State<BodyView> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  )..repeat(reverse: true);

  // Sensor placements over the figure (fractional -> Alignment).
  static const _spots = {
    SensorLocation.lowerBack: Alignment(0.0, -0.06),
    SensorLocation.ankleLeft: Alignment(-0.22, 0.74),
    SensorLocation.ankleRight: Alignment(0.22, 0.74),
  };

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The turning silhouette.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, child) {
                final angle = (_c.value - 0.5) * 0.7; // ~ -0.35..0.35 rad sway
                final m = Matrix4.identity()
                  ..setEntry(3, 2, 0.0012) // perspective
                  ..rotateY(angle);
                return Transform(
                  alignment: Alignment.center,
                  transform: m,
                  child: child,
                );
              },
              child: CustomPaint(painter: _BodyPainter()),
            ),
          ),
          // Sensor markers (kept flat so labels stay readable).
          for (final loc in SensorLocation.values)
            Align(
              alignment: _spots[loc]!,
              child: _SensorDot(
                location: loc,
                state: widget.status.of(loc),
                onTap: () => widget.onTap(loc),
              ),
            ),
        ],
      ),
    );
  }
}

class _BodyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final body = Paint()
      ..color = AppColors.surfaceDeep
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final limb = Paint()
      ..color = AppColors.surfaceDeep
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Head.
    canvas.drawCircle(Offset(cx, h * 0.10), w * 0.105, body);

    // Torso (rounded).
    final torso = RRect.fromRectAndRadius(
      Rect.fromLTRB(cx - w * 0.17, h * 0.19, cx + w * 0.17, h * 0.56),
      Radius.circular(w * 0.16),
    );
    canvas.drawRRect(torso, body);

    // Arms.
    limb.strokeWidth = w * 0.11;
    canvas.drawLine(
        Offset(cx - w * 0.14, h * 0.24), Offset(cx - w * 0.34, h * 0.47), limb);
    canvas.drawLine(
        Offset(cx + w * 0.14, h * 0.24), Offset(cx + w * 0.34, h * 0.47), limb);

    // Legs (reach down to the ankle markers).
    limb.strokeWidth = w * 0.13;
    canvas.drawLine(
        Offset(cx - w * 0.08, h * 0.54), Offset(cx - w * 0.10, h * 0.88), limb);
    canvas.drawLine(
        Offset(cx + w * 0.08, h * 0.54), Offset(cx + w * 0.10, h * 0.88), limb);

    // Feet.
    limb.strokeWidth = w * 0.07;
    canvas.drawLine(
        Offset(cx - w * 0.10, h * 0.90), Offset(cx - w * 0.02, h * 0.92), limb);
    canvas.drawLine(
        Offset(cx + w * 0.10, h * 0.90), Offset(cx + w * 0.02, h * 0.92), limb);
  }

  @override
  bool shouldRepaint(covariant _BodyPainter oldDelegate) => false;
}

class _SensorDot extends StatelessWidget {
  const _SensorDot(
      {required this.location, required this.state, required this.onTap});
  final SensorLocation location;
  final SensorConnState state;
  final VoidCallback onTap;

  Color get _color => switch (state) {
        SensorConnState.connected => AppColors.connected,
        SensorConnState.pairing => AppColors.cue,
        SensorConnState.notConnected => AppColors.notConnected,
      };

  IconData get _icon => switch (state) {
        SensorConnState.connected => Icons.check,
        SensorConnState.pairing => Icons.bluetooth_searching,
        SensorConnState.notConnected => Icons.add,
      };

  String get _statusLabel => switch (state) {
        SensorConnState.connected => 'Connected',
        SensorConnState.pairing => 'Pairing…',
        SensorConnState.notConnected => 'Tap to connect',
      };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${location.label}, $_statusLabel',
      child: Material(
        color: Colors.transparent,
        child: InkResponse(
          onTap: onTap,
          radius: 36,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: A11y.minTapTarget,
                height: A11y.minTapTarget,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: _color, width: 3),
                  boxShadow: AppShadows.card,
                ),
                child: Icon(_icon, color: _color, size: 24),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  boxShadow: AppShadows.card,
                ),
                child: Text(location.label,
                    style: AppType.label.copyWith(fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
