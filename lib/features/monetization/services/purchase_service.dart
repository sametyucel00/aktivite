import 'package:aktivite/features/monetization/domain/premium_tier.dart';

abstract class PurchaseService {
  Future<void> openPremiumOffer({
    required String placement,
    required PremiumTier targetTier,
  });
}

class PlaceholderPurchaseService implements PurchaseService {
  @override
  Future<void> openPremiumOffer({
    required String placement,
    required PremiumTier targetTier,
  }) async {}
}
