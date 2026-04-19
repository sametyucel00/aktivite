import 'package:aktivite/core/config/remote_config_keys.dart';
import 'package:aktivite/core/enums/map_privacy_mode.dart';
import 'package:aktivite/core/services/remote_config_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRemoteConfigService implements RemoteConfigService {
  _FakeRemoteConfigService({
    this.bools = const <String, bool>{},
    this.strings = const <String, String>{},
  });

  final Map<String, bool> bools;
  final Map<String, String> strings;

  @override
  bool getBool(String key) => bools[key] ?? false;

  @override
  String getString(String key) => strings[key] ?? '';
}

void main() {
  group('mapPrivacyMode', () {
    test('returns approximate by default', () {
      final remoteConfig = _FakeRemoteConfigService();

      expect(mapPrivacyMode(remoteConfig), MapPrivacyMode.approximate);
    });

    test('returns hidden for hidden remote config value', () {
      final remoteConfig = _FakeRemoteConfigService(
        strings: {
          RemoteConfigKeys.mapsPublicPrecision: 'hidden',
        },
      );

      expect(mapPrivacyMode(remoteConfig), MapPrivacyMode.hidden);
    });

    test('falls back to approximate for unknown remote config value', () {
      final remoteConfig = _FakeRemoteConfigService(
        strings: {
          RemoteConfigKeys.mapsPublicPrecision: 'street-level',
        },
      );

      expect(mapPrivacyMode(remoteConfig), MapPrivacyMode.approximate);
    });
  });

  group('activePlansLimit', () {
    test('returns default limit when value is missing', () {
      final remoteConfig = _FakeRemoteConfigService();

      expect(
        activePlansLimit(remoteConfig),
        RemoteConfigDefaults.plansMaxActive,
      );
    });

    test('returns parsed limit when value is numeric', () {
      final remoteConfig = _FakeRemoteConfigService(
        strings: {
          RemoteConfigKeys.plansMaxActive: '5',
        },
      );

      expect(activePlansLimit(remoteConfig), 5);
    });

    test('clamps large values and falls back for invalid values', () {
      final largeRemoteConfig = _FakeRemoteConfigService(
        strings: {
          RemoteConfigKeys.plansMaxActive: '150',
        },
      );
      final invalidRemoteConfig = _FakeRemoteConfigService(
        strings: {
          RemoteConfigKeys.plansMaxActive: 'many',
        },
      );

      expect(activePlansLimit(largeRemoteConfig), 99);
      expect(
        activePlansLimit(invalidRemoteConfig),
        RemoteConfigDefaults.plansMaxActive,
      );
    });
  });

  group('safetyBannerEnabled', () {
    test('reads boolean values from remote config', () {
      final enabledRemoteConfig = _FakeRemoteConfigService(
        bools: {
          RemoteConfigKeys.safetyBannerEnabled: true,
        },
      );
      final disabledRemoteConfig = _FakeRemoteConfigService(
        bools: {
          RemoteConfigKeys.safetyBannerEnabled: false,
        },
      );

      expect(safetyBannerEnabled(enabledRemoteConfig), isTrue);
      expect(safetyBannerEnabled(disabledRemoteConfig), isFalse);
    });
  });
}
