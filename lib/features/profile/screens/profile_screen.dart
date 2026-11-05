import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: asyncProfile.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error loading profile: $e')),
        data: (profile) {
          Widget buildGrid({
            required int itemCount,
            required int selectedIndex,
            required List<String> emojis,
            required ValueChanged<int> onSelect,
          }) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                final isSelected = index == selectedIndex;
                return GestureDetector(
                  onTap: () => onSelect(index),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.shade300,
                            width: isSelected ? 3 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            emojis[index % emojis.length],
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Positioned(
                          right: 2,
                          bottom: 2,
                          child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
                        ),
                    ],
                  ),
                );
              },
            );
          }

          final avatarEmojis = ['🐱', '😸', '😹', '😻', '😼', '😽', '🙀', '🦁'];
          final frameEmojis = ['👑', '⭐', '🌸', '🎀', '💎'];
          final skinEmojis = ['🐈', '🐈‍⬛', '🐅', '🐆', '🦊', '🐾'];

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.white,
                      child: Text(
                        avatarEmojis[profile.avatarIndex % avatarEmojis.length],
                        style: const TextStyle(fontSize: 44),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star_rounded, size: 18, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'ID: ${profile.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        const TabBar(
                          indicatorColor: AppColors.primary,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          tabs: [
                            Tab(text: 'Avatar'),
                            Tab(text: 'Frame'),
                            Tab(text: 'Cat Skin'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              buildGrid(
                                itemCount: 8,
                                selectedIndex: profile.avatarIndex,
                                emojis: avatarEmojis,
                                onSelect: (i) async {
                                  await ref.read(profileRepositoryProvider).updateAvatar(i);
                                  ref.invalidate(userProfileProvider);
                                },
                              ),
                              buildGrid(
                                itemCount: 5,
                                selectedIndex: profile.frameIndex,
                                emojis: frameEmojis,
                                onSelect: (i) async {
                                  await ref.read(profileRepositoryProvider).updateFrame(i);
                                  ref.invalidate(userProfileProvider);
                                },
                              ),
                              buildGrid(
                                itemCount: 6,
                                selectedIndex: profile.catSkinIndex,
                                emojis: skinEmojis,
                                onSelect: (i) async {
                                  await ref.read(profileRepositoryProvider).updateCatSkin(i);
                                  ref.invalidate(userProfileProvider);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile settings saved!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        context.go('/home');
                      },
                      child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
