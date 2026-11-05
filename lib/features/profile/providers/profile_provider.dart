import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/profile_repository.dart';
import '../models/user_profile.dart';

/// Provider for the repository instance.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) => ProfileRepository());

/// FutureProvider that loads the current user profile.
final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return await repo.loadProfile();
});

