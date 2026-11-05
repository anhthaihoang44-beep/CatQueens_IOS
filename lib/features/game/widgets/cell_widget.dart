import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/level/cell_pos.dart';
import '../models/cell_mark.dart';
import 'cat_face_widget.dart';
import 'region_pattern_painter.dart';
import 'rounded_cross_widget.dart';

class CellWidget extends StatefulWidget {
  final CellPos pos;
  final int n;
  final Color regionColor;
  final CellMark mark;
  final bool isGiven;
  final bool isError;
  final bool isSuccess;
  final bool isHighlighted;
  final int regionIndex;
  final bool showPattern;

  const CellWidget({
    super.key,
    required this.pos,
    required this.n,
    required this.regionColor,
    required this.mark,
    required this.isGiven,
    required this.isError,
    required this.isSuccess,
    required this.isHighlighted,
    this.regionIndex = 0,
    this.showPattern = false,
  });

  @override
  State<CellWidget> createState() => _CellWidgetState();
}

class _CellWidgetState extends State<CellWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    if (widget.isError) {
      _triggerShake();
    }
  }

  @override
  void didUpdateWidget(covariant CellWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isError && !oldWidget.isError) {
      _triggerShake();
    }
  }

  void _triggerShake() {
    HapticFeedback.heavyImpact();
    _animController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double radius = widget.n <= 5
        ? 12.0
        : widget.n <= 7
            ? 10.0
            : 7.0;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        // Horizontal shake
        double dx = 0.0;
        if (_animController.isAnimating) {
          dx = sin(_animController.value * 5 * pi) * (1.0 - _animController.value) * 8.0;
        }

        return Transform.translate(
          offset: Offset(dx, 0),
          child: child,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: widget.isError
              ? const Color(0xFFFFCDD2)
              : widget.regionColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: widget.isError
                ? const Color(0xFFD32F2F)
                : widget.isHighlighted
                    ? const Color(0xFFFF9800)
                    : Colors.white.withValues(alpha: 0.35),
            width: widget.isError || widget.isHighlighted ? 2.5 : 1.2,
          ),
          boxShadow: widget.isHighlighted
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.6),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : widget.isError
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD32F2F).withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.showPattern)
                CustomPaint(
                  painter: RegionPatternPainter(
                    regionIndex: widget.regionIndex,
                  ),
                ),
              Center(
                child: _buildMarkContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildMarkContent() {
    if (widget.mark == CellMark.queen) {
      final double catSize = widget.n <= 5
          ? 38
          : widget.n <= 7
              ? 30
              : 24;

      return TweenAnimationBuilder<double>(
        key: ValueKey('queen_${widget.pos.row}_${widget.pos.col}'),
        tween: Tween(begin: 0.2, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: CatFaceWidget(
              size: catSize,
              hasCrown: widget.isGiven,
            ),
          );
        },
      );
    }

    if (widget.mark == CellMark.xMark) {
      final double xSize = widget.n <= 5
          ? 26
          : widget.n <= 7
              ? 20
              : 16;

      return TweenAnimationBuilder<double>(
        key: ValueKey('manual_x_${widget.pos.row}_${widget.pos.col}'),
        tween: Tween(begin: 0.3, end: 1.0),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: RoundedCrossWidget(
              color: const Color(0xFFFF6E40), // Bold orange X for manual tap
              size: xSize,
            ),
          );
        },
      );
    }

    if (widget.mark == CellMark.autoXMark) {
      final double xSize = widget.n <= 5
          ? 26
          : widget.n <= 7
              ? 20
              : 16;

      return TweenAnimationBuilder<double>(
        key: ValueKey('auto_x_${widget.pos.row}_${widget.pos.col}'),
        tween: Tween(begin: 0.2, end: 1.0),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: RoundedCrossWidget(
              color: Colors.white, // Crisp bold white X for auto-fill
              size: xSize,
            ),
          );
        },
      );
    }

    return null;
  }
}
