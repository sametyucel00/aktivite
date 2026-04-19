import 'package:aktivite/shared/models/user_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserPreferences', () {
    const preferences = UserPreferences(
      notificationsEnabled: true,
      approximateLocationEnabled: false,
      safeMeetupRemindersEnabled: true,
    );

    test('capability getters mirror preference intent', () {
      expect(preferences.notificationsAllowed, isTrue);
      expect(preferences.sharesApproximateLocation, isFalse);
      expect(preferences.hidesMapLocation, isTrue);
      expect(preferences.safeMeetupRemindersActive, isTrue);
    });

    test('copyWith updates individual flags', () {
      final updated = preferences.copyWith(
        approximateLocationEnabled: true,
        safeMeetupRemindersEnabled: false,
      );

      expect(updated.sharesApproximateLocation, isTrue);
      expect(updated.safeMeetupRemindersActive, isFalse);
      expect(updated.notificationsAllowed, isTrue);
    });
  });
}
