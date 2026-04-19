import 'package:aktivite/core/enums/map_privacy_mode.dart';
import 'package:aktivite/features/settings/application/settings_controller.dart';
import 'package:aktivite/shared/models/user_preferences.dart';
import 'package:aktivite/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('effectiveMapPrivacyProvider', () {
    test('returns hidden when preferences hide map location', () {
      final container = ProviderContainer(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(
              const UserPreferences(
                notificationsEnabled: true,
                approximateLocationEnabled: false,
                safeMeetupRemindersEnabled: true,
              ),
            ),
          ),
          mapPrivacyModeProvider
              .overrideWith((ref) => MapPrivacyMode.approximate),
        ],
      );
      addTearDown(container.dispose);

      expect(
          container.read(effectiveMapPrivacyProvider), MapPrivacyMode.hidden);
    });

    test('returns remote config mode when preferences allow location', () {
      final container = ProviderContainer(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsController(
              const UserPreferences(
                notificationsEnabled: true,
                approximateLocationEnabled: true,
                safeMeetupRemindersEnabled: true,
              ),
            ),
          ),
          mapPrivacyModeProvider
              .overrideWith((ref) => MapPrivacyMode.approximate),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(effectiveMapPrivacyProvider),
        MapPrivacyMode.approximate,
      );
    });
  });
}

class _FakeSettingsController extends SettingsController {
  _FakeSettingsController(this._state);

  final UserPreferences _state;

  @override
  UserPreferences build() => _state;
}
