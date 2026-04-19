import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/availability_slot.dart';
import 'package:aktivite/core/enums/group_preference.dart';
import 'package:aktivite/core/enums/social_mood.dart';
import 'package:aktivite/core/enums/verification_level.dart';
import 'package:aktivite/shared/models/app_user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppUserProfile', () {
    const baseProfile = AppUserProfile(
      id: 'user-1',
      displayName: 'Samet',
      profilePhotoUrl: '',
      city: 'Istanbul',
      bio: 'Coffee and walks',
      profileCompletion: 59,
      favoriteActivities: [ActivityCategory.coffee],
      activeTimes: [AvailabilitySlot.evenings],
      groupPreference: GroupPreference.flexible,
      socialMood: SocialMood.casual,
      verificationLabel: 'phone',
      verificationLevel: VerificationLevel.phone,
    );

    test('canCreatePlans is false below threshold', () {
      expect(baseProfile.canCreatePlans, isFalse);
    });

    test('copyWith can update completion above threshold', () {
      final updated = baseProfile.copyWith(profileCompletion: 60);

      expect(updated.canCreatePlans, isTrue);
      expect(updated.displayName, baseProfile.displayName);
    });

    test('copyWith can update profile photo url', () {
      final updated = baseProfile.copyWith(
        profilePhotoUrl: 'https://example.com/photo.jpg',
      );

      expect(updated.profilePhotoUrl, 'https://example.com/photo.jpg');
    });
  });
}
