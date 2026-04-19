import 'dart:async';

import 'package:aktivite/core/config/remote_config_keys.dart';
import 'package:aktivite/core/services/remote_config_service.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseRemoteConfigService implements RemoteConfigService {
  FirebaseRemoteConfigService({
    FirebaseRemoteConfig Function()? remoteConfig,
  }) : _remoteConfig = remoteConfig ?? (() => FirebaseRemoteConfig.instance) {
    unawaited(_initialize());
  }

  final FirebaseRemoteConfig Function() _remoteConfig;

  @override
  bool getBool(String key) {
    final fallback = (RemoteConfigDefaults.values[key] as bool?) ?? false;
    try {
      return _remoteConfig().getBool(key);
    } catch (_) {
      return fallback;
    }
  }

  @override
  String getString(String key) {
    final fallback = RemoteConfigDefaults.values[key]?.toString() ?? '';
    try {
      final value = _remoteConfig().getString(key);
      if (value.isEmpty) {
        return fallback;
      }
      return value;
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _initialize() async {
    try {
      final remoteConfig = _remoteConfig();
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await remoteConfig.setDefaults(RemoteConfigDefaults.values);
      await remoteConfig.fetchAndActivate();
    } catch (_) {
      // Safe fallbacks already come from RemoteConfigDefaults in sync getters.
    }
  }
}
