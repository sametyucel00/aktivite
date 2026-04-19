import 'dart:async';

import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/availability_slot.dart';
import 'package:aktivite/core/enums/group_preference.dart';
import 'package:aktivite/core/enums/social_mood.dart';
import 'package:aktivite/core/enums/verification_level.dart';
import 'package:aktivite/features/profile/data/profile_repository.dart';
import 'package:aktivite/shared/models/app_user_profile.dart';

class InMemoryProfileRepository implements ProfileRepository {
  InMemoryProfileRepository() {
    _controller.add(_profile);
  }

  AppUserProfile _profile = const AppUserProfile(
    id: SampleIds.currentUser,
    displayName: 'Deniz',
    profilePhotoUrl: '',
    city: 'Istanbul',
    bio: 'Enjoys low-pressure plans, coffee breaks, and simple walks.',
    profileCompletion: 78,
    favoriteActivities: [
      ActivityCategory.coffee,
      ActivityCategory.walk,
      ActivityCategory.cowork,
    ],
    activeTimes: [
      AvailabilitySlot.evenings,
      AvailabilitySlot.weekends,
    ],
    groupPreference: GroupPreference.flexible,
    socialMood: SocialMood.calm,
    verificationLabel: 'phone',
    verificationLevel: VerificationLevel.phone,
  );
  final StreamController<AppUserProfile> _controller =
      StreamController<AppUserProfile>.broadcast();

  @override
  Future<void> saveProfile(AppUserProfile profile) async {
    _profile = profile;
    _controller.add(_profile);
  }

  @override
  Stream<AppUserProfile> watchCurrentProfile() {
    return Stream<AppUserProfile>.multi((multi) {
      multi.add(_profile);
      final subscription = _controller.stream.listen(
        multi.add,
        onError: multi.addError,
        onDone: multi.close,
      );
      multi.onCancel = subscription.cancel;
    });
  }
}
