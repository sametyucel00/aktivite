import 'package:aktivite/core/enums/map_privacy_mode.dart';
import 'package:aktivite/core/services/remote_config_service.dart';

abstract final class RemoteConfigKeys {
  static const mapsPublicPrecision = 'maps_public_precision';
  static const plansMaxActive = 'plans_max_active';
  static const safetyBannerEnabled = 'safety_banner_enabled';
}

abstract final class RemoteConfigDefaults {
  static const mapsPublicPrecision = 'approximate';
  static const plansMaxActive = 3;
  static const safetyBannerEnabled = true;

  static const values = <String, Object>{
    RemoteConfigKeys.mapsPublicPrecision: mapsPublicPrecision,
    RemoteConfigKeys.plansMaxActive: plansMaxActive,
    RemoteConfigKeys.safetyBannerEnabled: safetyBannerEnabled,
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
