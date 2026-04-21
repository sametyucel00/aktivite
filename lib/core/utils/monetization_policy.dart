import 'package:aktivite/core/config/remote_config_keys.dart';
import 'package:aktivite/core/enums/discovery_distance_filter.dart';
import 'package:aktivite/core/enums/discovery_surface.dart';
import 'package:aktivite/core/services/remote_config_service.dart';
import 'package:aktivite/features/monetization/domain/premium_tier.dart';
import 'package:aktivite/features/monetization/domain/user_entitlement.dart';
import 'package:aktivite/shared/models/activity_plan.dart';

int effectiveActivePlansLimit(
  RemoteConfigService remoteConfig,
  UserEntitlement entitlement,
) {
  final baseLimit = switch (entitlement.tier) {
    PremiumTier.free => activePlansLimit(remoteConfig),
    PremiumTier.plus => premiumPlusActivePlansLimit(remoteConfig),
    PremiumTier.pro => premiumProActivePlansLimit(remoteConfig),
  };
  return baseLimit + entitlement.rewardedExtraSlots;
}

List<DiscoveryDistanceFilter> availableDistanceFilters(
  UserEntitlement entitlement,
) {
  return switch (entitlement.tier) {
    PremiumTier.free => const [
        DiscoveryDistanceFilter.one,
        DiscoveryDistanceFilter.three,
        DiscoveryDistanceFilter.five,
      ],
    PremiumTier.plus => const [
        DiscoveryDistanceFilter.one,
        DiscoveryDistanceFilter.three,
        DiscoveryDistanceFilter.five,
        DiscoveryDistanceFilter.ten,
        DiscoveryDistanceFilter.twentyFive,
      ],
    PremiumTier.pro => DiscoveryDistanceFilter.values,
  };
}

int boostedVisibilityScore({
  required ActivityPlan plan,
  required DiscoverySurface surface,
  required RemoteConfigService remoteConfig,
  DateTime? now,
}) {
  if (!plan.hasActiveBoostAt(now ?? DateTime.now())) {
    return 0;
  }

  final base = monetizationBoostBonus(remoteConfig);
  if (surface == DiscoverySurface.now || surface == DiscoverySurface.tonight) {
    return base + 6;
  }
  return base;
}
