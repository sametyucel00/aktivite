import 'package:aktivite/core/config/sample_ids.dart';
import 'package:aktivite/core/utils/app_time.dart';
import 'package:aktivite/shared/models/moderation_event.dart';

abstract final class TrustEventReasonCodes {
  static const phoneVerified = 'phone_verified';
  static const safeMeetupReminderEnabled = 'safe_meetup_reminder_enabled';
  static const reportSubmitted = 'report_submitted';
  static const userBlocked = 'user_blocked';
  static const guestUserId = SampleIds.guestOne;

  static String reportSubmittedFor(String userId) {
    return '$reportSubmitted:$userId';
  }

  static String userBlockedFor(String userId) {
    return '$userBlocked:$userId';
  }

  static String root(String reasonCode) {
    return reasonCode.split(':').first;
  }

  static String? targetUserId(String reasonCode) {
    final parts = reasonCode.split(':');
    if (parts.length < 2 || parts.last.isEmpty) {
      return null;
    }
    return parts.last;
  }
}

ModerationEvent createSafeMeetupReminderTrustEvent({
  required String subjectUserId,
  DateTime? now,
}) {
  final createdAt = now ?? AppClock.now();
  return ModerationEvent(
    id: AppIdFactory.timestampId(prefix: 'trust-reminder', now: createdAt),
    subjectUserId: subjectUserId,
    reasonCode: TrustEventReasonCodes.safeMeetupReminderEnabled,
    isUserVisible: true,
    createdAt: createdAt,
  );
}

ModerationEvent createReportSubmittedTrustEvent({
  required String subjectUserId,
  required String reportedUserId,
  DateTime? now,
}) {
  final createdAt = now ?? AppClock.now();
  return ModerationEvent(
    id: AppIdFactory.timestampId(prefix: 'trust-report', now: createdAt),
    subjectUserId: subjectUserId,
    reasonCode: TrustEventReasonCodes.reportSubmittedFor(reportedUserId),
    isUserVisible: true,
    createdAt: createdAt,
  );
}

ModerationEvent createUserBlockedTrustEvent({
  required String subjectUserId,
  required String blockedUserId,
  DateTime? now,
}) {
  final createdAt = now ?? AppClock.now();
  return ModerationEvent(
    id: AppIdFactory.timestampId(prefix: 'trust-block', now: createdAt),
    subjectUserId: subjectUserId,
    reasonCode: TrustEventReasonCodes.userBlockedFor(blockedUserId),
    isUserVisible: true,
    createdAt: createdAt,
  );
}

bool isSafeMeetupReminderTrustEvent(ModerationEvent event) {
  return event.reasonCode == TrustEventReasonCodes.safeMeetupReminderEnabled;
}

bool isReportSubmittedTrustEvent(ModerationEvent event) {
  return TrustEventReasonCodes.root(event.reasonCode) ==
      TrustEventReasonCodes.reportSubmitted;
}

bool isUserBlockedTrustEvent(ModerationEvent event) {
  return TrustEventReasonCodes.root(event.reasonCode) ==
      TrustEventReasonCodes.userBlocked;
}

bool shouldCreateSafeMeetupReminderTrustEvent({
  required String? userId,
  required bool enabled,
  required Iterable<ModerationEvent> existingEvents,
}) {
  if (!enabled || userId == null) {
    return false;
  }

  return !existingEvents.any(isSafeMeetupReminderTrustEvent);
}
