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
  static const activityPlanPublished = 'activity_plan_published';
  static const exploreSurfaceSelected = 'explore_surface_selected';
  static const exploreCategorySelected = 'explore_category_selected';
  static const onboardingCompleted = 'onboarding_completed';
  static const profileUpdated = 'profile_updated';
  static const joinRequestApproved = 'join_request_approved';
  static const joinRequestRejected = 'join_request_rejected';

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
        name == activityPlanPublished ||
        name == joinRequestApproved ||
        name == joinRequestRejected;
  }
}
