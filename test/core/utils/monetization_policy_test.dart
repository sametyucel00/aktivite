import 'package:aktivite/core/services/in_memory_remote_config_service.dart';
import 'package:aktivite/core/utils/monetization_policy.dart';
import 'package:aktivite/core/enums/discovery_distance_filter.dart';
import 'package:aktivite/features/monetization/domain/premium_tier.dart';
import 'package:aktivite/features/monetization/domain/user_entitlement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final remoteConfig = InMemoryRemoteConfigService();

  test('effectiveActivePlansLimit respects tier and rewarded extra slots', () {
    const entitlement = UserEntitlement(
      userId: 'user-1',
      tier: PremiumTier.plus,
      boostCredits: 2,
      rewardedExtraSlots: 1,
    );

    expect(effectiveActivePlansLimit(remoteConfig, entitlement), 6);
  });

  test('availableDistanceFilters expands with premium tiers', () {
    expect(
      availableDistanceFilters(
        const UserEntitlement.free(userId: 'free-user'),
      ),
      const [
        DiscoveryDistanceFilter.one,
        DiscoveryDistanceFilter.three,
        DiscoveryDistanceFilter.five,
      ],
    );

    expect(
      availableDistanceFilters(
        const UserEntitlement(
          userId: 'pro-user',
          tier: PremiumTier.pro,
          boostCredits: 4,
          rewardedExtraSlots: 0,
        ),
      ),
      DiscoveryDistanceFilter.values,
    );
  });
}
