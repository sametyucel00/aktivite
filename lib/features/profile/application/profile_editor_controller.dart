import 'dart:typed_data';

import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/availability_slot.dart';
import 'package:aktivite/core/enums/group_preference.dart';
import 'package:aktivite/core/enums/social_mood.dart';
import 'package:aktivite/core/utils/profile_photo_policy.dart';
import 'package:aktivite/core/utils/profile_completion.dart';
import 'package:aktivite/features/profile/data/profile_photo_picker_service.dart';
import 'package:aktivite/features/profile/data/profile_repository.dart';
import 'package:aktivite/features/profile/data/profile_photo_storage_service.dart';
import 'package:aktivite/shared/models/app_user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileEditorState {
  const ProfileEditorState({
    required this.displayName,
    required this.profilePhotoUrl,
    required this.profilePhotoBytes,
    required this.city,
    required this.bio,
    required this.socialMood,
    required this.favoriteActivities,
    required this.activeTimes,
    required this.groupPreference,
    required this.safeMeetupRemindersEnabled,
    required this.isUploadingPhoto,
    required this.profilePhotoIssue,
    required this.hasSeeded,
  });

  const ProfileEditorState.initial()
      : displayName = '',
        profilePhotoUrl = '',
        profilePhotoBytes = null,
        city = '',
        bio = '',
        socialMood = SocialMood.calm,
        favoriteActivities = const [],
        activeTimes = const [],
        groupPreference = GroupPreference.flexible,
        safeMeetupRemindersEnabled = true,
        isUploadingPhoto = false,
        profilePhotoIssue = null,
        hasSeeded = false;

  final String displayName;
  final String profilePhotoUrl;
  final Uint8List? profilePhotoBytes;
  final String city;
  final String bio;
  final SocialMood socialMood;
  final List<ActivityCategory> favoriteActivities;
  final List<AvailabilitySlot> activeTimes;
  final GroupPreference groupPreference;
  final bool safeMeetupRemindersEnabled;
  final bool isUploadingPhoto;
  final ProfilePhotoValidationIssue? profilePhotoIssue;
  final bool hasSeeded;

  bool get canSubmit =>
      displayName.trim().isNotEmpty &&
      city.trim().isNotEmpty &&
      bio.trim().isNotEmpty &&
      favoriteActivities.isNotEmpty &&
      activeTimes.isNotEmpty;

  int get completionScore {
    return calculateProfileCompletion(
      displayName: displayName,
      city: city,
      bio: bio,
      favoriteActivities: favoriteActivities,
      activeTimes: activeTimes,
      groupPreference: groupPreference,
      safeMeetupRemindersEnabled: safeMeetupRemindersEnabled,
    );
  }

  ProfileEditorState copyWith({
    String? displayName,
    String? profilePhotoUrl,
    Object? profilePhotoBytes = _profilePhotoSentinel,
    String? city,
    String? bio,
    SocialMood? socialMood,
    List<ActivityCategory>? favoriteActivities,
    List<AvailabilitySlot>? activeTimes,
    GroupPreference? groupPreference,
    bool? safeMeetupRemindersEnabled,
    bool? isUploadingPhoto,
    ProfilePhotoValidationIssue? profilePhotoIssue,
    bool clearProfilePhotoIssue = false,
    bool? hasSeeded,
  }) {
    return ProfileEditorState(
      displayName: displayName ?? this.displayName,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      profilePhotoBytes: identical(
        profilePhotoBytes,
        _profilePhotoSentinel,
      )
          ? this.profilePhotoBytes
          : profilePhotoBytes as Uint8List?,
      city: city ?? this.city,
      bio: bio ?? this.bio,
      socialMood: socialMood ?? this.socialMood,
      favoriteActivities: favoriteActivities ?? this.favoriteActivities,
      activeTimes: activeTimes ?? this.activeTimes,
      groupPreference: groupPreference ?? this.groupPreference,
      safeMeetupRemindersEnabled:
          safeMeetupRemindersEnabled ?? this.safeMeetupRemindersEnabled,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
      profilePhotoIssue: clearProfilePhotoIssue
          ? null
          : profilePhotoIssue ?? this.profilePhotoIssue,
      hasSeeded: hasSeeded ?? this.hasSeeded,
    );
  }
}

