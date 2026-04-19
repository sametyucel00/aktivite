import 'package:aktivite/core/config/remote_config_keys.dart';
import 'package:aktivite/core/services/in_memory_remote_config_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryRemoteConfigService', () {
    test('returns configured default string values', () {
      final service = InMemoryRemoteConfigService();

      expect(
        service.getString(RemoteConfigKeys.mapsPublicPrecision),
        RemoteConfigDefaults.mapsPublicPrecision,
      );
      expect(
        service.getString(RemoteConfigKeys.plansMaxActive),
        RemoteConfigDefaults.plansMaxActive.toString(),
      );
    });

    test('returns configured default bool values', () {
      final service = InMemoryRemoteConfigService();

      expect(
        service.getBool(RemoteConfigKeys.safetyBannerEnabled),
        RemoteConfigDefaults.safetyBannerEnabled,
      );
    });

    test('falls back to safe empty values for unknown keys', () {
      final service = InMemoryRemoteConfigService();

      expect(service.getString('missing_key'), isEmpty);
      expect(service.getBool('missing_key'), isFalse);
    });
  });
}
