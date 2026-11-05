import 'package:flutter/material.dart';
import '../../../core/audio/sound_service.dart';
import '../../../domain/level/cell_pos.dart';
import '../models/game_state.dart';
import 'cell_widget.dart';
import 'sparkle_burst_effect.dart';

class BoardWidget extends StatefulWidget {
  final GameState state;
  final List<Color> regionColors;
  final void Function(CellPos pos) onTapCell;
  final void Function(CellPos pos) onDoubleTapCell;
  final void Function(CellPos pos) onDragCell;
  final bool showPattern;

  const BoardWidget({
    super.key,
    required this.state,
    required this.regionColors,
    required this.onTapCell,
    required this.onDoubleTapCell,
    required this.onDragCell,
    this.showPattern = false,
  });

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  CellPos? _lastDraggedCell;
  DateTime? _lastTapTime;
  CellPos? _lastTappedCell;

  // Active sparkle bursts
  final List<_ActiveBurst> _activeBursts = [];
  bool _showGreatBanner = false;

  @override
  void didUpdateWidget(covariant BoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.lastSuccessCell != null &&
        widget.state.lastSuccessCell != oldWidget.state.lastSuccessCell) {
      _triggerSuccessBurst(widget.state.lastSuccessCell!);
    }
  }

  void _triggerSuccessBurst(CellPos pos) {
    setState(() {
      _activeBursts.add(_ActiveBurst(id: DateTime.now().millisecondsSinceEpoch, pos: pos));
      _showGreatBanner = true;
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() => _showGreatBanner = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.state.level.n;

    return Center(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double boardWidth = constraints.maxWidth;
                final double cellSpacing = n <= 5 ? 6.0 : n <= 7 ? 4.5 : 3.0;
                final double totalSpacing = cellSpacing * (n - 1);
                final double cellSize = (boardWidth - totalSpacing) / n;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Main Grid
                    GestureDetector(
                      onPanStart: (details) {
                        _handleDrag(details.localPosition, cellSize, cellSpacing, n);
                      },
                      onPanUpdate: (details) {
                        _handleDrag(details.localPosition, cellSize, cellSpacing, n);
                      },
                      onPanEnd: (_) {
                        _lastDraggedCell = null;
                      },
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: n,
                          mainAxisSpacing: cellSpacing,
                          crossAxisSpacing: cellSpacing,
                        ),
                        itemCount: n * n,
                        itemBuilder: (context, index) {
                          final pos = CellPos.fromIndex(index, n);
                          final reg = widget.state.level.getRegionAt(pos);
                          final color = widget.regionColors[reg % widget.regionColors.length];
                          final mark = widget.state.getMarkAt(pos);
                          final isGiven = widget.state.isGiven(pos);
                          final isError = widget.state.lastErrorCell == pos;
                          final isSuccess = widget.state.lastSuccessCell == pos;
                          final isHighlighted = widget.state.highlightedCell == pos;

                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _handleTap(pos),
                            child: CellWidget(
                              key: ValueKey('cell_${pos.row}_${pos.col}_${widget.state.errorKey}'),
                              pos: pos,
                              n: n,
                              regionColor: color,
                              regionIndex: reg,
                              showPattern: widget.showPattern,
                              mark: mark,
                              isGiven: isGiven,
                              isError: isError,
                              isSuccess: isSuccess,
                              isHighlighted: isHighlighted,
                            ),
                          );
                        },
                      ),
                    ),

                    // Particle Sparkle Bursts
                    ..._activeBursts.map((burst) {
                      final cx = burst.pos.col * (cellSize + cellSpacing) + cellSize / 2;
                      final cy = burst.pos.row * (cellSize + cellSpacing) + cellSize / 2;
                      return Positioned.fill(
                        key: ValueKey('burst_${burst.id}'),
                        child: SparkleBurstEffect(
                          center: Offset(cx, cy),
                          scoreText: '+${widget.state.status == GameStatus.won ? 864 : 100}',
                          onComplete: () {
                            if (mounted) {
                              setState(() {
                                _activeBursts.removeWhere((b) => b.id == burst.id);
                              });
                            }
                          },
                        ),
                      );
                    }),

                    // Floating "Great" / "Tuyệt!" Banner (like frame 110s)
                    if (_showGreatBanner)
                      Positioned(
                        top: -14,
                        right: 8,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.elasticOut,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('✨ ', style: TextStyle(fontSize: 12)),
                                    Text(
                                      'Great!',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(CellPos pos) {
    final now = DateTime.now();
    if (_lastTappedCell == pos &&
        _lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 320)) {
      // Double tap detected!
      _lastTapTime = null;
      _lastTappedCell = null;
      widget.onDoubleTapCell(pos);
    } else {
      // First tap: trigger single tap action
      _lastTapTime = now;
      _lastTappedCell = pos;
      SoundService.playTap();
      widget.onTapCell(pos);
    }
  }

  void _handleDrag(
    Offset localPosition,
    double cellSize,
    double cellSpacing,
    int n,
  ) {
    final step = cellSize + cellSpacing;
    final c = (localPosition.dx / step).floor();
    final r = (localPosition.dy / step).floor();

    if (r >= 0 && r < n && c >= 0 && c < n) {
      final pos = CellPos(r, c);
      if (_lastDraggedCell != pos) {
        _lastDraggedCell = pos;
        SoundService.playTap();
        widget.onDragCell(pos);
      }
    }
  }
}

class _ActiveBurst {
  final int id;
  final CellPos pos;

  _ActiveBurst({required this.id, required this.pos});
}
