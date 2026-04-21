abstract final class AnalyticsEvents {
  static const settingsNotificationsToggled = 'settings_notifications_toggled';
  static const settingsLocationPrivacyToggled =
      'settings_location_privacy_toggled';
  static const settingsSafeMeetupToggled = 'settings_safe_meetup_toggled';
  static const sessionSignedOut = 'session_signed_out';
  static const safetyReportSubmitted = 'safety_report_submitted';
  static const safetyUserBlocked = 'safety_user_blocked';
  static const authPhoneSelected = 'auth_phone_selected';
  static const authGuestPreviewSelected = 'auth_guest_preview_selected';
  static const joinRequestSubmitted = 'join_request_submitted';
  static const mapJoinRequestSubmitted = 'map_join_request_submitted';
  static const mapNearbyJoinRequestSubmitted =
      'map_nearby_join_request_submitted';
  static const chatMessageSent = 'chat_message_sent';
  static const chatStarted = 'chat_started';
  static const activityPlanPublished = 'activity_plan_published';
  static const activityCreated = 'activity_created';
  static const activityBoosted = 'activity_boosted';
  static const exploreSurfaceSelected = 'explore_surface_selected';
  static const exploreCategorySelected = 'explore_category_selected';
  static const onboardingCompleted = 'onboarding_completed';
  static const profileUpdated = 'profile_updated';
  static const joinRequestApproved = 'join_request_approved';
  static const joinRequestRejected = 'join_request_rejected';
  static const adWatched = 'ad_watched';
  static const premiumClicked = 'premium_clicked';
  static const premiumConverted = 'premium_converted';
  static const planCompleted = 'plan_completed';

  static bool isAuthAction(String name) {
    return name == authPhoneSelected ||
        name == authGuestPreviewSelected ||
        name == sessionSignedOut;
  }

  static bool isSafetyAction(String name) {
    return name == safetyReportSubmitted ||
        name == safetyUserBlocked ||
        name == settingsSafeMeetupToggled;
  }

  static bool isCoordinationAction(String name) {
    return name == joinRequestSubmitted ||
        name == mapJoinRequestSubmitted ||
        name == mapNearbyJoinRequestSubmitted ||
        name == chatMessageSent ||
        name == chatStarted ||
        name == activityPlanPublished ||
        name == activityCreated ||
        name == activityBoosted ||
        name == joinRequestApproved ||
        name == joinRequestRejected;
  }
}
