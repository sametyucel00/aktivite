import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/availability_slot.dart';
import 'package:aktivite/core/enums/group_preference.dart';
import 'package:aktivite/core/utils/profile_completion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculateProfileCompletion', () {
    test('returns base group score when only preference is present', () {
      final score = calculateProfileCompletion(
        displayName: '',
        city: '',
        bio: '',
        favoriteActivities: const [],
        activeTimes: const [],
        groupPreference: GroupPreference.flexible,
        safeMeetupRemindersEnabled: false,
      );

      expect(score, 15);
    });

    test('caps completion at 100 for filled profile', () {
      final score = calculateProfileCompletion(
        displayName: 'Samet',
        city: 'Istanbul',
        bio: 'Coffee and walks',
        favoriteActivities: const [
          ActivityCategory.coffee,
          ActivityCategory.walk,
        ],
        activeTimes: const [
          AvailabilitySlot.evenings,
          AvailabilitySlot.weekends,
        ],
        groupPreference: GroupPreference.smallGroup,
        safeMeetupRemindersEnabled: true,
      );

      expect(score, 100);
    });
  });
}
