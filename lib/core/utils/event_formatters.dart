import 'package:aktivite/core/utils/analytics_events.dart';
import 'package:aktivite/core/utils/trust_event_factory.dart';
import 'package:aktivite/l10n/app_localizations.dart';
import 'package:aktivite/shared/models/analytics_event_record.dart';
import 'package:aktivite/shared/models/moderation_event.dart';

String trustEventTitle(
  AppLocalizations l10n,
  ModerationEvent event,
) {
  final reasonCode = TrustEventReasonCodes.root(event.reasonCode);
  switch (reasonCode) {
    case TrustEventReasonCodes.phoneVerified:
      return l10n.safetyEventPhoneVerified;
    case TrustEventReasonCodes.safeMeetupReminderEnabled:
      return l10n.safetyEventMeetupReminder;
    case TrustEventReasonCodes.reportSubmitted:
      return l10n.safetyEventReportSubmitted;
    case TrustEventReasonCodes.userBlocked:
      return l10n.safetyEventUserBlocked;
    default:
      return l10n.safetyTitle;
  }
}

String trustEventSubtitle(
  AppLocalizations l10n,
  ModerationEvent event,
) {
  return event.isUserVisible
      ? l10n.safetyEventVisible
      : l10n.safetyEventInternal;
}

String analyticsEventTitle(
  AppLocalizations l10n,
  AnalyticsEventRecord event,
) {
  switch (event.name) {
    case AnalyticsEvents.settingsNotificationsToggled:
      return l10n.analyticsSettingsNotifications;
    case AnalyticsEvents.settingsLocationPrivacyToggled:
      return l10n.analyticsSettingsLocationPrivacy;
    case AnalyticsEvents.settingsSafeMeetupToggled:
      return l10n.analyticsSettingsSafeMeetup;
    case AnalyticsEvents.sessionSignedOut:
      return l10n.analyticsSessionSignedOut;
    case AnalyticsEvents.safetyReportSubmitted:
      return l10n.analyticsSafetyReportSubmitted;
    case AnalyticsEvents.safetyUserBlocked:
      return l10n.analyticsSafetyUserBlocked;
    case AnalyticsEvents.authPhoneSelected:
      return l10n.analyticsAuthPhoneSelected;
    case AnalyticsEvents.authGuestPreviewSelected:
      return l10n.analyticsAuthGuestPreviewSelected;
    case AnalyticsEvents.joinRequestSubmitted:
      return l10n.analyticsJoinRequestSubmitted;
    case AnalyticsEvents.mapJoinRequestSubmitted:
      return l10n.analyticsMapJoinRequestSubmitted;
    case AnalyticsEvents.mapNearbyJoinRequestSubmitted:
      return l10n.analyticsMapNearbyJoinRequestSubmitted;
    case AnalyticsEvents.chatMessageSent:
      return l10n.analyticsChatMessageSent;
    case AnalyticsEvents.activityPlanPublished:
      return l10n.analyticsPlanPublished;
    case AnalyticsEvents.exploreSurfaceSelected:
      return l10n.analyticsExploreSurfaceSelected;
    case AnalyticsEvents.exploreCategorySelected:
      return l10n.analyticsExploreCategorySelected;
    case AnalyticsEvents.onboardingCompleted:
      return l10n.analyticsOnboardingCompleted;
    case AnalyticsEvents.profileUpdated:
      return l10n.analyticsProfileUpdated;
    case AnalyticsEvents.joinRequestApproved:
      return l10n.analyticsJoinRequestApproved;
    case AnalyticsEvents.joinRequestRejected:
      return l10n.analyticsJoinRequestRejected;
    default:
      return event.name;
  }
}

String boolStateLabel(
  AppLocalizations l10n,
  bool value,
) {
  return value ? l10n.commonOn : l10n.commonOff;
}

String formatTimeLabel(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
