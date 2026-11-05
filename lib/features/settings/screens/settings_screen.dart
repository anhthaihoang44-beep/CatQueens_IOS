import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/audio/sound_service.dart';
import '../../../core/theme/app_theme.dart';

final musicSettingsProvider = StateProvider<bool>((ref) => true);
final sfxSettingsProvider = StateProvider<bool>((ref) => true);
final catVoiceSettingsProvider = StateProvider<bool>((ref) => true);
final hapticSettingsProvider = StateProvider<bool>((ref) => true);
final patternSettingsProvider = StateProvider<bool>((ref) => true);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget buildSwitch(String label, String subtitle, StateProvider<bool> provider, IconData icon) {
      final value = ref.watch(provider);
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SwitchListTile(
          secondary: Icon(icon, color: AppColors.primary),
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          value: value,
          activeThumbColor: AppColors.primary,
          onChanged: (newVal) {
            ref.read(provider.notifier).state = newVal;
            if (provider == sfxSettingsProvider) {
              SoundService.setMuted(!newVal);
            } else if (provider == musicSettingsProvider) {
              SoundService.setMusicEnabled(newVal);
            }
            SoundService.playClick();
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          buildSwitch('Background Music', 'Relaxing ambient melodies', musicSettingsProvider, Icons.music_note_rounded),
          buildSwitch('Sound Effects', 'Tap, pop & victory sounds', sfxSettingsProvider, Icons.volume_up_rounded),
          buildSwitch('Cat Voices', 'Cute meows when placing cats', catVoiceSettingsProvider, Icons.pets_rounded),
          buildSwitch('Haptic Feedback', 'Subtle vibrations on interaction', hapticSettingsProvider, Icons.vibration_rounded),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          buildSwitch('Pattern Mode', 'Colorblind friendly region patterns', patternSettingsProvider, Icons.pattern_rounded),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'CatQueens v1.0.0 • Cozy Puzzle',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}
