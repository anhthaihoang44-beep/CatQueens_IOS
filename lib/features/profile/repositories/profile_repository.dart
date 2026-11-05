import 'package:hive/hive.dart';
import '../../profile/models/user_profile.dart';

/// Repository handling persistence of the user's profile.
class ProfileRepository {
  static const String _boxName = 'profile_box';

  Future<Box<UserProfile>> _openBox() async => await Hive.openBox<UserProfile>(_boxName);

  /// Load the saved profile, or create a default one if none exists.
  Future<UserProfile> loadProfile() async {
    final box = await _openBox();
    if (box.isEmpty) {
      // Generate a simple random 6‑char ID.
      final id = List.generate(6, (_) => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.codeUnitAt(_random.nextInt(36))).join();
      final profile = UserProfile(id: id);
      await box.put('profile', profile);
      return profile;
    }
    return box.get('profile')!;
  }

  Future<void> saveProfile(UserProfile profile) async {
    final box = await _openBox();
    await box.put('profile', profile);
  }

  Future<void> updateAvatar(int index) async {
    final profile = await loadProfile();
    profile.avatarIndex = index;
    await saveProfile(profile);
  }

  Future<void> updateFrame(int index) async {
    final profile = await loadProfile();
    profile.frameIndex = index;
    await saveProfile(profile);
  }

  Future<void> updateCatSkin(int index) async {
    final profile = await loadProfile();
    profile.catSkinIndex = index;
    await saveProfile(profile);
  }
}

// Simple pseudo‑random generator for the default ID.
final _random = _Random();
class _Random {
  int nextInt(int max) => DateTime.now().microsecondsSinceEpoch.remainder(max);
}

