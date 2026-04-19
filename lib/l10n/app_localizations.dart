import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @activePlansEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Publish a simple plan to start coordinating nearby.'**
  String get activePlansEmptyMessage;

  /// No description provided for @activePlansEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No active plans yet'**
  String get activePlansEmptyTitle;

  /// No description provided for @activePlansLimit.
  ///
  /// In en, this message translates to:
  /// **'You can keep up to {limit} active plans at once.'**
  String activePlansLimit(int limit);

  /// No description provided for @activePlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Your active plans'**
  String get activePlansTitle;

  /// No description provided for @activitiesFocusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the current plan visible while you review requests.'**
  String get activitiesFocusSubtitle;

  /// No description provided for @activitiesFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Primary plan'**
  String get activitiesFocusTitle;

  /// No description provided for @activitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a plan'**
  String get activitiesTitle;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @activityChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get activityChat;

  /// No description provided for @activityCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get activityCoffee;

  /// No description provided for @activityCowork.
  ///
  /// In en, this message translates to:
  /// **'Cowork'**
  String get activityCowork;

  /// No description provided for @activityEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get activityEvent;

  /// No description provided for @activityGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get activityGames;

  /// No description provided for @activityIndoor.
  ///
  /// In en, this message translates to:
  /// **'Indoor'**
  String get activityIndoor;

  /// No description provided for @activityMovie.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get activityMovie;

  /// No description provided for @activityOutdoor.
  ///
  /// In en, this message translates to:
  /// **'Outdoor'**
  String get activityOutdoor;

  /// No description provided for @activitySports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get activitySports;

  /// No description provided for @activityStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get activityStatusCancelled;

  /// No description provided for @activityStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get activityStatusCompleted;

  /// No description provided for @activityStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get activityStatusDraft;

  /// No description provided for @activityStatusFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get activityStatusFull;

  /// No description provided for @activityStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get activityStatusOpen;

  /// No description provided for @activityDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String activityDurationMinutes(int minutes);

  /// No description provided for @activityWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get activityWalk;

  /// No description provided for @analyticsAuthGuestPreviewSelected.
  ///
  /// In en, this message translates to:
  /// **'Guest preview selected'**
  String get analyticsAuthGuestPreviewSelected;

  /// No description provided for @analyticsAuthPhoneSelected.
  ///
  /// In en, this message translates to:
  /// **'Phone sign-in selected'**
  String get analyticsAuthPhoneSelected;

  /// No description provided for @analyticsChatMessageSent.
  ///
  /// In en, this message translates to:
  /// **'Chat message sent'**
  String get analyticsChatMessageSent;

  /// No description provided for @analyticsExploreCategorySelected.
  ///
  /// In en, this message translates to:
  /// **'Explore category selected'**
  String get analyticsExploreCategorySelected;

  /// No description provided for @analyticsExploreSurfaceSelected.
  ///
  /// In en, this message translates to:
  /// **'Explore surface selected'**
  String get analyticsExploreSurfaceSelected;

  /// No description provided for @analyticsJoinRequestApproved.
  ///
  /// In en, this message translates to:
  /// **'Join request approved'**
  String get analyticsJoinRequestApproved;

  /// No description provided for @analyticsJoinRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Join request rejected'**
  String get analyticsJoinRequestRejected;

  /// No description provided for @analyticsJoinRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Join request submitted'**
  String get analyticsJoinRequestSubmitted;

  /// No description provided for @analyticsMapJoinRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Map join request submitted'**
  String get analyticsMapJoinRequestSubmitted;

  /// No description provided for @analyticsMapNearbyJoinRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Nearby map join request submitted'**
  String get analyticsMapNearbyJoinRequestSubmitted;

  /// No description provided for @analyticsOnboardingCompleted.
  ///
  /// In en, this message translates to:
  /// **'Onboarding completed'**
  String get analyticsOnboardingCompleted;

  /// No description provided for @analyticsPlanPublished.
  ///
  /// In en, this message translates to:
  /// **'Plan published'**
  String get analyticsPlanPublished;

  /// No description provided for @analyticsProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get analyticsProfileUpdated;

  /// No description provided for @analyticsSafetyReportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Safety report submitted'**
  String get analyticsSafetyReportSubmitted;

  /// No description provided for @analyticsSafetyUserBlocked.
  ///
  /// In en, this message translates to:
  /// **'User blocked'**
  String get analyticsSafetyUserBlocked;

  /// No description provided for @analyticsSessionSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get analyticsSessionSignedOut;

  /// No description provided for @analyticsSettingsLocationPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Approximate location updated'**
  String get analyticsSettingsLocationPrivacy;

  /// No description provided for @analyticsSettingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications updated'**
  String get analyticsSettingsNotifications;

  /// No description provided for @analyticsSettingsSafeMeetup.
  ///
  /// In en, this message translates to:
  /// **'Safe meetup reminders updated'**
  String get analyticsSettingsSafeMeetup;

  /// No description provided for @analyticsSummaryAuth.
  ///
  /// In en, this message translates to:
  /// **'{count} auth actions'**
  String analyticsSummaryAuth(int count);

  /// No description provided for @analyticsSummaryCoordination.
  ///
  /// In en, this message translates to:
  /// **'{count} coordination actions'**
  String analyticsSummaryCoordination(int count);

  /// No description provided for @analyticsSummarySafety.
  ///
  /// In en, this message translates to:
  /// **'{count} safety actions'**
  String analyticsSummarySafety(int count);

  /// No description provided for @approveRequest.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveRequest;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to create nearby plans, join others, and coordinate in a low-pressure way.'**
  String get authSubtitle;

  /// No description provided for @authTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with a simple plan'**
  String get authTitle;

  /// No description provided for @authPhoneEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a phone number to continue.'**
  String get authPhoneEmpty;

  /// No description provided for @authPhoneCodeSentMessage.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code. Enter it below to finish phone sign-in.'**
  String get authPhoneCodeSentMessage;

  /// No description provided for @authPhoneCodeSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent'**
  String get authPhoneCodeSentTitle;

  /// No description provided for @authCodeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm code'**
  String get authCodeConfirm;

  /// No description provided for @authCodeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit verification code.'**
  String get authCodeEmpty;

  /// No description provided for @authCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'This verification code expired. Start phone sign-in again.'**
  String get authCodeExpired;

  /// No description provided for @authCodeFieldHint.
  ///
  /// In en, this message translates to:
  /// **'123456'**
  String get authCodeFieldHint;

  /// No description provided for @authCodeFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get authCodeFieldLabel;

  /// No description provided for @authCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the latest 6-digit code we sent.'**
  String get authCodeInvalid;

  /// No description provided for @authCodeResend.
  ///
  /// In en, this message translates to:
  /// **'Send code again'**
  String get authCodeResend;

  /// No description provided for @authCodeResent.
  ///
  /// In en, this message translates to:
  /// **'We sent a new verification code.'**
  String get authCodeResent;

  /// No description provided for @authCodeSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Verifying code...'**
  String get authCodeSubmitting;

  /// No description provided for @authCodeTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a bit and try again.'**
  String get authCodeTooManyRequests;

  /// No description provided for @authPhoneFailed.
  ///
  /// In en, this message translates to:
  /// **'Phone sign-in could not start right now.'**
  String get authPhoneFailed;

  /// No description provided for @authPhoneFieldHelper.
  ///
  /// In en, this message translates to:
  /// **'Use a reachable number. Adding a country code like +90 keeps verification clearer.'**
  String get authPhoneFieldHelper;

  /// No description provided for @authPhoneFieldHint.
  ///
  /// In en, this message translates to:
  /// **'+90 555 000 00 00'**
  String get authPhoneFieldHint;

  /// No description provided for @authPhoneFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get authPhoneFieldLabel;

  /// No description provided for @authPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number.'**
  String get authPhoneInvalid;

  /// No description provided for @authPhoneSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Starting phone sign-in...'**
  String get authPhoneSubmitting;

  /// No description provided for @authPhoneUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Phone verification UI is not fully connected yet on this platform.'**
  String get authPhoneUnsupported;

  /// No description provided for @authPhoneVerificationPending.
  ///
  /// In en, this message translates to:
  /// **'Enter the code we sent to finish sign-in.'**
  String get authPhoneVerificationPending;

  /// No description provided for @availabilityAfternoons.
  ///
  /// In en, this message translates to:
  /// **'Afternoons'**
  String get availabilityAfternoons;

  /// No description provided for @availabilityEvenings.
  ///
  /// In en, this message translates to:
  /// **'Evenings'**
  String get availabilityEvenings;

  /// No description provided for @availabilityMornings.
  ///
  /// In en, this message translates to:
  /// **'Mornings'**
  String get availabilityMornings;

  /// No description provided for @availabilityWeekends.
  ///
  /// In en, this message translates to:
  /// **'Weekends'**
  String get availabilityWeekends;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get blockUser;

  /// No description provided for @chatActivityLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity: {activityId}'**
  String chatActivityLabel(String activityId);

  /// No description provided for @chatBlockedThreadsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Chats connected to blocked users stay hidden from your coordination space.'**
  String get chatBlockedThreadsEmptyMessage;

  /// No description provided for @chatBlockedThreadsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Blocked chats stay hidden'**
  String get chatBlockedThreadsEmptyTitle;

  /// No description provided for @chatComposerHint.
  ///
  /// In en, this message translates to:
  /// **'Share a practical message'**
  String get chatComposerHint;

  /// No description provided for @chatEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Once a join request is approved, the conversation can stay focused on timing and meeting details.'**
  String get chatEmptyMessage;

  /// No description provided for @chatEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No approved chats yet'**
  String get chatEmptyTitle;

  /// No description provided for @chatHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.'**
  String get chatHistoryEmpty;

  /// No description provided for @chatHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent messages'**
  String get chatHistoryTitle;

  /// No description provided for @chatMessageSendFailedToast.
  ///
  /// In en, this message translates to:
  /// **'Message could not be sent right now.'**
  String get chatMessageSendFailedToast;

  /// No description provided for @chatParticipantsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} participants'**
  String chatParticipantsCount(int count);

  /// No description provided for @chatPrimaryThreadEmpty.
  ///
  /// In en, this message translates to:
  /// **'Choose an approved thread to start coordinating.'**
  String get chatPrimaryThreadEmpty;

  /// No description provided for @chatPrimaryThreadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your main coordination thread stays pinned here.'**
  String get chatPrimaryThreadSubtitle;

  /// No description provided for @chatPrimaryThreadTitle.
  ///
  /// In en, this message translates to:
  /// **'Primary thread'**
  String get chatPrimaryThreadTitle;

  /// No description provided for @chatQuickRepliesHint.
  ///
  /// In en, this message translates to:
  /// **'Use short coordination replies to keep plans moving.'**
  String get chatQuickRepliesHint;

  /// No description provided for @chatQuickRepliesTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick replies'**
  String get chatQuickRepliesTitle;

  /// No description provided for @chatSafetyBanner.
  ///
  /// In en, this message translates to:
  /// **'Meet in a public, easy-to-find place and keep exact details in approved chat only.'**
  String get chatSafetyBanner;

  /// No description provided for @chatThreadCreatedPreview.
  ///
  /// In en, this message translates to:
  /// **'Approved request. You can coordinate here.'**
  String get chatThreadCreatedPreview;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Coordination chat'**
  String get chatTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get commonOff;

  /// No description provided for @commonOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get commonOn;

  /// No description provided for @continueAsGuestPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview the experience'**
  String get continueAsGuestPreview;

  /// No description provided for @continueWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Continue with phone'**
  String get continueWithPhone;

  /// No description provided for @createPlanField.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get createPlanField;

  /// No description provided for @createPlanFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get createPlanFieldCategory;

  /// No description provided for @createPlanFieldCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get createPlanFieldCity;

  /// No description provided for @createPlanFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get createPlanFieldDescription;

  /// No description provided for @createPlanFieldDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get createPlanFieldDuration;

  /// No description provided for @createPlanFieldIndoor.
  ///
  /// In en, this message translates to:
  /// **'Indoor setting'**
  String get createPlanFieldIndoor;

  /// No description provided for @createPlanFieldLocation.
  ///
  /// In en, this message translates to:
  /// **'Approximate location'**
  String get createPlanFieldLocation;

  /// No description provided for @createPlanFieldTime.
  ///
  /// In en, this message translates to:
  /// **'Date and time'**
  String get createPlanFieldTime;

  /// No description provided for @createPlanFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get createPlanFieldTitle;

  /// No description provided for @createPlanPickDateTime.
  ///
  /// In en, this message translates to:
  /// **'Pick date and time'**
  String get createPlanPickDateTime;

  /// No description provided for @createPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the post short, specific, and easy to join.'**
  String get createPlanSubtitle;

  /// No description provided for @createPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan details'**
  String get createPlanTitle;

  /// No description provided for @exploreCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get exploreCategoryAll;

  /// No description provided for @exploreCategoryFilters.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get exploreCategoryFilters;

  /// No description provided for @exploreCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the kinds of plans you want to see first.'**
  String get exploreCategoryHint;

  /// No description provided for @exploreDiscoveryHint.
  ///
  /// In en, this message translates to:
  /// **'Time and proximity lead the experience, not endless browsing.'**
  String get exploreDiscoveryHint;

  /// No description provided for @exploreDiscoverySections.
  ///
  /// In en, this message translates to:
  /// **'Discovery surfaces'**
  String get exploreDiscoverySections;

  /// No description provided for @exploreEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Try another surface or create a plan so people can find you.'**
  String get exploreEmptyMessage;

  /// No description provided for @exploreEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No plans match this view'**
  String get exploreEmptyTitle;

  /// No description provided for @exploreReasonActivityMatch.
  ///
  /// In en, this message translates to:
  /// **'Matches your preferred activities'**
  String get exploreReasonActivityMatch;

  /// No description provided for @exploreReasonGroupMatch.
  ///
  /// In en, this message translates to:
  /// **'Fits your group preference'**
  String get exploreReasonGroupMatch;

  /// No description provided for @exploreReasonOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Open for quick coordination'**
  String get exploreReasonOpenNow;

  /// No description provided for @exploreReasonTimeMatch.
  ///
  /// In en, this message translates to:
  /// **'Fits your active time'**
  String get exploreReasonTimeMatch;

  /// No description provided for @exploreSafetyHint.
  ///
  /// In en, this message translates to:
  /// **'Privacy and trust should stay clear while people make quick plans.'**
  String get exploreSafetyHint;

  /// No description provided for @exploreSuggestedPlans.
  ///
  /// In en, this message translates to:
  /// **'Suggested plans'**
  String get exploreSuggestedPlans;

  /// No description provided for @exploreSuggestedReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Why this fits'**
  String get exploreSuggestedReasonTitle;

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore plans'**
  String get exploreTitle;

  /// No description provided for @finishSetup.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get finishSetup;

  /// No description provided for @groupPreferenceFlexible.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get groupPreferenceFlexible;

  /// No description provided for @groupPreferenceOneOnOne.
  ///
  /// In en, this message translates to:
  /// **'One-on-one'**
  String get groupPreferenceOneOnOne;

  /// No description provided for @groupPreferenceSmallGroup.
  ///
  /// In en, this message translates to:
  /// **'Small group'**
  String get groupPreferenceSmallGroup;

  /// No description provided for @joinOwnPlanNotice.
  ///
  /// In en, this message translates to:
  /// **'This is your plan.'**
  String get joinOwnPlanNotice;

  /// No description provided for @joinPlan.
  ///
  /// In en, this message translates to:
  /// **'Request to join'**
  String get joinPlan;

  /// No description provided for @joinPlanFullNotice.
  ///
  /// In en, this message translates to:
  /// **'This plan is already full.'**
  String get joinPlanFullNotice;

  /// No description provided for @joinRequestApprovedNotice.
  ///
  /// In en, this message translates to:
  /// **'You are approved for this plan.'**
  String get joinRequestApprovedNotice;

  /// No description provided for @joinRequestApprovedFirebaseNotice.
  ///
  /// In en, this message translates to:
  /// **'Request approved. Chat will open after backend checks finish.'**
  String get joinRequestApprovedFirebaseNotice;

  /// No description provided for @joinRequestApprovedLocalNotice.
  ///
  /// In en, this message translates to:
  /// **'Request approved. Coordination chat is ready.'**
  String get joinRequestApprovedLocalNotice;

  /// No description provided for @joinRequestAwaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Awaiting approval.'**
  String get joinRequestAwaitingApproval;

  /// No description provided for @joinRequestCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get joinRequestCancel;

  /// No description provided for @joinRequestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Join request cancelled.'**
  String get joinRequestCancelled;

  /// No description provided for @joinRequestDefaultMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi, I can join and coordinate easily.'**
  String get joinRequestDefaultMessage;

  /// No description provided for @joinRequestDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Keep it short and practical.'**
  String get joinRequestDialogHint;

  /// No description provided for @joinRequestDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a join request'**
  String get joinRequestDialogTitle;

  /// No description provided for @joinRequestFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get joinRequestFieldLabel;

  /// No description provided for @joinRequestPresetFlexible.
  ///
  /// In en, this message translates to:
  /// **'I can adapt to the timing if needed.'**
  String get joinRequestPresetFlexible;

  /// No description provided for @joinRequestPresetNearby.
  ///
  /// In en, this message translates to:
  /// **'I am nearby and can get there easily.'**
  String get joinRequestPresetNearby;

  /// No description provided for @joinRequestPresetTimeFit.
  ///
  /// In en, this message translates to:
  /// **'This time works well for me.'**
  String get joinRequestPresetTimeFit;

  /// No description provided for @joinRequestPresetTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick message ideas'**
  String get joinRequestPresetTitle;

  /// No description provided for @joinRequestRejectedNotice.
  ///
  /// In en, this message translates to:
  /// **'This request was not approved.'**
  String get joinRequestRejectedNotice;

  /// No description provided for @joinRequestRejectedLocalNotice.
  ///
  /// In en, this message translates to:
  /// **'Request rejected.'**
  String get joinRequestRejectedLocalNotice;

  /// No description provided for @joinRequestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No join requests yet.'**
  String get joinRequestsEmpty;

  /// No description provided for @joinRequestsNoPlanSelected.
  ///
  /// In en, this message translates to:
  /// **'Select or create a plan to review requests.'**
  String get joinRequestsNoPlanSelected;

  /// No description provided for @joinRequestsPendingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pending requests'**
  String joinRequestsPendingCount(int count);

  /// No description provided for @joinRequestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review requests and keep approvals lightweight.'**
  String get joinRequestsSubtitle;

  /// No description provided for @joinRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Join requests'**
  String get joinRequestsTitle;

  /// No description provided for @joinRequestSend.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get joinRequestSend;

  /// No description provided for @joinRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Join request sent.'**
  String get joinRequestSent;

  /// No description provided for @mapNearbyPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby plans'**
  String get mapNearbyPlansTitle;

  /// No description provided for @mapPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Approximate activity map preview'**
  String get mapPlaceholder;

  /// No description provided for @mapPrivacyApproximate.
  ///
  /// In en, this message translates to:
  /// **'Approximate area visible'**
  String get mapPrivacyApproximate;

  /// No description provided for @mapPrivacyHidden.
  ///
  /// In en, this message translates to:
  /// **'Map visibility is hidden right now.'**
  String get mapPrivacyHidden;

  /// No description provided for @mapPrivacyMessage.
  ///
  /// In en, this message translates to:
  /// **'Public maps should show area-level context, not exact meetup points.'**
  String get mapPrivacyMessage;

  /// No description provided for @mapPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Approximate map only'**
  String get mapPrivacyTitle;

  /// No description provided for @mapRecommendedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No map suggestions yet.'**
  String get mapRecommendedEmpty;

  /// No description provided for @mapRecommendedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended nearby'**
  String get mapRecommendedTitle;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby map'**
  String get mapTitle;

  /// No description provided for @moodCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get moodCalm;

  /// No description provided for @moodCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get moodCasual;

  /// No description provided for @moodEnergetic.
  ///
  /// In en, this message translates to:
  /// **'Energetic'**
  String get moodEnergetic;

  /// No description provided for @moodFocused.
  ///
  /// In en, this message translates to:
  /// **'Focused'**
  String get moodFocused;

  /// No description provided for @moodGroupFriendly.
  ///
  /// In en, this message translates to:
  /// **'Group-friendly'**
  String get moodGroupFriendly;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navPlans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get navPlans;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @onboardingActivityPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorite activity types'**
  String get onboardingActivityPreferencesTitle;

  /// No description provided for @onboardingAvailabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get onboardingAvailabilityTitle;

  /// No description provided for @onboardingCompletionScore.
  ///
  /// In en, this message translates to:
  /// **'{score}% complete'**
  String onboardingCompletionScore(int score);

  /// No description provided for @onboardingCompletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile completion'**
  String get onboardingCompletionTitle;

  /// No description provided for @onboardingFieldBio.
  ///
  /// In en, this message translates to:
  /// **'Short bio'**
  String get onboardingFieldBio;

  /// No description provided for @onboardingFieldCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get onboardingFieldCity;

  /// No description provided for @onboardingFieldGroupPreference.
  ///
  /// In en, this message translates to:
  /// **'Group preference'**
  String get onboardingFieldGroupPreference;

  /// No description provided for @onboardingFieldMood.
  ///
  /// In en, this message translates to:
  /// **'Social mood'**
  String get onboardingFieldMood;

  /// No description provided for @onboardingFieldName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get onboardingFieldName;

  /// No description provided for @onboardingItemAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability and notifications'**
  String get onboardingItemAvailability;

  /// No description provided for @onboardingItemBio.
  ///
  /// In en, this message translates to:
  /// **'Short bio and social style'**
  String get onboardingItemBio;

  /// No description provided for @onboardingItemIdentity.
  ///
  /// In en, this message translates to:
  /// **'Display name and city'**
  String get onboardingItemIdentity;

  /// No description provided for @onboardingItemInterests.
  ///
  /// In en, this message translates to:
  /// **'Interests and favorite activities'**
  String get onboardingItemInterests;

  /// No description provided for @onboardingItemPhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get onboardingItemPhoto;

  /// No description provided for @onboardingProfileHint.
  ///
  /// In en, this message translates to:
  /// **'Keep setup short, practical, and activity-first.'**
  String get onboardingProfileHint;

  /// No description provided for @onboardingProfileSection.
  ///
  /// In en, this message translates to:
  /// **'Profile essentials'**
  String get onboardingProfileSection;

  /// No description provided for @onboardingSafetyApproximateLocation.
  ///
  /// In en, this message translates to:
  /// **'Approximate location defaults'**
  String get onboardingSafetyApproximateLocation;

  /// No description provided for @onboardingSafetyHint.
  ///
  /// In en, this message translates to:
  /// **'Trust tools should be visible before the first meetup.'**
  String get onboardingSafetyHint;

  /// No description provided for @onboardingSafetyReminder.
  ///
  /// In en, this message translates to:
  /// **'Meetup reminders'**
  String get onboardingSafetyReminder;

  /// No description provided for @onboardingSafetyReportBlock.
  ///
  /// In en, this message translates to:
  /// **'Report and block tools'**
  String get onboardingSafetyReportBlock;

  /// No description provided for @onboardingSafetyVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification architecture'**
  String get onboardingSafetyVerification;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Build a trustworthy profile'**
  String get onboardingTitle;

  /// No description provided for @openExploreAction.
  ///
  /// In en, this message translates to:
  /// **'Open explore'**
  String get openExploreAction;

  /// No description provided for @openPlansAction.
  ///
  /// In en, this message translates to:
  /// **'Open plans'**
  String get openPlansAction;

  /// No description provided for @openProfileAction.
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get openProfileAction;

  /// No description provided for @openSafetyCenterAction.
  ///
  /// In en, this message translates to:
  /// **'Open safety center'**
  String get openSafetyCenterAction;

  /// No description provided for @openSettingsAction.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettingsAction;

  /// No description provided for @peopleCount.
  ///
  /// In en, this message translates to:
  /// **'{current}/{max} people'**
  String peopleCount(int current, int max);

  /// No description provided for @planPublishedToast.
  ///
  /// In en, this message translates to:
  /// **'Plan published.'**
  String get planPublishedToast;

  /// No description provided for @profileAvailabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Active times'**
  String get profileAvailabilityTitle;

  /// No description provided for @profileCompletion.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String profileCompletion(int percent);

  /// No description provided for @profileEditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust details that help people coordinate with you.'**
  String get profileEditSubtitle;

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditTitle;

  /// No description provided for @profilePhotoAdd.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get profilePhotoAdd;

  /// No description provided for @profilePhotoChange.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get profilePhotoChange;

  /// No description provided for @profilePhotoEmpty.
  ///
  /// In en, this message translates to:
  /// **'Choose a non-empty image file.'**
  String get profilePhotoEmpty;

  /// No description provided for @profilePhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile photo could not be updated.'**
  String get profilePhotoFailed;

  /// No description provided for @profilePhotoReady.
  ///
  /// In en, this message translates to:
  /// **'Profile photo is ready to save.'**
  String get profilePhotoReady;

  /// No description provided for @profilePhotoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get profilePhotoRemove;

  /// No description provided for @profilePhotoSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A clear, friendly photo helps people recognize you before a meetup.'**
  String get profilePhotoSectionSubtitle;

  /// No description provided for @profilePhotoSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhotoSectionTitle;

  /// No description provided for @profilePhotoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Choose an image smaller than 5 MB.'**
  String get profilePhotoTooLarge;

  /// No description provided for @profilePhotoUnsupportedType.
  ///
  /// In en, this message translates to:
  /// **'Use a JPG, PNG, or WebP image.'**
  String get profilePhotoUnsupportedType;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated.'**
  String get profilePhotoUpdated;

  /// No description provided for @profilePhotoUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading photo...'**
  String get profilePhotoUploading;

  /// No description provided for @profileGateAction.
  ///
  /// In en, this message translates to:
  /// **'Add a few details'**
  String get profileGateAction;

  /// No description provided for @profileGateMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a few more profile details to reach {completion}% and start joining or creating plans more easily.'**
  String profileGateMessage(int completion);

  /// No description provided for @profileGateTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a little more to your profile'**
  String get profileGateTitle;

  /// No description provided for @profileGroupPreferenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Group preference'**
  String get profileGroupPreferenceTitle;

  /// No description provided for @profileMoodLabel.
  ///
  /// In en, this message translates to:
  /// **'Social mood: {mood}'**
  String profileMoodLabel(String mood);

  /// No description provided for @profileQuickActionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Jump to the trust and preference tools that matter most.'**
  String get profileQuickActionsSubtitle;

  /// No description provided for @profileQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get profileQuickActionsTitle;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved.'**
  String get profileSaved;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get profileTitle;

  /// No description provided for @publishPlan.
  ///
  /// In en, this message translates to:
  /// **'Publish plan'**
  String get publishPlan;

  /// No description provided for @quickReplyConfirmTime.
  ///
  /// In en, this message translates to:
  /// **'Can we confirm the time?'**
  String get quickReplyConfirmTime;

  /// No description provided for @quickReplyOnMyWay.
  ///
  /// In en, this message translates to:
  /// **'I am on my way.'**
  String get quickReplyOnMyWay;

  /// No description provided for @quickReplyRunningLate.
  ///
  /// In en, this message translates to:
  /// **'Running a little late.'**
  String get quickReplyRunningLate;

  /// No description provided for @quickReplyShareArea.
  ///
  /// In en, this message translates to:
  /// **'I will share the approximate area.'**
  String get quickReplyShareArea;

  /// No description provided for @rejectRequest.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectRequest;

  /// No description provided for @reportUser.
  ///
  /// In en, this message translates to:
  /// **'Report user'**
  String get reportUser;

  /// No description provided for @requestStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get requestStatusApproved;

  /// No description provided for @requestStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get requestStatusCancelled;

  /// No description provided for @requestStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get requestStatusPending;

  /// No description provided for @requestStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get requestStatusRejected;

  /// No description provided for @safetyBlockedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} blocked'**
  String safetyBlockedCount(int count);

  /// No description provided for @safetyBlockedUsersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Blocked users stay hidden from lightweight coordination surfaces.'**
  String get safetyBlockedUsersSubtitle;

  /// No description provided for @safetyBlockedUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Blocked users'**
  String get safetyBlockedUsersTitle;

  /// No description provided for @safetyCenterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trust tools should be simple, direct, and never buried.'**
  String get safetyCenterSubtitle;

  /// No description provided for @safetyCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety center'**
  String get safetyCenterTitle;

  /// No description provided for @safetyEvent.
  ///
  /// In en, this message translates to:
  /// **'Safety event'**
  String get safetyEvent;

  /// No description provided for @safetyEventInternal.
  ///
  /// In en, this message translates to:
  /// **'Internal trust signal'**
  String get safetyEventInternal;

  /// No description provided for @safetyEventMeetupReminder.
  ///
  /// In en, this message translates to:
  /// **'Meetup reminder enabled'**
  String get safetyEventMeetupReminder;

  /// No description provided for @safetyEventPhoneVerified.
  ///
  /// In en, this message translates to:
  /// **'Phone verified'**
  String get safetyEventPhoneVerified;

  /// No description provided for @safetyEventReportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report submitted'**
  String get safetyEventReportSubmitted;

  /// No description provided for @safetyEventUserBlocked.
  ///
  /// In en, this message translates to:
  /// **'User blocked'**
  String get safetyEventUserBlocked;

  /// No description provided for @safetyEventVisible.
  ///
  /// In en, this message translates to:
  /// **'Visible in your safety timeline'**
  String get safetyEventVisible;

  /// No description provided for @safetyReportAlreadySubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report already submitted'**
  String get safetyReportAlreadySubmitted;

  /// No description provided for @safetyReportReasonDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the closest reason so moderation and safety review stay consistent.'**
  String get safetyReportReasonDialogHint;

  /// No description provided for @safetyReportReasonDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Why are you reporting this user?'**
  String get safetyReportReasonDialogTitle;

  /// No description provided for @safetyReportReasonFakeProfile.
  ///
  /// In en, this message translates to:
  /// **'Fake profile'**
  String get safetyReportReasonFakeProfile;

  /// No description provided for @safetyReportReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get safetyReportReasonHarassment;

  /// No description provided for @safetyReportReasonInappropriateContent.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get safetyReportReasonInappropriateContent;

  /// No description provided for @safetyReportReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get safetyReportReasonSpam;

  /// No description provided for @safetyReportReasonUnsafeMeetup.
  ///
  /// In en, this message translates to:
  /// **'Unsafe meetup behavior'**
  String get safetyReportReasonUnsafeMeetup;

  /// No description provided for @safetyReportedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reports'**
  String safetyReportedCount(int count);

  /// No description provided for @safetyReportSubmittedToast.
  ///
  /// In en, this message translates to:
  /// **'Report submitted.'**
  String get safetyReportSubmittedToast;

  /// No description provided for @safetyActionUnavailableToast.
  ///
  /// In en, this message translates to:
  /// **'Safety tools need an active session right now.'**
  String get safetyActionUnavailableToast;

  /// No description provided for @safetyActionFailedToast.
  ///
  /// In en, this message translates to:
  /// **'Safety action could not be completed right now.'**
  String get safetyActionFailedToast;

  /// No description provided for @safetySummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'A quick view of your recent trust actions.'**
  String get safetySummarySubtitle;

  /// No description provided for @safetySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety summary'**
  String get safetySummaryTitle;

  /// No description provided for @safetyTimelineEmpty.
  ///
  /// In en, this message translates to:
  /// **'No safety events yet.'**
  String get safetyTimelineEmpty;

  /// No description provided for @safetyTimelineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Important trust actions stay visible here.'**
  String get safetyTimelineSubtitle;

  /// No description provided for @safetyTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety timeline'**
  String get safetyTimelineTitle;

  /// No description provided for @safetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get safetyTitle;

  /// No description provided for @safetyUserAlreadyBlocked.
  ///
  /// In en, this message translates to:
  /// **'User already blocked'**
  String get safetyUserAlreadyBlocked;

  /// No description provided for @safetyUserBlockedToast.
  ///
  /// In en, this message translates to:
  /// **'User blocked.'**
  String get safetyUserBlockedToast;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get saveProfile;

  /// No description provided for @settingsApproximateLocation.
  ///
  /// In en, this message translates to:
  /// **'Use approximate location'**
  String get settingsApproximateLocation;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsPreferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tune privacy, reminders, and coordination defaults.'**
  String get settingsPreferencesSubtitle;

  /// No description provided for @settingsProfileShortcutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open your profile and update visible details.'**
  String get settingsProfileShortcutSubtitle;

  /// No description provided for @settingsSafeMeetupReminders.
  ///
  /// In en, this message translates to:
  /// **'Safe meetup reminders'**
  String get settingsSafeMeetupReminders;

  /// No description provided for @settingsSafetyLinkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open reporting, blocking, and trust timeline tools.'**
  String get settingsSafetyLinkSubtitle;

  /// No description provided for @settingsSafetyLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety tools'**
  String get settingsSafetyLinkTitle;

  /// No description provided for @settingsSignalsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recent signals yet.'**
  String get settingsSignalsEmpty;

  /// No description provided for @settingsSignalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recent product and trust actions show up here.'**
  String get settingsSignalsSubtitle;

  /// No description provided for @settingsSignalsSummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'A quick count of recent auth, safety, and coordination actions.'**
  String get settingsSignalsSummarySubtitle;

  /// No description provided for @settingsSignalsSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Signals summary'**
  String get settingsSignalsSummaryTitle;

  /// No description provided for @settingsSignalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent signals'**
  String get settingsSignalsTitle;

  /// No description provided for @settingsSummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review your current coordination preferences.'**
  String get settingsSummarySubtitle;

  /// No description provided for @settingsSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Current settings'**
  String get settingsSummaryTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @surfaceGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get surfaceGroups;

  /// No description provided for @surfaceNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get surfaceNearby;

  /// No description provided for @surfaceNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get surfaceNow;

  /// No description provided for @surfaceTonight.
  ///
  /// In en, this message translates to:
  /// **'Tonight'**
  String get surfaceTonight;

  /// No description provided for @surfaceWeekend.
  ///
  /// In en, this message translates to:
  /// **'Weekend'**
  String get surfaceWeekend;

  /// No description provided for @trustApprovalDescription.
  ///
  /// In en, this message translates to:
  /// **'Chat opens only after the plan owner approves the request.'**
  String get trustApprovalDescription;

  /// No description provided for @trustApprovalLabel.
  ///
  /// In en, this message translates to:
  /// **'Approval before chat'**
  String get trustApprovalLabel;

  /// No description provided for @trustApproximateLocationDescription.
  ///
  /// In en, this message translates to:
  /// **'Public discovery stays at area level by default.'**
  String get trustApproximateLocationDescription;

  /// No description provided for @trustApproximateLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Approximate location'**
  String get trustApproximateLocationLabel;

  /// No description provided for @trustToolsDescription.
  ///
  /// In en, this message translates to:
  /// **'Report and block tools stay easy to reach.'**
  String get trustToolsDescription;

  /// No description provided for @trustToolsLabel.
  ///
  /// In en, this message translates to:
  /// **'Trust tools'**
  String get trustToolsLabel;

  /// No description provided for @verificationPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone verified'**
  String get verificationPhone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