const _profilePhotoSentinel = Object();

class ProfileEditorController extends Notifier<ProfileEditorState> {
  @override
  ProfileEditorState build() {
    return const ProfileEditorState.initial();
  }

  void seedFromProfile(AppUserProfile profile) {
    state = ProfileEditorState(
      displayName: profile.displayName,
      profilePhotoUrl: profile.profilePhotoUrl,
      profilePhotoBytes: null,
      city: profile.city,
      bio: profile.bio,
      socialMood: profile.socialMood,
      favoriteActivities: profile.favoriteActivities,
      activeTimes: profile.activeTimes,
      groupPreference: profile.groupPreference,
      safeMeetupRemindersEnabled: true,
      isUploadingPhoto: false,
      profilePhotoIssue: null,
      hasSeeded: true,
    );
  }

  void setDisplayName(String value) {
    state = state.copyWith(displayName: value);
  }

  void setCity(String value) {
    state = state.copyWith(city: value);
  }

  void setBio(String value) {
    state = state.copyWith(bio: value);
  }

  void setSocialMood(SocialMood value) {
    state = state.copyWith(socialMood: value);
  }

  void toggleActivity(ActivityCategory activity) {
    final current = [...state.favoriteActivities];
    if (current.contains(activity)) {
      current.remove(activity);
    } else {
      current.add(activity);
    }
    state = state.copyWith(favoriteActivities: current);
  }

  void toggleActiveTime(AvailabilitySlot slot) {
    final current = [...state.activeTimes];
    if (current.contains(slot)) {
      current.remove(slot);
    } else {
      current.add(slot);
    }
    state = state.copyWith(activeTimes: current);
  }

  void setGroupPreference(GroupPreference value) {
    state = state.copyWith(groupPreference: value);
  }

  Future<bool> uploadProfilePhoto({
    required String userId,
    required ProfilePhotoPickerService picker,
    required ProfilePhotoStorageService storage,
  }) async {
    final photo = await picker.pickProfilePhoto();
    if (photo == null) {
      return false;
    }
    final validationIssue = validateProfilePhoto(photo);
    if (validationIssue != null) {
      state = state.copyWith(profilePhotoIssue: validationIssue);
      return false;
    }

    state = state.copyWith(
      isUploadingPhoto: true,
      clearProfilePhotoIssue: true,
    );
    try {
      final photoUrl = await storage.uploadProfilePhoto(
        userId: userId,
        photo: photo,
      );
      if (photoUrl == null || photoUrl.isEmpty) {
        state = state.copyWith(isUploadingPhoto: false);
        return false;
      }

      state = state.copyWith(
        profilePhotoUrl: photoUrl,
        profilePhotoBytes: photo.bytes,
        isUploadingPhoto: false,
        clearProfilePhotoIssue: true,
      );
      return true;
    } catch (_) {
      state = state.copyWith(isUploadingPhoto: false);
      return false;
    }
  }

  void removeProfilePhoto() {
    state = state.copyWith(
      profilePhotoUrl: '',
      profilePhotoBytes: null,
      clearProfilePhotoIssue: true,
    );
  }

  Future<void> save(
    ProfileRepository repository,
    AppUserProfile currentProfile,
  ) async {
    if (!state.canSubmit) {
      return;
    }

    await repository.saveProfile(
      currentProfile.copyWith(
        displayName: state.displayName.trim(),
        profilePhotoUrl: state.profilePhotoUrl,
        city: state.city.trim(),
        bio: state.bio.trim(),
        profileCompletion: state.completionScore,
        favoriteActivities: state.favoriteActivities,
        activeTimes: state.activeTimes,
        groupPreference: state.groupPreference,
        socialMood: state.socialMood,
      ),
    );
  }
}

final profileEditorControllerProvider =
    NotifierProvider<ProfileEditorController, ProfileEditorState>(
  ProfileEditorController.new,
);
