class FirebaseCollectionPaths {
  const FirebaseCollectionPaths._();

  static const users = 'users';
  static const profiles = 'profiles';
  static const activities = 'activities';
  static const joinRequests = 'joinRequests';
  static const chatThreads = 'chatThreads';
  static const messages = 'messages';
  static const moderationEvents = 'moderationEvents';
  static const trustEvents = 'trustEvents';
  static const reports = 'reports';
  static const blocks = 'blocks';
  static const notificationTokens = 'notificationTokens';

  static String activityJoinRequests(String activityId) {
    return '$activities/$activityId/$joinRequests';
  }

  static String chatThreadMessages(String threadId) {
    return '$chatThreads/$threadId/$messages';
  }

  static String userNotificationTokens(String userId) {
    return '$users/$userId/$notificationTokens';
  }
}

class FirebaseDocumentFields {
  const FirebaseDocumentFields._();

  static const activityId = 'activityId';
  static const activeTimes = 'activeTimes';
  static const approximateLocation = 'approximateLocation';
  static const bio = 'bio';
  static const budgetLevel = 'budgetLevel';
  static const category = 'category';
  static const city = 'city';
  static const createdAt = 'createdAt';
  static const description = 'description';
  static const displayName = 'displayName';
  static const distanceKm = 'distanceKm';
  static const durationMinutes = 'durationMinutes';
  static const favoriteActivities = 'favoriteActivities';
  static const groupPreference = 'groupPreference';
  static const id = 'id';
  static const isIndoor = 'isIndoor';
  static const isUserVisible = 'isUserVisible';
  static const lastMessagePreview = 'lastMessagePreview';
  static const maxParticipants = 'maxParticipants';
  static const message = 'message';
  static const participantCount = 'participantCount';
  static const ownerUserId = 'ownerUserId';
  static const participantIds = 'participantIds';
  static const profileCompletion = 'profileCompletion';
  static const profilePhotoUrl = 'profilePhotoUrl';
  static const reason = 'reason';
  static const reasonCode = 'reasonCode';
  static const requesterId = 'requesterId';
  static const safetyBannerVisible = 'safetyBannerVisible';
  static const senderUserId = 'senderUserId';
  static const sentAt = 'sentAt';
  static const scheduledAt = 'scheduledAt';
  static const socialMood = 'socialMood';
  static const status = 'status';
  static const subjectUserId = 'subjectUserId';
  static const surfaces = 'surfaces';
  static const targetUserId = 'targetUserId';
  static const text = 'text';
  static const threadId = 'threadId';
  static const timeLabel = 'timeLabel';
  static const timeOption = 'timeOption';
  static const title = 'title';
  static const updatedAt = 'updatedAt';
  static const userId = 'userId';
  static const verificationLabel = 'verificationLabel';
  static const verificationLevel = 'verificationLevel';
  static const workflowSource = 'workflowSource';
  static const workflowStatus = 'workflowStatus';
}
