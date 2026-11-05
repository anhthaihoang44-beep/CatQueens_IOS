import 'package:flutter/material.dart';
import 'cat_face_widget.dart';
import 'rounded_cross_widget.dart';

class RuleCards extends StatelessWidget {
  const RuleCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(child: _buildCard('1 cat per color', _buildMiniGridColor())),
          const SizedBox(width: 8),
          Expanded(child: _buildCard('1 cat per row & col', _buildMiniGridRowCol())),
          const SizedBox(width: 8),
          Expanded(child: _buildCard('Cats cannot touch', _buildMiniGridNoTouch())),
        ],
      ),
    );
  }

  Widget _buildCard(String text, Widget miniGrid) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          miniGrid,
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8B5E3C),
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniGridColor() {
    return _build3x3(
      centerWidget: const CatFaceWidget(size: 9),
      centerColor: const Color(0xFFF8B4D0),
      otherColor: const Color(0xFF6BBBE8),
    );
  }

  Widget _buildMiniGridRowCol() {
    return _build3x3(
      centerWidget: const CatFaceWidget(size: 9),
      centerColor: const Color(0xFFE5BB43),
      otherWidget: const RoundedCrossWidget(color: Colors.white, size: 7, strokeRatio: 0.3),
    );
  }

  Widget _buildMiniGridNoTouch() {
    return _build3x3(
      centerWidget: const CatFaceWidget(size: 9),
      centerColor: const Color(0xFFA9D893),
      otherWidget: const RoundedCrossWidget(color: Color(0xFFFF6E40), size: 7, strokeRatio: 0.3),
    );
  }

  Widget _build3x3({
    Widget? centerWidget,
    Color? centerColor,
    Color? otherColor,
    Widget? otherWidget,
  }) {
    return SizedBox(
      width: 38,
      height: 38,
      child: GridView.count(
        crossAxisCount: 3,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        children: List.generate(9, (index) {
          final isCenter = index == 4;
          return Container(
            decoration: BoxDecoration(
              color: isCenter
                  ? (centerColor ?? const Color(0xFFF0932B))
                  : (otherColor ?? const Color(0xFFE0D7CE)),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Center(
              child: isCenter ? centerWidget : otherWidget,
            ),
          );
        }),
      ),
    );
  }
}
