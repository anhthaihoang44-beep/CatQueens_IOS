import 'package:flutter/material.dart';
import 'cat_face_widget.dart';

class CatProgressBar extends StatelessWidget {
  final int n;
  final Set<int> completedRegions;
  final List<Color> regionColors;

  const CatProgressBar({
    super.key,
    required this.n,
    required this.completedRegions,
    required this.regionColors,
  });

  @override
  Widget build(BuildContext context) {
    final double catSize = n <= 5 ? 26 : n <= 7 ? 20 : 15;
    final double horizontalMargin = n >= 8 ? 10 : 20;
    final double horizontalPadding = n >= 8 ? 6 : 14;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 4),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(n, (regionIdx) {
          final isCompleted = completedRegions.contains(regionIdx);
          final color = regionColors[regionIdx % regionColors.length];

          return AnimatedScale(
            scale: isCompleted ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.elasticOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.all(n >= 8 ? 3 : 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? color.withValues(alpha: 0.28)
                    : Colors.grey.withValues(alpha: 0.08),
                border: Border.all(
                  color: isCompleted ? color : Colors.grey.withValues(alpha: 0.3),
                  width: isCompleted ? 2.2 : 1.0,
                ),
                boxShadow: isCompleted
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: isCompleted
                  ? CatFaceWidget(size: catSize)
                  : CatFaceWidget(
                      size: catSize,
                      isSilhouette: true,
                      silhouetteColor: color.withValues(alpha: 0.4),
                    ),
            ),
          );
        }),
      ),
    );
  }
}
