import 'package:aktivite/features/monetization/domain/premium_tier.dart';

class UserEntitlement {
  const UserEntitlement({
    required this.userId,
    required this.tier,
    required this.boostCredits,
    required this.rewardedExtraSlots,
    this.subscriptionExpiresAt,
  });

  const UserEntitlement.free({required this.userId})
      : tier = PremiumTier.free,
        boostCredits = 0,
        rewardedExtraSlots = 0,
        subscriptionExpiresAt = null;

  final String userId;
  final PremiumTier tier;
  final int boostCredits;
  final int rewardedExtraSlots;
  final DateTime? subscriptionExpiresAt;

  bool get isPlus => tier == PremiumTier.plus || tier == PremiumTier.pro;

  bool get isPro => tier == PremiumTier.pro;

  bool get hasPremium => tier != PremiumTier.free;

  bool get supportsAdvancedFilters => isPlus;

  bool get supportsExpandedRange => isPlus;

  bool get supportsRecurringPlans => isPro;

  bool get supportsHostControls => isPro;

  bool get supportsBoostTools => hasPremium || boostCredits > 0;

  UserEntitlement copyWith({
    String? userId,
    PremiumTier? tier,
    int? boostCredits,
    int? rewardedExtraSlots,
    Object? subscriptionExpiresAt = _unset,
  }) {
    return UserEntitlement(
      userId: userId ?? this.userId,
      tier: tier ?? this.tier,
      boostCredits: boostCredits ?? this.boostCredits,
      rewardedExtraSlots: rewardedExtraSlots ?? this.rewardedExtraSlots,
      subscriptionExpiresAt: identical(subscriptionExpiresAt, _unset)
          ? this.subscriptionExpiresAt
          : subscriptionExpiresAt as DateTime?,
    );
  }
}

const _unset = Object();
