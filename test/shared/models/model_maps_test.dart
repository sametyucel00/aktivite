import 'package:aktivite/core/enums/activity_category.dart';
import 'package:aktivite/core/enums/activity_status.dart';
import 'package:aktivite/core/enums/availability_slot.dart';
import 'package:aktivite/core/enums/discovery_surface.dart';
import 'package:aktivite/core/enums/group_preference.dart';
import 'package:aktivite/core/enums/join_request_status.dart';
import 'package:aktivite/core/enums/plan_time_option.dart';
import 'package:aktivite/core/enums/social_mood.dart';
import 'package:aktivite/core/enums/verification_level.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:aktivite/shared/models/app_user_profile.dart';
import 'package:aktivite/shared/models/chat_message.dart';
import 'package:aktivite/shared/models/chat_thread.dart';
import 'package:aktivite/shared/models/join_request.dart';
import 'package:aktivite/shared/models/model_maps.dart';
import 'package:aktivite/shared/models/moderation_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('model maps', () {
    test('activityPlan round-trip preserves typed time option and surfaces',
        () {
      final plan = ActivityPlan(
        id: 'plan-1',
        ownerUserId: 'user-1',
        title: 'Coffee now',
        category: ActivityCategory.coffee,
        description: 'Quick meetup',
        city: 'Istanbul',
        approximateLocation: 'Kadikoy center',
        timeLabel: 'Now',
        timeOption: PlanTimeOption.now,
        scheduledAt: DateTime.utc(2026, 4, 19, 17, 30),
        durationMinutes: 45,
        participantCount: 2,
        maxParticipants: 4,
        isIndoor: true,
        status: ActivityStatus.open,
        surfaces: [
          DiscoverySurface.now,
          DiscoverySurface.nearby,
        ],
      );

      final restored = activityPlanFromMap(plan.id, activityPlanToMap(plan));

      expect(restored.id, plan.id);
      expect(restored.ownerUserId, plan.ownerUserId);
      expect(restored.timeOption, PlanTimeOption.now);
      expect(restored.surfaces, plan.surfaces);
      expect(restored.approximateLocation, plan.approximateLocation);
      expect(restored.durationMinutes, plan.durationMinutes);
    });

    test('activityPlan fallback keeps nearby surface when list is missing', () {
      final restored = activityPlanFromMap('plan-2', {
        'ownerUserId': 'user-1',
        'title': 'Walk later',
        'category': 'walk',
        'description': 'Simple walk',
        'city': 'Istanbul',
        'approximateLocation': 'Moda coast',
        'timeLabel': 'Tonight',
        'scheduledAt': '2026-04-19T19:00:00.000Z',
        'durationMinutes': 60,
        'status': 'open',
      });

      expect(restored.surfaces, const [DiscoverySurface.nearby]);
      expect(restored.timeOption, isNull);
      expect(restored.durationMinutes, 60);
    });

    test('appUserProfile round-trip preserves enum lists', () {
      const profile = AppUserProfile(
        id: 'user-42',
        displayName: 'Samet',
        profilePhotoUrl: 'https://example.com/profile.jpg',
        city: 'Istanbul',
        bio: 'Coffee and walks',
        profileCompletion: 88,
        favoriteActivities: [
          ActivityCategory.coffee,
          ActivityCategory.walk,
        ],
        activeTimes: [
          AvailabilitySlot.evenings,
          AvailabilitySlot.weekends,
        ],
        groupPreference: GroupPreference.smallGroup,
        socialMood: SocialMood.casual,
        verificationLabel: 'Phone verified',
        verificationLevel: VerificationLevel.phone,
      );

      final restored = appUserProfileFromMap(
        profile.id,
        appUserProfileToMap(profile),
      );

      expect(restored.favoriteActivities, profile.favoriteActivities);
      expect(restored.activeTimes, profile.activeTimes);
      expect(restored.groupPreference, profile.groupPreference);
      expect(restored.verificationLevel, profile.verificationLevel);
      expect(restored.profilePhotoUrl, profile.profilePhotoUrl);
    });

    test('joinRequest and chat models round-trip through maps', () {
      const request = JoinRequest(
        id: 'request-1',
        activityId: 'plan-1',
        requesterId: 'user-2',
        message: 'Is there room for one more?',
        status: JoinRequestStatus.pending,
      );
      const thread = ChatThread(
        id: 'thread-1',
        activityId: 'plan-1',
        participantIds: ['user-1', 'user-2'],
        lastMessagePreview: 'See you there',
        safetyBannerVisible: true,
      );

      final restoredRequest = joinRequestFromMap(
        request.id,
        joinRequestToMap(request),
      );
      final restoredThread =
          chatThreadFromMap(thread.id, chatThreadToMap(thread));

      expect(restoredRequest.status, JoinRequestStatus.pending);
      expect(restoredThread.participantIds, thread.participantIds);
      expect(restoredThread.safetyBannerVisible, isTrue);
    });

    test('chatMessage and moderationEvent parse ISO timestamps', () {
      final sentAt = DateTime.utc(2026, 4, 18, 19, 30);
      final createdAt = DateTime.utc(2026, 4, 18, 20, 15);
      final message = ChatMessage(
        id: 'message-1',
        threadId: 'thread-1',
        senderUserId: 'user-1',
        text: 'On my way',
        sentAt: sentAt,
      );
      final event = ModerationEvent(
        id: 'event-1',
        subjectUserId: 'user-1',
        reasonCode: 'report_submitted:user-2',
        isUserVisible: true,
        createdAt: createdAt,
      );

      final restoredMessage = chatMessageFromMap(
        message.id,
        chatMessageToMap(message),
      );
      final restoredEvent = moderationEventFromMap(
        event.id,
        moderationEventToMap(event),
      );

      expect(restoredMessage.sentAt, sentAt);
      expect(restoredEvent.createdAt, createdAt);
    });
  });
}
