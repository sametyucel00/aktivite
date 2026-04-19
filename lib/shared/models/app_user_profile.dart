import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/availability_slot.dart';
import 'package:aktivite/core/enums/group_preference.dart';
import 'package:aktivite/core/enums/social_mood.dart';
import 'package:aktivite/core/enums/verification_level.dart';

const minimumPlanCreationProfileCompletion = 60;

class AppUserProfile {
  const AppUserProfile({
    required this.id,
    required this.displayName,
    required this.profilePhotoUrl,
    required this.city,
    required this.bio,
    required this.profileCompletion,
    required this.favoriteActivities,
    required this.activeTimes,
    required this.groupPreference,
    required this.socialMood,
    required this.verificationLabel,
    required this.verificationLevel,
  });

  final String id;
  final String displayName;
  final String profilePhotoUrl;
  final String city;
  final String bio;
  final int profileCompletion;
  final List<ActivityCategory> favoriteActivities;
  final List<AvailabilitySlot> activeTimes;
  final GroupPreference groupPreference;
  final SocialMood socialMood;
  final String verificationLabel;
  final VerificationLevel verificationLevel;

  bool get canCreatePlans =>
      profileCompletion >= minimumPlanCreationProfileCompletion;

  AppUserProfile copyWith({
    String? id,
    String? displayName,
    String? profilePhotoUrl,
    String? city,
    String? bio,
    int? profileCompletion,
    List<ActivityCategory>? favoriteActivities,
    List<AvailabilitySlot>? activeTimes,
    GroupPreference? groupPreference,
    SocialMood? socialMood,
    String? verificationLabel,
    VerificationLevel? verificationLevel,
  }) {
    return AppUserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      city: city ?? this.city,
      bio: bio ?? this.bio,
      profileCompletion: profileCompletion ?? this.profileCompletion,
      favoriteActivities: favoriteActivities ?? this.favoriteActivities,
      activeTimes: activeTimes ?? this.activeTimes,
      groupPreference: groupPreference ?? this.groupPreference,
      socialMood: socialMood ?? this.socialMood,
      verificationLabel: verificationLabel ?? this.verificationLabel,
      verificationLevel: verificationLevel ?? this.verificationLevel,
    );
  }
}
