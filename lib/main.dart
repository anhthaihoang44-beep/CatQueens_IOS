import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/profile/models/user_profile.dart';
import 'features/streak/models/streak_info.dart';
import 'features/daily/models/daily_challenge.dart';
import 'core/audio/sound_service.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SoundService.startBgm();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(UserProfileAdapter());
    await Hive.openBox<UserProfile>('profile_box');

    Hive.registerAdapter(StreakInfoAdapter());
    await Hive.openBox<StreakInfo>('streak_box');

    Hive.registerAdapter(DailyChallengeAdapter());
    await Hive.openBox<DailyChallenge>('daily_challenge_box');

    await Hive.openBox('catqueens_progress');
  } catch (e) {
    debugPrint('Hive initialization error: $e');
  }

  runApp(
    const ProviderScope(
      child: CatQueensApp(),
    ),
  );
}

class CatQueensApp extends StatelessWidget {
  const CatQueensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CatQueens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF0932B), // Main Orange
          surface: const Color(0xFFF7F1EC), // Cozy Cream
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F1EC),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
