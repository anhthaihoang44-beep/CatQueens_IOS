import 'dart:math';
import 'package:flutter/material.dart';

class RegionPatternPainter extends CustomPainter {
  final int regionIndex;
  final Color patternColor;

  const RegionPatternPainter({
    required this.regionIndex,
    this.patternColor = const Color(0x60FFFFFF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pattern = regionIndex % 9;
    final paint = Paint()
      ..color = patternColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = patternColor
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Clip to cell bounds
    canvas.clipRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(8),
    ));

    switch (pattern) {
      case 0:
        // Polka Dots (3x3 grid)
        const rows = 3;
        const cols = 3;
        final dx = w / (cols + 1);
        final dy = h / (rows + 1);
        final r = max(1.8, w * 0.05);
        for (int rIdx = 1; rIdx <= rows; rIdx++) {
          for (int cIdx = 1; cIdx <= cols; cIdx++) {
            canvas.drawCircle(Offset(cIdx * dx, rIdx * dy), r, fillPaint);
          }
        }
        break;

      case 1:
        // Diagonal Stripes ///
        final step = max(8.0, w / 4);
        for (double d = -w; d <= w + h; d += step) {
          canvas.drawLine(Offset(d, 0), Offset(d + h, h), paint);
        }
        break;

      case 2:
        // Grid / Plaid
        final step = max(9.0, w / 3.5);
        for (double x = step; x < w; x += step) {
          canvas.drawLine(Offset(x, 0), Offset(x, h), paint);
        }
        for (double y = step; y < h; y += step) {
          canvas.drawLine(Offset(0, y), Offset(w, y), paint);
        }
        break;

      case 3:
        // Wave lines
        final path1 = Path();
        final path2 = Path();
        final y1 = h * 0.35;
        final y2 = h * 0.65;
        path1.moveTo(0, y1);
        path2.moveTo(0, y2);
        for (double x = 0; x <= w; x += 1) {
          final sine1 = sin((x / w) * 2 * pi * 2) * (h * 0.08);
          final sine2 = sin((x / w) * 2 * pi * 2) * (h * 0.08);
          path1.lineTo(x, y1 + sine1);
          path2.lineTo(x, y2 + sine2);
        }
        canvas.drawPath(path1, paint);
        canvas.drawPath(path2, paint);
        break;

      case 4:
        // Triangles
        final triSize = max(5.0, w * 0.16);
        void drawTri(double cx, double cy) {
          final path = Path()
            ..moveTo(cx, cy - triSize / 2)
            ..lineTo(cx + triSize / 2, cy + triSize / 2)
            ..lineTo(cx - triSize / 2, cy + triSize / 2)
            ..close();
          canvas.drawPath(path, paint);
        }
        drawTri(w * 0.3, h * 0.35);
        drawTri(w * 0.7, h * 0.35);
        drawTri(w * 0.5, h * 0.75);
        break;

      case 5:
        // Horizontal parallel lines
        final step = h / 4;
        for (int i = 1; i <= 3; i++) {
          final y = i * step;
          canvas.drawLine(Offset(w * 0.15, y), Offset(w * 0.85, y), paint..strokeWidth = 2.0);
        }
        break;

      case 6:
        // Diamonds
        final dSize = max(4.5, w * 0.13);
        void drawDiamond(double cx, double cy) {
          final path = Path()
            ..moveTo(cx, cy - dSize)
            ..lineTo(cx + dSize, cy)
            ..lineTo(cx, cy + dSize)
            ..lineTo(cx - dSize, cy)
            ..close();
          canvas.drawPath(path, paint);
        }
        drawDiamond(w * 0.5, h * 0.28);
        drawDiamond(w * 0.26, h * 0.72);
        drawDiamond(w * 0.74, h * 0.72);
        break;

      case 7:
        // Mini Plus / Crosses +
        final pSize = max(3.5, w * 0.1);
        void drawPlus(double cx, double cy) {
          canvas.drawLine(Offset(cx - pSize, cy), Offset(cx + pSize, cy), paint..strokeWidth = 2.0);
          canvas.drawLine(Offset(cx, cy - pSize), Offset(cx, cy + pSize), paint..strokeWidth = 2.0);
        }
        drawPlus(w * 0.32, h * 0.35);
        drawPlus(w * 0.68, h * 0.35);
        drawPlus(w * 0.5, h * 0.72);
        break;

      case 8:
        // Concentric Circles
        canvas.drawCircle(Offset(w / 2, h / 2), w * 0.15, paint);
        canvas.drawCircle(Offset(w / 2, h / 2), w * 0.32, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant RegionPatternPainter oldDelegate) {
    return oldDelegate.regionIndex != regionIndex || oldDelegate.patternColor != patternColor;
  }
}

