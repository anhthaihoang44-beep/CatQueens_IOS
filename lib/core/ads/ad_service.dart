import 'package:flutter/foundation.dart';

enum RewardedAdType {
  revive,
  extraBoosters,
}

abstract class AdService {
  bool get isAdAvailable;

  /// Shows a rewarded ad. Returns true if the user watched the ad and earned the reward.
  Future<bool> showRewardedAd({
    required RewardedAdType type,
    VoidCallback? onRewardEarned,
  });
}

