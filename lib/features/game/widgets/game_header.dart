import 'package:flutter/material.dart';

class GameHeader extends StatelessWidget {
  final int levelNumber;
  final int score;
  final int lives;
  final int maxLives;
  final VoidCallback onBack;
  final VoidCallback onSettings;

  const GameHeader({
    super.key,
    required this.levelNumber,
    required this.score,
    required this.lives,
    required this.maxLives,
    required this.onBack,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          _buildCircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: onBack,
          ),

          // Level & Score with Sparkle Animation
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Level $levelNumber',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF8B5E3C),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    key: ValueKey(score),
                    tween: Tween(begin: 1.25, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Text(
                          'Score $score',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 2),
                  const Text('✨', style: TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),

          // Lives pill (Golden fish cracker biscuits)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(maxLives, (index) {
                final isAlive = index < lives;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: AnimatedScale(
                    scale: isAlive ? 1.0 : 0.85,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: Opacity(
                      opacity: isAlive ? 1.0 : 0.25,
                      child: const _FishBiscuitWidget(size: 16),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Settings button
          _buildCircleButton(
            icon: Icons.settings_rounded,
            onTap: onSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF8B5E3C),
          ),
        ),
      ),
    );
  }
}

/// Adorable vector golden fish biscuit (Taiyaki style) matching the video.
class _FishBiscuitWidget extends StatelessWidget {
  final double size;

  const _FishBiscuitWidget({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.3,
      height: size,
      child: CustomPaint(
        painter: _FishBiscuitPainter(),
      ),
    );
  }
}

class _FishBiscuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fishPaint = Paint()..color = const Color(0xFFFFB300);
    final borderPaint = Paint()
      ..color = const Color(0xFFE68A00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final eyePaint = Paint()..color = const Color(0xFF4E342E);

    // Fish body + tail path
    final path = Path()
      ..moveTo(w * 0.15, h * 0.5) // Mouth
      ..quadraticBezierTo(w * 0.35, h * 0.05, w * 0.70, h * 0.30) // Upper back
      ..lineTo(w * 0.95, h * 0.10) // Upper tail fin
      ..quadraticBezierTo(w * 0.85, h * 0.50, w * 0.95, h * 0.90) // Tail notch
      ..lineTo(w * 0.70, h * 0.70) // Lower tail fin
      ..quadraticBezierTo(w * 0.35, h * 0.95, w * 0.15, h * 0.5) // Belly to mouth
      ..close();

    canvas.drawPath(path, fishPaint);
    canvas.drawPath(path, borderPaint);

    // Eye
    canvas.drawCircle(Offset(w * 0.30, h * 0.40), w * 0.05, eyePaint);

    // Cute smile
    final smilePaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(w * 0.18, h * 0.55)
      ..quadraticBezierTo(w * 0.24, h * 0.65, w * 0.28, h * 0.58);
    canvas.drawPath(smilePath, smilePaint);

    // Fin detail
    final finPath = Path()
      ..moveTo(w * 0.48, h * 0.50)
      ..quadraticBezierTo(w * 0.56, h * 0.65, w * 0.46, h * 0.70);
    canvas.drawPath(finPath, smilePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
