// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get activePlansEmptyMessage =>
      'Publish a simple plan to start coordinating nearby.';

  @override
  String get activePlansEmptyTitle => 'No active plans yet';

  @override
  String activePlansLimit(int limit) {
    return 'You can keep up to $limit active plans at once.';
  }

  @override
  String get activePlansTitle => 'Your active plans';

  @override
  String get activitiesFocusSubtitle =>
      'Keep the current plan visible while you review requests.';

  @override
  String get activitiesFocusTitle => 'Primary plan';

  @override
  String get activitiesTitle => 'Create a plan';

  @override
  String get activity => 'Activity';

  @override
  String get activityChat => 'Chat';

  @override
  String get activityCoffee => 'Coffee';

  @override
  String get activityCowork => 'Cowork';

  @override
  String get activityEvent => 'Event';

  @override
  String get activityGames => 'Games';

  @override
  String get activityIndoor => 'Indoor';

  @override
  String get activityMovie => 'Movie';

  @override
  String get activityOutdoor => 'Outdoor';

  @override
  String get activitySports => 'Sports';

  @override
  String get activityStatusCancelled => 'Cancelled';

  @override
  String get activityStatusCompleted => 'Completed';

  @override
  String get activityStatusDraft => 'Draft';

  @override
  String get activityStatusFull => 'Full';

  @override
  String get activityStatusOpen => 'Open';

  @override
  String activityDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get activityWalk => 'Walk';

  @override
  String get analyticsAuthGuestPreviewSelected => 'Guest preview selected';

  @override
  String get analyticsAuthPhoneSelected => 'Phone sign-in selected';

  @override
  String get analyticsChatMessageSent => 'Chat message sent';

  @override
  String get analyticsExploreCategorySelected => 'Explore category selected';

  @override
  String get analyticsExploreSurfaceSelected => 'Explore surface selected';

  @override
  String get analyticsJoinRequestApproved => 'Join request approved';

  @override
  String get analyticsJoinRequestRejected => 'Join request rejected';

  @override
  String get analyticsJoinRequestSubmitted => 'Join request submitted';

  @override
  String get analyticsMapJoinRequestSubmitted => 'Map join request submitted';

  @override
  String get analyticsMapNearbyJoinRequestSubmitted =>
      'Nearby map join request submitted';

  @override
  String get analyticsOnboardingCompleted => 'Onboarding completed';

  @override
  String get analyticsPlanPublished => 'Plan published';

  @override
  String get analyticsProfileUpdated => 'Profile updated';

  @override
  String get analyticsSafetyReportSubmitted => 'Safety report submitted';

  @override
  String get analyticsSafetyUserBlocked => 'User blocked';

  @override
  String get analyticsSessionSignedOut => 'Signed out';

  @override
  String get analyticsSettingsLocationPrivacy => 'Approximate location updated';

  @override
  String get analyticsSettingsNotifications => 'Notifications updated';

  @override
  String get analyticsSettingsSafeMeetup => 'Safe meetup reminders updated';

  @override
  String analyticsSummaryAuth(int count) {
    return '$count auth actions';
  }

  @override
  String analyticsSummaryCoordination(int count) {
    return '$count coordination actions';
  }

  @override
  String analyticsSummarySafety(int count) {
    return '$count safety actions';
  }

  @override
  String get approveRequest => 'Approve';

  @override
  String get authSubtitle =>
      'Sign in to create nearby plans, join others, and coordinate in a low-pressure way.';

  @override
  String get authTitle => 'Start with a simple plan';

  @override
  String get authPhoneEmpty => 'Enter a phone number to continue.';

  @override
  String get authPhoneCodeSentMessage =>
      'We sent a verification code. Enter it below to finish phone sign-in.';

  @override
  String get authPhoneCodeSentTitle => 'Verification code sent';

  @override
  String get authCodeConfirm => 'Confirm code';

  @override
  String get authCodeEmpty => 'Enter the 6-digit verification code.';

  @override
  String get authCodeExpired =>
      'This verification code expired. Start phone sign-in again.';

  @override
  String get authCodeFieldHint => '123456';

  @override
  String get authCodeFieldLabel => 'Verification code';

  @override
  String get authCodeInvalid => 'Enter the latest 6-digit code we sent.';

  @override
  String get authCodeResend => 'Send code again';

  @override
  String get authCodeResent => 'We sent a new verification code.';

  @override
  String get authCodeSubmitting => 'Verifying code...';

  @override
  String get authCodeTooManyRequests =>
      'Too many attempts. Wait a bit and try again.';

  @override
  String get authPhoneFailed => 'Phone sign-in could not start right now.';

  @override
  String get authPhoneFieldHelper =>
      'Use a reachable number. Adding a country code like +90 keeps verification clearer.';

  @override
  String get authPhoneFieldHint => '+90 555 000 00 00';

  @override
  String get authPhoneFieldLabel => 'Phone number';

  @override
  String get authPhoneInvalid => 'Enter a valid phone number.';

  @override
  String get authPhoneSubmitting => 'Starting phone sign-in...';

  @override
  String get authPhoneUnsupported =>
      'Phone verification UI is not fully connected yet on this platform.';

  @override
  String get authPhoneVerificationPending =>
      'Enter the code we sent to finish sign-in.';

  @override
  String get availabilityAfternoons => 'Afternoons';

  @override
  String get availabilityEvenings => 'Evenings';

  @override
  String get availabilityMornings => 'Mornings';

  @override
  String get availabilityWeekends => 'Weekends';

  @override
  String get blockUser => 'Block user';

  @override
  String chatActivityLabel(String activityId) {
    return 'Activity: $activityId';
  }

  @override
  String get chatComposerHint => 'Share a practical message';

  @override
  String get chatEmptyMessage =>
      'Once a join request is approved, the conversation can stay focused on timing and meeting details.';

  @override
  String get chatEmptyTitle => 'No approved chats yet';

  @override
  String get chatHistoryEmpty => 'No messages yet.';

  @override
  String get chatHistoryTitle => 'Recent messages';

  @override
  String chatParticipantsCount(int count) {
    return '$count participants';
  }

  @override
  String get chatPrimaryThreadEmpty =>
      'Choose an approved thread to start coordinating.';

  @override
  String get chatPrimaryThreadSubtitle =>
      'Your main coordination thread stays pinned here.';

  @override
  String get chatPrimaryThreadTitle => 'Primary thread';

  @override
  String get chatQuickRepliesHint =>
      'Use short coordination replies to keep plans moving.';

  @override
  String get chatQuickRepliesTitle => 'Quick replies';

  @override
  String get chatSafetyBanner =>
      'Meet in a public, easy-to-find place and keep exact details in approved chat only.';

  @override
  String get chatThreadCreatedPreview =>
      'Approved request. You can coordinate here.';

  @override
  String get chatTitle => 'Coordination chat';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonOff => 'Off';

  @override
  String get commonOn => 'On';

  @override
  String get continueAsGuestPreview => 'Preview the experience';

  @override
  String get continueWithPhone => 'Continue with phone';

  @override
  String get createPlanField => 'Field';

  @override
  String get createPlanFieldCategory => 'Category';

  @override
  String get createPlanFieldCity => 'City';

  @override
  String get createPlanFieldDescription => 'Description';

  @override
  String get createPlanFieldDuration => 'Duration';

  @override
  String get createPlanFieldIndoor => 'Indoor setting';

  @override
  String get createPlanFieldLocation => 'Approximate location';

  @override
  String get createPlanFieldTime => 'Date and time';

  @override
  String get createPlanFieldTitle => 'Title';

  @override
  String get createPlanPickDateTime => 'Pick date and time';

  @override
  String get createPlanSubtitle =>
      'Keep the post short, specific, and easy to join.';

  @override
  String get createPlanTitle => 'Plan details';

  @override
  String get exploreCategoryAll => 'All';

  @override
  String get exploreCategoryFilters => 'Categories';

  @override
  String get exploreCategoryHint =>
      'Choose the kinds of plans you want to see first.';

  @override
  String get exploreDiscoveryHint =>
      'Time and proximity lead the experience, not endless browsing.';

  @override
  String get exploreDiscoverySections => 'Discovery surfaces';

  @override
  String get exploreEmptyMessage =>
      'Try another surface or create a plan so people can find you.';

  @override
  String get exploreEmptyTitle => 'No plans match this view';

  @override
  String get exploreReasonActivityMatch => 'Matches your preferred activities';

  @override
  String get exploreReasonGroupMatch => 'Fits your group preference';

  @override
  String get exploreReasonOpenNow => 'Open for quick coordination';

  @override
  String get exploreReasonTimeMatch => 'Fits your active time';

  @override
  String get exploreSafetyHint =>
      'Privacy and trust should stay clear while people make quick plans.';

  @override
  String get exploreSuggestedPlans => 'Suggested plans';

  @override
  String get exploreSuggestedReasonTitle => 'Why this fits';

  @override
  String get exploreTitle => 'Explore plans';

  @override
  String get finishSetup => 'Finish setup';

  @override
  String get groupPreferenceFlexible => 'Flexible';

  @override
  String get groupPreferenceOneOnOne => 'One-on-one';

  @override
  String get groupPreferenceSmallGroup => 'Small group';

  @override
  String get joinOwnPlanNotice => 'This is your plan.';

  @override
  String get joinPlan => 'Request to join';

  @override
  String get joinPlanFullNotice => 'This plan is already full.';

  @override
  String get joinRequestApprovedNotice => 'You are approved for this plan.';

  @override
  String get joinRequestAwaitingApproval => 'Awaiting approval.';

  @override
  String get joinRequestDefaultMessage =>
      'Hi, I can join and coordinate easily.';

  @override
  String get joinRequestDialogHint => 'Keep it short and practical.';

  @override
  String get joinRequestDialogTitle => 'Send a join request';

  @override
  String get joinRequestFieldLabel => 'Message';

  @override
  String get joinRequestPresetFlexible =>
      'I can adapt to the timing if needed.';

  @override
  String get joinRequestPresetNearby => 'I am nearby and can get there easily.';

  @override
  String get joinRequestPresetTimeFit => 'This time works well for me.';

  @override
  String get joinRequestPresetTitle => 'Quick message ideas';

  @override
  String get joinRequestRejectedNotice => 'This request was not approved.';

  @override
  String get joinRequestsEmpty => 'No join requests yet.';

  @override
  String get joinRequestsNoPlanSelected =>
      'Select or create a plan to review requests.';

  @override
  String joinRequestsPendingCount(int count) {
    return '$count pending requests';
  }

  @override
  String get joinRequestsSubtitle =>
      'Review requests and keep approvals lightweight.';

  @override
  String get joinRequestsTitle => 'Join requests';

  @override
  String get joinRequestSend => 'Send request';

  @override
  String get joinRequestSent => 'Join request sent.';

  @override
  String get mapNearbyPlansTitle => 'Nearby plans';

  @override
  String get mapPlaceholder => 'Approximate activity map preview';

  @override
  String get mapPrivacyApproximate => 'Approximate area visible';

  @override
  String get mapPrivacyHidden => 'Map visibility is hidden right now.';

  @override
  String get mapPrivacyMessage =>
      'Public maps should show area-level context, not exact meetup points.';

  @override
  String get mapPrivacyTitle => 'Approximate map only';

  @override
  String get mapRecommendedEmpty => 'No map suggestions yet.';

  @override
  String get mapRecommendedTitle => 'Recommended nearby';

  @override
  String get mapTitle => 'Nearby map';

  @override
  String get moodCalm => 'Calm';

  @override
  String get moodCasual => 'Casual';

  @override
  String get moodEnergetic => 'Energetic';

  @override
  String get moodFocused => 'Focused';

  @override
  String get moodGroupFriendly => 'Group-friendly';

  @override
  String get navChat => 'Chat';

  @override
  String get navExplore => 'Explore';

  @override
  String get navMap => 'Map';

  @override
  String get navPlans => 'Plans';

  @override
  String get navProfile => 'Profile';

  @override
  String get onboardingActivityPreferencesTitle => 'Favorite activity types';

  @override
  String get onboardingAvailabilityTitle => 'Availability';

  @override
  String onboardingCompletionScore(int score) {
    return '$score% complete';
  }

  @override
  String get onboardingCompletionTitle => 'Profile completion';

  @override
  String get onboardingFieldBio => 'Short bio';

  @override
  String get onboardingFieldCity => 'City';

  @override
  String get onboardingFieldGroupPreference => 'Group preference';

  @override
  String get onboardingFieldMood => 'Social mood';

  @override
  String get onboardingFieldName => 'Display name';

  @override
  String get onboardingItemAvailability => 'Availability and notifications';

  @override
  String get onboardingItemBio => 'Short bio and social style';

  @override
  String get onboardingItemIdentity => 'Display name and city';

  @override
  String get onboardingItemInterests => 'Interests and favorite activities';

  @override
  String get onboardingItemPhoto => 'Profile photo';

  @override
  String get onboardingProfileHint =>
      'Keep setup short, practical, and activity-first.';

  @override
  String get onboardingProfileSection => 'Profile essentials';

  @override
  String get onboardingSafetyApproximateLocation =>
      'Approximate location defaults';

  @override
  String get onboardingSafetyHint =>
      'Trust tools should be visible before the first meetup.';

  @override
  String get onboardingSafetyReminder => 'Meetup reminders';

  @override
  String get onboardingSafetyReportBlock => 'Report and block tools';

  @override
  String get onboardingSafetyVerification => 'Verification architecture';

  @override
  String get onboardingTitle => 'Build a trustworthy profile';

  @override
  String get openExploreAction => 'Open explore';

  @override
  String get openPlansAction => 'Open plans';

  @override
  String get openProfileAction => 'Open profile';

  @override
  String get openSafetyCenterAction => 'Open safety center';

  @override
  String get openSettingsAction => 'Open settings';

  @override
  String peopleCount(int current, int max) {
    return '$current/$max people';
  }

  @override
  String get planPublishedToast => 'Plan published.';

  @override
  String get profileAvailabilityTitle => 'Active times';

  @override
  String profileCompletion(int percent) {
    return '$percent% complete';
  }

  @override
  String get profileEditSubtitle =>
      'Adjust details that help people coordinate with you.';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profilePhotoAdd => 'Add photo';

  @override
  String get profilePhotoChange => 'Change photo';

  @override
  String get profilePhotoFailed => 'Profile photo could not be updated.';

  @override
  String get profilePhotoReady => 'Profile photo is ready to save.';

  @override
  String get profilePhotoSectionSubtitle =>
      'A clear, friendly photo helps people recognize you before a meetup.';

  @override
  String get profilePhotoSectionTitle => 'Profile photo';

  @override
  String get profilePhotoUpdated => 'Profile photo updated.';

  @override
  String get profilePhotoUploading => 'Uploading photo...';

  @override
  String get profileGateAction => 'Complete profile';

  @override
  String profileGateMessage(int completion) {
    return 'Complete at least $completion% of your profile to create and join plans confidently.';
  }

  @override
  String get profileGateTitle => 'Complete your profile first';

  @override
  String get profileGroupPreferenceTitle => 'Group preference';

  @override
  String profileMoodLabel(String mood) {
    return 'Social mood: $mood';
  }

  @override
  String get profileQuickActionsSubtitle =>
      'Jump to the trust and preference tools that matter most.';

  @override
  String get profileQuickActionsTitle => 'Quick actions';

  @override
  String get profileSaved => 'Profile saved.';

  @override
  String get profileTitle => 'Your profile';

  @override
  String get publishPlan => 'Publish plan';

  @override
  String get quickReplyConfirmTime => 'Can we confirm the time?';

  @override
  String get quickReplyOnMyWay => 'I am on my way.';

  @override
  String get quickReplyRunningLate => 'Running a little late.';

  @override
  String get quickReplyShareArea => 'I will share the approximate area.';

  @override
  String get rejectRequest => 'Reject';

  @override
  String get reportUser => 'Report user';

  @override
  String get requestStatusApproved => 'Approved';

  @override
  String get requestStatusCancelled => 'Cancelled';

  @override
  String get requestStatusPending => 'Pending';

  @override
  String get requestStatusRejected => 'Rejected';

  @override
  String safetyBlockedCount(int count) {
    return '$count blocked';
  }

  @override
  String get safetyBlockedUsersSubtitle =>
      'Blocked users stay hidden from lightweight coordination surfaces.';

  @override
  String get safetyBlockedUsersTitle => 'Blocked users';

  @override
  String get safetyCenterSubtitle =>
      'Trust tools should be simple, direct, and never buried.';

  @override
  String get safetyCenterTitle => 'Safety center';

  @override
  String get safetyEvent => 'Safety event';

  @override
  String get safetyEventInternal => 'Internal trust signal';

  @override
  String get safetyEventMeetupReminder => 'Meetup reminder enabled';

  @override
  String get safetyEventPhoneVerified => 'Phone verified';

  @override
  String get safetyEventReportSubmitted => 'Report submitted';

  @override
  String get safetyEventUserBlocked => 'User blocked';

  @override
  String get safetyEventVisible => 'Visible in your safety timeline';

  @override
  String get safetyReportAlreadySubmitted => 'Report already submitted';

  @override
  String safetyReportedCount(int count) {
    return '$count reports';
  }

  @override
  String get safetyReportSubmittedToast => 'Report submitted.';

  @override
  String get safetySummarySubtitle =>
      'A quick view of your recent trust actions.';

  @override
  String get safetySummaryTitle => 'Safety summary';

  @override
  String get safetyTimelineEmpty => 'No safety events yet.';

  @override
  String get safetyTimelineSubtitle =>
      'Important trust actions stay visible here.';

  @override
  String get safetyTimelineTitle => 'Safety timeline';

  @override
  String get safetyTitle => 'Safety';

  @override
  String get safetyUserAlreadyBlocked => 'User already blocked';

  @override
  String get safetyUserBlockedToast => 'User blocked.';

  @override
  String get saveProfile => 'Save profile';

  @override
  String get settingsApproximateLocation => 'Use approximate location';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsPreferencesSubtitle =>
      'Tune privacy, reminders, and coordination defaults.';

  @override
  String get settingsProfileShortcutSubtitle =>
      'Open your profile and update visible details.';

  @override
  String get settingsSafeMeetupReminders => 'Safe meetup reminders';

  @override
  String get settingsSafetyLinkSubtitle =>
      'Open reporting, blocking, and trust timeline tools.';

  @override
  String get settingsSafetyLinkTitle => 'Safety tools';

  @override
  String get settingsSignalsEmpty => 'No recent signals yet.';

  @override
  String get settingsSignalsSubtitle =>
      'Recent product and trust actions show up here.';

  @override
  String get settingsSignalsSummarySubtitle =>
      'A quick count of recent auth, safety, and coordination actions.';

  @override
  String get settingsSignalsSummaryTitle => 'Signals summary';

  @override
  String get settingsSignalsTitle => 'Recent signals';

  @override
  String get settingsSummarySubtitle =>
      'Review your current coordination preferences.';

  @override
  String get settingsSummaryTitle => 'Current settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get signOut => 'Sign out';

  @override
  String get surfaceGroups => 'Groups';

  @override
  String get surfaceNearby => 'Nearby';

  @override
  String get surfaceNow => 'Now';

  @override
  String get surfaceTonight => 'Tonight';

  @override
  String get surfaceWeekend => 'Weekend';

  @override
  String get trustApprovalDescription =>
      'Chat opens only after the plan owner approves the request.';

  @override
  String get trustApprovalLabel => 'Approval before chat';

  @override
  String get trustApproximateLocationDescription =>
      'Public discovery stays at area level by default.';

  @override
  String get trustApproximateLocationLabel => 'Approximate location';

  @override
  String get trustToolsDescription =>
      'Report and block tools stay easy to reach.';

  @override
  String get trustToolsLabel => 'Trust tools';

  @override
  String get verificationPhone => 'Phone verified';
}
