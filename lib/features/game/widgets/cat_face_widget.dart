import 'dart:math';
import 'package:flutter/material.dart';

/// Adorable vector Tuxedo Cat face matching the MeowDoku art style.
class CatFaceWidget extends StatelessWidget {
  final double size;
  final bool hasCrown;
  final bool isSilhouette;
  final Color? silhouetteColor;

  const CatFaceWidget({
    super.key,
    required this.size,
    this.hasCrown = false,
    this.isSilhouette = false,
    this.silhouetteColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CatFacePainter(
          hasCrown: hasCrown,
          isSilhouette: isSilhouette,
          silhouetteColor: silhouetteColor ?? Colors.black26,
        ),
      ),
    );
  }
}

class _CatFacePainter extends CustomPainter {
  final bool hasCrown;
  final bool isSilhouette;
  final Color silhouetteColor;

  _CatFacePainter({
    required this.hasCrown,
    required this.isSilhouette,
    required this.silhouetteColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    if (isSilhouette) {
      _paintSilhouette(canvas, size);
      return;
    }

    final blackPaint = Paint()..color = const Color(0xFF222226);
    final whitePaint = Paint()..color = Colors.white;
    final pinkPaint = Paint()..color = const Color(0xFFFFB6C1);
    final nosePaint = Paint()..color = const Color(0xFFFF6584);
    final blushPaint = Paint()..color = const Color(0xFFFF8DA1).withValues(alpha: 0.45);
    final whiskerPaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..strokeWidth = max(1.0, w * 0.035)
      ..strokeCap = StrokeCap.round;

    // 1. Ears (Black triangles)
    // Left ear
    final leftEar = Path()
      ..moveTo(w * 0.18, h * 0.42)
      ..lineTo(w * 0.12, h * 0.08)
      ..lineTo(w * 0.44, h * 0.22)
      ..close();
    canvas.drawPath(leftEar, blackPaint);

    // Right ear
    final rightEar = Path()
      ..moveTo(w * 0.82, h * 0.42)
      ..lineTo(w * 0.88, h * 0.08)
      ..lineTo(w * 0.56, h * 0.22)
      ..close();
    canvas.drawPath(rightEar, blackPaint);

    // Inner pink ears
    final leftInnerEar = Path()
      ..moveTo(w * 0.22, h * 0.38)
      ..lineTo(w * 0.17, h * 0.15)
      ..lineTo(w * 0.38, h * 0.24)
      ..close();
    canvas.drawPath(leftInnerEar, pinkPaint);

    final rightInnerEar = Path()
      ..moveTo(w * 0.78, h * 0.38)
      ..lineTo(w * 0.83, h * 0.15)
      ..lineTo(w * 0.62, h * 0.24)
      ..close();
    canvas.drawPath(rightInnerEar, pinkPaint);

    // 2. Head circle (Black base)
    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.56), width: w * 0.86, height: h * 0.76),
      Radius.circular(w * 0.40),
    );
    canvas.drawRRect(headRect, blackPaint);

    // 3. White Muzzle / Face Blaze (Tuxedo marking)
    final muzzlePath = Path()
      ..moveTo(w * 0.5, h * 0.36)
      ..quadraticBezierTo(w * 0.36, h * 0.46, w * 0.22, h * 0.62)
      ..quadraticBezierTo(w * 0.20, h * 0.86, w * 0.5, h * 0.90)
      ..quadraticBezierTo(w * 0.80, h * 0.86, w * 0.78, h * 0.62)
      ..quadraticBezierTo(w * 0.64, h * 0.46, w * 0.5, h * 0.36)
      ..close();
    canvas.drawPath(muzzlePath, whitePaint);

    // 4. Eyes (Curious big shiny eyes)
    final eyeY = h * 0.50;
    final leftEyeX = w * 0.34;
    final rightEyeX = w * 0.66;
    final eyeRadius = w * 0.11;

    // Eye base (Dark charcoal)
    canvas.drawCircle(Offset(leftEyeX, eyeY), eyeRadius, blackPaint);
    canvas.drawCircle(Offset(rightEyeX, eyeY), eyeRadius, blackPaint);

    // Eye catchlights (Sparkly white reflections)
    final catch1Radius = eyeRadius * 0.44;
    final catch2Radius = eyeRadius * 0.22;
    canvas.drawCircle(Offset(leftEyeX - eyeRadius * 0.25, eyeY - eyeRadius * 0.25), catch1Radius, whitePaint);
    canvas.drawCircle(Offset(leftEyeX + eyeRadius * 0.28, eyeY + eyeRadius * 0.25), catch2Radius, whitePaint);

    canvas.drawCircle(Offset(rightEyeX - eyeRadius * 0.25, eyeY - eyeRadius * 0.25), catch1Radius, whitePaint);
    canvas.drawCircle(Offset(rightEyeX + eyeRadius * 0.28, eyeY + eyeRadius * 0.25), catch2Radius, whitePaint);

    // 5. Blush (Cheeks)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.22, h * 0.66), width: w * 0.16, height: h * 0.10),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.78, h * 0.66), width: w * 0.16, height: h * 0.10),
      blushPaint,
    );

    // 6. Nose (Cute pink rounded triangle)
    final nosePath = Path()
      ..moveTo(w * 0.46, h * 0.61)
      ..lineTo(w * 0.54, h * 0.61)
      ..lineTo(w * 0.50, h * 0.66)
      ..close();
    canvas.drawPath(nosePath, nosePaint);

    // 7. Mouth (Gentle :3 curve)
    final mouthPaint = Paint()
      ..color = const Color(0xFF6A3B39)
      ..strokeWidth = max(1.2, w * 0.035)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final mouthLeft = Path()
      ..moveTo(w * 0.50, h * 0.66)
      ..quadraticBezierTo(w * 0.44, h * 0.74, w * 0.38, h * 0.71);
    final mouthRight = Path()
      ..moveTo(w * 0.50, h * 0.66)
      ..quadraticBezierTo(w * 0.56, h * 0.74, w * 0.62, h * 0.71);
    canvas.drawPath(mouthLeft, mouthPaint);
    canvas.drawPath(mouthRight, mouthPaint);

    // 8. Whiskers
    final whiskerY = h * 0.66;
    // Left whiskers
    canvas.drawLine(Offset(w * 0.20, whiskerY - h * 0.02), Offset(w * 0.04, whiskerY - h * 0.06), whiskerPaint);
    canvas.drawLine(Offset(w * 0.20, whiskerY + h * 0.04), Offset(w * 0.05, whiskerY + h * 0.06), whiskerPaint);
    // Right whiskers
    canvas.drawLine(Offset(w * 0.80, whiskerY - h * 0.02), Offset(w * 0.96, whiskerY - h * 0.06), whiskerPaint);
    canvas.drawLine(Offset(w * 0.80, whiskerY + h * 0.04), Offset(w * 0.95, whiskerY + h * 0.06), whiskerPaint);

    // 9. Optional Crown
    if (hasCrown) {
      final crownPaint = Paint()..color = const Color(0xFFFFD700);
      final crownBorder = Paint()
        ..color = const Color(0xFFE6A800)
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.0, w * 0.03);

      final crownPath = Path()
        ..moveTo(w * 0.34, h * 0.22)
        ..lineTo(w * 0.30, h * 0.08)
        ..lineTo(w * 0.42, h * 0.15)
        ..lineTo(w * 0.50, h * 0.04)
        ..lineTo(w * 0.58, h * 0.15)
        ..lineTo(w * 0.70, h * 0.08)
        ..lineTo(w * 0.66, h * 0.22)
        ..close();

      canvas.drawPath(crownPath, crownPaint);
      canvas.drawPath(crownPath, crownBorder);
    }
  }

  void _paintSilhouette(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..color = silhouetteColor;

    // Ears
    final leftEar = Path()
      ..moveTo(w * 0.18, h * 0.42)
      ..lineTo(w * 0.12, h * 0.08)
      ..lineTo(w * 0.44, h * 0.22)
      ..close();
    canvas.drawPath(leftEar, paint);

    final rightEar = Path()
      ..moveTo(w * 0.82, h * 0.42)
      ..lineTo(w * 0.88, h * 0.08)
      ..lineTo(w * 0.56, h * 0.22)
      ..close();
    canvas.drawPath(rightEar, paint);

    // Head
    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.56), width: w * 0.86, height: h * 0.76),
      Radius.circular(w * 0.40),
    );
    canvas.drawRRect(headRect, paint);
  }

  @override
  bool shouldRepaint(covariant _CatFacePainter oldDelegate) {
    return oldDelegate.hasCrown != hasCrown ||
        oldDelegate.isSilhouette != isSilhouette ||
        oldDelegate.silhouetteColor != silhouetteColor;
  }
}

