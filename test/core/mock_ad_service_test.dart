import 'package:cat_queens/core/ads/ad_service.dart';
import 'package:cat_queens/core/ads/mock_ad_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockAdService', () {
    test('isAdAvailable is always true', () {
      const service = MockAdService();
      expect(service.isAdAvailable, isTrue);
    });

    test('showRewardedAd completes and triggers onRewardEarned', () async {
      const service = MockAdService(simulatedDuration: Duration.zero);
      bool rewardEarned = false;

      final success = await service.showRewardedAd(
        type: RewardedAdType.revive,
        onRewardEarned: () => rewardEarned = true,
      );

      expect(success, isTrue);
      expect(rewardEarned, isTrue);
    });
  });
}

