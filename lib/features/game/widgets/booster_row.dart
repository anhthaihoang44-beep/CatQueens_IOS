import 'package:flutter/material.dart';
import '../../../core/audio/sound_service.dart';
import 'cat_face_widget.dart';

class BoosterRow extends StatelessWidget {
  final int autoPlaceCount;
  final int hintCount;
  final VoidCallback onAutoPlace;
  final VoidCallback onHint;
  final VoidCallback onUndoLocked;

  const BoosterRow({
    super.key,
    required this.autoPlaceCount,
    required this.hintCount,
    required this.onAutoPlace,
    required this.onHint,
    required this.onUndoLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // AutoPlace booster
          _buildBoosterButton(
            iconWidget: const CatFaceWidget(size: 28),
            badgeCount: autoPlaceCount,
            label: 'Auto Place',
            onTap: () {
              SoundService.playClick();
              onAutoPlace();
            },
          ),

          // Hint booster
          _buildBoosterButton(
            iconText: '💡',
            badgeCount: hintCount,
            label: 'Hint',
            onTap: () {
              SoundService.playClick();
              onHint();
            },
          ),

          // Locked booster (Lv.21)
          _buildLockedButton(
            lockText: 'Lv.21',
            label: 'Undo',
            onTap: () {
              SoundService.playError();
              onUndoLocked();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBoosterButton({
    String? iconText,
    Widget? iconWidget,
    required int badgeCount,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 3,
              shadowColor: Colors.black.withValues(alpha: 0.12),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  child: iconWidget ??
                      Text(
                        iconText ?? '',
                        style: const TextStyle(fontSize: 26),
                      ),
                ),
              ),
            ),
            // Count badge
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0932B), // Main Orange
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8B5E3C),
          ),
        ),
      ],
    );
  }

  Widget _buildLockedButton({
    required String lockText,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: const Color(0xFFEEEEEE),
          shape: const CircleBorder(),
          elevation: 1,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 58,
              height: 58,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_rounded, size: 18, color: Colors.grey),
                  const SizedBox(height: 2),
                  Text(
                    lockText,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

