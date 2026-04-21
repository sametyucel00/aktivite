import 'dart:async';

import 'package:aktivite/core/services/analytics_service.dart';
import 'package:aktivite/core/services/remote_config_service.dart';
import 'package:aktivite/features/activities/data/activity_repository.dart';
import 'package:aktivite/features/activities/data/join_request_repository.dart';
import 'package:aktivite/features/chat/data/chat_repository.dart';
import 'package:aktivite/features/safety/data/moderation_repository.dart';
import 'package:aktivite/features/safety/data/safety_repository.dart';
import 'package:aktivite/core/enums/join_request_status.dart';
import 'package:aktivite/shared/models/activity_plan.dart';
import 'package:aktivite/shared/models/analytics_event_record.dart';
import 'package:aktivite/shared/models/chat_message.dart';
import 'package:aktivite/shared/models/chat_thread.dart';
import 'package:aktivite/shared/models/join_request.dart';
import 'package:aktivite/shared/models/moderation_event.dart';

class FakeActivityRepository implements ActivityRepository {
  FakeActivityRepository(this.plans);

  final List<ActivityPlan> plans;

  @override
  Future<void> createPlan(ActivityPlan plan) async {}

  @override
  Future<void> incrementParticipantCount(String activityId) async {}

  @override
  Future<void> applyBoost({
    required String activityId,
    required DateTime expiresAt,
    int boostLevel = 1,
  }) async {}

  @override
  Stream<List<ActivityPlan>> watchNearbyPlans() => Stream.value(plans);
}

class FakeJoinRequestRepository implements JoinRequestRepository {
  FakeJoinRequestRepository({
    required Map<String, List<JoinRequest>> requestsByActivityId,
  }) : _requestsByActivityId = requestsByActivityId;

  final Map<String, List<JoinRequest>> _requestsByActivityId;
  String? lastCancelledRequestId;
  String? lastUpdatedRequestId;

  @override
  Future<void> cancelJoinRequest({required String requestId}) async {
    lastCancelledRequestId = requestId;
  }

  @override
  Future<void> submitJoinRequest({
    required String activityId,
    required String message,
  }) async {}

  @override
  Future<void> updateRequestStatus({
    required String requestId,
    required JoinRequestStatus status,
  }) async {
    lastUpdatedRequestId = requestId;
  }

  @override
  Stream<List<JoinRequest>> watchRequestsForActivity(String activityId) {
    return Stream.value(
        _requestsByActivityId[activityId] ?? const <JoinRequest>[]);
  }
}

class FakeChatRepository implements ChatRepository {
  FakeChatRepository({
    required this.threads,
    required this.messagesByThreadId,
    this.throwOnSend = false,
  });

  final List<ChatThread> threads;
  final Map<String, List<ChatMessage>> messagesByThreadId;
  final bool throwOnSend;
  String? lastThreadId;
  String? lastMessage;

  @override
  Future<void> ensureThreadForActivity({
    required String activityId,
    required List<String> participantIds,
    required String initialMessagePreview,
  }) async {}

  @override
  Future<void> sendMessage({
    required String threadId,
    required String senderUserId,
    required String message,
  }) async {
    lastThreadId = threadId;
    lastMessage = message;
    if (throwOnSend) {
      throw StateError('send failed');
    }
  }

  @override
  Stream<List<ChatThread>> watchApprovedThreads() => Stream.value(threads);

  @override
  Stream<List<ChatMessage>> watchMessages(String threadId) {
    return Stream.value(messagesByThreadId[threadId] ?? const <ChatMessage>[]);
  }
}

class FakeSafetyRepository implements SafetyRepository {
  String? lastReportedTargetUserId;
  String? lastReportReason;
  String? lastBlockedTargetUserId;
  final Set<String> blockedUserIds = <String>{};
  final Map<String, List<String>> reportedReasonsByUser =
      <String, List<String>>{};

  @override
  Future<void> blockUser({required String targetUserId}) async {
    lastBlockedTargetUserId = targetUserId;
    blockedUserIds.add(targetUserId);
  }

  @override
  Future<void> reportUser({
    required String targetUserId,
    required String reason,
  }) async {
    lastReportedTargetUserId = targetUserId;
    lastReportReason = reason;
    final reasons = reportedReasonsByUser.putIfAbsent(
      targetUserId,
      () => <String>[],
    );
    if (!reasons.contains(reason)) {
      reasons.add(reason);
    }
  }

  @override
  Stream<Set<String>> watchBlockedUserIds() {
    return Stream.value(Set<String>.unmodifiable(blockedUserIds));
  }

  @override
  Stream<Map<String, List<String>>> watchReportedReasonsByUser() {
    return Stream.value({
      for (final entry in reportedReasonsByUser.entries)
        entry.key: List<String>.unmodifiable(entry.value),
    });
  }
}

class FakeModerationRepository implements ModerationRepository {
  FakeModerationRepository({
    List<ModerationEvent> initialEvents = const <ModerationEvent>[],
  }) : _events = initialEvents;

  final List<ModerationEvent> _events;
  ModerationEvent? lastCreatedEvent;

  @override
  Future<void> createTrustEvent(ModerationEvent event) async {
    lastCreatedEvent = event;
    _events.add(event);
  }

  @override
  Stream<List<ModerationEvent>> watchTrustEvents(String userId) {
    return Stream.value(
      _events.where((event) => event.subjectUserId == userId).toList(),
    );
  }
}

class FakeAnalyticsService implements AnalyticsService {
  final List<String> loggedEvents = <String>[];

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?> parameters = const {},
  }) async {
    loggedEvents.add(name);
  }

  @override
  Stream<List<AnalyticsEventRecord>> watchEvents() {
    return const Stream<List<AnalyticsEventRecord>>.empty();
  }
}

class FakeRemoteConfigService implements RemoteConfigService {
  const FakeRemoteConfigService({
    this.bools = const <String, bool>{},
    this.strings = const <String, String>{},
  });

  final Map<String, bool> bools;
  final Map<String, String> strings;

  @override
  bool getBool(String key) => bools[key] ?? false;

  @override
  String getString(String key) => strings[key] ?? '';
}
