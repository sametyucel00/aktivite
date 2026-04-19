import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/availability_slot.dart';
import 'package:aktivite/core/enums/group_preference.dart';
import 'package:aktivite/core/enums/social_mood.dart';
import 'package:aktivite/core/enums/verification_level.dart';
import 'package:aktivite/shared/models/app_user_profile.dart';
import 'package:aktivite/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('canCreatePlansProvider derives from profile helper', () async {
    const profile = AppUserProfile(
      id: 'user-1',
      displayName: 'Samet',
      profilePhotoUrl: '',
      city: 'Istanbul',
      bio: 'Coffee and walks',
      profileCompletion: 75,
      favoriteActivities: [ActivityCategory.coffee],
      activeTimes: [AvailabilitySlot.evenings],
      groupPreference: GroupPreference.flexible,
      socialMood: SocialMood.casual,
      verificationLabel: 'phone',
      verificationLevel: VerificationLevel.phone,
    );

    final container = ProviderContainer(
      overrides: [
        currentUserProfileProvider.overrideWith((ref) => Stream.value(profile)),
      ],
    );
    addTearDown(container.dispose);

    await container.read(currentUserProfileProvider.future);

    expect(container.read(canCreatePlansProvider).valueOrNull, isTrue);
    expect(container.read(profileCompletionProvider).valueOrNull, 75);
  });
}
