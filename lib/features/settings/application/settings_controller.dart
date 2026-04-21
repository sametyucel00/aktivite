import 'package:aktivite/features/settings/data/settings_storage_service.dart';
import 'package:aktivite/shared/models/user_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsController extends Notifier<UserPreferences> {
  bool _hydrated = false;

  @override
  UserPreferences build() {
    if (!_hydrated) {
      _hydrated = true;
      _hydrate();
    }
    return const UserPreferences.initial();
  }

  void setNotificationsEnabled(bool value) {
    state = state.copyWith(notificationsEnabled: value);
    _persist();
  }

  void setApproximateLocationEnabled(bool value) {
    state = state.copyWith(approximateLocationEnabled: value);
    _persist();
  }

  void setSafeMeetupRemindersEnabled(bool value) {
    state = state.copyWith(safeMeetupRemindersEnabled: value);
    _persist();
  }

  void setLocaleCode(String value) {
    if (value != 'tr' && value != 'en') {
      return;
    }
    state = state.copyWith(localeCode: value);
    _persist();
  }

  Future<void> _hydrate() async {
    final stored = await ref.read(settingsStorageServiceProvider).read();
    state = stored;
  }

  Future<void> _persist() {
    return ref.read(settingsStorageServiceProvider).write(state);
  }
}

final settingsStorageServiceProvider = Provider<SettingsStorageService>(
  (ref) => SettingsStorageService(),
);

final settingsControllerProvider =
    NotifierProvider<SettingsController, UserPreferences>(
  SettingsController.new,
);
