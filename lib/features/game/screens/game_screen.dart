import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/screens/settings_screen.dart';
import '../controllers/game_controller.dart';
import '../models/game_state.dart';
import '../widgets/board_widget.dart';
import '../widgets/booster_row.dart';
import '../widgets/cat_progress_bar.dart';
import '../widgets/game_header.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/rule_cards.dart';
import '../widgets/win_dialog.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int initialLevel;
  final VoidCallback? onBackToHome;

  const GameScreen({
    super.key,
    this.initialLevel = 1,
    this.onBackToHome,
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late int _currentLevel;
  bool _dialogShowing = false;

  static const List<Color> regionColors = [
    Color(0xFFE5BB43), // Gold
    Color(0xFFF8B4D0), // Pink
    Color(0xFF6BBBE8), // Sky Blue
    Color(0xFFA9D893), // Mint Green
    Color(0xFFC3A6F5), // Lavender
    Color(0xFFF4A76B), // Peach
    Color(0xFF6ECFC3), // Teal
    Color(0xFFE88FA0), // Rose
    Color(0xFFF5E27A), // Butter
  ];

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.initialLevel;
  }

  void _checkDialogs(BuildContext context, GameState state, GameController controller) {
    if (_dialogShowing) return;

    if (state.status == GameStatus.won) {
      _dialogShowing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => WinDialog(
            levelNumber: _currentLevel,
            score: state.score,
            elapsedTime: state.elapsedTime,
            onNextLevel: () {
              Navigator.of(ctx).pop();
              _dialogShowing = false;
              setState(() => _currentLevel++);
            },
            onReplay: () {
              Navigator.of(ctx).pop();
              _dialogShowing = false;
              controller.restartLevel();
            },
          ),
        );
      });
    } else if (state.status == GameStatus.lost) {
      _dialogShowing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => GameOverDialog(
            levelNumber: _currentLevel,
            onRetry: () {
              Navigator.of(ctx).pop();
              _dialogShowing = false;
              controller.restartLevel();
            },
            onHome: () {
              Navigator.of(ctx).pop();
              _dialogShowing = false;
              if (widget.onBackToHome != null) {
                widget.onBackToHome!();
              } else if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameControllerProvider(_currentLevel));
    final controller = ref.read(gameControllerProvider(_currentLevel).notifier);

    ref.listen<GameState>(gameControllerProvider(_currentLevel), (prev, next) {
      _checkDialogs(context, next, controller);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F1EC), // Cozy Cream
      body: SafeArea(
        child: Column(
          children: [
            // Header
            GameHeader(
              levelNumber: _currentLevel,
              score: state.score,
              lives: state.lives,
              maxLives: state.maxLives,
              onBack: () {
                if (widget.onBackToHome != null) {
                  widget.onBackToHome!();
                } else if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              onSettings: () => _showQuickSettings(context, controller, state),
            ),

            // 3 Rule Cards
            const RuleCards(),

            // Cat Progress Bar (N cat heads corresponding to N regions)
            CatProgressBar(
              n: state.level.n,
              completedRegions: state.completedRegions,
              regionColors: regionColors,
            ),

            // Optional Hint Banner
            if (state.hintExplanation != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFB74D)),
                ),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.hintExplanation!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Main Board Grid
            Expanded(
              child: BoardWidget(
                state: state,
                regionColors: regionColors,
                showPattern: ref.watch(patternSettingsProvider),
                onTapCell: (pos) => controller.tapCell(pos),
                onDoubleTapCell: (pos) => controller.doubleTapCell(pos),
                onDragCell: (pos) => controller.dragMarkX(pos),
              ),
            ),

            // Bottom Booster Row
            BoosterRow(
              autoPlaceCount: state.autoPlaceRemaining,
              hintCount: state.hintsRemaining,
              onAutoPlace: () {
                final success = controller.useAutoPlace();
                if (!success && state.autoPlaceRemaining <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No Auto Place boosters remaining!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              onHint: () {
                final success = controller.useHint();
                if (!success && state.hintsRemaining <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No Hint boosters remaining!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              onUndoLocked: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Undo booster unlocks at Level 21'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickSettings(
    BuildContext context,
    GameController controller,
    GameState state,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool autoX = state.autoXAfterQueen;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F1EC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Game Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5E3C),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text(
                      'Auto-fill X',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8B5E3C),
                      ),
                    ),
                    subtitle: const Text(
                      'Automatically cross out invalid cells when placing a cat',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: autoX,
                    activeThumbColor: const Color(0xFFF0932B),
                    onChanged: (val) {
                      setSheetState(() => autoX = val);
                      controller.toggleAutoX(val);
                    },
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final isPattern = ref.watch(patternSettingsProvider);
                      return SwitchListTile(
                        title: const Text(
                          'Pattern Mode',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B5E3C),
                          ),
                        ),
                        subtitle: const Text(
                          'Colorblind friendly region patterns on board',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: isPattern,
                        activeThumbColor: const Color(0xFFF0932B),
                        onChanged: (val) {
                          ref.read(patternSettingsProvider.notifier).state = val;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8B5E3C),
                        side: const BorderSide(color: Color(0xFF8B5E3C)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        controller.restartLevel();
                      },
                      child: const Text('Replay This Level'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
