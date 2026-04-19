import 'dart:typed_data';

import 'package:aktivite/app/app_routes.dart';
import 'package:aktivite/core/constants/app_spacing.dart';
import 'package:aktivite/core/utils/app_feedback.dart';
import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/availability_slot.dart';
import 'package:aktivite/core/enums/group_preference.dart';
import 'package:aktivite/core/enums/social_mood.dart';
import 'package:aktivite/core/utils/analytics_events.dart';
import 'package:aktivite/core/utils/localized_labels.dart';
import 'package:aktivite/core/utils/profile_photo_policy.dart';
import 'package:aktivite/features/profile/application/profile_editor_controller.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/providers/app_providers.dart';
import 'package:aktivite/shared/providers/profile_media_providers.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:aktivite/shared/widgets/app_section_card.dart';
import 'package:aktivite/shared/widgets/async_value_view.dart';
import 'package:aktivite/shared/widgets/route_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  static const routePath = AppRoutes.profile;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _cityController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(currentUserProfileProvider);
    final editor = ref.watch(profileEditorControllerProvider);
    final editorController = ref.read(profileEditorControllerProvider.notifier);

    final profile = profileAsync.valueOrNull;
    if (profile != null && !editor.hasSeeded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(profileEditorControllerProvider.notifier)
            .seedFromProfile(profile);
      });
    }

    if (_nameController.text != editor.displayName) {
      _nameController.value = TextEditingValue(
        text: editor.displayName,
        selection: TextSelection.collapsed(offset: editor.displayName.length),
      );
    }
    if (_cityController.text != editor.city) {
      _cityController.value = TextEditingValue(
        text: editor.city,
        selection: TextSelection.collapsed(offset: editor.city.length),
      );
    }
    if (_bioController.text != editor.bio) {
      _bioController.value = TextEditingValue(
        text: editor.bio,
        selection: TextSelection.collapsed(offset: editor.bio.length),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: [
          IconButton(
            onPressed: () => context.go(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          profileAsync.when(
            data: (loadedProfile) => AppSectionCard(
              title: loadedProfile.displayName,
              subtitle:
                  '${loadedProfile.city} - ${verificationLabel(l10n, loadedProfile.verificationLabel)}',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: _ProfilePhotoAvatar(
                      photoUrl: loadedProfile.profilePhotoUrl,
                      semanticLabel: l10n.profilePhotoSectionTitle,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(loadedProfile.bio),
                  const SizedBox(height: AppSpacing.md),
                  LinearProgressIndicator(
                    value: loadedProfile.profileCompletion / 100,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.profileCompletion(loadedProfile.profileCompletion),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: loadedProfile.favoriteActivities
                        .map(
                          (activity) => Chip(
                            label: Text(activityLabel(l10n, activity)),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.profileMoodLabel(
                      moodLabel(l10n, loadedProfile.socialMood),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '${l10n.profileGroupPreferenceTitle}: ${groupPreferenceLabel(l10n, loadedProfile.groupPreference)}',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.profileAvailabilityTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: loadedProfile.activeTimes
                        .map(
                          (slot) => Chip(
                            label: Text(availabilityLabel(l10n, slot)),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
              ),
            ),
            loading: () => const AsyncLoadingView(),
            error: (error, stackTrace) =>
                AsyncErrorView(message: error.toString()),
          ),
          const SizedBox(height: AppSpacing.md),
          AppSectionCard(
            title: l10n.profileQuickActionsTitle,
            subtitle: l10n.profileQuickActionsSubtitle,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                RouteActionButton(
                  label: l10n.openSafetyCenterAction,
                  route: AppRoutes.safety,
                ),
                RouteActionButton(
                  label: l10n.openSettingsAction,
                  route: AppRoutes.settings,
                  tonal: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppSectionCard(
            title: l10n.profileEditTitle,
            subtitle: l10n.profileEditSubtitle,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.profilePhotoSectionTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ProfilePhotoAvatar(
                  photoUrl: editor.profilePhotoUrl,
                  photoBytes: editor.profilePhotoBytes,
                  semanticLabel: l10n.profilePhotoSectionTitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _profilePhotoMessage(context, editor),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: profile == null || editor.isUploadingPhoto
                          ? null
                          : () async {
                              final success =
                                  await editorController.uploadProfilePhoto(
                                userId: profile.id,
                                picker:
                                    ref.read(profilePhotoPickerServiceProvider),
                                storage: ref
                                    .read(profilePhotoStorageServiceProvider),
                              );
                              if (!context.mounted) {
                                return;
                              }
                              showAppSnackBar(
                                context,
                                success
                                    ? l10n.profilePhotoUpdated
                                    : _profilePhotoMessage(
                                        context,
                                        ref.read(
                                            profileEditorControllerProvider),
                                      ),
                              );
                            },
                      child: Text(
                        editor.isUploadingPhoto
                            ? l10n.profilePhotoUploading
                            : editor.profilePhotoUrl.isEmpty
                                ? l10n.profilePhotoAdd
                                : l10n.profilePhotoChange,
                      ),
                    ),
                    if (editor.profilePhotoUrl.isNotEmpty ||
                        editor.profilePhotoBytes != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      TextButton(
                        onPressed: editor.isUploadingPhoto
                            ? null
                            : editorController.removeProfilePhoto,
                        child: Text(l10n.profilePhotoRemove),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _nameController,
                  onChanged: editorController.setDisplayName,
                  decoration: InputDecoration(
                    labelText: l10n.onboardingFieldName,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _cityController,
                  onChanged: editorController.setCity,
                  decoration: InputDecoration(
                    labelText: l10n.onboardingFieldCity,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _bioController,
                  onChanged: editorController.setBio,
                  minLines: 2,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.onboardingFieldBio,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<SocialMood>(
                  initialValue: editor.socialMood,
                  decoration: InputDecoration(
                    labelText: l10n.onboardingFieldMood,
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
                      editorController.setSocialMood(value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<GroupPreference>(
                  initialValue: editor.groupPreference,
                  decoration: InputDecoration(
                    labelText: l10n.onboardingFieldGroupPreference,
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
                      editorController.setGroupPreference(value);
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
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: ActivityCategory.values
                      .map(
                        (activity) => FilterChip(
                          selected:
                              editor.favoriteActivities.contains(activity),
                          label: Text(activityLabel(l10n, activity)),
                          onSelected: (_) =>
                              editorController.toggleActivity(activity),
                        ),
                      )
                      .toList(growable: false),
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
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: AvailabilitySlot.values
                      .map(
                        (slot) => FilterChip(
                          selected: editor.activeTimes.contains(slot),
                          label: Text(availabilityLabel(l10n, slot)),
                          onSelected: (_) =>
                              editorController.toggleActiveTime(slot),
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.profileCompletion(editor.completionScore),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: profile == null || !editor.canSubmit
                        ? null
                        : () async {
                            await editorController.save(
                              ref.read(profileRepositoryProvider),
                              profile,
                            );
                            await ref.read(analyticsServiceProvider).logEvent(
                              name: AnalyticsEvents.profileUpdated,
                              parameters: {
                                'completion': editor.completionScore,
                              },
                            );
                            if (!context.mounted) {
                              return;
                            }
                            showAppSnackBar(context, l10n.profileSaved);
                          },
                    child: Text(l10n.saveProfile),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePhotoAvatar extends StatelessWidget {
  const _ProfilePhotoAvatar({
    this.photoUrl = '',
    this.photoBytes,
    required this.semanticLabel,
  });

  final String photoUrl;
  final Uint8List? photoBytes;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final imageProvider = _imageProvider();
    return Semantics(
      image: true,
      label: semanticLabel,
      child: CircleAvatar(
        radius: 36,
        backgroundImage: imageProvider,
        child: imageProvider == null
            ? const Icon(Icons.person_outline, size: 32)
            : null,
      ),
    );
  }

  ImageProvider<Object>? _imageProvider() {
    if (photoBytes != null && photoBytes!.isNotEmpty) {
      return MemoryImage(photoBytes!);
    }
    if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
      return NetworkImage(photoUrl);
    }
    return null;
  }
}

String _profilePhotoMessage(
  BuildContext context,
  ProfileEditorState editor,
) {
  final l10n = AppLocalizations.of(context);
  switch (editor.profilePhotoIssue) {
    case ProfilePhotoValidationIssue.empty:
      return l10n.profilePhotoEmpty;
    case ProfilePhotoValidationIssue.unsupportedType:
      return l10n.profilePhotoUnsupportedType;
    case ProfilePhotoValidationIssue.tooLarge:
      return l10n.profilePhotoTooLarge;
    case null:
      return editor.profilePhotoUrl.isEmpty
          ? l10n.profilePhotoSectionSubtitle
          : l10n.profilePhotoReady;
  }
}
