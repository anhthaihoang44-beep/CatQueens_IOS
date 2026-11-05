import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/audio/sound_service.dart';
import 'cat_face_widget.dart';

/// Full-screen victory celebration dialog faithfully matching the MeowDoku video (frame 116s).
class WinDialog extends StatefulWidget {
  final int levelNumber;
  final int score;
  final Duration elapsedTime;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;

  const WinDialog({
    super.key,
    required this.levelNumber,
    required this.score,
    required this.elapsedTime,
    required this.onNextLevel,
    required this.onReplay,
  });

  @override
  State<WinDialog> createState() => _WinDialogState();
}

class _WinDialogState extends State<WinDialog>
    with TickerProviderStateMixin {
  late AnimationController _raysController;
  late AnimationController _popController;
  late AnimationController _confettiController;
  late List<_ConfettiPiece> _confetti;

  @override
  void initState() {
    super.initState();
    SoundService.playWin();
    // 1. Rotating sunburst rays
    _raysController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // 2. Pop-in bounce (default value: 1.0 for instant interaction)
    _popController = AnimationController(
      vsync: this,
      value: 1.0,
      duration: const Duration(milliseconds: 700),
    );

    // 3. Falling confetti
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    final rng = Random();
    final colors = [
      const Color(0xFFFF5252),
      const Color(0xFF448AFF),
      const Color(0xFFFFD740),
      const Color(0xFF69F0AE),
      const Color(0xFFFF7043),
      const Color(0xFFE040FB),
    ];

    _confetti = List.generate(40, (index) {
      return _ConfettiPiece(
        x: rng.nextDouble(),
        speed: 0.3 + rng.nextDouble() * 0.7,
        size: 7.0 + rng.nextDouble() * 7.0,
        color: colors[index % colors.length],
        rotation: rng.nextDouble() * 2 * pi,
        rotationSpeed: (rng.nextDouble() - 0.5) * 6,
        swingFreq: 2.0 + rng.nextDouble() * 3.0,
        swingAmp: 0.05 + rng.nextDouble() * 0.08,
      );
    });
  }

  @override
  void dispose() {
    _raysController.dispose();
    _popController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextLevel = widget.levelNumber + 1;
    final minutes = widget.elapsedTime.inMinutes;
    final seconds = widget.elapsedTime.inSeconds % 60;
    final timeStr = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. Rotating Sunburst Rays behind everything
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _raysController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _raysController.value * 2 * pi,
                  child: CustomPaint(
                    size: const Size(420, 420),
                    painter: _SunburstPainter(
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.22),
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Falling Confetti Canvas
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ConfettiPainter(
                      progress: _confettiController.value,
                      confetti: _confetti,
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. Central Celebration Card
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _popController,
              curve: Curves.elasticOut,
            ),
            child: Container(
              width: 320,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFFFFE0B2), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.20),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.15),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  // Title: "Awesome!"
                  _buildBubbleTitle('Awesome!'),
                  const SizedBox(height: 12),

                  // Cheering Cat Illustration with Stars
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Golden Glow ring
                        Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFFFE082).withValues(alpha: 0.8),
                                const Color(0xFFFFCA28).withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                        // Cheering Cat Head
                        const CatFaceWidget(size: 88, hasCrown: true),
                        // Thumbs up / sparkles
                        const Positioned(
                          right: 0,
                          top: 10,
                          child: Text('✨', style: TextStyle(fontSize: 22)),
                        ),
                        const Positioned(
                          left: 2,
                          bottom: 12,
                          child: Text('👍', style: TextStyle(fontSize: 24)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Celebratory Witty Quote
                  const Text(
                    'Tricky puzzle, but you\nsolved it beautifully!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF8D5B4C),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Score & Time Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFCC80)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Score', '+${widget.score}', const Color(0xFFE65100)),
                        Container(width: 1.5, height: 26, color: const Color(0xFFFFCC80)),
                        _buildStat('Time', timeStr, const Color(0xFF5C6BC0)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Big Orange Next Level Button (matching the video)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(0xFFFF9800).withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: () {
                        SoundService.playClick();
                        widget.onNextLevel();
                      },
                      child: const Text(
                        'Next Level',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Replay text button
                  TextButton.icon(
                    onPressed: () {
                      SoundService.playClick();
                      widget.onReplay();
                    },
                    icon: const Icon(Icons.replay_rounded, size: 18, color: Color(0xFF9E9E9E)),
                    label: const Text(
                      'Replay',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildBubbleTitle(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: Color(0xFFFF9800),
        shadows: [
          Shadow(offset: Offset(0, 3), blurRadius: 4, color: Color(0xFFBF360C)),
          Shadow(offset: Offset(0, -1), blurRadius: 1, color: Colors.white),
          Shadow(offset: Offset(1, 0), blurRadius: 1, color: Colors.white),
          Shadow(offset: Offset(-1, 0), blurRadius: 1, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF8D6E63),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SunburstPainter extends CustomPainter {
  final Color color;

  _SunburstPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const count = 16;
    final sweep = (2 * pi) / count;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < count; i += 2) {
      final startAngle = i * sweep;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweep,
          false,
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunburstPainter oldDelegate) => false;
}

class _ConfettiPiece {
  final double x;
  final double speed;
  final double size;
  final Color color;
  final double rotation;
  final double rotationSpeed;
  final double swingFreq;
  final double swingAmp;

  _ConfettiPiece({
    required this.x,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.swingFreq,
    required this.swingAmp,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiPiece> confetti;

  _ConfettiPainter({required this.progress, required this.confetti});

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in confetti) {
      final y = ((progress * c.speed + c.x) % 1.0) * (size.height + 40) - 20;
      final x = (c.x + sin(progress * 2 * pi * c.swingFreq) * c.swingAmp) * size.width;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(c.rotation + progress * 2 * pi * c.rotationSpeed);

      final paint = Paint()..color = c.color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: c.size, height: c.size * 0.55),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
