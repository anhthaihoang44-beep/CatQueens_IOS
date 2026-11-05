import 'dart:math';
import 'package:flutter/material.dart';

/// Animated sparkle burst and floating score overlay when a queen is successfully placed.
class SparkleBurstEffect extends StatefulWidget {
  final Offset center;
  final String scoreText;
  final VoidCallback? onComplete;

  const SparkleBurstEffect({
    super.key,
    required this.center,
    this.scoreText = '+100',
    this.onComplete,
  });

  @override
  State<SparkleBurstEffect> createState() => _SparkleBurstEffectState();
}

class _SparkleBurstEffectState extends State<SparkleBurstEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_StarParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    final rng = Random();
    _particles = List.generate(10, (index) {
      final angle = (index / 10) * 2 * pi + rng.nextDouble() * 0.4;
      final speed = 35.0 + rng.nextDouble() * 45.0;
      final size = 10.0 + rng.nextDouble() * 12.0;
      final color = index % 3 == 0
          ? Colors.white
          : index % 3 == 1
              ? const Color(0xFFFFD54F)
              : const Color(0xFFFFB300);
      return _StarParticle(
        angle: angle,
        speed: speed,
        size: size,
        color: color,
        rotationSpeed: (rng.nextDouble() - 0.5) * 4,
      );
    });

    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final fadeOut = (1.0 - t).clamp(0.0, 1.0);
        final scoreOffsetY = -50.0 * Curves.easeOutCubic.transform(t);
        final scoreScale = 0.5 + 0.8 * Curves.elasticOut.transform((t * 2.0).clamp(0.0, 1.0));

        return Stack(
          children: [
            // 1. Star Particles
            CustomPaint(
              size: Size.infinite,
              painter: _SparklesPainter(
                center: widget.center,
                progress: t,
                particles: _particles,
              ),
            ),

            // 2. Floating score popup
            Positioned(
              left: widget.center.dx - 40,
              top: widget.center.dy + scoreOffsetY - 20,
              child: Opacity(
                opacity: (fadeOut * 1.5).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: scoreScale,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB300).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.scoreText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE65100),
                        shadows: [
                          Shadow(
                            color: Colors.white,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StarParticle {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  final double rotationSpeed;

  _StarParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotationSpeed,
  });
}

class _SparklesPainter extends CustomPainter {
  final Offset center;
  final double progress;
  final List<_StarParticle> particles;

  _SparklesPainter({
    required this.center,
    required this.progress,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress;
    final ease = Curves.easeOutCubic.transform(t);
    final alpha = (1.0 - t).clamp(0.0, 1.0);

    for (final p in particles) {
      final dist = p.speed * ease;
      final px = center.dx + cos(p.angle) * dist;
      final py = center.dy + sin(p.angle) * dist;
      final currentSize = p.size * (1.0 - t * 0.4);

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.angle + p.rotationSpeed * t);

      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      // Draw 4-pointed sparkle star
      final star = Path();
      final r = currentSize * 0.5;
      final inner = r * 0.28;

      for (int i = 0; i < 4; i++) {
        final a1 = (i * pi / 2);
        final a2 = a1 + (pi / 4);
        if (i == 0) {
          star.moveTo(cos(a1) * r, sin(a1) * r);
        } else {
          star.lineTo(cos(a1) * r, sin(a1) * r);
        }
        star.lineTo(cos(a2) * inner, sin(a2) * inner);
      }
      star.close();
      canvas.drawPath(star, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SparklesPainter oldDelegate) => true;
}

