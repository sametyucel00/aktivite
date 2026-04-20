import 'package:aktivite/core/config/firebase_collection_paths.dart';
import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/availability_slot.dart';
import 'package:aktivite/core/enums/discovery_surface.dart';
import 'package:aktivite/core/enums/plan_time_option.dart';
import 'package:aktivite/core/utils/enum_codecs.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:aktivite/shared/models/app_user_profile.dart';
import 'package:aktivite/shared/models/chat_message.dart';
import 'package:aktivite/shared/models/chat_thread.dart';
import 'package:aktivite/shared/models/join_request.dart';
import 'package:aktivite/shared/models/moderation_event.dart';

typedef ModelMap = Map<String, Object?>;

ModelMap activityPlanToMap(ActivityPlan plan) {
  return {
    FirebaseDocumentFields.id: plan.id,
    FirebaseDocumentFields.ownerUserId: plan.ownerUserId,
    FirebaseDocumentFields.title: plan.title,
    FirebaseDocumentFields.category: enumName(plan.category),
    FirebaseDocumentFields.description: plan.description,
    FirebaseDocumentFields.city: plan.city,
    FirebaseDocumentFields.approximateLocation: plan.approximateLocation,
    FirebaseDocumentFields.timeLabel: plan.timeLabel,
    FirebaseDocumentFields.timeOption: plan.timeOption?.name,
    FirebaseDocumentFields.scheduledAt: plan.scheduledAt.toIso8601String(),
    FirebaseDocumentFields.durationMinutes: plan.durationMinutes,
    FirebaseDocumentFields.participantCount: plan.participantCount,
    FirebaseDocumentFields.maxParticipants: plan.maxParticipants,
    FirebaseDocumentFields.distanceKm: plan.distanceKm,
    FirebaseDocumentFields.isIndoor: plan.isIndoor,
    FirebaseDocumentFields.status: enumName(plan.status),
    FirebaseDocumentFields.surfaces: enumNames(plan.surfaces),
  };
}

ActivityPlan activityPlanFromMap(String id, ModelMap map) {
  final surfaces = enumListFromNames(
    DiscoverySurface.values,
    map[FirebaseDocumentFields.surfaces],
  );
  return ActivityPlan(
    id: id,
    ownerUserId: _string(map[FirebaseDocumentFields.ownerUserId]),
    title: _string(map[FirebaseDocumentFields.title]),
    category: activityCategoryFromName(map[FirebaseDocumentFields.category]),
    description: _string(map[FirebaseDocumentFields.description]),
    city: _string(map[FirebaseDocumentFields.city]),
    approximateLocation:
        _string(map[FirebaseDocumentFields.approximateLocation]),
    timeLabel: _string(map[FirebaseDocumentFields.timeLabel]),
    timeOption: enumFromNameOrNull(
      PlanTimeOption.values,
      map[FirebaseDocumentFields.timeOption],
    ),
    scheduledAt: _dateTime(map[FirebaseDocumentFields.scheduledAt]),
    durationMinutes: _int(
      map[FirebaseDocumentFields.durationMinutes],
      fallback: 60,
    ),
    participantCount:
        _int(map[FirebaseDocumentFields.participantCount], fallback: 1),
    maxParticipants:
        _int(map[FirebaseDocumentFields.maxParticipants], fallback: 2),
    distanceKm: _doubleOrNull(map[FirebaseDocumentFields.distanceKm]),
    isIndoor: _bool(map[FirebaseDocumentFields.isIndoor], fallback: true),
    status: activityStatusFromName(map[FirebaseDocumentFields.status]),
    surfaces: surfaces.isEmpty ? const [DiscoverySurface.nearby] : surfaces,
  );
}

ModelMap appUserProfileToMap(AppUserProfile profile) {
  return {
    FirebaseDocumentFields.displayName: profile.displayName,
    FirebaseDocumentFields.profilePhotoUrl: profile.profilePhotoUrl,
    FirebaseDocumentFields.city: profile.city,
    FirebaseDocumentFields.bio: profile.bio,
    FirebaseDocumentFields.profileCompletion: profile.profileCompletion,
    FirebaseDocumentFields.favoriteActivities: enumNames(
      profile.favoriteActivities,
    ),
    FirebaseDocumentFields.activeTimes: enumNames(profile.activeTimes),
    FirebaseDocumentFields.groupPreference: enumName(profile.groupPreference),
    FirebaseDocumentFields.socialMood: enumName(profile.socialMood),
    FirebaseDocumentFields.verificationLabel: profile.verificationLabel,
    FirebaseDocumentFields.verificationLevel: enumName(
      profile.verificationLevel,
    ),
  };
}

