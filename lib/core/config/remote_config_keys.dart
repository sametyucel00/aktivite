import 'package:aktivite/core/enums/map_privacy_mode.dart';
import 'package:aktivite/core/services/remote_config_service.dart';

abstract final class RemoteConfigKeys {
  static const mapsPublicPrecision = 'maps_public_precision';
  static const plansMaxActive = 'plans_max_active';
  static const safetyBannerEnabled = 'safety_banner_enabled';
  static const premiumPlusPlansMaxActive = 'premium_plus_plans_max_active';
  static const premiumProPlansMaxActive = 'premium_pro_plans_max_active';
  static const monetizationRewardedAdsEnabled =
      'monetization_rewarded_ads_enabled';
  static const monetizationPremiumEnabled = 'monetization_premium_enabled';
  static const monetizationBoostHours = 'monetization_boost_hours';
  static const monetizationBoostBonus = 'monetization_boost_bonus';
  static const monetizationPlusMonthlyBoostCredits =
      'monetization_plus_monthly_boost_credits';
  static const monetizationProMonthlyBoostCredits =
      'monetization_pro_monthly_boost_credits';
}

abstract final class RemoteConfigDefaults {
  static const mapsPublicPrecision = 'approximate';
  static const plansMaxActive = 3;
  static const safetyBannerEnabled = true;
  static const premiumPlusPlansMaxActive = 5;
  static const premiumProPlansMaxActive = 8;
  static const monetizationRewardedAdsEnabled = true;
  static const monetizationPremiumEnabled = true;
  static const monetizationBoostHours = 12;
  static const monetizationBoostBonus = 24;
  static const monetizationPlusMonthlyBoostCredits = 2;
  static const monetizationProMonthlyBoostCredits = 6;

  static const values = <String, Object>{
    RemoteConfigKeys.mapsPublicPrecision: mapsPublicPrecision,
    RemoteConfigKeys.plansMaxActive: plansMaxActive,
    RemoteConfigKeys.safetyBannerEnabled: safetyBannerEnabled,
    RemoteConfigKeys.premiumPlusPlansMaxActive: premiumPlusPlansMaxActive,
    RemoteConfigKeys.premiumProPlansMaxActive: premiumProPlansMaxActive,
    RemoteConfigKeys.monetizationRewardedAdsEnabled:
        monetizationRewardedAdsEnabled,
    RemoteConfigKeys.monetizationPremiumEnabled: monetizationPremiumEnabled,
    RemoteConfigKeys.monetizationBoostHours: monetizationBoostHours,
    RemoteConfigKeys.monetizationBoostBonus: monetizationBoostBonus,
    RemoteConfigKeys.monetizationPlusMonthlyBoostCredits:
        monetizationPlusMonthlyBoostCredits,
    RemoteConfigKeys.monetizationProMonthlyBoostCredits:
        monetizationProMonthlyBoostCredits,
  };
}

String mapPrivacyPrecision(RemoteConfigService remoteConfig) {
  final value = remoteConfig.getString(RemoteConfigKeys.mapsPublicPrecision);
  if (value.isEmpty) {
    return RemoteConfigDefaults.mapsPublicPrecision;
  }
  return value;
}

MapPrivacyMode mapPrivacyMode(RemoteConfigService remoteConfig) {
  switch (mapPrivacyPrecision(remoteConfig)) {
    case 'hidden':
      return MapPrivacyMode.hidden;
    case 'approximate':
    default:
      return MapPrivacyMode.approximate;
  }
}

int activePlansLimit(RemoteConfigService remoteConfig) {
  final rawValue = remoteConfig.getString(RemoteConfigKeys.plansMaxActive);
  final parsed = int.tryParse(rawValue);
  if (parsed == null) {
    return RemoteConfigDefaults.plansMaxActive;
  }
  return parsed.clamp(0, 99).toInt();
}

bool safetyBannerEnabled(RemoteConfigService remoteConfig) {
  return remoteConfig.getBool(RemoteConfigKeys.safetyBannerEnabled);
}

bool rewardedAdsEnabled(RemoteConfigService remoteConfig) {
  return remoteConfig.getBool(RemoteConfigKeys.monetizationRewardedAdsEnabled);
}

bool premiumEnabled(RemoteConfigService remoteConfig) {
  return remoteConfig.getBool(RemoteConfigKeys.monetizationPremiumEnabled);
}

int premiumPlusActivePlansLimit(RemoteConfigService remoteConfig) {
  return _intValue(
    remoteConfig,
    RemoteConfigKeys.premiumPlusPlansMaxActive,
    RemoteConfigDefaults.premiumPlusPlansMaxActive,
  );
}

int premiumProActivePlansLimit(RemoteConfigService remoteConfig) {
  return _intValue(
    remoteConfig,
    RemoteConfigKeys.premiumProPlansMaxActive,
    RemoteConfigDefaults.premiumProPlansMaxActive,
  );
}

int monetizationBoostHours(RemoteConfigService remoteConfig) {
  return _intValue(
    remoteConfig,
    RemoteConfigKeys.monetizationBoostHours,
    RemoteConfigDefaults.monetizationBoostHours,
  );
}

int monetizationBoostBonus(RemoteConfigService remoteConfig) {
  return _intValue(
    remoteConfig,
    RemoteConfigKeys.monetizationBoostBonus,
    RemoteConfigDefaults.monetizationBoostBonus,
  );
}

int premiumIncludedBoostCredits(
  RemoteConfigService remoteConfig, {
  required bool isPro,
}) {
  return _intValue(
    remoteConfig,
    isPro
        ? RemoteConfigKeys.monetizationProMonthlyBoostCredits
        : RemoteConfigKeys.monetizationPlusMonthlyBoostCredits,
    isPro
        ? RemoteConfigDefaults.monetizationProMonthlyBoostCredits
        : RemoteConfigDefaults.monetizationPlusMonthlyBoostCredits,
  );
}

int _intValue(
  RemoteConfigService remoteConfig,
  String key,
  int fallback,
) {
  final rawValue = remoteConfig.getString(key);
  final parsed = int.tryParse(rawValue);
  if (parsed == null) {
    return fallback;
  }
  return parsed.clamp(0, 999).toInt();
}
