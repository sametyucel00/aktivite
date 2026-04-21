import 'package:aktivite/shared/models/user_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorageService {
  SettingsStorageService({
    Future<SharedPreferences> Function()? preferences,
  }) : _preferences = preferences ?? SharedPreferences.getInstance;

  final Future<SharedPreferences> Function() _preferences;

  static const _notificationsKey = 'settings.notificationsEnabled';
  static const _approximateLocationKey = 'settings.approximateLocationEnabled';
  static const _safeMeetupRemindersKey = 'settings.safeMeetupRemindersEnabled';
  static const _localeCodeKey = 'settings.localeCode';

  Future<UserPreferences> read() async {
    try {
      final preferences = await _preferences();
      return UserPreferences(
        notificationsEnabled: preferences.getBool(_notificationsKey) ??
            const UserPreferences.initial().notificationsEnabled,
        approximateLocationEnabled:
            preferences.getBool(_approximateLocationKey) ??
                const UserPreferences.initial().approximateLocationEnabled,
        safeMeetupRemindersEnabled:
            preferences.getBool(_safeMeetupRemindersKey) ??
                const UserPreferences.initial().safeMeetupRemindersEnabled,
        localeCode: preferences.getString(_localeCodeKey) ??
            const UserPreferences.initial().localeCode,
      );
    } catch (_) {
      return const UserPreferences.initial();
    }
  }

  Future<void> write(UserPreferences preferencesState) async {
    try {
      final preferences = await _preferences();
      await preferences.setBool(
        _notificationsKey,
        preferencesState.notificationsEnabled,
      );
      await preferences.setBool(
        _approximateLocationKey,
        preferencesState.approximateLocationEnabled,
      );
      await preferences.setBool(
        _safeMeetupRemindersKey,
        preferencesState.safeMeetupRemindersEnabled,
      );
      await preferences.setString(_localeCodeKey, preferencesState.localeCode);
    } catch (_) {
      // Keep UX responsive in environments where preferences are unavailable.
    }
  }
}
