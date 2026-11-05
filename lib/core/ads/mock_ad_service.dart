import 'package:flutter/foundation.dart';
import 'ad_service.dart';

class MockAdService implements AdService {
  final Duration simulatedDuration;
  final bool alwaysSucceed;

  const MockAdService({
    this.simulatedDuration = const Duration(milliseconds: 600),
    this.alwaysSucceed = true,
  });

  @override
  bool get isAdAvailable => true;

  @override
  Future<bool> showRewardedAd({
    required RewardedAdType type,
    VoidCallback? onRewardEarned,
  }) async {
    if (simulatedDuration > Duration.zero) {
      await Future.delayed(simulatedDuration);
    }

    if (alwaysSucceed) {
      onRewardEarned?.call();
      return true;
    }
    return false;
  }
}

