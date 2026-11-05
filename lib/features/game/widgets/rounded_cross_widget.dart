import 'package:flutter/material.dart';

/// Renders a cute chunky rounded cross matching the MeowDoku style.
class RoundedCrossWidget extends StatelessWidget {
  final Color color;
  final double size;
  final double strokeRatio;

  const RoundedCrossWidget({
    super.key,
    required this.color,
    this.size = 24.0,
    this.strokeRatio = 0.26,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RoundedCrossPainter(
          color: color,
          strokeWidth: size * strokeRatio,
        ),
      ),
    );
  }
}

class _RoundedCrossPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _RoundedCrossPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final padding = strokeWidth * 0.55;
    // Diagonal \
    canvas.drawLine(
      Offset(padding, padding),
      Offset(size.width - padding, size.height - padding),
      paint,
    );
    // Diagonal /
    canvas.drawLine(
      Offset(size.width - padding, padding),
      Offset(padding, size.height - padding),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RoundedCrossPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

