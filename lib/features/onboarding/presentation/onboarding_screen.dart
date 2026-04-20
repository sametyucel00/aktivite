import 'dart:typed_data';

import 'package:aktivite/app/app_routes.dart';
import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/availability_slot.dart';
import 'package:aktivite/core/enums/group_preference.dart';
import 'package:aktivite/core/enums/social_mood.dart';
import 'package:aktivite/core/utils/profile_photo_policy.dart';
import 'package:aktivite/core/utils/analytics_events.dart';
import 'package:aktivite/core/utils/localized_labels.dart';
import 'package:aktivite/features/auth/application/session_controller.dart';
import 'package:aktivite/features/onboarding/application/onboarding_controller.dart';
import 'package:aktivite/features/settings/application/settings_controller.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/providers/profile_media_providers.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:aktivite/shared/widgets/app_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const routePath = AppRoutes.onboarding;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _cityController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _cityController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onboarding = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    if (_displayNameController.text != onboarding.displayName) {
      _displayNameController.value = TextEditingValue(
        text: onboarding.displayName,
        selection:
            TextSelection.collapsed(offset: onboarding.displayName.length),
      );
    }
    if (_cityController.text != onboarding.city) {
      _cityController.value = TextEditingValue(
        text: onboarding.city,
        selection: TextSelection.collapsed(offset: onboarding.city.length),
      );
    }
    if (_bioController.text != onboarding.bio) {
      _bioController.value = TextEditingValue(
        text: onboarding.bio,
        selection: TextSelection.collapsed(offset: onboarding.bio.length),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.onboardingTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppSectionCard(
            title: l10n.onboardingProfileSection,
            subtitle: l10n.onboardingProfileHint,
            child: Column(
              children: [
                TextField(
                  controller: _displayNameController,
                  onChanged: controller.setDisplayName,
                  decoration:
                      InputDecoration(labelText: l10n.onboardingFieldName),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _cityController,
                  onChanged: controller.setCity,
                  decoration:
                      InputDecoration(labelText: l10n.onboardingFieldCity),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _bioController,
                  onChanged: controller.setBio,
                  minLines: 2,
                  maxLines: 3,
                  decoration:
                      InputDecoration(labelText: l10n.onboardingFieldBio),
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.onboardingItemPhoto,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _OnboardingPhotoAvatar(
                  photoUrl: onboarding.profilePhotoUrl,
                  photoBytes: onboarding.profilePhotoBytes,
                  semanticLabel: l10n.onboardingItemPhoto,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(_onboardingPhotoMessage(context, onboarding)),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  alignment: WrapAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: onboarding.isUploadingPhoto
                          ? null
                          : () async {
                              final userId =
                                  ref.read(sessionControllerProvider).userId;
                              if (userId == null) {
                                return;
                              }
                              final success =
                                  await controller.uploadProfilePhoto(
                                userId: userId,
                                picker:
                                    ref.read(profilePhotoPickerServiceProvider),
                                storage: ref
                                    .read(profilePhotoStorageServiceProvider),
                              );
                              if (!context.mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? l10n.profilePhotoUpdated
                                        : _onboardingPhotoMessage(
                                            context,
                                            ref.read(
                                                onboardingControllerProvider),
                                          ),
                                  ),
                                ),
                              );
                            },
                      child: Text(
                        onboarding.isUploadingPhoto
                            ? l10n.profilePhotoUploading
                            : onboarding.profilePhotoUrl.isEmpty
                                ? l10n.profilePhotoAdd
                                : l10n.profilePhotoChange,
                      ),
                    ),
                    if (onboarding.profilePhotoUrl.isNotEmpty ||
                        onboarding.profilePhotoBytes != null)
                      TextButton(
                        onPressed: onboarding.isUploadingPhoto
                            ? null
                            : controller.removeProfilePhoto,
                        child: Text(l10n.profilePhotoRemove),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<SocialMood>(
                  initialValue: onboarding.socialMood,
                  decoration: InputDecoration(
                    labelText: l10n.onboardingFieldMood,
                    prefixIcon: Icon(socialMoodIcon(onboarding.socialMood)),
                  ),
                  items: SocialMood.values
                      .map(
                        (mood) => DropdownMenuItem(
                          value: mood,
                          child: Text(moodLabel(l10n, mood)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) {
                      controller.setSocialMood(value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<GroupPreference>(
                  initialValue: onboarding.groupPreference,
                  decoration: InputDecoration(
                    labelText: l10n.onboardingFieldGroupPreference,
                    prefixIcon: Icon(
                      groupPreferenceIcon(onboarding.groupPreference),
                    ),
                  ),
                  items: GroupPreference.values
                      .map(
                        (preference) => DropdownMenuItem(
                          value: preference,
                          child: Text(groupPreferenceLabel(l10n, preference)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) {
                      controller.setGroupPreference(value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.onboardingActivityPreferencesTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ActivityCategory.values
                        .map(
                          (activity) => Padding(
                            padding:
                                const EdgeInsets.only(right: AppSpacing.sm),
                            child: FilterChip(
                              selected: onboarding.favoriteActivities
                                  .contains(activity),
                              showCheckmark: false,
                              avatar: Icon(activityIcon(activity), size: 18),
                              label: Text(activityLabel(l10n, activity)),
                              visualDensity: VisualDensity.compact,
                              onSelected: (_) =>
                                  controller.toggleActivity(activity),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.onboardingAvailabilityTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: AvailabilitySlot.values
                        .map(
                          (slot) => Padding(
                            padding:
                                const EdgeInsets.only(right: AppSpacing.sm),
                            child: FilterChip(
                              selected: onboarding.activeTimes.contains(slot),
                              showCheckmark: false,
                              avatar: Icon(availabilityIcon(slot), size: 18),
                              label: Text(availabilityLabel(l10n, slot)),
                              visualDensity: VisualDensity.compact,
                              onSelected: (_) =>
                                  controller.toggleActiveTime(slot),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppSectionCard(
            title: l10n.safetyTitle,
            subtitle: l10n.onboardingSafetyHint,
            child: Column(
              children: [
                _ChecklistRow(item: l10n.onboardingSafetyApproximateLocation),
                _ChecklistRow(item: l10n.onboardingSafetyReportBlock),
                SwitchListTile.adaptive(
                  value: onboarding.safeMeetupRemindersEnabled,
                  onChanged: controller.setSafeMeetupRemindersEnabled,
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.onboardingSafetyReminder),
                ),
                _ChecklistRow(item: l10n.onboardingSafetyVerification),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppSectionCard(
            title: l10n.onboardingCompletionTitle,
            subtitle:
                l10n.onboardingCompletionScore(onboarding.completionScore),
            child: LinearProgressIndicator(
              value: onboarding.completionScore / 100,
              minHeight: 10,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: FilledButton(
              onPressed: onboarding.canSubmit
                  ? () async {
                      final userId = ref.read(sessionControllerProvider).userId;
                      if (userId == null) {
                        return;
                      }
                      await ref.read(profileRepositoryProvider).saveProfile(
                            controller.toProfile(
                              userId: userId,
                            ),
                          );
                      ref
                          .read(settingsControllerProvider.notifier)
                          .setSafeMeetupRemindersEnabled(
                            onboarding.safeMeetupRemindersEnabled,
                          );
                      ref.read(analyticsServiceProvider).logEvent(
                        name: AnalyticsEvents.onboardingCompleted,
                        parameters: {
                          'completion_score': onboarding.completionScore,
                          'activities_count':
                              onboarding.favoriteActivities.length,
                        },
                      );
                      ref
                          .read(sessionControllerProvider.notifier)
                          .completeOnboarding();
                    }
                  : null,
              child: Text(l10n.finishSetup),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPhotoAvatar extends StatelessWidget {
  const _OnboardingPhotoAvatar({
    required this.photoUrl,
    required this.photoBytes,
    required this.semanticLabel,
  });

  final String photoUrl;
  final Object? photoBytes;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final bytes = photoBytes is Uint8List ? photoBytes as Uint8List : null;
    final imageProvider = bytes != null && bytes.isNotEmpty
        ? MemoryImage(bytes)
        : (photoUrl.startsWith('http://') || photoUrl.startsWith('https://'))
            ? NetworkImage(photoUrl)
            : null;

    return Semantics(
      image: true,
      label: semanticLabel,
      child: CircleAvatar(
        radius: 32,
        backgroundImage: imageProvider as ImageProvider<Object>?,
        child: imageProvider == null
            ? const Icon(Icons.person_outline, size: 28)
            : null,
      ),
    );
  }
}

String _onboardingPhotoMessage(
  BuildContext context,
  OnboardingState onboarding,
) {
  final l10n = AppLocalizations.of(context);
  switch (onboarding.profilePhotoIssue) {
    case ProfilePhotoValidationIssue.empty:
      return l10n.profilePhotoEmpty;
    case ProfilePhotoValidationIssue.unsupportedType:
      return l10n.profilePhotoUnsupportedType;
    case ProfilePhotoValidationIssue.tooLarge:
      return l10n.profilePhotoTooLarge;
    case null:
      return onboarding.profilePhotoUrl.isEmpty
          ? l10n.profilePhotoSectionSubtitle
          : l10n.profilePhotoReady;
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.item});

  final String item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.check_circle_outline),
      title: Text(item),
    );
  }
}
