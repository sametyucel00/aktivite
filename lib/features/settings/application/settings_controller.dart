import 'package:aktivite/shared/models/user_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsController extends Notifier<UserPreferences> {
  @override
  UserPreferences build() {
    return const UserPreferences.initial();
  }

  void setNotificationsEnabled(bool value) {
    state = state.copyWith(notificationsEnabled: value);
  }

  void setApproximateLocationEnabled(bool value) {
    state = state.copyWith(approximateLocationEnabled: value);
  }

  void setSafeMeetupRemindersEnabled(bool value) {
    state = state.copyWith(safeMeetupRemindersEnabled: value);
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, UserPreferences>(
  SettingsController.new,
);