AppUserProfile appUserProfileFromMap(String id, ModelMap map) {
  return AppUserProfile(
    id: id,
    displayName: _string(map[FirebaseDocumentFields.displayName]),
    profilePhotoUrl: _string(map[FirebaseDocumentFields.profilePhotoUrl]),
    city: _string(map[FirebaseDocumentFields.city]),
    bio: _string(map[FirebaseDocumentFields.bio]),
    profileCompletion: _int(map[FirebaseDocumentFields.profileCompletion]),
    favoriteActivities: enumListFromNames(
      ActivityCategory.values,
      map[FirebaseDocumentFields.favoriteActivities],
    ),
    activeTimes: enumListFromNames(
      AvailabilitySlot.values,
      map[FirebaseDocumentFields.activeTimes],
    ),
    groupPreference: groupPreferenceFromName(
      map[FirebaseDocumentFields.groupPreference],
    ),
    socialMood: socialMoodFromName(map[FirebaseDocumentFields.socialMood]),
    verificationLabel: _string(map[FirebaseDocumentFields.verificationLabel]),
    verificationLevel: verificationLevelFromName(
      map[FirebaseDocumentFields.verificationLevel],
    ),
  );
}

ModelMap joinRequestToMap(JoinRequest request) {
  return {
    FirebaseDocumentFields.activityId: request.activityId,
    FirebaseDocumentFields.requesterId: request.requesterId,
    FirebaseDocumentFields.message: request.message,
    FirebaseDocumentFields.status: enumName(request.status),
  };
}

JoinRequest joinRequestFromMap(String id, ModelMap map) {
  return JoinRequest(
    id: id,
    activityId: _string(map[FirebaseDocumentFields.activityId]),
    requesterId: _string(map[FirebaseDocumentFields.requesterId]),
    message: _string(map[FirebaseDocumentFields.message]),
    status: joinRequestStatusFromName(map[FirebaseDocumentFields.status]),
  );
}

ModelMap chatThreadToMap(ChatThread thread) {
  return {
    FirebaseDocumentFields.activityId: thread.activityId,
    FirebaseDocumentFields.participantIds: thread.participantIds,
    FirebaseDocumentFields.lastMessagePreview: thread.lastMessagePreview,
    FirebaseDocumentFields.safetyBannerVisible: thread.safetyBannerVisible,
  };
}

ChatThread chatThreadFromMap(String id, ModelMap map) {
  return ChatThread(
    id: id,
    activityId: _string(map[FirebaseDocumentFields.activityId]),
    participantIds: _stringList(map[FirebaseDocumentFields.participantIds]),
    lastMessagePreview: _string(
      map[FirebaseDocumentFields.lastMessagePreview],
    ),
    safetyBannerVisible: _bool(
      map[FirebaseDocumentFields.safetyBannerVisible],
    ),
  );
}

ModelMap chatMessageToMap(ChatMessage message) {
  return {
    FirebaseDocumentFields.threadId: message.threadId,
    FirebaseDocumentFields.senderUserId: message.senderUserId,
    FirebaseDocumentFields.text: message.text,
    FirebaseDocumentFields.sentAt: message.sentAt.toIso8601String(),
  };
}

ChatMessage chatMessageFromMap(String id, ModelMap map) {
  return ChatMessage(
    id: id,
    threadId: _string(map[FirebaseDocumentFields.threadId]),
    senderUserId: _string(map[FirebaseDocumentFields.senderUserId]),
    text: _string(map[FirebaseDocumentFields.text]),
    sentAt: _dateTime(map[FirebaseDocumentFields.sentAt]),
  );
}

ModelMap moderationEventToMap(ModerationEvent event) {
  return {
    FirebaseDocumentFields.subjectUserId: event.subjectUserId,
    FirebaseDocumentFields.reasonCode: event.reasonCode,
    FirebaseDocumentFields.isUserVisible: event.isUserVisible,
    FirebaseDocumentFields.createdAt: event.createdAt.toIso8601String(),
  };
}

ModerationEvent moderationEventFromMap(String id, ModelMap map) {
  return ModerationEvent(
    id: id,
    subjectUserId: _string(map[FirebaseDocumentFields.subjectUserId]),
    reasonCode: _string(map[FirebaseDocumentFields.reasonCode]),
    isUserVisible: _bool(map[FirebaseDocumentFields.isUserVisible]),
    createdAt: _dateTime(map[FirebaseDocumentFields.createdAt]),
  );
}

String _string(Object? value, {String fallback = ''}) {
  return value is String ? value : fallback;
}

int _int(Object? value, {int fallback = 0}) {
  return value is int ? value : fallback;
}

double? _doubleOrNull(Object? value) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  return null;
}

bool _bool(Object? value, {bool fallback = false}) {
  return value is bool ? value : fallback;
}

List<String> _stringList(Object? value) {
  if (value is! Iterable) {
    return const [];
  }
  return value.whereType<String>().toList(growable: false);
}

DateTime _dateTime(Object? value) {
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}
