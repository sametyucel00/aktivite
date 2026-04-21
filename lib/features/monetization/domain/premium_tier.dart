enum PremiumTier {
  free,
  plus,
  pro,
}

PremiumTier premiumTierFromName(Object? value) {
  final name = value is String ? value : '';
  switch (name) {
    case 'plus':
      return PremiumTier.plus;
    case 'pro':
      return PremiumTier.pro;
    case 'free':
    default:
      return PremiumTier.free;
  }
}
