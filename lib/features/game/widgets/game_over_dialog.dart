import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  final int levelNumber;
  final VoidCallback onRetry;
  final VoidCallback? onHome;

  const GameOverDialog({
    super.key,
    required this.levelNumber,
    required this.onRetry,
    this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F1EC),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😿', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            const Text(
              'Out of Lives!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B5E3C),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Don\'t give up! You can retry and solve this puzzle.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9A5B5B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // Retry button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0932B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                onPressed: onRetry,
                icon: const Icon(Icons.replay_rounded, size: 22),
                label: const Text(
                  'Try Again',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (onHome != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8B5E3C),
                    side: const BorderSide(color: Color(0xFF8B5E3C), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: onHome,
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
